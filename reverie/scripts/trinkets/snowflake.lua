local ItemPools = CuerLib.ItemPools;
local Snowflake = ModTrinket("Snowflake", "SNOWFLAKE");

function Snowflake:PrePickupCollision(pickup, other, low)
    if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Wait <= 0) then
        if (other.Type == EntityType.ENTITY_PLAYER) then
            local player = other:ToPlayer();
            local hasSnowflake = player:HasTrinket(Snowflake.Trinket);
            local hasItem = player:HasCollectible(pickup.SubType, true);
            if (player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B) then
                local forgor = player:GetMainTwin();
                hasSnowflake = hasSnowflake or forgor:HasTrinket(Snowflake.Trinket);
                hasItem = hasItem or forgor:HasCollectible(pickup.SubType, true);
            end
            if (hasSnowflake) then
                if (pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and hasItem) then
                    local game = Game();
                    local room = game:GetRoom();
                    local pool = game:GetItemPool();
                    local poolType = ItemPools:GetRoomPool(pickup.InitSeed);
                    local newItem = pool:GetCollectible(poolType, true, pickup.InitSeed);
                    pickup:Morph(pickup.Type, pickup.Variant, newItem, true, false, true);
                    pickup.Wait = 30;
                    SFXManager():Play(SoundEffect.SOUND_THUMBSUP);
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                    return false;
                end
            end
        end
    end
end
Snowflake:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Snowflake.PrePickupCollision);

return Snowflake;