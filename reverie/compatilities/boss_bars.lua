
-- boss designs
local path = HPBars.iconPath.."reverie/"
local barPath = HPBars.barPath.."reverie/"
HPBars.BarStyles["Doremy"] = {
    sprite = barPath .. "bossbar_doremy.png",
    overlayAnm2 = barPath .. "doremy_bosshp_overlay.anm2",
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


local UFO = THI.Monsters.BonusUFO;
local ufoType = UFO.Type;
local ufoVariant = UFO.Variant;
local ufoRedSubType = UFO.SubTypes.RED;
local ufoBlueSubType = UFO.SubTypes.BLUE;
local ufoGreenSubType = UFO.SubTypes.GREEN;
local ufoColorfulSubType = UFO.SubTypes.RAINBOW;

local bosses = THI.Bosses;
local TheAbandoned = bosses.TheAbandoned;
local TheSummoner = bosses.TheSummoner;
local Devilcrow = bosses.Devilcrow;
local TheCentipede = bosses.TheCentipede;
local Necrospyder = bosses.Necrospyder;
local Pyroplume = bosses.Pyroplume;
local Guppet = bosses.Guppet;
HPBars.BossDefinitions[ufoType.."."..ufoVariant] = {
	sprite = path .. "ufo_red.png",
	conditionalSprites = {
		{
			function(entity)
				return entity.SubType == ufoBlueSubType or (entity.SubType == ufoColorfulSubType and entity.FrameCount % 4 == 1);
			end,
			path .. "ufo_blue.png"
		},
		{
			function(entity)
				return entity.SubType == ufoGreenSubType or (entity.SubType == ufoColorfulSubType and entity.FrameCount % 4 == 2);
			end,
			path .. "ufo_green.png"
		},
		{
			function(entity)
				return entity.SubType == ufoColorfulSubType and entity.FrameCount % 4 == 3;
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


-- Reverie.
local Notes = THI.Bosses.ReverieNote;

local conditionalSpr = {};
for _, subtype in pairs(Notes.SubTypes) do
	table.insert(conditionalSpr, {
		function(entity)
			return entity.SubType == subtype;
		end,
		path .. "reverie/note_"..subtype..".png"
	});
end
HPBars.BossDefinitions[Notes.Type.."."..Notes.Variant] = {
	sprite = path .. "reverie/note_0.png",
	conditionalSprites = conditionalSpr,
	offset = Vector(0, 0)
};

HPBars.BossIgnoreList[Notes.Type.."."..Notes.Variant] = function(entity)
	return not Notes:IsNoteActive(entity);
end