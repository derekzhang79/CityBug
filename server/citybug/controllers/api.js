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
 
    model.Report.find({})
        .populate('user','username email thumbnail_image')
        .populate('categories','title')
        .exec(function (err, report) {
            if (err) { 
                return handleError(err);
            }
            res.send('{ "reports":' + JSON.stringify(report) + ' }');
    });
};

// GET /api/report/{id} >> get one report from id
exports.report = function(req, res){
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );
    res.contentType('application/json');

    model.Report.findOne({_id:currentID})
        .populate('user','username email thumbnail_image')
        .populate('categories','title')
        .populate('comments')
        .populate('imins')
        .populate('place')
        .exec(function (err, report) {
            if (err) { 
                return handleError(err);
            }
            res.send('{ "reports":' + JSON.stringify(report) + ' }');
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
    var report = new model.Report();
    
    var thumbnail_image_type = req.files.thumbnail_image.type.match( /[^\/]+\/?$/ );
    var thumbnail_image_short_path = "/images/report/" + report._id + "_thumbnail." + thumbnail_image_type;
    var full_image_type = req.files.full_image.type.match( /[^\/]+\/?$/ );
    var full_image_short_path = "/images/report/" + report._id + "." + full_image_type;
    
    report.title = req.body.title;
    report.thumbnail_image = thumbnail_image_short_path;
    report.full_image = full_image_short_path;
    report.lat = req.body.lat;
    report.lng = req.body.lng;
    report.note = req.body.note;
    report.is_resolved = false;
    report.imin_count = 0;
    report.last_modified = new Date();
    report.created_at = new Date();

/*
    , categories        : [{ type: Schema.Types.ObjectId, ref: 'Category' }]
    , user              : { type: Schema.Types.ObjectId, ref: 'User' }
    , place             : { type: Schema.Types.ObjectId, ref: 'Place' }
*/

    //Find User from username
    model.User.findOne({username: req.body.username }, function(err,user) {   
        if (user == null) {
            // res.contentType('Content-Type', 'application/json');
            // res.statusCode = 200;
            // res.send(2003);
            res.redirect('/');
            return;
        };
        // Set user to Report
        report.user = user._id;

        // model.Category.find({ $or : [ { title : 'cat1' } , { title : 'cat2' } ] } , function(err,catArray) { 

        //Find Category from request
        var query = {};
        query["$or"]=[];
        for (cat in req.body.categories) {
            query["$or"].push({"title":req.body.categories[cat]});
        }

        //Category can not add from client
        model.Category.find(query, function(err,catTitleFromClient) { 
          
            if (!err) {
                for (i in catTitleFromClient ) {
                    // Push category to Report's category list
                    report.categories.push(catTitleFromClient[i]._id);
                    console.log('categories' + catTitleFromClient);
                }
            } else {
                console.log('err' + err);
            }


            model.Place.findOne({_id: req.body.placeID }, function(err,place) {   

                if (!err && place != null) { //Can find place in database
                    report.place = place._id;
                } else {
                    //เอา id ที่ได้ ไป map กับ foursquare

                }

                //Save new Report to Database
                report.save(function (err) {
                    if (!err){
                        console.log('Success! with ' + report);
                        console.log('report JSON >>' + JSON.stringify(report));
                        res.statusCode = 200;
                        res.contentType('application/json'); 
                        res.send("Add new report success!");
                        //res.render('add_response', {title: 'City bug', report: report});

                        //Query report with user data
                        model.Report.findOne({ title: report.title })
                        .populate('user','username email thumbnail_image')
                        .populate('categories','title')
                        .exec(function (err, report) {
                            if (err) { 
                                return handleError(err);
                            }
                            console.log('The creator is ' + report); 
                            console.log('The creator JSON is ' + JSON.stringify(report));
                    })
                        
                    } else {
                        console.log('Error !');
                        console.log(err);
                        res.statusCode = 500;
                        res.contentType('application/json'); 
                        res.send("Add new report not success with error "+err);
                        // res.send();
                    }
                });

            });
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

// GET /api/categories >> get list of categories
exports.categories = function(req, res) {
    res.contentType('application/json');
    model.Category.find({}, function(err,docs) {   
        res.send('{ "categories":' + JSON.stringify(docs) + '}');
    });
}
