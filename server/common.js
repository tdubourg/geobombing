"use strict"

// library call
var clMap = require("./Classes/clMap").clMap; 
var clNode = require("./Classes/clNode").clNode;
var clWay = require("./Classes/clWay").clWay; 
var clPosition = require("./Classes/clPosition").clPosition; 

// -- Math

function dist(ptA,ptB) {
	return Math.sqrt(Math.pow(ptB.x-ptA.x,2) + Math.pow(ptB.y-ptA.y,2))
}
exports.dist = dist


// -- Creating

function CreatePosition(idNode1, idNode2, coef)
{
	var pos = new clPosition();
	pos.n1 = idNode1;
	pos.n2 = idNode2;
    pos.c = coef;
    if (idNode1 == null) console.log("CreatePosition:", idNode1, "undefined")
    if (idNode2 == null) console.log("CreatePosition:", idNode2, "undefined")
    if (idNode1 == null) console.log("CreatePosition:", idNode1, "undefined")
	return pos;
}


function CreateNode(id, lat, lon)
{
	var node = new clNode();
	node.id = id;
	node.x = lat;
	node.y = lon;
	return node;
}
function CreateEmptyWay(name)
{
	var way = new clWay();
	way.wName = name;
	way.wLstNdId = new Array();
	return way;
}
function CreateEmptyMap(id, name)
{
	var map = new clMap();
	map.mapId = id;
	map.mapName = name;
	map.mapListNode = new Array();
	map.mapListWay = new Array();
	return map;
}

// -- Adding --
function AddNodeToMap(map, node)
{
	if (map == null || node == null || map.mapListNode == null) return false;
	else map.mapListNode[map.mapListNode.length] = node;
}
function AddNodeIdToWay(way, nodeId)
{
	if (way == null || nodeId == 0 || way.wLstNdId == null) return false;
	else way.wLstNdId[way.wLstNdId.length] = nodeId;
}
function AddWayToMap(map, way)
{
	if (map == null || way == null || map.mapListWay == null) return false;
	else map.mapListWay[map.mapListWay.length] = way;
}

exports.CreatePosition = CreatePosition

exports.CreateNode = CreateNode
exports.CreateEmptyWay = CreateEmptyWay
exports.CreateEmptyMap = CreateEmptyMap

exports.AddNodeToMap = AddNodeToMap
exports.AddNodeIdToWay = AddNodeIdToWay
exports.AddWayToMap = AddWayToMap
