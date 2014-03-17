require "camera"
require "vector2D"
local utils = require("lib.ecusson.Utils")
local CameraAwareSprite = require("camera_aware_sprite")
require "print_r"
require "arcPos"
local Deque = require "deque"

-- error accepted when moving the player
local accepted_error = 0.008

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local Player = {}

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function Player.new( pId, pSpeed, pNbDeath,arcP)   -- constructor
	local self = utils.extend(Player)
	dbg (INFO, {"Creating player... "})
	--Player name / speed / number of death
	self.id = pId
	self.name ="Unknown"
	self.speed = pSpeed or 0.2
	self.nbDeath = pNDeath or 0
	self.nbKill = 0
	self.isDead = true
	dbg(Y,{"ID is", self.id})
	self.color = idToColor(self.id)

	--Player current state : FROZEN / WALKING / DEAD
	self.currentState = PLAYER_FROZEN_STATE 

  self.arcPCurrent = arcP
	--Player Sprite
	self.pos = Vector2D:new(0, 0)
	self.oldpos = Vector2D:new(0, 0)

	self.currentAnimString = "downstand"

	self.sprite = CameraAwareSprite.create {
		spriteSet = "man",
		animation = self.currentAnimString,
		anchor = "bc",
		worldPosition = self.pos,
		scale = 1,
		position = camera:worldToScreen(self.pos),
		group = playerLayer,
	}


	self.colorSprite = CameraAwareSprite.create {
		spriteSet = "manc",
		animation = "leftwalk",
		anchor = "bc",
		worldPosition = self.pos,
		scale = 1,
		color = self.color,
		position = camera:worldToScreen(self.pos),
		group = playerLayer,
	}

	self.nodeFrom=self.arcPCurrent.arc.end1
	self.nodeTo=self.arcPCurrent.arc.end2
	self.currentArcRatio=self.arcPCurrent.progress
	-- self.currentArc=nodeF.arcs[nodeT]
	-- if(self.currentArc.end1==nodeF) then
	--     self.currentArcRatio=0
	-- else
	--     self.currentArcRatio=1
	-- end

  
	--Player current destination
	self.arcPDest = nil
	self.toX= self.pos.x
	self.toY= self.pos.y

	--nodes to go to the final destination
	self.nodes= nil
	self.nodesI=0
	self.nodesMax=0

	--???
	self.objectType = objectType

	return self
end

function Player:getArcPCurrent()
	return self.arcPCurrent
end

function Player:getPos(  )
	return self.pos
end

function Player:die()
	self.sprite:play("death")
	self.colorSprite:play("death")
	self.isDead = true
	return self
end

function Player:revive()
	self.sprite:play("downstand")
	self.colorSprite:play("downstand")
	self.isDead = false
	return self
end

function Player:saveNewNodes(nodes, arcP)
	self.nodes=nodes
	self.arcPDest=arcP
   -- self.saveNewDestination(self.nodes[1])
   if (nodes~=nil) then
		self.nodesI=1
		self.nodesMax=#nodes
		-- print (self.nodesMax .." BOUH")
		self.toX=self.nodes[1].pos.x
		self.toY=self.nodes[1].pos.y
		self.nodeTo=nodes[1]
   else
		self.nodesI=0
		self.nodesMax=0
		if (arcP ~=nil) then
			 self:goToAR(arcP)
		end
		--self.nodeTo=nil
	end
end

-- function Player:saveNewDestination(e)

--     local screenPos = Vector2D:new(e.x, e.y)
--     local worldPos = screenToWorld(screenPos)
--     self.toX=worldPos.x
--     self.toY=worldPos.y

-- end

-- function Player:saveNewDestinationVect(e)

--     self.toX=e.x
--     self.toY=e.y

-- end

-- function Player:saveNewDestinationNode(e)

--     self.toX=e.pos.x
--     self.toY=e.pos.y 

-- end

