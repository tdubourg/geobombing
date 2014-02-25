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
	var a = stream.address()
	return a.address+":"+a.port
}

function Connexion(gserver, stream, player) {
	var that = this
	
	console.log("Connecting player "+player.name)
	
	this.stream = stream
	this.player = player
	
	//console.log(streamKey(stream))
	
	// TODO: this seems useless since stream object equality can be used to identify clients
	
	
	// Unique randomized id gen for security
	var cons = gserver.connexions
	do {
		this.conKey = Math.random();
	} while (!Object.keys(cons).reduce (
		function(prev,currKey) {
			return prev && cons[currKey].conKey != that.conKey
		}, true)
	)
	
	gserver.connexions[streamKey(stream)] = this
	
	//gserver.playersByStream[stream] = player
	
	function disco()
	{
		console.log("Disconnecting player "+player.name)
		//gserver.connexions.splice(gserver.connexions.indexOf(this), 1)
		//delete gserver.playersByStream[stream]
		//gserver.connexions.splice(gserver.connexions.indexOf(this), 1)
		delete gserver.connexions[streamKey(this.stream)]//gserver.conByKey[this.conKey]
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
	//this.connexions = [] // FIXME NOT USED
	//this.playersByStream = {}
	//this.conByStream = {}
	//this.conByKey = {}
	this.connexions = {}
	
	//console.log(performance.now()	)

	/*
	Date.now()         //  1337376068250
   	performance.now()  //  20303.427000007
	*/
	var lastTime = Date.now()
	
	//console.log("AA")
	// Game model computation
	setInterval(function() {
	//setTimeout(function() {
		//console.log("BB")
		var time = Date.now()
		game.update((time-lastTime)/1000)
		lastTime = time
	}, GAME_REFRESH_PERIOD)
	
	// Player network updates
	setInterval(function() {
		//game.players.forEach(function(p) { })
		//console.log(that.playersByStream)
		/*
		for (var streamKey in that.playersByStream) {
			//stream  playersByStream[stream]
			var player = that.playersByStream[streamKey]
			
			//console.log(player)
			var id = 0;

			var data = {};
			data[fa.TYPEPOS] = player.getPosition()
			data["id"] = id
			fa.sendPlayerUpdate(player.stream, data) // if position
			
		}*/
		/*
		that.connexions.forEach(function(con) {
			fa.sendPlayerUpdate(player.stream, con.player.id, player.getPosition()); // if position
		})
		*/
		for (var conKey in that.connexions) 
		{
			var con = that.connexions[conKey]
			var data = {}
			data[net.TYPEPOS] = con.player.getPosition() 
			data["id"] = con.player.id 
			fa.sendPlayerUpdate(con.stream, data);
		}
		
	}, MOVE_REFRESH_PERIOD)
	
}

GameServer.prototype.addPlayer = function(stream) {
	// TODO handle timeouts
	
	//console.log(stream.toString())
	
	var c = new Connexion(this, stream, new g.Player(this.game, stream))
	//this.connexions.push(c)
	//game.addPlayer(c)
	
	/*var data = {};
	data[fa.TYPEPOS] = player.getPosition()
	data["id"] = 0
	fa.sendPlayerUpdate(player.stream, data) // if position*/
	
	return c
}
GameServer.prototype.getPlayer = function(stream) {
	//return gserver.connexions.indexOf(con).player
	return this.connexions[streamKey(stream)].player
}
/*
GameServer.prototype.getConByStream = function(stream) {
	return gserver.connexions.indexOf(con).player
}
*/

GameServer.prototype.moveCommand = function(stream, conKey, endCoeff, nodes) {
	//console.log(stream == this.connexions[0].stream)
	//console.log(this.playersByStream[stream].id)
	
	//console.log(startCoeff, endCoeff, nodes)
	
	console.log("Move com from", this.getPlayer(stream).name)//this.playersByStream[stream].name)
	
	//this.playersByStream[stream].move(nodes, endCoeff)
	//this.connexions[streamKey(stream)].player.move(nodes, endCoeff)
	this.getPlayer(stream).move(nodes, endCoeff)
	
}

GameServer.prototype.bombCommand = function(stream, key) { // FIXME key?
	this.getPlayer(stream).bomb()

	var data = {}
	data["id"] = 0 // player id
	data[net.TYPEBOMBID] = 0 
	data[net.TYPEBOMBSTATE] = 0 // 0 = new, 1 = explosion
	data[net.TYPEBOMBTYPE] = 0 // strength or type of bomb
	fa.sendBombUpdate(stream, data)
}

GameServer.prototype.setInitialPosition = function(stream, position) {
	this.getPlayer(stream).setPosition(position)
}


