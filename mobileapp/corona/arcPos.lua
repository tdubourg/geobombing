ArcPos = {}                   -- Create a table to hold the class methods

-- do not call this method, use Map:createArcPos() or Map:createArcPosByUID()
function ArcPos:new(arc, progress)  -- The constructor
	local self = {arc=arc, progress=progress, dist=progress*arc.len}
	self.posXY = nil
	
	setmetatable(self, { __index = ArcPos })  -- Inheritance
	return self
end

function ArcPos:getPosXY()
	if not self.posXY then
		self.posXY = Vector2D:Lerp(self.arc.end1.pos, self.arc.end2.pos, self.progress)
	end
	return self.posXY
end

function ArcPos.createFromNetworkPosObj( map, network_pos_obj )
	local arcpos = map:createArcPosByUID(network_pos_obj.n1, network_pos_obj.n2, network_pos_obj.c)
	return arcpos
end

function ArcPos:equals( arcP, precision )
	return arcP.arc == self.arc and (arcP.progress - self.progress) <= precision
end

function ArcPos:setProgress(progress)
	self.progress = progress
	self.dist = progress * self.arc.len
end

function ArcPos:clone()
	return ArcPos:new(self.arc, self.progress)
end

-- Adds some progress to the current ArcPos object
-- @param {float} distance to move the current {ArcPos} object
-- @param {Node} the node towards which we want to go
-- @return {float} the remainder if the distance that was given in parameter
-- was higher than the maximum distance we could move towards this node
-- @return nil if the dist was was not higher than what we can move and there is still 
-- some distance to move towards this node on this {Arc}
function ArcPos:addDistTowards(dist, node_towards)
	local remainder = self:addProgressTowards(dist / self.arc.len, node_towards)
	if (remainder ~= nil) then
		return remainder * self.arc.len
	end
	return remainder
end

-- Adds some progress to the current ArcPos object
-- @param {float} progress
-- @param {Node} the node towards which we want to go
-- @return {float} the remainder if the progress that was given in parameter
-- was higher than the maximum progress we could make towards this node
-- @return nil if the progress was not higher and there is still some progress to make
function ArcPos:addProgressTowards(progress, node_towards)
	local remainder = nil
	if (node_towards == self.arc.end2) then
		self.progress = self.progress + progress
		if (self.progress > 1) then
			remainder = self.progress - 1
			self.progress = 1
		end
	else
		self.progress = self.progress - progress
		if (self.progress < 0) then
			remainder = math.abs(self.progress)
			self.progress = 0
		end
	end
	return remainder
end

function ArcPos:initExplosion(power)
	drawPosList = {}
	local end1dist = self.progress*self.arc.len
	local end2dist = (1-self.progress)*self.arc.len
	local end1Power = power - end1dist
	local end2Power = power - end2dist
	local end1AP = nil
	local end2AP = nil

	-- TODO: faire un truc plus générique et moins dégueu
	-- ... ou s'en foutre et faire refaire cette partie au stagiaire quand on est riches.
	if end1Power>0 then
		local forceTransmit = (end1dist < FORCETRANSMIT_RADIUS)
		self.arc.end1:transmitExplosion(self.arc.end2, end1Power, EXPLOSION_INTERVAL, drawPosList, forceTransmit)
		end1AP = ArcPos:new(self.arc, 0.0)
	else
		end1AP = ArcPos:new(self.arc, self.progress - power/self.arc.len)
	end

	if end2Power>0 then
		local forceTransmit = (end2dist < FORCETRANSMIT_RADIUS)
		self.arc.end2:transmitExplosion(self.arc.end1, end2Power, EXPLOSION_INTERVAL, drawPosList, forceTransmit)
		end2AP = ArcPos:new(self.arc, 1.0)
	else
		end2AP = ArcPos:new(self.arc, self.progress + power/self.arc.len)
	end
 
	array_insert(drawPosList, ArcPos.PosListBetween(self, end1AP, EXPLOSION_INTERVAL))
	array_insert(drawPosList, ArcPos.PosListBetween(self, end2AP, EXPLOSION_INTERVAL))

	return drawPosList
end

-- generates a table filled with positions between arcPosFrom and arcPosTo.
-- distanceInterval is the spacing between added positions. (distance, not ratio!) 
function ArcPos.PosListBetween(arcPosFrom, arcPosTo, distanceInterval)
	if arcPosFrom.arc == arcPosTo.arc then               -- same arc check
		local commonArc = arcPosFrom.arc
		if arcPosFrom.progress < arcPosTo.progress then
			APsmall = arcPosFrom
			APbig = arcPosTo
		else
			APsmall = arcPosTo
			APbig = arcPosFrom
		end

		result = {}
		result[1] = APsmall

		ratio = APsmall.progress
		deltaRatio = distanceInterval/commonArc.len        -- ratio interval regarding arc length

		while ratio <= APbig.progress do
			result[#result+1] = ArcPos:new(commonArc, ratio)
			ratio = ratio + deltaRatio
		end
		result[#result+1] = APbig
		return result
	end
end

return ArcPos