var controller = require('./controller'),
    api = require('./controller/api');
module.exports = function(app, express){

	app.get('/', controller.index);

	app.get('/add', api.add);

	app.get('/api/reports', api.reports);
	// app.post('/api/entries', routes.index_post);
	app.post('/api/reports', api.report_post);
	//app.post('/api/entries', api.entries_post);
	app.get('/api/reports/*', api.report);
};