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
}

function Arc(id, name, n1, n2) {
	this.id = id
	this.name = name
	this.name = length = com.dist(n1,n2)
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
	this.arcs = []
	this.nb_arcs = 0
	this.jsonObj = jsonObj
	// TODO
	
	this.name = jsonObj.mapName
	this.id = jsonObj.mapId
	jsonObj.mapListNode.forEach(function(n){
		//nodes.push(new Node(n.id, n.x, n.y))
		that.nodes[n.id] = new Node(n.id, n.x, n.y)
	})
	jsonObj.mapListWay.forEach(function(w){
		for (var i = 0; i < w.wLstNdId.length-1; i++) {
			that.arcs.push(new Arc(that.nb_arcs++, w.wName, w.wLstNdId[i], w.wLstNdId[i+1]))
		}
	})
	
}

function Player(id, name) {
	this.id = id
	this.name = name
	this.currentPath = []
	this.speed = 1E-3
	this.currentArc = null
	this.currentArcPos = null
	this.nextNode = null
}

function Game(map) {
	this.map = map
	this.players = []
}

function BombAction() {
	
}

Player.prototype.update = function (period) {
	//console.log("Updating "+this)
	if (this.nextNode != null) {
		var distToWalk = this.speed*period
		var distToNode = this.currentArc.distFromTo(this.currentArcPos, this.nextNode)
		if (distToWalk < distToNode)
	}
	
}

Game.prototype.update = function (period) {
	//console.log(Player.prototype.update)
	//this.players.forEach()
	//this.players.thismap(Player.prototype.update, [period])
	this.players.thismap(Player.prototype.update, period)
	
}
