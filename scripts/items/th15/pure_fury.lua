
local Stats = CuerLib.Stats;
local PureFury = ModItem("Pure Fury", "PureFury");

function PureFury:onEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        local Seija = THI.Players.Seija;
        local base = 1.5;
        if (Seija:WillPlayerNerf(player)) then
            base = 1.01
        end
        local multiplier = base ^ player:GetCollectibleNum(PureFury.Item);
        --player.Damage = player.Damage * multiplier;
        Stats:MultiplyDamage(player, multiplier);
    end
end
PureFury:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PureFury.onEvaluateCache);

return PureFury;