// library call
var clMap = require("./classes/clMap").clMap; 
var clNode = require("./classes/clNode").clNode;
var clWay = require("./classes/clWay").clWay; 

// -- Creating
exports.CreateNode = CreateNode
function CreateNode(id, lat, lon)
{
	var node = new clNode();
	node.nodeId = id;
	node.nodeLatitude = lat;
	node.nodeLongitude = lon;
	return node;
}

exports.CreateEmptyWay = CreateEmptyWay
function CreateEmptyWay(id, name)
{
	var way = new clWay();
	way.wayId = id;
	way.wayName = name;
	way.wayListNodeId = new Array();
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
	if (way == null || nodeId == 0 || way.wayListNodeId == null) return false;
	else way.wayListNodeId[way.wayListNodeId.length] = nodeId;
}

exports.AddWayToMap = AddWayToMap
function AddWayToMap(map, way)
{
	if (map == null || way == null || map.mapListWay == null) return false;
	else map.mapListWay[map.mapListWay.length] = way;
}