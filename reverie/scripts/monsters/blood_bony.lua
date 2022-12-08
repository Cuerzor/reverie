local Players = CuerLib.Players;
local BloodBony = ModEntity("Blood Bony", "BloodBony");

BloodBony.SubTypes = {
    TEMPORARY = 0,
    PERNAMENT = 1,
}
BloodBony.Variants = {
    SOUL = {
        Type = Isaac.GetEntityTypeByName("Soul Bony"), 
        Variant = Isaac.GetEntityVariantByName("Soul Bony"),
        SubTypes = {
            LEVEL1 = 0,
            LEVEL2 = 1,
            LEVEL3 = 2
        }
    },
    DEVIL =  {
        Type = Isaac.GetEntityTypeByName("Devil Bony"), 
        Variant = Isaac.GetEntityVariantByName("Devil Bony"),
        SubTypes = {
            LEVEL1 = 0,
            LEVEL2 = 1,
            LEVEL3 = 2
        }
    },
    DEVIL_TEMPORARY =  {
        Type = Isaac.GetEntityTypeByName("Devil Bony (Temporary)"), 
        Variant = Isaac.GetEntityVariantByName("Devil Bony (Temporary)"),
        SubType = 0
    },
    FATTY =  {
        Type = Isaac.GetEntityTypeByName("Blood Big Bony"), 
        Variant = Isaac.GetEntityVariantByName("Blood Big Bony"),
        SubType = 0
    },
}

local function GetBoneData(ent, init)
    return BloodBony:GetData(ent, init, function() return {Inited = false} end);
end

local function GetBonyData(ent, init)
    return BloodBony:GetTempData(ent, init, function() return {DamageCooldown = -1} end);
end

function BloodBony:IsBloodBony(ent)
    return ent.Type == self.Type and ent.Variant == self.Variant;
end
function BloodBony:IsSoulBony(ent)
    local Soul = self.Variants.SOUL;
    return ent.Type == Soul.Type and ent.Variant == Soul.Variant
end
function BloodBony:IsTemporaryDevilBony(ent)
    local DevilTemporary = self.Variants.DEVIL_TEMPORARY;
    
    if (ent.Type == DevilTemporary.Type and ent.Variant == DevilTemporary.Variant) then
        return true;
    end
    return false;
end
function BloodBony:IsDevilBony(ent)
    local Devil = self.Variants.DEVIL;
    if (ent.Type == Devil.Type and ent.Variant == Devil.Variant) then
        return true;
    end
    return BloodBony:IsTemporaryDevilBony(ent);
end
function BloodBony:IsBigBony(ent)
    local Fatty = self.Variants.FATTY;
    return ent.Type == Fatty.Type and ent.Variant == Fatty.Variant
end

function BloodBony:IsBloodSkeleton(ent)
    if (self:IsBloodBony(ent)) then
        return true;
    end
    if (self:IsSoulBony(ent)) then
        return true;
    end
    if (self:IsDevilBony(ent)) then
        return true;
    end
    if (self:IsBigBony(ent)) then
        return true;
    end
    return false;
end

function BloodBony:SpawnBony(type, variant, subtype, position, player)
    local bony = Isaac.Spawn(type, variant, subtype, position, Vector.Zero, player);
    bony.Parent = player;
    bony:AddCharmed(EntityRef(player), -1);
    -- Make Bony Immune to Spikes.
    bony:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_SPIKE_DAMAGE);
    bony.CollisionDamage = 0;
    return bony
end

function BloodBony:FindOwner()
    local EikaB = THI.Players.EikaB;
    for p, player in Players.PlayerPairs() do
        if (player:GetPlayerType() == EikaB.Type) then
            return player;
        end
    end
    return Isaac.GetPlayer(0);
end