local lastPredictionRunTime = 0
function Player:refresh()
	if (not ENABLE_MOVE_PREDICTION or self.isDead) then
		return
	end
	local delta = 0.00001 -- TODO: Move this constant and document it, cf server for now
	local newPredictionRunTime = now()
	local delta_time = newPredictionRunTime - lastPredictionRunTime
	lastPredictionRunTime = newPredictionRunTime
	local distToWalk = PLAYER_SPEED * delta_time/1000.0
	dbg(PREDICTION_DBG, {"distToWalk=", distToWalk})

	if (self.arcPCurrent == nil) then
		dbg(PREDICTION_DBG, {"Not enough information to run prediction: arcPCurrent is nil"})
		return
	elseif (self.predictionDestination == nil or self.predictionNodes == nil) then
		dbg(PREDICTION_DBG, {"Not enough information to run prediction: self.predictionDestination is nil"})
		return
	end
	if (self.arcPCurrent:equals(self.predictionDestination, delta)) then
		dbg(PREDICTION_DBG, {"STANDING STILL (up to precision), NOT RUNNING PREDICTION"})
		dbg(PREDICTION_DBG, {self.arcPCurrent.progress, self.predictionDestination.progress})
		return
	end
	dbg(PREDICTION_DBG, {"self.arcPCurrent=", self.arcPCurrent.arc.end1.uid, self.arcPCurrent.arc.end2.uid, self.arcPCurrent.progress})
	dbg(PREDICTION_DBG, {"self.predictionDestination=", self.predictionDestination.arc.end1.uid, self.predictionDestination.arc.end2.uid, self.predictionDestination.progress})
	dbg(PREDICTION_DBG, {"Running prediction!"})

	-- local currentArc = self.arcPCurrent.arc
	-- local currentArcDist = self.arcPCurrent.dist
	-- local targetArcDist = self.predictionDestination.progress
	local copyOfArcPCurrent = self.arcPCurrent:clone()
	if (copyOfArcPCurrent == nil) then
		dbg(ERRORS, {"Something went wrong cloning self.arcPCurrent"})
		return
	end
	if (self.nextPredictionNode == nil) then
		-- self.currPredictionNode = Deque.popleft(self.predictionNodes)
		if (self.predictionNodes.length > 0) then
			self.nextPredictionNode = Deque.popleft(self.predictionNodes)
		end
	end		
	while (distToWalk > delta) do
		-- Iterate until we have walked the entire distance we can walk in a single round
		-- This has to be done in multiple iterations when we need to change arc 
		-- (the distance to walk is > to the distance until the end of the current arc)

		-- Distance between current pos and the next destination (next node on path)
		local distToNextDest
		if (self.predictionNodes.length == 0) then
			-- If we are on the final arc of the path, the distance is the final position
			-- on the arc, minus the current position
			dbg(PREDICTION_DBG, {"We are moving on the final arc."})
			local distToDest = copyOfArcPCurrent:distToReachDistPositionTowards(self.predictionDestination.dist, self.nextPredictionNode)
			if (distToDest < distToWalk) then
				copyOfArcPCurrent = self.predictionDestination
				dbg(PREDICTION_DBG, {"Setting next predicted destination to self.predictionDestination"})
			else
				copyOfArcPCurrent:addDistTowards(distToWalk, self.nextPredictionNode)
				dbg(PREDICTION_DBG, {"Just walking on final arc of distToWalk=", distToWalk, "towards node", self.nextPredictionNode.uid})
			end
			distToWalk = 0 -- Either we walked all in the current arc, or we could have walked more, but we stoppped, in all cases, we do not want to walk more than once on final arc!
		else
			-- If we are not on the final arc of the path, the distance to the next node is
			-- the total length of current arc minus the current position on this arc
			local remainder_dist = copyOfArcPCurrent:addDistTowards(distToWalk, self.nextPredictionNode)
			dbg(PREDICTION_DBG, {"Not final arc, distToWalk=", distToWalk, "copyOfArcPCurrent=", copyOfArcPCurrent.arc.end1.uid, ",", copyOfArcPCurrent.arc.end2.uid, ",", copyOfArcPCurrent.progress})
			dbg(PREDICTION_DBG, {"Not final arc, current next node is=", self.nextPredictionNode.uid})
			if (remainder_dist ~= nil) then
				-- There is still some distance to walk, and it was returned by the addDistTowards
				distToWalk = remainder_dist
				dbg(PREDICTION_DBG, {"Time to switch arc"})
				self.currPredictionNode = self.nextPredictionNode
				self.nextPredictionNode = Deque.popleft(self.predictionNodes)
				dbg(PREDICTION_DBG, {"self.nextPredictionNode=", self.nextPredictionNode.uid})
				copyOfArcPCurrent = currentMap:createArcPos(self.currPredictionNode, self.nextPredictionNode, 0)
				if (copyOfArcPCurrent) then
					dbg(PREDICTION_DBG, {"Switching to arc (", copyOfArcPCurrent.arc.end1.uid, copyOfArcPCurrent.arc.end2.uid, ")"})
				else
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"[Game Model Error]: couldn't find a path from node", self.currPredictionNode.uid, "to node", self.nextPredictionNode.uid})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
				end
			else
				distToWalk = 0 -- There is no distance to walk anymore
				dbg(PREDICTION_DBG, {"We did not do enough distance to switch arc"})
			end
		end
	end
	if (copyOfArcPCurrent == nil) then
		-- Somehow, something went wrong, maybe network preemptively took some CPU time and changed data
		-- We cannot move the currently computed prediction anymore, forget about it
		dbg(ERRORS, {"copyOfArcPCurrent is nil at the end of prediction computation"})
		return
	end
	dbg(PREDICTION_DBG, {"Prediction is setting AR to", copyOfArcPCurrent.arc.end1.uid, ",", copyOfArcPCurrent.arc.end2.uid, ",", copyOfArcPCurrent.progress})
	self:setAR(copyOfArcPCurrent, true)
	if (copyOfArcPCurrent == self.predictionDestination) then
		local xy = copyOfArcPCurrent:getPosXY()
		 -- So that we stand still when the destination has been reached:
		self:refreshAnimation(xy, xy, true)
		self:stopPrediction()
	end
