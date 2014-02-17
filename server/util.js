
function apply(f, arr) { return f.apply(null, arr) }
function min(arr) { return apply(Math.min, arr) }
function max(arr) { return apply(Math.max, arr) }
function flatten(arrays) {
	var merged = []
	merged = merged.concat.apply(merged, arrays)
	return merged
}
exports.apply = apply
exports.min = min
exports.max = max
exports.flatten = flatten

/*
exps = {
	apply: function(f, arr) { return f.apply(null, arr) },
	min: function(arr) { return apply(Math.min, arr) },
	max: function(arr) { return apply(Math.max, arr) },
	flatten: function(arrays) {
		var merged = []
		merged = merged.concat.apply(merged, arrays)
		return merged
	},
}
for (e in exps) exports[e] = exps[e]
*/
/*
exports.apply = function(f, arr) { return f.apply(null, arr) }  // apply(f,[1,2,3]) executes f(1,2,3)
exports.min = function(arr) { return apply(Math.min, arr) }
exports.max = function(arr) { return apply(Math.max, arr) }
exports.flatten = function(arrays) {
	var merged = []
	merged = merged.concat.apply(merged, arrays)
	return merged
}
*/

