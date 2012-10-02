var environment = require('../environment'),
    service = require('../service'),
    model =  service.useModel('model');

exports.sign_in = function(req, res) {
	console.log('sign in');
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'authenticated'});
	res.end();
}

exports.sign_out = function(req, res){
	req.logout();
	res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
	res.end();
};

exports.sign_up = function(req, res) {
	console.log('sign up');

	if (req.body.username == undefined || req.body.password == undefined || req.email == undefined) {
		res.writeHead(500, { 'Content-Type' : 'application/json;/charset=utf-8', 'Text' : 'missing variable'});
		res.end();
		return;
	};

	findUser(req.body.username, function(err, can_sign_up){
		if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.end();
		} else if (!can_sign_up) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'user exit'});
            res.end();
		} else if (can_sign_up) {
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

function findUser(username, callbackFunction) {
	model.User.findOne({username:username}, function(err, user){
		if (err) {
			callbackFunction(err, false);
		} else if (user) {
			callbackFunction(null, false);
		} else if (!user) {
			callbackFunction(null, true);
		};
	});
}