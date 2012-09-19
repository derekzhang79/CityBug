var controller = require('./controller'),
    api = require('./controller/api');
module.exports = function(app, express){

	app.get('/', controller.index);

	app.get('/add', api.add);

	app.get('/api/entries', api.entries);
	// app.post('/api/entries', routes.index_post);
	app.post('/api/entries', api.entry_post);
	//app.post('/api/entries', api.entries_post);
	app.get('/api/entries/*', api.entry);
};