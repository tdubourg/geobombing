local json = require "json"
local socket = require "socket"

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

-- local last_print = 0
-- _G.print = function ( ... )
-- 	if (now() - last_print < 3000) then
-- 		return
-- 	end
-- 	last_print = now()
-- 	io.write( "Utiliser la fonction print tue des chatons, je vais utiliser dbg(const, {arg1, arg2, arg3} a la place.\n")
-- 	io.write( "Ce message ne s'affiche qu'une fois par 3 secondes.\n")
-- end

function array_insert(receivingArray, insertedArray)
	for _,v in ipairs(insertedArray) do
		receivingArray[#receivingArray+1] = v
	end
	return receivingArray
end

function silent_fail_require(module_name)
    local function requiref(module_name)
        require(module_name)
    end
    local res = pcall(requiref,module_name)
    return res
end

function dbg( mode, things )
	if (mode) then
		dbg_write(now(), "\t")
		for _,v in pairs(things) do
			if (type(v) == "table") then
				v = json.encode(v)
			else
				v = tostring(v)
			end
			dbg_write(v, "\t")
		end
		dbg_write("\n")
	end
end

local dbg_file = nil

function dbg_write( ... )
	if(LOG_TO_FILE) then
		if (dbg_file == nil) then
			local path = system.pathForFile(LOG_TO_FILE, system.DocumentsDirectory )
			io.write( "path\t", tostring(path), "\n")
			dbg_file = io.open( path, "w" )
			io.write( "dbg_file==nil\t", tostring(dbg_file==nil), "\n")
		end
		dbg_file:write( ... )
	else
		io.write( ... )
	end
end

local colors = {
	[1] = {255,0,0},
	[2] = {0,255,0},
	[3] = {0,0,255},
	[4] = {255,0,195},
	[5] = {162,0,255},
	[6] = {0,221,255},
	[7] = {234,255,0},
	[8] = {255,149,0},
	[9] = {255,255,255},
	[10] = {0,0,0},
}

function idToColor(pid)
	-- old method based on random + seeding
	-----------------------------------------------
	-- math.randomseed(pid)
	-- local r = math.random()
	-- local g = math.random()
	-- local b = math.random()
	-- math.randomseed(os.time())

	-- local total = r+g+b

	-- r = r*255/total
	-- g = g*255/total
	-- b = b*255/total
	-----------------------------------------------
	return colors[pid%(#colors)]
end

-- Returns the timestamp in milliseconds 
-- That is to say the number of milliseconds since the 01/01/1970
function now()
	return socket.gettime()*1000
end


function fileExists(fileName, base)
  assert(fileName, "fileName is missing")
  local base = base or system.ResourceDirectory
  local filePath = system.pathForFile( fileName, base )
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end