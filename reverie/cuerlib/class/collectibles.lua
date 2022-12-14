local Lib = LIB;

local Collectibles = Lib:NewClass()

local function PostPickupCollectible(player, item, touched)
    touched = touched or false;
    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_PICK_UP_COLLECTIBLE, item, player, item, touched);
end

local function PostPickupTrinket(player, trinket, golden, touched)
    touched = touched or false;
    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_PICK_UP_TRINKET, trinket, player, trinket, golden, touched);
end

local function PostGainCollectible(player, item, count, touched, holding)
    count = count or 1;
    touched = touched or false;
    holding = holding or false;
    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, item, player, item, count, touched, holding);
end

local function PostLoseCollectible(player, item, count)
    count = count or 1;
    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_LOSE_COLLECTIBLE, item, player, item, count);
end

local function PostChangeCollectibles(player, item, diff)
    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_CHANGE_COLLECTIBLES, item, player, item, diff);
end

-- Config.
local itemConfig = Isaac.GetItemConfig();



local ChangedItems = {
    Trinkets = {

    }
}


local function GetPickupData(pickup, init) 
    local data = Lib:GetEntityLibData(pickup, true);
    if (data) then
        data._COLLECTIBLES = data._COLLECTIBLES or {
            LastID = -1
        } 
    end
    return data._COLLECTIBLES;
end
local function GetPlayerData(player, init)
    local entData = Lib:GetEntityLibData(player, true);
    if (init) then
        entData._COLLECTIBLES = entData._COLLECTIBLES or {
            Items = {},
            Count = 0,
            QueueingItem = nil
        };
    end
    return entData._COLLECTIBLES;
end

function Collectibles.FindCollectibles(condition)
    local results = {};
    local collectibleCount = itemConfig:GetCollectibles().Size;
    for i = 1, collectibleCount do
        local config = itemConfig:GetCollectible(i);
        if (config and condition(i, config)) then
            table.insert(results, i);
        end
    end
    return results;
end

function Collectibles.GetPlayerCollectibles(player)
    local results = {}
    local collectibleCount = itemConfig:GetCollectibles().Size;
    for i = 1, collectibleCount do
        local config = itemConfig:GetCollectible(i);
        if (config) then
            local key = i;
            local num = player:GetCollectibleNum(i, true);
            results[key] = num;
        end
    end
    return results;
end


function Collectibles.IsAnyHasCollectible(item, onlyTrue)
    if (onlyTrue == nil) then
        onlyTrue = false;
    end
    for index, player in Lib.Players.PlayerPairs() do
        if (player:HasCollectible(item, onlyTrue)) then
            return true;
        end
    end
    return false;
end

local function CheckCollectibleChanged(player)
    
    local data = GetPlayerData(player, true);
    
    -- If total count is not the same with record.
    if (data.Count ~= player:GetCollectibleCount()) then
        return true;
    end

    -- If an item's number is not the same with record.
    local totalCount = 0;
    for key, curNum in pairs(data.Items) do
        local id = tonumber(key);
        local num = player:GetCollectibleNum(id, true);
        totalCount = totalCount + num;
        if (curNum ~= num) then
            return true;
        end
    end
    return false;
end

local function UpdateCollectibles(player)
    local data = GetPlayerData(player, true);

    data.Count = player:GetCollectibleCount();
    local queuedItem = data.QueueingItem;

    -- Update Collectibles.
    local collectibleCount = itemConfig:GetCollectibles().Size;
    for item = 1, collectibleCount do
        local config = itemConfig:GetCollectible(item);
        if (config) then
            local key = tostring(item);
            local curNum = data.Items[key] or 0;
            local num = player:GetCollectibleNum(item, true);

            -- If this collectible's number is different with record.
            local diff = num - curNum;
            if (diff ~= 0) then


                if (diff > 0) then
                    local gained = diff;
                    -- If player has queued item record, trigger gain event for it.
                    if (queuedItem) then
                        
                        if (item == queuedItem.Item and queuedItem.Type ~= ItemType.ITEM_TRINKET) then
                            PostGainCollectible(player, item, 1, queuedItem.Touched, true);
                            gained = gained - 1;
                            data.QueueingItem = nil;
                        end
                    end

                    -- Trigger gain event.
                    if (gained > 0) then
                        PostGainCollectible(player, item, gained, false, false);
                    end
                else
                    PostLoseCollectible(player, item, -diff);
                end
                PostChangeCollectibles(player, item, diff);
                data.Items[key] = num;
            end
        end
    end
