"use strict"

var netw = require('./network');
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
var TYPEMAP = "map";
var TYPEGPS = "gps";
var db = require('./pgsql');

// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	console.log("sendmap_action");
	db.fullMapAccordingToLocation(0, 0, function (map) 
	{
		var content = 
		{
			"type": TYPEMAP, 
			"data": map
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {console.log("Data sent:\n" + data)})
	}); // lat, lon
}

var sendInit_location = function (frame_data, stream) {}


var frame_actions = 
{
	"map": sendmap_action,
	"loc": sendInit_location
}

exports.frame_actions = frame_actions