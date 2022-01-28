local ModPart = CuerLib.ModComponents.ModPart;
local Detection = CuerLib.Detection;
local Pickups = CuerLib.Pickups;
local Dream = ModPart:New("Gensou Dream", "GENSOU_DREAM");
GensouDream = Dream;

if (Game():GetFrameCount() <= 0) then
    GensouFocusPause = Options.PauseOnFocusLost;
end

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
        OutroPlayed = false,
        EndingPlayed = false,
        MusicPlayed = false,
        Cleared = false,
        Dialog = {
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
            Name = ""
        },
        WhiteScreenAlpha = 0,
        WhiteScreenAlphaSpeed = 0,
        BlackScreenAlpha = 0,
        BlackScreenAlphaSpeed = 0,
    }
end



function Dream:GetDreamData()
    return Dream:GetGlobalData(true, GetDefaultGlobalData);
end


GensouDreamTempData = GensouDreamTempData or GetDefaultTempData();

function Dream:GetTempData()
    return GensouDreamTempData;
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
local DreamWorldRoomVariant = 58123;
local musicID = Isaac.GetMusicIdByName("Doremy");

local CodeUtil = include("utilities/code_utility");

local Require = CuerLib.Require;

Dream.SpellCardEffect = Require("scripts/doremy/effects/spell_card_effect")
Dream.SpellCard = Require("scripts/doremy/spell_card");


Dream.SpellCards = {
    {
        NonSpell = Require("scripts/doremy/non_spells/non_spell_1"),
        Spell = Require("scripts/doremy/spell_cards/scarlet_nightmare"),
        NameTextKey = "#SPELL_CARD_SCARLET_NIGHTMARE",
    },
    {
        NonSpell = Require("scripts/doremy/non_spells/non_spell_2"),
        Spell = Require("scripts/doremy/spell_cards/ochre_confusion"),
        NameTextKey = "#SPELL_CARD_OCHRE_CONFUSION",
    },
    {
        NonSpell = Require("scripts/doremy/non_spells/non_spell_3"),
        Spell = Require("scripts/doremy/spell_cards/dream_express"),
        NameTextKey = "#SPELL_CARD_DREAM_EXPRESS",
    },
    {
        NonSpell = Require("scripts/doremy/non_spells/non_spell_4"),
        Spell = Require("scripts/doremy/spell_cards/dream_catcher"),
        NameTextKey = "#SPELL_CARD_DREAM_CATCHER",
    }
}

Dream.Doremy = Require("scripts/doremy/entities/doremy");
Dream.Dialog = Require("scripts/doremy/dialogs/dialog");

local IntroRunner = Require("scripts/doremy/dialogs/intro");
local OutroRunner = Require("scripts/doremy/dialogs/outro");
local EndingRunner = Require("scripts/doremy/dialogs/ending");

local function CreateDoremy() 
    Isaac.Spawn(Dream.Doremy.Type, Dream.Doremy.Variant, 0, Vector(320, 280), Vector.Zero, nil);
end


local function CreateDreamBack() 
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();

    local plate = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.PlateSubtype, Vector.Zero, Vector.Zero, nil);
    plate.DepthOffset = 80;
    plate:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    local spellCard = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.SpellCardSubtype, center, Vector.Zero, nil);
    spellCard:GetSprite().Color = Dream:GetTempData().SpellCardBG.Color;
    spellCard.DepthOffset = -center.Y +50;
    spellCard:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    local redMeridian = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.BackgroundSubtype, center, Vector.Zero, nil);
    redMeridian:GetSprite():Play("RedScroll");
    redMeridian.DepthOffset = -center.Y +2;
    redMeridian:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)

    local blueMeridian = Isaac.Spawn(DreamBack.Type, DreamBack.Variant, DreamBack.BackgroundSubtype, center, Vector.Zero, nil);
    blueMeridian:GetSprite():Play("BlueScroll");
    blueMeridian.DepthOffset = -center.Y +1;
    blueMeridian:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
end

local function IsDreamWorld()
    
    local room = THI.Game:GetRoom();
    local level = THI.Game:GetLevel();
    local desc = level:GetCurrentRoomDesc();
    local config = desc.Data;
    return config.Type == DreamWorldRoomType and config.Variant == DreamWorldRoomVariant;
end

----------------
-- Events
----------------

local function StartIntro() 
    local globalData = Dream:GetDreamData();
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

