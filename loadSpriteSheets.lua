local spriteSheet = require 'spriteSheet'
local spriteSheetManager = require 'spriteSheetManager'

local body_animations =
{
	['walkup'] = 
	{
		_frames = { 106, 107, 108, 109, 110, 111, 112, 113 },
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }, 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['walkleft'] = 
	{
		_frames = { 119, 120, 121, 122, 123, 124, 125, 126 },
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }, 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['walkdown'] = 
	{
		_frames = { 132, 133, 134, 135, 136, 137, 138, 139 },
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }, 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['walkright'] = 
	{
		_frames = { 145, 146, 147, 148, 149, 150, 151, 152 },
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }, 
			{ 32, 32 }, { 32, 32 }, { 32, 32 }, { 32, 32 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	}		
}

-- the human male light body sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/body/male/light.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_body_light', ss)

-- the orc male green body sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/body/male/orc.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_body_orc', ss)

-- the brown shirt sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/torso/male/shirt_brown.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_torso_shirt_brown', ss)

-- the brown shirt sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/legs/male/metalpants_copper.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_legs_metalpants_copper', ss)

-- dungeon tile set
-- the human male light body sprite sheet
local ss = spriteSheet:new(imageManager.load('images/tiles/dungeon0.png'))
ss:uniformFrames(32, 32)
ss:quads()
spriteSheetManager.sheet('tiles_dungeon_0', ss)