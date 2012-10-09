var environment = require('../environment'),
    service = require('../service'),
    passport = require('passport'),
    model =  service.useModel('model'),
    http = require('http'),
    KEYS = require('../key');

exports.subscriptions = function(req, res){

    model.Subscription.find({})
        .populate('place')
        .populate('user','username email thumbnail_image')
        .exec(function (err, docs) {
        if (err) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Cannot get subscription");
            res.end();
            return;
        } else {
            res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write('{ "subscriptions":' + JSON.stringify(docs) + '}');
            res.end();
            return;
        }
    });
    
};

//POST new subscriptions by id_foursquare of place
exports.subscription_place_post = function(req, res) {
    var currentId4sq = req.body.place_id;
    console.log(JSON.stringify(req.body));
    var currentUser = req.user;

    console.log('post new subscription from place id 4sq'+ currentId4sq);
    model.Place.findOne({id_foursquare: currentId4sq}, function(err, place) {
        //ถ้า  place ยังไม่มีใน server ต้อง add ก่อน
        if (err || place == null) {
            //Save new place
            var newPlace = new model.Place();
            newPlace.id_foursquare = req.body.place_id;       
            newPlace.title = req.body.place_title;         
            newPlace.lat = req.body.place_lat;                   
            newPlace.lng = req.body.place_lng;
            newPlace.last_modified = new Date();
            newPlace.created_at = new Date();
            // newPlace.is_subscribed = true;

            newPlace.save(function (err){
                if (err) {
                    console.log(err);
                    // do something
                } else {
                    console.log('newPlace' + newPlace);

                    //add sub ใหม่
                    var sub = new model.Subscription();
                    sub.place = newPlace;
                    sub.user = currentUser;
                    sub.created_at = new Date();
                    sub.last_modified = new Date();
                    sub.save(function (err){
                        if (err) {
                            console.log(err);
                            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                            res.end();
                            return;
                        } else {
                            console.log('saved new sub' + sub);
                            res.writeHead(200,  { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'subscribed'});
                            res.write(JSON.stringify(sub));
                            res.end();
                            return;
                        }
                    }); 
                }
            }); 
        } 
        // ถ้ามี place นั้นแล้วในserver ก็ add sub ใหม่ได้เลย
        else {
            //add sub ใหม่
            var sub = new model.Subscription();
            sub.place = place;
            sub.user = currentUser;
            sub.created_at = new Date();
            sub.last_modified = new Date();
            sub.save(function (err){
                if (err) {
                    console.log(err);
                    res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                    res.end();
                    return;
                } else {
                    console.log('saved new sub' + sub);
                    res.writeHead(200,  { 'Content-Type' : 'application/json;charset=utf-8', 'Text' : 'subscribed'});
                    res.write(JSON.stringify(sub));
                    res.end();
                    return;
                }
            }); 
        }

    });
}

//delete subscriptions by place
exports.subscription_place_delete = function(req, res) {

}

exports.subscriptions_username = function(req, res) {
    var currentUsername = req.url.match( /[^\/]+\/?$/ );
    console.log("get subscribed place of current Username =>>> "+ currentUsername);

    // Find user by username
    model.User.findOne({username: currentUsername}, function(errUser, currentUser){
        if (errUser || currentUser == null) {
            res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
            res.write("Cannot get subscription of username "+ currentUsername);
            res.end();
            return;
        }
        // Find all subscriptions of user
        model.Subscription.find({user: currentUser._id})
        .populate('place')
        .exec(function (err, subs) {
            if (err) {
                res.writeHead(500, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write("Cannot get subscription of username "+ currentUsername);
                res.end();
                return;
            } else {
                var placeArray = [];
                //Get all places
                for (i in subs) {
                    placeArray.push(subs[i].place);
                }
                //Sort by title's alphabet
                placeArray = placeArray.sort(function(a, b) { 
                    a.is_subscribed = true;
                    b.is_subscribed = true;
                    var ret = 0;
                    var aCompare = a.title.toLowerCase();
                    var bCompare = b.title.toLowerCase();
                    if(aCompare > bCompare) 
                        ret = 1;
                    if(aCompare < bCompare) 
                        ret = -1; 
                    return ret;
                });

                res.writeHead(200, { 'Content-Type' : 'application/json;charset=utf-8'});
                res.write('{ "places":' + JSON.stringify(placeArray) + '}');
                res.end();
                return;
            }
        });
    });
    
};
