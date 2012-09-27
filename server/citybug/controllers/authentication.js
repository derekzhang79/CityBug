var passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util'),
	LocalStrategy = require('passport-local').Strategy;

exports.login_post = function(req, res, next) {
	passport.authenticate('local', function(err, user, info) {
	if (err) {
		return next(err);
	}
	if (!user) {
		req.flash('error', info.message);
		res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
	}
	req.logIn(user, function(err) {
		if (err) { 
			return next(err); 
		}
		res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		});
	})(req, res, next);
};

exports.login = function(req, res){
	res.render('login.jade', {title:'City bug'});
};

exports.logout = function(req, res){
	req.logout();
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
};

exports.test_login = function(req, res){
	res.render('test_login.jade',{title:'City bug', text:'login with user', user:req.user});
};