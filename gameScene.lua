--[[

gameScene.lua
January 9th, 2013

]]
local setmetatable, pairs, ipairs, table
	= setmetatable, pairs, ipairs, table
		
module(...)

--
--  Creates a game scene
--
function _M:new()	
	local o = { 
		_components = {},
		_orderedDraw = false
	}	
	
	self.__index = self
	return setmetatable(o, self)	
end

--
--  Draws the game scene
--
function _M:draw()
	if self._orderedDraw then
		local sorted = {}
		for k, v in pairs(self._components) do
			sorted[#sorted+1] = v
		end
		table.sort(sorted, function(a,b) return a._drawOrder < b._drawOrder end)
		for _, c in ipairs(sorted) do
			c:draw(self._camera)
		end
	else
		for _, c in pairs(self._components) do
			c:draw(self._camera)
		end	
	end
end

--
--  Updates the game scene
--
function _M:update(dt)
	for _, c in pairs(self._components) do
		c:update(dt)	
	end
end

--
--  Adds a component
--
function _M:addComponent(c)
	self._components[c] = c
end

--
--  Removes a component
--
function _M:removeComponent(c)
	self._components[c] = nil
end

--
--  Sets or gets the camera for this scene
--
function _M:camera(c)
	if not c then return self._camera end
	self._camera = c
end
