/*!
* Demo registration application
* Copyright(c) 2011 Jean-Tiare LE BIGOT <admin@jtlebi.fr>
* MIT Licensed
*/

// loads model file and engine
var mongoose    = require('mongoose'),
    entryModel = require('../models/entry');

// Open DB connection
mongoose.connect('mongodb://localhost/entry');

// Home page => registration form
exports.index = function(req, res){
    entryModel.find({},function(err, docs){
        res.render('index.jade', { title: 'City bug', entry: docs });
    });
};
