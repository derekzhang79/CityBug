/*!
* Demo registration application
* Copyright(c) 2011 Jean-Tiare LE BIGOT <admin@jtlebi.fr>
* MIT Licensed
*/

// loads model file and engine
var mongoose    = require('mongoose'),
    reportModel = require('../models/model');

// Open DB connection
mongoose.connect('mongodb://localhost/model');

// Home page => registration form
exports.index = function(req, res){
    reportModel.find({},function(err, docs){
        res.render('index.jade', { title: 'City bug', report: docs });
    });
};