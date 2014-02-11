
"use strict"
var clMap = require("./Classes/clMap").clMap; 
var utils = require("./common"); 
var qh = require('./query_helper'); // for generic query
var lastMapId = 1;
var lastNodeId = 1;

function getMapFromPGSQL(latitude, longitude, hauteur, largeur, callback)
{
	var query = "	\
		SELECT ST_asText(ST_GeometryN(r.geom,1))	\
		from roads as r,				\
			ST_MakeBox2D (				\
				ST_Point("+(longitude-largeur)+", "+(latitude-hauteur)+"), ST_Point("+(longitude+largeur)+", "+(latitude+hauteur)+")	\
			) as box					\
		WHERE ST_Intersects(r.geom, box) and exists (	\
		  select r						\
		  from (						\
		    select pp.geom as p			\
		    from ST_DumpPoints(r.geom) as pp	\
		  ) as foo						\
		  where ST_Contains (			\
		    box, p						\
		  )								\
		)								\
		;								\
	"
	qh.text_query ( query, function(err, rez) {
		
		var SHIFTX = 8.73, SHIFTY = 41.92, COEFF = 50000  // FIXME: not the right place!!
		
		var roads = []
		rez.rows.forEach(function (r) {
			var pts = []
			r.st_astext.replace("LINESTRING(","").replace(")","").split(",").forEach(function(e) {
				var coords = e.split(" ")
				pts.push( [parseFloat((coords[0]-SHIFTX)*COEFF), parseFloat((coords[1]-SHIFTY)*COEFF)] )
			})
			roads.push(pts)
		})
		console.log(roads)
		
		callback(err, roads);
	});
	
	// todo replace by select_query();
	/*return [[
	["8.7369691", "41.9198811"], ["8.7368306", "41.9191348"], 
	["8.7369374", "41.9186287"]],
			[["8.7347978", "41.919762"], ["8.7353263", "41.9198519"]]];
			*/
}

function fullMapAccordingToLocation(latitude, longitude, callback)
{
	var s = 0.0001
	// TODO use latitude, longitude
	getMapFromPGSQL(41.9205551, 8.7361006, s, s, function(err,listString)
	//getMapFromPGSQL(latitude, longitude, s, s, function(err,rez) 
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
