local Collectibles = CuerLib.Collectibles;
local Stats = CuerLib.Stats;

local FriedTofu = ModItem("Fried Tofu", "FriedTofu");


function FriedTofu:onBingeEaterChange(player, item, diff)
    if (player:HasCollectible(FriedTofu.Item)) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_LUCK);
        player:EvaluateItems();
    end
end
FriedTofu:AddCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, FriedTofu.onBingeEaterChange, CollectibleType.COLLECTIBLE_BINGE_EATER);

function FriedTofu:onEvaluateCache(player, flag) 
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then
        local tofuCount = player:GetCollectibleNum(FriedTofu.Item);
        if (flag == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + 60 * tofuCount;
        elseif (flag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.03 * tofuCount;
        elseif (flag == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + 1 * tofuCount;
        end
    end
end
FriedTofu:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FriedTofu.onEvaluateCache)

return FriedTofu;