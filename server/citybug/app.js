
var express = require('express'),
	connect = require('express/node_modules/connect'),
	passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util');

//https
var fs = require('fs');

var hskey = fs.readFileSync('citybug-key.pem');
var hscert = fs.readFileSync('citybug-cert.pem')

var options = {
    key: hskey,
    cert: hscert
};

var app = module.exports = express.createServer(options);
// Configuration
require('./configuration')(app, express, passport, flash);
require('./routes')(app, express);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);