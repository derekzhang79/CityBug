var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model'),
    mockup_places = require('../mockup/places');
    
var sys = require('sys'),
express = require('express'),
assert = require('assert');

var KEYS = require('../key');

var CLIENT_ID = KEYS.CLIENT_ID;
var CLIENT_SECRET = KEYS.CLIENT_SECRET;
var REDIRECT_URI = KEYS.HOST;

var foursquare = (require('foursquarevenues'))(CLIENT_ID, CLIENT_SECRET); 


exports.places = function(req, res){

    model.Place.find({})
        .exec(function (err, docs) {
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Can not get place");
            res.end();
            return;
        } else {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "places":' + JSON.stringify(docs) + '}');
            res.end();
            return;
        }
    });
    
};

/*
foursquare.getVenues(params, function(error, venues) {  
    if (!error) {  
        console.log(venues);  
    }  
});  
foursquare.exploreVenues(params, function(error, venues) {  
    if (!error) {  
          console.log(venues);  
    }  
});
*/

exports.place_search = function(req, res){
/*
    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
    res.write(JSON.stringify(mockup_places));
    res.end()
*/

	var lat = req.query.lat;
	var lng = req.query.lng;

	console.log("get request param >> "+ JSON.stringify(req.query));
	var params = {  
	    "ll": lat + "," + lng  
	};
	console.log("parameters = "+JSON.stringify(params));


	foursquare.getVenues(params, function(error, venues) {  
	    if (!error && venues != null && venues.response != null && venues.response.venues != null) {  
	        // console.log(JSON.stringify(venues.response.venues));

    		//------------------------ Manage 4sq places ---------------------------------
			var itemArray = venues.response.venues;;
			var foursquarePlaceArray = [];
			var foursquarePlaceIDArray = [];

			for (i in itemArray) {
				//Create place object from 4sq data
				var newPlace = new model.Place();
				newPlace.id_foursquare = itemArray[i].id;		
				newPlace.title = itemArray[i].name;			
				newPlace.distance = itemArray[i].location.distance;
				newPlace.type = 'additional';
				newPlace.lat = itemArray[i].location.lat;
				newPlace.lng = itemArray[i].location.lng;
				newPlace.last_modified = new Date();
				newPlace.created_at = new Date();

				foursquarePlaceArray.push(newPlace);
				foursquarePlaceIDArray.push(itemArray[i].id);
			}

			//Sort 4sq place by distance
			foursquarePlaceArray = foursquarePlaceArray.sort(function(a, b) {
				if (a.distance < b.distance) { return -1; }
				if (a.distance > b.distance) { return  1; }
				return 0;
			});
			console.log("Get place from foursquare "+foursquarePlaceArray.length + " places");

			//------------------------ Manage server places ---------------------------------
			
			model.Place.find({}).exec(function (err, serverPlace) {
	            var serverPlaceArray = [];
	            if (err) { 
	                console.log("error find place " + err);
	            } else {
					for (i in serverPlace) {
						serverPlace[i].type = 'suggested';
						//Calculate distance in each server place
						serverPlace[i].distance = service.distanceCalculate(serverPlace[i].lat, serverPlace[i].lng, lat, lng);
						serverPlaceArray.push(serverPlace[i]);
					}
	            
		            //Sort server place by distance
					serverPlaceArray = serverPlaceArray.sort(function(a, b) {
						if (a.distance < b.distance) { return -1; }
						if (a.distance > b.distance) { return  1; }
						return 0;
					});
				}

				//Get only first 30 sorted places
				var thirtyServerPlaceArray;
				if (serverPlaceArray != null && serverPlaceArray.length > 30) 
					thirtyServerPlaceArray = serverPlaceArray.slice(0,30);
				else
					thirtyServerPlaceArray = serverPlaceArray;

				console.log("Get place from server "+thirtyServerPlaceArray.length + " places");						

				// Remove duplicate place from 4sq place (at variable name "placeArray")
				for (j in serverPlaceArray) {
					var tmpID = serverPlaceArray[i].id_foursquare;
					if (foursquarePlaceIDArray.indexOf(tmpID) != -1) {
						var index = foursquarePlaceIDArray.indexOf(tmpID);
						foursquarePlaceIDArray = foursquarePlaceIDArray.splice(index, 1);  //remove object at index
						foursquarePlaceArray = foursquarePlaceArray.splice(index, 1);
					}
				}

	            //---------------------------------------- Send response ----------------------------------
	            var responseArray = [];
	            responseArray = responseArray.concat(thirtyServerPlaceArray, foursquarePlaceArray);
				var responseString = '{ "places":'+ JSON.stringify(responseArray) + ' }';
				
				res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
				res.write(responseString);
			    res.end();
	    	});

		} else {
			res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.write("Cannot Find Place");
		    res.end();
		}  
	});  
}


