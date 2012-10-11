var environment;
var mongoose = require('mongoose'),
	salt = 'cityBugOpendream',
	SHA2 = new (require('jshashes').SHA512)();

module.exports.encodePassword = function(pass){
	if( typeof pass === 'string' && pass.length < 3 ) 
		return '';
	return SHA2.b64_hmac(pass, salt);
};

module.exports.init = function(env, mongoose) {
    environment = env;
    mongoose = mongoose;
};

module.exports.useModel = function (modelName) {
    var checkConnectionExists = (mongoose.connection.readyState === 1 || mongoose.connection.readyState === 2);
    if(!checkConnectionExists)
        mongoose.connect(environment.db.URL);
    return require("./models/" + modelName)(mongoose);
};

module.exports.useModule = function (moduleName) {
    return require("./modules/" + moduleName);
};

module.exports.distanceCalculate = function (lat1, lon1, lat2, lon2) {
	var radlat1 = Math.PI * lat1/180;
	var radlat2 = Math.PI * lat2/180;
	var radlon1 = Math.PI * lon1/180;
	var radlon2 = Math.PI * lon2/180;
	var theta = lon1-lon2;
	var radtheta = Math.PI * theta/180;
	var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
	dist = Math.acos(dist);
	dist = dist * 180/Math.PI;
	dist = dist * 60 * 1.1515;
	dist = dist * 1.609344;  //kilometre

	//console.log("distance from "+lat1 +" "+ lon1+" "+ lat2 +" "+ lon2 + " = " + dist + "km");
	return dist;
};