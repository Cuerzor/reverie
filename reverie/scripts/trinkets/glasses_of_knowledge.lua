local Stats = CuerLib.Stats;
local Glasses = ModTrinket("Glasses of Knowledge", "KnowledgeGlasses");

local itemConfig = Isaac.GetItemConfig();
local itemCount = itemConfig:GetCollectibles().Size;

function Glasses:OnEvaluateCache(player, cache)
    if (player:HasTrinket(Glasses.Trinket)) then
        -- local count = 0;
        -- for i = 1, itemCount do
        --     local col = itemConfig:GetCollectible(i);
        --     if (col and player:HasCollectible(i, true)) then
        --         count = count + 1;
        --     end
        -- end
        local count = player:GetCollectibleCount ( );
        local multiplier = player:GetTrinketMultiplier (Glasses.Trinket);

        if (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:AddDamageUp(player, count * 0.03 * multiplier);
        elseif (cache == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsUp(player, count * 0.02 * multiplier);
        elseif (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + count * 0.03 * multiplier;
        elseif (cache == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + count * 0.038 * 50 * multiplier;
        end
    end
end
Glasses:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Glasses.OnEvaluateCache);

function Glasses:PostChangeCollectibles(player, item, diff)
    if (player:HasTrinket(Glasses.Trinket)) then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE);
        player:EvaluateItems();
    end
end
Glasses:AddCallback(CuerLib.Callbacks.CLC_POST_CHANGE_COLLECTIBLES, Glasses.PostChangeCollectibles);

return Glasses;