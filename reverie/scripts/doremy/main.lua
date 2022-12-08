local ModPart = CuerLib.ModComponents.ModPart;
local Entities = CuerLib.Entities;
local Pickups = CuerLib.Pickups;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;
local Math = CuerLib.Math;
local Dream = ModPart:New("Gensou Dream", "GENSOU_DREAM");
GensouDream = Dream;

Dream.States = {
    NULL = 0,
    NON_SPELL = 1,
    CHOOSING = 2,
    READY_SPELL_CARD = 3,
    SPELL_CARD = 4
}

local function GetDefaultGlobalData() 
    return {
        IntroPlayed = false,
        DreamTriggered = false,
        DreamSoulSpawned = false,
    };
end

local function GetDefaultTempData()
    return {
        GoingDream = false,
        GoingDreamTime = 0,
        
        IsInDream = false,

        OutroPlayed = false,
        EndingPlayed = false,
        MusicPlayed = false,
        Cleared = false,
        Dialog = {
            LastRunning = false,
            Running = false,
            Runner = nil
        },
        SpellCardBG = {
            Display = false,
            Color = Color(1,1,1,0)
        },
        SpellCardName = {
            Display = false,
            Alpha = 0,
            Time = 0,
            Name = "",
        },
        Doremy = nil,
        LastDoremyPosition = Vector(320, 280),
        FightData = {
            State = 0,
            Timeout = -1,
            ClearedSpells = {},
            SpellId = 1,
        },

        WhiteScreenAlpha = 0,
        WhiteScreenAlphaSpeed = 0,
        BlackScreenAlpha = 0,
        BlackScreenAlphaSpeed = 0,
    }
end



function Dream:GetDreamData(create)
    return Dream:GetGlobalData(create, GetDefaultGlobalData);
end


GensouDreamTempData = GensouDreamTempData or GetDefaultTempData();

function Dream:GetTempData()
    return GensouDreamTempData;
end
function Dream:SetTempData(data)
    GensouDreamTempData = data;
end


local DreamBack = {
    Type = Isaac.GetEntityTypeByName("Dream World Backdrop"),
    Variant = Isaac.GetEntityVariantByName("Dream World Backdrop"),
    PlateSubtype = 0,
    BackgroundSubtype = 1,
    SpellCardSubtype = 2
}
local DreamSoul = {
    Id = Isaac.GetItemIdByName("Dream Soul"),
}
local DreamCushion = {
    Type = Isaac.GetEntityTypeByName("Dream Cushion"),
    Variant = Isaac.GetEntityVariantByName("Dream Cushion")
}
local DreamBackEntityVariant = Isaac.GetEntityVariantByName("Dream World Backdrop");
local DreamWorldRoomType = RoomType.ROOM_PLANETARIUM;
local DreamWorldRoomVariant = 5800;
--THI.Shared.RoomGen:AddAdditionalRoom("planetarium", DreamWorldRoomVariant, -58123);

THI.Shared.SoftlockFix:AddModGotoRoom(DreamWorldRoomType, DreamWorldRoomVariant);

local musicID = Isaac.GetMusicIdByName("Doremy");

local Require = CuerLib.Require;

Dream.SpellCard = Require("scripts/doremy/spell_card");

local EmptySpell = Require("scripts/doremy/non_spells/empty_spell");
Dream.NonSpells = {
    Require("scripts/doremy/non_spells/non_spell_1"),
    Require("scripts/doremy/non_spells/non_spell_2"),
    Require("scripts/doremy/non_spells/non_spell_3"),
    Require("scripts/doremy/non_spells/non_spell_4")
}
Dream.SpellCards = {
    Require("scripts/doremy/spell_cards/scarlet_nightmare"),
    Require("scripts/doremy/spell_cards/creeping_bullet"),
    Require("scripts/doremy/spell_cards/dream_express"),
    Require("scripts/doremy/spell_cards/dream_catcher"),
    Require("scripts/doremy/spell_cards/butterfly_supplantation"),
    Require("scripts/doremy/spell_cards/ochre_confusion"),
    Require("scripts/doremy/spell_cards/ultramarine_lunatic_dream")
}

