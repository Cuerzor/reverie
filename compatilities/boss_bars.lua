
-- boss designs
local path = HPBars.iconPath
local barPath = HPBars.barPath
HPBars.BarStyles["Doremy"] = {
    sprite = barPath .. "bosses/bossbar_doremy.png",
    overlayAnm2 = barPath .. "bosses/doremy_bosshp_overlay.anm2",
    overlayAnimationType = "Animated",
    idleColoring = HPBars.BarColorings.none,
    hitColoring = HPBars.BarColorings.white,
    tooltip = "'Doremy' - Boss themed"
};

	--[[ Format: ["Type.Variant"] = { 
		sprite = main sprite that this entity should use as its icon
		ignoreInvincible = if set to true, this will make the boss bar to not show invincible state
		iconAnm2 = Path to a .anm2 file this icon should use instead of the default one.
		iconAnimationType = Possible values: ["HP","Animated"]
				HP: 		DEFAULT. The given .anm2 file will render the animation frame based on the current boss HP in percent (0-99 Frames). This allows for custom animations based on the progress of damage you have dealt.
				Animated: 	the provided .anm2 file will be played as a normal animation, allowing for custom animated icons
		conditionalSprites = table containing subtables of conditional sprite objects, formatted as {ConditionFunction, SpritePath, optional table of args}. ConditionFunction can either be a function or the name of the macro condition from the HPBars.conditions table
		offset = offset of the icon sprite to the start of the bar, used to prevent overlapping of the last percents of the hp
		barSyle = Specific bar-style the boss should use. Value can either be the Name of the entry from the HPBars.BarStyles table or a new table formated the same as an entry in the HPBars.BarStyles table
	}
	]] --
local type = THI.GensouDream.Doremy.Type;
local variant = THI.GensouDream.Doremy.Variant;
HPBars.BossDefinitions[type.."."..variant] = {
    sprite = path .. "final/doremy.png",
    barStyle = "Doremy",
    offset = Vector(-9, 0)
};


local ufoType = THI.Monsters.BonusUFO.Type;
local ufoRedVariant = THI.Monsters.BonusUFO.Variant;
local ufoBlueVariant = THI.Monsters.BonusUFO.BlueVariant;
local ufoGreenVariant = THI.Monsters.BonusUFO.GreenVariant;
local ufoColorfulVariant = THI.Monsters.BonusUFO.RainbowVariant;

local bosses = THI.Bosses;
local TheAbandoned = bosses.TheAbandoned;
local TheSummoner = bosses.TheSummoner;
local Devilcrow = bosses.Devilcrow;
local TheCentipede = bosses.TheCentipede;
local Necrospyder = bosses.Necrospyder;
local Pyroplume = bosses.Pyroplume;
local Guppet = bosses.Guppet;
HPBars.BossDefinitions[ufoType.."."..ufoRedVariant] = {
    sprite = path .. "ufo_red.png",
    offset = Vector(-6, 0)
};
HPBars.BossDefinitions[ufoType.."."..ufoBlueVariant] = {
    sprite = path .. "ufo_blue.png",
    offset = Vector(-6, 0)
};
HPBars.BossDefinitions[ufoType.."."..ufoGreenVariant] = {
    sprite = path .. "ufo_green.png",
    offset = Vector(-6, 0)
};
HPBars.BossDefinitions[ufoType.."."..ufoColorfulVariant] = {
	sprite = path .. "ufo_red.png",
	conditionalSprites = {
		{
			function(entity)
				return entity.FrameCount % 4 == 1;
			end,
			path .. "ufo_blue.png"
		},
		{
			
			function(entity)
				return entity.FrameCount % 4 == 2;
			end,
			path .. "ufo_green.png"
		},
		{
			
			function(entity)
				return entity.FrameCount % 4 == 3;
			end,
			path .. "ufo_yellow.png"
		}
	},
	offset = Vector(-6, 0)
};

HPBars.BossDefinitions[TheAbandoned.Type.."."..TheAbandoned.Variant] = {
	sprite = path .. "the abandoned.png",
	offset = Vector(-6, 0)
};
HPBars.BossDefinitions[TheSummoner.Type.."."..TheSummoner.Variant] = {
    sprite = path .. "the summoner.png",
    offset = Vector(0, 0)
};
HPBars.BossDefinitions[Devilcrow.Type.."."..Devilcrow.Variant] = {
    sprite = path .. "devilcrow.png",
    offset = Vector(0, 0)
};
HPBars.BossDefinitions[TheCentipede.Type.."."..TheCentipede.Variant] = {
	sprite = path .. "the centipede_head.png",
	conditionalSprites = {
		{"isMiddleSegment", path .. "the centipede_segment.png"},
		{"isTailSegment", path .. "the centipede_segment.png"}
	},
	offset = Vector(-6, 0)
};
HPBars.BossDefinitions[Necrospyder.Type.."."..Necrospyder.Variant] = {
	sprite = path .. "necrospyder.png",
	offset = Vector(-6, 0)
};

HPBars.BossDefinitions[Pyroplume.Type.."."..Pyroplume.Variants.PHASE1] = {
	sprite = path .. "pyroplume.png",
	offset = Vector(0, 0)
};

HPBars.BossDefinitions[Pyroplume.Type.."."..Pyroplume.Variants.PHASE2] = {
	sprite = path .. "pyroplume_2.png",
	offset = Vector(0, 0)
};

HPBars.BossDefinitions[Pyroplume.Type.."."..Pyroplume.Variants.PHASE3] = {
	sprite = path .. "pyroplume_3.png",
	offset = Vector(0, 0)
};
HPBars.BossDefinitions[Guppet.Type.."."..Guppet.Variant] = {
	sprite = path .. "guppet.png",
	offset = Vector(-6, 0)
};