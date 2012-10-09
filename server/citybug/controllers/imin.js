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

        if (include(report.imins, user._id)) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'imin existed'});
            res.end();
            console.log('user existed');
        	return;
        }

		report.imin_count = report.imin_count + 1;
		report.imins.push(imin._id);
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
	});
}

exports.imin_delete = function(req, res) {
	
	var user = req.user;
    var url = req.url;
    var report_id = url.match( /[^\/]+\/?$/ );

	console.log('delete imin at report_id' + report_id);

	model.Imin.findOne({_id:imin._id},function(err, imin) {

		model.Report.findOne({_id:report_id}, function(err, report) {
			if (err) {
				console.log(err);
				res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
				res.end();
				return;
			};

			report.imin_count = report.imin_count - 1;

			report.update({ _id: report_id }, { $pull: { imin: imin._id }}, function(err) {

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
	});
}

function include(arr, obj) {
    for(var i = 0; i < arr.length; i++) {
        if (arr[i].user.equals(obj)) return true;
    }
    return false;
}

