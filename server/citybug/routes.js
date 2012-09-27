var controller = require('./controllers/index'),
    api = require('./controllers/api'),
    place = require('./controllers/place'),
    auth = require('./controllers/authentication'),
	service = require('./service');

module.exports = function(app, express){
	app.get('/', controller.index);

	//report
	// app.get('/add',ensureAuthenticated, api.add);
	app.get('/add', api.add);
	app.get('/api/reports', api.reports);
	app.post('/api/reports', api.report_post);
	// app.post('/api/reports', auth.ensureAuthenticated, api.report_post);
	app.get('/api/report/*', api.report);
	app.get('/api/reports/all', api.all_reports);

	//comment
	app.get('/add_comment', api.add_comment);
	// app.post('/api/report/*/comment', auth.ensureAuthenticated, api.comment_post);
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
	app.get('/test_login', auth.testAuthenticated, auth.test_login);
};

