
"use strict"
var clMap = require("./Classes/clMap").clMap; 
var utils = require("./common"); 
var conDB = false
var qh = conDB? require('./query_helper'):null; // for generic query
var lastMapId = 1;
var lastNodeId = 1;

function getMapFromPGSQL(latitude, longitude, hauteur, largeur, callback)
{
	// todo replace by select_query();
	if (!conDB) {
		callback([[
	["8.7369691", "41.9198811"], ["8.7368306", "41.9191348"], 
	["8.7369374", "41.9186287"]],
			[["8.7347978", "41.919762"], ["8.7353263", "41.9198519"]]]);
		return;
	}
	qh.text_query("SELECT ST_asText(box), r.*		
		from roads as r,				
			ST_MakeBox2D (				
				ST_Point("+(longitude-largeur)+", "+(latitude-hauteur)+"), ST_Point("+(longitude+largeur)+", "+(latitude+hauteur)+")	
			) as box					
		--WHERE ST_Crosses(r.geom, box) and exists (	
		WHERE ST_Intersects(r.geom, box) and exists (	
		  select r						
		  from (						
		    select pp.geom as p			
		    from ST_DumpPoints(r.geom) as pp	
		  ) as foo						
		  where ST_Contains (			
		    box, p						
		  )								
		)								
		;								
	", callback); // pass in parameter the function which will send the map
	

}

function fullMapAccordingToLocation(latitude, longitude, callback)
{
	var s = 0.0001
	getMapFromPGSQL(latitude, longitude, s, s, function(err,rez) 
	{
		// construct map struture using utils functions
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
		callback(map)
	});
}

exports.fullMapAccordingToLocation = fullMapAccordingToLocation