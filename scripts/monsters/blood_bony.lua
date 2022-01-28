local BloodBoney = ModEntity("Blood Boney", "BloodBoney");

local function GetBoneData(ent, init)
    return BloodBoney:GetData(ent, init, function() return {Inited = false} end);
end

function BloodBoney:PostProjectileUpdate(tear)
    if (tear.Variant == ProjectileVariant.PROJECTILE_BONE) then
        local data = GetBoneData(tear, true);
        if (not data.Inited) then
            local spawner = tear.SpawnerEntity;

            if (spawner and spawner.Type == BloodBoney.Type and spawner.Variant == BloodBoney.Variant) then
                tear:SetColor(Color(1,0,0,1,0,0,0), -1, 99, false);
                local boneySpawner = spawner.SpawnerEntity;
                local player = nil;
                if (boneySpawner) then
                    player = boneySpawner:ToPlayer();
                end

                if (player) then
                    -- Bones has 5 basic damage.
                    -- the final damage is 5 + CollisionDamage.
                    tear.CollisionDamage = player.Damage;
                end
            end
            data.Inited = true;
        end
    end
end
BloodBoney:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, BloodBoney.PostProjectileUpdate);

local regTime = 30;
function BloodBoney:PostUpdate()
    
    regTime = regTime - 1;
    if (regTime <= 0) then
        regTime = 30;

        for i, ent in pairs(Isaac.FindByType(BloodBoney.Type, BloodBoney.Variant)) do
            
            if(ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and ent.HitPoints < ent.MaxHitPoints) then
                -- Birthright.
                local boneySpawner = ent.SpawnerEntity;
                local player = nil;
                if (boneySpawner) then
                    player = boneySpawner:ToPlayer();
                end
    
                if (player) then
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                        ent.HitPoints = math.min(ent.MaxHitPoints, ent.HitPoints + ent.MaxHitPoints / 30);
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, ent.Position, Vector.Zero, ent);
                        effect.DepthOffset = 10;
                        THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP, 0.3)
                    end
                end
            end
        end
    end
end
BloodBoney:AddCallback(ModCallbacks.MC_POST_UPDATE, BloodBoney.PostUpdate);

function BloodBoney:PreEntityTakeDamage(tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == BloodBoney.Type and tookDamage.Variant == BloodBoney.Variant) then
        if(tookDamage:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            if (flags & DamageFlag.DAMAGE_SPIKES > 0) then
                return false;
            end

            if (source.Type == EntityType.ENTITY_FIREPLACE) then
                return false;
            end

        end
    end
end
BloodBoney:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, BloodBoney.PreEntityTakeDamage);
return BloodBoney;