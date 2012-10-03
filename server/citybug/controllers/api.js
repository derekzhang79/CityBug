var environment = require('../environment'),
    service = require('../service'),
    passport = require('passport'),
    model =  service.useModel('model'),
    http = require('http'),
    KEYS = require('../key');

exports.add = function(req, res){
    model.Report.find({},function(err, docs){
        res.render('add.jade', { title: 'City bug', report: docs });
    });
};

exports.subscriptions = function(req, res){

    model.Subscription.find({})
        .populate('place')
        .populate('user','username email thumbnail_image')
        .exec(function (err, docs) {
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Cannot get subscription");
            res.end();
            return;
        } else {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "subscriptions":' + JSON.stringify(docs) + '}');
            res.end();
            return;
        }
    });
    
};

exports.user_detail = function(req, res) {
    console.log('get user feed');
    var url = req.url;
    var username = url.match( /[^\/]+\/?$/ );
    model.User.findOne({username: username}, {_id:1, username:1, email:1, thumbnail_image:1}, function(err, user){
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
            return;
        } else if(!user) {
            res.writeHead(404, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
            return;
        } else {
            model.Subscription.count({user: user._id}, function(err,subscription_count) {

                getAllReports({user: user._id}, function(reports){
                    var new_report = {};
                    new_report["user"] = ({_id:user._id,username:user.username,email:user.email});
                    new_report["subscribe_count"] = subscription_count;
                    new_report["reports"] = reports;

                    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                    res.write('{"user_detail":' + JSON.stringify(new_report) + '}');
                    res.end();
                });
            });
        }
    });
}

exports.subscriptions_username = function(req, res){
    var currentUsername = req.url.match( /[^\/]+\/?$/ );
    console.log("get subscribed place of current Username =>>> "+ currentUsername);

    // Find user by username
    model.User.findOne({username: currentUsername}, function(errUser, currentUser){
        if (errUser || currentUser == null) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Cannot get subscription of username "+ currentUsername);
            res.end();
            return;
        }
        // Find all subscriptions of user
        model.Subscription.find({user: currentUser._id})
        .populate('place')
        .exec(function (err, subs) {
            if (err) {
                res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write("Cannot get subscription of username "+ currentUsername);
                res.end();
                return;
            } else {
                var placeArray = [];
                //Get all places
                for (i in subs) {
                    placeArray.push(subs[i].place);
                }
                //Sort by title's alphabet
                placeArray = placeArray.sort(function(a, b) { 
                    var ret = 0;
                    var aCompare = a.title.toLowerCase();
                    var bCompare = b.title.toLowerCase();
                    if(aCompare > bCompare) 
                        ret = 1;
                    if(aCompare < bCompare) 
                        ret = -1; 
                    return ret;
                });

                res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write('{ "places":' + JSON.stringify(placeArray) + '}');
                res.end();
                return;
            }
        });
    });
    
};

exports.users = function(req, res){

    model.User.find({}) //, {username:1, password:1, email:1, created_at:1, last_modified:1})
        .exec(function (err, docs) {
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Can not get user");
            res.end();
            return;
        } else {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "users":' + JSON.stringify(docs) + '}');
            res.end();
            return;
        }
    });
    
};


exports.comment_post = function(req, res) {
    var url = req.url;
    // reg localhost:3003/api/report/505c1671ae45f73d0d000006/comment --> 505c1671ae45f73d0d000006
    var urlArrayID = url.match( /^.*?\/(\w+)\/[^\/]*$/ );    
    var currentID;
    // get :id from url
    if(urlArrayID != null && urlArrayID.length > 1) {
        currentID = urlArrayID[1];
    } else {
        res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
        res.write("Can not add new comment, wrong report ID\n Please use format /api/report/:id/comment");
        res.end();
        return;
    }
    
    //Find User by username from http basic
    model.User.findOne({username:req.user.username}, function (err, user){
        //add comment
        if (err) {
            console.log(err);
        } else if (user == null || user == undefined) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Can not add new comment, cannot find user Please use format /api/report/:id/comment");
            res.end();
        } else {
            var newComment = new model.Comment();
            newComment.text = req.body.text;
            newComment.user = user._id;
            newComment.report = currentID;
            newComment.last_modified = new Date();
            newComment.created_at = new Date();
            newComment.save(function (err){
                if (err) {
                    console.log(err);
                    res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                    res.write("Can not add new comment, save failed");
                    res.end();
                } else {
                    // find report by id
                    model.Report.findOne({_id:currentID}, function(err, report) {
                        if (err) {
                            console.log('err' + err);
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.write("Can not add new comment, cannot find user Please use format /api/report/:id/comment");
                            res.end();
                        } else if (report == null || report == undefined) {
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.write("Can not add new comment, wrong report ID\n Please use format /api/report/:id/comment");
                            res.end();
                        } else {
                            console.log('new comment ' + report);
                            report.comments.push(newComment._id);
                            report.save(function (err){
                                if (err) {
                                    console.log(err);
                                    res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                                    res.write("Can not add new comment, save comments failed");
                                    res.end();
                                } else {
                                    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'commented'});
                                    res.write(JSON.stringify(report));
                                    res.end();
                                }
                            });
                        }
                    });
                }
            });
        } 
    });
}

