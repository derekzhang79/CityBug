
var express = require('express'),
    routes = require('./routes'),
    api = require('./routes/api');

var app = module.exports = express.createServer();
var io = require('socket.io').listen(app);

// Configuration
require('./configuration')(app, express);

// Routes
app.get('/', routes.index);
app.post('/', routes.index_post);

app.get('/api/entries', api.entries);
app.post('/api/entries', api.entries_post);

app.get('/api/entries/*', api.entry);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

io.sockets.on('connection', function (socket) {
   socket.emit('news', { hello: 'world' });
   socket.on('my other event', function (data) {
     console.log(data);
   });
 });