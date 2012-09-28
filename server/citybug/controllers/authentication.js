var passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util'),
	LocalStrategy = require('passport-local').Strategy,
	BasicStrategy = require('passport-http').BasicStrategy,
	service = require('../service'),
	model =  service.useModel('model');

exports.login_post = function(req, res, next) {
	passport.authenticate('local', function(err, user, info) {
	if (err) {
		res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		return next(err);
	}
	if (!user) {
		req.flash('error', info.message);
		res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		return;
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

exports.test_login = function(req, res) {
	res.render('test_login.jade',{title:'City bug', text:'login with user', user:req.user});
};

exports.basic = function(req, res) {

}

// Passport session setup.
//   To support persistent login sessions, Passport needs to be able to
//   serialize users into and deserialize users out of the session.  Typically,
//   this will be as simple as storing the user ID when serializing, and finding
//   the user by ID when deserializing.
passport.serializeUser(function(user, done) {
	done(null, user._id);
});

passport.deserializeUser(function(id, done) {
	findById(id, function (err, user) {
		done(err, user);
	});
});

function findById(id, fn) {
	model.User.findOne({ _id: id }, function (err, user) {
		if (user && !err) {
			fn(null, user);
		} else {
			fn(new Error('User ' + id + ' does not exist'));
		}
	});
}


// Use the LocalStrategy within Passport.
//   Strategies in passport require a `verify` function, which accept
//   credentials (in this case, a username and password), and invoke a callback
//   with a user object.
passport.use(new LocalStrategy(
	function(username, password, done) {
		model.User.findOne({ username: username }, function (err, user) {
			if (err) {
				return done(err);
			}
			if (!user) {
				return done(null, false, { message: 'Unknown user' });
			}
			if (user.password != password) {
				return done(null, false, { message: 'Invalid password' });
			}
			return done(null, user);
		});
	}
));

// Use the BasicStrategy within Passport.
//   Strategies in Passport require a `verify` function, which accept
//   credentials (in this case, a username and password), and invoke a callback
//   with a user object.
passport.use(new BasicStrategy({
  },
	function(username, password, done) {
		model.User.findOne({ username: username }, function (err, user) {
			if (err) {
				return done(err);
			}
			if (!user) {
				return done(null, false, { message: 'Unknown user' });
			}
			if (user.password != password) {
				return done(null, false, { message: 'Invalid password' });
			}
			return done(null, user);
		});
	}
));


// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
exports.ensureAuthenticated = function(req, res, next) {
	if (req.isAuthenticated()) { 
		return next(); 
	}
	console.log('ensureAuthenticated error');
	res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
}

exports.testAuthenticated = function(req, res, next) {
	if (req.isAuthenticated()) { 
		return next(); 
	}
	res.render('test_login.jade',{title:'City bug', text:'Please login', user:''});
}