end

function Player:stopPrediction()
	self.predictionNodes = nil
	self.currPredictionNode = nil
	self.nextPredictionNode = nil
	self.predictionDestination = nil
	return self -- allows chaining
end

function Player:setPredictionNodesAndDestination(nodes, destinationArcP)
	dbg(PREDICTION_DBG, {"Setting prediction nodes"})
	self:stopPrediction() -- Clear previously running prediction data\
	-- And initialize new prediction data: 
	self.predictionNodes = Deque.new()
	if (nodes == nil) then
		return
	end
	-- Nodes to go through:
	for i,v in ipairs(nodes) do
		dbg(PREDICTION_DBG, {"Adding node", tostring(i), v.uid, "to predictionNodes"})
		Deque.pushright(self.predictionNodes, v)
	end
	dbg(PREDICTION_DBG, {"Setting prediction destination to", destinationArcP.arc.end1.uid, destinationArcP.arc.end2.uid, destinationArcP.progress})
	self.predictionDestination = destinationArcP
	local node_to_add = nil
	if (self.predictionNodes.length ~= 0) then
		-- If this is a "path", with different nodes to go through, add the "other" end of the final arc as a node
		-- as this will be used to give the "direction" towards which we should go, on this final arc
		if (destinationArcP.arc.end2 == Deque.last(self.predictionNodes)) then
			node_to_add = destinationArcP.arc.end1
		else
			node_to_add = destinationArcP.arc.end2
		end
	else
		-- If this is a same-arc move, then just we have to actually figure out towards which end we're going
		-- we do this by comparing destination to current position
		local current_progress_on_arc = self.arcPCurrent.progress
		local destination_progress_on_arc = destinationArcP.progress
		if (destination_progress_on_arc > current_progress_on_arc) then
			node_to_add = destinationArcP.arc.end2
		else
			node_to_add = destinationArcP.arc.end1
		end
	end
	Deque.pushright(self.predictionNodes, node_to_add)
	dbg(PREDICTION_DBG, {"Adding node", self.predictionNodes.length, node_to_add.uid, "to predictionNodes"})
	return self -- allows chaining
end

function Player:goToAR(arcP)

	local destination = arcP:getPosXY()
	self.nodeFrom=arcP.arc.end1
	self.nodeTo=arcP.arc.end2
	self.toX=destination.x
	self.toY=destination.y
	self.arcPDest = nil

	return self -- allows chaining
end

function Player:setAR(arcP, isPrediction)
	self.oldpos = self.pos
	local destination = arcP:getPosXY()
	self.toX=destination.x
	self.toY=destination.y
	self.pos=destination
	self.sprite:setWorldPosition(self.pos)
	self.colorSprite:setWorldPosition(self.pos)
	self.arcPCurrent = arcP

	if ((not isPrediction) 
		and self.predictionDestination ~= nil 
		and self.arcPCurrent:equals(self.predictionDestination, ACCEPTABLE_POS_DELTA_FOR_STANDING_STILL_OUTSIDE_PREDICTION)
	) then
		self:stopPrediction()
	end

	-- update sprites
	self:refreshAnimation(self.oldpos, self.pos, isPrediction)
end

function Player:refreshAnimation(oldpos, newpos, isPrediction)
	local myCuteDir = Vector2D:Sub(newpos, oldpos)
	local myCuteDirAbs = Vector2D:Abs(myCuteDir)

	local delta_for_standing_still
	if (isPrediction) then
		delta_for_standing_still = ACCEPTABLE_POS_DELTA_FOR_STANDING_STILL_DURING_PREDICTION
	else
		delta_for_standing_still = ACCEPTABLE_POS_DELTA_FOR_STANDING_STILL_OUTSIDE_PREDICTION
	end

	if myCuteDirAbs.x <= delta_for_standing_still and myCuteDirAbs.y <= delta_for_standing_still then
		dbg(PREDICTION_DBG_LITE, {"Animation of standing still. vect=", myCuteDirAbs.x, myCuteDir.y, "delta=", delta_for_standing_still})
		self.animString = "stand"
	else
		self.animString = "walk"
		if myCuteDirAbs.x > myCuteDirAbs.y then
			if myCuteDir.x > 0 then -- right
				self.dirString = "right"
			else                    -- left
				self.dirString = "left"
			end
		else
			if myCuteDir.y < 0 then -- up
				self.dirString = "up"
			else                    -- down
				self.dirString = "down"
			end
		end
	end
	if not self.isDead then
		local newAnimString = self.dirString .. self.animString
		if self.currentAnimString ~= newAnimString then
			self.sprite:play(newAnimString)
			self.colorSprite:play(newAnimString)
			self.currentAnimString = newAnimString
		end
	end
end

function Player:getCurrentStreetName()
	return self.arcPCurrent.arc.streetName
end

function Player:destroy()
	dbg (ERRORS, {"player:destroy()"})
	self.sprite:destroy()
	self.colorSprite:destroy()
end

return Player
