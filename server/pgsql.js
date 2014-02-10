
"use strict"
var clMap = require("./classes/clMap").clMap; 
var utils = require("./common"); 
//var qh = require('./query_helper'); // for generic query
var lastMapId = 1;
var lastNodeId = 1;

function getMapFromPGSQL()
{
	//var queryResult = qh.text_query(""); // todo replace by select_query();
	return ["", 
			"", 
			"", 
			"", 
			"", 
			"", 
			""];
}

function fullMapAccordingToLocalisation(latitude, longitude)
{
	var listString = getMapFromPGSQL();

	// todo construct map struture using utils functions
	var map = utils.CreateEmptyMap(++lastMapId, "mapName");

	
	var mapObj = utils.CreateFakeMap(); // todo delete

	return mapObj; // replace by map
}

exports.fullMapAccordingToLocalisation = fullMapAccordingToLocalisation