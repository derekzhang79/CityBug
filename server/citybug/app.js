
var express = require('express'),
	connect = require('express/node_modules/connect'),
	passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util');
const crypto = require('crypto'),
      fs = require("fs");
// ssl
var privateKey = fs.readFileSync('privatekey.pem').toString();
var certificate = fs.readFileSync('certificate.pem').toString();

var credentials = crypto.createCredentials({key: privateKey, cert: certificate});


var hskey = fs.readFileSync('privatekey.pem');
var hscert = fs.readFileSync('certificate.pem')

var options = {
    key: hskey,
    cert: hscert
};

var app = module.exports = express.createServer();
// Configuration
require('./configuration')(app, express, passport, flash);
require('./routes')(app, express);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);