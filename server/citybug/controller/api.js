var mongoose    = require('mongoose'),
    reportModel = require('../models/model');

exports.add = function(req, res){
    reportModel.find({},function(err, docs){
        res.render('add.jade', { title: 'City bug', report: docs });
    });
};

// GET /api/reports >> get list of entries
exports.reports = function(req, res){
    console.log('get list');
    res.contentType('application/json'); 
 
    reportModel.find({},function(err, docs){
        res.send('{ "report":' + JSON.stringify(docs) + ' }');
    });

};

// GET /api/report/{id} >> get one report from id
exports.report = function(req, res){
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );
    console.log('current : '+currentID);

    res.contentType('application/json');
    reportModel.findOne({_id:currentID }, function(err,docs) {    	
        res.send('"report" : ' + JSON.stringify(docs));
	});
};

exports.report_post = function(req, res){
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
    report = new reportModel();
    report.title = req.body.title;
    report.thumbnail_image = "/images/" + report._id + "/" + req.files.thumbnail_image.name;
    report.full_image = "/images/"+ report._id + "/" + req.files.full_image.name;
    report.lat = req.body.lat;
    report.long = req.body.long;
    report.note = req.body.note;
    report.categories = req.body.categories;
    report.last_modified = new Date();

    report.save(function (err) {
        if (!err){
            console.log('Success!');
            res.statusCode = 200;
        }
        else {
            console.log('Error !');
            console.log(err);
            res.statusCode = 500;
        }
    });

    // make directory
    fs.mkdirParent("./public/images/" + report._id + "/");

    //save picture to /public/images/:id/pictureName

    if (req.files.thumbnail_image.name) {
        // get the temporary location of the file : ./uploads
        var tmp_path = req.files.thumbnail_image.path;
        // set where the file should actually exists - in this case it is in the "images" directory
        var thumbnail_image_path = './public/images/' + report._id + "/" + req.files.thumbnail_image.name;
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
        var full_image_path = './public/images/' + report._id + "/" + req.files.full_image.name;
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

    reportModel.findOne({_id:report._id }, function(err,docs) {       
        res.render('add_response', {title: 'City bug',report: docs});
    });
};
