var controller = require('./controllers/index'),
    api = require('./controllers/api');
module.exports = function(app, express){

	app.get('/', controller.index);

	//report
	app.get('/add', api.add);
	app.get('/api/reports', api.reports);
	app.post('/api/reports', api.report_post);
	app.get('/api/reports/*', api.report);

	//place
	app.get('/api/place/search', api.place_search)

	//categories
	app.get('/api/categories', api.categories);
};