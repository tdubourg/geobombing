"use strict"

exports.Node = Node
exports.Arc = Arc
exports.Map = Map
exports.Player = Player
exports.Game = Game

var u = require("./util")
var com = require("./common")
var fa = require("./frame_action")

var PLAYER_SPEED = .1 //.5
var BOMB_TIMER = 3 // seconds
var BOMB_PROPAG_TIME = 1
var BOMB_POWER = .2
var REDUCE_BOMB_POWER_AT_ANGLE = true
var DEBUG_BOMBES = true

/// MAP //////////////////////

function panic(str) {
	console.log("[Game Model Error]: "+(str? str: "unspecified"))
}

function Node(id, x, y) {
	this.id = id // node Id
	this.x = x   // latitude
	this.y = y   // longitude
	//nodes[id] = this
	//this.arcsTo = []
	this.arcsTo = {}
}

Node.prototype.toString = function () {
	//return "("+this.x+","+this.y+")"
	return "(Node "+this.id+")"
}

// Returns null if there is no arc to the node from this node
Node.prototype.arcToId = function (nodeId) {
	if (this.arcsTo[nodeId]) return this.arcsTo[nodeId]
	else return null
}

var idNb = 0

function Arc(/*id, name,*/ n1, n2) {
	//this.id = id
	//this.name = name
	//console.log(">>>>>",n1,n1.x)
	this.id = idNb++
	this.nodes = [this.n1 = n1, this.n2 = n2]
	this.length = com.dist(n1,n2)
	this.angle = Math.atan2(this.n2.y - this.n1.y, this.n2.x - this.n1.x)
	/*
	this.walls = []
	this.bombs = []
	*/
	//this.arcs[id] = this
}

Arc.prototype.distFromTo = function (coeff, node) {
	if (node === this.n1) return this.length*coeff
	if (node === this.n2) return this.length*(1-coeff)
	throw "Not a node of this arc"
}

// angle formed by n1, n2, node
Arc.prototype.angleWith = function (node) {
	//return Math.atan2(this.n2.y - this.n1.y,)
	//return (this.angle - this.n2.arcToId(node.id).angle)%(2*Math.PI)
	var a = (this.angle + 2*Math.PI - this.n2.arcToId(node.id).angle)%(2*Math.PI)
	if (a > Math.PI)
		a -= 2*Math.PI
	return a
}

Arc.prototype.getOpposite = function () {
	return this.n2.arcToId(this.n1.id)
}

Arc.prototype.toString = function () {
	return "<"+this.n1+","+this.n2+">"
}

// Takes the same map object that will be converted
// into JSon to be sent and stores it as jsonObj
function Map(jsonObj) {
	var that = this
	this.nodes = []
	//this.arcs = []
	this.nb_arcs = 0
	this.jsonObj = jsonObj
	// TODO
	
	//console.log(jsonObj)
	
	this.name = jsonObj.mapName
	this.id = jsonObj.mapId
	jsonObj.mapListNode.forEach(function(n) {
		//console.log("adding node",n.id)
		//nodes.push(new Node(n.id, n.x, n.y))
		that.nodes[n.id] = new Node(n.id, n.x, n.y)
	})
	jsonObj.mapListWay.forEach(function(w) {
		//console.log(w)
		for (var i = 0; i < w.wLstNdId.length-1; i++) {
			
			//n1 = this.getNode(w.wLstNdId[i]), n2 = this.getNode(w.wLstNdId[i+1])
			var n1 = that.nodes[w.wLstNdId[i]], n2 = that.nodes[w.wLstNdId[i+1]]
			that.nodes[n1.id].arcsTo[n2.id] = new Arc(n1, n2)
			that.nodes[n2.id].arcsTo[n1.id] = new Arc(n2, n1)
		}
	})
	
}

Map.prototype.getNode = function (nid) {
	return this.nodes[nid]
}


/// PLAYERS /////////////////////////


var pids = 0
function Player(game, stream) {
	//console.log("CRE PLAY",game)
	/*this.id = id
	this.name = name*/
	this.game = game
	game.players.push(this)
	this.stream = stream
	this.id = ++pids
	this.name = "Player_" + this.id
	this.currentPath = []  // contains nextNode? -> NOT
	this.speed = PLAYER_SPEED //.3 //1E-3
	this.connexion = null
	this.dead = false
	this.spwanPosition = null

	// for ranking
	this.deads = 0
	this.kills = 0
	this.points = 0

	//this.currentArcPos = null
	this.currentArc = null
	this.currentArcDist = null
	this.targetArcDist = null
	//this.nextNode = null
}

function Game(map) {
	this.map = map
	this.players = []
	this.playersId = 0
	this.bombs = []
	//this.dyingPlayers = []
}

