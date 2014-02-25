"use strict"

exports.Node = Node
exports.Arc = Arc
exports.Map = Map
exports.Player = Player
exports.Game = Game

var u = require("./util")
var com = require("./common")

function panick(str) {
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

function Arc(/*id, name,*/ n1, n2) {
	//this.id = id
	//this.name = name
	//console.log(">>>>>",n1,n1.x)
	this.length = com.dist(n1,n2)
	this.nodes = [this.n1 = n1, this.n2 = n2]
	this.walls = []
	this.bombs = []
	//this.arcs[id] = this
}

Arc.prototype.distFromTo = function (coeff, node) {
	if (node === this.n1) return this.length*coeff
	if (node === this.n2) return this.length*(1-coeff)
	throw "Not a node of this arc"
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

var pids = 0
//function Player(id, name, stream) {
//function Player(id, name) {
function Player(game,stream) {
	//console.log("CRE PLAY",game)
	/*this.id = id
	this.name = name*/
	this.game = game
	game.players.push(this)
	this.stream = stream
	this.id = ++pids
	this.name = "Player_"+this.id
	this.currentPath = []  // contains nextNode? -> NOT
	this.speed = .3 //1E-3
	this.connexion = null
	
	//this.currentArc = null
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
	//this.bombs = {}
	this.bombs = []
}

var bombNb = 0
function Bomb(player) { //, arc, coeff) {
	this.player = player
	this.id = ++bombNb
	this.time = -1
	this.arc = player.currentArc
	this.arcDist = player.currentArcDist
	//player.game.bombs[this.id] = this
	
}
/*
function BombAction() {
	
}
*/

Bomb.prototype.update = function (period, explodingBombs) {
	//console.log("tick...")
	if (this.time < 0 && this.time+period >= 0) {
		explodingBombs.push(this)
		console.log("BOOM!!")
	}
	this.time += period
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

Player.prototype.getPosition = function () {
	return com.CreatePosition(
		this.currentArc.n1.id,
		this.currentArc.n2.id,
		this.currentArcDist/this.currentArc.length);
}

Player.prototype.setPosition = function (position) {
	console.log("setpos",position)
	this.currentArc = this.game.map.nodes[position.n1].arcToId(position.n2)
	if (!this.currentArc)
		console.log("[Game Model Error]: couldn't set initial position with nodes ", position.n1, position.n2)
	this.currentArcDist = position.c*this.currentArc.length;
	this.targetArcDist = null
}

Player.prototype.move = function (nodeIds, endCoeff) {
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
	else panick("Unknown move")
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
			panick("Invalid move: no way to node "+node)
			return
		}
	}
	//console.log("Ending at: "+arc)
	this.targetArcDist = endCoeff*arc.length
	
	
	//console.log("Going to", this.currentArc+"")
	
}
Player.prototype.bomb = function () {
	// TODO
	var b = new Bomb(this)
	
	this.game.bombs.push(b)
	
	return b
}

Game.prototype.update = function (period, explodingBombs) {
	//console.log(period)
	
	this.players.thismap(Player.prototype.update, period)
	
	this.bombs.thismap(Bomb.prototype.update, period, explodingBombs)
	
	
}




