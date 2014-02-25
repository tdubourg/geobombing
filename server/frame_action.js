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
var sendInit_action = function (frame_data, stream) 
{
	var lat = parseFloat(frame_data.latitude);
	var lon = parseFloat(frame_data.longitude);
	
	function sendInit(jsonMap)
	{
		var conKey = single_game_server.addPlayer(stream).conKey
		var id = 0
		var data = {}
		data["id"] = id // id
		data["key"] = conKey // key
		data[net.TYPEMAP] = jsonMap // map
		var content =  
		{
			"type": net.TYPEPLAYERINIT, 
			"data": data
		}
		
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + net.FRAME_SEPARATOR, function () { console.log(data) })
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

			sendInit(single_game_server.game.map.jsonObj);
			setInitialPosition();
		}); // lat, lon
		else
		{
			sendInit(single_game_server.game.map.jsonObj);
			setInitialPosition();
		}
} // end send map


// --- updates ---


var sendPlayerUpdate = function (stream, id, pos) // player and other players
{	
	var data = {}
	data[net.TYPEPOS] = pos 
	data["id"] = id 
	var content = 
	{
		"type": net.TYPEPLAYERUPDATE, 
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {})
}
exports.sendPlayerUpdate = sendPlayerUpdate

var sendBombUpdate = function (stream, id, data) // player and other players
{	
	var content = 
	{
		"type": net.TYPEBOMBUPDATE, 
		"id": id,
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {console.log("Bomb update sent")})
}
exports.sendBombUpdate = sendBombUpdate

// receiving function 
var move_action = function (frame_data, stream) 
{
	var endedge = parseFloat(frame_data.end_edge_pos);	
	var key = frame_data.key;
	single_game_server.moveCommand(stream, key, endedge, frame_data.nodes) // send new position
}

var bomb_action = function (frame_data, stream) 
{
	console.log("bomb_action:\n" + frame_data);
	var key = frame_data.key;
	single_game_server.bombCommand(stream, key) // send bomb
}


// --- end updates ---

//Types received from client
var frame_actions = 
{	
	"gps":  sendInit_action, 

	// answer type update
	"move": move_action,
	"bomb": bomb_action
}
exports.frame_actions = frame_actions
