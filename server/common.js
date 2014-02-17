// library call
var clMap = require("./Classes/clMap").clMap; 
var clNode = require("./Classes/clNode").clNode;
var clWay = require("./Classes/clWay").clWay; 
var clPosition = require('./network').clPosition; 

// -- Creating
exports.CreatePosition = CreatePosition
function CreatePosition(node1, node2, coef)
{
	var pos = new clNode();
	pos.n1 = node1;
	pos.n2 = node2;
    pos.c = coef;
	return pos;
}

function CreateNode(id, lat, lon)
{
	var node = new clNode();
	node.id = id;
	node.la = lat;
	node.lo = lon;
	return node;
}

exports.CreateEmptyWay = CreateEmptyWay
function CreateEmptyWay(name)
{
	var way = new clWay();
	way.wayName = name;
	way.wLstNdId = new Array();
	return way;
}

exports.CreateEmptyMap = CreateEmptyMap
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
exports.AddNodeToMap = AddNodeToMap
function AddNodeToMap(map, node)
{
	if (map == null || node == null || map.mapListNode == null) return false;
	else map.mapListNode[map.mapListNode.length] = node;
}

exports.AddNodeIdToWay = AddNodeIdToWay
function AddNodeIdToWay(way, nodeId)
{
	if (way == null || nodeId == 0 || way.wLstNdId == null) return false;
	else way.wLstNdId[way.wLstNdId.length] = nodeId;
}

exports.AddWayToMap = AddWayToMap
function AddWayToMap(map, way)
{
	if (map == null || way == null || map.mapListWay == null) return false;
	else map.mapListWay[map.mapListWay.length] = way;
}