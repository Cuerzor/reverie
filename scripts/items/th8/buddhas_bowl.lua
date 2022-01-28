local BuddhasBowl = ModItem("Buddha's Bowl", "BuddhasBowl");
BuddhasBowl.Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_buddhas_bowl.anm2")

function BuddhasBowl.GetPlayerData(player, init)
    return BuddhasBowl:GetData(player, init, function() return {
        Protected = false
    } end);
end

function BuddhasBowl:PrePlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(BuddhasBowl.Item)) then
        local ashed = THI.Collectibles.AshOfPheonix:IsAsh(player);
        local damageInvincible = flags & DamageFlag.DAMAGE_INVINCIBLE > 0;
        local playerData = BuddhasBowl.GetPlayerData(player, true);
        local prevent = playerData.Protected and not damageInvincible and not ashed;
        if (prevent) then
            if (not damageInvincible) then
                playerData.Protected = false;
                player:SetMinDamageCooldown(45);
                player:TryRemoveNullCostume(BuddhasBowl.Costume);
                local sfx = THI.SFXManager;
                sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                sfx:Play(SoundEffect.SOUND_HOLY_MANTLE);
                local renderRNG = RNG();
                renderRNG:SetSeed(Random(), 0);
                for i = 1, 4 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.ROCK_PARTICLE,0, player.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, player); 
                    local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0, player.Position, Vector.FromAngle(renderRNG:RandomFloat() * 360) * renderRNG:RandomFloat() * 5, player); 
                    local e = dust:ToEffect(); 
                    e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
                    e.Timeout = e.LifeSpan;
                end
                return false;
            end
        else
            playerData.Protected = true;
            Isaac.Spawn(1000,15,0, player.Position, Vector.Zero, player); 
            player:AddNullCostume(BuddhasBowl.Costume);
        end
    end
end
BuddhasBowl:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, BuddhasBowl.PrePlayerTakeDamage, EntityType.ENTITY_PLAYER, 16);

function BuddhasBowl:PostPlayerEffect(player)
    if (not player:HasCollectible(BuddhasBowl.Item)) then
        local playerData = BuddhasBowl.GetPlayerData(player, false);
        local prevent = playerData and playerData.Protected;
        if (prevent) then
            if (not damageInvincible) then
                playerData.Protected = false;
                player:TryRemoveNullCostume(BuddhasBowl.Costume);
            end
        end
    end
end
BuddhasBowl:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BuddhasBowl.PostPlayerEffect);


return BuddhasBowl;