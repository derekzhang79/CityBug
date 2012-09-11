/*!
* Demo registration application
* Copyright(c) 2011 Jean-Tiare LE BIGOT <admin@jtlebi.fr>
* MIT Licensed
*/

// loads model file and engine
var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

// Open DB connection
mongoose.connect('mongodb://localhost/entry');

// Home page => registration form
exports.index = function(req, res){
    entryModel.find({},function(err, docs){
        res.render('index.jade', { title: 'City bug', entry: docs });
    });
};

exports.index_post = function(req, res){
    entry = new entryModel();
    entry.title = req.body.title;
    entry.thumbnail_image = req.body.thumbnail_image;
    entry.full_image = req.body.full_image;
    entry.latitude = req.body.latitude;
    entry.longitude = req.body.longitude;
    entry.note = req.body.note;
    // entry.categories = req.body.categories;
    
    entry.save(function (err) {
        messages = [];
        errors = [];
        if (!err){
            console.log('Success!');
            messages.push("Thank you for you new membership !");
        }
        else {
            console.log('Error !');
            errors.push("At least a mandatory field has not passed validation...");
            console.log(err);
        }
    });
    entryModel.find({},function(err, docs){
        res.render('index.jade', { title: 'City bug', entry: docs });
    });
};