/*!
* Demo registration application
* Copyright(c) 2011 Jean-Tiare LE BIGOT <admin@jtlebi.fr>
* MIT Licensed
*/
var environment = require('../environment');
var service = require('../service');
    service.init(environment);
// loads model file and engine
var model = service.useModel('model');

// Home page => registration form
exports.index = function(req, res){
    var query =  model.Report.find({});

    query.exec(function (err, docs) {
			res.render('index.jade', { title: 'City bug', report: docs });
	});	
};