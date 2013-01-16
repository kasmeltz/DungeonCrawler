--[[

spriteSheet.lua
January 10th, 2013

]]
local setmetatable, ipairs, love
	= setmetatable, ipairs, love

module (...)

--
--  Creates a new sprite sheet
--
function _M:new(i, f, a)	
	local o = { 
		_image = i,
		_frames = {} or f,
		_animations = {} or a
	}	
	
	self.__index = self
	return setmetatable(o, self)	
end

--
--  Sets or gets the sheet image used by the spritesheet
--
function _M:image(i)
	if not i then return self._image end
	self._image = i
end

--
--  Sets or gets the frame definition of this spritesheet
--
function _M:frames(f)
	if not f then return self._frames end
	self._quads = nil
	self._frames = f
end

--
--  Sets the spritesheet to use uniform sized frames 
--  that span the width and height of the sheet image
--
--	Inputs:
--		w - the width of a frame
--		h - the height of a frame
--
function _M:uniformFrames(w, h)
	self._frames = {}
	self._quads = nil
	
	for y = 0, self._image:getHeight() - (w - 1), w do
		for x = 0, self._image:getWidth() - (h - 1), h do		
			self:addFrame{x, y, w, h}
		end
	end
end

--
--  Adds a frame to the sprite sheet
--	
--	Input:
--		f - a table in the format 
--		{
--			left starting pixel,
--			top starting pixel,
--			width,
--			height
--		}
--
function _M:addFrame(f)
	self._frames[#self._frames + 1] = f
	
	self._quads = nil
end

--
--  Gets the quads used to draw the frames
--	of this sprite sheet
--
function _M:quads()
	if self._quads then return self._quads end
	
	self._quads = {}
	local w = self._image:getWidth()
	local h = self._image:getHeight()	
	
	for k, v in ipairs(self._frames) do
		self._quads[k] 
			= love.graphics.newQuad( v[1], v[2], v[3], v[4], w, h )
	end

	return self._quads
end

--
--  Sets or gets the animations table
--
function _M:animations(a)
	if not a then return self._animations end
	self._animations = a
end

--
--  Adds an animation to the sprite sheet
--	
--	Input:
--		n - the name of the animation
--		a - a table in the format
--		{
--			frames = { 1, 2, 3, 4 },
--			delay = { 10, 10, 10, 10 },
--			offset = { { 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 } },
--			animationType = { 'loop' || 'pingpong' },
--			animationCount = 1,
--		}
--
function _M:addAnimation(n, a)
	self._animations[n] = a
end

--
--  Removes an animation from the sprite sheet
--
function _M:removeAnimation(n)
	self._animations[n] = nil
end