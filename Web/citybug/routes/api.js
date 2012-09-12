var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

exports.add = function(req, res){
    entryModel.find({},function(err, docs){
        res.render('add.jade', { title: 'City bug', entry: docs });
    });
};

// GET /api/entries >> get list of entries
exports.entries = function(req, res){
    console.log('get list');
    res.contentType('application/json'); 
 
    entryModel.find({},function(err, docs){
        res.send(JSON.stringify(docs));
    });

};

/*
// POST /api/entries >> add new entry from client
exports.entries_post = function(req, res){
	var jsonString = JSON.stringify(req.body);
	var obj = JSON.parse(jsonString);
	console.log('post : ' + obj.title + ' <<');

	// Create new object
	entry = new entryModel();
    entry.title = obj.title;
    entry.thumbnail_image = obj.thumbnail_image;
    entry.full_image = obj.full_image;
    entry.latitude = obj.latitude;
    entry.longitude = obj.longitude;
    entry.note = obj.note;
    entry.categories = obj.categories;
    
    entry.save(function (err) {
        messages = [];
        errors = [];
        if (!err){
            console.log('Success!');
        	res.statusCode = 200;
			res.json(['OK']);
            messages.push("Thank you for you new membership !");
        }
        else {
            console.log('Error !');
            errors.push("At least a mandatory field has not passed validation...");
        	res.statusCode = 500;
			res.json(['NOT OK']);
            console.log(err);
        }
    });
};
*/

// GET /api/entries/{id} >> get one entry from id
exports.entry = function(req, res){
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );
    console.log('current : '+currentID);

    res.contentType('application/json');
    entryModel.findOne({_id:currentID }, function(err,docs) {    	
        res.send('"entry" : ' + JSON.stringify(docs));
	});
};
