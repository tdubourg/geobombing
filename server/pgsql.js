
"use strict"
var clMap = require("./Classes/clMap").clMap
var common = require("./common")
var qh = require('./query_helper')
var lastMapId = 1
var lastNodeId = 1
var u = require("./util")
var t = require("./tiles")
var consts = require("./constants")

function getMapFromPGSQL(latitude, longitude, hauteur, largeur, callback) {
	// from now on "hauteur" refers to hauteur/2 :-P
	hauteur /= 2
	largeur /= 2

	latitude = 45.7816; 
	longitude = 4.8730
	console.log("Loading map from: " + latitude + ", " + longitude)

	var topLeft = {'lat': latitude-hauteur, 'lng': longitude-largeur}
	var bottomRight = {'lat': latitude+hauteur, 'lng': longitude+largeur}

	t.MapTiles.setGPSWindow(
		topLeft,
		bottomRight,
		consts.ZOOM_OF_GPS_MAP_SESSION
	)
	
	var query = "	\n\
		SELECT ST_asText(ST_GeometryN(r.the_geom,1)), r.name	\n\
		from shp_roads as r,				\n\
			ST_MakeBox2D (				\n\
				ST_Point("+topLeft.lng+", "+topLeft.lat+"), ST_Point("+bottomRight.lng+", "+bottomRight.lat+")	\n\
			) as box					\n\
		WHERE ST_Intersects(r.the_geom, box) and exists (	\n\
		  select r						\n\
		  from (						\n\
		    select pp.geom as p			\n\
		    from ST_DumpPoints(r.the_geom) as pp	\n\
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
		var road_names = []
		rez.rows.forEach(function (r) {
			var pts = []
			r.st_astext.replace("LINESTRING(","").replace(")","").split(",").forEach(function(e) {
				var coords = e.split(" ")
				pts.push( [parseFloat((coords[0]-SHIFTX)*COEFF), parseFloat((coords[1]-SHIFTY)*COEFF)] )
			})
			roads.push(pts)
			road_names.push(r.name)
		})
		roads.roadNames = road_names
		//console.log(rez)
		console.log("Number of roads loaded: " + roads.length)
		
		// callback(err,
		// 	projectMap(
		// 		autoScaleMap(
		// 			trimMap(roads, latitude, longitude, hauteur, largeur)
		// 	))
		// );
		
		var map = roads
		//trimMap(map, latitude, longitude, hauteur, largeur)
		projectMap(map)
		// autoScaleMap(map)
		scaleMap(map)
		// console.log(map)
		
		callback(err, map)
		
	});
	
	// todo replace by select_query();
	
}

function projectMap (leMap)
{
	for (var i = 0; i < leMap.length; i++)
		for (var j = 0; j < leMap[i].length; j++) 
		{
			var pt = t.MapTiles.project({lat: leMap[i][j][1], lng: leMap[i][j][0]})
			leMap[i][j] = [pt.x, pt.y]
		}
	//console.log(leMap)
	return leMap
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
		  || leMap[i][j][1] < latitude-hauteur  || leMap[i][j][1] > latitude+hauteur
		) {
			trimmed++
			leMap[i].splice(j, 1)
			j--
		}
	}
	console.log("Trimmed "+trimmed+" outlying points "+"("+total+" total)")
	return leMap
}