end


-- Events.
function Collectibles:onPlayerUpdate(player)
    if (Game():GetFrameCount() > 0) then
        if (not player:IsItemQueueEmpty()) then -- If player is queueing items
            local data = GetPlayerData(player, true);
            if (not data.QueueingItem) then -- If has not recorded queueing item.
                local queued = player.QueuedItem;

                -- record the queued item.
                local id = queued.Item.ID;
                local type = queued.Item.Type;
                local touched = queued.Touched;
                data.QueueingItem = { Item = id, Type = type, Touched = touched };


                if (type == ItemType.ITEM_TRINKET) then
                    for i, item in pairs(ChangedItems.Trinkets) do
                        if (item.ID == id or item.ID - 32768 == id) then
                            PostPickupTrinket(player, id, item.ID > 32768, touched);
                            table.remove(ChangedItems.Trinkets, i);
                            break;
                        end
                    end
                else
                    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                        local data = GetPickupData(ent, false);
                        local idMatches = (data and data.LastID == id);
                        local swapped = ent.FrameCount <= 0;
                        local taken = (ent.SubType <= 0 and idMatches) or not ent:Exists();
                        if (swapped or taken) then
                            PostPickupCollectible(player, id, touched);
                            break;
                        end
                    end
                end
            end
        end
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Collectibles.onPlayerUpdate);


function Collectibles:onPlayerRender(player, offset, variant)
    if (Game():GetFrameCount() > 0) then -- Avoid triggering events while loading game.
        local data = GetPlayerData(player, true);
        local function NeedsUpdate()
            -- If has recorded queued item,
            -- and player no longer has queued item.
            if (data.QueueingItem and player:IsItemQueueEmpty()) then 
                return true;
            end

            if (CheckCollectibleChanged(player)) then
                return true;
            end
            return false;
        end
        local data = GetPlayerData(player, true);

        --if needs to update collectible record.
        if (NeedsUpdate()) then
            -- Update collectibles.
            UpdateCollectibles(player);
        end
        
        -- Clear recorded queued Item.
        if (data.QueueingItem and player:IsItemQueueEmpty()) then 
            data.QueueingItem = nil;
        end
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Collectibles.onPlayerRender);

function Collectibles:onGameStarted(isContinued)
    if (isContinued) then
        for p, player in Lib.Players.PlayerPairs()  do

            -- Re-record player's collectibles at the start of game
            -- To prevent event retrigger.
            local data = GetPlayerData(player, true);
            data.Count = player:GetCollectibleCount();

            local collectibleCount = itemConfig:GetCollectibles().Size;
            for item = 1, collectibleCount do
                local config = itemConfig:GetCollectible(item);
                if (config) then
                    local key = tostring(item);
                    local curNum = data.Items[key] or 0;
                    local num = player:GetCollectibleNum(item, true);

                    if (curNum ~= num) then
                        data.Items[key] = num;
                    end
                end
            end
        end
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Collectibles.onGameStarted);

local function PostPickupUpdate(mod, pickup)
    if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE) then
        local data = GetPickupData(pickup, true);
        data.LastID = pickup.SubType;
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate);

local function PostPickupRemove(mod, entity)
    if (entity.Variant == PickupVariant.PICKUP_TRINKET) then
        table.insert(ChangedItems.Trinkets, { ID = entity.SubType, Timeout = 1});
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostPickupRemove, EntityType.ENTITY_PICKUP);

local function PostUpdate(mod)
    for i, item in pairs(ChangedItems.Trinkets) do
        if (item.Timeout > 0) then
            item.Timeout = item.Timeout - 1;
        else
            ChangedItems.Trinkets[i] = nil
        end 
    end
end
Collectibles:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);


return Collectibles;