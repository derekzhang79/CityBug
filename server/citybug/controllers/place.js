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
	var queryText = req.query.text;

	console.log("get request param >> "+ JSON.stringify(req.query));

	//------------------------ Manage server places ---------------------------------
	model.Place.find({}).exec(function (err, serverPlace) {

        if (err || serverPlace == null) { 
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.write("Can not Find Place");
		    res.end();
		    return;
		}

		//ถ้า  GET /api/place/search? ไม่ได้ส่ง lat lng และ queryText มา จะ return server place แบบ sort by alphabet
		if ((lat == null || lng == null) && queryText == null) {
			console.log("lat lng text is null!");
			serverPlace = serverPlace.sort(function(a, b) { 
			 	a.type = 'suggested';
			 	b.type = 'suggested';
				var ret = 0;
				var aCompare = a.title.toLowerCase();
				var bCompare = b.title.toLowerCase();
				if(aCompare > bCompare) 
					ret = 1;
				if(aCompare < bCompare) 
					ret = -1; 
				return ret;
			});
			//---------------------------------------- Send response ----------------------------------
			res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.write('{ "places":'+ JSON.stringify( serverPlace.slice(0,30) ) + ' }');
		    res.end();
		    return;
		} 
		//ถ้า  GET /api/place/search? ไม่ได้ส่ง lat lng แต่ส่ง queryText มา จะ return server place แบบ search ตาม text แล้ว
		else if ((lat == null || lng == null) && queryText != null) {
			console.log("lat lng is null but text is not null!");
			var serverPlaceFilterdByQueryTextArray = [];

			//remove '\' to avoid crash of regex
			queryText = queryText.replace(/\\/g, '');
			console.log("new query text = "+queryText);
			var queryString = new RegExp(queryText, 'i');

			//Get only place that have query text
			for (i in serverPlace) {
				serverPlace[i].type = 'suggested';
				if (serverPlace[i].title.search(queryString) != -1) {
					serverPlaceFilterdByQueryTextArray.push(serverPlace[i]);
				}
			}
			//Sort server place by index of query text
			serverPlaceFilterdByQueryTextArray = serverPlaceFilterdByQueryTextArray.sort(function(a, b) {
				if (a.title.search(queryString) < b.title.search(queryString)) { return -1; }
				if (a.title.search(queryString) > b.title.search(queryString)) { return  1; }
				return 0;
			});
			//---------------------------------------- Send response ----------------------------------
			res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.write('{ "places":'+ JSON.stringify( serverPlaceFilterdByQueryTextArray.slice(0,30) ) + ' }');
		    res.end();
		    return;
		}
		//ถ้า GET /api/place/search? ส่ง latและlng ส่วน query text ส่งมาหรือไม่ก็ได้ จะต้อง return server places + 4sq places แบบเรียงตาม distance
		else {
			console.log("lat lng (text) is not null!");
	        var serverPlaceArray = [];
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

			//Get only first 30 sorted places
			var thirtyServerPlaceArray = serverPlaceArray.slice(0,30);
			console.log("Get place from server "+thirtyServerPlaceArray.length + " places");

			//------------------------ Manage 4sq places ---------------------------------
			var params = {  
			    "ll": lat + "," + lng,
			    "query": queryText
			};
			console.log("parameters = "+JSON.stringify(params));

			foursquare.getVenues(params, function(error, venues) {  
			    if (!error && venues != null && venues.response != null && venues.response.venues != null) {  
			        // console.log(JSON.stringify(venues.response.venues));
		    		
					var itemArray = venues.response.venues;;
					var foursquarePlaceArray = [];

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
					}

					//Sort 4sq place by distance
					foursquarePlaceArray = foursquarePlaceArray.sort(function(a, b) {
						if (a.distance < b.distance) { return -1; }
						if (a.distance > b.distance) { return  1; }
						return 0;
					});
					console.log("Get place from foursquare "+foursquarePlaceArray.length + " places");
								

					// Remove duplicate place from 4sq place (at variable name "placeArray")
					var foursquarePlaceIDArray = [];
					for (count in foursquarePlaceArray) {
						foursquarePlaceIDArray.push(foursquarePlaceArray[count].id_foursquare);
					}

					for (j in thirtyServerPlaceArray) {
						var tmpID = thirtyServerPlaceArray[j].id_foursquare;
						if (foursquarePlaceIDArray.indexOf(tmpID) != -1) {
							var index = foursquarePlaceIDArray.indexOf(tmpID);
							foursquarePlaceIDArray.splice(index, 1);  //remove object at index
							foursquarePlaceArray.splice(index, 1);  //remove object at index
						}
					}

		            //---------------------------------------- Send response ----------------------------------
		            var responseArray = [];
		            responseArray = responseArray.concat(thirtyServerPlaceArray, foursquarePlaceArray);
					var responseString = '{ "places":'+ JSON.stringify(responseArray) + ' }';
					
					res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
					res.write(responseString);
				    res.end();
				    return;

				} else {
					//---------------------------------------- Send response ----------------------------------
					res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
					res.write('{ "places":'+ JSON.stringify(thirtyServerPlaceArray) + ' }');
				    res.end();
				    return;
				}  
			}); 
		}
	});
}


