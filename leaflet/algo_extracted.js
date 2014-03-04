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

var Map = {
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
		console.log("Loading tile with point", tilePoint.z, tilePoint.x, tilePoint.y)
		return template(this._url, /*L.extend(*/{
			// s: this._getSubdomain(tilePoint),
			z: tilePoint.z,
			x: tilePoint.x,
			y: tilePoint.y
		}/*, this.options)*/);
	},

	tileSize: 256,

	compute_grid_of_urls: function (zoom, lat, long) {		
		var center = [lat, long]

		var viewHalf = this.getSize()._divideBy(2);
		// TODO round on display, not calculation to increase precision?
		var _initialTopLeftPoint = this.project(center, zoom)._subtract(viewHalf);
		console.log("_initialTopLeftPoint", _initialTopLeftPoint)

		var topLeftPoint = _initialTopLeftPoint;
		console.log("this.getSize", this.getSize())
		var bounds = new L.Bounds(topLeftPoint, topLeftPoint.add(this.getSize()));
		this.last_bounds = bounds // TODO: Remove that when we remove html_demo(), eventually
		console.log("bounds", bounds.min.x, bounds.min.y)

		var tileBounds = L.bounds(
		        bounds.min.divideBy(this.tileSize)._floor(),
		        bounds.max.divideBy(this.tileSize)._floor());

		console.log("tileBounds", tileBounds.min.x, tileBounds.min.y)

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
		return this.last_grid_of_urls
	},

	html_demo: function () {
		var zoom = parseInt(document.getElementById("zoom").value)
		var lat=parseFloat(document.getElementById("lat").value), long=parseFloat(document.getElementById("long").value)

		this.compute_grid_of_urls(zoom, lat, long)

		var d = document.getElementById("map2")
		d.innerHTML = ""
		var c = document.getElementById("calin")
		if (c) {
			c.parentNode.removeChild(c)
		};

		for (var i = 0; i < this.last_grid_of_urls.length; i++) {
			for (var j = 0; j < this.last_grid_of_urls[i].length; j++) {
				var img = document.createElement("img")
				img.src = this.last_grid_of_urls[i][j]
				img.width = 256
				img.height = 256
				img.style.border="1px solid black"
				img.style.margin="none"
				img.style.padding="none"
				d.appendChild(img)
			};
			d.appendChild(document.createElement("br"))
		};

		var delta = this.last_bounds.min.divideBy(this.tileSize)._subtract(this.last_bounds.min.divideBy(this.tileSize)._floor())
		var deltaY = delta.y
		var deltaX = delta.x

		// console.log(this.last_bounds.min.divideBy(this.tileSize))
		// console.log(this.last_bounds.min.divideBy(this.tileSize)._floor())
		// console.log(this.last_bounds.min.divideBy(this.tileSize)._subtract(this.last_bounds.min.divideBy(this.tileSize)._floor()))
		// console.log("dx, dy", (this.last_bounds.min.x - tileBounds.min.x*this.tileSize), (this.last_bounds.min.y - tileBounds.min.y*this.tileSize))
		console.log("rx, ry", deltaX, deltaY)
		var e = document.createElement("div")
		e.id="calin"
		e.style.border = "2px solid red"
		e.style.position = "absolute"
		e.style.height = this.clientHeight + "px"
		e.style.width = this.clientWidth + "px"
		console.log(this.tileSize/2)
		// console.log("top=", top)
		// console.log("left=", left)
		e.style.left = deltaX*this.tileSize + "px"
		e.style.top = deltaY*this.tileSize + "px"
		e.style.background = "red"
		e.style.opacity = "0.3"
		console.log(e)
		document.getElementsByTagName("body")[0].appendChild(e)
	}
}