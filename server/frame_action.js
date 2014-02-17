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
var nb_instance_move = 0;


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
		stream.write(data + FRAME_SEPARATOR, function () {console.log("MapData sent:\n" + data)})
	}); // lat, lon
}


var move_action = function (frame_data, stream) 
{
	console.log("move_action:\n" + frame_data);
	nb_instance_move++; // to stop previous moving

	//decode frame
	var pos;
	if (frame_data != null && frame_data.start_edge_pos != null && frame_data.end_edge_pos != null
		&& frame_data.nodes != null && frame_data.nodes.length > 0) 
		{
			var startedge = parseFloat(frame_data.start_edge_pos);
			var endedge = parseFloat(frame_data.end_edge_pos);

			// send answer
			setTimeout(function(){multiple_send_position(stream, startedge, endedge, frame_data.nodes)}, 1000); // execute the function every 1000ms
		}
}
var multiple_send_position = function (stream, startedge, endedge, idnodes) 
{
    // calculate position
    if (idnodes.length == 2 && startedge >= endedge) startedge = endedge; // add stop send
	else if (startedge < 1) startedge += 0.2;
	else if (startedge >= 1)
	{
		startedge = 0;
		if (idnodes.length > 2) idnodes.shift();
	}

    var position = utils.CreatePosition(idnodes[0], idnodes[1], startedge);
	var content = 
	{
		"type": TYPEPOS, 
		"data": position
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("PosData sent:\n" + data)})
	if (nb_instance_move < 2) {setTimeout(function(){multiple_send_position(stream, startedge, endedge, idnodes)}, 1000);}
	else nb_instance_move--;
        
}
var calculate_position= function (startedge, endedge, idnodes)
{
	if (idnodes.length == 2 && startedge >= endedge) startedge = endedge;
	else if (startedge < 1) startedge += 0.2;
	else if (startedge >= 1)
	{
		startedge = 0;
		if (idnodes.length > 2) idnodes.shift();
	}

    var pos = utils.CreatePosition(idnodes[0], idnodes[1], startedge);
	return pos;
}

var bomb_action = function (frame_data, stream) 
{
	console.log("bomb_action:\n" + frame_data);
	var pos = CreatePosition(0, 0, 0)
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
	"bomb": bomb_action
}
exports.frame_actions = frame_actions