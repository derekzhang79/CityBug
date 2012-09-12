
var express = require('express'),
    routes = require('./routes'),
    api = require('./routes/api'),
	connect = require('express/node_modules/connect'),
	parseCookie = connect.utils.parseCookie,
    MemoryStore = connect.middleware.session.MemoryStore,
    store;
var app = module.exports = express.createServer();
var sio = require('socket.io');

// Configuration
require('./configuration')(app, express);

// Routes
app.get('/', routes.index);
app.post('/', routes.index_post);

app.get('/add', api.add);

app.get('/api/entries', api.entries);
app.post('/api/entries', routes.index_post);
//app.post('/api/entries', api.entries_post);

app.get('/api/entries/*', api.entry);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

var io = sio.listen(app);

io.sockets.on('connection', function (socket) {
  socket.on('ferret', function (name, fn) {
    fn('woot');
  });
});