exports.add_comment = function(req, res){
    res.render('add_comment.jade', { title: 'City bug'});
};

// GET /api/reports >> get list of entries
exports.all_reports = function(req, res) {
    console.log('Get all report list');

    getAllReports({}, function(new_report){

        res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
        res.write('{ "reports":' + JSON.stringify(new_report) + '}');
        res.end();
        return;
    });    
                        
};

function getAllReports(queryString, callbackFunction) {
    // Query all report with all attribute
    // create custom json because relation database that 
    // report can get comment, but comment can get only _id 
    // so we query user in comment and make a new json
    // return have 3, none of report, report with comment, report without comment
    var new_report = [];
    var queryCount = 0;
    var maxQueryCount = 0;
    model.Report.find(queryString)
        .populate('user','username email thumbnail_image')
        .populate('categories','title')
        .populate('comments')
        .populate('imins')
        .populate('place')
        .exec(function (err, report) {
            if (err) { 
                console.log(err);
            }

            // have none of report
            if (report.length == 0 || report == null) {
                callbackFunction(report);
                return;
            };

            // find max comment, imin
            // find need to do before query
            for (r in report) {
                for (i in report[r].comments) {
                    if (report[r].comments[i]._id != null && report[r].comments.length > 0) {
                        if (i == 0) {
                            maxQueryCount++;
                        };
                    }
                    if (report[r].imins._id != null && report[r].imins.length > 0) {
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
                    if (report[r].comments[i]._id != null && report[r].comments.length > 0) {
                        query_comments["$or"].push({"_id":report[r].comments[i]._id});
                    }
                }

                // add query imin where _id:id or _id:id .... 
                var query_imins = {};
                query_imins["$or"] = [];
                for (i in report[r].imins) {
                    if (report[r].imins[i]._id != null && report[r].imins.length > 0) {
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
                        // have comment in any report
                        if (maxQueryCount == queryCount && maxQueryCount != 0) {

                            //Sorted by last_modified
                            new_report = new_report.sort(function(a, b) {
                                return new Date(b.last_modified).getTime() - new Date(a.last_modified).getTime();
                            });

                            // Return all Reports with all fields to callback function
                            callbackFunction(new_report);
                        }
                    });
                });   
            }
            //Sorted by last_modified
            new_report = new_report.sort(function(a, b) {
                return new Date(b.last_modified).getTime() - new Date(a.last_modified).getTime();
            });
            
            // none of comment in any report
            if (maxQueryCount == 0) {
                callbackFunction(new_report);
            };
    });
}

function isSignInWithUser(currentUser) {
    return true;
    // return false;
}

function getCurrentUserID(tmp) {
    return '505c0e2451a3f4ab11000003';
}

function sortReportByDistance(report, currentLat, currentLng, callbackFunction) {
    //sort by distance
    for ( i in report ) {
        if (report[i].place == null) {
            report[i].place = new model.Place();
        }
        report[i].place.distance = service.distanceCalculate(currentLat, currentLng, report[i].lat, report[i].lng);
        // console.log("distance > " + i + " => "+ report[i].place.distance);
    }
    //ใช้ตัวแปร distance จาก place 
    report = report.sort(function(a, b) {
        if (a.place.distance < b.place.distance) { return -1; }
        if (a.place.distance > b.place.distance) { return  1; }
        return 0;
    });

    callbackFunction(report);
}

function responseReportsJSONToClient(res, report, maxNumber) {
    var resultReports;
    if (report != null && report.length > maxNumber) 
        resultReports = report.slice(0,maxNumber);
    else
        resultReports = report;

    //Response to client
    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
    res.write('{ "reports":' + JSON.stringify(resultReports) + '}');
    res.end();
    return;
}

