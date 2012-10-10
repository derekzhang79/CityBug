var service = require('../service'),
    model =  service.useModel('model');

exports.imin_post = function(req, res) {
	var user = req.user;
    var url = req.url;
    var report_id = url.match( /[^\/]+\/?$/ );

	console.log('add imin at report_id ' + report_id +' wirh user id ' + user._id);

	var imin = new model.Imin();
	imin.user = user._id;
	imin.report = report_id;
	imin.created_at = new Date();
	imin.last_modified = new Date();

	model.Report.findOne({_id:report_id})
        .populate('imins')
        .exec(function(err, report) {

        if (containUser(report.imins, user._id)) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'imin existed'});
            res.end();
            console.log('user existed');
        	return;
        }

		report.imin_count = report.imin_count + 1;
		report.imins.push(imin._id);
		report.save(function(err) {
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
	});
}

exports.imin_delete = function(req, res) {
	
	var user = req.user;
    var url = req.url;
    var report_id = url.match( /[^\/]+\/?$/ );

	console.log('delete imin at report_id' + report_id);

	model.Imin.findOne({report:report_id, user:user._id},function(err, imin) {
		if (err) {
			console.log(err);
			res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.end();
			return;
		}
		console.log('report ' + report_id + ' userid ' + user._id);
		if (imin == null) {
			res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.end();
			return;
		}

		model.Report.findOne({_id:report_id})
	        .populate('comments')
	        .populate('imins')
	        .exec(function(err, report) {
			if (err) {
				console.log(err);
				res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
				res.end();
				return;
			};

			if (containUser(report.comments, user._id)) {
	            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'imin existed'});
	            res.end();
	            console.log('user existed');
	        	return;
        	}

			report.imins = removeUserInArrayByUserId(report.imins, user._id);
			report.imin_count = report.imins.length;
	        if (err) {
				console.log(err);
				res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
				res.end();
				return;
			}

			report.save(function(err) {
				if (err) {
					console.log(err);
					res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
					res.end();
				} else {
					
					imin.remove(function(err) {

						if (err) {
							console.log(err);
							res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
							res.end();
						} else {
							console.log('delete imin');
							res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'imin delete'});
							res.end();
						}
					});					
				}
			});
		});
	});
}

exports.imin_list = function(req, res) {
    var url = req.url;
    var report_id = url.match( /[^\/]+\/?$/ );
    console.log('imin user list with report id ' + report_id);
    model.Imin.find({report:report_id})
	    .populate('user','username email thumbnail_image')
	    .exec(function(err, imins) {

	    if (err) {
			console.log('error ' + err);
			res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
			res.end();
	    }

		imins = imins.sort(function(a, b) {
			return new Date(b.last_modified).getTime() - new Date(a.last_modified).getTime();
		});

	    var user = [];
	    for (i in imins) {
	    	user.push(imins[i].user);
	    }

		res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
		res.write('{ "user":' + JSON.stringify(user) + '}');
		res.end();
    });
}

function containUser(arr, obj) {
    for(var i = 0; i < arr.length; i++) {
        if (arr[i].user.equals(obj)) return true;
    }
    return false;
}

function removeUserInArrayByUserId(arr, obj) {
	for(var i = 0; i < arr.length; i++ ) { 
		if (arr[i].user.equals(obj))
			arr.splice(i, 1); 
	}
	console.log('array ' + arr);
	return arr;
}


