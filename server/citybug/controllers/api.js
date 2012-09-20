var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model');

exports.add = function(req, res){
    model.Report.find({},function(err, docs){
        res.render('add.jade', { title: 'City bug', report: docs });
    });
};

// GET /api/reports >> get list of entries
exports.reports = function(req, res){
    console.log('get list');
    res.contentType('application/json'); 
 
    model.Report.find({},function(err, docs){
        res.send('{ "reports":' + JSON.stringify(docs) + ' }');
    });

};

// GET /api/report/{id} >> get one report from id
exports.report = function(req, res){
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );

    res.contentType('application/json');
    model.Report.findOne({_id:currentID }, function(err,docs) {   
        res.send('"reports" : ' + JSON.stringify(docs));
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

    // // add mockup user nut id = 5059a5241b9c322369000011
    // var user = new model.User();
    // user.username = 'nut';

    // user.save(function (err){
    //     if (err) {
    //         console.log(err);
    //         // do something
    //     } else {
    //         console.log('user' + user);
    //     }
    // }); 


    // save data to db
    var report = new model.Report();
    
    var thumbnail_image_type = req.files.thumbnail_image.name.match( /[^.]+.?$/ );
    var thumbnail_image_short_path = "/images/report/" + report._id + "_thumbnail." + thumbnail_image_type;
    var full_image_type = req.files.full_image.name.match( /[^.]+.?$/ );
    var full_image_short_path = "/images/report/" + report._id + "." + full_image_type;
    
    report.title = req.body.title;
    report.thumbnail_image = thumbnail_image_short_path;
    report.full_image = full_image_short_path;
    report.lat = req.body.lat;
    report.long = req.body.long;
    report.note = req.body.note;
    report.is_resolved = false;
    report.imin_count = 0;
    report.categories = req.body.categories;
    report.last_modified = new Date();
    report.created_at = new Date();


    model.User.findOne({username: 'nut' }, function(err,user) {   
        console.log('find user1 ' + user + ' -id- ' + user._id);
        
        report.user = user._id;

        report.save(function (err) {
            if (!err){
                console.log('Success! with ' + report.user.username);
                console.log('report JSON >>' + JSON.stringify(report));
                res.statusCode = 200;
                res.render('add_response', {title: 'City bug', report: report});

                model.Report.findOne({ title: report.title }).populate('user').exec(function (err, report) {
                    if (err) 
                        return handleError(err);
                    console.log('The creator is ' + report); // prints "The creator is Aaron"
                })
            } else {
                console.log('Error !');
                console.log(err);
                res.statusCode = 500;
            }
        });
    });


    // make directory
    fs.mkdirParent("./public/images/report/");

    //save picture to /public/images/report/:id

    if (req.files.thumbnail_image.name) {
        // get the temporary location of the file : ./uploads
        var tmp_path = req.files.thumbnail_image.path;
        // set where the file should actually exists - in this case it is in the "images" directory
        var thumbnail_image_path = './public' + thumbnail_image_short_path;
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
        var full_image_path = './public' + full_image_short_path;
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
};