// GET /api/reports >> get list of reports
exports.reports = function(req, res) {

    console.log('Get report list');
    console.log('Get user ' + req.user);

    var currentLat = req.query.lat;
    var currentLng = req.query.lng;

    if (currentLat != null && currentLng != null) {
        console.log("get location from request lat:"+ currentLat +" lng:" + currentLng);
    } else {
        console.log("not get location from request");
    }

    var maxNumber = 30;

    // var currentUserID = getCurrentUserID(req.headers);
    // var currentUsername = req.query.username;
    // var currentPassword = req.query.password;

    var currentUsername = '';
    var currentPassword = '';

    if (req.user != undefined && req.user != null) {
        currentUsername = req.user.username;
        currentPassword = req.user.password;
    };
    // model.User.findOne({_id: currentUserID}, function(err,currentUser) { 

    model.User.findOne( { $and: [ { username: currentUsername }, { password: currentPassword } ] } , function(err,currentUser) { 
        if (err ) {
            console.log("Can not find username:"+ currentUsername+" with error:"+ err);
        } 

        //ถ้า USER sign in และ subscription ไม่เป็น null จะแสดง feed โดยเรียงลำดับตามเวลาที่แก้ไขล่าสุด และ แสดงเฉพาะสถานที่(place) ที่ถูก subscribe เท่านั้น 
        else if ( currentUser != null && isSignInWithUser(currentUser) == true ) {
            console.log("logged in with user "+ currentUser);
            model.Subscription.find({user: currentUser}, function(err,subscribes) { 
                if (err || subscribes == null || subscribes.length < 1) {
                    console.log("Can not find subscription with error "+ err);
                    getAllReports({}, function(report){
                        // ถ้า User sign in แล้ว แต่ไม่ได้ subscribe ใครเลย และมี location จะแสดง feed โดยเรียงลำดับตามระยะห่าง และเอาแค่ 30 อัน แรก
                        if (currentLng != null && currentLat != null) {
                            //sort by distance
                            sortReportByDistance(report, currentLat, currentLng, function(sortedReport){
                                responseReportsJSONToClient(res, sortedReport,maxNumber);
                                return;
                            });
                        }
                        // ถ้า User sign in แล้ว แต่ไม่ได้ subscribe ใครเลย และไม่มี location จะแสดง feed โดยเรียงลำดับตาม วันที่แก้ไข และเอาแค่ 30 อัน แรก 
                        else {
                            responseReportsJSONToClient(res, report,maxNumber);
                            return;
                        }
                    });

                } else { //have subscription
                    console.log("Can find subscription");
                    // ถ้า User sign in แล้ว มี subscribe แต่ถ้าไม่มี location service จะแสดงตามลำดับเวลาที่แก้ไขล่าสุด 30 อัน
                    
                    // create query where subscribe.user._id = "user._id"
                    var query = {};
                    query["$or"] = [];
                    query["$or"].push({"user":currentUser._id}); //check report.user is current user feed
                    for (i in subscribes) {
                        console.log(i + " subscribes >> "+ subscribes[i]);
                        if (subscribes[i].place != null && subscribes[i].place != undefined) {
                            query["$or"].push({"place":subscribes[i].place}); //check report.place is in subscribe
                        }
                    }

                    console.log("query[$or] subscribe is => "+ query["$or"]);

                    var qq = {};
                    if(query["$or"].length != 0) {
                        qq = query;
                    }
                    //find only subscribed report
                    getAllReports(qq, function(report){
                        if (err) { 
                            console.log("can not find report with error "+err);
                        }

                        responseReportsJSONToClient(res, report,maxNumber);
                        return;
                    });
                }
            });
        } 

        else if (err || currentUser == null || currentUser == undefined  || isSignInWithUser(currentUser) == false ) {
            console.log("Not signed in user >> Can not find user at /api/reports");

            getAllReports({}, function(report){
                if (err || report == null) { 
                    console.log(err);
                    console.log("report is null");
                    responseReportsJSONToClient(res, report,maxNumber);
                    return;
                }

                //ถ้า USER ไม่ sign in และมี lat lng จะแสดง feed โดยเรียงลำดับตามระยะห่าง เทียบกับ report.lat lng (30อันแรก)
                if ( currentLat != null && currentLng != null ) {
                    console.log("Not signin & current lat ="+ currentLat+" lng = "+ currentLng);

                    //sort by distance
                    sortReportByDistance(report, currentLat, currentLng, function(sortedReport){
                        responseReportsJSONToClient(res, sortedReport,maxNumber);
                        return;
                    });

                } else {
                     responseReportsJSONToClient(res, report,maxNumber);
                    return;
                }
            });
        }
    });
};

