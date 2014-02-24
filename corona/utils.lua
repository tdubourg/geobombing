-- table.indexOf( array, object ) returns the index
-- of object in array. Returns 'nil' if not in array.
table.indexOf = function( t, object )
	local result
	if "table" == type( t ) then
		for i=1,#t do
			if object == t[i] then
				result = i
				break
			end
		end
	end

	return result
end

-- return a new array containing the concatenation of all of its 
-- parameters. Scaler parameters are included in place, and array 
-- parameters have their values shallow-copied to the final array.
-- Note that userdata and function values are treated as scalar.
function array_concat(...) 
    local t = {}
    for n = 1,select("#",...) do
        local arg = select(n,...)
        if type(arg)=="table" then
            for _,v in ipairs(arg) do
                t[#t+1] = v
            end
        else
            t[#t+1] = arg
        end
    end
    return t
end


function array_insert(receivingArray, insertedArray)
	for _,v in ipairs(insertedArray) do
		receivingArray[#receivingArray+1] = v
	end
	return receivingArray
end