Dream.Doremy = Require("scripts/doremy/entities/doremy");
Dream.Dialog = Require("scripts/doremy/dialogs/dialog");
Dream.Effects = {
    NightmareTrail = Require("scripts/doremy/effects/nightmare_trail"),
    NightmareMegasatanHand = Require("scripts/doremy/effects/nightmare_megasatan_hand"),
    NightmareMothersShadow = Require("scripts/doremy/effects/nightmare_mothers_shadow"),
    DreamCatcher = Require("scripts/doremy/effects/dream_catcher"),
    NightmareChoice = Require("scripts/doremy/effects/nightmare_choice"),
    DreamStar = Require("scripts/doremy/effects/dream_star")
}

local IntroRunner = Require("scripts/doremy/dialogs/intro");
local OutroRunner = Require("scripts/doremy/dialogs/outro");
local EndingRunner = Require("scripts/doremy/dialogs/ending");

local function CreateDoremy(position) 
    local doremy = Isaac.Spawn(Dream.Doremy.Type, Dream.Doremy.Variant, 0, position or Vector(320, 280), Vector.Zero, nil);
    doremy:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
    doremy:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    return doremy;
end


local function CreateDreamBack() 
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();

    local pos = Vector(0, 80);
    local plate = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.PlateSubtype, pos, Vector.Zero, nil);
    plate.SpriteOffset = Vector(0, -48);
    plate:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    pos = Vector(0, 20);
    local spellCard = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.SpellCardSubtype, pos, Vector.Zero, nil);
    spellCard:GetSprite().Color = Dream:GetTempData().SpellCardBG.Color;
    spellCard.SpriteOffset = (center - pos) * 0.6;
    spellCard:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    pos = Vector(0, 2);
    local redMeridian = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.BackgroundSubtype, pos, Vector.Zero, nil);
    redMeridian:GetSprite():Play("RedScroll");
    spellCard.SpriteOffset = (center - pos) * 0.6;
    redMeridian:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    pos = Vector(0, 1);
    local blueMeridian = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.BackgroundSubtype, pos, Vector.Zero, nil);
    blueMeridian:GetSprite():Play("BlueScroll");
    spellCard.SpriteOffset = (center - pos) * 0.6;
    blueMeridian:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
end

-- Dialogs.
local function StartIntro() 
    local globalData = Dream:GetDreamData(true);
    globalData.IntroPlayed = true;
    local dialogData = Dream:GetTempData().Dialog;
    dialogData.Running = true;
    dialogData.Runner = IntroRunner:New();
    dialogData.Runner:Start();
end

local function StartOutro()
    local tempData = Dream:GetTempData(); 
    local dialogData = tempData.Dialog;
    tempData.OutroPlayed = true;
    dialogData.Running = true;
    dialogData.Runner = OutroRunner:New();
    dialogData.Runner:Start();
end

local function StartEnding() 
    local tempData = Dream:GetTempData(); 
    local dialogData = tempData.Dialog;
    tempData.EndingPlayed = true;
    dialogData.Running = true;
    dialogData.Runner = EndingRunner:New();
    dialogData.Runner:Start();
end

function Dream:IsDreamWorld()
    local game = Game();
    local room = game:GetRoom();
    local level = game:GetLevel();
    local desc = level:GetCurrentRoomDesc();
    local config = desc.Data;
    if (config) then
        return config.Type == DreamWorldRoomType and config.Variant == DreamWorldRoomVariant;
    end
    return false;
end
local function IsDreamWorld()
    return Dream:IsDreamWorld();
end


function Dream:StartChoosingDream()
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    fightData.Timeout = 30;
    fightData.State = Dream.States.CHOOSING;
end

function Dream:StartSpellCard(id)
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    fightData.Timeout = 70;
    fightData.State = Dream.States.READY_SPELL_CARD;
    fightData.SpellId = id;
end

function Dream:AddClearedSpellCard(id)
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    table.insert(fightData.ClearedSpells, id);
end

function Dream:IsSpellCardCleared(id)
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    for k,v in pairs(fightData.ClearedSpells) do
        if (v == id) then
            return true;
        end
    end
    return false;
end

function Dream:IsAllCleared()
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    return #fightData.ClearedSpells >= #self.SpellCards or fightData.IsEnd;
end
function Dream:EndBattle()
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    fightData.IsEnd = true;
end


