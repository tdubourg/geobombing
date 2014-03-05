"use strict"

var net = require('./network');
var utils = require("./common");

var db = require('./pgsql');
var nb_instance_move = 0;

var g = require('./game')
//var single_game_instance/*: g.Game */ = null
var gs = require('./game_server')
var single_game_server = null

exports.getServer = function() { return single_game_server }

// executed function according to client result
var sendInit_action = function (frame_data, stream) 
{
	var lat = parseFloat(frame_data.latitude);
	var lon = parseFloat(frame_data.longitude);
	
	function sendInit(jsonMap, tiles)
	{
		//var conKey = single_game_server.addPlayer(stream).conKey
		var player = single_game_server.addPlayer(stream)
		var data = {}
		data[net.TYPEID] = player.id // id
		data[net.TYPEKEY] = player.connexion.conKey // key
		data[net.TYPEMAP] = jsonMap // map
		data[net.TYPETILES] = tiles // map
		var content =  
		{
			"type": net.TYPEPLAYERINIT, 
			"data": data
		}
		
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + net.FRAME_SEPARATOR, function () { console.log(data); console.log(tiles) })
	}
	
	function setInitialPosition()
	{
		var position = db.getInitialPosition(); // FIXME calcul de position initiale par la base de données
		single_game_server.setInitialPosition(stream, position)
	}
	
	if (single_game_server == null) db.fullMapAccordingToLocation(lat, lon, 
		function (mapData, position, tiles)
		{
			single_game_server = new gs.GameServer(
				new g.Game(new g.Map(db.mapDataToJSon(mapData))))

			sendInit(single_game_server.game.map.jsonObj, tiles);
			setInitialPosition();
		}); // lat, lon
		else
		{
			sendInit(single_game_server.game.map.jsonObj);
			setInitialPosition();
		}
} // end sendInit_action


function sendEnd(stream, game)
{
	var data = {}
	data[net.TYPERANKING] = {"jo":100, "lili":0} // palmares
	var content =  
	{
		"type": net.TYPEGAMEEND, 
		"data": data
	}
	
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + net.FRAME_SEPARATOR, function () { console.log(data) })
}
exports.sendEnd = sendEnd


// --- updates ---

var sendPlayerUpdate = function (stream, player) // player and other players
{
	var data = {}
	data[net.TYPEPOS] = player.getPosition() 
	data[net.TYPEID] = player.id
	if (player.dead)
	{ 
		data[net.TYPEDEAD] = player.dead
	}
	var content = 
	{
		"type": net.TYPEPLAYERUPDATE,
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {
		//console.log("Send updt", stream.address().address)
	})
}
exports.sendPlayerUpdate = sendPlayerUpdate

var sendPlayerRemove = function (stream, player) // player and other players
{	
	var data = {}
	data[net.TYPEID] = player.id
	var content = 
	{
		"type": net.TYPEGONE, 
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {console.log("Bomb update sent")})
}
exports.sendPlayerRemove = sendPlayerRemove

var sendBombUpdate = function (stream, bomb) // player and other players
{
	var data = {}
	data[net.TYPEID] = bomb.player.id // player id
	data[net.TYPEPOS] = bomb.getPosition()
	data[net.TYPEBOMBID] = bomb.id
	data[net.TYPEBOMBSTATE] = bomb.time<0?1:0 // time since explosion (>0: exploding)
	data[net.TYPERADIUS] = bomb.power // area touched
	data[net.TYPEBOMBTYPE] = 1 // strength or type of bomb
	var content =
	{
		"type": net.TYPEBOMBUPDATE, 
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR,function() {
		//console.log("Bomb update sent ("+(bomb.time<0?1:0)+")")
		//console.log(bomb.arc.toString(), bomb.arcDist)
	})
}
exports.sendBombUpdate = sendBombUpdate


// --- receiving function ---

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

var quit_action = function (frame_data, stream) // not used atm
{
	console.log("quit_action:\n" + frame_data);
	var key = frame_data.key;
	single_game_server.quitCommand(stream, key) // remove player from game
}


// --- end updates ---


//Types received from client
var frame_actions = 
{	
	"gps":  sendInit_action, 

	// answer type update
	"move": move_action,
	"bomb": bomb_action,
	"quit": quit_action
}
exports.frame_actions = frame_actions
