local HeartSticker = ModTrinket("Heart Sticker", "HEART_STICKER");

function HeartSticker:UseCard(card, player, flags)
    if (flags & (UseFlag.USE_OWNED | UseFlag.USE_MIMIC) > 0) then
        local multiplier = player:GetTrinketMultiplier(HeartSticker.Trinket);
        local room = Game():GetRoom();
        for i = 1, multiplier do
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, pos, Vector.Zero, player);
        end
    end
end
HeartSticker:AddCallback(ModCallbacks.MC_USE_CARD, HeartSticker.UseCard);

return HeartSticker;