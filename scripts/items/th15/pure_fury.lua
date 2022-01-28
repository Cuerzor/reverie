
local Stats = CuerLib.Stats;
local PureFury = ModItem("Pure Fury", "PureFury");

function PureFury:onEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        local multiplier = 1.5 ^ player:GetCollectibleNum(PureFury.Item);
        --player.Damage = player.Damage * multiplier;
        Stats:MultiplyDamage(player, multiplier);
    end
end
PureFury:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PureFury.onEvaluateCache);

return PureFury;