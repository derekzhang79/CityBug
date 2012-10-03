var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model');

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
			newUser.password = req.body.password;
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