// -- Creating
function CreateNode(id, lat, lon)
{
	var node = clNode();
	node.nodeId = id;
	node.nodeLatitude = lat;
	node.nodeLongitude = lon;
	return node;
}

function CreateEmptyWay(id, name)
{
	var way = clWay();
	way.wayId = id;
	way.wayName = name;
	way.wayListNodeId = new Array();
	return way;
}

function CreateEmptyMap(id, name)
{
	var map = clMap();
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
		if (way == null || nodeId == 0 || way.wayListNodeId == null) return false;
	else way.wayListNodeId[way.wayListNodeId.length] = nodeId;
}

function AddWayToMap(map, way)
{
		if (map == null || way == null || map.mapListWay == null) return false;
	else map.mapListWay[map.mapListWay.length] = way;
}