
"use strict"
var clMap = require("./Classes/clMap").clMap; 
var common = require("./common");
var conDB = false;
var qh = conDB? require('./query_helper'): null; // for generic query
var lastMapId = 1;
var lastNodeId = 1;
var u = require("./util")


function getMapFromPGSQL(latitude, longitude, hauteur, largeur, callback) {
	// from now on "hauteur" refers to hauteur/2 :-P
	hauteur /= 2
	largeur /= 2
	
	//////////////////////////////////
	// FIXME !! (méthode agile)
	//latitude = 4.8730; longitude = 45.7816
	latitude = 45.7816; longitude = 4.8730
	//latitude = 41.9205551; longitude = 8.7361006
	
	//////////////////////////////////
	
	if (!conDB) {
		callback(null, autoScaleMap(
			[[[0, 0], [0, 200], [100, 100], [100, 200]], 
			[[0, 0], [100, 200], [150, 250], [500, 250]]]));
		return;
	}
	
	console.log("Loading map from: " + latitude + ", " + hauteur)
	
	var query = "	\n\
		SELECT ST_asText(ST_GeometryN(r.geom,1))	\n\
		from roads as r,				\n\
			ST_MakeBox2D (				\n\
				ST_Point("+(longitude-largeur)+", "+(latitude-hauteur)+"), ST_Point("+(longitude+largeur)+", "+(latitude+hauteur)+")	\n\
			) as box					\n\
		WHERE ST_Intersects(r.geom, box) and exists (	\n\
		  select r						\n\
		  from (						\n\
		    select pp.geom as p			\n\
		    from ST_DumpPoints(r.geom) as pp	\n\
		  ) as foo						\n\
		  where ST_Contains (			\n\
		    box, p						\n\
		  )								\n\
		);								\n\
	"
	qh.text_query ( query, function(err, rez) {
		
		if (err) {
			console.log(err)
			throw "SQL ERROR"
		}
		
		//var SHIFTX = 8.73, SHIFTY = 41.92, COEFF = 50000  // FIXME: not the right place!!
		var SHIFTX = 0, SHIFTY = 0, COEFF = 1
		
		var roads = []
		rez.rows.forEach(function (r) {
			var pts = []
			r.st_astext.replace("LINESTRING(","").replace(")","").split(",").forEach(function(e) {
				var coords = e.split(" ")
				pts.push( [parseFloat((coords[0]-SHIFTX)*COEFF), parseFloat((coords[1]-SHIFTY)*COEFF)] )
			})
			roads.push(pts)
		})
		//console.log(roads)
		console.log("Number of roads loaded: " + roads.length)
		
		callback(err, autoScaleMap(trimMap(roads, latitude, longitude, hauteur, largeur)));
		
	});
	
	// todo replace by select_query();
	
}

// removes points lying outside the selection box
function trimMap(leMap, latitude, longitude, hauteur, largeur) {
	
	//////////////////////////////////
	//return leMap // FIXME !!
	//////////////////////////////////
	
	var total = 0, trimmed = 0
	for (var i = 0; i < leMap.length; i++)
	for (var j = 0; j < leMap[i].length; j++) {
		total++
		if ( leMap[i][j][0] < longitude-largeur || leMap[i][j][0] > longitude+largeur
		  && leMap[i][j][1] < latitude-hauteur  || leMap[i][j][1] > latitude+hauteur
		) {
			trimmed++
			leMap[i].splice(j, 1)
			j--
		}
	}
	console.log("Trimmed "+trimmed+" outlying points "+"("+total+" total)")
	return leMap
}

function autoScaleMap(leMap) {
	
	//////////////////////////////////
	//return leMap // FIXME !!
	//////////////////////////////////
	
	function extr(coord,coeff) {
		return u.min( u.flatten( leMap.map(function(r){ return r.map(function(p){return p[coord]*coeff}) }) ) )
	}
	var minX =  extr(0,  1),
	    maxX = -extr(0, -1),
	    minY =  extr(1,  1),
	    maxY = -extr(1, -1),
	    
	    shiftX = minX,
	    shiftY = minY,
	    coeff = 1/(maxY-minY) // or use coord X
	
	//////////////////////////////////
	//coeff = 1; //50000; // FIXME
	//////////////////////////////////
	
	leMap.forEach(function(road) {
		road.forEach(function(p) {
			//console.log(p[0])
			p[0] = (p[0]-shiftX)*coeff
			p[1] = (p[1]-shiftY)*coeff
		})
	})
	
	return leMap
}

function mapDataToJSon(mapData) {
	var map = common.CreateEmptyMap(++lastMapId, "mapName");
    for (var i = 0; i < mapData.length; i++) 
    {
    	var way = common.CreateEmptyWay("way" + i);
        for (var j = 0; j < mapData[i].length; j++) 
    	{
    		if (mapData[i][j] == null || mapData[i][j].length != 2) return null;
        	var node = common.CreateNode(++lastNodeId,
        		mapData[i][j][0],mapData[i][j][1]);
        	common.AddNodeToMap(map, node);
        	common.AddNodeIdToWay(way, lastNodeId);
    	}
    	common.AddWayToMap(map, way);
    }
    return map
}
exports.mapDataToJSon = mapDataToJSon

function fullMapAccordingToLocation(latitude, longitude, callback) {
	//var s = 0.0001
	//var s = 0.003
	var s = 0.01
	
	// TODO use latitude, longitude
	//getMapFromPGSQL(41.9205551, 8.7361006, s, s, function(err,listString)
	getMapFromPGSQL(latitude, longitude, s, s, function(err,mapData)
	//getMapFromPGSQL(latitude, longitude, s, s, function(err,rez) 
	{
		/*
		// construct map struture using common functions
		var map = common.CreateEmptyMap(++lastMapId, "mapName");
	    for (var i = 0; i < listString.length; i++) 
	    {
	    	var way = common.CreateEmptyWay("way" + i);
	        for (var j = 0; j < listString[i].length; j++) 
	    	{
	    		if (listString[i][j] == null || listString[i][j].length != 2) return null;
	        	var node = common.CreateNode(++lastNodeId,
	        		listString[i][j][0],listString[i][j][1]);
	        	common.AddNodeToMap(map, node);
	        	common.AddNodeIdToWay(way, lastNodeId);
	    	}
	    	common.AddWayToMap(map, way);
	    }
	    */
		//callback({jsonMap: map, mapData: listString})
		callback(mapData)
	});
}
exports.fullMapAccordingToLocation = fullMapAccordingToLocation
