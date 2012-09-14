var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var CategorySchema = new Schema({
	  id				: ObjectId
	, title				: String
});

var EntrySchema = new Schema({
	  id				: ObjectId
	, title				: String
	, thumbnail_image	: String
	, full_image		: String
	, latitude			: Number
	, longitude			: Number
	, note				: String
	, categories		: String
	, last_modified		: Date
	// , categories		: [CategorySchema]

});

module.exports = mongoose.model('Category', CategorySchema);
module.exports = mongoose.model('Entry', EntrySchema);