function Dream:onNewRoom()

    local globalData = Dream:GetDreamData();
    local room = THI.Game:GetRoom();
    
    GensouDreamTempData = GetDefaultTempData();


    -- Dream Soul spawn while Ascent.
    local hasDadsNote = false;
    local hasDreamSoul = false;
    for i, player in Detection.PlayerPairs() do 
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_DADS_NOTE)) then
            hasDadsNote = true;
        end
        if (player:HasCollectible(DreamSoul.Id)) then
            hasDreamSoul = true;
        end
    end
    if (hasDadsNote and not hasDreamSoul) then
        -- if has dad's note and don't has dream soul.
        local level = THI.Game:GetLevel();
        local room = THI.Game:GetRoom();
        local stage = level:GetStage();
        if (stage == 1 and level:GetStageType() == 0 and room:GetType() == RoomType.ROOM_TREASURE) then
            -- if it's stage 1 treasure room.
            local dreamSoulExists = #Isaac.FindByType(5,100, DreamSoul.Id) > 0;
            local dreamSoulSpawned = globalData.DreamSoulSpawned;
            if (not dreamSoulExists and not dreamSoulSpawned) then
                local pos = room:FindFreePickupSpawnPosition(Vector(320, 280), 0, true);
                Pickups.SpawnFixedCollectible(DreamSoul.Id, pos, Vector.Zero, nil);
                globalData.DreamSoulSpawned = true;
            end
        end
    end

    if (IsDreamWorld()) then
        for i=0, 7 do
            room:RemoveDoor(i);
        end
        CreateDreamBack();
        if (not globalData.IntroPlayed) then
            StartIntro();
        else
            CreateDoremy();
        end
    else
        -- Home Update.
        local level = THI.Game:GetLevel();
        local stage = level:GetStage();
        if (stage == LevelStage.STAGE8 and level:GetStageType() == 0) then
            -- If it's home, and not dogma home.
            
            if (globalData.DreamTriggered) then
                
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
    local globalData = Dream:GetDreamData();
    local tempData = Dream:GetTempData(); 

    -- Dream World Update.
    if (IsDreamWorld()) then
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
            Options.PauseOnFocusLost = false;
            local runner = tempData.Dialog.Runner;
            if (runner) then
                runner:Run();
                if (runner:IsFinished()) then
                    tempData.Dialog.Runner = nil;
                    tempData.Dialog.Running = false;
                    Options.PauseOnFocusLost = GensouFocusPause;
                end
            end
        else
            -- If no dialog is running.
            if (globalData.IntroPlayed) then
                local hasDoremy = false;
                for k, v in pairs(Isaac.FindByType(Dream.Doremy.Type, Dream.Doremy.Variant)) do
                    if (not v:IsDead()) then
                        hasDoremy = true;
                    end
                end
                -- Play Music.
                if (hasDoremy) then
                    if (MusicManager():GetCurrentMusicID() ~= musicID and not tempData.MusicPlayed) then
                        local music = MusicManager();
                        music:Play(musicID, 0);
                        music:UpdateVolume()
                        tempData.MusicPlayed = true;
                    end
                else
                    if (MusicManager():GetCurrentMusicID() == musicID) then
                        MusicManager():Fadeout();
                    end
                    tempData.Cleared = true;
                end
            end

            if (tempData.Cleared) then
                if (not tempData.OutroPlayed) then
                    tempData.BlackScreenAlphaSpeed = 0.01;
                    if (tempData.BlackScreenAlpha >= 1) then
                        THI.Game:End(0);
                        StartOutro();
                    end
                elseif (not tempData.EndingPlayed) then
                    StartEnding();
                end
            end
        end
    else
        
        -- Home Update.
        local level = THI.Game:GetLevel();
        local stage = level:GetStage();
        if (stage == LevelStage.STAGE8 and level:GetStageType() == 0) then
            -- If it's home, and not dogma home.
            local roomDesc = level:GetCurrentRoomDesc ( );
            local room = THI.Game:GetRoom();
            if (roomDesc.ListIndex == 3) then
                -- If the room is before mom's room.
                if (not globalData.DreamTriggered) then
                    local isInFrontOfDoor = false;
                    local hasDreamSoul = false;
                    for i, player in Detection.PlayerPairs() do
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
                        for i, player in Detection.PlayerPairs() do
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
                    for i, player in Detection.PlayerPairs() do
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
                        THI.GotoRoom("s.planetarium.58123")
                        tempData.BlackScreenAlpha = 1;
                        tempData.GoingDream = false;
                        for i, player in Detection.PlayerPairs() do
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
    local paused = THI.Game:IsPaused()
    if (not paused or tempData.WhiteScreenAlphaSpeed < 0) then
        tempData.WhiteScreenAlpha = math.max(0, math.min(1, tempData.WhiteScreenAlpha + tempData.WhiteScreenAlphaSpeed / 2));
    end

    if (not paused or tempData.BlackScreenAlphaSpeed < 0) then
        tempData.BlackScreenAlpha = math.max(0, math.min(1, tempData.BlackScreenAlpha + tempData.BlackScreenAlphaSpeed / 2));
    end
end

Dream:AddCallback(ModCallbacks.MC_POST_RENDER, Dream.postRender);

function Dream:getShaderParams(shaderName) 
    local tempData = Dream:GetTempData(); 
    if (shaderName == "Reverie White Screen") then
        return {
            Alpha = tempData.WhiteScreenAlpha;
        }
    elseif (shaderName == "Reverie Black Screen") then
        return {
            Alpha = tempData.BlackScreenAlpha;
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
Dream:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, Dream.playerTakeDamage, EntityType.ENTITY_PLAYER);


function Dream:postBackgroundUpdate(effect)
    local tempData = Dream:GetTempData(); 
    if (effect.SubType == DreamBack.BackgroundSubtype) then
        effect.SpriteRotation = math.sin(THI.Game:GetFrameCount() / 150) * 5;
    elseif (effect.SubType == DreamBack.SpellCardSubtype) then
        local frame = THI.Game:GetFrameCount();
        local room = THI.Game:GetRoom();
        local center = room:GetCenterPos();
        effect.Position = center + Vector.FromAngle(frame) * 30;
        effect.SpriteRotation = math.sin(frame / 30) * 5;
        effect:GetSprite().Color = tempData.SpellCardBG.Color;
    end 
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Dream.postBackgroundUpdate, DreamBack.Variant);



GensouDream = nil;
return Dream;