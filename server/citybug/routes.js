var controller = require('./controllers/index'),
    api = require('./controllers/api'),
    place = require('./controllers/place')
    auth = require('./controllers/authentication')
	passport = require('passport'),
	flash = require('connect-flash'),
	util = require('util'),
	LocalStrategy = require('passport-local').Strategy;

var service = require('./service'),
    model =  service.useModel('model');

module.exports = function(app, express){

	app.get('/', controller.index);

	//report
	// app.get('/add',ensureAuthenticated, api.add);
	app.get('/add', api.add);
	app.get('/api/reports', api.reports);
	app.post('/api/reports', api.report_post);
	// app.post('/api/reports',ensureAuthenticated, api.report_post);
	app.get('/api/report/*', api.report);
	app.get('/api/reports/all', api.all_reports);

	//comment
	app.get('/add_comment', api.add_comment);
	// app.post('/api/report/*/comment', ensureAuthenticated,api.comment_post);
	app.post('/api/report/*/comment',api.comment_post);

	//place
	app.get('/callback_place_search', place.callback_place_search);
	app.get('/api/place/search', place.place_search)
	app.get('/api/places', place.places)

	//categories
	app.get('/api/categories', api.categories);

	//subscribe
	app.get('/api/subscriptions', api.subscriptions);

	//user
	app.get('/api/users', api.users);

	//authenticated
	app.get('/login', auth.login);
	app.get('/logout', auth.logout);
	app.post('/api/user/sign_in', auth.login_post);
	app.get('/api/user/sign_out', auth.logout);
	app.get('/test_login', testAuthenticated, auth.test_login);
};

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
//   with a user object.  In the real world, this would query a database;
//   however, in this example we are using a baked-in set of users.
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

// Simple route middleware to ensure user is authenticated.
//   Use this route middleware on any resource that needs to be protected.  If
//   the request is authenticated (typically via a persistent login session),
//   the request will proceed.  Otherwise, the user will be redirected to the
//   login page.
function ensureAuthenticated(req, res, next) {
	if (req.isAuthenticated()) { 
		return next(); 
	}
	res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
}

function testAuthenticated(req, res, next) {
	if (req.isAuthenticated()) { 
		return next(); 
	}
	res.render('test_login.jade',{title:'City bug', text:'Please login', user:''});
}
