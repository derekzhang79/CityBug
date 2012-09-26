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
for (i in places) {
    var sub1 = {place:allPlaces[i]._id, user:adminUser._id, created_at:nowDate, last_modified:nowDate};
    db.subscriptions.save(sub1);
}