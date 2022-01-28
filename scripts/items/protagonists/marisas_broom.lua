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


local function GetPlayerData(player)
    return MarisasBroom:GetData(player, true, function() return {
        GotMushrooms = {},
        MushroomCount = 0
    } end);
end

function MarisasBroom:CheckMushroom(player, id)
    local data = GetPlayerData(player);
    local key = tostring(id);
    if (player:HasCollectible(id)) then
        if (data.GotMushrooms[key] ~= true) then
            data.MushroomCount = data.MushroomCount + 1;
            data.GotMushrooms[key] = true
            return true;
        end
    else 
        if (data.GotMushrooms[key] == true) then
            data.MushroomCount = data.MushroomCount - 1;
            data.GotMushrooms[key] = false
            
            return true;
        end
    end
    return false;
end

function MarisasBroom:CheckMushrooms(player)
    local evaluatable = false;;
    for i, item in pairs(MushroomList) do
        if (MarisasBroom:CheckMushroom(player, item)) then
            evaluatable = true;
        end
    end
    
    if (evaluatable) then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end
end

function MarisasBroom:ClearMushrooms(player)
    local data = GetPlayerData(player);
    if (data.MushroomCount > 0) then
        data.GotMushrooms = {};
        data.MushroomCount = 0;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end
end

function MarisasBroom:onPlayerEffect(player)
    local has = player:HasCollectible(MarisasBroom.Item);
    if (has) then
        MarisasBroom:CheckMushrooms(player);
    else
        MarisasBroom:ClearMushrooms(player);
    end
end

function MarisasBroom:onEvaluateCache(player, flags)
    local data = GetPlayerData(player);
    if (player:HasCollectible(MarisasBroom.Item)) then
        if (flags == CacheFlag.CACHE_FLYING) then
            player.CanFly = true;
        end
    end
    local count = data.MushroomCount;
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
    local data = GetPlayerData(player);
end

MarisasBroom:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MarisasBroom.onPlayerEffect);
MarisasBroom:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MarisasBroom.onEvaluateCache);

return MarisasBroom;