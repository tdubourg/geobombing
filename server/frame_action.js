"use strict"

var net = require('./network');
var utils = require("./common");


var db = require('./pgsql');
var nb_instance_move = 0;

var g = require('./Game')
//var single_game_instance/*: g.Game */ = null
var gs = require('./game_server')
var single_game_server = null


// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	var lat = 0;
	var lon = 0;

	if (frame_data != null && frame_data.latitude != null) 
		lat = parseFloat(frame_data.latitude);
	if (frame_data != null && frame_data.longitude != null) 
		lon = parseFloat(frame_data.longitude);
	
	function sendMap(jsonMap)
	{	
		var conId = single_game_server.addPlayer(stream).conId
		//var jsonMap = db.mapDataToJSon(mapData)
		var content =  
		{
			"type": net.TYPEMAP, 
			"id": conId, // kesako?!
			"data": jsonMap
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + net.FRAME_SEPARATOR, function () {console.log(conId)})
	}
	
	function setInitialPosition()
	{
		var position = db.getInitialPosition(); // FIXME calcul de position initiale par la base de données
		single_game_server.setInitialPosition(stream, position)
	}
	
	if (single_game_server == null) db.fullMapAccordingToLocation(lat, lon, 
		function (mapData, position)
		{
			single_game_server = new gs.GameServer(
				new g.Game(new g.Map(db.mapDataToJSon(mapData))))

			sendMap(single_game_server.game.map.jsonObj);
			setInitialPosition();
		}); // lat, lon
		else
		{
			sendMap(single_game_server.game.map.jsonObj);
			setInitialPosition();
		}
} // end send map


// --- updates ---


var sendPlayerPosition = function (stream, id, pos) // player and other players
{
	// IDs are string on client side
	pos.n1 = pos.n1.toString()
	pos.n2 = pos.n2.toString()
	
	var content = 
	{
		"type": net.TYPEPLAYERUPDATE, 
		"id": id,
		"data": pos
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {})
}
exports.sendPlayerPosition = sendPlayerPosition

var sendPlayerUpdate = function (stream, id, data) // player and other players
{	
	var content = 
	{
		"type": net.TYPEPLAYERUPDATE, 
		"id": id,
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {console.log("player update:\n" + data)})
}
exports.sendPlayerUpdate = sendPlayerUpdate

// receiving function 
var move_action = function (frame_data, stream) 
{
	//decode frame
	if (frame_data != null && frame_data.end_edge_pos != null
		&& frame_data.nodes != null && frame_data.nodes.length > 0) // minimum of two nodes for moving
	{
		var endedge = parseFloat(frame_data.end_edge_pos);	
		single_game_server.moveCommand(stream, endedge, frame_data.nodes) // send new position
	}
	else console.log("Error move msg from client.")
}

var bomb_action = function (frame_data, stream) 
{
	console.log("bomb_action:\n" + frame_data);
	if (frame_data != null && frame_data.id != null)
	{
		var id = frame_data.id;
		var pos = CreatePosition(0, 0, 0)
		single_game_server.bombCommand(stream, id, pos) // send bomb
	}
	else console.log("Error bomb msg from client.")
}


// --- end updates ---


var frame_actions = 
{
	//Type from client
	"gps":  sendmap_action, // reponse function to localise

	// answer type update
	"move": move_action,
	"bomb": bomb_action
}
exports.frame_actions = frame_actions
