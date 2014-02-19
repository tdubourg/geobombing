require "heap"
require "arcPos"
require "print_r"

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
          print(previousNode.uid .. " / " .. node.uid)
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
  self.arcs[#(self.arcs)+1] = self.nodesByUID["2"]:linkTo(self.nodesByUID["3"])
  self.arcs[#(self.arcs)+1] = self.nodesByUID["3"]:linkTo(self.nodesByUID["4"])
  self.arcs[#(self.arcs)+1] = self.nodesByUID["4"]:linkTo(self.nodesByUID["1"])
  self.arcs[#(self.arcs)+1] = self.nodesByUID["5"]:linkTo(self.nodesByUID["2"])
  self.arcs[#(self.arcs)+1] = self.nodesByUID["6"]:linkTo(self.nodesByUID["2"])
  self.arcs[#(self.arcs)+1] = self.nodesByUID["6"]:linkTo(self.nodesByUID["3"])
end

  return self
end

function Map:getArc( node_from_uid, node_to_uid )
    print(node_from_uid, node_to_uid)
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

-- returns nil if non existing arc
function Map:createArcPos(n1, n2, ratio)
  local arc = n1.arcs[n2]
  if arc then
    if arc.end1==n1 then
      return ArcPos:new(arc, ratio)
    else -- arc.end1==n2
      return ArcPos:new(arc, 1-ratio)
    end
  end
  return nil
end

-- returns nil if non existing arc
function Map:createArcPosByUID(n1uid, n2uid, ratio)
  local n1 = self.nodesByUID[n1uid]
  local n2 = self.nodesByUID[n2uid]

  if n1 and n2 then
    return self:createArcPos(n1,n2,ratio)
  end
  return nil
end

function Map:getClosestPos(v2pos)
  local toReturn={}
  local ratio =0
  local min = math.huge
  local best = nil
  --print ("La")
  for _,arc in ipairs(self.arcs) do
    local from = arc.end1.pos
    --print (arc.end1.uid)
    local to = arc.end2.pos
    --print (arc.end2.uid)
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    vectDir:normalize()
    local vectPos = Vector2D:Sub(v2pos,from)
    local distProj = vectPos:dot(vectDir)
    local distVectPos = Vector2D:Dist(v2pos,from)
    --Pythagore
    local dist = math.sqrt(distVectPos* distVectPos - distProj * distProj)

    --print (dist)
    if dist < min then
      min = dist
      best = arc
      ratio = distProj/arc.len
    end
  end
  --print("Ici")
  toReturn[1]=best
  toReturn[2]=ratio
  print(toReturn[1].end1.uid .."  youhou "..toReturn[1].end2.uid .. " ratio ="..toReturn[2])
  return toReturn
end


-- WORK IN PROGRESS
function Map:getExplosionPos(bombArcPos, bombPower, interval)
  local posList = {} -- Vector2D list, world coordinates
  local end1Power = bombPower - (bombArcPos:getPosXY()):dist(bombArcPos.end1)
  local end2Power = bombPower - (bombArcPos:getPosXY()):dist(bombArcPos.end2)

  if end1Power > 0 then
    --bombArcPos.end1:recursiveCall(end1Power)
  end
  if end2Power > 0 then
    --bombArcPos.end2:recursiveCall(end2Power)
  end
end

-- OPTIM: replace open table & popSmalestValue() by a priority queue
function Map:findPathArcs(arcPosFrom, arcPosTo)
  local open = {}
  local closed = {}
  local precedence = {}

  open[arcPosFrom.arc.end1] = Vector2D:Dist(arcPosFrom:getPosXY(), arcPosFrom.arc.end1.pos)
  open[arcPosFrom.arc.end2] = Vector2D:Dist(arcPosFrom:getPosXY(), arcPosFrom.arc.end2.pos)

  local currentNode = nil
  local currentDist = 0

  while next(open) ~= nil do   -- open not empty
    currentNode, currentDist = popSmalestValue(open)
    --inserting neighbours
    closed[currentNode] = true

    if currentNode == "TARGET" then
      return rewindPathArcs(precedence)
    end

    for next,arc in pairs(currentNode.arcs) do
      if closed[next] == nil then  -- not in closed list
        local nextDist = open[next]
        local newNextDist = currentDist + currentNode.pos:dist(next.pos)
        if (not nextDist or newNextDist<nextDist) then
          open[next] = newNextDist
          precedence[next] = currentNode
        end
      end

      -- fake node insertion regarding
      if (arc == arcPosTo.arc) then
        local newTargetDist = currentDist + Vector2D:Dist(arcPosTo:getPosXY(), currentNode.pos)
        local targetDist = open["TARGET"]
        if (not targetDist or newTargetDist < targetDist) then
          open["TARGET"] = newTargetDist
          precedence["TARGET"] = currentNode
        end
      end

    end
  end
  return nil
end

-- OPTIM: replace open table & popSmalestValue() by a priority queue
function Map:findPath(from, to)
  local open = {}
  local closed = {}
  local precedence = {}

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


function rewindPath(precedence, to)
    revPath = {}
    local node = to

    repeat
      revPath[#revPath+1] = node
      node = precedence[node]
    until node == nil
      
    return invertIndexedTable(revPath)
end

function rewindPathArcs(precedence)
    revPath = {}
    local node = precedence["TARGET"]

    repeat
      revPath[#revPath+1] = node
      node = precedence[node]
    until node == nil
      
    return invertIndexedTable(revPath)
end


function invertIndexedTable ( tab )
    local size = #tab+1
    local newTable = {}

    for i,v in ipairs ( tab ) do
        newTable[size-i] = v
    end

    return newTable
end


function Map:destroy()
  for _,node in pairs(self.nodesByUID) do
    node:destroy()
  end

    for _,arc in ipairs(self.arcs) do
    arc:destroy()
  end
end