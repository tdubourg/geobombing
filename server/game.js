"use strict"

exports.Node = Node
exports.Arc = Arc
exports.Map = Map
exports.Player = Player
exports.Game = Game

var u = require("./util")
var com = require("./common")

function panick() {
	console.log("[Game Model Error]: ??")
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
	return "("+this.x+","+this.y+")"
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
			//that.arcs.push(new Arc(that.nb_arcs++, w.wName, w.wLstNdId[i], w.wLstNdId[i+1]))
			/*
			w.wLstNdId[i].arcsTo.push(new Arc(w.wLstNdId[i], w.wLstNdId[i+1]))
			w.wLstNdId[i+1].arcsTo.push(new Arc(w.wLstNdId[i+1], w.wLstNdId[i]))
			*/
			//console.log(w)
			/*
			that.nodes[w.wLstNdId[i  ]].arcsTo.push(new Arc(w.wLstNdId[i], w.wLstNdId[i+1]))
			that.nodes[w.wLstNdId[i+1]].arcsTo.push(new Arc(w.wLstNdId[i+1], w.wLstNdId[i]))
			*/
			/*
			that.nodes[w.wLstNdId[i  ]].arcsTo[w.wLstNdId[i+1]] = new Arc(w.wLstNdId[i], w.wLstNdId[i+1])
			that.nodes[w.wLstNdId[i+1]].arcsTo[w.wLstNdId[i  ]] = new Arc(w.wLstNdId[i+1], w.wLstNdId[i])
			*/
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
	this.bombs = {}
}

var bombNb = 0
function Bomb(gserver, arc, coeff) {
	this.id = ++bombNb
	this.time = 1000
	gserver.bombs[this.id] = this
	
}

function BombAction() {
	
}

var delta = 0.0001
Player.prototype.update = function (period) {
	//console.log("Updating "+this)
	/*
	// this was for node-to-node navigation:
	if (this.nextNode != null) {
		var distToWalk = this.speed*period
		//var distToNode = this.currentArc.distFromTo(this.currentArcPos, this.nextNode)
		//console.log(period)
		
		while (distToWalk > delta) {
			var distToNode = this.currentArc.length-this.currentArcDist
			if (distToWalk < distToNode) {
				this.currentArcDist += distToWalk
				distToWalk = 0
			} else {
				distToWalk -= distToNode
				//var currNode = this.currentPath.shift()
				var currNode = this.nextNode
				this.nextNode = this.currentPath.shift()
				
				if (currNode); // should always be true actually
				else panick()
				
				if (this.nextNode) {
					//var newCurrentArc = currNode.arcToId(this.currentPath[0].id)
					var newCurrentArc = currNode.arcToId(this.nextNode.id)
					if (newCurrentArc)
						this.currentArc = newCurrentArc
					else
						console.log("[Game Model Error]: couldn't find a path from node",
							currNode.id, "to node", this.currentPath[0].id)
					this.currentArcDist = 0 //this.currentArc.length
				} else return;
				//this.currentArcDist = 0
			}
		}
	}
	*/
	
	// this is for arc coeff navigation:
	// TODO
	if (this.targetArcDist != null) {
		var distToWalk = this.speed*period
		//var distToNode = this.currentArc.distFromTo(this.currentArcPos, this.nextNode)
		//console.log(period)
		
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
							currNode.id, "to node", this.currentPath[0].id)
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
	//console.log(this.game.map.nodes)
	//console.log(this.game.map.nodes[position.n1].arcsTo)
	this.currentArc = this.game.map.nodes[position.n1].arcToId(position.n2)
	if (!this.currentArc)
		console.log("[Game Model Error]: couldn't set initial position with nodes ", position.n1, position.n2)
	this.currentArcDist = position.c*this.currentArc.length;
	this.targetArcDist = null
}

Player.prototype.move = function (nodeIds, endCoeff) {
	var firstNodeId = nodeIds.shift()
	/*
	//var nextNode
	//console.log(this.currentArc.n1.id, " - ", firstNodeId)
	//console.log(nodeIds)
	if (this.currentArc.n1.id == firstNodeId) {
		this.currentArc = this.currentArc.n2.arcToId(firstNodeId)
		this.currentArcDist = this.currentArc.length - this.currentArcDist
		this.nextNode = this.currentArc.n2
		//TODO//this.targetArcDist = endCoeff*this.currentArc.length
	}
	else if (this.currentArc.n2.id == firstNodeId) {
		this.nextNode = this.currentArc.n2
		//TODO//
	}
	else console.log("[Game Model Error]: Unknown move ")
	//console.log("mvTo:",this.nextNode)
	var nodesRest = []
	for (var i = 0; i < nodeIds.length; i++)
		nodesRest.push(this.game.map.getNode(nodeIds[i]))
	this.currentPath = nodesRest
	*/
	
	if (this.currentArc.n1.id == firstNodeId) {
		this.currentArc = this.currentArc.n2.arcToId(firstNodeId)
		this.currentArcDist = this.currentArc.length - this.currentArcDist
		//this.targetArcDist = endCoeff*this.currentArc.length
	}
	else if (this.currentArc.n2.id == firstNodeId) {
		//this.nextNode = this.currentArc.n2
		//TODO//
	}
	else console.log("[Game Model Error]: Unknown move ")
	//console.log("mvTo:",this.nextNode)
	
	this.targetArcDist = endCoeff*this.currentArc.length
	
	var nodesRest = []
	for (var i = 0; i < nodeIds.length; i++)
		nodesRest.push(this.game.map.getNode(nodeIds[i]))
	this.currentPath = nodesRest
	
	console.log("Going to", this.currentArc)
	
}
Player.prototype.bomb = function () {
	// TODO
	
	
	
}

Game.prototype.update = function (period) {
	//console.log(period)
	
	//console.log(Player.prototype.update)
	//this.players.forEach()
	//this.players.thismap(Player.prototype.update, [period])
	this.players.thismap(Player.prototype.update, period)
	
}
/*
Game.prototype.addPlayer = function (stream) {
	var id = ++this.playersId
	//var p = new Player(id, "Player_"+id, stream)
	var p = new Player(this)
	this.players.push(p)
	return p
}
*/




