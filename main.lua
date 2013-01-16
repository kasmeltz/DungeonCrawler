local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local soundManager = require 'soundManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'
local spriteSheet = require 'spriteSheet'
local spriteSheetManager = require 'spriteSheetManager'
local sprite = require 'sprite'
local map = require 'map'
local camera = require 'camera'

local cx = 300
local hero

require 'loadSpriteSheets'

function love.load()
	math.randomseed( os.time() )
		
	local dungeonScene = gameScene:new()
	dungeonScene._orderedDraw = true
	
	local c = camera:new()
	gameScene:camera(c)

	local m = map:new(spriteSheetManager.sheet('tiles_dungeon_0'))
	m._drawOrder = -1000
	dungeonScene:addComponent(m)
	m:createObjects(dungeonScene)
	
	hero = {}
	hero.x = 100
	hero.y = 100
	hero.speed = 100
	
	hero._sprites = {}
	
	hero._sprites[1] = sprite:new(spriteSheetManager.sheet('male_body_light'), nil)
	hero._sprites[2] = sprite:new(spriteSheetManager.sheet('male_torso_shirt_brown'), hero._sprites[1])
	hero._sprites[3] = sprite:new(spriteSheetManager.sheet('male_legs_metalpants_copper'), hero._sprites[1])

	function hero:play(n)
		for _, v in ipairs(self._sprites) do
			v:play(n)
		end
	end
	
	hero:play('walkleft')
	
	function hero:update(dt)	
		for _, v in ipairs(self._sprites) do
			v:update(dt)
		end
		
		local speedMulti = self.speed * dt
		if love.keyboard.isDown('left') then
			self.x = self.x - speedMulti
			self:play('walkleft')
		end
		if love.keyboard.isDown('right') then
			self.x = self.x + speedMulti
			self:play('walkright')
		end
		if love.keyboard.isDown('up') then
			self.y = self.y - speedMulti
			self:play('walkup')
		end
		if love.keyboard.isDown('down') then
			self.y = self.y + speedMulti
			self:play('walkdown')
		end
		
		self._drawOrder = self.y + self._sprites[1]._offsets[2]- self.x * 1e-14
	end

	function hero:draw(camera)
		love.graphics.setColor(255,255,255,255)
		
		local sx = math.floor((self.x * camera._zoomX) - camera._cwzx)
		local sy = math.floor((self.y * camera._zoomY) - camera._cwzy)
		
		for _, v in ipairs(self._sprites) do
			v:draw(sx, sy)		
		end
	end
	
	dungeonScene:addComponent(hero)	
	
	local function createOrc()		
		local e = {}
		e.x = 900
		e.y = 300
		e.speed = 100
		e.entities = {}
		e.sprite = sprite:new(spriteSheetManager.sheet('male_body_orc'))
		e.sprite:play('walkleft')
		
		function e:update(dt)
			self.x = self.x - dt * 25
			self.sprite:update(dt)		
			for _, en in pairs(self.entities) do
				en:update(dt)
			end
			self._drawOrder = self.y + self.sprite._offsets[2]- self.x * 1e-14
		end

		function e:draw(camera)
			love.graphics.setColor(255,255,255,255)
			
			local sx = math.floor((self.x * camera._zoomX) - camera._cwzx)
			local sy = math.floor((self.y * camera._zoomY) - camera._cwzy)
		
			self.sprite:draw(sx, sy)
		end	
		return e
	end
	
	for i = 1, 4 do
		local o = createOrc()
		o.y = math.random(0,600)		
		dungeonScene:addComponent(o)
	end
		
	sceneManager.addScene('dungeon', dungeonScene)
	sceneManager.switch('dungeon')
end
			
function love.draw()
	love.graphics.setBackgroundColor(100,100,100,255)
	love.graphics.clear()		

	sceneManager.draw()
end

function love.update(dt)
	local scene = sceneManager.getScene('dungeon')
	local c = scene:camera()	
	c:center(hero.x, hero.y)
	sceneManager.update(dt)
end