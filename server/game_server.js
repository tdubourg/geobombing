"use strict"

var g = require('./Game')
var fa = require('./frame_action')
var net = require('./network')


exports.GameServer = GameServer
exports.Connexion = Connexion


// in milliseconds:
var GAME_REFRESH_PERIOD = 50
var MOVE_REFRESH_PERIOD = 50

function streamKey(stream) {
	//console.log(stream)
	/*
	var a = stream.address()
	return a.address+":"+a.port
	*/
	return stream.id
}

function Connexion(gserver, stream, player) {
	var that = this
	
	console.log("Connecting player "+player.name)//+", key "+)
	
	if (!stream)
	{
		console.log("Error: stream is null, cannot connect")
		return null
	}
	
	this.stream = stream
	this.player = player
	
	// Unique randomized id gen for security
	var cons = gserver.connexions
	do {
		this.conKey = Math.random().toString().substring(2);
	} while (!Object.keys(cons).reduce (
		function(prev,currKey) {
			return prev && cons[currKey].conKey != that.conKey
		}, true)
	)
	stream.id = this.conKey
	console.log("Generated key for "+player.name+":", this.conKey)
	
	gserver.connexions[streamKey(stream)] = this
	
	//gserver.playersByStream[stream] = player
	
	function disco()
	{
		console.log("Disconnecting player "+player.name)
		delete gserver.connexions[streamKey(stream)]
	}
	
	stream.addListener("end", disco)
	stream.addListener("error", function(err) {
		disco()
	})
	
	//gserver.connexions.push(this)
}

function GameServer(game) {
	var that = this
	
	this.game = game
	this.connexions = {}
	
	var lastTime = Date.now()
	
	setInterval(function() {
		var time = Date.now()
		game.update((time-lastTime)/1000)
		lastTime = time
	}, GAME_REFRESH_PERIOD)
	
	// Player network updates
	setInterval(function() {
		
		for (var conKey in that.connexions) 
		{
			var con = that.connexions[conKey]
			game.players.forEach(function (player) 
			{
				fa.sendPlayerUpdate(con.stream, player);
			})
		}
		
	}, MOVE_REFRESH_PERIOD)
	
}

GameServer.prototype.addPlayer = function(stream) {
	// TODO handle timeouts
	
	var c = new Connexion(this, stream, new g.Player(this.game, stream))
	
	return c
}
GameServer.prototype.getPlayer = function(stream) {
	//return gserver.connexions.indexOf(con).player
	return this.connexions[streamKey(stream)].player
}

GameServer.prototype.moveCommand = function(stream, conKey, endCoeff, nodes) {
	
	console.log("Move com from", this.getPlayer(stream).name)//this.playersByStream[stream].name)
	
	this.getPlayer(stream).move(nodes, endCoeff)
	
}

GameServer.prototype.bombCommand = function(stream, key) { // FIXME key?
	this.getPlayer(stream).bomb()
}

GameServer.prototype.setInitialPosition = function(stream, position) {
	this.getPlayer(stream).setPosition(position)
}


