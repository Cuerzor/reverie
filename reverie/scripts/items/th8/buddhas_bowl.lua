local BuddhasBowl = ModItem("Buddha's Bowl", "BuddhasBowl");
BuddhasBowl.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl.anm2")
BuddhasBowl.CostumeJupiter = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl_jupiter.anm2")
BuddhasBowl.CostumeJupiterBody = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl_jupiter_body.anm2")
BuddhasBowl.CostumeJupiterBodyAngel = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl_jupiter_body_angel.anm2")
BuddhasBowl.CostumeJupiterBodyPony = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl_jupiter_body_pony.anm2")
BuddhasBowl.CostumeJupiterBodyWhitepony = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_buddhas_bowl_jupiter_body_whitepony.anm2")


function BuddhasBowl.GetPlayerData(player, init)
    return BuddhasBowl:GetData(player, init, function() return {
        Protected = false,
        JupiterState = 0,
    } end);
end

function BuddhasBowl:AddCostume(player)
    local data = BuddhasBowl.GetPlayerData(player, false);
    local state = (data and data.JupiterState) or 0;
    if (state > 0) then
        player:AddNullCostume(self.CostumeJupiter);
        if (state == 4) then
            player:AddNullCostume(self.CostumeJupiterBodyWhitepony);
        elseif (state == 3) then
            player:AddNullCostume(self.CostumeJupiterBodyPony);
        elseif (state == 2) then
            player:AddNullCostume(self.CostumeJupiterBodyAngel);
        else
            player:AddNullCostume(self.CostumeJupiterBody);
        end
        player:TryRemoveNullCostume(self.Costume);
    else
        player:AddNullCostume(self.Costume);
        player:TryRemoveNullCostume(self.CostumeJupiter);
        player:TryRemoveNullCostume(self.CostumeJupiterBodyWhitepony);
        player:TryRemoveNullCostume(self.CostumeJupiterBodyPony);
        player:TryRemoveNullCostume(self.CostumeJupiterBodyAngel);
        player:TryRemoveNullCostume(self.CostumeJupiterBody);
    end
end
function BuddhasBowl:RemoveCostume(player)
    player:TryRemoveNullCostume(self.Costume);
    player:TryRemoveNullCostume(self.CostumeJupiter);
    player:TryRemoveNullCostume(self.CostumeJupiterBodyWhitepony);
    player:TryRemoveNullCostume(self.CostumeJupiterBodyPony);
    player:TryRemoveNullCostume(self.CostumeJupiterBodyAngel);
    player:TryRemoveNullCostume(self.CostumeJupiterBody);
end

function BuddhasBowl:GetJupiterState(player)
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER)) then
        if (player.CanFly) then
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_WHITE_PONY)) then
                return 4
            elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_PONY)) then
                return 3
            else
                return 2
            end
        else
            return 1
        end
    end
    return 0;
end



function BuddhasBowl:PrePlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(BuddhasBowl.Item)) then
        local ashed = THI.Collectibles.AshOfPhoenix:IsAsh(player);
        local damageInvincible = flags & DamageFlag.DAMAGE_INVINCIBLE > 0;
        local playerData = BuddhasBowl.GetPlayerData(player, true);
        local prevent = playerData.Protected and not damageInvincible and not ashed;
        if (prevent) then
            if (not damageInvincible) then
                playerData.Protected = false;
                player:SetMinDamageCooldown(45);
                BuddhasBowl:RemoveCostume(player);
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
            BuddhasBowl:AddCostume(player);
        end
    end
end
BuddhasBowl:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BuddhasBowl.PrePlayerTakeDamage, EntityType.ENTITY_PLAYER, 16);

function BuddhasBowl:PostPlayerEffect(player)
    if (not player:HasCollectible(BuddhasBowl.Item)) then
        local playerData = BuddhasBowl.GetPlayerData(player, false);
        local prevent = playerData and playerData.Protected;
        if (prevent) then
            playerData.Protected = false;
            BuddhasBowl:RemoveCostume(player);
        end
    else -- If has Buddha's bowl.
        local playerData = BuddhasBowl.GetPlayerData(player, false);
        if (playerData) then
            local prevent =  playerData.Protected;
            if (prevent) then
                local jupiterState = BuddhasBowl:GetJupiterState(player);
                if (playerData.JupiterState ~= jupiterState) then
                    playerData.JupiterState = jupiterState;
                    BuddhasBowl:RemoveCostume(player);
                    BuddhasBowl:AddCostume(player);
                end
            end
        end
    end
end
BuddhasBowl:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BuddhasBowl.PostPlayerEffect);


return BuddhasBowl;