function BloodBony:PostProjectileUpdate(tear)
    if (tear.Variant == ProjectileVariant.PROJECTILE_BONE) then
        local spawner = tear.SpawnerEntity;
        if (not spawner) then
            return;
        end


        spawner.SpawnerEntity = spawner.SpawnerEntity or BloodBony:FindOwner();
        
        local boneySpawner = spawner.SpawnerEntity;
        local player = boneySpawner and boneySpawner:ToPlayer();
        local playerDamage = (player and player.Damage) or 2.5;

        local SoulBony = BloodBony.Variants.SOUL;
        local DevilBony = BloodBony.Variants.DEVIL;

        if (BloodBony:IsBloodBony(spawner)) then
            local data = GetBoneData(tear, true);
            if (not data.Inited) then
                tear:SetColor(Color(1,0,0,1,0,0,0), -1, 99, false);
                -- Bones has +5 damage itself.
                tear.CollisionDamage = playerDamage * 0.8 -5
                data.Inited = true;
            end
        elseif (BloodBony:IsSoulBony(spawner)) then
            local subtype = spawner.SubType;
            if (tear.FrameCount == 1 and spawner:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                tear:SetColor(Color(0.2,0.8,1,0.5,0,0,0), -1, 99);
                tear.CollisionDamage = playerDamage - 5;
                if ((subtype == SoulBony.SubTypes.LEVEL2 and Random() % 100 < 50) or subtype == SoulBony.SubTypes.LEVEL3) then
                    local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, tear.Position, tear.Velocity, boneySpawner):ToEffect();
                    
                    flame.CollisionDamage = playerDamage * 0.2;
                    flame:SetTimeout(60);
                end
            end
        elseif (BloodBony:IsDevilBony(spawner)) then
            local subtype = spawner.SubType;
            if (tear.FrameCount == 1) then
                tear:SetColor(Color(0.1,0.1,0.1,1,0,0,0), -1, 99);
                if (subtype == DevilBony.SubTypes.LEVEL2) then
                    tear:AddProjectileFlags(ProjectileFlags.SMART_PERFECT);
                    tear.CollisionDamage = playerDamage * 2;
                elseif (subtype == DevilBony.SubTypes.LEVEL3) then
                    tear:AddProjectileFlags(ProjectileFlags.SMART_PERFECT);
                    tear.CollisionDamage = playerDamage * 3;
                else
                    tear.CollisionDamage = playerDamage;
                end
            end
        end
    end
end
BloodBony:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, BloodBony.PostProjectileUpdate);

local function PostUpdate(mod)
    
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_BONE)) do
        local spawner = ent.SpawnerEntity;
        if (spawner and BloodBony:IsDevilBony(spawner)) then
            local DevilBony = BloodBony.Variants.DEVIL
            local proj = ent:ToProjectile();
                
            local boneySpawner = spawner.SpawnerEntity;
            local player;
            if (boneySpawner) then
                player = boneySpawner:ToPlayer()
            end
            if (proj:IsDead() and spawner.SubType == DevilBony.SubTypes.LEVEL3) then
                local ball = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL, 0, proj.Position, Vector.Zero, player):ToEffect();
                ball.Parent = player;
                ball.CollisionDamage = proj.CollisionDamage * 0.2;
                ball:SetTimeout(10);
                THI.SFXManager:Play(SoundEffect.SOUND_BLOOD_LASER)
            end
        end
    end
end
BloodBony:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

local ClearColor = Color(1,1,1,0,0,0,0);
local function PostNPCUpdate(mod, npc)
    if (BloodBony:IsBloodSkeleton(npc)) then
        if(npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local data = GetBonyData(npc, false);
            if (data) then
                if (data.DamageCooldown > 0) then
                    data.DamageCooldown = data.DamageCooldown - 1;
                end
            end

            -- Avoid skeleton eaten by Rotgut.
            for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_ROTGUT, 0)) do
                local distance = ent.Position:Distance(npc.Position);
                if (ent:ToNPC().State == 16 and distance < 60) then
                    local speed = (60 - distance) /60 * 10;
                    local vel = (npc.Position - ent.Position):Resized(speed);
                    npc:AddVelocity(vel);
                end
            end
        end
    end
end
BloodBony:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate);

