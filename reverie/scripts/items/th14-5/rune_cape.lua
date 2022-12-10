local Cape = ModItem("Rune Cape", "RUNE_CAPE")

do
    local function EvaluateCache(mod, player, flag)
        if (player:HasCollectible(Cape.Item)) then
            if (flag == CacheFlag.CACHE_SHOTSPEED) then
                player.ShotSpeed = player.ShotSpeed + 0.16;
            end
        end
    end
    Cape:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

    local function PostGainCape(mod, player, item, count, touched)
        if (not touched and player.Variant == 0 and not player:IsCoopGhost()) then
            local room = Game():GetRoom();
            local itemPool = Game():GetItemPool();
            local rng = player:GetCollectibleRNG(Cape.Item);
            for i = 1, 3 * count do
                local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
                local rune = itemPool:GetCard(rng:Next(), false, true, true);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, pos, Vector.Zero, nil);
            end
        end
    end
    Cape:AddCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainCape, Cape.Item)
end

return Cape;