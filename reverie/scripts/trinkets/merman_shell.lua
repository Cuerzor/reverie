local Detection = CuerLib.Detection;
local Stats = CuerLib.Stats;
local Shell = ModTrinket("Merman Shell", "MERMAN_SHELL")

local function GetPlayerTempData(player, create)
    local function getter()
        return {
            WaterAmplify = 0;
        }
    end
    return Shell:GetTempData(player, create, getter);
end

local RoomTypeWhiteList = {
    RoomType.ROOM_BOSS,
    RoomType.ROOM_CHALLENGE,
    RoomType.ROOM_CURSE,
    RoomType.ROOM_DEFAULT,
    RoomType.ROOM_MINIBOSS,
}

function Shell.IsRoomIncluded(index)
    local level = Game():GetLevel();
    local startingRoomIndex = level:GetStartingRoomIndex ( );
    if (index == startingRoomIndex) then
        return false;
    end

    local room = level:GetRoomByIdx(index);
    if (room.Flags & RoomDescriptor.FLAG_FLOODED > 0) then
        return false;
    end

    local data = room.Data;
    if (data) then
        local roomType = data.Type;
        for i, type in pairs(RoomTypeWhiteList) do
            if (type == roomType) then
                return true;
            end
        end
    end
    return false;
end

do

    local function PostPlayerEffect(mod, player)
        local targetAmplify = 0;
        local hasWater= Game():GetRoom():HasWater();
        if (hasWater) then
            targetAmplify = player:GetTrinketMultiplier(Shell.Trinket);
        end

        local playerData = GetPlayerTempData(player, false);
        local waterAmplify = 0;
        if (playerData) then
            waterAmplify = playerData.WaterAmplify;
        end
        if (targetAmplify ~= waterAmplify) then
            playerData = GetPlayerTempData(player, true);
            playerData.WaterAmplify = targetAmplify;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end
    end
    Shell:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

    local function EvaluateCache(mod, player, flags)
        local playerData = GetPlayerTempData(player, false);
        local amplify = playerData and playerData.WaterAmplify;
        if (amplify and amplify > 0) then 
            if (flags == CacheFlag.CACHE_DAMAGE) then
                Stats:AddFlatDamage(player,2);
            elseif (flags == CacheFlag.CACHE_FIREDELAY) then
                Stats:AddTearsModifier(player, function(tears)
                    return tears + 1;
                end);
            elseif (flags == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed + 0.15;
            end
        end
    end
    Shell:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

    local function PostNewLevel()
        local trinketMultiplier = 0;
        for p, player in Detection.PlayerPairs() do
            trinketMultiplier = trinketMultiplier + player:GetTrinketMultiplier(Shell.Trinket);
        end

        
        if (trinketMultiplier > 0) then

            local game = Game();
            local level = game:GetLevel();
            local seeds = game:GetSeeds();
            local rng = RNG();
            rng:SetSeed(seeds:GetStageSeed (level:GetStage()), 0);

            local rooms = level:GetRooms();
            local pool = {};
            local totalRoomCount = rooms.Size;
            for i = 1, rooms.Size do
                local room = rooms:Get(i - 1);
                if (room and Shell.IsRoomIncluded(room.SafeGridIndex)) then
                    table.insert(pool, room.SafeGridIndex);
                end
            end

            local roomCount = math.min(#pool, math.ceil(totalRoomCount * 0.2 * trinketMultiplier));
            for i = 1, roomCount do
                local index = rng:RandomInt(#pool) + 1;
                local roomIndex = pool[index];
                local room = level:GetRoomByIdx(roomIndex);
                room.Flags = room.Flags | RoomDescriptor.FLAG_FLOODED;
                table.remove(pool, index);
            end
        end
    end
    Shell:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);
end
return Shell;