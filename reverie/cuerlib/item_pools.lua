local Lib = _TEMP_CUERLIB;
local Callbacks = Lib.Callbacks;
local ItemPools = Lib:NewClass();
ItemPools.RoomBlacklist = {};

--- 获取本房间的道具池，会考虑BOSS挑战以及堕落恶魔。
---@param seed integer @随机种子
function ItemPools:GetRoomPool(seed)
    local itemPool = Game():GetItemPool();
    local level = Game():GetLevel();
    local room = Game():GetRoom();
    local roomType = room:GetType();
    local newPool = itemPool:GetPoolForRoom (roomType, seed);

    if (roomType == RoomType.ROOM_CHALLENGE and Game():GetLevel():HasBossChallenge()) then
        newPool = ItemPoolType.POOL_BOSS;
    end

    if (newPool < 0) then
        newPool = ItemPoolType.POOL_TREASURE;
    end

    if (roomType == RoomType.ROOM_BOSS) then
        if (room:GetBossID() == 23 or level:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED)) then
            newPool = ItemPoolType.POOL_DEVIL;
        end
    end
    return newPool;
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
local function PostNewRoom(mod)
    if (not blacklistCleared) then
        ItemPools.RoomBlacklist = {};
        blacklistCleared = true;
    end
end

function ItemPools:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, PostGetCollectible)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)
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