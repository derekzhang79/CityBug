var environment = require('../environment'),
    service = require('../service'),
    passport = require('passport'),
    model =  service.useModel('model'),
    http = require('http');


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
                    model.Report.findOne({_id:currentID})
                        .populate('imins')
                        .exec(function(err, report) {
                        if (err) {
                            console.log('err' + err);
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.write("Can not add new comment, cannot find user Please use format /api/report/:id/comment");
                            res.end();
                        } else if (report == null || report == undefined) {
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.write("Can not add new comment, wrong report ID\n Please use format /api/report/:id/comment");
                            res.end();
                        } else if (!containUser(report.imins, user._id)) {
                            var imin = new model.Imin();
                            imin.user = req.user._id;
                            imin.report = report._id;
                            imin.created_at = new Date();
                            imin.last_modified = new Date();

                            report.imin_count = report.imin_count + 1;
                            report.imins.push(imin._id);
                            report.last_modified = new Date();
                            report.comments.push(newComment._id);
                            report.save(function(err){
                                if (err) {
                                    console.log(err);
                                    res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                                    res.end();
                                } else {
                                    imin.save(function(err){
                                        if (err) {
                                            console.log(err);
                                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                                            res.end();
                                        } else {
                                            console.log('save imin');
                                            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'imin add'});
                                            res.end();
                                        }
                                    });
                                }
                            });
                        } else {
                            console.log('new comment ' + report);
                            report.last_modified = new Date();
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

exports.add_comment = function(req, res) {
    res.render('add_comment.jade', { title: 'City bug'});
};

function containUser(arr, obj) {
    for(var i = 0; i < arr.length; i++) {
        if (arr[i].user.equals(obj)) return true;
    }
    return false;
}