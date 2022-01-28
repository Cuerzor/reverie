local Bottle = ModEntity("Fox's Advice Bottle", "ADVICE_BOTTLE");

function Bottle.GetBottleData(bottle, init)
    return Bottle:GetData(bottle, init, function() return {
        DamageCountdown = 0,
        Collectible = 0
    } end)
end

function Bottle:PostBottleInit(pickup)
    if (pickup:HasEntityFlags(EntityFlag.FLAG_APPEAR)) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
    end

    pickup.TargetPosition = pickup.Position;
    local spr = pickup:GetSprite();
    if (pickup.SubType == 0) then
        spr:ReplaceSpritesheet(1, "gfx/items/advice_restock.png");
    elseif (pickup.SubType == 1) then
        spr:ReplaceSpritesheet(1, "gfx/items/advice_black_hearts.png");
    elseif (pickup.SubType == 2) then
        spr:ReplaceSpritesheet(1, "gfx/items/advice_dimes.png");
    elseif (pickup.SubType == 3 or pickup.SubType == 4) then
        spr:ReplaceSpritesheet(1, "gfx/items/advice_free.png");
    elseif (pickup.SubType == 5) then
        local itemPool = THI.Game:GetItemPool();
        local seed = THI.Game:GetRoom():GetSpawnSeed();
        local item = itemPool:GetCollectible(ItemPoolType.POOL_SECRET, true, seed, CollectibleType.COLLECTIBLE_BREAKFAST);

        pickup.SubType = 32768 + item;
    end


    if (pickup.SubType > 32768) then
        local item = pickup.SubType - 32768;
        local config = Isaac.GetItemConfig();
        local col = config:GetCollectible(item);

        local path = "";
        if (col) then
            path = col.GfxFileName;
        end
        spr:ReplaceSpritesheet(1, path);
    end
    spr:LoadGraphics();
end
Bottle:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Bottle.PostBottleInit, Bottle.Variant);

function Bottle:PostBottleUpdate(pickup)
    pickup.Velocity = pickup.TargetPosition - pickup.Position;

    local data = Bottle.GetBottleData(pickup, true);
    if (data.DamageCountdown > 0 ) then
        data.DamageCountdown = data.DamageCountdown - 1;
    end
    for _, ent in pairs(Isaac.FindInRadius(pickup.Position, pickup.Size, EntityPartition.TEAR)) do
        if (data.DamageCountdown <= 0) then
            pickup.HitPoints = pickup.HitPoints - 1;
            pickup:SetColor(Color(1,1,1,1,1, 0,0), 15, 0, true, true);
            data.DamageCountdown = 30;
            THI.SFXManager:Play(SoundEffect.SOUND_STONE_IMPACT);
        end
        local tear = ent:ToTear();
        if (tear and not tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
            tear:Die();
        end
    end

    if (pickup.HitPoints <= 0) then
        pickup:Remove();
        THI.SFXManager:Play(SoundEffect.SOUND_GLASS_BREAK);
        THI.Game:SpawnParticles (pickup.Position, EffectVariant.ROCK_PARTICLE, 10, 10, Color(1,1,1,0.5,0.5,0.5,0.5));
    end
end
Bottle:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Bottle.PostBottleUpdate, Bottle.Variant);

function Bottle:PreBottleCollision(pickup, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local game = THI.Game;
        local room = game:GetRoom();
        local FoxInTube = THI.Collectibles.FoxInTube;
        if (pickup.SubType == 0) then
            local pos = room:FindFreePickupSpawnPosition(pickup.Position, 0, true);
            Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, pos, Vector.Zero, other);
            FoxInTube.AddPay("TreasureRoom", 3);

            local data = FoxInTube.GetPayData(true);
            data.CanShowTreasureRoomFortune = true;
        elseif (pickup.SubType == 1) then
            other:ToPlayer():AddBlackHearts(6);
            --FoxInTube.AddPay("SacrificeRoom", 1);
            THI.SFXManager:Play(SoundEffect.SOUND_UNHOLY);
            FoxInTube.AddPay("SacrificeRoom", 1);
            FoxInTube.PayForSacrifice()
        elseif (pickup.SubType == 2) then
            other:ToPlayer():AddCoins(30);
            FoxInTube.AddPay("Shop", 1);
            THI.SFXManager:Play(SoundEffect.SOUND_DIMEPICKUP);
        elseif (pickup.SubType == 3) then
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                ent:ToPickup().Price = 0;
            end
            FoxInTube.AddPay("DevilRoom", 1);
        elseif (pickup.SubType == 4) then
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                ent:ToPickup().OptionsPickupIndex = 0;
            end
            FoxInTube.AddPay("AngelRoom", 1);
        elseif (pickup.SubType > 32768) then
            local item = pickup.SubType - 32768;
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, pickup.Position, Vector.Zero, nil);
            FoxInTube.AddPay("SecretRoom", 1);
        end

        THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
        pickup:Remove();
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
    end
end
Bottle:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Bottle.PreBottleCollision, Bottle.Variant);

return Bottle;