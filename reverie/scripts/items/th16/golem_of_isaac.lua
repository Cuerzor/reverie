local GolemOfIsaac = ModItem("Golem of Isaac", "GolemOfIsaac");
GolemOfIsaac.rng = RNG();

function GolemOfIsaac:onEvaluateCache(player, flag)

    if (flag == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(GolemOfIsaac.Item);
        
        local count = player:GetCollectibleNum(GolemOfIsaac.Item) + player:GetEffects():GetCollectibleEffectNum(GolemOfIsaac.Item) 
        player:CheckFamiliar(THI.Familiars.IsaacGolem.Variant, count, GolemOfIsaac.rng, item);
    end
end
GolemOfIsaac:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GolemOfIsaac.onEvaluateCache);
return GolemOfIsaac;