var bombNb = 0
function Bomb(player) { //, arc, coeff) {
	this.player = player
	this.id = ++bombNb
	this.time = -BOMB_TIMER
	this.arc = player.currentArc
	this.arcDist = player.currentArcDist
	//this.power = 1
	this.power = BOMB_POWER
	//player.game.bombs[this.id] = this
}

Player.prototype.onKillPlayer = function (player_killed) // can be called on himself (kamikaze)
{
	player_killed.deads++
	if (player_killed.id != this.id)
	{	
		player_killed.points -= 5
		this.points += 10
		this.kills++
	}
}


Bomb.prototype.update = function (period, explodingBombs) {
	//console.log("tick...")
	if (this.time < 0 && this.time+period >= 0)
	{
		explodingBombs.push(this)
		console.log("BOOM!!")
		this.explode_propagate(1)
	}
	this.time += period
	
	if (this.time > BOMB_PROPAG_TIME)
	{
		this.remove()
	}
	else if (this.time > 0)
	{
		//this.explode_propagate(this.time/BOMB_PROPAG_TIME)
	}
}

function DEBUG_fillWithBombs(game, player, arc, from, to) {
	//console.log(from, to, "/"+arc.length)
	for (var i = from; i < to; i+=.2) {
		if (i <= arc.length) {
			var b = new Bomb(player)
			b.arc = arc
			b.arcDist = i
			//console.log(i)
			//console.log(b.arc.toString(), b.arcDist)
			fa.getServer().notifyBomb(b)
		}
	}
}

Bomb.prototype.explode_propagate = function (coeff) {
	var game = this.player.game
	var player = this.player
	var playersOnArc = {}
	var visitedArc = {}
	var that = this
	
	function addPlayerOn(player, arc, dist) {
		if (!playersOnArc[arc.id])
			playersOnArc[arc.id] = []

		playersOnArc[arc.id].push({p:player, d:dist})
	}

	game.players.forEach(function(p) {
		addPlayerOn(p, p.currentArc, p.currentArcDist)
		addPlayerOn(p, p.currentArc.getOpposite(), p.currentArc.length - p.currentArcDist)
	})

	function rec (startDist, distToCover, prevNode, arc) {
		
		if (visitedArc[arc.id]) return
		visitedArc[arc.id] = true
		visitedArc[arc.getOpposite().id] = true
		
		if (DEBUG_BOMBES
		)
			DEBUG_fillWithBombs(game, player, arc, startDist, distToCover)
		
		// Test kills:
		
		if (playersOnArc[arc.id])
		playersOnArc[arc.id].forEach(function(pd) 
		{
			if (startDist <= pd.d && pd.d <= distToCover) 
			{
				console.log("\nKILLER:", that.player.name)
				console.log("DYER:", pd.p.name)
				pd.p.die()
				that.player.onKillPlayer(pd.p)
				console.log("\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n")
			}
		})
		
		// Propagate:
		
		var newDistToCover = distToCover-(arc.length-startDist)
		
		if (newDistToCover > 0)
		{
			//arc.n2.arcsTo.forEach(function(a) {
			for (var k in arc.n2.arcsTo)
			{
				var newArc = arc.n2.arcsTo[k]
				//console.log("> "+a)
				var angle = arc.angleWith(newArc.n2)
				
				if (!visitedArc[newArc.id]
					&& angle > -Math.PI/2 && angle < Math.PI/2
				) {
					//console.log("ang: "+angle)
					//console.log(">> "+a)
					if (REDUCE_BOMB_POWER_AT_ANGLE)
						 rec(0, newDistToCover*Math.cos(angle), arc.n2, newArc)
					else rec(0, newDistToCover, arc.n2, newArc)
				}
				
			}
		}
		
	}
	var curArc = this.arc
	////////////////////////////
	//var power = 1 // 3 // TODO adjust to real value
	var power = this.power
	////////////////////////////
	
	power *= coeff
	
	rec(this.arcDist, this.arcDist+power, curArc.n1, curArc)
	visitedArc[curArc.getOpposite().id] = false
	//rec(curArc.length-this.arcDist, power, curArc.n2, curArc.n2.arcToId(curArc.n1.id))
	var d = curArc.length-this.arcDist
	rec(d, d+power, curArc.n2, curArc.getOpposite())
	
}

Bomb.prototype.remove = function () {
	var bs = this.player.game.bombs
	bs.splice(bs.indexOf(this),1)
}

Bomb.prototype.getPosition = function () {
	return com.CreatePosition(
		this.arc.n1.id,
		this.arc.n2.id,
		this.arcDist/this.arc.length);
}

