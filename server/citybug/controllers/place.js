var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model');
    
var sys = require('sys'),
express = require('express'),
assert = require('assert');

var FOURSQ = require('../foursquare'),
	KEYS = require('../key');

var CLIENT_ID = KEYS.CLIENT_ID;
var CLIENT_SECRET = KEYS.CLIENT_SECRET;
// var REDIRECT_URI = "http://localhost:3003/callback";
var REDIRECT_URI = "http://54.251.32.49:3003/callback";

exports.place_search = function(req, res){
	var lat = req.query.lat;
	var lng = req.query.lng;

	// res.cookie('lat', lat, { expires: new Date(Date.now() + 900000), httpOnly: true });
	// res.cookie('lng', lng, { expires: new Date(Date.now() + 900000), httpOnly: true });

	console.log("get request param >> "+ JSON.stringify(req.query));
	var newRedirectUrl = REDIRECT_URI + "?lat=" + lat + "&lng="+lng;

	var loc = "https://foursquare.com/oauth2/authenticate?client_id=" + CLIENT_ID + "&response_type=code&redirect_uri=" + REDIRECT_URI;
	res.writeHead(303, { 'location': loc });
	res.end();
}

exports.callback = function(req, res){

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
					res.contentType('application/json'); 
					res.statuscode = 200;
					res.send('{ "additional_places":' + JSON.stringify(data) + ' }');
				} else {
					res.contentType('application/html');
					res.statuscode = 500;
					res.send("Cannot Find Place");
				}
			});
			

		} else {
			console.log("access_token is undefined.");
		}

	});
};


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
