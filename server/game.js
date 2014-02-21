"use strict"

exports.Node = Node
exports.Arc = Arc
exports.Map = Map
exports.Player = Player
exports.Game = Game

var u = require("./util")
var com = require("./common")

function Node(id, x, y) {
	this.id = id // node Id
	this.x = x   // latitude
	this.y = y   // longitude
	//nodes[id] = this
	this.arcsTo = []
}

// Returns null if there is no arc to the node from this node
Node.prototype.arcTo = function (node) {
	if (this.arcsTo[node]) return this.arcsTo[node]
	else return null
}

function Arc(/*id, name,*/ n1, n2) {
	//this.id = id
	//this.name = name
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

// Takes the same map object that will be converted
// into JSon to be sent and stores it as jsonObj
function Map(jsonObj) {
	var that = this
	this.nodes = []
	//this.arcs = []
	this.nb_arcs = 0
	this.jsonObj = jsonObj
	// TODO
	
	this.name = jsonObj.mapName
	this.id = jsonObj.mapId
	jsonObj.mapListNode.forEach(function(n) {
		//nodes.push(new Node(n.id, n.x, n.y))
		that.nodes[n.id] = new Node(n.id, n.x, n.y)
	})
	jsonObj.mapListWay.forEach(function(w) {
		for (var i = 0; i < w.wLstNdId.length-1; i++) {
			//that.arcs.push(new Arc(that.nb_arcs++, w.wName, w.wLstNdId[i], w.wLstNdId[i+1]))
			/*
			w.wLstNdId[i].arcsTo.push(new Arc(w.wLstNdId[i], w.wLstNdId[i+1]))
			w.wLstNdId[i+1].arcsTo.push(new Arc(w.wLstNdId[i+1], w.wLstNdId[i]))
			*/
			//console.log(w)
			that.nodes[w.wLstNdId[i  ]].arcsTo.push(new Arc(w.wLstNdId[i], w.wLstNdId[i+1]))
			that.nodes[w.wLstNdId[i+1]].arcsTo.push(new Arc(w.wLstNdId[i+1], w.wLstNdId[i]))
		}
	})
	
}

var pids = 0
//function Player(id, name, stream) {
//function Player(id, name) {
function Player() {
	/*this.id = id
	this.name = name*/
	this.id = ++pids
	this.name = "Player_"+this.id
	this.currentPath = []
	this.speed = 1E-3
	
	//this.currentArc = null
	//this.currentArcPos = null
	this.currentArc = null
	this.currentArcDist = null
	
	this.nextNode = null
}

function Game(map) {
	this.map = map
	this.players = []
	this.playersId = 0
}

function BombAction() {
	
}

Player.prototype.update = function (period) {
	//console.log("Updating "+this)
	if (this.nextNode != null) {
		var distToWalk = this.speed*period
		//var distToNode = this.currentArc.distFromTo(this.currentArcPos, this.nextNode)
		
		while (distToWalk > 0) {
			var distToNode = this.currentArc.length-this.currentArcDist
			if (distToWalk < distToNode) {
				this.currentArcDist += distToWalk
				distToWalk = 0
			} else {
				var currNode = this.currentPath.shift()
				this.nextNode = this.currentPath.shift()
				if (currNode) {
					this.currentArc = currNode.arcTo(this.currentPath[0])
					if (this.currentArc == null); // TODO
					this.currentArcDist = 0 //this.currentArc.length
				}
			}
		}
		
		
	}
	
}

Game.prototype.update = function (period) {
	//console.log(period)
	
	//console.log(Player.prototype.update)
	//this.players.forEach()
	//this.players.thismap(Player.prototype.update, [period])
	this.players.thismap(Player.prototype.update, period)
	
}

Game.prototype.addPlayer = function (stream) {
	var id = ++this.playersId
	var p = new Player(id, "Player_"+id, stream)
	this.players.push(p)
	return p
}





