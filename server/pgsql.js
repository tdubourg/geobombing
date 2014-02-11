
"use strict"
var clMap = require("./Classes/clMap").clMap; 
var utils = require("./common"); 
//var qh = require('./query_helper'); // for generic query
var lastMapId = 1;
var lastNodeId = 1;

function getMapFromPGSQL()
{
	//var queryResult = qh.text_query(""); // todo replace by select_query();
	return [[
	["8.7369691", "41.9198811"], ["8.7368306", "41.9191348"], 
	["8.7369374", "41.9186287"]],
			[["8.7347978", "41.919762"], ["8.7353263", "41.9198519"]]];
}

function fullMapAccordingToLocalisation(latitude, longitude)
{
	var listString = getMapFromPGSQL();
	if (listString == null) return null;

	// todo construct map struture using utils functions
	var map = utils.CreateEmptyMap(++lastMapId, "mapName");
    for (var i = 0; i < listString.length; i++) 
    {
    	var way = utils.CreateEmptyWay("way" + i);
        for (var j = 0; j < listString[i].length; j++) 
    	{

        	var node = utils.CreateNode(++lastNodeId,0,0);
    	}
    }



	
	var mapObj = utils.CreateFakeMap(); // todo delete

	return mapObj; // replace by map
}

exports.fullMapAccordingToLocalisation = fullMapAccordingToLocalisation