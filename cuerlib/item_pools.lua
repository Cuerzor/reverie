local Lib = _TEMP_CUERLIB;
local Callbacks = Lib.Callbacks;
local ItemPools = Lib:NewClass();
ItemPools.RoomBlacklist = {};

function ItemPools:GetItemPoolCollectibles()
    local game = Game();
    local list = {};
    local itemPools = game:GetItemPool();
    for pool = 0, ItemPoolType.NUM_ITEMPOOLS - 1 do
        local col = itemPools:GetCollectible(pool, false, Random(), -1);
        while (col > 0) do
            list[col] = list[col] or {};
            table.insert(list[col], pool);
            itemPools:AddRoomBlacklist (col);
            col = itemPools:GetCollectible(pool, false, Random(), -1);
        end
        itemPools:ResetRoomBlacklist();
    end
    return list;
end

function ItemPools:GetPoolForRoom(roomType, seed)
    local itemPool = Game():GetItemPool();
    local newPool = itemPool:GetPoolForRoom (roomType, seed);

    if (roomType == RoomType.ROOM_CHALLENGE and Game():GetLevel():HasBossChallenge()) then
        newPool = ItemPoolType.POOL_BOSS;
    end

    if (newPool < 0) then
        newPool = ItemPoolType.POOL_TREASURE;
    end

    if (Game():GetRoom():GetBossID() == 23) then
        newPool = ItemPoolType.POOL_DEVIL;
    end
    return newPool;
end

function ItemPools:GetQuality4Item(pool, decrease, seed, default)
    local condition = function(id, config) return config.Quality < 4 end
    ItemPools:AddPoolBlacklist(condition)
    local item = Game():GetItemPool():GetCollectible(pool, decrease, seed, default)
    return item;
end

function ItemPools:AddPoolBlacklist(condition)
    local itemPool = Game():GetItemPool();
    local itemConfig = Isaac.GetItemConfig();

    -- Exclude items that not fits the condition.
    local collectibles = itemConfig:GetCollectibles();
    for i = 1, collectibles.Size do
        local config = itemConfig:GetCollectible(i);
        if (config and condition(i, config)) then
            itemPool:AddRoomBlacklist(i);
        end
    end
end
function ItemPools:ResetRoomBlacklist()
    local itemPool = Game():GetItemPool();
    itemPool:ResetRoomBlacklist();
end

function ItemPools:EvaluateRoomBlacklist()
    local itemPool = Game():GetItemPool();
    itemPool:ResetRoomBlacklist();

    for _, id in ipairs(ItemPools.RoomBlacklist) do
        itemPool:AddRoomBlacklist(id);
    end

    local itemConfig = Isaac.GetItemConfig();
    local collectibles = itemConfig:GetCollectibles();
    local affectedFunctions = {};
    for i = 1, collectibles.Size do
        local config = itemConfig:GetCollectible(i);
        if (config) then
            for index, info in ipairs(Callbacks.Functions.EvaluatePoolBlacklist) do
                if (info.Func(info.Mod, i, config)) then
                    affectedFunctions[index] = true;
                    itemPool:AddRoomBlacklist(i);
                    break;
                end
            end
        end
    end
    -- for func, _ in ipairs(affectedFunctions) do
    --     print("function #"..func.." has the effect.")
    -- end
end

local function PostGetCollectible(mod, id, pool, decrease, seed)
    if (decrease) then
        table.insert(ItemPools.RoomBlacklist, id);
    end
end

local blacklistCleared = false;
local function PreRoomEntitySpawn(mod, type, variant,subtype, gridIndex, seed)
    if (not blacklistCleared) then
        ItemPools.RoomBlacklist = {};
        ItemPools:EvaluateRoomBlacklist()
        blacklistCleared = true;
    end
end
local function PreGetCollectible(mod, pool, decrease, seed)
    if (not blacklistCleared and Game():GetRoom():GetFrameCount() <= 0) then
        ItemPools.RoomBlacklist = {};
        ItemPools:EvaluateRoomBlacklist()
        blacklistCleared = true;
    end
end
local function PostUpdate(mod)
    blacklistCleared = false;
end

function ItemPools:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, PostGetCollectible)
    --mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)
    mod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, PreGetCollectible)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)
end

-- function ItemPools:GetConditionalCollectible(pool, decrease, seed, default, condition)
--     local itemPool = Game():GetItemPool();
--     local itemConfig = Isaac.GetItemConfig();

--     -- Exclude items that not fits the condition.
--     ItemPools:AddPoolBlacklist(function(i, conf) return not condition(i, conf) end)
--     local item = itemPool:GetCollectible(pool, decrease, seed, default);
--     itemPool:ResetRoomBlacklist();
--     return item;

--     --local rng = RNG();
--     --rng:SetSeed(seed, 0);
--     -- local newSeed = seed;
--     -- local curPool = pool;
--     -- local breakfastCount = 0;
--     -- for i = 1, 1024 do
--     --     local collectible = itemPool:GetCollectible(curPool, false, newSeed);
--     --     print("Get", i)
--     --     if (collectible == CollectibleType.COLLECTIBLE_BREAKFAST) then
--     --         breakfastCount = breakfastCount + 1;
--     --     end
--     --     if (breakfastCount > 2) then
--     --         return CollectibleType.COLLECTIBLE_BREAKFAST;
--     --     end
--     --     itemPool:AddRoomBlacklist(collectible);
--     --     newSeed = rng:Next();
--     -- end
--     --return CollectibleType.COLLECTIBLE_BREAKFAST;
-- end


return ItemPools;