local Raiment = ModItem("Angel's Raiment", "ANGELS_RAIMENT");

local function PostPlayerTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    local player = tookDamage:ToPlayer();
    if (player and player:HasCollectible(Raiment.Item)) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY, 0, -1);
    end
end
Raiment:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostPlayerTakeDamage, EntityType.ENTITY_PLAYER)


local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_FLYING and player:HasCollectible(Raiment.Item)) then
        player.CanFly = true;
    end
end
Raiment:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

return Raiment;