local function PostNPCInit(mod, npc)
    if (BloodBony:IsSoulBony(npc)) then
        local subType = npc.SubType;
        local soulBony = BloodBony.Variants.SOUL;
        local stage = Game():GetLevel():GetStage();
        local maxHP = npc.MaxHitPoints;
        if (subType == soulBony.SubTypes.LEVEL2) then
            local spr = npc:GetSprite();
            spr:Load("gfx/reverie/227.581.1_soul bony l2.anm2", true);
            npc.MaxHitPoints = 8 + stage * 2;
        elseif (subType == soulBony.SubTypes.LEVEL3) then
            local spr = npc:GetSprite();
            spr:Load("gfx/reverie/227.581.2_soul bony l3.anm2", true);
            npc.MaxHitPoints = 12 + stage * 3;
        end
        npc.HitPoints = npc.HitPoints + math.max(0, npc.MaxHitPoints - maxHP);
    elseif (BloodBony:IsDevilBony(npc)) then
        local subType = npc.SubType;
        local devilBony = BloodBony.Variants.DEVIL;
        local stage = Game():GetLevel():GetStage();
        local maxHP = npc.MaxHitPoints;
        if (subType == devilBony.SubTypes.LEVEL2) then
            local spr = npc:GetSprite();
            spr:Load("gfx/reverie/277.580.1_devil bony l2.anm2", true);
            npc.MaxHitPoints = 8 + stage * 2;
        elseif (subType == devilBony.SubTypes.LEVEL3) then
            local spr = npc:GetSprite();
            spr:Load("gfx/reverie/277.580.2_devil bony l3.anm2", true);
            npc.MaxHitPoints = 12 + stage * 3;
        end
        npc.HitPoints = npc.HitPoints + math.max(0, npc.MaxHitPoints - maxHP);
    end
end
BloodBony:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostNPCInit);

local function ConvertHeart(self,bonyVariant, position, amount, spawner)
    local upgradeTimes = math.ceil(amount / 2);
    local level1 = bonyVariant.SubTypes.LEVEL1;
    local level2 = bonyVariant.SubTypes.LEVEL2;
    local level3 = bonyVariant.SubTypes.LEVEL3;
    -- Upgrade all possible bonies.
    for i, ent in pairs(Isaac.FindByType(bonyVariant.Type, bonyVariant.Variant)) do
        if (upgradeTimes <= 0) then
            break;
        end

        local npc = ent:ToNPC();
        local subType = ent.SubType;
        local times = upgradeTimes;
        for i = 1, times do
            local isLevel1 = subType == level1;
            local isLevel2 = subType == level2;
            -- Upgradable.
            if (isLevel1 or isLevel2) then
                if (isLevel2) then
                    subType = level3;
                else
                    subType = level2;
                end
                upgradeTimes = upgradeTimes - 1;
            else
                break;
            end
        end

        if (subType ~= ent.SubType) then
            npc:Remove();
            self:SpawnBony(bonyVariant.Type, bonyVariant.Variant, subType, position, spawner);
        end

    end

    -- If there are spare soul hearts:
    if (upgradeTimes > 0) then
        local newLevel3Bonies = math.floor(upgradeTimes / 3);
        local remainderLevel = upgradeTimes % 3;
        for i = 1, newLevel3Bonies do
            self:SpawnBony(bonyVariant.Type, bonyVariant.Variant, level3, position, spawner);
        end

        local remainderSubType = remainderLevel - 1;
        if (remainderSubType >= 0) then
            self:SpawnBony(bonyVariant.Type, bonyVariant.Variant, remainderSubType, position, spawner);
        end
    end
end

function BloodBony:ConvertSoulHearts(position, amount, spawner)
    local bonyVariant = BloodBony.Variants.SOUL;
    ConvertHeart(self, bonyVariant, position, amount, spawner)
end


function BloodBony:ConvertBlackHearts(position, amount, spawner)
    local bonyVariant = BloodBony.Variants.DEVIL;
    ConvertHeart(self,bonyVariant, position, amount, spawner)
end

function BloodBony:Regenerate(entity)
    entity.HitPoints = math.min(entity.MaxHitPoints, entity.HitPoints + entity.MaxHitPoints / 30);
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, entity.Position, Vector.Zero, entity);
    effect.DepthOffset = 10;
    THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP, 0.3)
end

