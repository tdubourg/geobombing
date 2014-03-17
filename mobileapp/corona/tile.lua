require "utils"
require "consts"

local tempFileIndex = 0

Tile = {}
function Tile:new(url, tileBackground)
	local self = {}
	setmetatable(self, { __index = Tile })  -- Inheritance
	local i = url[1]
	local j = url[2]
	local z = url[3]
	self.url = url[4]
	dbg(T, {"i,j,z,self.url=", i, j, z, self.url})
	self.tileBackground = tileBackground
	-- dbg(T, {"TBG=", tileBackground})
	self.image = nil

	local loadCompleteListener = 
	function(event)
		dbg(T, { "In event listener!"})
		if (event.phase ~= "ended") then
			dbg(T, {"Handler called but not finished yet"})
			return
		end
		if ( event.isError or event.target == nil) then
			dbg (ERRORS, "Failed loading tile " .. self.url)
		else
			dbg(T, {"Everything went smooth..."})
			self:setImage(event.target)
		end
	end

	local filename = z .. "-" .. i .. "-" .. j .. ".png"

	dbg(T, {"filename=", filename})
	dbg(T, {"system.ResourceDirectory=", system.ResourceDirectory})
	dbg(T, {"system.TemporaryDirectory=", system.TemporaryDirectory})
	dbg(T, {"system.DocumentsDirectory=", tostring(system.DocumentsDirectory)})
	
	if (fileExists(filename, system.DocumentsDirectory)) then
		dbg(T, {"The file exists!", system.pathForFile( fileName, system.DocumentsDirectory )})
		self:setImage(display.newImage(filename, system.DocumentsDirectory, -10000, -10000))
	else
		dbg(T, {"The file DOES NOT exists!"})
		display.loadRemoteImage( self.url , "GET", loadCompleteListener, filename, system.DocumentsDirectory, -10000, -10000 )
		tempFileIndex = tempFileIndex +1		
	end

	return self
end

function Tile:setImage(img, redraw)
	dbg(T, {"Setttimg image to", tostring(img)})
	self.image = img
	self.image.anchorX = 0
	self.image.anchorY = 0
	tileLayer:insert(self.image)
	self.tileBackground:redraw(true)
end

function Tile:setScreenSize(width,height)
	if self.image then
		self.image.xScale = width/self.image.width
		self.image.yScale = height/self.image.height
	end
end

function Tile:destroy()
	if self.image then self.image:removeSelf( ) end
end