function Dream:StartNonSpell()
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    local Doremy = Dream.Doremy;
    local doremy = tempData.Doremy;
    if (not doremy or not doremy:Exists() or doremy:IsDead()) then
        doremy = CreateDoremy(tempData.LastDoremyPosition);
    end
    doremy.MaxHitPoints = 400;
    doremy.HitPoints = doremy.MaxHitPoints;
    
    Doremy:SetWait(doremy, true, 30);
    Doremy:SetSpellCard(doremy, Random() % #self.NonSpells + 1, false);
    fightData.State = Dream.States.SPELL_CARD
    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU)
end

function Dream:UpdateFight()
    local tempData = self.GetTempData();
    local fightData = tempData.FightData;
    if (not self:IsAllCleared()) then
        if (fightData.State == Dream.States.CHOOSING) then
            if (fightData.Timeout >= 0) then
                fightData.Timeout = fightData.Timeout - 1;
            end
            if (fightData.Timeout == 0) then
                local Catcher = self.Effects.DreamCatcher;
                Isaac.Spawn(Catcher.Type, Catcher.Variant, Catcher.SubType, Game():GetRoom():GetCenterPos(), Vector.Zero, nil);
            end 
        elseif (fightData.State == Dream.States.READY_SPELL_CARD) then
            if (fightData.Timeout >= 0) then
                fightData.Timeout = fightData.Timeout - 1;
            end
            if (fightData.Timeout == 30) then
                local Doremy = Dream.Doremy;
                local doremy = CreateDoremy();
                Doremy:SetSpellCard(doremy, fightData.SpellId or 1, true);
                Doremy:SetWait(doremy, true, 30);
                doremy:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 30, 0, true);
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_SPELL_CARD)
            end 
            if (fightData.Timeout == 0) then
                fightData.State = Dream.States.SPELL_CARD
            end 
        elseif (fightData.State == Dream.States.SPELL_CARD) then
            if (not tempData.Doremy or not tempData.Doremy:Exists()) then
                Dream:StartNonSpell();
            end
        elseif (fightData.State == Dream.States.NON_SPELL) then
            if (not tempData.Doremy or not tempData.Doremy:Exists()) then
                Dream:StartChoosingDream();
            end
        end
    end
end

----------------
-- Events
----------------


function Dream:onNewRoom()

    local globalData = Dream:GetDreamData(false);
    local level = THI.Game:GetLevel();
    local room = THI.Game:GetRoom();

    local dreamWorld = IsDreamWorld();
    local tempData = Dream:GetTempData();
    local inDreamBefore = tempData.IsInDream

    Dream:SetTempData(GetDefaultTempData());

    tempData = Dream:GetTempData();
    if (dreamWorld ~= inDreamBefore) then
        tempData.IsInDream = dreamWorld;
        for p, player in Players.PlayerPairs(true, true) do
            player:AddCacheFlags(CacheFlag.CACHE_RANGE);
            player:EvaluateItems();
        end
    end

    -- Dream Soul spawn while Ascent.
    if (THI.IsBossEnabled("Doremy")) then
        local ascent = level:IsAscent();
        local hasDreamSoul = false;
        for i, player in Players.PlayerPairs() do 
            if (player:HasCollectible(DreamSoul.Id)) then
                hasDreamSoul = true;
            end
        end
        if (ascent and not hasDreamSoul) then
            -- if has dad's note and don't has dream soul.
            local stage = level:GetStage();
            if (stage == 1 and level:GetStageType() == 0 and room:GetType() == RoomType.ROOM_TREASURE) then
                -- if it's stage 1 treasure room.
                local dreamSoulExists = #Isaac.FindByType(5,100, DreamSoul.Id) > 0;
                local dreamSoulSpawned = globalData and globalData.DreamSoulSpawned;
                if (not dreamSoulExists and not dreamSoulSpawned) then
                    local pos = room:FindFreePickupSpawnPosition(Vector(320, 280), 0, true);
                    local collectible = Pickups.SpawnFixedCollectible(DreamSoul.Id, pos, Vector.Zero, nil);
                    collectible:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);
                    globalData = Dream:GetDreamData(true);
                    globalData.DreamSoulSpawned = true;
                end
            end
        end
    end

    if (IsDreamWorld()) then
        for i=0, 7 do
            room:RemoveDoor(i);
        end
        CreateDreamBack();
        if (not globalData or not globalData.IntroPlayed) then
            StartIntro();
        else
            Dream:StartNonSpell();
        end
    else
        -- Home Update.
        local level = THI.Game:GetLevel();
        local stage = level:GetStage();
        if (stage == LevelStage.STAGE8 and level:GetStageType() == 0) then
            -- If it's home, and not dogma home.
            
            if (globalData and globalData.DreamTriggered) then
                
                local roomDesc = level:GetCurrentRoomDesc ( );
                local room = THI.Game:GetRoom();
                if (roomDesc.ListIndex == 0) then
                    -- If the room is isaac's room.
                    local ent = Isaac.Spawn(DreamCushion.Type, DreamCushion.Variant, 0, Vector(320, 280), Vector.Zero, nil);
                    ent.DepthOffset = -279;
                end
                local music = MusicManager();
                music:Fadeout(1);
            end
        end
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dream.onNewRoom);

