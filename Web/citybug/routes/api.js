var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

exports.entries = function(req, res){
    console.log('API page');
    res.contentType('application/json'); 
 
    entryModel.find({},function(err, docs){
        res.send('"entries" : ' + JSON.stringify(docs));
    });

};


exports.entry = function(req, res){
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );
    console.log('current : '+currentID);

    res.contentType('application/json');
    entryModel.findOne({_id:currentID }, function(err,docs) {    	
        res.send('"entry" : ' + JSON.stringify(docs));
	});
};
