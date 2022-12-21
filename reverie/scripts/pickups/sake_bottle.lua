local Players = CuerLib.Players;
local Bottle = ModEntity("Sake Bottle", "SAKE_BOTTLE");
Bottle.SubType = 0;

local particleColor = Color(0.2, 0.2, 0.1, 1, 0, 0, 0);

local function GetGlobalData(create)
    return Bottle:GetGlobalData(create, function()
        return {
            ForgottingStage = nil
        }
    end)
end

local function GetBottleData(bottle, create)
    return Bottle:GetTempData(bottle, create, function()
        return {
            LastTouched = false,
            Touched = false,
            TouchPlayer = nil,
        }
    end)
end

function Bottle:GetForgottingStage()
    local data = GetGlobalData(false)
    return (data and data.ForgottingStage and data.ForgottingStage.Stage) or nil;
end
function Bottle:GetForgottingStageType()
    local data = GetGlobalData(false)
    return (data and data.ForgottingStage and data.ForgottingStage.Type) or nil;
end
function Bottle:SetForgottingStage(stage, type)
    local data = GetGlobalData(true)
    data.ForgottingStage = {Stage = stage, Type = type};
end
function Bottle:ClearForgottingStage()
    local data = GetGlobalData(true)
    data.ForgottingStage = nil;
end



function Bottle:IsForgottingStage()
    local forgotStage = Bottle:GetForgottingStage();
    local forgotStageType = Bottle:GetForgottingStageType()
    if (forgotStage and forgotStageType) then
        local level = Game():GetLevel();
        local stage = level:GetStage();
        local stageType = level:GetStageType();
        if (stage == forgotStage and stageType == forgotStageType) then
            return true;
        end
    end
    return false;
end

local function PostNewRoom(mod)
    if (Bottle:IsForgottingStage()) then
        for p, player in Players.PlayerPairs() do
            local effect = player:GetEffects()
            if (not effect:HasNullEffect(NullItemID.ID_LOST_CURSE)) then
                effect:AddNullEffect(NullItemID.ID_LOST_CURSE);
            end
        end
    else
        if (Bottle:GetForgottingStage()) then
            for p, player in Players.PlayerPairs() do
                local effect = player:GetEffects()
                if (effect:HasNullEffect(NullItemID.ID_LOST_CURSE)) then
                    effect:RemoveNullEffect(NullItemID.ID_LOST_CURSE);
                end
            end
        end
    end
end
Bottle:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);


local function PostNewLevel(mod)
    if (not Bottle:IsForgottingStage()) then
        if (Bottle:GetForgottingStage()) then
            Bottle:ClearForgottingStage();
        end
    end
end
Bottle:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

local function PostCurseEvaluate(mod, curse)
    if (Bottle:IsForgottingStage()) then
        local level = Game():GetLevel();
        local stage = level:GetStage();
        curse = curse | LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_MAZE;
        if (level:CanStageHaveCurseOfLabyrinth (stage)) then
           curse = curse | LevelCurse.CURSE_OF_LABYRINTH;
        end 
        return curse;
    end
end
Bottle:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, PostCurseEvaluate);