function Dream:postUpdate()
    local tempData = Dream:GetTempData(); 
    local music = MusicManager();

    -- Dream World Update.
    local dreamWorld = IsDreamWorld();
    if (dreamWorld) then


        local scBack = tempData.SpellCardBG;
        local alpha = scBack.Color.A;
        if (scBack.Display) then
            alpha = alpha + 1/30;
        else
            alpha = alpha - 1/30;
        end
        alpha = math.min(1, math.max(0, alpha));
        scBack.Color.A = alpha;

        
        if (tempData.Dialog.Running) then
            -- Run Dialog.

            local runner = tempData.Dialog.Runner;
            if (runner) then
                if (runner:IsFinished()) then
                    tempData.Dialog.Runner = nil;
                    tempData.Dialog.Running = false;
                else
                    runner:Run();
                end
            end
        else
            -- If no dialog is running.
            local globalData = Dream:GetDreamData(false);
            if (globalData and globalData.IntroPlayed) then
                -- local hasDoremy = false;
                -- for k, v in pairs(Isaac.FindByType(Dream.Doremy.Type, Dream.Doremy.Variant)) do
                --     if (not v:IsDead() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                --         hasDoremy = true;
                --     end
                -- end
                
                -- Play Music.
                local cleared = false;
                cleared = Dream:IsAllCleared();
                if (not cleared) then
                    if (music:GetCurrentMusicID() ~= musicID and not tempData.MusicPlayed) then
                        music:Play(musicID, 0);
                        music:UpdateVolume();
                        tempData.MusicPlayed = true;
                    end
                else -- Cleared.
                    if (music:GetCurrentMusicID() == musicID) then
                        music:Fadeout();
                        tempData.MusicPlayed = false;
                    end
                    tempData.Cleared = true;
                end
            end
        end
        -- Cleared.
        -- Start Outro and Ending.
        if (tempData.Cleared) then
            if (not tempData.Dialog.Running and not tempData.OutroPlayed) then
                tempData.BlackScreenAlphaSpeed = 0.01;
                if (tempData.BlackScreenAlpha >= 1) then
                    THI.Game:End(0);
                    StartOutro();
                end
            end
            if (not tempData.Dialog.Running and tempData.OutroPlayed and not tempData.EndingPlayed) then
                StartEnding();
            end
        end

        if (tempData.Dialog.LastRunning ~= tempData.Dialog.Running) then
            local Opt = THI.Shared.Options;
            if (tempData.Dialog.Running) then
                Opt:CancelPauseFocus();
            else
                Opt:ResumePauseFocus();
            end
            tempData.Dialog.LastRunning = tempData.Dialog.Running;
        end


    else
        
        -- Home Update.
        local level = THI.Game:GetLevel();
        local stage = level:GetStage();
        if (stage == LevelStage.STAGE8 and level:GetStageType() == 0) then
            -- If it's home, and not dogma home.
            
            local globalData = Dream:GetDreamData(true);
            local roomDesc = level:GetCurrentRoomDesc ( );
            local room = THI.Game:GetRoom();
            if (roomDesc.ListIndex == 3) then
                -- If the room is before mom's room.
                if (not globalData.DreamTriggered) then
                    local isInFrontOfDoor = false;
                    local hasDreamSoul = false;
                    for i, player in Players.PlayerPairs() do
                        if (player.Position.Y <= 270) then
                            isInFrontOfDoor = true;
                        end
                        if (player:HasCollectible(DreamSoul.Id)) then
                            hasDreamSoul = true;
                        end
                    end
                    if (isInFrontOfDoor and hasDreamSoul) then
                        room:RemoveDoor(1); 
                        local music = MusicManager();
                        music:Play(Music.MUSIC_BOSS_OVER_TWISTED, 0);
                        music:UpdateVolume();
                        music:Fadeout(0.01);
                        globalData.DreamTriggered = true;
                    end
                else
                    room:RemoveDoor(1);
                end
            elseif (roomDesc.ListIndex == 0) then
                -- If the room is isaac's room.
                if (globalData.DreamTriggered and not tempData.GoingDream) then

                    if (room:GetFrameCount() > 60) then
                        for i, player in Players.PlayerPairs() do
                            if ((player.Position - Vector(320, 280)):Length() <= 40) then
                                player:PlayExtraAnimation("DeathTeleport");
                                tempData.GoingDream = true;
                                tempData.GoingDreamTime = 0;
                                goto jumptoDream;
                            end
                        end

                        ::jumptoDream::
                    end
                end

                if (tempData.GoingDream) then
                    for i, player in Players.PlayerPairs() do
                        player.ControlsEnabled = false;
                        if (tempData.GoingDreamTime >= 15) then
                            local spr = player:GetSprite();
                            if (spr:GetAnimation() == "DeathTeleport") then
                                spr.PlaybackSpeed = 0;
                            end
                        end
                    end

                    tempData.GoingDreamTime = tempData.GoingDreamTime + 1;
                    tempData.BlackScreenAlphaSpeed = 0;
                    tempData.BlackScreenAlpha = tempData.GoingDreamTime / 40;

                    if (tempData.GoingDreamTime > 90) then
                        --THI.GotoAdditionalRoom(-58123);
                        THI.GotoRoom("s.planetarium."..DreamWorldRoomVariant)
                        tempData.BlackScreenAlpha = 1;
                        tempData.GoingDream = false;
                        for i, player in Players.PlayerPairs() do
                            local spr = player:GetSprite();
                            if (spr:GetAnimation() == "DeathTeleport") then
                                spr.PlaybackSpeed = 1;
                            end
                        end
                    end
                end
            end
            if (globalData.DreamTriggered) then
                local music = MusicManager();
                if (music:GetCurrentMusicID() ~= Music.MUSIC_BOSS_OVER_TWISTED) then
                    music:Fadeout(1);
                end
            end
        end
    end



    -- Find Doremy.
    local Doremy = Dream.Doremy;
    if (not tempData.Doremy or not tempData.Doremy:Exists() or tempData.Doremy:IsDead()) then
        tempData.Doremy = nil;
    end
    for i, doremy in ipairs(Isaac.FindByType(Doremy.Type, Doremy.Variant)) do
        if (doremy:Exists() and not doremy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local tempData = Dream:GetTempData();
            if (not tempData.Doremy or not tempData.Doremy:Exists() or tempData.Doremy:IsDead()) then
                tempData.Doremy = doremy;
            end
        end
    end

    -- Doremy Spell Card Effect.
    local doremy = tempData.Doremy;
    local scName = tempData.SpellCardName;
    local spellcarding = false;
    if (doremy) then
        spellcarding = Doremy:IsUsingSpellCard(doremy);
        tempData.LastDoremyPosition = doremy.Position;
    end
    tempData.SpellCardBG.Display = spellcarding;
    if (scName.Display ~= spellcarding) then
        scName.Display = spellcarding;
        if (spellcarding) then
            scName.Time = 0;
            local key = Doremy:GetUsingSpell(doremy).NameKey;
            local category = THI.StringCategories.DEFAULT;
            scName.Name = THI.GetText(category, key) or "404 Spell Card not found";
        end
    end

    -- Progress.
    Dream:UpdateFight();
    
    tempData.WhiteScreenAlpha = math.max(0, math.min(1, tempData.WhiteScreenAlpha + tempData.WhiteScreenAlphaSpeed));
    tempData.BlackScreenAlpha = math.max(0, math.min(1, tempData.BlackScreenAlpha + tempData.BlackScreenAlphaSpeed));
end
Dream:AddCallback(ModCallbacks.MC_POST_UPDATE, Dream.postUpdate);

function Dream:postRender()
    local tempData = Dream:GetTempData(); 
    if (tempData.Dialog.Running) then
        -- Render Dialog.
        local runner = tempData.Dialog.Runner;
        if (runner) then
            tempData.Dialog.Runner:Render();
        end
    end
    -- local paused = THI.Game:IsPaused()
    -- if (not paused or tempData.WhiteScreenAlphaSpeed < 0) then
    --     tempData.WhiteScreenAlpha = math.max(0, math.min(1, tempData.WhiteScreenAlpha + tempData.WhiteScreenAlphaSpeed / 2));
    -- end

    -- if (not paused or tempData.BlackScreenAlphaSpeed < 0) then
    --     tempData.BlackScreenAlpha = math.max(0, math.min(1, tempData.BlackScreenAlpha + tempData.BlackScreenAlphaSpeed / 2));
    -- end
end

Dream:AddCallback(ModCallbacks.MC_POST_RENDER, Dream.postRender);



local SpellCardNameFont = "DOREMY_SPELL_CARD";
local SpellCardNameSprite = Sprite()
SpellCardNameSprite:Load("gfx/doremy/ui/spell_card_name_underline.anm2", true);
SpellCardNameSprite:Play("Idle");
local function renderSpellName(mod)
    local tempData = Dream:GetTempData(); 
    local scName = tempData.SpellCardName;
    if (scName.Display) then
        scName.Alpha = 1;
    else
        scName.Alpha = scName.Alpha - 0.05;
    end

    if (scName.Alpha > 0) then
        local game = Game();
        local Doremy = Dream.Doremy;
        local doremy = tempData.Doremy;
        if (not game:IsPaused()) then
            scName.Time = scName.Time + 1;
        end

        local screenSize = Screen.GetScreenSize();
        local x = 0;
        local y = 0;
        if (scName.Time < 40) then
            x = (screenSize.X -180 ) * Math.EaseOut(scName.Time / 40);
        else
            x = screenSize.X - 180;
        end
        
        if (scName.Time < 40) then
            y = screenSize.Y - 20;
        elseif (scName.Time < 60) then
            y = (screenSize.Y - 20) * (1 -Math.EaseOut((scName.Time - 40) / 20));
        end

        local font = THI.GetFont(SpellCardNameFont);
        font:DrawStringUTF8(scName.Name,x,y,KColor(1,1,1,scName.Alpha),0,true) -- render string with loaded font on position 60x50y
        
        
        if (scName.Display) then
            local timeout = 99.99;
            if (doremy) then
                local spell = Doremy:GetUsingSpell(doremy);
                if (spell) then
                    local duration = spell:GetDuration();
                    timeout = (duration - Doremy:GetSpellFrame(doremy)) / 30;
                end
            end
            local timeoutStr = string.format("%2.2f", timeout);
            local timeColor = KColor(1,1,1,scName.Alpha);
            local scaleX = 1;
            local scaleY = 1;

            if (timeout <= 10) then
                if (timeout % 1 >= 0.5) then
                    scaleX = timeout % 1 + 0.5
                    scaleY = timeout % 1 + 0.5
                end
                timeColor.Green = 0;
                timeColor.Blue = 0;
            end
            font:DrawStringScaledUTF8(timeoutStr,x,y + 20, scaleX, scaleY,timeColor,0,true) -- render string with loaded font on position 60x50y
        end
        
        SpellCardNameSprite:Render(Vector(x, y), Vector.Zero, Vector.Zero);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_RENDER, renderSpellName);

local function PostPlayerUpdate(mod, player)
    local dialogRunner;
    local tempData = Dream:GetTempData(); 
    if (tempData.Dialog.Running) then
        dialogRunner = tempData.Dialog.Runner;
    end
    if (dialogRunner) then
        if (Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, player.ControllerIndex) or
        Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, player.ControllerIndex)) then
            dialogRunner:Finish();
        end
    end
    
    local room = Game():GetRoom();
    -- Bomb
    if (IsDreamWorld()) then
        local golden = player:HasGoldenBomb ( );
        if (player:AreControlsEnabled() and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex)) then
            local bombs = Isaac.FindByType(EntityType.ENTITY_BOMB);
            for _, ent in ipairs(bombs) do
                local bomb = ent:ToBomb();
                if (bomb.FrameCount == 0 and Entities.CompareEntity(bomb.SpawnerEntity, player)) then
                    local giga = bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA ;
                    local canBomb = false;
                    if (golden or giga) then
                        canBomb = true;
                    elseif (player:GetNumBombs() >= 9) then
                        canBomb = true;
                        player:AddBombs(-9);
                    end
                    if (canBomb) then
                        bomb:Remove();
                        room:MamaMegaExplosion(player.Position);
                        player:SetMinDamageCooldown(90);
                        break;
                    end
                end
            end
        end
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

