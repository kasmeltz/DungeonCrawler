--[[

animation.lua
January 10th, 2013

]]
local setmetatable
	= setmetatable

module (...)

--
--  Creates a new animation
--
function _M:new(s)	
	local o = { 
		_spriteSheet = s
	}	
	
	self.__index = self
	return setmetatable(o, self)	
end
