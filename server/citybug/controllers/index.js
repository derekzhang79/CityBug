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
    
    //  // add mockup place
    // var place = new model.Place();
    // place.title = 'สวนดอกจ้า';
    // place.id_foursquare = "mockupplaceid";
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


    // Query all report with all attribute
    // create custom json because relation database that 
    // report can get comment, but comment can get only _id 
    // so we query user in comment and make a new json
    // Query all report with all attribute
    var new_report = [];
    var queryCount = 0;
    var maxQueryCount = 0;
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

            // have none of report
            if (report.length == 0) {
                res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write('{ "reports":' + JSON.stringify(report) + '}');
                res.end();
            };


            // find max comment, imin
            // find need to do before query
            for (r in report) {
                for (i in report[r].comments) {
                    if (report[r].comments[i]._id != undefined && report[r].comments.length > 0) {
                        if (i == 0) {
                            maxQueryCount++;
                        };
                    }
                    if (report[r].imins._id != undefined && report[r].imins.length > 0) {
                        if (i == 0) {
                            maxQueryCount++;
                        };
                    };
                }
            }

            for (r in report) {
                
                // add query comment where _id:id or _id:id .... 
                var query_comments = {};
                query_comments["$or"] = [];
                for (i in report[r].comments) {
                    if (report[r].comments[i]._id != undefined && report[r].comments.length > 0) {
                        query_comments["$or"].push({"_id":report[r].comments[i]._id});
                    }
                }

                // add query imin where _id:id or _id:id .... 
                var query_imins = {};
                query_imins["$or"] = [];
                for (i in report[r].imins) {
                    if (report[r].imins[i]._id != undefined && report[r].imins.length > 0) {
                        query_imins["$or"].push({"_id":report[r].imins[i]._id});
                    }
                }

                // get all comment
                queryListComment(query_comments, r, function(comments, index, isQueryComment) {

                    // get all imin
                    queryListImin(query_imins, index, function(imins, index, isQueryImins) {
                        // add data to report
                        new_report.push(
                            {"user":report[index].user,
                             "_id":report[index]._id,
                             "comments":comments,
                             "title":report[index].title,
                             "lat":report[index].lat,
                             "lng":report[index].lng,
                             "note":report[index].note,
                             "full_image":report[index].full_image,
                             "thumbnail_image":report[index].thumbnail_image,
                             "is_resolved":report[index].is_resolved,
                             "categories":report[index].categories,
                             "place":report[index].place,
                             "imins":imins,
                             "last_modified":report[index].last_modified,
                             "created_at":report[index].created_at
                            });

                        if (isQueryComment || isQueryImins) {
                            queryCount++;
                        };
                        if (maxQueryCount == queryCount) {

                            // implement sort here //
                            //                     //
                            //                     //
                            /////////////////////////

                            res.render('index.jade',{title: 'City bug',report: new_report})
                        }
                    });
                });   
            }
    });
};

function queryListComment(query, r, callbackFunction) {
    if (query['$or'].length <= 0) {
        var emptyQuery = [];
        callbackFunction(emptyQuery, r, false);
        return;
    };
    model.Comment.find(query)
        .populate('user','username email thumbnail_image')
        .exec(function (err, comments) {
            if (err) { 
                console.log('query ' + err);
                return;
            }
            if (comments != undefined && comments.length > 0) {
                callbackFunction(comments, r, true);                  
            } 
            return;
    });
}

function queryListImin(query, r, callbackFunction) {
    if (query['$or'].length <= 0) {
        var emptyQuery = [];
        callbackFunction(emptyQuery, r, false);
        return;
    };
    model.Imin.find(query)
        .populate('user','username email thumbnail_image')
        .exec(function (err, imins) {
            if (err) { 
                console.log('query ' + err);
                return;
            }
            if (comments != undefined && comments.length > 0) {
                callbackFunction(imins, r, true);                  
            } 
            return;
    });
}
