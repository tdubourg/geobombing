"use strict"

var netw = require('./network');
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
var db = require('./pgsql');

// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	console.log("sendmap_action");
	var map = db.fullMapAccordingToLocalisation(0, 0); // lat, lon
	var data = JSON.stringify(map); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("Data sent:\n" + data)})
}

var sendInit_location = function (frame_data, stream) {}


var frame_actions = 
{
	"map": sendmap_action,
	"loc": sendInit_location
}

exports.frame_actions = frame_actions