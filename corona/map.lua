require "heap"

Map = {}
function Map:new(luaMap) -- luaMap = nil  ->  build dummy map
  local self = {}
  self.nodesByUID = {}
  self.arcs ={}
  self.latMin = math.huge
  self.lonMin = math.huge
  self.latMax = -math.huge
  self.lonMax = -math.huge

  setmetatable(self, { __index = Map })  -- Inheritance

  if luaMap then
    local mapName = luaMap[JSON_MAP_NAME]
    local nodes = luaMap[JSON_NODE_LIST]
    local ways = luaMap[JSON_WAY_LIST]

    -- -- update min/max
    -- for i,node in ipairs(nodes) do
    --   local lat = node[JSON_NODE_LAT]
    --   local lon = node[JSON_NODE_LON]
    --   self.latMin = math.min( self.latMin, lat )
    --   self.lonMin = math.min( self.lonMin, lon )
    --   self.latMax = math.max( self.latMax, lat )
    --   self.lonMax = math.max( self.lonMax, lon )

    -- end

    -- load nodes
    for i,node in ipairs(nodes) do
      local x = node[JSON_NODE_X]
      local y = node[JSON_NODE_Y]
      local uid = tostring(node[JSON_NODE_UID])

       if self.nodesByUID[uid] ~= nil then
         print ("WARNING: node uid: ".. uid .." is not unique!")
      end

      self.nodesByUID[uid] = Node:new(x, y , uid)
    end


    -- load arcs
    for i,way in ipairs(ways) do
      local nodeList = way[JSON_WAY_NODE_LIST]
      local previousNode = nil
      for j,nodeID in ipairs(nodeList) do
        local strUid = tostring(nodeID)
        local node = self.nodesByUID[strUid]
        if (previousNode) then
          self.arcs[#(self.arcs)+1] =previousNode:linkTo(node)
          print(j .. " / ")
        end
        previousNode = node
      end
    end
else
  --dummy map
  print "loading dummy map"

  self.nodesByUID["1"] = Node:new(0, 0, "1")
  self.nodesByUID["2"] = Node:new(0, 1, "2")
  self.nodesByUID["3"]= Node:new(0.5,0.5, "3")
  self.nodesByUID["4"]= Node:new(0.5,0.2, "4")
  self.nodesByUID["5"] = Node:new(0.8,1, "5")
  self.nodesByUID["6"]= Node:new(0.7,0.7, "6")

  self.arcs[1] = self.nodesByUID["1"]:linkTo(self.nodesByUID["2"])
  self.arcs[2] = self.nodesByUID["2"]:linkTo(self.nodesByUID["3"])
  self.arcs[3] = self.nodesByUID["3"]:linkTo(self.nodesByUID["4"])
  self.arcs[4] = self.nodesByUID["4"]:linkTo(self.nodesByUID["1"])
  self.arcs[5] = self.nodesByUID["5"]:linkTo(self.nodesByUID["2"])
  self.arcs[6] = self.nodesByUID["6"]:linkTo(self.nodesByUID["2"])
  self.arcs[7] = self.nodesByUID["6"]:linkTo(self.nodesByUID["3"])
end

  return self
end

function Map:getArc( node_from_uid, node_to_uid )
  return self.nodesByUID[node_from_uid].arcs[self.nodesByUID[node_to_uid]]
end

function Map:getNode( node_uid )
  return self.nodesByUID[node_uid]
end

function Map:getClosestNode(v2pos)
  local min = math.huge
  local best = nil
  for _,node in pairs(self.nodesByUID) do
    local dist = v2pos:dist(node.pos)
    if dist < min then
      min = dist
      best = node
    end
  end
  return best
end

function Map:getClosestPos(v2pos)
  local toReturn={}
  local ratio =0
  local min = math.huge
  local best = nil
  print ("La")
  for _,arc in ipairs(self.arcs) do
    local from = arc.end1.pos
    print (arc.end1.uid)
    local to = arc.end2.pos
    print (arc.end2.uid)
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    vectDir:normalize()
    local vectPos = Vector2D:Sub(v2pos,from)
    local distProj = vectPos:dot(vectDir)
    local distVectPos = Vector2D:Dist(v2pos,from)
    --Pythagore
    local dist = math.sqrt(distVectPos* distVectPos - distProj * distProj)

    print (dist)
    if dist < min then
      min = dist
      best = arc
      ratio = distProj/arc.len
    end
  end
  print("Ici")
  toReturn[1]=best
  toReturn[2]=ratio
  print(toReturn[1].end1.uid .."  youhou "..toReturn[1].end2.uid .. " ration ="..toReturn[2])
  return toReturn
end


function Map:findPath(from, to)
  local open = {}
  local closed = {}
  local precedence = { }

  open[from] = 0

  local currentNode = nil
  local currentDist = 0

  while next(open) ~= nil do   -- open not empty
    currentNode, currentDist = popSmalestValue(open)
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
      end

    end
    if currentNode == to then
      return rewindPath(precedence, currentNode)
    end
  end
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

-- BACKUP
-- function rewindPath(precedence, to)
--     revPath = {}

--     local node = to
--     local prevNode = nil

--     repeat
--       revPath[#revPath+1] = node
--       prevNode = precedence[node]
--       node = prevNode
--     until prevNode == nil

--     return invertIndexedTable(revPath)
-- end


function rewindPath(precedence, to)
    revPath = {}
    local node = to

    repeat
      revPath[#revPath+1] = node
      node = precedence[node]
    until precedence[node] == nil --TODO : "until node == nil"  -> ajoute from dans le resultat, plus propre
      
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