local function PostPlayerEffect(mod, player)
    local EikaB = THI.Players.EikaB;
    if (EikaB.BirthrightMode == 0 and player:IsFrame(30, 0)) then
        local hash = GetPtrHash(player);
        if (player:GetPlayerType() == EikaB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            for i, ent in pairs(Isaac.GetRoomEntities()) do
                local isHolyBony = ent.Type == EntityType.ENTITY_BONY and ent.Variant == 1;
                if (BloodBony:IsBloodSkeleton(ent) or isHolyBony) then
                    if(ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and ent.HitPoints < ent.MaxHitPoints) then
                        -- Birthright.
                        local boneySpawner = ent.SpawnerEntity;
                        local p = nil;
                        if (boneySpawner) then
                            p = boneySpawner:ToPlayer();
                        end
                
                        if (GetPtrHash(p) == hash) then
                            BloodBony:Regenerate(ent)
                        end
                    end
                end
            end
        end
    end
end
BloodBony:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

local function PostEntityKill(mod, entity) 
    local subtype = -1;
    if (BloodBony:IsSoulBony(entity)) then
        subtype = HeartSubType.HEART_SOUL;
    elseif (BloodBony:IsTemporaryDevilBony(entity)) then
        subtype = -1;
    elseif (BloodBony:IsDevilBony(entity)) then
        subtype = HeartSubType.HEART_BLACK;
    elseif (BloodBony:IsBigBony(entity)) then
        subtype = HeartSubType.HEART_BONE;
    end

    if (subtype >= 0) then
        local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, subtype, entity.Position, RandomVector(), entity):ToPickup();
        heart.Timeout = 90;
    end

    local EikaB = THI.Players.EikaB;
    if (EikaB.BirthrightMode == 1) then
        if (BloodBony:IsBloodSkeleton(entity)) then
        
            -- local maxDamage = 0;
            -- local maxDamagePlayer = nil
            -- for p, player in Players.PlayerPairs() do
            --     if (player:GetPlayerType() == EikaB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            --         if (player.Damage > maxDamage) then
            --             maxDamage = player.Damage;
            --             maxDamagePlayer = player;
            --         end
            --     end
            -- end

            -- if (maxDamagePlayer) then
            --     local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.ENEMY_GHOST, 1, entity.Position, Vector.Zero, entity):ToEffect();
            --     THI.SFXManager:Play(SoundEffect.SOUND_DEMON_HIT, 0.2);
            --     --exp.CollisionDamage = maxDamage * 10;
            -- end

            local birthrightPlayer = false;
            for p, player in Players.PlayerPairs() do
                if (player:GetPlayerType() == EikaB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                    birthrightPlayer = player;
                    break;
                end
            end
            if (birthrightPlayer) then
                Game():BombExplosionEffects (entity.Position, entity.MaxHitPoints * 5, TearFlags.TEAR_NORMAL, Color(1,0,0,1,0,0,0), birthrightPlayer, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR);
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, entity.Position, Vector.Zero, entity);
                THI.SFXManager:Play(THI.Sounds.SOUND_CORPSE_EXPLODE_CAST, 2);
                THI.SFXManager:Play(THI.Sounds.SOUND_CORPSE_EXPLODE, 2);
            end
        end
    end
end
BloodBony:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);

function BloodBony:PreEntityTakeDamage(tookDamage, amount, flags, source, countdown)
    if (BloodBony:IsBloodSkeleton(tookDamage)) then
        if(tookDamage:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            if (Game():GetRoom():IsClear()) then
                return false;
            end
            
            if (flags & DamageFlag.DAMAGE_SPIKES > 0) then
                return false;
            end

            if (source.Type == EntityType.ENTITY_FIREPLACE) then
                return false;
            end
            local data = GetBonyData(tookDamage, false);
            if (data and data.DamageCooldown > 0) then
                return false;
            end
            
            if (amount > 1) then
                tookDamage:TakeDamage(1, flags, source, countdown);
                return false;
            end

            data = GetBonyData(tookDamage, true);
            data.DamageCooldown = 30;
        end
    end
end
BloodBony:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, BloodBony.PreEntityTakeDamage);

return BloodBony;