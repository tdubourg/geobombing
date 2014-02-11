Map = {}                   -- Create a table to hold the class methods
function Map:new(luaMap)  -- The constructor
  local object = {}
  object.nodesByUID = {}
 
  setmetatable(object, { __index = Map })  -- Inheritance

  if luaMap then
    local mapName = luaMap[JSON_MAP_NAME]
    local nodes = luaMap[JSON_NODE_LIST]
    local ways = luaMap[JSON_WAY_LIST]

    -- load nodes
    for i,node in ipairs(nodes) do
      local lat = node[JSON_NODE_LAT]
      local lon = node[JSON_NODE_LON]
      local uid = node[JSON_NODE_UID]

       if object.nodesByUID[uid] ~= nil then
         print ("WARNING: node uid: ".. uid .." is not unique!")
      end

      object.nodesByUID[uid] = Node:new(lat, lon, uid)
    end


    -- load arcs
    for i,way in ipairs(ways) do
      local nodeList = way[JSON_WAY_NODE_LIST]
      local previousNode = nil
      for j,nodeID in ipairs(nodeList) do
        local node = object.nodesByUID[nodeID]
        if (previousNode) then
          previousNode:linkTo(node)
        end
        previousNode = node
      end
    end
else
  --dummy map
  local n1 = Node:new(0, 0, 1)
  local n2 = Node:new(20, 200, 2)
  local n3 = Node:new(100,100, 3)
  local n4 = Node:new(100,20, 4)
  local n5 = Node:new(150,250, 5)
  local n6 = Node:new(150,150, 6)


  n1:linkTo(n2)
  n2:linkTo(n3)
  n3:linkTo(n4)
  n4:linkTo(n1)
  n5:linkTo(n2)
  n6:linkTo(n2)
  n6:linkTo(n3)
end

  return object
end