local function PostPickupUpdate(mod, pickup)
    if (IsDreamWorld() and pickup.SubType <= 0) then
        pickup:Remove();
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE);

function Dream:getShaderParams(shaderName) 
    local tempData = Dream:GetTempData(); 
    if (shaderName == "Reverie White Screen") then
        return {
            Alpha = (tempData and tempData.WhiteScreenAlpha) or 0;
        }
    elseif (shaderName == "Reverie Black Screen") then
        return {
            Alpha = (tempData and tempData.BlackScreenAlpha) or 0;
        }
    end
end
Dream:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, Dream.getShaderParams);



function Dream:inputAction(entity, hook, action)
    local tempData = Dream:GetTempData(); 
    if (not THI.Game:IsPaused()) then
        if (tempData.Dialog.Running or tempData.Cleared) then
            if (hook == InputHook.IS_ACTION_TRIGGERED or hook == InputHook.IS_ACTION_PRESSED) then
                if (action == ButtonAction.ACTION_PAUSE or action == ButtonAction.ACTION_MENUBACK) then
                    return false;
                end
            end
        end
    end

    
    if (tempData.Cleared and tempData.OutroPlayed and tempData.Dialog.Running) then
        if (hook == InputHook.IS_ACTION_TRIGGERED or hook == InputHook.IS_ACTION_PRESSED) then
            if (action == ButtonAction.ACTION_CONSOLE or action == ButtonAction.ACTION_RESTART) then
                return false;
            end
        end
    end
