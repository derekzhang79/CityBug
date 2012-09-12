var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

var user = {
  username: 'The Reddest',
  email: 'brandon@switchonthecode.com',
  firstName: 'Brandon',
  lastName: 'Cannaday'
};

var userString = JSON.stringify(user);

var headers = {
  'Content-Type': 'application/json',
  'Content-Length': userString.length
};

var options = {
  host: 'http://localhost',
  port: 3003,
  method: 'POST',
  headers: headers
};

exports.entries = function(req, res){
    console.log('API page');

    entryModel.find({},function(err, docs){
        console.log(docs);
    });

	var responseString = '';

	res.on('data', function(data) {
		responseString += data;
	});

	res.on('end', function() {
		var resultObject = JSON.parse(responseString);
	});


    // res.writeHeader(200, {"Content-Type": "text/plain"});  
    // res.write('helloooo');

    res.write(userString);
    res.end();

};