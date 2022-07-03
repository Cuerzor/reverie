local Detection = CuerLib.Detection;
local Collectibles = CuerLib.Collectibles;
local Sake = ModItem("Sake of Forgotten", "SAKE_OF_FORGOTTEN")

local function GetGlobalData(create)
    return Sake:GetGlobalData(create, function()
        return {
            BottleSpawned = false
        }
    end)
end

function Sake:IsBottleSpawned()
    local data = GetGlobalData(false);
    return (data and data.BottleSpawned);
end
function Sake:ClearBottleSpawned()
    local data = GetGlobalData(true);
    data.BottleSpawned = false;
end

function Sake:SpawnBottle()
    local data = GetGlobalData(true);
    data.BottleSpawned = true;

    local Bottle = THI.Pickups.SakeBottle;
    local room = Game():GetRoom();
    local center = room:GetCenterPos();
    local pos = room:FindFreePickupSpawnPosition(center + Vector(40, 80));

    local bottle = Isaac.Spawn(Bottle.Type, Bottle.Variant, Bottle.SubType, pos, Vector.Zero, nil);
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bottle.Position, Vector.Zero, nil);
end

function Sake:HasClearObject()
    local room = Game():GetRoom();
    local gridSize = room:GetGridSize();
    if (#Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST) > 0) then
        return true;
    end
    if (#Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY) > 0) then
        return true;
    end
    if (#Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR) > 0) then
        return true;
    end

    for i = 0, gridSize do
        local gridEntity = room:GetGridEntity(i);
        if (gridEntity) then
            if (gridEntity:GetType() == GridEntityType.GRID_TRAPDOOR) then
                return true;
            elseif (gridEntity:GetType() == GridEntityType.GRID_DOOR) then
                local door = gridEntity:ToDoor();
                if (door.TargetRoomType == RoomType.ROOM_SECRET_EXIT) then
                    return true;
                end
            end
        end
    end
end

function Sake:CanStageSpawnBottle(stage)
    local level = Game():GetLevel();
    return level:CanStageHaveCurseOfLabyrinth (stage) 
    or stage == LevelStage.STAGE4_3 
    or stage == LevelStage.STAGE5
    or stage == LevelStage.STAGE6
    or stage == LevelStage.STAGE7
    or stage == LevelStage.STAGE8;
end


local function PostUpdate(mod)
    local room = Game():GetRoom();
    local stage = Game():GetLevel():GetStage();
    if (room:GetType() == RoomType.ROOM_BOSS and room:IsClear() and room:GetFrameCount() > 1) then
        local Bottle = THI.Pickups.SakeBottle;
        if (Collectibles.IsAnyHasCollectible(Sake.Item) and not Bottle:IsForgottingStage()) then
            if (not Sake:IsBottleSpawned()) then
                if (Sake:CanStageSpawnBottle(stage) and Sake:HasClearObject()) then
                    Sake:SpawnBottle();
                end
            end
        end
    end
end
Sake:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)


local function PostNewLevel(mod)
    Sake:ClearBottleSpawned();
end
Sake:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel)

return Sake;