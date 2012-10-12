var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model');


exports.users_all = function(req, res){

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

exports.editThumbnailImage = function(req, res) {
	var currentUser = req.user;

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

	var thumbnail_image_type = req.files.thumbnail_image.type.split("/");
	if (req.files.thumbnail_image != null && thumbnail_image_type[0] == 'image' && thumbnail_image_type[1] != 'gif') {
        var thumbnail_image_extension = req.files.thumbnail_image.type.match( /[^\/]+\/?$/ );
        var thumbnail_image_short_path = "/images/user/" + currentUser._id + "_thumbnail." + thumbnail_image_extension;
        currentUser.thumbnail_image = thumbnail_image_short_path;
        currentUser.save(function (err) {
	        if (!err){
	        	//delete temp file
		        var tmp_path = req.files.thumbnail_image.path;
		        fs.unlink(tmp_path, function() {
		            console.log('Delete user thumbnail image temporary file');
		        });

		        // make directory
		        fs.mkdirParent("./public/images/user/");
		        
		        //save picture to /public/images/report/:id
		        if (req.files.thumbnail_image != null && thumbnail_image_type[0] == 'image' && thumbnail_image_type[1] != 'gif') {
		            // get the temporary location of the file : ./uploads
		            var tmp_path = req.files.thumbnail_image.path;
		            // set where the file should actually exists - in this case it is in the "images" directory
		            var thumbnail_image_path = './public' + thumbnail_image_short_path;
		            console.log('thumbnail_image_path '+ thumbnail_image_path + ' tmp_path ' + tmp_path);

		            fs.rename(tmp_path, thumbnail_image_path, function(err) {
		                if (err) throw err;
		                // delete the temporary file, so that the explicitly set temporary upload dir does not get filled with unwanted files
		                fs.unlink(tmp_path, function(err) {
		                    if (err) throw err;
	                        console.log('File uploaded to: ' + thumbnail_image_path + ' - ' + req.files.thumbnail_image.size + ' bytes');
	                        res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
				            res.write('{ "users":' + JSON.stringify(currentUser) + '}');
				            res.end();
				            return;
		                });
		            });        
		        } else {
		            // delete temporary file : ./upload
		            var tmp_path = req.files.thumbnail_image.path;
		            fs.unlink(tmp_path, function() {
		                console.log('Delete temporary file');
		            });
		        }
		    } else {
		    	res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
	            res.end();
	            return;
		    }
	    });
    }
}

exports.user = function(req, res) {
	console.log('get user');
	var url = req.url;
    var username = url.match( /[^\/]+\/?$/ );
	model.User.findOne({username: username}, {_id:1, username:1, email:1, thumbnail_image:1, last_modified:1, created_at:1}, function(err, user) {
		if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
		} else if(!user) {
            res.writeHead(404, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
		} else if (user) {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{"user":' + JSON.stringify(user) + '}');
            res.end();
		}
	});
}

exports.sign_in = function(req, res) {
	console.log('sign in');
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'authenticated'});
    res.write('{"user":' + JSON.stringify(req.user) + '}');
	res.end();
}

exports.sign_out = function(req, res){
	req.logout();
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
};

exports.sign_up = function(req, res) {
	console.log('sign up');

	if (req.body.username == null || req.body.password == null || req.body.email == null) {
		res.writeHead(500, { 'Content-Type' : 'application/json;/charset=utf-8', 'Text' : 'missing variable'});
		res.end();
		return;
	};

	findUser(req.body.username, req.body.email, function(err, user_existed, email_existed){
		if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
		} else if (user_existed) {
			console.log("sign up username existed");
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'username existed'});
            res.end();
		} else if (email_existed) {
			console.log("sign up email existed");
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'email existed'});
            res.end();
		} else if (user_existed == false && email_existed == false) {
			var newUser = model.User();
			newUser.username = req.body.username;
			newUser.password = service.encodePassword(req.body.password);
			newUser.email = req.body.email;
			newUser.save(function(err) {
				if (err) {
		            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
		            res.end();
				} else {
					console.log('sign in complete');
		            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'registered'});
		            res.end();
				}
			});
		}
	});
}

function findUser(username, email, callbackFunction) {
	model.User.findOne({username:username}, function(err, userWithUsername){
		var userExisted = false, emailExisted = false;
		if (userWithUsername != null) {
			userExisted = true;
		} 
		model.User.findOne({email:email}, function(err, userWithEmail){
			if (userWithEmail != null) {
				emailExisted = true;
			}
			callbackFunction(err, userExisted, emailExisted); 
		});
	});
}