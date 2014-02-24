"use strict"

var g = require('./Game')
var fa = require('./frame_action')
var net = require('./network')


exports.GameServer = GameServer
exports.Connexion = Connexion


// in milliseconds:
var GAME_REFRESH_PERIOD = 50
var MOVE_REFRESH_PERIOD = 50


function Connexion(gserver, stream, player) {
	var that = this
	
	console.log("Connecting player "+player.name)
	
	this.stream = stream
	this.player = player
	
	// TODO: this seems useless since stream object equality can be used to identify clients
	
	 // Unique randomized id gen for security
	do {
		this.conId = Math.random();
	} while (!gserver.connexions.reduce (
		function(prev,curr) {
			return prev && curr.conId != that.conId
		}, true)
	)
	
	//gserver.playersByStream[stream] = player
	
	function disco()
	{
		console.log("Disconnecting player "+player.name)
		gserver.connexions.splice(gserver.connexions.indexOf(this), 1)
		delete gserver.playersByStream[stream]
	}
	
	stream.addListener("end", disco)
	stream.addListener("error", function(err) {
		disco()
	})
	
	gserver.connexions.push(this)
}

function GameServer(game) {
	var that = this
	
	this.game = game
	this.connexions = [] // FIXME NOT USED
	//this.playersByStream = {}
	
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
			
			//console.log("Pos:", player.getPosition())
			var id = 0;
			//fa.sendPlayerPosition(player.stream, id, player.getPosition())

			var data = {};
			data[fa.TYPEPOS] = player.getPosition()
			fa.sendPlayerUpdate(player.stream, id, data) // if position
			
		}*/
		
		that.connexions.forEach(function(con) {
			
			fa.sendPlayerUpdate(player.stream, con.player.id, player.getPosition()); // if position
			
		})
		
		
	}, MOVE_REFRESH_PERIOD)
	
}

GameServer.prototype.addPlayer = function(stream) {
	// TODO handle timeouts
	
	var c = new Connexion(this, stream, new g.Player(this.game, stream))
	//this.connexions.push(c)
	//game.addPlayer(c)

			/*var data = {};
			data[fa.TYPEPOS] = player.getPosition()
			fa.sendPlayerUpdate(player.stream, id, data) // if position*/
	
	return c
}

GameServer.prototype.moveCommand = function(stream, endCoeff, nodes) {
	//console.log(stream == this.connexions[0].stream)
	//console.log(this.playersByStream[stream].id)
	
	//console.log(startCoeff, endCoeff, nodes)
	
	console.log("Move com from",this.playersByStream[stream].name)
	
	this.playersByStream[stream].move(nodes, endCoeff)
	
}

GameServer.prototype.bombCommand = function(stream, id, pos) {
	//this.playersByStream[stream].//bomb(pos, id) // TODO Lionel :D
	
}

GameServer.prototype.setInitialPosition = function(stream, position) {
	this.playersByStream[stream].setPosition(position)
}