// GET /api/report/{id} >> get one report from id
exports.report = function(req, res) {
    var url = req.url;
    var currentID = url.match( /[^\/]+\/?$/ );

    
    // Query all report with all attribute
    // create custom json because relation database that 
    // report can get comment, but comment can get only _id 
    // so we query user in comment and make a new json
    // Query all report with all attribute
    // return have 3, none of report, report with comment, report without comment
    var new_report = [];
    var queryCount = 0;
    var maxQueryCount = 0;
    model.Report.findOne({_id:currentID})
        .populate('user','username email thumbnail_image')
        .populate('categories','title')
        .populate('comments')
        .populate('imins')
        .populate('place')
        .exec(function (err, report) {
            if (err) { 
                console.log(err);
                return;
            }

            // have none of report
            if (report == null || report.length == 0) {
                res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write('{ "reports":' + JSON.stringify(report) + '}');
                res.end();
                return;
            };


            // find max comment, imin
            // find need to do before query
            for (i in report.comments) {
                if (report.comments[i]._id != null && report.comments.length > 0) {
                    if (i == 0) {
                        maxQueryCount++;
                    };
                }
                if (report.imins._id != null && report.imins.length > 0) {
                    if (i == 0) {
                        maxQueryCount++;
                    };
                };
            }

            // add query comment where _id:id or _id:id .... 
            var query_comments = {};
            query_comments["$or"] = [];
            for (i in report.comments) {
                if (report.comments[i]._id != null && report.comments.length > 0) {
                    query_comments["$or"].push({"_id":report.comments[i]._id});
                }
            }            
            // add query imins where _id:id or _id:id ....
            var query_imins = {};
            query_imins["$or"] = [];
            for (i in report.imins) {
                if (report.imins[i]._id != null && report.imins.length > 0) {
                    query_imins["$or"].push({"_id":report.imins[i]._id});
                }
            }

            // get all list 
            queryListComment(query_comments, 0, function(comments, index, isQueryComment) {

                // get all comment
                queryListImin(query_imins, 0, function(imins, index, isQueryImins) {
                    // add data to report
                    new_report.push(
                        {"user":report.user,
                         "_id":report._id,
                         "comments":comments,
                         "title":report.title,
                         "lat":report.lat,
                         "lng":report.lng,
                         "note":report.note,
                         "full_image":report.full_image,
                         "thumbnail_image":report.thumbnail_image,
                         "is_resolved":report.is_resolved,
                         "categories":report.categories,
                         "place":report.place,
                         "imins":imins,
                         "last_modified":report.last_modified,
                         "created_at":report.created_at
                        });

                    if (isQueryComment || isQueryImins) {
                        queryCount++;
                    };
                    // have comment in report
                    if (maxQueryCount == queryCount && maxQueryCount != 0) {

                        res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                        res.write('{ "reports":' + JSON.stringify(new_report) + '}');
                        res.end();
                    }
                });
            });   
        // none of comment in report
        if (maxQueryCount == 0) {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "reports":' + JSON.stringify(new_report) + '}');
            res.end();
        };
    });
};

