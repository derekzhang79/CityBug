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
	var loc = "https://foursquare.com/oauth2/authenticate?client_id=" + CLIENT_ID + "&response_type=code&redirect_uri=" + REDIRECT_URI;
	res.writeHead(303, { 'location': loc });
	res.end();
}

exports.callback = function(req, res){

	var code = req.query.code;

	FOURSQ.getAccessToken({
		code: code,
		redirect_uri: REDIRECT_URI,
		client_id: CLIENT_ID,
		client_secret: CLIENT_SECRET
	}, function (access_token) {

		if (access_token !== undefined) {

			// testUserCheckins(access_token);
			// testUserBadges(access_token);
			// testTipSearch(access_token);
			// testUserSearch(access_token);

			venueSearch(access_token, 12, 34, function (data) {
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
			
			// testGetRecentCheckins(access_token);
			// testGetSettings(access_token);
			// testGetPhoto(access_token);

			// testGetUser(access_token);
			// testGetVenue(access_token);
			// testGetVenueAspect(access_token);

			// testGetCheckin(access_token);
			// testGetTip(access_token);

			// res.send('access token = '+ access_token);

		} else {
			console.log("access_token is undefined.");
		}

	});
};


function venueSearch(access_token, lat, lng, callbackFunction) {

	var query = { ll: "40.721294, -73.983994" };
	// console.log("res2" + res);
	FOURSQ.searchVenues(query, access_token, function (data) {
		console.log("-> searchVenue OK");

		callbackFunction(data);
		// console.log("res3" + res);

	}, function (error) {
		console.log(error);
		console.log("-> searchVenue ERROR");

		callbackFunction(null);
	});
}
