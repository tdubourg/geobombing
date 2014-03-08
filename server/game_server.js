"use strict"

var g = require('./game')
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
	return a.address+":" + a.port
	*/
	return stream.id
}

var usedConKeys = []

function Connexion(gserver, stream, player) {
	var that = this
	
	console.log("Connecting player " + player.name)//+", key "+)
	
	if (!stream)
	{
		console.log("Error: stream is null, cannot connect")
		return null
	}
	
	this.open = false
	this.stream = stream
	this.player = player
	player.connexion = this
	
	// Unique randomized id gen for security
	var cons = gserver.connexions
	do {
		this.conKey = Math.random().toString().substring(2);
	//} while (!Object.keys(cons).reduce (
	} while (!usedConKeys.reduce (
		function(prev,currKey) {
			//return prev && cons[currKey].conKey != that.conKey
			return prev && currKey != that.conKey
		}, true)
	)
	stream.id = this.conKey
	console.log("Generated key for " + player.name + ":", this.conKey)
	
	gserver.connexions[streamKey(stream)/*==this.conKey*/] = this
	usedConKeys.push(this.conKey)
	
	//gserver.playersByStream[stream] = player
	
	function disco()
	{
		if (that.open) {
			console.log("Disconnecting player "+player.name)
			that.open = false
			delete gserver.connexions[streamKey(stream)]
			player.remove()
			gserver.notify(function(stream) {
				fa.sendPlayerRemove(stream, player)
			})
		} else {
			console.log("Player "+player.name+" is already disconnected")
		}
	}
	
	stream.addListener("end", disco)
	stream.addListener("error", function(err) {
		disco()
	})
	
	this.open = true
	
	//gserver.connexions.push(this)
}

function GameServer(game) {
	var that = this
	
	this.game = game
	this.connexions = {}
	
	var lastTime = Date.now()
	
	setInterval(function() {
		var time = Date.now()
		var explodingBombs = []
		game.update((time-lastTime)/1000, explodingBombs)
		
		explodingBombs.forEach(function (bomb) 
		{
			that.notifyBomb(bomb);
		})
		
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

	setTimeout(function() // durée session //todo delete after sprint2
	{
		console.log("fin de la partie")
		for (var conKey in that.connexions) 
		{
			var con = that.connexions[conKey]
			game.players.forEach(function (player) 
			{
				fa.sendEnd(con.stream, null)
			})
		}
		
	}, 20000); // after 20s
	
}

GameServer.prototype.notify = function(fct) {
	for (var conKey in this.connexions) 
	{
		fct(this.connexions[conKey].stream)
	}
}

GameServer.prototype.notifyBomb = function(bomb) {
	//game.bombs.forEach(function (bomb)
	for (var conKey in this.connexions) 
	{
		var con = this.connexions[conKey]
		fa.sendBombUpdate(con.stream, bomb);
	}
	//console.log("Bomb:", bomb)
}

GameServer.prototype.addPlayer = function(stream) {
	// TODO handle timeouts
	
	var p = new g.Player(this.game, stream)
	
	var c = new Connexion(this, stream, p)
	
	return p
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
	var b = this.getPlayer(stream).bomb()
	this.notifyBomb(b)
}

GameServer.prototype.quitCommand = function(stream, key) { // not used atm
	//this.getPlayer(stream).quit() // todo complete, Lionel!
}

GameServer.prototype.setInitialPosition = function(stream, position) {
	this.getPlayer(stream).setPosition(position)
}


