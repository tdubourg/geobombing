
var g = require('./Game')


exports.GameServer = GameServer
exports.Connexion = Connexion


// in milliseconds:
var GAME_REFRESH_PERIOD = 50
var MOVE_REFRESH_PERIOD = 200


function Connexion(gserver, stream) {
	this.stream = stream
	
	 // Unique randomized id gen for security
	do {
		this.conId = Math.random();
	} while ( !gserver.connexions.reduce (
		function(prev,curr) {
			return prev && curr.conId != this.conId
		}, true)
	)
	
	gserver.connexions.push(this)
}

function GameServer(game) {
	this.game = game
	this.connexions = []
	
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
		time = Date.now()
		game.update((time-lastTime)/1000)
		lastTime = time
	}, GAME_REFRESH_PERIOD)
	
	// Player network updates
	setInterval(function() {
		game.players.forEach(function(p) {
			// TODO 
		})
	},GAME_REFRESH_PERIOD)
1
}

GameServer.prototype.addPlayer = function(stream) {
	// TODO handle timeouts
	
	var c = new Connexion(this, stream, new g.Player())
	//this.connexions.push(c)
	//game.addPlayer(c)
	
	return c
}



