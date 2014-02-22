"use strict"

var netw = require('./network');
var utils = require("./common");
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
//var MOVE_REFRESH_FREQUENCY = 20; // in milliseconds

// Type from server
var TYPEMAP = "map";
var TYPEPOS = "pos"; // current player position
var TYPEPLAYERPOS = "ppos"; // other players pos
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
		
		///////////////////
		var conId = single_game_server.addPlayer(stream).conId
		// TODO send id!!
		///////////////////
		
		//var jsonMap = db.mapDataToJSon(mapData)
		var content =  
		{
			"type": TYPEMAP, 
			"data": jsonMap
		};
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + FRAME_SEPARATOR, function () {console.log("MapData sent:\n" + data)})
	}
	
	function sendInitialPosition()
	{
		var position = db.getInitialPosition(); // FIXME bullshit
		single_game_server.setInitialPosition(stream, position)
		var content =
		{
			"type": TYPEPOS, 
			"data": position
		};
		var data = JSON.stringify(content); // parsage JSON
		
		/////////
		// FIXME: removing this makes the client crash
		return
		/////////
		
		stream.write(data + FRAME_SEPARATOR, function() {
			console.log("sendInitialPosition sent:\n" + data)
		})
	}
	
	if (single_game_server == null)
		db.fullMapAccordingToLocation(lat, lon, function (mapData, position)
		{
			single_game_server = new gs.GameServer(
				new g.Game(new g.Map(db.mapDataToJSon(mapData))))
			sendMap(single_game_server.game.map.jsonObj /* == mapData */)
			sendInitialPosition();
			//sendMap(mapData /* == single_game_instance.map.data */)
		}); // lat, lon
	else
	{
	 	sendMap(single_game_server.game.map.jsonObj);
	 	sendInitialPosition();
	}
	
}

var sendPlayerPosition = function (stream, pos) {
	
	// FIXME: strings for ids? seriously?
	pos.n1 = pos.n1.toString()
	pos.n2 = pos.n2.toString()
	
	var content = 
	{
		"type": TYPEPOS, 
		"data": pos
	};
	
	//console.log(pos)
	
	var data = JSON.stringify(content);
	//return
	stream.write(data + FRAME_SEPARATOR,
		function() {
			// too verbose:
			//console.log("PosData sent:\n" + data + "\n");
		})
	
}
exports.sendPlayerPosition = sendPlayerPosition


var player_state = function (frame_data, stream) 
{
	//decode frame if one
	var state = netw.clPlayer(); // A modifier par Lionel
	if (stream = null)
	{
		// todo by lionel
	}
	var content =  
	{
		"type": TYPEPLAYER, 
		"data": state
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("sendPlayerState sent:\n" + data)})
}

var move_action = function (frame_data, stream) 
{
	//decode frame
	if (frame_data != null && frame_data.start_edge_pos != null && frame_data.end_edge_pos != null
		&& frame_data.nodes != null && frame_data.nodes.length >= 2) // minimum of two nodes for moving
	{
		console.log("\nmove_action:"); // FIXME message?
		var startedge = parseFloat(frame_data.start_edge_pos);
		var endedge = parseFloat(frame_data.end_edge_pos);

		// send answer
		//multiple_send_position(stream, startedge, endedge, frame_data.nodes); // execute the function every 1000ms
		single_game_server.moveCommand(stream, startedge, endedge, frame_data.nodes)
	}
	else console.log("Error move msg from client.")
}
/*
var multiple_send_position = function (stream, startedge, endedge, idnodes) 
{
	//console.log("CC")
	
	// calculate position
	if (idnodes.length < 2 // do not send if invalid request
		|| (idnodes.length == 2 && startedge >= endedge)
	) return; // stop send when destination reached
	else
	{
		while (idnodes.length > 2 && idnodes[0] == idnodes[1]) {idnodes.shift();}
	 	if (startedge < 1) 
		{
			startedge += 0.05;
			if (startedge > 1) startedge = 1;
		}
		else if (startedge >= 1)
		{
			startedge = 0;
			if (idnodes.length > 2) idnodes.shift();
		}
	}

 	var position = utils.CreatePosition(idnodes[0], idnodes[1], startedge);
	var content = 
	{
		"type": TYPEPOS, 
		"data": position
	};
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + FRAME_SEPARATOR, function () {console.log("PosData sent:\n" + data + "\n");}) // send network

///////////////// TODO
	setTimeout(function(){console.log("STREAM>> "+stream); multiple_send_position(stream, startedge, endedge, idnodes)}, 
			20);
}
*/

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
	"player": player_state,
	"bomb": bomb_action
}
exports.frame_actions = frame_actions
