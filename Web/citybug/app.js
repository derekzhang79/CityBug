
var express = require('express'),
    routes = require('./routes');

var app = module.exports = express.createServer();


// Configuration
require('./configuration')(app, express);

// Routes
app.get('/', routes.index);
app.post('/', routes.index_post);

// Open App socket
app.listen(3003);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