exports.report_post = function(req, res) {
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
    
    
    var thumbnail_image_type = req.files.thumbnail_image.type.split("/");
    var full_image_type = req.files.full_image.type.split("/");
    /*
    console.log("unicode of received title = ");
    for (i in req.body.title) {
        console.log(i + ">> "+ req.body.title.charCodeAt(i));
    }
    */
    report.title = req.body.title;
    report.lat = req.body.lat;
    report.lng = req.body.lng;
    report.note = req.body.note;
    report.is_resolved = false;
    report.imin_count = 0;
    report.last_modified = new Date();
    report.created_at = new Date();

    if (req.files.thumbnail_image != null && thumbnail_image_type[0] == 'image' && thumbnail_image_type[1] != 'gif') {
        var thumbnail_image_extension = req.files.thumbnail_image.type.match( /[^\/]+\/?$/ );
        var thumbnail_image_short_path = "/images/report/" + report._id + "_thumbnail." + thumbnail_image_extension;
        report.thumbnail_image = thumbnail_image_short_path;
    };
    if (req.files.full_image != null && full_image_type[0] == 'image' && full_image_type[1] != 'gif') {
        var full_image_extension = req.files.full_image.type.match( /[^\/]+\/?$/ );
        var full_image_short_path = "/images/report/" + report._id + "." + full_image_extension;
        report.full_image = full_image_short_path;
    };
/*
    , categories        : [{ type: Schema.Types.ObjectId, ref: 'Category' }]
    , user              : { type: Schema.Types.ObjectId, ref: 'User' }
    , place             : { type: Schema.Types.ObjectId, ref: 'Place' }
*/

    //Find User from username
    model.User.findOne({username: req.user.username }, function(err,user) {   
        if (user == null) {
            // delete temp upload
            var tmp_path = req.files.thumbnail_image.path;
            fs.unlink(tmp_path, function() {
                console.log('Delete temporary file');
            });
            var tmp_path = req.files.full_image.path;
            fs.unlink(tmp_path, function() {
                console.log('Delete temporary file');
            });

            res.writeHead(401, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
            return;
        };
        // Set user to Report
        report.user = user._id;

        //Find Category from request
        var query = {};
        query["$or"]=[];
        for (cat in req.body.categories) {
            query["$or"].push({"title":req.body.categories[cat]});
        }
        var x = req.body.categories;
        var r = /\\u([\d\w]{4})/gi;

        x = x.replace(r, function (match, grp) {
        return String.fromCharCode(parseInt(grp, 16)); } );
        x = x.split('"');
        //Category can not add from client
        model.Category.find({title: x[1]}, function(err,catTitleFromClient) { 
          
            if (!err && catTitleFromClient != null) {
                for (i in catTitleFromClient ) {
                    // Push category to Report's category list
                    report.categories.push(catTitleFromClient[i]._id);
                    console.log('categories' + catTitleFromClient);
                }
            } else {
                console.log('err' + err);
            }

            model.Place.findOne({id_foursquare: req.body.place_id }, function(err,place) {   
                console.log(">>>>>>>>>>>>>>>> " + req.body.place_id);
                if (!err && place != null) { //Can find place in database
                    report.place = place._id;
                    console.log("Can find place in database > "+ place);
                    //--------------------------------------------------------------
                    //Save new Report to Database
                    report.save(function (err) {
                        if (!err){
                            console.log('Success! with ' + report);
                            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'posted'});
                            res.end();
                            
                        } else {
                            console.log('Error !'+ err);
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.end();
                        }
                    });
                    //--------------------------------------------------------------

                } else { //Can NOT find place in database
                    console.log("Can NOT find place in database");

                    //Save place
                    var newPlace = new model.Place();
                    newPlace.id_foursquare = req.body.place_id;       
                    newPlace.title = req.body.place_title;         
                    newPlace.lat = req.body.place_lat;                   
                    newPlace.lng = req.body.place_lng;
                    newPlace.last_modified = new Date();
                    newPlace.created_at = new Date();

                    newPlace.save(function (err){
                        if (err) {
                            console.log(err);
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.end();
                        } else {
                            console.log('>>> Saved place' + newPlace);
                            report.place = newPlace._id;

                            //--------------------------------------------------------------
                            //Save new Report to Database
                            report.save(function (err) {
                                if (!err){
                                    console.log('Success! with ' + report);
                                    res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'posted'});
                                    res.end();
                                    
                                } else {
                                    console.log('Error !'+ err);
                                    res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                                    res.end();
                                }
                            });
                            //--------------------------------------------------------------
                        }
                    }); 
                }

            });
        });
        // make directory
        fs.mkdirParent("./public/images/report/");
        
        //save picture to /public/images/report/:id
        if (req.files.thumbnail_image != null && thumbnail_image_type[0] == 'image' && thumbnail_image_type[1] != 'gif') {
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
        if (req.files.full_image != null && full_image_type[0] == 'image' && full_image_type[1] != 'gif') {
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

    });

};

// GET /api/categories >> get list of categories
exports.categories = function(req, res) {
    model.Category.find({}, function(err,docs) {
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Cannot get categories");
            res.end();
            return;
        } else {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "categories":' + JSON.stringify(docs) + '}');
            res.end();
            return;
        }
    });
}

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
                console.log('query comment ' + err);
                return;
            }
            if (comments != null && comments.length > 0) {
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
                console.log('query imin' + err);
                return;
            }
            if (comments != null && comments.length > 0) {
                callbackFunction(imins, r, true);                  
            } 
            return;
    });
}
