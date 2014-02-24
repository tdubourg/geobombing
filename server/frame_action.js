"use strict"

var netw = require('./network');
var utils = require("./common");
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;

// Type from server
var TYPEMAP = "map";
var TYPEPOS = "pos"; // current player position
var TYPEBOMB = "bomb";
var TYPEPLAYER = "player";
var TYPEPLAYERBOMB = "pbomb"

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

	if (frame_data != null && frame_data.latitude != null) lat = parseFloat(frame_data.latitude);
	if (frame_data != null && frame_data.longitude != null) lon = parseFloat(frame_data.longitude);
	console.log("sendmap_action:\nlat=" + lat + "\nlon=" + lon);
	
	function sendMap(jsonMap)
	{	
		var conId = single_game_server.addPlayer(stream).conId
		//var jsonMap = db.mapDataToJSon(mapData)
		var content =  
		{
			"type": TYPEMAP, 
			"id": conId,
			"data": jsonMap
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {})
	}
	
	function sendInitialPosition()
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
			sendInitialPosition();
		}); // lat, lon
		else
		{
			sendMap(single_game_server.game.map.jsonObj);
			sendInitialPosition();
		}
}

var sendPlayerPosition = function (stream, pos) // player and other players
{
	// IDs are string on client side
	pos.n1 = pos.n1.toString()
	pos.n2 = pos.n2.toString()
	var id = 0;
	
	var content = 
	{
		"type": TYPEPOS, 
		"id": id,
		"data": pos
	};
	
	var data = JSON.stringify(content);
	stream.write(data + FRAME_SEPARATOR,function() {})
}
exports.sendPlayerPosition = sendPlayerPosition


var player_state = function (frame_data, stream) 
{
	//decode frame if one
	var state = netw.clPlayer(); // A modifier par Lionel
	var id = 0;
	if (stream = null)
	{
		// todo by lionel
	}
	var content =  
	{
		"type": TYPEPLAYER, 
		"id": id,
		"data": state
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("sendPlayerState sent:\n" + data)})
}

var move_action = function (frame_data, stream) 
{
	//decode frame
	if (frame_data != null && frame_data.end_edge_pos != null
		&& frame_data.nodes != null && frame_data.nodes.length > 0) // minimum of two nodes for moving
	{
		var endedge = parseFloat(frame_data.end_edge_pos);	
		single_game_server.moveCommand(stream, 0, endedge, frame_data.nodes) // send new position
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
		var content = 
		{
			"type": TYPEBOMB,
			"id": id,
			"data": pos
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {console.log("BombData sent:\n" + data)})
	}
}


var frame_actions = 
{
	//Type from client
	"gps":  sendmap_action, // reponse function to localise
	"move": move_action,
	"player": player_state,
	"bomb": bomb_action
}
exports.frame_actions = frame_actions
