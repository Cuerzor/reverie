local Players = CuerLib.Players;
local Rooms = CuerLib.Rooms;
local Detector = ModItem("Geomantic Detector", "GEOMANTIC_DETECTOR");

Detector.CachedLuck = 0;
Detector.UnitLuck = 0.05;

function Detector:GetGridLuck(room, index)
    if (not room:IsPositionInRoom(room:GetGridPosition(index), 0)) then
        return 0;
    end

    local gridEnt = room:GetGridEntity(index);

    
    if (gridEnt) then
        local gridType = gridEnt:GetType();
        local gridVariant = gridEnt:GetVariant();
        local gridState = gridEnt.State;
        if (gridType == GridEntityType.GRID_DECORATION) then
            --if (gridVariant < 4096) then
            --end
            return Detector.UnitLuck;
        elseif (gridType == GridEntityType.GRID_SPIKES or 
        gridType == GridEntityType.GRID_SPIKES_ONOFF or 
        gridType == GridEntityType.GRID_DOOR or
        gridType == GridEntityType.GRID_FIREPLACE) then
            return 0;
        elseif (gridType == GridEntityType.GRID_SPIDERWEB) then
            return Detector.UnitLuck;
        else
            if (gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
                return Detector.UnitLuck;
            end
        end
        return 0;
    end
    return Detector.UnitLuck;
end

function Detector:GetRoomLuck()
    local luck = -3;
    local room = Game():GetRoom();
    local level = Game():GetLevel();
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    for x = 1, width -1 do
        for y = 1, height - 1 do
            local index = x + y * width;
            luck = luck + Detector:GetGridLuck(room, index);
        end
    end


    luck = luck - Detector.UnitLuck * #Isaac.FindByType(EntityType.ENTITY_FIREPLACE);
    
    local currentRoom = level:GetCurrentRoomDesc ();
    local roomData = currentRoom.Data;
    if (roomData) then
        local shape = roomData.Shape;
        local adjacentIndexes = Rooms.GetAdjacentIndexes(currentRoom.GridIndex, shape)
        for _, index in ipairs(adjacentIndexes) do
            local roomDesc = level:GetRoomByIdx(index);
            local roomDescData = roomDesc and roomDesc.Data;
            if (roomDescData) then
                if (roomDescData.Type == RoomType.ROOM_SECRET or roomDescData.Type == RoomType.ROOM_SUPERSECRET) then
                    luck = luck + 3;
                end
            end
        end
    end

    return luck;
end

function Detector:EvaluateAllPlayersLuck()
    for p, player in Players.PlayerPairs(true, true) do
        if (player:HasCollectible(Detector.Item)) then
            player:AddCacheFlags(CacheFlag.CACHE_LUCK);
            player:EvaluateItems();
        end
    end
end

function Detector:ReevaluateRoomLuck()
    
    local roomLuck = Detector:GetRoomLuck();
    if (Detector.CachedLuck ~= roomLuck) then
        Detector.CachedLuck = roomLuck;
        Detector:EvaluateAllPlayersLuck();
    end
end


local function PostUpdate(mod)
    if (Game():GetRoom():GetFrameCount() % 15 == 1) then
        Detector:ReevaluateRoomLuck()
    end
end
Detector:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function EvaluateCache(mod, player, flag)
    if (player:HasCollectible(Detector.Item)) then
        if (flag == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + Detector.CachedLuck;
        end
    end
end
Detector:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

-- local function PostNewRoom(mod)
--     Detector:ReevaluateRoomLuck()
-- end
-- Detector:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


return Detector;