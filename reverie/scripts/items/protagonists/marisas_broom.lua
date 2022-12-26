local MarisasBroom = ModItem("Marisa's Broom", "MarisasBroom");
local Stats = CuerLib.Stats;

local function GetMushroomList()
    local config = Isaac:GetItemConfig();
    local collectibles = config:GetCollectibles();
    local size = collectibles.Size;
    local result = {};
    for i=1, size do
        local item = config:GetCollectible(i);
        if (item ~= nil and item:HasTags(ItemConfig.TAG_MUSHROOM)) then
            table.insert(result, item.ID);
        end
    end
    return result;
end

local MushroomList = GetMushroomList();


local function GetPlayerData(player, create)
    return MarisasBroom:GetData(player, create, function() return {
        MushroomCount = 0
    } end);
end

function MarisasBroom:CacheMushroomCount(player)
    local data = GetPlayerData(player, true);
    local count = 0;
    for i, item in pairs(MushroomList) do
        count = count + player:GetCollectibleNum(item);
    end
    data.MushroomCount = count;
    return count;
end

function MarisasBroom:PostCollectiblesChanged(player, item, diff)
    local data = GetPlayerData(player, false);
    if (data and data.MushroomCount) then
        data.MushroomCount = nil;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end
end
MarisasBroom:AddCallback(CuerLib.Callbacks.CLC_POST_CHANGE_COLLECTIBLES, MarisasBroom.PostCollectiblesChanged);

function MarisasBroom:onEvaluateCache(player, flags)
    if (player:HasCollectible(MarisasBroom.Item)) then
        local data = GetPlayerData(player, true);
        if (flags == CacheFlag.CACHE_FLYING) then
            player.CanFly = true;
        end

        local count = (data and data.MushroomCount) or MarisasBroom:CacheMushroomCount(player);
        if (flags == CacheFlag.CACHE_DAMAGE) then
            --player.Damage = player.Damage + 1 * count;
            Stats:AddDamageUp(player, 1 * count);
        end
        if (flags == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.3 * count;
        end
        if (flags == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsUp(player, 0.5 * count);
        end
    end
end

MarisasBroom:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MarisasBroom.onEvaluateCache);

return MarisasBroom;