--[[

sprite.lua
January 10th, 2013

]]
local setmetatable, pairs, love
	= setmetatable, pairs, love

module (...)

--
--  Creates a new sprite 
--
function _M:new(ss, sync)	
	local o = { 
		_drawOrder = 0,
		_spriteSheet = ss,
		_currentAnimation = nil,
		_synchronizer = sync,
		_offsets = { 0, 0 }
	}
		
	self.__index = self	
	local t = setmetatable(o, self)	
	t:initializeAnimations()
	return t
end

--
--  Initializes the animations for this sprite
--
function _M:initializeAnimations()
	self._animations = {}
	
	for k, v in pairs(self._spriteSheet._animations) do
		local a = { _definition = v }
		
		function a:reset()
			self._currentFrame = 1
			self._currentDelay = 0
			self._currentLoop = 0
			self._frameDirection = 1
		end

		function a:update(dt)
			local d = self._definition
					
			self._currentDelay = self._currentDelay + dt			
			if self._currentDelay >= d._delays[self._currentFrame] then
				self._currentDelay = self._currentDelay - d._delays[self._currentFrame]
				self._currentFrame = self._currentFrame + self._frameDirection
								
				if self._currentFrame < 1 or self._currentFrame > #d._frames then
					self._currentLoop = self._currentLoop + 1
					if d._loopCount == -1 or self._currentLoop < d._loopCount then
						if d._loopType == 'loop' then
							self._currentFrame = 1
						elseif d._loopType == 'pingpong' then
							self._frameDirection = self._frameDirection * -1
							self._currentFrame = self._currentFrame + (self._frameDirection * 2)
						end						
					else
						self._currentFrame = self._currentFrame - self._frameDirection 
						self._frameDirection = 0
					
						if self.end_cb then
							self:end_cb()
						end
					end
				end
			end
		end
		
		a:reset()
		
		self._animations[k] = a
	end
end

-- 
--  Plays the animation with the given name
--
function _M:play(n, r)
	self._currentAnimation = self._animations[n]
	if r then
		self._currentAnimation:reset()
	end
end

--
--  Draws the sprite
--
function _M:draw(x, y)
	local d = self._currentAnimation._definition
	local f = self._currentAnimation._currentFrame
	self._offsets[1] = d._offsets[f][1]
	self._offsets[2] = d._offsets[f][2]
	
	love.graphics
		.drawq(
			self._spriteSheet._image, 
			self._spriteSheet._quads[d._frames[f]], 
			x, y, 0, 1, 1, 
			self._offsets[1], self._offsets[2]
		)
end

-- 
--  Updates the sprite
--
function _M:update(dt)
	-- updates the animation
	if self._currentAnimation then	
		if self._synchronizer then
			self._currentAnimation._currentFrame = 
				self._synchronizer._currentAnimation._currentFrame
		else	
			self._currentAnimation:update(dt)
		end
	end
end