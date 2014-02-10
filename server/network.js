"use strict"

// Utils for network
var FRAME_SEPARATOR = "\n"

var decode_frame = function (frame_string) {
	return {type: "dummy", data: "frame_string"} //TODO implement that
}

// provides "attributes" and "methods" for the "class" shared_data.js
exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
