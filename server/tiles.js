"use strict"
// From algo_extracted.js (openstreetmap)
var L = require("./leaflet_node");

var template = function (str, data) {
	return str.replace(/\{ *([\w_]+) *\}/g, function (str, key) {
		var value = data[key];
		if (value === undefined) {
			throw new Error('No value provided for variable ' + str);
		} else if (typeof value === 'function') {
			value = value(data);
		}
		return value;
	});
}

var MapTiles = 
{
	crs: L.CRS.EPSG3857,
	clientWidth: 512,
	clientHeight: 512,
	_url: "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
	// _url: "http://tdvps.fr.nf:8080/osm_tiles/{z}/{x}/{y}.png",

	project: function (latlng, zoom) { // (LatLng[, Number]) -> Point
		zoom = zoom === undefined ? this.zoom : zoom;
		return this.crs.latLngToPoint(L.latLng(latlng), zoom);
	},
	unproject: function (point, zoom) { // (Point[, Number]) -> LatLng
		zoom = zoom === undefined ? this.zoom : zoom;
		return this.crs.pointToLatLng(L.point(point), zoom);
	},
	getTileUrl: function (tilePoint) {
		//console.log("Loading tile with point", tilePoint.z, tilePoint.x, tilePoint.y)
		return template(this._url, /*L.extend(*/{
			// s: this._getSubdomain(tilePoint),
			z: tilePoint.z,
			x: tilePoint.x,
			y: tilePoint.y
		}/*, this.options)*/);
	},

	setGPSWindow: function (gps_top_left, gps_bottom_right, zoom) {
		this.zoom = zoom + 7 // TODO CHANGE THAT AS SOON AS THE ZOOM VALUE IS FIXED
		gps_top_left = L.latLng(gps_top_left.lat, gps_top_left.lng)
		gps_bottom_right = L.latLng(gps_bottom_right.lat, gps_bottom_right.lng)
		this.topLeftPoint = this.project(gps_top_left, this.zoom)
		this.bottomRightPoint = this.project(gps_bottom_right, this.zoom)
		this.sessionMapBounds = L.bounds(this.topLeftPoint, this.bottomRightPoint)
	},

	tileSize: 256,

	compute_grid_of_urls: function (lat, long) 
	{	
		var bounds = new L.Bounds(this.topLeftPoint, this.bottomRightPoint);
		console.log("bounds", bounds.min.x, bounds.min.y)

		var tileBounds = L.bounds(
		        bounds.min.divideBy(this.tileSize)._floor(),
		        bounds.max.divideBy(this.tileSize)._floor());

		//console.log("tileBounds", tileBounds.min.x, tileBounds.min.y)
		//console.log("##############################exported_bounds#####################", tileBounds)
		var i,j,point
		var grid = []
		for (j = tileBounds.min.y; j < tileBounds.max.y + 1; j++) {
			var grid_line = []
			for (i = tileBounds.min.x; i < tileBounds.max.x + 1; i++) {
				point = new L.Point(i, j);
				point.z = this.zoom
				grid_line.push(this.getTileUrl(point))
			}
			grid.push(grid_line)
		}
		this.last_grid_of_urls = grid
		var result = {
			'grid': this.last_grid_of_urls,
			'sessionMapTopLeftPoint': {'x': this.sessionMapBounds.min.x, 'y': this.sessionMapBounds.min.y},
			'sessionMapBottomRightPoint': {'x': this.sessionMapBounds.max.x, 'y': this.sessionMapBounds.max.y},
			'tilesTopLeftPoint': {'x': tileBounds.min.x * this.tileSize, 'y': tileBounds.min.y * this.tileSize},
			'tilesBottomRightPoint': {'x': (tileBounds.max.x + 1) * this.tileSize, 'y': (tileBounds.max.y + 1) * this.tileSize}
		}
		//console.log(result) // TODO: Remove that when debug is done :) 
		return result
	},
}
exports.MapTiles = MapTiles

