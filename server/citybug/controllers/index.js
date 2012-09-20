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
    
    // // add mockup place
    // var place = new model.Place();
    // place.title = 'สวนดอกจ้า';
    // place.lat = 12.34;
    // place.lng = 45.67;
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

			res.render('index.jade', { title: 'City bug', report: report });
    });

};