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
		id_foursquare		: String
		, title				: String
		, lat 				: Number
		, lng 				: Number
		, distance			: Number
		, type 				: String 		//suggested,additional
		, last_modified		: Date
		, created_at		: Date
		, is_subscribed		: Boolean
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
		, user 				: { type: Schema.Types.ObjectId, ref: 'User' }
		, report 			: { type: Schema.Types.ObjectId, ref: 'Report'}
		, last_modified		: Date
		, created_at		: Date
	});

	var IminSchema = new Schema({
		user 				: { type: Schema.Types.ObjectId, ref: 'User' }
		, report 			: { type: Schema.Types.ObjectId, ref: 'Report' }
		, last_modified		: Date
		, created_at		: Date
	});

	var ReportSchema = new Schema({
		title				: String
		, lat				: Number
		, lng				: Number
		, note				: String
		, full_image		: String
		, thumbnail_image	: String
		, is_resolved		: Boolean
		, categories		: [{ type: Schema.Types.ObjectId, ref: 'Category' }]
		, user				: { type: Schema.Types.ObjectId, ref: 'User' }
		, place				: { type: Schema.Types.ObjectId, ref: 'Place' }
		, imin_count		: Number
		, comments 			: [{ type: Schema.Types.ObjectId, ref: 'Comment' }]
		, imins 			: [{ type: Schema.Types.ObjectId, ref: 'Imin' }]
		, last_modified		: Date
		, created_at		: Date
	});

	var SubscriptionSchema = new Schema({
		place 				: { type: Schema.Types.ObjectId, ref: 'Place' }
		, user 				: { type: Schema.Types.ObjectId, ref: 'User' }
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


