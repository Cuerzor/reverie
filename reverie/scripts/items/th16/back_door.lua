
local Door = ModItem("Back Door", "BACK_DOOR");

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(Door.Item);
        local has = player:HasCollectible(Door.Item) or player:GetEffects():HasCollectibleEffect(Door.Item) 
        local Familiar = THI.Familiars.BackDoor;
        local count = 0;
        if (has) then
            count = 1;
        end
        player:CheckFamiliar(Familiar.Variant, count, RNG(), item);
    end
end
Door:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

return Door;