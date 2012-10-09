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
        if (err || allUser == null || allUser.length < 1) {

            var user2 = new model.User();
            user2.username = 'admin';
            user2.password = 'qwer4321';
            user2.email = 'admin@citybug.in.th';
            user2.created_at = new Date();
            user2.last_modified = new Date();
            user2.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('saved user' + user);
                }
            }); 
            
            var user = new model.User();
            user.username = 'user';
            user.password = '1234';
            user.email = '123@ggg.com';
            user.created_at = new Date();
            user.last_modified = new Date();
            user.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('saved user' + user);
                }
            }); 

            
        } else if (err || allUser == null || allUser.length < 1 || (allUser != null && allUser.length < 3)) {
            var ODusername = ['anusorn', 'anyarat', 'apirak', 'arthit', 'chatchai', 'chongsawad', 'nattapol', 'nat', 'nawaporn', 'nirut', 'nutchaya', 'nut', 'panudate', 'panu', 'patcharaporn', 'patipat', 'pirapa', 'polawat', 'prathan', 'sarocha', 'siriwat', 'supatjaree', 'tawee', 'teerapong', 'teerarat', 'thanyawan', 'tarongpong', 'thawatchai', 'twin', 'veerapong', 'wasan', 'pui'];
            var ODpassword = '1234';

            for (i in ODusername) {
                var ODuser = new model.User();
                ODuser.username = ODusername[i];
                ODuser.password = ODpassword;
                ODuser.email = ODusername[i]+'@opendream.co.th';
                ODuser.created_at = new Date();
                ODuser.last_modified = new Date();
                ODuser.save(function (err){
                    if (err) {
                        console.log(err);
                        // do something
                    } else {
                        console.log('saved user' + ODuser);
                    }
                }); 
            }
        }
    });

    //id of opendream BKK
    model.Place.findOne({id_foursquare: '4b0e2fdcf964a520bb5523e3'}, function (err, opendreamPlace) {
        if (opendreamPlace != null && !err) {
            model.User.find({} , function(errUser,allUser) { 
                model.Subscription.find({} , function(errSub,allSub) { 
                    if (!errUser && (errSub || allSub == null || allSub.length < 3)) {
                        for (i in allUser) {
                            var sub = new model.Subscription();
                            sub.place = opendreamPlace;
                            sub.user = allUser[i];
                            sub.created_at = new Date();
                            sub.last_modified = new Date();
                            sub.save(function (err){
                                if (err) {
                                    console.log(err);
                                    // do something
                                } else {
                                    console.log('saved sub OD bkk' + sub);
                                }
                            }); 
                        }
                    }
                });
                
            });
        }
    });

    //id of opendream chiangmai 4f601418e4b0aee01425b61b
    model.Place.findOne({id_foursquare: '4f601418e4b0aee01425b61b'}, function (err, opendreamPlace) {
        if (opendreamPlace != null && !err) {
            model.User.find({} , function(errUser,allUser) { 
                model.Subscription.find({} , function(errSub,allSub) { 
                    if (!errUser && (errSub || allSub == null || allSub.length < 40)) {
                        for (i in allUser) {
                            var sub = new model.Subscription();
                            sub.place = opendreamPlace;
                            sub.user = allUser[i];
                            sub.created_at = new Date();
                            sub.last_modified = new Date();
                            sub.save(function (err){
                                if (err) {
                                    console.log(err);
                                    // do something
                                } else {
                                    console.log('saved sub OD chiangmai' + sub);
                                }
                            }); 
                        }
                    }
                });
                
            });
        }
    });

    // add Mock up category
    model.Category.find({} , function(err,allCategory) { 
        if (err || allCategory == null || allCategory.length < 1) {

            var catTitles = ['ไฟฟ้า','ประปา','ถนน','ขนส่งมวลชน','ชุมชน','สาธารณสมบัติ','อื่นๆ'];
            for (i in catTitles) {
                var cat1 = new model.Category();
                cat1.title = catTitles[i];
                cat1.last_modified = new Date();
                cat1.created_at = new Date();
                cat1.save(function (err){
                    if (err) {
                        console.log(err);
                        // do something
                    } else {
                        console.log('Saved cat' + cat1);
                    }
                }); 
            }
        }
    });

    //add mockup user 
    model.Subscription.find({} , function(err,allSubscription) { 
        if (err || allSubscription == null || allSubscription.length < 1) {

            model.User.findOne({username: 'admin'} , function(err,adminUser) {
                if (adminUser != null && !err) {

                    model.Place.find({} , function(err,allPlace) {
                        if (allPlace != null && allPlace.length > 0) {
                            var ss = new model.Subscription();
                            ss.place = allPlace[0]._id;
                            ss.user = adminUser._id;
                            ss.created_at = new Date();
                            ss.last_modified = new Date();
                            ss.save(function (err){
                                if (err) {
                                    console.log(err);
                                    // do something
                                } else {
                                    console.log('saved subscription' + ss);
                                }
                            }); 
                        }
                        if (allPlace != null && allPlace.length > 1) {
                            var ss2 = new model.Subscription();
                            ss2.place = allPlace[1]._id;
                            ss2.user =  adminUser._id; 
                            ss2.created_at = new Date();
                            ss2.last_modified = new Date();
                            ss2.save(function (err){
                                if (err) {
                                    console.log(err);
                                    // do something
                                } else {
                                    console.log('saved subscription' + ss2);
                                }
                            }); 
                        }
                    });
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
                console.log(err);
                return;
            }

            // have none of report
            if (report.length == 0) {
                res.render('index.jade',{title: 'City bug',report: report});
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
                        if (maxQueryCount == queryCount && maxQueryCount != 0) {

                            new_report = new_report.sort(function(a, b) {
                                return new Date(b.last_modified).getTime() - new Date(a.last_modified).getTime();
                            });

                            res.render('index.jade',{title: 'City bug',report: new_report});
                        }
                    });
                });   
            }
            if (maxQueryCount == 0) {
                new_report = new_report.sort(function(a, b) {
                    return new Date(b.last_modified).getTime() - new Date(a.last_modified).getTime();
                });
                res.render('index.jade',{title: 'City bug',report: new_report});
            };
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
            if (imins != undefined && imins.length > 0) {
                callbackFunction(imins, r, true);                  
            } 
            return;
    });
}
