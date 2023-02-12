local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local RainbowCard = ModItem("Rainbow Card", "RAINBOW_CARD");

function RainbowCard:GetCardData(create)
    return RainbowCard:GetGlobalData(create, function ()
        return {
            UsedCount = 0,
            HasEffect = false
        }
    end)
end
function RainbowCard:GetPlayerData(player, create)
    return RainbowCard:GetData(player, create, function ()
        return {
            JudasDamageUp = 0
        }
    end)
end

function RainbowCard:HasEffect()
    local data = RainbowCard:GetCardData(false);
    return (data and data.HasEffect) or false;
end

function RainbowCard:PostUseItem(item, rng, player, flags, slot, varData)

    local Seija = Reverie.Players.Seija;

    if (not Seija:WillPlayerBuff(player)) then
        local virtues = Actives:CanSpawnWisp(player, flags);
        local judasBook = Players.HasJudasBook(player);
        local removedCount = 0;
        local itemConfig = Isaac.GetItemConfig();
        for id = 1, itemConfig:GetCollectibles().Size do
            local config = itemConfig:GetCollectible(id);
            if (config and not config:HasTags(ItemConfig.TAG_QUEST)) then
                local num = player:GetCollectibleNum(id, true);
                if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == id) then
                    num = num - 1;
                end
                if (player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == id) then
                    num = num - 1;
                end
                for n = 1, num do
                    player:RemoveCollectible(id, true);
                end
                removedCount = removedCount + num;
            end
        end
        if (virtues) then
            for i = 1, removedCount do
                player:AddWisp( RainbowCard.Item, player.Position, true);
            end
        end
        if (judasBook) then
            local playerData = RainbowCard:GetPlayerData(player, true);
            playerData.JudasDamageUp = (playerData.JudasDamageUp or 0) + 0.3 * removedCount;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
            player:EvaluateItems();
        end
    end

    local data = RainbowCard:GetCardData(true);
    data.UsedCount = (data.UsedCount or 0) + 1;
    return {ShowAnim = true, Remove = true}
end
RainbowCard:AddCallback(ModCallbacks.MC_USE_ITEM, RainbowCard.PostUseItem, RainbowCard.Item);


function RainbowCard:PostNewLevel()
    local data = RainbowCard:GetCardData(false);
    if (data) then
        data.HasEffect = false;
        if (data.UsedCount and data.UsedCount > 0) then
            data.UsedCount = data.UsedCount - 1;
            data.HasEffect = true;
        end
    end
end
RainbowCard:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, RainbowCard.PostNewLevel);

function RainbowCard:PostPickupUpdate(pickup)
    if (RainbowCard:HasEffect()) then
        if (pickup.AutoUpdatePrice and pickup.Price ~= PickupPrice.PRICE_FREE and pickup.Price ~= 0) then
            pickup.Price = PickupPrice.PRICE_FREE;
        end
    end
end
RainbowCard:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, RainbowCard.PostPickupUpdate);

function RainbowCard:EvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local playerData = RainbowCard:GetPlayerData(player, false);
        if (playerData and playerData.JudasDamageUp) then
            Stats:AddDamageUp(player, playerData.JudasDamageUp);
        end
    end
end
RainbowCard:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RainbowCard.EvaluateCache);

return RainbowCard;