// function scaleMap(leMap,hauteur,largeur)
function scaleMap (leMap) //, topLeft, bottomRight)
{
	// var topLeft = t.MapTiles.topLeftPoint,
	//     bottomRight = t.MapTiles.bottomRightPoint,
	    
	//     shiftX = topLeft.x,
	//     shiftY = topLeft.y,
	//     coeffX = 1/Math.abs(bottomRight.x-topLeft.x),
	//     coeffY = 1/Math.abs(bottomRight.y-topLeft.y)
	var
	    shiftX = t.MapTiles.sessionMapBounds.min.x,
	    shiftY = t.MapTiles.sessionMapBounds.min.y,
	    coeffX = 1/(t.MapTiles.sessionMapBounds.max.x-t.MapTiles.sessionMapBounds.min.x),
	    coeffY = 1/(t.MapTiles.sessionMapBounds.max.y-t.MapTiles.sessionMapBounds.min.y)
	
	
	// console.log(shiftX,shiftY)
	// console.log(coeffX,coeffY)
	var trimmed = 0, total = 0
	// leMap.forEach(function(road) {
	// 	road.forEach(function(p) {
			
	// 		if (p[0] < t.MapTiles.sessionMapBounds.min.x
	// 			|| p[0] > t.MapTiles.sessionMapBounds.max.x)
	// 			// console.log("LOOOOL!!")
	// 			out++
			
	// 		p[0] = (p[0]-shiftX)*coeffX
	// 		p[1] = (p[1]-shiftY)*coeffY
	// 	})
	// })
	
	for (var i = 0; i < leMap.length; i++)
	for (var j = 0; j < leMap[i].length; j++) 
	{
		total++
		var p = leMap[i][j]
		if (p[0] < t.MapTiles.sessionMapBounds.min.x
		 || p[0] > t.MapTiles.sessionMapBounds.max.x
		 || p[1] < t.MapTiles.sessionMapBounds.min.y
		 || p[1] > t.MapTiles.sessionMapBounds.max.y) 
		{
			trimmed++
			leMap[i].splice(j, 1)
			j--
			// p[0] = 10
			// p[1] = 0
		} 
		else 
		{
			p[0] = (p[0]-shiftX)*coeffX
			p[1] = (p[1]-shiftY)*coeffY
		}
	}
	
	// if (out > 0)
	// 	console.log("Warning: outlying points:", out)
	
	console.log("Removed "+trimmed+" outlying points out of "+total)
	
	// FIXME: in practice this could produce empty roads if all
	// points of the road lie out of the bounds
	
	return leMap
}

function autoScaleMap(leMap) 
{
	
	//////////////////////////////////
	//return leMap // FIXME !!
	//////////////////////////////////
	
	function extr(coord,coeff) 
	{
		return u.min( u.flatten( leMap.map(function(r)
			{ return r.map(function(p)
				{return p[coord]*coeff}) 
		}) ) )
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
			// p[0] = (p[0]-shiftX)*coeffX
			// p[1] = (p[1]-shiftY)*coeffY
		})
	})
	
	leMap.shiftX = shiftX
	leMap.shiftY = shiftY
	leMap.scale = coeff
	// leMap.scaleX = coeffX
	// leMap.scaleY = coeffY
	
	return leMap
}

function mapDataToJSon(mapData) 
{
	var map = common.CreateEmptyMap(++lastMapId, "mapDummy");
	var nodes_dic = {}
    for (var i = 0; i < mapData.length; i++) 
    {
    	var wayName = (mapData.roadNames[i] == null)?"Road " + i: mapData.roadNames[i]
    	var way = common.CreateEmptyWay(wayName);
        for (var j = 0; j < mapData[i].length; j++)
    	{
    		var node
    		if (nodes_dic[mapData[i][j]] == undefined)
    		{
    			var id = lastNodeId++
        		node = common.CreateNode(id, mapData[i][j][0], mapData[i][j][1]);
        		nodes_dic[mapData[i][j]] = node;
        		common.AddNodeToMap(map, node);
        	}
        	else node = nodes_dic[mapData[i][j]]  		
        	
        	common.AddNodeIdToWay(way, node.id);
    	}
    	common.AddWayToMap(map, way);
    }
    map.shiftX = mapData.shiftX
    map.shiftY = mapData.shiftY
    map.scale  = mapData.scale
    
    //console.log("Map scale:",mapData.scale,"shifts:",mapData.shiftX,mapData.shiftY)
    
    return map
}



// function getInitialPosition() 
// {	
// 	var x = Math.floor((Math.random()*3)+1)
//  	var y = x + 1
//  	var z = Math.random() 
//     return common.CreatePosition(x, y, z);
// }



function fullMapAccordingToLocation(latitude, longitude, callback) 
{
	getMapFromPGSQL(
		latitude,
		longitude,
		consts.HEIGHT_OF_GPS_MAP_SESSION,
		consts.WIDTH_OF_GPS_MAP_SESSION,
		function(err, mapData, roadNames) 
		{
			callback(mapData, //getInitialPosition(), 
				getMapTiles(latitude, longitude, consts.ZOOM_OF_GPS_MAP_SESSION))
		}
	);
}

function getMapTiles(latitude, longitude, zoom) 
{
	return t.MapTiles.compute_grid_of_urls(latitude, longitude)
}

exports.mapDataToJSon = mapDataToJSon
// exports.getInitialPosition = getInitialPosition
exports.fullMapAccordingToLocation = fullMapAccordingToLocation
