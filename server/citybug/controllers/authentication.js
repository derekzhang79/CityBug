var passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util'),
	LocalStrategy = require('passport-local').Strategy;;

exports.login_post = function(req, res, next) {
  passport.authenticate('local', function(err, user, info) {
    if (err) { return next(err); }
    if (!user) {
      req.flash('error', info.message);
      return res.redirect('/login')
    }
    req.logIn(user, function(err) {
      if (err) { return next(err); }
      return res.redirect('/api/reports');
    });
  })(req, res, next);
};

exports.login = function(req, res){
	res.render('login.jade', {title:'City bug'});
};

exports.logout = function(req, res){
	req.logout();
	res.redirect('/');
};