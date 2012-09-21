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


    //add mockup user 
    model.User.find({} , function(err,allUser) { 
        if (err || allUser.length < 1) {
            var user = new model.User();
            user.username = 'admin';
            user.password = '1234';
            user.email = '123@ggg.com';
            user.created_at = new Date();
            user.last_modified = new Date();
            user.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('user' + user);
                }
            }); 
        }
    });

    // add Mock up category
    model.User.find({} , function(err,allUser) { 
        if (err || allUser.length < 1) {
            var cat1 = new model.Category();
            cat1.title = 'cat1';
            cat1.last_modified = new Date();
            cat1.created_at = new Date();
            var cat2 = new model.Category();
            cat2.title = 'cat2';
            cat2.last_modified = new Date();
            cat2.created_at = new Date();
            cat1.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('cat1' + cat1);
                }
            }); 
            cat2.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('cat2' + cat2);
                }
            }); 
        }
    });
    
     // add mockup place
    // var place = new model.Place();
    // place.title = 'สวนดอกจ้า';
    // place.id_foursquare = "40a55d80f964a52020f31ee3";
    // place.lat = 122.34;
    // place.lng = 453.67;
    // place.created_at = new Date();
    // place.last_modified = new Date();
    // place.save(function (err){
    //     if (err) {
    //         console.log(err);
    //         // do something
    //     } else {
    //         console.log('place' + place);
    //     }
    // }); 

    // var comment = new model.Comment();
    // comment.text = 'เหงาแท้ๆเธอ';
    // comment.user = '505c1650ae45f73d0d000003';
    // comment.report = '505c165bae45f73d0d000004';
    // comment.last_modified = new Date();
    // comment.created_at = new Date();

    // comment.save(function (err){
    //     if (err) {
    //         console.log(err);

    //     } else {
    //         model.Report.findOne({_id:'505c165bae45f73d0d000004'})
    //         .exec(function (err, report) {
    //             if (err) { 
    //                 return handleError(err);
    //             }
    //             report.comments.push(comment._id); 

    //             report.save(function(err){
    //                 console.log('report' + report);
    //             });
    //         });

    //     }
    // }); 
    var json_report = [];
    var queryCount = 0;
    var maxCommentCount = 0;
    model.Report.find({})
        .populate('user','username email thumbnail_image')
        .populate('categories','title')
        .populate('comments')
        .populate('imins')
        .populate('place')
        .exec(function (err, report) {
            if (err) { 
                return handleError(err);
            }

            for (r in report) {
                var query = {};
                query["$or"] = [];
                for (i in report[r].comments) {
                    if (report[r].comments[i]._id != undefined && report[r].comments.length > 0) {
                        query["$or"].push({"_id":report[r].comments[i]._id});
                        if (i == 0) {
                            maxCommentCount++;
                        };
                    }
                }

                if (!(query["$or"].length > 0)) {
                    json_report.push(
                            {"user":report[r].user,
                             "_id":report[r]._id,
                             "comments":[],
                             "title":report[r].title,
                             "lat":report[r].lat,
                             "lng":report[r].lng,
                             "note":report[r].note,
                             "full_image":report[r].full_image,
                             "thumbnail_image":report[r].thumbnail_image,
                             "is_resolved":report[r].is_resolved,
                             "categories":report[r].categories,
                             "place":report[r].place,
                             "imins":report[r].imins,
                             "last_modified":report[r].last_modified,
                             "created_at":report[r].created_at
                    });
                } else {
                    queryComment(query, report, r, json_report, function(comments) {
                        queryCount++;

                        json_report.push(
                            {"user":report[r].user,
                             "_id":report[r]._id,
                             "comments":comments,
                             "title":report[r].title,
                             "lat":report[r].lat,
                             "lng":report[r].lng,
                             "note":report[r].note,
                             "full_image":report[r].full_image,
                             "thumbnail_image":report[r].thumbnail_image,
                             "is_resolved":report[r].is_resolved,
                             "categories":report[r].categories,
                             "place":report[r].place,
                             "imins":report[r].imins,
                             "last_modified":report[r].last_modified,
                             "created_at":report[r].created_at
                        });
                        if (maxCommentCount == queryCount) {
                            // res.render('index.jade', { title: 'City bug', report: json_report });
                            console.log('my report' + JSON.stringify(json_report));
                        }
                    });
                }
            }
            res.render('index.jade', { title: 'City bug', report: report });
    });

};

function queryComment(query, report, r,json_report, callbackFunction) {

    model.Comment.find(query)
        .populate('user','username email thumbnail_image')
        .exec(function (err, comments) {
            if (err) { 
                console.log(err);
                return;
            }
            if (comments != undefined && comments.length > 0) {
                callbackFunction(comments);                  
            } 
            return;
    });

}