end
Dream:AddCallback(ModCallbacks.MC_INPUT_ACTION, Dream.inputAction);

function Dream:playerTakeDamage(tookDamage, amount, flags, source, countdown)
    local tempData = Dream:GetTempData(); 
    if (tempData.Dialog.Running) then
        return false;
    end
end
Dream:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, Dream.playerTakeDamage, EntityType.ENTITY_PLAYER);

local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_RANGE) then
        if (IsDreamWorld()) then
            if (not player:HasWeaponType(WeaponType.WEAPON_BONE)) then
                player.TearRange = math.max(800, player.TearRange);
            end
        end
    end
end
Dream:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);


local SpellNames = {
    "Megasatan",
    "Lamb",
    "Mother",
    "TheBeast",
    "Bluebaby",
    "Greed",
    "Delirium"
}

function Dream:GetAnimationNameBySpellID(id)
    return SpellNames[id] or "Megasatan";
end

function Dream:SetSpellCardBackground(effect, name)
    local spr = effect:GetSprite();
    spr:Play(name);
end

function Dream:postBackgroundUpdate(effect)
    local tempData = Dream:GetTempData(); 
    if (effect.SubType == DreamBack.BackgroundSubtype) then
        effect.SpriteRotation = math.sin(THI.Game:GetFrameCount() / 150) * 5;
    elseif (effect.SubType == DreamBack.SpellCardSubtype) then
        local game = Game();
        local frame = game:GetFrameCount();
        local room =game:GetRoom();
        local center = (room:GetCenterPos() - effect.Position) * 0.6;
        effect.SpriteOffset = center + Vector.FromAngle(frame) * 30;
        effect.SpriteRotation = math.sin(frame / 30) * 5;
        effect:GetSprite().Color = tempData.SpellCardBG.Color;


        local doremy = tempData.Doremy;
        if (doremy and doremy:Exists()) then
            local Doremy = Dream.Doremy;
            local doremyData = Doremy.GetDoremyData(doremy);
            local targetState = doremyData.SpellId;
            if (Doremy:IsUsingSpellCard(doremy) and effect.State ~= targetState) then
                effect.State = targetState;
                local name = Dream:GetAnimationNameBySpellID(targetState);
                Dream:SetSpellCardBackground(effect, name)
            end
            
        end
    end 
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Dream.postBackgroundUpdate, DreamBack.Variant);



GensouDream = nil;
return Dream;