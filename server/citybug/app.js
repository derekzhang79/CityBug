
var express = require('express'),
	connect = require('express/node_modules/connect'),
	passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util');

var app = module.exports = express.createServer();
// Configuration
require('./configuration')(app, express, passport, flash);
require('./routes')(app, express);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);