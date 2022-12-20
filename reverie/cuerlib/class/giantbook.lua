-- Codes are from Giantbook API.
local Lib =LIB;
local GiantBook = Lib:NewClass();

local hideJera = false

--layer #0 - popup
--layer #1 - screen (color 2)
--layer #2 - dust poof (color 1)
--layer #3 - dust poof (color 1)
--layer #4 - swirl poof (color 3)
--layer #5 - fire

local function Pause()
    local pickups = {};
    for _, ent in ipairs(Isaac.FindByType(5)) do
        pickups[GetPtrHash(ent)] = true;
    end
    hideJera = true;
	Isaac.GetPlayer(0):UseCard(Card.RUNE_JERA, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	--remove the newly spawned pickups.
    for _, ent in ipairs(Isaac.FindByType(5)) do
        if (not pickups[GetPtrHash(ent)]) then
            ent:Remove();
        end
    end
end

--giving jera back it's visual effect
local function UseJera()
	if not hideJera  then
		GiantBook.PlayGiantBook("Appear", "rune_02_jera.png", Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0), nil, true)
	end
end
GiantBook:AddCallback(ModCallbacks.MC_USE_CARD, UseJera, Card.RUNE_JERA)


do  -- Giant Book.
    local bigBook = Sprite()
    local maxFrames = { ["Appear"] = 33,  ["Shake"] = 36,  ["ShakeFire"] = 32,  ["Flip"] = 33 }
    local bookColors = { [0] = Color(1, 1, 1, 1, 0, 0, 0), [1] = Color(1, 1, 1, 1, 0, 0, 0), [2] = Color(1, 1, 1, 1, 0, 0, 0), [3] = Color(1, 1, 1, 1, 0, 0, 0), [4] = Color(1, 1, 1, 1, 0, 0, 0), [5] = Color(1, 1, 1, 1, 0, 0, 0) }
    local bookDuration = 0
    function GiantBook.PlayGiantBook(animName, popup, poofColor, bgColor, poof2Color, soundName, notHide) 
        bigBook:Load("gfx/ui/giantbook/giantbook.anm2", true)
        bigBook:ReplaceSpritesheet(0, popup)
        bigBook:LoadGraphics()
        bigBook:Play(animName, true)
        bookDuration = maxFrames[animName]
        bookColors[1] = bgColor
        bookColors[2] = poofColor
        bookColors[3] = poofColor
        bookColors[4] = poof2Color
        hideJera = true
        if not notHide then
            Pause()
            --if sound exists, play it
            if (soundName) then
                SFXManager():Play(soundName, 0.8, 0, false, 1)
            end
        end
    end

	
	local function Book_PostRender(mod)
		if bookDuration > 0 then
			if (Isaac.GetFrameCount() % 2 == 0) then
				bigBook:Update()
				bookDuration = bookDuration - 1
			end
			for i=5, 0, -1 do
				bigBook.Color = bookColors[i]
				local screenCenter = Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2)
				bigBook:RenderLayer(i, screenCenter, Vector(0,0), Vector(0,0))
			end
		end
		if bookDuration == 0 and hideJera then
			hideJera = false
		end
	end
	GiantBook:AddCallback(ModCallbacks.MC_POST_RENDER, Book_PostRender)
end

do --ACHIEVEMENT DISPLAY
	local achievementQueue = {}
	local bigPaper = Sprite()
	local paperFrames = 0
	local paperSwitch = false
	function GiantBook.ShowAchievement(gfx) 
		table.insert(achievementQueue, gfx)
	end

	-- Callbacks.
	local function PostRenderPaper(mod)
		if (paperFrames <= 0) then
			--setback
			if paperSwitch then
				--move on
				--Isaac.ConsoleOutput("Stopped! \n")
				for i = 1, #achievementQueue-1 do
					achievementQueue[i] = achievementQueue[i+1]
				end
				achievementQueue[#achievementQueue] = nil
				--false
				paperSwitch = false
			end
			--play in queue
			if (not paperSwitch) and (#achievementQueue > 0) then
				--play animation
				--Isaac.ConsoleOutput("Playing: " .. achievementQueue[1] .. "\n")
				bigPaper:Load("gfx/ui/achievement/cuerlib_achievement.anm2", true)
				bigPaper:ReplaceSpritesheet(2, achievementQueue[1])
				bigPaper:LoadGraphics()
				bigPaper:Play("Idle", true)
				--set variables and pause
				paperFrames = 41
				paperSwitch = true
				hideJera = true
				Pause()
			end
		else
		--visual
			--update sprites
			if (Isaac.GetFrameCount() % 2 == 0) then
				bigPaper:Update()
				paperFrames = paperFrames - 1
			end
		end
		
		--sound
		local sfx = SFXManager();
		if bigPaper:IsEventTriggered("paperIn") then
			sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
		end
		if bigPaper:IsEventTriggered("paperOut") then
			sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
		end
	end
	GiantBook:AddCallback(ModCallbacks.MC_POST_RENDER, PostRenderPaper)
	local function RenderOverlay(mod)
		if (paperFrames > 0) then
			--render
			for i=0, 3, 1 do
				local screenCenter = Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2)
				bigPaper:RenderLayer(i, screenCenter, Vector(0,0), Vector(0,0))
			end
		end
	end
	GiantBook:AddCallback(Lib.Callbacks.CLC_RENDER_OVERLAY, RenderOverlay)
end

return GiantBook