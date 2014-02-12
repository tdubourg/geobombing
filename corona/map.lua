require "heap"

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
  -- local n1 = Node:new(0, 0, 1)
  -- local n2 = Node:new(20, 200, 2)
  -- local n3 = Node:new(100,100, 3)
  -- local n4 = Node:new(100,20, 4)
  -- local n5 = Node:new(150,250, 5)
  -- local n6 = Node:new(150,150, 6)


  -- n1:linkTo(n2)
  -- n2:linkTo(n3)
  -- n3:linkTo(n4)
  -- n4:linkTo(n1)
  -- n5:linkTo(n2)
  -- n6:linkTo(n2)
  -- n6:linkTo(n3)

  object.nodesByUID[1] = Node:new(0, 0, 1)
  object.nodesByUID[2] = Node:new(0, 200, 2)
  object.nodesByUID[3]= Node:new(100,100, 3)
  object.nodesByUID[4]= Node:new(100,20, 4)
  object.nodesByUID[5] = Node:new(150,250, 5)
  object.nodesByUID[6]= Node:new(150,150, 6)

  object.nodesByUID[1]:linkTo(object.nodesByUID[2])
  object.nodesByUID[2]:linkTo(object.nodesByUID[3])
  object.nodesByUID[3]:linkTo(object.nodesByUID[4])
  object.nodesByUID[4]:linkTo(object.nodesByUID[1])
  object.nodesByUID[5]:linkTo(object.nodesByUID[2])
  object.nodesByUID[6]:linkTo( object.nodesByUID[2])
  object.nodesByUID[6]:linkTo( object.nodesByUID[3])
end

  return object
end

function Map:getClosestNode(v2pos)
  print_r(v2pos)
  local min = math.huge
  local best = nil
  for i,node in ipairs(self.nodesByUID) do
    print_r(node.pos)
    local dist = v2pos:dist(node.pos)
    print "dist"
    print(dist)
    if dist < min then
      print "yes"
      min = dist
      best = node
    end
  end
  return best
end

function Map:findPath(from, to)
  local open = {}
  local closed = {}
  local precedence = { }

  open[from] = 0

  local currentNode = nil
  local currentDist = 0

  while next(open) ~= nil do
    print "while"
    currentNode, currentDist = popSmalestValue(open)
    print(currentDist)
    --inserting neighbours
    closed[currentNode] = true
    for next,_ in pairs(currentNode.arcs) do
      if closed[next] == nil then
        local nextDist = open[next]
        local newNextDist = currentDist + currentNode.pos:dist(next.pos)
        if (not nextDist or newNextDist<nextDist) then
          open[next] = newNextDist
          precedence[next] = currentNode
        end
        --adding to closed licensing.init( providerName )
      else
        print "in closed"
      end

    end
    if currentNode == to then
      return rewindPath(precedence, currentNode)
    end
  end
  print "not found"
  return nil

end

function popSmalestValue(table)
  minV = math.huge
  bestK = nil
  for k,v in pairs(table) do
    if (v < minV) then
      minV = v
      bestK = k
    end
  end
  table[bestK] = nil
  return bestK,minV
end


function rewindPath(precedence, to)
    revPath = {}

    local node = to
    local prevNode = nil

    repeat
      print "revrev"
      print (node.uid)
      revPath[#revPath+1] = node
      prevNode = precedence[node]
      node = prevNode
    until prevNode == nil

    return invertIndexedTable(revPath)
end

function invertIndexedTable ( tab )
    local size = #tab
    local newTable = {}

    for i,v in ipairs ( tab ) do
        newTable[size-i] = v
    end

    return newTable
end