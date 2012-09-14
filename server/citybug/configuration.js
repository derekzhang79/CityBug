var connect = require('express/node_modules/connect'),
	MemoryStore = connect.middleware.session.MemoryStore;
module.exports = function(app, express){
	app.configure(function(){
	    app.set('views', __dirname + '/views');
	    app.set('view engine', 'jade');
	    app.use(express.bodyParser({uploadDir:'./uploads'}));
	    app.use(express.methodOverride());
	    app.use(app.router);
	    app.use(express.static(__dirname + '/public'));
	    app.use(express.cookieParser());
  		app.use(express.session({
      		secret: 'secret'
    		, key: 'express.sid'
    		, store: store = new MemoryStore()
  		}));
	});

	app.configure('development', function(){
	    app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
	});

	app.configure('production', function(){
	    app.use(express.errorHandler()); 
	});
};