module.exports = function (mongoose) {	
	var modelObject= {};
	var Schema = mongoose.Schema,
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

	modelObject.Category = mongoose.model('Category', CategorySchema);
	modelObject.Place = mongoose.model('Place', PlaceSchema);
	modelObject.User = mongoose.model('User', UserSchema);
	modelObject.Comment = mongoose.model('Comment', CommentSchema);
	modelObject.Imin = mongoose.model('Imin', IminSchema);
	modelObject.Report = mongoose.model('Report', ReportSchema);
	modelObject.Subscription = mongoose.model('Subscription', SubscriptionSchema);
	return modelObject;
};


