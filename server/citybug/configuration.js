module.exports = function(app, express, passport, flash){
	app.configure(function(){
	    app.set('views', __dirname + '/views');
	    app.set('view engine', 'jade');
		app.use(express.logger());
	    app.use(express.bodyParser({uploadDir:'./uploads'}));
	    app.use(express.methodOverride());
	    app.use(express.static(__dirname + '/public'));
		app.use(flash());
		app.use(passport.initialize());
		app.use(app.router);
	});

	app.configure('development', function(){
	    app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
	});

	app.configure('production', function(){
	    app.use(express.errorHandler()); 
	});
};