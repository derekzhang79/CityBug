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

    // create directory
    var path = require('path');
    // functon create directory
    fs.mkdirParent = function(dirPath, mode, callback) {
      //Call the standard fs.mkdir
      fs.mkdir(dirPath, mode, function(error) {
        //When it fail in this way, do the custom steps
        if (error && error.errno === 34) {
          //Create all the parents recursively
          fs.mkdirParent(path.dirname(dirPath), mode, callback);
          //And then the directory
          fs.mkdirParent(dirPath, mode, callback);
        }
        //Manually run the callback since we used our own callback to do all these
        callback && callback(error);
      });
    };

    // save data to db
    entry = new entryModel();
    entry.title = req.body.title;
    entry.thumbnail_image = "./images/" + entry._id + "/" + req.files.thumbnail_image.name;
    entry.full_image = "./images/"+ entry._id + "/" + req.files.full_image.name;
    entry.latitude = req.body.latitude;
    entry.longitude = req.body.longitude;
    entry.note = req.body.note;
    entry.categories = req.body.categories;

    entry.save(function (err) {
        if (!err){
            console.log('Success!');
        }
        else {
            console.log('Error !');
            console.log(err);
        }
    });

    // make directory
    fs.mkdirParent("./public/images/" + entry._id + "/");

    //save picture to /public/images/:id/pictureName

    if (req.files.thumbnail_image.name) {
        // get the temporary location of the file : ./uploads
        var tmp_path = req.files.thumbnail_image.path;
        // set where the file should actually exists - in this case it is in the "images" directory
        var thumbnail_image_path = './public/images/' + entry._id + "/" + req.files.thumbnail_image.name;
        // move the file from the temporary location to the intended location
        fs.rename(tmp_path, thumbnail_image_path, function(err) {
            if (err) throw err;
            // delete the temporary file, so that the explicitly set temporary upload dir does not get filled with unwanted files
            fs.unlink(tmp_path, function() {
                if (err) throw err;
                    console.log('File uploaded to: ' + thumbnail_image_path + ' - ' + req.files.thumbnail_image.size + ' bytes');
            });
        });        
    } else {
        // delete temporary file : ./upload
        var tmp_path = req.files.thumbnail_image.path;
        fs.unlink(tmp_path, function() {
            console.log('Delete temporary file');
        });
    }

    // do the same thing
    if (req.files.full_image.name) {
        var tmp_path = req.files.full_image.path;
        var full_image_path = './public/images/' + entry._id + "/" + req.files.full_image.name;
        fs.rename(tmp_path, full_image_path, function(err) {
            if (err) throw err;
            fs.unlink(tmp_path, function() {
                if (err) throw err;
                    console.log('File uploaded to: ' + full_image_path + ' - ' + req.files.full_image.size + ' bytes');
            });
        });
    } else {
        var tmp_path = req.files.full_image.path;
        fs.unlink(tmp_path, function() {
            console.log('Delete temporary file');
        });
    }

    entryModel.find({},function(err, docs){
        res.render('index.jade', { title: 'City bug', entry: docs });
    });
};
