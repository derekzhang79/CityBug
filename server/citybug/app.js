
var express = require('express'),
	connect = require('express/node_modules/connect'),
	passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util'),
	LocalStrategy = require('passport-local').Strategy;
	// service = require('./service'),
 //    model =  service.useModel('model');
var app = module.exports = express.createServer();
var sio = require('socket.io');

// Configuration
require('./configuration')(app, express, passport, flash);
require('./routes')(app, express);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

var io = sio.listen(app);

io.sockets.on('connection', function (socket) {
	socket.on('user message', function (msg) {
    	socket.broadcast.emit('user message', msg);
  	});
});

// Passport session setup.
//   To support persistent login sessions, Passport needs to be able to
//   serialize users into and deserialize users out of the session.  Typically,
//   this will be as simple as storing the user ID when serializing, and finding
//   the user by ID when deserializing.
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  findById(id, function (err, user) {
    done(err, user);
  });
});

// Use the LocalStrategy within Passport.
//   Strategies in passport require a `verify` function, which accept
//   credentials (in this case, a username and password), and invoke a callback
//   with a user object.  In the real world, this would query a database;
//   however, in this example we are using a baked-in set of users.
// passport.use(new LocalStrategy(
//   function(username, password, done) {
//     model.User.findOne({ username: username }, function (err, user) {
//       if (err) { return done(err); }
//       if (!user) {
//         return done(null, false, { message: 'Unknown user' });
//       }
//       if (!user.validPassword(password)) {
//         return done(null, false, { message: 'Invalid password' });
//       }
//       return done(null, user);
//     });
//   }
// ));


// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  res.redirect('/login')
}
