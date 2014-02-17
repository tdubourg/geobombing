"use strict"

var netw = require('./network');
var utils = require("./common");
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;

// Type from server
var TYPEMAP = "map";
var TYPEPOS = "pos"; // current player position
var TYPEPLAYERPOS = "ppos"; // other players pos
var TYPEBOMB = "bomb";
var TYPEPLAYERBOMB = "pbomb"

var db = require('./pgsql');
var now = new Date();


// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	var lat = 0;
	var lon = 0;

	if (frame_data != null && frame_data.latitude != null) lat = parseFloat(frame_data.latitude);
	if (frame_data != null && frame_data.longitude != null) lon = parseFloat(frame_data.longitude);
	console.log("sendmap_action:\nlat=" + lat + "\nlon=" + lon);
	db.fullMapAccordingToLocation(lat, lon, function (map) 
	{
		var content = 
		{
			"type": TYPEMAP, 
			"data": map
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {console.log("MapData sent")})
	}); // lat, lon
}

var test_action = function (frame_data, stream) 
{
	console.log("test_action:\n" + frame_data);
}

var move_action = function (frame_data, stream) 
{
	console.log("move_action:\n" + frame_data);
	var pos = utils.CreatePosition(0, 0, -1)
	var content = 
	{
		"type": TYPEPOS, 
		"data": pos
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("PosData sent:\n" + data)})
}

var bomb_action = function (frame_data, stream) 
{
	console.log("bomb_action:\n" + frame_data);
	var pos = CreatePosition(0, 0, -1)
	var content = 
	{
		"type": TYPEBOMB, 
		"data": pos
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("BombData sent:\n" + data)})
}


var frame_actions = 
{
	//Type from client
	"gps":  sendmap_action, // reponse function to localise
	"move": move_action,
	"bomb": bomb_action,
	"test": test_action
}
exports.frame_actions = frame_actions