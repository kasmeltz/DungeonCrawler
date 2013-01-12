local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local soundManager = require 'soundManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

function love.load()
	math.randomseed( os.time() )
end
			
function love.draw()
	sceneManager.draw()
end

function love.update(dt)
	sceneManager.update(dt)
end