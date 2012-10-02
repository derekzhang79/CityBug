var controller = require('./controllers/index'),
	util = require('util'),
    api = require('./controllers/api'),
    place = require('./controllers/place'),
    auth = require('./controllers/authentication'),
    user = require('./controllers/user'),
	passport = require('passport'),
	service = require('./service');

module.exports = function(app, express){
	app.get('/', controller.index);

	//report
	// app.get('/add',ensureAuthenticated, api.add);
	app.get('/add', api.add);
	app.get('/api/reports', auth.basic_auth_reports, api.reports);
	app.get('/api/reports/*', auth.basic_auth_reports, api.reports_user);
	app.post('/api/reports', auth.basic_auth, api.report_post);
	// app.post('/api/reports', auth.ensureAuthenticated, api.report_post);
	app.get('/api/report/*', api.report);
	app.get('/api/reports/all', api.all_reports);

	//comment
	app.get('/add_comment', api.add_comment);
	// app.post('/api/report/*/comment', auth.ensureAuthenticated, api.comment_post);
	app.post('/api/report/*/comment', auth.basic_auth, api.comment_post);

	//place
	app.get('/callback_place_search', place.callback_place_search);
	app.get('/api/place/search', place.place_search);
	app.get('/api/places', place.places);

	//categories
	app.get('/api/categories', api.categories);

	//subscribe
	app.get('/api/subscriptions', api.subscriptions);
	app.get('/api/subscriptions/*', api.subscriptions_username);

	//user
	app.get('/api/users', api.users);

	//authenticated
	app.post('/api/user/sign_up', user.sign_up);
	app.post('/api/user/sign_in', auth.basic_auth, user.sign_in);
	app.get('/api/user/sign_out', user.sign_out);

	app.get('/login', auth.basic_auth, auth.login);
	app.get('/logout', auth.logout);
	app.get('/test_login', passport.authenticate('basic', { session: false }), auth.test_login);
};

