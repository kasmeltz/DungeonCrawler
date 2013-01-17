local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local soundManager = require 'soundManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'
local spriteSheet = require 'spriteSheet'
local spriteSheetManager = require 'spriteSheetManager'
local camera = require 'camera'

require 'map'
require 'actor'
require 'loadSpriteSheets'

local hero

local orcsSlain = 0
local font = love.graphics.newFont(32)

function love.load()
	math.randomseed( os.time() )
		
	local dungeonScene = gameScene:new()
	dungeonScene:createCollisionBuckets(100,200)
	dungeonScene._orderedDraw = true	
	--dungeonScene._showCollisionBoxes = true
	
	local c = camera:new()
	gameScene:camera(c)

	local m = objects.Map{ _spriteSheet = spriteSheetManager.sheet('tiles_dungeon_0') }	
	m._drawOrder = -1000
	dungeonScene:addComponent(m)
	m:createObjects(dungeonScene)
	
	hero = objects.Actor{ _spriteSheet = spriteSheetManager.sheet('male_body_light') }
	hero._position[1] = 400
	hero._position[2] = 400
	hero:direction('left')
	hero:animation('walk')
	
	function hero:on_begin_attack()			
		local dagger = objects.Actor{ _spriteSheet = spriteSheetManager.sheet('weapons_flying_dagger') }		
		hero:ignoreCollision(dagger)
		dagger:ignoreCollision(hero)

		local speed = 250
		local currentTime = 0
		local timeToLive = 1
		local dir = hero:direction()
		local hv = hero:velocity()
		local vx, vy = 0, 0
		
		if (hv[1] > 0 or dir == 'right' ) then
			dagger:position(hero._position[1] + 20, hero._position[2] - 30)			
			vx = speed
		end
		if (hv[1] < 0 or dir == 'left' ) then
			dagger:position(hero._position[1] - 20, hero._position[2] - 30)			
			vx = -speed
		end		
		if (hv[2] < 0 or dir == 'up' ) then
			dagger:position(hero._position[1], hero._position[2] - 30)			
			vy = -speed
		end
		if (hv[2] > 0 or dir == 'down' ) then
			dagger:position(hero._position[1], hero._position[2] - 20 )			
			vy = speed
		end				
		
		dagger._velocity[1] = vx
		dagger._velocity[2] = vy
		
		dagger:animation('attack')
		dagger:update(0)		
				
		function dagger:update(dt)
			currentTime = currentTime + dt
			if currentTime >= timeToLive then
				dungeonScene:removeComponent(dagger)
				return
			end			
			dagger._rotation = dagger._rotation + 20 * dt
			objects.Actor.update(dagger, dt)
		end
		
		function dagger:on_collide(other)
			if other.ACTOR then
				orcsSlain = orcsSlain + 1
				dungeonScene:removeComponent(other)
			end
			dungeonScene:removeComponent(dagger)
		end
		
		dungeonScene:addComponent(dagger)
	end
	
	dungeonScene:addComponent(hero)		
	dungeonScene:addComponent{
		update = function(self, dt)
			local speed = 200
			
			if not hero._currentAction then
				local vx, vy = 0, 0				
				if love.keyboard.isDown('left') then
					vx = -speed
					hero:direction('left')
					hero:animation('walk')
				end
				if love.keyboard.isDown('right') then
					vx = speed
					hero:direction('right')
					hero:animation('walk')
				end
				if love.keyboard.isDown('up') then
					vy = -speed
					hero:direction('up')
					hero:animation('walk')
				end
				if love.keyboard.isDown('down') then
					vy = speed
					hero:direction('down')
					hero:animation('walk')
				end
				hero:velocity(vx, vy)				
				if vx == 0 and vy == 0 then
					hero:animation('stand')
				end
				
				if love.keyboard.isDown('lctrl') then
					hero:action('attack')
					hero:velocity(0,0)					
				end			

				if love.keyboard.isDown('a') then					
					local x = c._zoomX
					local y = c._zoomY
					c:zoom(x + 0.01, y + 0.01)
				end
				
				if love.keyboard.isDown('z') then					
					local x = c._zoomX
					local y = c._zoomY
					c:zoom(x - 0.01, y - 0.01)
				end				
			end
		end
	}
	
	-- orc spawner
	local spawner = objects.Drawable{ _spriteSheet = spriteSheetManager.sheet('male_body_light'), 
		_spawnTime = 1, _currentTime = 0 }
	spawner._position[1] = 500
	spawner._position[2] = 500	
	spawner:direction('down')
	spawner:animation('stand')
	spawner:update(0)
	
	function spawner:update(dt)		
		local function changeDirection(orc)
			local dir = 'up'
			local vx = math.random(-200,200)
			local vy = math.random(-200,200)

			if math.abs(vx) > math.abs(vy) then
				if vx < 0 then						
					dir = 'left'
				else
					dir = 'right'
				end			
			else
				if vy < 0 then						
					dir = 'up'
				else
					dir = 'down'
				end						
			end

			orc:direction(dir)
			orc:animation('walk')			
			orc._velocity[1] = vx
			orc._velocity[2] = vy
		end
		
		self._currentTime = self._currentTime + dt
		if self._currentTime >= self._spawnTime then	
			self._currentTime = 0
			local orc = objects.Actor{ _spriteSheet = spriteSheetManager.sheet('male_body_orc') }
			changeDirection(orc)
			orc._position[1] = spawner._position[1]
			orc._position[2] = spawner._position[2]			
			orc:update(0)
			
			function orc:on_collide(other)
				changeDirection(orc)
			end

			dungeonScene:addComponent(orc)
		end
		
		objects.Drawable.update(self, dt)
	end	
	dungeonScene:addComponent(spawner)
		
	dungeonScene:addComponent{
		_drawOrder = 10000,
		draw = function()	
			love.graphics.setColor{0,255,0,255}
			love.graphics.setFont(font)
			love.graphics.print('Demons defeated', 500, 0)
			love.graphics.print(orcsSlain, 700, 40)
		end}
	
	sceneManager.addScene('dungeon', dungeonScene)
	sceneManager.switch('dungeon')
end
			
function love.draw()
	love.graphics.setColor{255,255,255,255}
	love.graphics.setBackgroundColor(100,100,100,255)
	love.graphics.clear()		

	sceneManager.draw()
end

function love.update(dt)
	local scene = sceneManager.getScene('dungeon')
	sceneManager.update(dt)
	local c = scene:camera()	
	c:center(hero._position[1], hero._position[2])	
end