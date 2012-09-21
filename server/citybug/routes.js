var controller = require('./controllers/index'),
    api = require('./controllers/api'),
    place = require('./controllers/place');

module.exports = function(app, express){

	app.get('/', controller.index);

	//report
	app.get('/add', api.add);
	app.get('/api/reports', api.reports);
	app.post('/api/reports', api.report_post);
	app.get('/api/report/*', api.report);
	app.post('/api/report/*/comment', api.comment_post);

	//place
	app.get('/callback_place_search', place.callback_place_search);
	app.get('/api/place/search', place.place_search)

	//categories
	app.get('/api/categories', api.categories);
};