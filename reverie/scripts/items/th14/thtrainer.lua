local Collectibles = CuerLib.Collectibles;
local Players = CuerLib.Players;
local THTRAINER = ModItem("THTRAINER", "THTRAINER");

THTRAINER.ErrorRoomVariants = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
5800,5801,5802,5803,5804,5805,5806,5807,5808,5809,5810,5811, 5812, 5813, 5814, 5815
}

local function GetPlayerTempData(player, create)
    return THTRAINER:GetTempData(player, create, function()
        return {
            ResetPosition = nil
        }
    end);
end

local function RoomDataFits(data, targetDesc)
    if (data and targetDesc) then
        if (targetDesc.Data) then
            return data.Doors & targetDesc.Data.Doors == targetDesc.Data.Doors and data.Shape == targetDesc.Data.Shape;
        end
    end
    return false;
end

local function FindSuitableErrorData(roomDesc, seed)
    local game = Game();
    local level = game:GetLevel();
    local variantPool = {};
    for i = 1, #THTRAINER.ErrorRoomVariants do
        variantPool[i] = THTRAINER.ErrorRoomVariants[i];
    end
    
    repeat 
        local index = seed % #variantPool + 1;
        local variant = variantPool[index];
        Isaac.ExecuteCommand("goto s.error."..variant);
        local errorDesc = level:GetRoomByIdx(-3);
        
        if (errorDesc.Data and RoomDataFits(errorDesc.Data, roomDesc)) then
            return errorDesc.Data;
        end
        table.remove(variantPool, index);
    until (#variantPool <= 0)

    
    Isaac.ExecuteCommand("goto s.error.0");
    local errorDesc = level:GetRoomByIdx(-3);
    return errorDesc.Data;
end


local function PostNewStage(mod)
    local game = Game();
    local room = game:GetRoom();
    for p, player in Players.PlayerPairs() do
        local data = GetPlayerTempData(player, false);
        if (data and data.ResetPosition) then
            data.ResetPosition = nil;
        end
    end
end
THTRAINER:AddCustomCallback(CuerLib.CLCallbacks.CLC_NEW_STAGE, PostNewStage)

local function PostNewLevel(mod)
    if (Collectibles.IsAnyHasCollectible(THTRAINER.Item)) then

        local game = Game();
        local seeds = game:GetSeeds();
        local level = game:GetLevel();
        local rooms = level:GetRooms();
        local startRoomIndex = level:GetCurrentRoomIndex();
        for p, player in Players.PlayerPairs() do
            local data = GetPlayerTempData(player, true);
            data.ResetPosition = player.Position;
        end
        
        local rng = RNG();
        rng:SetSeed(seeds:GetStageSeed(level:GetStage()), 0);
        for i = 0, rooms.Size - 1 do
            local desc = rooms:Get(i);
            if (desc and desc.Data and desc.Data.Type == RoomType.ROOM_SUPERSECRET) then
                local index = desc.SafeGridIndex;
                local errorData = FindSuitableErrorData(desc, rng:Next());
                if (errorData) then
                    -- Only roomDesc got by GetRoomByIdx can be modified.
                    level:GetRoomByIdx(index).Data = errorData;
                end
            end
        end
        game:StartRoomTransition(startRoomIndex, 0, RoomTransitionAnim.WALK);
    end
end
THTRAINER:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel)


local function PreEntitySpawn(mod, type, variant, subtype, position, velocity, spawner, seed)
    if (type == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE and subtype == THTRAINER.Item) then
        return {type, variant, CollectibleType.COLLECTIBLE_TMTRAINER, seed};
    end
end
THTRAINER:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, PreEntitySpawn)

local function PostPickupSelection(mod, pickup, variant, subtype)
    if (variant == PickupVariant.PICKUP_COLLECTIBLE and subtype == THTRAINER.Item) then
        return {variant, CollectibleType.COLLECTIBLE_TMTRAINER};
    end
end
THTRAINER:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, PostPickupSelection)

local function PostNewRoom(mod)
    for p, player in Players.PlayerPairs() do
        local data = GetPlayerTempData(player, false);
        if (data and data.ResetPosition) then
            player.Position = data.ResetPosition;
            data.ResetPosition = nil;
        end
    end
end
THTRAINER:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

return THTRAINER;