
"use strict"
var clMap = require("./Classes/clMap").clMap; 
var utils = require("./common"); 
//var qh = require('./query_helper'); // for generic query
var lastMapId = 1;
var lastNodeId = 1;

function getMapFromPGSQL(latitude, longitude)
{
	//var queryResult = qh.text_query(""); // todo replace by select_query();
	return [[
	["8.7369691", "41.9198811"], ["8.7368306", "41.9191348"], 
	["8.7369374", "41.9186287"]],
			[["8.7347978", "41.919762"], ["8.7353263", "41.9198519"]]];
}

function fullMapAccordingToLocalisation(latitude, longitude)
{
	var listString = getMapFromPGSQL(latitude, longitude);
	if (listString == null) return null;

	// todo construct map struture using utils functions
	var map = utils.CreateEmptyMap(++lastMapId, "mapName");
    for (var i = 0; i < listString.length; i++) 
    {
    	var way = utils.CreateEmptyWay("way" + i);
        for (var j = 0; j < listString[i].length; j++) 
    	{
    		if (listString[i][j] == null || listString[i][j].length != 2) return null;
        	var node = utils.CreateNode(++lastNodeId,
        		listString[i][j][0],listString[i][j][1]);
        	utils.AddNodeToMap(map, node);
        	utils.AddNodeIdToWay(way, lastNodeId);
    	}
    	utils.AddWayToMap(map, way);
    }



	
	var mapObj = utils.CreateFakeMap(); // todo delete

	return mapObj; // replace by map
}

exports.fullMapAccordingToLocalisation = fullMapAccordingToLocalisation