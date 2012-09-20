var controller = require('./controllers/index'),
    api = require('./controllers/api');
module.exports = function(app, express){

	app.get('/', controller.index);

	app.get('/add', api.add);

	app.get('/api/reports', api.reports);
	app.post('/api/reports', api.report_post);
	app.get('/api/reports/*', api.report);

	app.get('/api/place/search', api.place_search)
};