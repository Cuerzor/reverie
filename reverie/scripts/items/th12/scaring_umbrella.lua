
local Umbrella = ModItem("Scaring Umbrella", "SCARING_UMBRELLA");

local sourceItem = Isaac.GetItemConfig():GetCollectible(Umbrella.Item);
function Umbrella:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_FAMILIARS) then
        local familiar = THI.Familiars.ScaringUmbrella;
        local hasUmbrella = player:HasCollectible(Umbrella.Item) or player:GetEffects():HasCollectibleEffect(Umbrella.Item);
        local count = 0;
        if (hasUmbrella) then
            count = 1;
        end
        player:CheckFamiliar(familiar.Variant, count, RNG(), sourceItem);
    end
end
Umbrella:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Umbrella.EvaluateCache);

return Umbrella;