var delta = 0.0001
Player.prototype.update = function (period) {
	
	if (this.targetArcDist != null) {
		var distToWalk = this.speed*period
		//var distToNode = this.currentArc.distFromTo(this.currentArcPos, this.nextNode)
		//console.log(period)
		
		//console.log("Going to", this.currentArc+"", this.targetArcDist+"/"+this.currentArc.length)
		
		while (distToWalk > delta) {
			//var distToNode = this.currentArc.length-this.currentArcDist
			//var distToNode = this.targetArcDist-this.currentArcDist
			var distToNode = this.currentPath.length == 0?
				this.targetArcDist-this.currentArcDist
			:	this.currentArc.length-this.currentArcDist
			
			if (distToWalk < distToNode) {
				this.currentArcDist += distToWalk
				distToWalk = 0
				//this.targetArcDist = null
			} else {
				distToWalk -= distToNode
				//var currNode = this.currentPath.shift()
				
				if (this.currentPath.length > 0) {
					
					var currNode = this.currentArc.n2
					var nextNode = this.currentPath.shift()
					
					var newCurrentArc = currNode.arcToId(nextNode.id)
					if (newCurrentArc)
						this.currentArc = newCurrentArc
					else
						console.log("[Game Model Error]: couldn't find a path from node",
							currNode.id, "to node", nextNode.id)
					this.currentArcDist = 0
					
				} else {
					this.targetArcDist = null
					break
				}
				
			}
		}
	}
	
}

Player.prototype.die = function () {
	if (!this.dead) 
	{
		console.log("Player",this.name,"died in horrible pain!!")
		this.dead = true
		this.resetMove()
		
		this.game.dyingPlayers.push(this)
		
	}
}

Player.prototype.remove = function () {
	this.game.players.splice(this.game.players.indexOf(this),1)
}

Player.prototype.getPosition = function () {
	return com.CreatePosition(
		this.currentArc.n1.id,
		this.currentArc.n2.id,
		this.currentArcDist/this.currentArc.length);
}

Player.prototype.setSpawnPosition = function (position) {
	console.log("setpos",position)
	this.spwanPosition = position
	this.respawn()
	// this.currentArc = this.game.map.nodes[position.n1].arcToId(position.n2)
	// if (!this.currentArc)
	// 	console.log("[Game Model Error]: couldn't set initial position with nodes ", position.n1, position.n2)
	// this.currentArcDist = position.c*this.currentArc.length;
	// this.targetArcDist = null
}

Player.prototype.respawn = function () {
	this.setPosition(this.spwanPosition)
	this.dead = false
}

Player.prototype.setPosition = function (position) {
	this.currentArc = this.game.map.nodes[position.n1].arcToId(position.n2)
	if (!this.currentArc)
		console.log("[Game Model Error]: couldn't set initial position with nodes ", position.n1, position.n2)
	this.currentArcDist = position.c*this.currentArc.length;
	this.targetArcDist = null
}

Player.prototype.move = function (nodeIds, endCoeff) {
	if (this.dead) return
	
	var firstNodeId = nodeIds.shift()
	
	if (this.currentArc.n1.id == firstNodeId) {
		this.currentArc = this.currentArc.n2.arcToId(firstNodeId)
		this.currentArcDist = this.currentArc.length - this.currentArcDist
		//this.targetArcDist = endCoeff*this.currentArc.length
	}
	else if (this.currentArc.n2.id == firstNodeId) {
		//this.nextNode = this.currentArc.n2
	}
	//else console.log("[Game Model Error]: Unknown move ")
	else panic("Unknown move")
	//console.log("mvTo:",this.nextNode)
	
	
	var nodesRest = []
	for (var i = 0; i < nodeIds.length; i++)
		nodesRest.push(this.game.map.getNode(nodeIds[i]))
	this.currentPath = nodesRest
	
	var nodesRest2 = nodesRest.slice()
	var arc = this.currentArc
	while(nodesRest2.length > 0)
	{
		var node = nodesRest2.shift()
		//console.log("Next node: "+node)
		arc = arc.n2.arcToId(node.id)
		if (!arc) {
			this.targetArcDist = 0
			panic("Invalid move: no way to node "+node)
			return
		}
	}
	//console.log("Ending at: "+arc)
	this.targetArcDist = endCoeff*arc.length
	
	//console.log("Going to", this.currentArc+"")
}

Player.prototype.resetMove = function (nodeIds, endCoeff) {
	this.targetArcDist = null
}

Player.prototype.bomb = function () 
{
	if (this.dead) return
	
	var b = new Bomb(this)
	this.game.bombs.push(b)
	return b
}

Game.prototype.update = function (period, explodingBombs, dyingPlayers) 
{
	this.dyingPlayers = dyingPlayers
	this.players.thismap(Player.prototype.update, period)	
	this.bombs.thismap(Bomb.prototype.update, period, explodingBombs)
}

Game.prototype.newGame = function () 
{	
	for (var i = 0; i < this.players.length; i++) 
	{
		var p = this.players[i]
		p.deads = 0
		p.kills = 0
		p.points = 0
		p.respawn()
	};
	
}




