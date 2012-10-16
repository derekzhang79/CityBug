/*!
* Demo registration application
* Copyright(c) 2011 Jean-Tiare LE BIGOT <admin@jtlebi.fr>
* MIT Licensed
*/
var environment = require('../environment');
var service = require('../service');
    service.init(environment),
    api = require('../controllers/api')
;
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

    api.getAllReports({}, function(reports) {
        res.render('index.jade',{title: 'City bug',report: reports});
    });
};
