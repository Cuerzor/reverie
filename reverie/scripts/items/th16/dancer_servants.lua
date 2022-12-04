
local Dancer = ModItem("Dancer Servants", "DANCER_SERVANT");

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(Dancer.Item);
        local count = player:GetCollectibleNum(Dancer.Item) + player:GetEffects():GetCollectibleEffectNum(Dancer.Item) 
        local Familiar = THI.Familiars.DancerServant;
        player:CheckFamiliar(Familiar.Variant, count, RNG(), item, Familiar.SubTypes.MAI);
        player:CheckFamiliar(Familiar.Variant, count, RNG(), item, Familiar.SubTypes.SANATO);
    end
end
Dancer:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

return Dancer;