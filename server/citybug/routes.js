var controller = require('./controllers/index'),
	util = require('util'),
    api = require('./controllers/api'),
    place = require('./controllers/place'),
    auth = require('./controllers/authentication'),
    user = require('./controllers/user'),
    imin = require('./controllers/imin'),
    comment = require('./controllers/comment'),
    subscription = require('./controllers/subscription'),
	passport = require('passport'),
	service = require('./service');

module.exports = function(app, express){
	app.get('/', controller.index);

	//report
	app.get('/add', api.add);
	app.get('/api/reports/user/*', api.reports_username);
	app.get('/api/reports/place/*', api.reports_place);

	app.get('/api/reports', auth.basic_auth_not_required, api.reports);
	app.post('/api/reports', auth.basic_auth, api.report_post);
	app.get('/api/report/*', api.report);
	app.get('/api/reports/all', api.all_reports);

	//comment
	app.get('/add_comment', comment.add_comment);
	app.post('/api/report/*/comment', auth.basic_auth, comment.comment_post);

	//place
	app.get('/callback_place_search', place.callback_place_search);
	app.get('/api/place/search',auth.basic_auth_not_required , place.place_search);
	app.get('/api/places', place.places);

	//categories
	app.get('/api/categories', api.categories);

	//subscribe
	app.get('/api/subscriptions', subscription.subscriptions);
	app.get('/api/subscriptions/user/*', subscription.subscriptions_username);
	app.post('/api/subscription/place',auth.basic_auth , subscription.subscription_place_post);
	app.delete('/api/subscription/place',auth.basic_auth , subscription.subscription_place_delete);

	//user
	app.get('/api/users', user.users_all);
	app.get('/api/user/*', user.user);

	//imin
	app.get('/api/imin/report/*', imin.imin_list);
	app.post('/api/imin/report/*', auth.basic_auth, imin.imin_post);
	app.delete('/api/imin/report/*', auth.basic_auth, imin.imin_delete);

	//authenticated
	app.post('/api/user/sign_up', user.sign_up);
	app.post('/api/user/sign_in', auth.basic_auth, user.sign_in);
	app.get('/api/user/sign_out', user.sign_out);

	app.get('/login', auth.basic_auth, auth.login);
	app.get('/logout', auth.logout);
	app.get('/test_login', passport.authenticate('basic', { session: false }), auth.test_login);
};

