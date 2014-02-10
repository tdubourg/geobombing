
cameraGroup = nil

function initCamera()
	cameraGroup = display.newGroup()
end

-- function Camera:new()  -- The constructor
--   local object = {}

--   setmetatable(object, { __index = Camera })  -- Inheritance
--   return object
-- end

-- function Camera:getSingleton()   -- Another member function
--   if instance==nil then
-- 	instance = Camera:new()
--   end
--   return instance
-- end