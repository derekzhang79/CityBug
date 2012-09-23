var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model'),
    mockup_places = require('../mockup/places');
    
var sys = require('sys'),
express = require('express'),
assert = require('assert');

var FOURSQ = require('../foursquare'),
	KEYS = require('../key');

var CLIENT_ID = KEYS.CLIENT_ID;
var CLIENT_SECRET = KEYS.CLIENT_SECRET;
var REDIRECT_URI = KEYS.HOST;

exports.place_search = function(req, res){

    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
    res.write(JSON.stringify(mockup_places));
    res.end()

/*
	var lat = req.query.lat;
	var lng = req.query.lng;

	console.log("get request param >> "+ JSON.stringify(req.query));
	var newRedirectUrl = REDIRECT_URI + "?lat=" + lat + "&lng="+lng;

	var loc = "https://foursquare.com/oauth2/authenticate?client_id=" + CLIENT_ID + "&response_type=code&redirect_uri=" + REDIRECT_URI + "callback_place_search";
	res.writeHead(303, { 'location': loc });
	res.end();
*/

}


exports.callback_place_search = function(req, res){

	var code = req.query.code;
	// var lat = req.cookies.lat;
	// var lng = req.cookies.lng;
	// console.log("llllat" + lat + "lngggg" + lng);
	// console.log("cookie! "+ req.cookies);

	FOURSQ.getAccessToken({
		code: code,
		redirect_uri: REDIRECT_URI,
		client_id: CLIENT_ID,
		client_secret: CLIENT_SECRET
	}, function (access_token) {

		if (access_token !== undefined) {

			//Mock up lat lng
			var lat = 40.721294;
			var lng = -73.983994;

			venueSearch(access_token, lat, lng, function (data) {
				if (data != null && data != undefined) {

					//------------------------ Manage 4sq places ---------------------------------
					var object = data[0];
					// console.log(">>>>>> "+ object+" \n "+JSON.stringify(object.items));
					var itemArray = object.items;
					var foursquarePlaceArray = [];
					var foursquarePlaceIDArray = [];

					for (i in itemArray) {
						//Create place object from 4sq data
						var newPlace = new model.Place();
						newPlace.id_foursquare = itemArray[i].id;		
						newPlace.title = itemArray[i].name;			
						newPlace.distance = itemArray[i].location.distance;
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
								//Calculate distance in each server place
								serverPlace[i].distance = distanceCalculate(serverPlace[i].lat, serverPlace[i].lng, lat, lng);
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
						var responseString = '{ "suggest_places":'+ JSON.stringify(thirtyServerPlaceArray) +',"additional_places":' + JSON.stringify(foursquarePlaceArray) + ' }';
						
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
			
		} else {
			console.log("access_token is undefined.");
			res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.write("Cannot Find Place , Access token is undefined");
		    res.end();
		}

	});

};

function distanceCalculate(lat1, lon1, lat2, lon2) {
	var radlat1 = Math.PI * lat1/180;
	var radlat2 = Math.PI * lat2/180;
	var radlon1 = Math.PI * lon1/180;
	var radlon2 = Math.PI * lon2/180;
	var theta = lon1-lon2;
	var radtheta = Math.PI * theta/180;
	var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
	dist = Math.acos(dist);
	dist = dist * 180/Math.PI;
	dist = dist * 60 * 1.1515;
	dist = dist * 1.609344;  //kilometre

	//console.log("distance from "+lat1 +" "+ lon1+" "+ lat2 +" "+ lon2 + " = " + dist + "km");
	return dist
}

function venueSearch(access_token, lat, lng, callbackFunction) {

	var latlngString = lat + "," + lng;
	var query = { ll: latlngString };

	FOURSQ.searchVenues(query, access_token, function (data) {
		console.log("-> searchVenue OK");
		callbackFunction(data);
	}, function (error) {
		console.log(error);
		console.log("-> searchVenue ERROR");
		callbackFunction(null);
	});
}

function getVenue(access_token, id_foursquare, callbackFunction) {

	FOURSQ.getVenue(id_foursquare, access_token, function (data) {
		console.log("-> getVenue OK");
		callbackFunction(data);
	}, function (error) {
		console.log(error);
		console.log("-> getVenue ERROR");
	});
}
