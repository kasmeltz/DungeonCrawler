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
local smallFont = love.graphics.newFont(14)

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
	
	hero._maxLevel = 11
	hero._experienceLevels = { 10, 18, 32, 58, 105, 189, 340, 612, 1101, 1983, 3570, 3570 }
	hero._currentExperience = 0	
	hero._currentLevel = 1
	hero._skillPoints = 0
	hero._baseMovementSpeed = 50
	hero._position[1] = 400
	hero._position[2] = 400
	hero:direction('left')
	hero:animation('walk')
	
	local minAttackModifier = -0.04
	local maxMovementModifier = 4
	
	hero._skills = {}

	hero._skills.Nimbleness = {
		_name = 'Nimbleness',
		_isPassive = true,
		_currentLevel = 1,
		_maxLevel = 10,
		_stats = {
			_movementSpeedPercentage = { 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 2.5, 3, 3 }
		},
		helperText = function(self, levelAdd)
			local levelAdd = levelAdd or 0
			local asp = self._stats._movementSpeedPercentage[self._currentLevel + levelAdd]
			local astext = string.format('%.0f',asp * 100)
			return 'Increases movement speed by ' .. astext .. '%'		
		end				
	}
	
	hero._skills.RapidFire = {
		_name = 'Rapid Fire',
		_isPassive = true,
		_currentLevel = 1,
		_maxLevel = 5,
		_stats = {
			_attackSpeedPercentage = { 0, 0.09, 0.17, 0.3, 0.5, 0.5 }
		},
		helperText = function(self, levelAdd)
			local levelAdd = levelAdd or 0
			local asp = self._stats._attackSpeedPercentage[self._currentLevel + levelAdd]
			local astext = string.format('%.0f',
				(1 / (1 - asp) - 1) * 100)
			return 'Increases attack speed by ' .. astext .. '%'		
		end				
	}
	
	function hero:updateAttackSpeedModifier(percentage)
		-- get the base attack speed delay	
		local baseAttackDelay
		for k, v in pairs(self._animations) do
			if k:find('attack') then
				baseAttackDelay = v._definition._delays[1]
				break				
			end
		end
				
		-- calculate and set the delay modifier for the attack animations
		local modifier = -(baseAttackDelay * percentage)
		modifier = math.max(modifier, minAttackModifier)
		
		for k, v in pairs(self._animations) do
			if k:find('attack') then
				v._delayModifier = modifier
			end
		end
	end

	--
	-- Calculte attack speed
	--
	function hero:calculateAttackSpeed()
		self._attackSpeedPercentage = 0

		-- attack speed from skills
		for k, v in pairs(self._skills) do		
			local stats = v._stats
			if stats._attackSpeedPercentage then
				self._attackSpeedPercentage = 
					self._attackSpeedPercentage + stats._attackSpeedPercentage[v._currentLevel]
			end
		end	
		
		-- attack speed from items

		-- set attack speed
		self:updateAttackSpeedModifier(self._attackSpeedPercentage)	
	end
	
	--
	--  Calculate movement speed
	--
	function hero:calculateMovementSpeed()
		self._movementSpeedPercentage = 1
		
		-- movement speed from skills
		for k, v in pairs(self._skills) do		
			local stats = v._stats
			if stats._movementSpeedPercentage then
				self._movementSpeedPercentage = 
					self._movementSpeedPercentage + stats._movementSpeedPercentage[v._currentLevel]
			end
		end			
		
		self._movementSpeedPercentage = math.min(self._movementSpeedPercentage, maxMovementModifier)		
		self._movementSpeed = self._baseMovementSpeed * self._movementSpeedPercentage
	end
	
	function hero:recalculateStats()	
		self:calculateAttackSpeed()
		self:calculateMovementSpeed()
	end
	
	--
	--  Called when the hero gains a level
	--
	function hero:gainLevel()
		if self._currentLevel >= self._maxLevel then return end
		
		self._currentLevel = self._currentLevel + 1
		self._skillPoints = self._skillPoints + 1
		self:recalculateStats()
	end
	
	--
	--  Called when the hero gains experience
	--
	function hero:gainExperience(e)
		if self._currentLevel >= self._maxLevel then return end
	
		self._currentExperience = self._currentExperience + e
		while self._currentExperience >= self._experienceLevels[self._currentLevel] do
			self:gainLevel()		
		end
	end
	
	function hero:on_begin_attack()			
		local dagger = objects.Actor{ 
			_spriteSheet = spriteSheetManager.sheet('weapons_flying_dagger') 
		}
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
				hero:gainExperience(other._experienceOnDefeat)
				dungeonScene:removeComponent(other)				
			end
			dungeonScene:removeComponent(dagger)
		end
		
		dungeonScene:addComponent(dagger)
	end
	
	hero:recalculateStats()
	dungeonScene:addComponent(hero)		
	
	local overlay = { _isVisible = false, _drawOrder = 1000000 }
	overlay._buttons = {}
	
	for k, v in pairs(hero._skills) do
		overlay._buttons[k] = {
			_x = 0, _y = 0, _w = 25, _h = 25,
			_buttonDown = false,
			_isHover = false,
			draw = function(self)
				if hero._skillPoints > 0 and v._currentLevel < v._maxLevel then
					if self._buttonDown then
						love.graphics.setColor(255,0,0,255)
						love.graphics.rectangle('fill', self._x, self._y, self._w, self._h)
						love.graphics.setColor(255,255,0,255)
						love.graphics.print('+', self._x + 7, self._y + 5)
					else
						love.graphics.setColor(255,255,0,255)
						love.graphics.rectangle('fill', self._x, self._y, self._w, self._h)
						love.graphics.setColor(255,0,0,255)
						love.graphics.print('+', self._x + 7, self._y + 5)					
					end
				end
			end,
			update = function(self, dt)
				self._isHover = false

				if v._currentLevel >= v._maxLevel then return end
				if hero._skillPoints <= 0 then return end

				local mx, my = love.mouse.getPosition()		

				if mx >= self._x and my >= self._y and
					mx <= self._x + self._w and
					my <= self._y + self._h then
						self._isHover = true
				end					

				if self._isHover then
					if love.mouse.isDown('l') then
						self._buttonDown = true						
					else 
						if self._buttonDown then
							self._buttonDown = false
							v._currentLevel = v._currentLevel + 1
							hero._skillPoints = hero._skillPoints - 1
							hero:recalculateStats()
						end
					end					
				end
			end
		}
	end
	
	function overlay:update(dt)
		if not self._isVisible then return end
		
		for k, v in pairs(self._buttons) do
			v:update(dt)
		end
	end
	
	function overlay:draw(camera)
		if not self._isVisible then return end
		love.graphics.setColor(0,0,100,220)
		love.graphics.rectangle('fill', 100, 100, 600, 400)
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(smallFont)
		local sx = 110
		local sy = 110		
		love.graphics.print('Level - ' ..
			hero._currentLevel, sx, sy)
		sy = sy + 25
		love.graphics.print('Experience - ' ..
			hero._currentExperience .. ' / ' ..
			hero._experienceLevels[hero._currentLevel], sx, sy)
		sy = sy + 25
		love.graphics.print('Skill Points - ' ..
			hero._skillPoints, sx, sy)
		sy = sy + 25		
		love.graphics.print('Total enemies defeated: ' .. orcsSlain, sx, sy)
		
		sy = sy + 100
			
		for k, v in pairs(hero._skills)	do
			local b = self._buttons[k]		
			local levelAdd = 0
			if b then	
				b._x = sx
				b._y = sy + 25
				b:draw()
				if b._isHover then
					levelAdd = 1
				end
			end
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.print(v._name .. 
				' - Level ' .. 
				(v._currentLevel - (1 - levelAdd)) .. 
				' - ' .. v:helperText(levelAdd), sx, sy)
			
			sy = sy + 50				
		end
	end
	
	dungeonScene:addComponent(overlay)
	
	-- input handler
	dungeonScene:addComponent{
		update = function(self, dt)
			if not hero._currentAction then
				local vx, vy = 0, 0				
				if love.keyboard.isDown('left') then
					vx = -1
					hero:direction('left')
					hero:animation('walk')
				end
				if love.keyboard.isDown('right') then
					vx = 1
					hero:direction('right')
					hero:animation('walk')
				end
				if love.keyboard.isDown('up') then
					vy = -1
					hero:direction('up')
					hero:animation('walk')
				end
				if love.keyboard.isDown('down') then
					vy = 1
					hero:direction('down')
					hero:animation('walk')
				end
				
				vx = vx * hero._movementSpeed
				vy = vy * hero._movementSpeed
				
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
					
			if love.keyboard.isDown('c') then
				overlay._isVisible = true
			end
			if love.keyboard.isDown('v') then
				overlay._isVisible = false
			end
		end
	}
	
	-- orc spawner
	local spawner = objects.Drawable{ 
		_spriteSheet = spriteSheetManager.sheet('male_body_light'), 
		_spawnTime = 2, _currentTime = 0 }
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
			orc._experienceOnDefeat = 5
			orc:update(0)
			
			function orc:on_collide(other)
				changeDirection(orc)
			end

			dungeonScene:addComponent(orc)
		end
		
		objects.Drawable.update(self, dt)
	end	
	dungeonScene:addComponent(spawner)
		
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