local function UpdateBottle(bottle)

    if (Game():GetLevel():IsAscent()) then
        bottle:Remove();
    end

    local data = GetBottleData(bottle, false);
    local spr = bottle:GetSprite();
    if (data) then
        if (data.LastTouched ~= data.Touched) then
            
            data.LastTouched = data.Touched;
            if (data.Touched) then
                spr:Play("Drink");
            else
                spr:Play("Restore");
            end
        end
        if (data.Touched) then
            local player = data.TouchPlayer;

            if (spr:IsFinished("Drink") and player) then
                spr:Play("Idle");
                THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
                local level = Game():GetLevel();
                Bottle:SetForgottingStage(level:GetStage(), level:GetStageType());
                local flags = UseFlag.USE_MIMIC | UseFlag.USE_NOANIM;
                player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, flags, -1);
            end

            if (not player or player.Position:Distance(bottle.Position) > player.Size + bottle.Size + 5) then
                data.Touched = false;
                data.TouchPlayer = nil;
            end
        end
    end
    if (spr:IsFinished("Restore")) then
        spr:Play("Idle");
    end

    if (bottle.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND) then
        THI:RemoveRecentRewards(bottle.Position);

        bottle:Remove();
        SFXManager():Play(SoundEffect.SOUND_POT_BREAK_2, 1);
        SFXManager():Play(SoundEffect.SOUND_GASCAN_POUR, 1);

        Game():SpawnParticles (bottle.Position, EffectVariant.ROCK_PARTICLE, 5, 5, particleColor);
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, bottle.Position, Vector.Zero, bottle):ToEffect();
        
        local creepScale = 1
		creep:GetSprite():SetFrame("BiggestBlood0"..creep.InitSeed % 6, 0)

        creep.LifeSpan = 280;
        creep.Timeout = creep.LifeSpan;
        creep.Scale = creepScale
        creep.Size = creepScale
        creep.SpriteScale = Vector.Zero
        creep:Update();
    end
end

local function PostUpdate(mod)
    for _, ent in ipairs(Isaac.FindByType(Bottle.Type, Bottle.Variant)) do
        UpdateBottle(ent);
    end
end
Bottle:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

local function OnBottleTouch(player, slot)
    if (player.Variant == 0 and not player:IsCoopGhost()) then
        local data = GetBottleData(slot, true);
        data.Touched = true;
        data.TouchPlayer = player;
    end
end
THI:OnSlotTouch(OnBottleTouch, Bottle.Variant)

local function PrePlayerCollision(mod, player, other, low)
    if (other.Type == Bottle.Type and other.Variant == Bottle.Variant) then
        return true;
    end
end
Bottle:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PrePlayerCollision)

-- local function PostPickupUpdate(mod, pickup)
--     if (pickup.SubType == Bottle.SubType) then
--         local data = GetBottleData(pickup, false);
--         local spr = pickup:GetSprite();
--         if (data) then
--             if (data.LastTouched ~= data.Touched) then
                
--                 data.LastTouched = data.Touched;
--                 if (data.Touched) then
--                     spr:Play("Drink");
--                 else
--                     spr:Play("Restore");
--                 end
--             end
--             if (data.Touched) then
--                 local player = data.TouchPlayer;

--                 if (spr:IsFinished("Drink") and player) then
--                     spr:Play("Idle");
--                     THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
--                     local level = Game():GetLevel();
--                     Bottle:SetForgottingStage(level:GetStage(), level:GetStageType());
--                     local flags = UseFlag.USE_MIMIC | UseFlag.USE_NOANIM;
--                     player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, flags, -1);
--                 end

--                 if (not player or player.Position:Distance(pickup.Position) > player.Size + pickup.Size + 5) then
--                     data.Touched = false;
--                     data.TouchPlayer = nil;
--                 end
--             end
--         end
--         if (spr:IsFinished("Restore")) then
--             spr:Play("Idle");
--         end
        
--         local room = Game():GetRoom();
--         if (room:GetType() ~= RoomType.ROOM_DUNGEON) then
--             pickup.Velocity = pickup.TargetPosition - pickup.Position;
--         end
--     end
-- end
-- Bottle:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, Bottle.Variant);

-- local function PrePickupCollision(mod, pickup, other, low)
--     if (pickup.SubType == Bottle.SubType) then
--         if (other.Type == EntityType.ENTITY_PLAYER and other.Variant == 0) then
--             local player = other:ToPlayer();
--             if (not player:IsCoopGhost()) then
--                 local data = GetBottleData(pickup, true);
--                 data.Touched = true;
--                 data.TouchPlayer = player;
--                 return true;
--             end
--         elseif (other.Type == EntityType.ENTITY_PICKUP or other.Type == EntityType.ENTITY_MOVABLE_TNT) then
--             return false;
--         end
--     end
-- end
-- Bottle:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PrePickupCollision, Bottle.Variant)


return Bottle;