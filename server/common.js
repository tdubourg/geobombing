// library call
var clMap = require("./classes/clMap").clMap; 
var clNode = require("./classes/clNode").clNode;
var clWay = require("./classes/clWay").clWay; 

// -- Creating
exports.CreateNode = CreateNode
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

exports.CreateFakeMap = CreateFakeMap // todo delete
function CreateFakeMap() // todo replace by SQL result map
{
	var mapObj = CreateEmptyMap(123, "maptest");
	var node1 = CreateNode(1, 10, 100);
	var node2 = CreateNode(2, 100, 50);
	var node3 = CreateNode(3, 0, 150);
	var node4 = CreateNode(4, 50, 50);
	var node5 = CreateNode(5, 100, 100);
	AddNodeToMap(mapObj, node1);
	AddNodeToMap(mapObj, node2);
	AddNodeToMap(mapObj, node3);
	AddNodeToMap(mapObj, node4);
	AddNodeToMap(mapObj, node5);
	var way1 = CreateEmptyWay("Rue du short");
	AddNodeIdToWay(way1, 1);
	AddNodeIdToWay(way1, 2);
	AddNodeIdToWay(way1, 3);
	var way2 = CreateEmptyWay("Rue du slip");
	AddNodeIdToWay(way2, 1);
	AddNodeIdToWay(way2, 3);
	AddNodeIdToWay(way2, 5);
	var way3 = CreateEmptyWay("Rue du bonnet");
	AddNodeIdToWay(way3, 1);
	AddNodeIdToWay(way3, 5);
	AddNodeIdToWay(way3, 4);
	AddWayToMap(mapObj, way1);
	AddWayToMap(mapObj, way2);
	AddWayToMap(mapObj, way3);
	return mapObj;
}