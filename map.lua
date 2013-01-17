--[[

map.lua
January 10th, 2013

]]

local Object = (require 'object').Object

require 'collidable'

local love = love

local setmetatable, pairs, math
	= setmetatable, pairs, math
	
module('objects')

Map = Object{}

Map.objectLayer = 4

--
--  Creates a new sprite 
--
function Map:_clone(values)
	local o = Object._clone(self,values)
	
	o._extents = { 0, 0, 4000, 4000 }
	
	o._tiles = {}
	for i = 1, 4 do
		o._tiles[i] = {}
		for y = 1, 100 do
			o._tiles[i][y] = {}
			for x = 1, 100 do
				o._tiles[i][y][x] = math.random(1,2)
			end
		end
	end
	
	o._tiles[Map.objectLayer][3][2] = 5
	o._tiles[Map.objectLayer][3][22] = 7
	o._tiles[Map.objectLayer][21][2] = 19
	o._tiles[Map.objectLayer][21][22] = 21
	for x = 3, 21 do
		o._tiles[Map.objectLayer][3][x] = 6
		o._tiles[Map.objectLayer][21][x] = 20
	end
	for y = 4, 20 do
		o._tiles[Map.objectLayer][y][2] = 12
		o._tiles[Map.objectLayer][y][22] = 14
	end	
	
	return o
end

--
--  Creates objects in the game scene that are to be drawn above base map layer
--  Could even be animated etc etc
--
function Map:createObjects(scene)		
	local map = self
	local function drawnObject(x, y, frameNumber, tile)
		local o = Collidable{ _position = { x, y } }		
		o._drawOrder = y + tile._height - x * 1e-14
		
		function o:draw(camera)		
			local sx = math.floor((self._position[1] * camera._zoomX) - camera._cwzx)
			local sy = math.floor((self._position[2] * camera._zoomY) - camera._cwzy)			
			love.graphics
			.drawq(
				map._spriteSheet._image, 
				map._spriteSheet._quads[frameNumber], 
				sx, sy, 0, 
				camera._zoomX, camera._zoomY, 
				tile._offset[1], tile._offset[2]
			)		
		end
		
		function o:baseBoundary()
			return tile._boundary
		end

		function o:baseOffset()
			return tile._offset
		end
		
		return o
	end
	
	local objectLayer = self._tiles[Map.objectLayer]
	local py = 0
	for y = 1, #objectLayer do
		local px = 0
		for x = 1, #objectLayer[1] do
			local frameNumber = objectLayer[y][x]
			if frameNumber and self._spriteSheet._tiles[frameNumber] then
				scene:addComponent(
					drawnObject(px, py, 
						frameNumber, 
						self._spriteSheet._tiles[frameNumber]))
			end			
			px = px + self._spriteSheet._tileSize[1]
		end
		py = py + self._spriteSheet._tileSize[1]
	end
end

--
--  Draws the map base tiles
--
function Map:draw(camera)
	local ts = self._spriteSheet._tileSize
	local stepX = ts[1] * camera._zoomX
	local stepY = ts[2] * camera._zoomY
	
	local sx = math.floor((0 * camera._zoomX) - camera._cwzx)
	local sy = math.floor((0 * camera._zoomY) - camera._cwzy)
	
	local ex = sx + 800 + (stepX*2)
	local ey = sy + 600 + (stepY*2)
	
	local ty = 1	
	for y = sy, ey, stepY do
		local tx = 1
		for x = sx, ex, stepX do
			local frameNumber = self._tiles[1][ty][tx]
			love.graphics
				.drawq(
					self._spriteSheet._image, 
					self._spriteSheet._quads[frameNumber], 
					x, y, 0,
					camera._zoomX, camera._zoomY
				)
			tx = tx + 1
		end
		ty = ty + 1
	end
end

--
--  Updates the map
--
function Map:update()
end