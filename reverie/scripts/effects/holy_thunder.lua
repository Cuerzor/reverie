local Thunder = ModEntity("Holy Thunder", "HOLY_THUDNER");

Thunder.SubTypes = {
    NORMAL = 0,
    DELAYED = 1;
}

local function ChainLightning(position, damage, radius, spawner, blacklist)
    
    for i, ent in ipairs(Isaac.FindInRadius(position, radius, EntityPartition.ENEMY)) do
        local hash = GetPtrHash(ent);
        if (not blacklist[hash] and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            blacklist[hash] = true;
            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, LaserSubType.LASER_SUBTYPE_LINEAR, position, Vector.Zero, spawner):ToLaser();
            laser.Timeout = 3;
            laser.OneHit = true;
            laser.CollisionDamage = damage;
            laser.PositionOffset = Vector(0, -10);

            local ent2Source = ent.Position - position;
            if (ent2Source:Length() < 0.1) then
                ent2Source = Vector(0, 1);
            end
            ent2Source = ent2Source:Resized(math.max(8, ent2Source:Length()))
            laser.AngleDegrees = ent2Source:GetAngleDegrees();
            laser.MaxDistance = ent2Source:Length() + ent.Size;
            laser.Position = laser.Position - ent2Source:Normalized() * ent.Size / 2;
            laser.TearFlags = laser.TearFlags | TearFlags.TEAR_PIERCING;

            --ent:AddFreeze(EntityRef(spawner), 30);

            ChainLightning(ent.Position, damage, radius, spawner, blacklist);
        end
    end
end

local function Shock(thunder)
    local spr = thunder:GetSprite();
    spr:Play("Shock");
    local halfVector = Vector(0.5, 0.5)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, thunder.Position, Vector.Zero, thunder);
    local game = Game();
    game:SpawnParticles (thunder.Position, EffectVariant.EMBER_PARTICLE, 10, 10, Color.Default);
    local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, thunder.Position, Vector.Zero, thunder):ToEffect();
    exp.Scale = 0.5;
    exp.SpriteScale = halfVector;

    local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 1, thunder.Position, Vector.Zero, thunder):ToEffect();
    crater.SpriteScale = halfVector;
    crater.Timeout = 150;
    THI.SFXManager:Play(THI.Sounds.SOUND_THUNDER_SHOCK, 2);

    --Damage Enemies.
    local blacklist = {};
    local radius = 80;
    if (Game():GetRoom():HasWater()) then
        radius = radius * 3;
    end
    ChainLightning(thunder.Position, thunder.CollisionDamage, radius, thunder, blacklist)
end

-- Main.
do
    local function PostThunderInit(mod, thunder)
        local spr = thunder:GetSprite();
        spr:Play("Appear");

    end
    Thunder:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostThunderInit, Thunder.Variant);

    local function PostThunderUpdate(mod, thunder)

        if (thunder.SubType == Thunder.SubTypes.DELAYED) then
            if (thunder.FrameCount == 30) then
                Shock(thunder);
            end
        else
            if (thunder.FrameCount == 1) then
                Shock(thunder);
            end
        end
        local spr = thunder:GetSprite();
        if (spr:IsFinished("Shock")) then
            thunder:Remove();
        end
    end
    Thunder:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostThunderUpdate, Thunder.Variant);
end

return Thunder;
