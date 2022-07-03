local YoungNativeGod = ModItem("Young Native God", "YOUNG_NATIVE_GOD");


function YoungNativeGod:onEvaluateCache(player, flag)

    if (flag == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(YoungNativeGod.Item);
        
        local count = player:GetCollectibleNum(YoungNativeGod.Item) + player:GetEffects():GetCollectibleEffectNum(YoungNativeGod.Item) 
        player:CheckFamiliar(THI.Familiars.YoungNativeGod.Variant, count, RNG(), item);
    end
end
YoungNativeGod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, YoungNativeGod.onEvaluateCache);

return YoungNativeGod;