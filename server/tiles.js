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
	_url: "http://tdvps.fr.nf:8080/osm_tiles/{z}/{x}/{y}.png",

	project: function (latlng, zoom) { // (LatLng[, Number]) -> Point
		zoom = zoom === undefined ? this._zoom : zoom;
		return this.crs.latLngToPoint(L.latLng(latlng), zoom);
	},
	unproject: function (point, zoom) { // (Point[, Number]) -> LatLng
		zoom = zoom === undefined ? this._zoom : zoom;
		return this.crs.pointToLatLng(L.point(point), zoom);
	},
	getSize: function () {
		if (!this._size || this._sizeChanged) {
			this._size = new L.Point(
				this.clientWidth,
				this.clientHeight);

			this._sizeChanged = false;
		}
		return this._size.clone();
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

	tileSize: 256,

	compute_grid_of_urls: function (zoom, lat, long) 
	{		
		var center = [lat, long]
		var viewHalf = this.getSize()._divideBy(2);
		// TODO round on display, not calculation to increase precision?
		var _initialTopLeftPoint = this.project(center, zoom)._subtract(viewHalf);
		console.log("_initialTopLeftPoint", _initialTopLeftPoint)

		var topLeftPoint = _initialTopLeftPoint;
		//console.log("this.getSize", this.getSize())
		var bounds = new L.Bounds(topLeftPoint, topLeftPoint.add(this.getSize()));
		console.log("bounds", bounds.min.x, bounds.min.y)

		var tileBounds = L.bounds(
		        bounds.min.divideBy(this.tileSize)._floor(),
		        bounds.max.divideBy(this.tileSize)._floor());

		//console.log("tileBounds", tileBounds.min.x, tileBounds.min.y)
		console.log("##############################exported_bounds#####################", tileBounds)
		var i,j,point
		var grid = []
		for (j = tileBounds.min.y; j < tileBounds.max.y + 1; j++) {
			var grid_line = []
			for (i = tileBounds.min.x; i < tileBounds.max.x + 1; i++) {
				point = new L.Point(i, j);
				point.z = zoom
				grid_line.push(this.getTileUrl(point))
			}
			grid.push(grid_line)
		}
		this.last_grid_of_urls = grid
		return {'grid': this.last_grid_of_urls, 'topLeftPoint': {'x': topLeftPoint.x, 'y': topLeftPoint.y}}
	},
}
exports.MapTiles = MapTiles

