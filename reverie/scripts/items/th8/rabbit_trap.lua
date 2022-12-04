local Detection = CuerLib.Detection;
local Collectibles = CuerLib.Collectibles;

local RabbitTrap = ModItem("Rabbit Trap", "RabbitTrap");
RabbitTrap.Entity = {
    Type = Isaac.GetEntityTypeByName("Rabbit Trap"),
    Variant = Isaac.GetEntityVariantByName("Rabbit Trap"),
    SubType = 5810
};

local chunkWidth = 7;
local chunkHeight = 5;
local emptyGrids = {};
local entities = nil;

local function CanSpawn(room, index)
    
    local pos = room:GetGridPosition(index);
    if (room:IsPositionInRoom(pos, 20)) then
        local path = room:GetGridPath(index);
        if (path <= 0 ) then
            for _, ent in pairs(entities) do
                if (ent:ToNPC() or (ent.Type == RabbitTrap.Entity.Type and ent.Type == RabbitTrap.Entity.Variant)) then
                    if (room:GetGridIndex(ent.Position) == index) then
                        return false;
                    end
                end
            end
            return true;
        end
    end
    return false;
end

local function SpawnInChunk(room, x, y, count, rng, spawner)
    
    for i = #emptyGrids, 1, -1 do
        table.remove(emptyGrids, i);
    end

    local width = room:GetGridWidth();
    for ix = x, x + chunkWidth - 1 do
        for iy = y, y + chunkHeight - 1 do
            local index = iy * width + ix;
            
            if (CanSpawn(room, index)) then
                table.insert(emptyGrids, index);
            end
        end
    end

    while (#emptyGrids > 0 and count > 0) do
        local index = rng:RandomInt(#emptyGrids - 1) + 1;
        local target = emptyGrids[index];
        Isaac.Spawn(RabbitTrap.Entity.Type, RabbitTrap.Entity.Variant, RabbitTrap.Entity.SubType, room:GetGridPosition(target), Vector.Zero, spawner)
        count = count - 1;
        table.remove(emptyGrids, index);
    end
end

local function SpawnTraps(room, count, spawner)
    -- Not Dungeon.
    entities = Isaac.GetRoomEntities();

    if (room:GetType()~= 16) then
        local seed = room:GetSpawnSeed();
        local rng = RNG();
        rng:SetSeed(seed, 0);
        
        local width = room:GetGridWidth();
        local height = room:GetGridHeight();
        local chunkX = 0;
        local chunkY = 0;
        while (chunkX < width - 2) do
            while (chunkY < height - 2) do
                SpawnInChunk(room, chunkX, chunkY, count, rng, spawner);
                chunkY = chunkY + chunkHeight;
            end
            chunkX = chunkX + chunkWidth;
            chunkY = 0;
        end
        chunkX = 0;
    end
end

function RabbitTrap:postNewRoom()
    local room = THI.Game:GetRoom();
    local spawner = nil;
    if (room:GetAliveEnemiesCount() > 0) then
        for p, player in Detection.PlayerPairs() do
            local count = player:GetCollectibleNum(RabbitTrap.Item);
            if (count > 0) then
                SpawnTraps(room, count, player);
            end
        end
    end
end
RabbitTrap:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RabbitTrap.postNewRoom);


function RabbitTrap:onEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + player:GetCollectibleNum(RabbitTrap.Item);
    end
end
RabbitTrap:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RabbitTrap.onEvaluateCache);

return RabbitTrap;