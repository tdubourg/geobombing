"use strict"

var pg = require('pg');
var conString = "postgres://postgres:quepasa@localhost/postgres" // todo modify

var client = new pg.Client(conString)

client.connect()

var DBG = true

var text_query = function (query, callback) {
	if (DBG) {
		console.log("DB::Issuing query:", query)
	};
	client.query(query, [], callback)
}

var insert_query = function (table_name, columns, values, callback) {
	var values_params = ""
	var comma = ''
	for (var i = 0; i < values.length; i++) {
		values_params += comma + "$" + (i+1)
		comma = ', '
	};
	var query_str = "INSERT INTO " + table_name + " (" + columns.join(", ") + ") VALUES (" + values_params + ")"
	if (DBG) {
		console.log("DB::Issuing query:", query_str, "with values", values)
	};
	client.query(query_str, values , callback)
}

var select_query = function (table_name, columns, columns_where, values_where, operator_where, callback, addition_to_query_str) {
	var where_clause = ""
	if (typeof columns_where != "undefined" && typeof values_where != "undefined" && columns_where && values_where) {
		where_clause =" WHERE (" + get_where_clause(columns_where, values_where, 1, operator_where) + ")" 
	}

	var query_str = "SELECT " + columns.join(", ") + " FROM " + table_name + where_clause
	if (addition_to_query_str) {
		query_str += " " + addition_to_query_str;
	};
	if (DBG) {
		console.log("DB::Issuing query:", query_str, "with values", values_where)
	};
	client.query(query_str, values_where , callback)
}

var update_query = function (table_name, columns, values, columns_where, values_where, operator_where, callback) {
	var values_params = []
	var comma = ''
	for (var i = 0; i < columns.length; i++) {
		values_params += comma + columns[i] + "=$" + (i+1)
		comma = ', '
	};
	var where_clause = ""
	if (typeof columns_where != "undefined" && typeof values_where != "undefined" && columns_where && values_where) {
		where_clause =" WHERE (" + get_where_clause(columns_where, values_where, values.length+1, operator_where) + ")" 
	}
	var query_str = "UPDATE " + table_name + " SET " + values_params + where_clause
	values = values.concat(values_where)
	console.log("Issuing query ", query_str, "with values", values)
	client.query(query_str, values , callback)
}

var delete_query = function (table_name, columns, values, operator, callback) {
	var values_params = get_where_clause(columns, values, operator)
	client.query("DELETE FROM " + table_name + " WHERE " + values_params, values , callback)
}

var get_where_clause = function (columns, values, start_index, operator) {
	var values_params = ""
	if (typeof operator == "undefined" || !operator) {
		var operator = " AND "
	} else {
		operator = " " + operator + " "
	}
	var comma = ''
	for (var i = 0; i < values.length; i++) {
		values_params += comma + columns[i] + "=$" + (i+start_index)
		comma = operator
	};
	return values_params
}


exports.insert_query = insert_query
exports.update_query = update_query
exports.delete_query = delete_query
exports.select_query = select_query
exports.text_query = text_query