var passport = require('passport'),
	util = require('util'),
	BasicStrategy = require('passport-http').BasicStrategy,
	service = require('../service'),
	model =  service.useModel('model');


exports.basic_auth = function(req, res, next) {
	passport.authenticate('basic', {session: false}, function(err, user, info) {
	if (err) {
		console.log("UNAUTHEN #2");
		res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		return next(err);
	}
	if (!user) {
		console.log("UNAUTHEN #1");
		res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		return;
	}
	req.logIn(user, function(err) {
		if (err) { 
			return next(err); 
		}
		// call next function
		console.log("AUTHEN 1");
		next();
		return;
		});
	})(req, res, next);
}

exports.basic_auth_not_required = function(req, res, next) {
	passport.authenticate('basic', {session: false}, function(err, user, info) {
	if (err) {
		res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.end();
		return next(err);
	}
	if (!user) {
		// auth with unsign in user
		next();
		return;
	}
	req.logIn(user, function(err) {
		if (err) { 
			return next(err); 
		}
		// auth with user
		next();
		return;
		});
	})(req, res, next);
}

exports.login_post = function(req, res, next) {

	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'authenticated'});
	res.end();
}

exports.login = function(req, res) {
	res.render('login.jade', {title:'City bug'});
};

exports.logout = function(req, res) {
	req.logOut();
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
};

exports.test_login = function(req, res) {
	res.render('test_login.jade',{title:'City bug', text:'login with user', user:req.user});
};

// Passport session setup.
//   To support persistent login sessions, Passport needs to be able to
//   serialize users into and deserialize users out of the session.  Typically,
//   this will be as simple as storing the user ID when serializing, and finding
  // the user by ID when deserializing.
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

// Use the BasicStrategy within Passport.
//   Strategies in Passport require a `verify` function, which accept
//   credentials (in this case, a username and password), and invoke a callback
//   with a user object.
passport.use(new BasicStrategy({
  },
	function(username, password, done) {
		model.User.findOne({ username: username }, function (err, user) {
			//console.log('ENCRYPT **** '+ service.encodePassword(password));
			if (err) {
				return done(err);
			}
			if (!user) {
				return done(null, false, { message: 'Unknown user' });
			}
			if (user.password != service.encodePassword(password) && user.password != password) {
				return done(null, false, { message: 'Invalid password' });
			}
			return done(null, user);
		});
	}
));