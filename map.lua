--[[

map.lua
January 10th, 2013

]]
local love = love

local setmetatable, pairs, math
	= setmetatable, pairs, math

module (...)

--
--  Creates a new sprite 
--
function _M:new(ss, sync)	
	local o = { 
		_spriteSheet = ss
	}
		
	self.__index = self	
	return setmetatable(o, self)	
end

--
--  Creates objects in the game scene that are to be drawn above base map layer
--  Could even be animated etc etc
--
function _M:createObjects(scene)	
	local map = self
	local function drawnObject(x, y, q)
		return 
		{
			_drawOrder = y + 16 - x * 1e-14,
			draw = function(self, camera)				
				local sx = math.floor((x * camera._zoomX) - camera._cwzx)
				local sy = math.floor((y * camera._zoomY) - camera._cwzy)			
				love.graphics
				.drawq(
					map._spriteSheet._image, 
					map._spriteSheet._quads[q], 
					sx, sy, 0, 1, 1, 16, 16
				)		
			end,
			update = function()
			end
		}
	end
		
	scene:addComponent(drawnObject(128,128,5))
	
	for x = 160, 500, 32 do
		scene:addComponent(drawnObject(x,128,6))
	end
	
	scene:addComponent(drawnObject(512,128,7))
	scene:addComponent(drawnObject(128,160,12))
	scene:addComponent(drawnObject(128,192,19))
	scene:addComponent(drawnObject(160,192,20))
end

--
--  Draws the map
--
function _M:draw(camera)
	local q = 1
	
	local sx = math.floor((0 * camera._zoomX) - camera._cwzx)
	local sy = math.floor((0 * camera._zoomY) - camera._cwzy)
	
	for y = sy, sy + 600, 32 do
		for x = sx, sx + 800, 32 do
			love.graphics
				.drawq(
					self._spriteSheet._image, 
					self._spriteSheet._quads[q], 
					x, y
				)
			q = q + 1
			if q > 2 then q = 1 end
		end
	end
end

--
--  Updates the map
--
function _M:update()
end