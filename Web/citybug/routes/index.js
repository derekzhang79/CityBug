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

    var fs = require('fs');
    // get the temporary location of the file
    var tmp_path = req.files.thumbnail_image.path;
    // set where the file should actually exists - in this case it is in the "images" directory
    var target_path = './public/images/' + req.files.thumbnail_image.name;
    // move the file from the temporary location to the intended location
    fs.rename(tmp_path, target_path, function(err) {
        if (err) throw err;
        // delete the temporary file, so that the explicitly set temporary upload dir does not get filled with unwanted files
        fs.unlink(tmp_path, function() {
            if (err) throw err;
            console.log('File uploaded to: ' + target_path + ' - ' + req.files.thumbnail_image.size + ' bytes');
        });
    });

    var tmp_path = req.files.full_image.path;
    // set where the file should actually exists - in this case it is in the "images" directory
    var target_path = './public/images/' + req.files.full_image.name;
    // move the file from the temporary location to the intended location
    fs.rename(tmp_path, target_path, function(err) {
        if (err) throw err;
        // delete the temporary file, so that the explicitly set temporary upload dir does not get filled with unwanted files
        fs.unlink(tmp_path, function() {
            if (err) throw err;
            console.log('File uploaded to: ' + target_path + ' - ' + req.files.full_image.size + ' bytes');
        });
    });


    entry = new entryModel();
    entry.title = req.body.title;
    entry.thumbnail_image = req.files.thumbnail_image.name;
    entry.full_image = req.files.full_image.name;
    entry.latitude = req.body.latitude;
    entry.longitude = req.body.longitude;
    entry.note = req.body.note;
    entry.categories = req.body.categories;
    
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