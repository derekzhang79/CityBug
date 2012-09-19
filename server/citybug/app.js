
var express = require('express'),
	connect = require('express/node_modules/connect'),
	parseCookie = connect.utils.parseCookie,
    MemoryStore = connect.middleware.session.MemoryStore,
    store;
var app = module.exports = express.createServer();
var sio = require('socket.io');

// Configuration
require('./configuration')(app, express);
require('./routes')(app, express);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

var io = sio.listen(app);

io.sockets.on('connection', function (socket) {
	socket.on('user message', function (msg) {
		console.log('entry' + msg);
    	socket.broadcast.emit('user message', msg);
  	});
});