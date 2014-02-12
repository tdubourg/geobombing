"use strict"

var netw = require('./network');
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
var TYPEMAP = "map";
var TYPEGPS = "gps";
var db = require('./pgsql');

// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	var lat = 0;
	var lon = 0;
	console.log("sendmap_action:\n", frame_data.latitude);
	if (frame_data != null && frame_data.latitude != null) lat = frame_data.latitude;
	if (frame_data != null && frame_data.longitude != null) lon = frame_data.longitude;
	console.log("sendmap_action:\nlat=" + lat + "\nlon=" + lon);
	db.fullMapAccordingToLocation(lat, lon, function (map) 
	{
		var content = 
		{
			"type": TYPEMAP, 
			"data": map
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {console.log("Data sent")})
	}); // lat, lon
}

var test_action = function (frame_data, stream) {console.log("test_action");}


var frame_actions = 
{
	"gps": sendmap_action, // reponse function to localise
	"test": test_action
}

exports.frame_actions = frame_actions