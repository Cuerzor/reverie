local Inputs = CuerLib.Inputs;
local Entities = CuerLib.Entities;
local Consts = CuerLib.Consts;
local Synergies = CuerLib.Synergies;
local Tech666 = ModItem("Technology 666", "Tech666");

local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;

local LaserColor = Color(1, 1, 1, 1, 0.5, 1, 0.5);

local DamageSourceAlt = {
    Type = Isaac.GetEntityTypeByName("Damage Source Alternate"),
    Variant = Isaac.GetEntityVariantByName("Damage Source Alternate"),
    NuclearBrimstone = 1
}

local maxFireDelay = 30;


function Tech666.GetNPCTempData(npc, init)
    local data = npc:GetData();
    if (init) then
        data._TECH666 = data._TECH666 or {
            ReleaseBrimstone = false,
            ReleaseClearTime = 0,
            BrimstoneSpawner = nil
        }
    end
    return data._TECH666;
end

function Tech666.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        data._TECH666 = data._TECH666 or {
            FireDelay = 0,
            MarkedTarget = nil,
            Brimstone = nil,
        }
    end
    return data._TECH666;
end

function Tech666.IsAllDirectionShoot(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or
               player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
end


function Tech666.GetShootingVector(player)
    local target = Synergies.GetMarkedTarget(player);
    if (target) then
        return (target.Position - player.Position):Normalized();
    end

    local raw = Inputs.GetRawShootingVector(player);
    if (Tech666.IsAllDirectionShoot(player)) then
        return raw;
    end

    if (raw:Length() > 0.1) then
        local headDirection = player:GetHeadDirection ( );
    
        return Consts.DirectionVectors[headDirection];
    end
    return Vector.Zero;
end


function Tech666.FireLaser(player, dir)
    local source = Isaac.Spawn(DamageSourceAlt.Type, DamageSourceAlt.Variant, DamageSourceAlt.NuclearBrimstone, player.Position, Vector.Zero, player);
    local laser = player:FireBrimstone(dir, source, 0.15);
    laser:SetColor(LaserColor, -1, 0, false, false);
    laser.SpawnerEntity = source;
    laser.MaxDistance = -1;
    source.Child = laser;
    return laser;
end

function Tech666:PostPlayerEffect(player)
    if (player:HasCollectible(Tech666.Item)) then
        if (player:IsExtraAnimationFinished()) then
            local data = Tech666.GetPlayerTempData(player, true);
            if (data.FireDelay > 0) then
                data.FireDelay = data.FireDelay - 1;
            end
            local shooting = Tech666.GetShootingVector(player);
            if (data.FireDelay <= 0) then
                local headDirection = player:GetHeadDirection ( );
                local headVector = Consts.DirectionVectors[headDirection];
                if (shooting:Length() > 0.1) then
                    local laser = Tech666.FireLaser(player, shooting);
                    laser.PositionOffset = Vector(headVector.X * 24 * player.SpriteScale.X, -40 * player.SpriteScale.Y);
                    data.Brimstone = laser;

                    data.FireDelay = data.FireDelay + maxFireDelay;
                end 
            end

            if (EntityExists(data.Brimstone)) then
                local brimstone = data.Brimstone;
                if (shooting:Length() > 0.1 and Tech666.IsAllDirectionShoot(player)) then
                    brimstone.AngleDegrees = shooting:GetAngleDegrees();
                end
            end
        end
    end
end
Tech666:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Tech666.PostPlayerEffect);

function Tech666:PostNPCUpdate(npc)
    local npcData = Tech666.GetNPCTempData(npc, false);
    if (npcData) then
        if (npcData.ReleaseBrimstone) then
            npcData.ReleaseClearTime = npcData.ReleaseClearTime - 1;
            if (npcData.ReleaseClearTime <= 0) then
                npcData.ReleaseBrimstone = false;
                npcData.BrimstoneSpawner = nil;
            end
        end
    end
end
Tech666:AddCallback(ModCallbacks.MC_NPC_UPDATE, Tech666.PostNPCUpdate);

function Tech666:PostNPCKill(npc)
    
    if (npc:IsEnemy()) then
        local npcData = Tech666.GetNPCTempData(npc, false);
        if (npcData and npcData.BrimstoneSpawner) then
            -- Release 6 lasers.
            local spawner = npcData.BrimstoneSpawner.SpawnerEntity;
            local player;
            if (spawner) then
                player = spawner:ToPlayer();;
            end
            if (player) then
                for i = 1, 6 do
                    local angle = (player.Position - npc.Position):GetAngleDegrees() + 30 + i * 60;
                    local laser = Tech666.FireLaser(player, Vector.FromAngle(angle));
                    laser.DisableFollowParent = true;
                    laser.Position = npc.Position;
                    laser.Timeout = 30;
                end

                THI.Game:BombExplosionEffects (npc.Position, npc.MaxHitPoints / 2, TearFlags.TEAR_NORMAL, LaserColor, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR )
            end
        end
    end
end
Tech666:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Tech666.PostNPCKill);

function Tech666:PostSourceUpdate(effect)
    if (effect.SubType == DamageSourceAlt.NuclearBrimstone) then
        if (not EntityExists(effect.Child)) then
            effect:Remove();
        end
    end
end
Tech666:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Tech666.PostSourceUpdate, DamageSourceAlt.Variant);

function Tech666:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    local sourceEnt = source.Entity;
    if (tookDamage:IsEnemy()) then
        local player;
        local isTech666Brimstone;
        while (EntityExists(sourceEnt)) do
            if (sourceEnt.Type == DamageSourceAlt.Type and sourceEnt.Variant == DamageSourceAlt.Variant and sourceEnt.SubType == DamageSourceAlt.NuclearBrimstone) then
                isTech666Brimstone = true;
                break;
            end
            sourceEnt = sourceEnt.SpawnerEntity;
        end
        if (isTech666Brimstone) then
            local npcData = Tech666.GetNPCTempData(tookDamage, true);
            npcData.ReleaseBrimstone = true;
            npcData.ReleaseClearTime = 5;
            npcData.BrimstoneSpawner = sourceEnt;
        else
            -- Remove brimstone flag when get hurt.
            local npcData = Tech666.GetNPCTempData(tookDamage, false);
            if (npcData) then
                npcData.ReleaseBrimstone = false;
                npcData.ReleaseClearTime = 0;
                npcData.BrimstoneSpawner = nil;
            end
        end
    end
end
Tech666:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, Tech666.PostTakeDamage);

return Tech666;