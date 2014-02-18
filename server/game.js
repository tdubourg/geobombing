"use strict"

exports.Node = Node
exports.Arc = Arc
exports.Player = Player
exports.Game = Game

var u = require("./util")

function Node(id, x, y) {
	this.id = id // node Id
	this.x = x   // latitude
	this.y = y   // longitude
	nodes[id] = this
}

function Arc(id, n1, n2) {
	this.nodes = [this.n1 = n1, this.n2 = n2]
	this.walls = []
	this.bombs = []
	//this.arcs[id] = this
}

function Player(id, name) {
	this.id = id
	this.name = name
	this.currentPath = []
}

function Game() {
	this.nodes = []
	this.arcs = []
	this.players = []
}

function BombAction() {
	
}

Player.prototype.update = function (period) {
	//console.log("Updating "+this)
	
}

Game.prototype.update = function (period) {
	//console.log(Player.prototype.update)
	//this.players.forEach()
	//this.players.thismap(Player.prototype.update, [period])
	this.players.thismap(Player.prototype.update, period)
	
}
