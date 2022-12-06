local Detection = CuerLib.Detection;
local Asthma = ModItem("Asthma", "ASTHMA");


function Asthma:PreEntitySpawn(type, variant, subtype, pos, vel, spawner, seed)
    if (type == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_HEART and (not spawner or spawner.Type ~= EntityType.ENTITY_PLAYER)) then
        
        local asthmaPlayer = nil;
        for p, player in Detection.PlayerPairs() do
            if (player:HasCollectible(Asthma.Item)) then
                asthmaPlayer = player;
                break;
            end
        end
        if (asthmaPlayer) then
            local game = Game();
            local room = game:GetRoom();
            if (room:IsFirstVisit() or room:GetFrameCount() > 0) then
                local rng = asthmaPlayer:GetCollectibleRNG(Asthma.Item);
                local value = rng:RandomInt(100);
                if (value < 40) then
                    local itemPool = game:GetItemPool();
                    return {type, PickupVariant.PICKUP_TAROTCARD, itemPool:GetCard(rng:Next(), true, true, false), seed}
                elseif (value < 60) then
                    return {type, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, seed};
                end
            end
        end
    end
end
Asthma:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, Asthma.PreEntitySpawn);

return Asthma;
