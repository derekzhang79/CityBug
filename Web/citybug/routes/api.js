var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

exports.entries = function(req, res){
    console.log('API page');
    res.contentType('application/json'); 
 
    entryModel.find({},function(err, docs){
        res.send('"entries" : ' + JSON.stringify(docs));
    });

};