"use strict"

var net = require('./network');
var utils = require("./common");
var db = require('./pgsql');

var nb_instance_move = 0;
var g = require('./game')
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
		var player = single_game_server.addPlayer(stream)
		var data = {}
		data[net.TYPEID] = player.id // id
		data[net.TYPENAME] = player.name // id
		data[net.TYPEKEY] = player.connexion.conKey // key
		data[net.TYPEMAP] = jsonMap // map
		if (tiles != null) data[net.TYPETILES] = tiles // maptiles
		var content =  
		{
			"type": net.TYPEPLAYERINIT, 
			"data": data
		}
		
		var data = JSON.stringify(content); // parsage JSON
		stream.write(data + net.FRAME_SEPARATOR, function () 
		{
			//console.log("sendInit(data): ", data)
			console.log("sendInit(nb tiles?): ", tiles? tiles.grid.length:"no_tiles")
		})
	}
	
	function setInitialPosition()
	{
		// var position = db.getInitialPosition(); // FIXME calcul de position initiale par la base de données
		var position = single_game_server.game.getRandomPosition()
		single_game_server.setInitialPosition(stream, position)
		
		////////
		// FIXME: debug add monsters
		// single_game_server.addMonster(single_game_server.game.getRandomPosition())
		////////
	}
	
	if (single_game_server == null)
		db.fullMapAccordingToLocation(lat, lon, function (mapData, tiles)
		{
			single_game_server = new gs.GameServer(
				new g.Game(new g.Map(db.mapDataToJSon(mapData))), tiles)
			
			sendInit(single_game_server.game.map.jsonObj,  tiles);
			setInitialPosition();
		}); // lat, lon
	else
	{
		sendInit(single_game_server.game.map.jsonObj, single_game_server.tiles);
		setInitialPosition();
	}
} // end sendInit_action


function sendEnd(stream, players)
{
	var data = {}
	data[net.TYPERANKING] = {}
	players.forEach(function (player) 
	{
		data[net.TYPERANKING][player.name] = {}
		data[net.TYPERANKING][player.name][net.TYPEID] = player.id
		data[net.TYPERANKING][player.name][net.TYPEPLAYERDEADS] = player.deads
		data[net.TYPERANKING][player.name][net.TYPEPLAYERKILLS] = player.kills
		data[net.TYPERANKING][player.name][net.TYPEPLAYERPOINTS] = player.points
	}) 

	var content =  
	{
		"type": net.TYPEGAMEEND, 
		"data": data
	}
	
	var data = JSON.stringify(content); // parsage JSON
	stream.write(data + net.FRAME_SEPARATOR, function () { console.log(data) })
}



// --- updates ---

var sendMonstersUpdate = function (stream, monsters) // all monsters
{
	var data = {}
	data[net.TYPETIMESTAMP] = Date.now() // for discard monsterUpdatePosition 
	var all_monsters = []
	monsters.forEach(function (monster) 
	{
		var current_monster = {}
		current_monster[net.TYPEPOS] = monster.getPosition() 
		current_monster[net.TYPEID] = monster.id
		if (monster.dead) { current_monster[net.TYPEDEAD] = monster.dead }

		all_monsters[all_monsters.length] = current_monster
	})

	data[net.TYPEMONSTERS] = all_monsters
	var content = 
	{
		"type": net.TYPEMONSTERSUPDATE,
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR, function() {
		//console.log("sendMonstersUpdate: ", data)
	})
}

var sendPlayersUpdate = function (stream, players) // player and other players
{
	var data = {}
	data[net.TYPETIMESTAMP] = Date.now() // for discard playerUpdatePosition
	data[net.TYPETIMEREMAINING] = gs.session_time_remaining // time before end of game 

	var all_players = []
	var haskilled = 0
	players.forEach(function (player) 
	{
		if (player.haskilled) haskilled = player.kills
		var current_player = {}
		current_player[net.TYPEPOS] = player.getPosition() 
		current_player[net.TYPEID] = player.id
		current_player[net.TYPEKILLS] = player.kills
		if (player.dead) { current_player[net.TYPEDEAD] = player.dead }

		all_players[all_players.length] = current_player
	})

	data[net.TYPEPLAYERS] = all_players
	var content = 
	{
		"type": net.TYPEPLAYERSUPDATE,
		"data": data
	};
	
	var data = JSON.stringify(content);
	stream.write(data + net.FRAME_SEPARATOR, function() {
		// console.log("sent update: ", data)
		if (haskilled != 0) console.log("sendPlayersUpdate killed: ", haskilled)
	})
}

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

var sendBombUpdate = function (stream, bomb) // player and other players
{
	if (bomb == null)
	{
		console.log("Error: Unknown Bomb")
		return
	}
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
		console.log("radius: ", content.data[net.TYPERADIUS])
	})
}


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


exports.sendEnd = sendEnd
exports.sendPlayersUpdate = sendPlayersUpdate
exports.sendMonstersUpdate = sendMonstersUpdate
exports.sendPlayerRemove = sendPlayerRemove
exports.sendBombUpdate = sendBombUpdate
exports.frame_actions = frame_actions
