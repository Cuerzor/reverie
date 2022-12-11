local Lib = LIB;
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
    for i = 1, collectibles.Size do
        local config = itemConfig:GetCollectible(i);
        if (config) then
            local callbacks = Isaac.GetCallbacks(Lib.Callbacks.CLC_EVALUATE_POOL_BLACKLIST);
            for _, callback in ipairs(callbacks) do
                if (callback.Function(callback.Mod, i, config)) then
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
ItemPools:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, PostGetCollectible)

-- Callback.
local loopCount = 0;
local function PreGetCollectible(mod, pool, decrease, seed)
    loopCount = loopCount + 1;
    local callbacks = Isaac.GetCallbacks(Lib.Callbacks.CLC_PRE_GET_COLLECTIBLE);
    for _, callback in pairs(callbacks) do
        local result = callback.Function(mod, pool, decrease, seed, loopCount);
        if (result) then
            loopCount = loopCount - 1;
            return result;
        end
    end
    loopCount = loopCount - 1;
end
ItemPools:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, PreGetCollectible)

-- Evaluate Room Blacklist.
local blacklistCleared = false;
local function PreGetCollectible(mod, pool, decrease, seed)
    if (not blacklistCleared and Game():GetRoom():GetFrameCount() <= 0) then
        ItemPools.RoomBlacklist = {};
        ItemPools:EvaluateRoomBlacklist()
        blacklistCleared = true;
    end
end
ItemPools:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, PreGetCollectible)

local function PostUpdate(mod)
    blacklistCleared = false;
end
ItemPools:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostNewRoom(mod)
    if (not blacklistCleared) then
        ItemPools.RoomBlacklist = {};
        blacklistCleared = true;
    end
end
ItemPools:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

return ItemPools;