//!Mongo scipt
load('mockupData.js');

// Categories
for (i in catItems) { c = {title:catItems[i],last_modified:nowDate, created_at:nowDate}; db.categories.save(c);};
// Places
for (i in places) { db.places.save(places[i]) };
// Users
for (i in users) { db.users.save(users[i]) };
// Subscriptions
var adminUser = db.users.findOne({username: 'admin'});
var allPlaces = db.places.find();
var allCat = db.categories.find();
for (i in places) {
    var sub1 = {place:allPlaces[i]._id, user:adminUser._id, created_at:nowDate, last_modified:nowDate};
    db.subscriptions.save(sub1);
}

// for (i in reports) {
//     var report = {
//     	created_at:reports[i].created_at,
//     	last_modified:reports[i].last_modified,
//     	imin_count:reports[i].imin_count,
//     	is_resolved:reports[i].is_resolved,
//     	lat:allPlaces[i].lat,
//     	lng:allPlaces[i].lng,
//     	note:reports[i].note,
//     	place:allPlaces[i]._id,
//     	title:reports[i].title,
//     	categories:[allCat[i]._id],
//     	user:adminUser._id,
//     	imins:[],
//     	comments:[]
//     };
//     db.reports.save(report);
// }

// var allReport = db.reports.find();

// for(i in comments) {
// 	var comment = {
// 		text:comments[i].text,
// 		last_modified:comments[i].last_modified,
// 		created_at:comments[i].created_at,
// 		user:adminUser._id,
// 		report:allReport[i%2]._id
// 	}
//     db.comments.save(comment);
//     var last_comment = db.comments.findOne({text:comments[i].text});
//     db.reports.update({_id: allReport[i%2]._id}, { $set : { comments : [last_comment._id] } });

// }
