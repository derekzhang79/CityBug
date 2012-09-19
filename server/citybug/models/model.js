var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;

var CategorySchema = new Schema({
	title				: String
	, last_modified		: Date
	, created_at		: Date
});

var PlaceSchema = new Schema({
	title				: String
	, lat 				: Number
	, long 				: Number
	, last_modified		: Date
	, created_at		: Date
});

var UserSchema = new Schema({
	username			: String
	, password 			: String
	, email				: String
	, thumbnail_image	: String
	, last_modified		: Date
	, created_at		: Date
});

var CommentSchema = new Schema({
	text				: String
	, user 				: [UserSchema]
	, last_modified		: Date
	, created_at		: Date
});

var IminSchema = new Schema({
	user 				: [UserSchema]
	, last_modified		: Date
	, created_at		: Date
});

var ReportSchema = new Schema({
	title				: String
	, lat				: Number
	, long				: Number
	, note				: String
	, full_image		: String
	, thumbnail_image	: String
	, is_resolved		: Boolean
	, categories		: [CategorySchema]
	, user				: [UserSchema]
	, place				: [PlaceSchema]
	, imin_count		: Number
	, comments 			: [CommentSchema]
	, imins 			: [IminSchema]
	, last_modified		: Date
	, created_at		: Date
});

var SubscriptionSchema = new Schema({
	place 				: [PlaceSchema]
	, user 				: [UserSchema]
	, last_modified		: Date
	, created_at		: Date
});

module.exports = mongoose.model('Category', CategorySchema);
module.exports = mongoose.model('Place', PlaceSchema);
module.exports = mongoose.model('User', UserSchema);
// module.exports = mongoose.model('Comment', CommentSchema);
// module.exports = mongoose.model('Imin', IminSchema);
module.exports = mongoose.model('Report', ReportSchema);
// module.exports = mongoose.model('Subscription', SubscriptionSchema);


