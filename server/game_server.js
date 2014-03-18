"use strict"

exports.GameServer = GameServer
exports.Connexion = Connexion

var g = require('./game')
var fa = require('./frame_action')
var net = require('./network')

// in milliseconds:
var GAME_REFRESH_PERIOD = 50
var TIME_BEFORE_RESPAWN = 5000

// in seconds
var SESSION_LENGHT = 300
var PALMARES_SHOW_TIME = 15
var session_time_remaining = SESSION_LENGHT
var session = true
exports.session_time_remaining = session_time_remaining

function streamKey(stream) 
{
	/*
	var a = stream.address()
	return a.address+":" + a.port
	*/
	return stream.id
}

var usedConKeys = []

function Connexion(gserver, stream, player) 
{
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
	do { this.conKey = Math.random().toString().substring(2); } 
	while (!usedConKeys.reduce (
		function(prev,currKey) 
		{
			return prev && currKey != that.conKey
		}, true)
	)
	stream.id = this.conKey
	console.log("Generated key for " + player.name + ":", this.conKey)	
	gserver.connexions[streamKey(stream)/*==this.conKey*/] = this
	usedConKeys.push(this.conKey)
	
	function disco()
	{
		if (that.open) 
		{
			console.log("Disconnecting player "+player.name)
			that.open = false
			delete gserver.connexions[streamKey(stream)]
			player.remove()
			gserver.notify(function(stream) 
			{
				fa.sendPlayerRemove(stream, player)
			})
		} else { console.log("Player "+player.name+" is already disconnected") }
	}	
	stream.addListener("end", disco)
	stream.addListener("error", function(err) { disco() })	
	this.open = true
	//gserver.connexions.push(this)
}

function GameServer(game, tiles) 
{
	var that = this
	this.tiles = tiles
	this.game = game
	this.connexions = {}
	this.respawnIntervalsByPlayerId = {}
	var sending_player_updates = true
	var lastTime = Date.now()
	
	// MAIN LOOP (GAME ENGINE)
	setInterval(function() 
	{
		var time = Date.now()
		var explodingBombs = []
		var dyingPlayers = []
		
		// Dying players (Is it used for monsters as well?)
		game.update((time-lastTime)/1000, explodingBombs, dyingPlayers)		
		explodingBombs.forEach(function (bomb) { that.notifyBomb(bomb) })		
		dyingPlayers.forEach(function (p) 
		{
			var to_id = setTimeout(function() 
			{
				console.log("Player",p.name,"automatically respawned")
				p.respawn()
				delete that.respawnIntervalsByPlayerId[p.id]
			}, TIME_BEFORE_RESPAWN)
			that.respawnIntervalsByPlayerId[p.id] = to_id
		})
		lastTime = time

		// Network updates
		if (sending_player_updates)
		{	
			for (var conKey in that.connexions) 
			{
				var con = that.connexions[conKey]
				fa.sendPlayersUpdate(con.stream, game.players)
				fa.sendMonstersUpdate(con.stream, game.monsters)
			}

			// to stop sending number kills	
			game.players.forEach(function (player) {player.haskilled = false })	
		}		
	}, GAME_REFRESH_PERIOD)


	// SESSIONS
	if (session)
	{ 
		setInterval(function() 
		{		
			session_time_remaining--;
			exports.session_time_remaining = session_time_remaining
			if (session_time_remaining == 0)
			{
				console.log("fin de la partie")			
				sending_player_updates = false
				for (var p_id in that.respawnIntervalsByPlayerId) 
				{
					clearTimeout(that.respawnIntervalsByPlayerId[p_id])
					delete that.respawnIntervalsByPlayerId[p_id]
				}

				// calculates palmares
				var sortFn = function(p1,p2)
				{
        			if (p1.points > p2.points) return -1;
        			if (p1.points < p2.points) return 1;
        			if (p1.points == p2.points) return 0;
        		}

    			game.players.sort(sortFn);
				for (var conKey in that.connexions) 
				{
					var con = that.connexions[conKey]
					game.players.forEach(function (player) 
					{
						fa.sendEnd(con.stream, game.players)
					})
				}			
			}
			else if (session_time_remaining == -PALMARES_SHOW_TIME)
			{ 
				session_time_remaining = SESSION_LENGHT
				console.log("nouvelle partie")
				that.game.newGame()
				sending_player_updates = true
			}
			
		}, 1000) // refresh counter each second
	}
	
}

GameServer.prototype.notify = function(fct) 
{
	for (var conKey in this.connexions) 
	{
		fct(this.connexions[conKey].stream)
	}
}

GameServer.prototype.notifyBomb = function(bomb) 
{
	for (var conKey in this.connexions) 
	{
		var con = this.connexions[conKey]
		fa.sendBombUpdate(con.stream, bomb);
	}
}

GameServer.prototype.addPlayer = function(stream) 
{
	// TODO handle timeouts
	var p = new g.Player(this.game)
	var c = new Connexion(this, stream, p)
	
	return p
}
GameServer.prototype.addMonster = function(position) 
{
	var m = new g.Player(this.game, true)
	m.setSpawnPosition(position)
	return m
}

GameServer.prototype.getPlayer = function(stream) 
{
	return this.connexions[streamKey(stream)].player
}

GameServer.prototype.moveCommand = function(stream, conKey, endCoeff, nodes) {
	
	console.log("Move com from", this.getPlayer(stream).name)	
	this.getPlayer(stream).move(nodes, endCoeff)
	
}

GameServer.prototype.bombCommand = function(stream, key) { // FIXME key?
	var b = this.getPlayer(stream).bomb()
	this.notifyBomb(b)
}

GameServer.prototype.quitCommand = function(stream, key) { // not used atm
	console.log("player gone")
	//this.getPlayer(stream).quit() // todo complete, Lionel!
}

GameServer.prototype.setInitialPosition = function(stream, position) {
	this.getPlayer(stream).setSpawnPosition(position)
}


