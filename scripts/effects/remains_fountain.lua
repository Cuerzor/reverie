local Consts = CuerLib.Consts;
local RemainsFountain = ModEntity("Blood Fountain", "REMAINS_FOUNTAIN");
RemainsFountain.SubTypes = {
    BLOODY = 0,
    BONE = 1,
    FLY = 2,
    SPIDER = 3,
    POOP = 4
}
function RemainsFountain:SpawnRemain(target, position, spawner)
    local EntityTags = THI.Shared.EntityTags;

    local subtype = self.SubTypes.BLOODY;
    local maxHP = target.MaxHitPoints;
    local timeout = 120;
    if (EntityTags:EntityFits(target, "PoopEnemies")) then
        subtype = self.SubTypes.POOP;
        timeout = 210;
    elseif (EntityTags:EntityFits(target, "BoneEnemies")) then
        subtype = self.SubTypes.BONE;
        timeout = 90;
    elseif (EntityTags:EntityFits(target, "SpiderEnemies")) then
        subtype = self.SubTypes.SPIDER;
        timeout = math.ceil(maxHP / 3.5) * 3 + 30;
    elseif (EntityTags:EntityFits(target, "FlyEnemies")) then
        subtype = self.SubTypes.FLY;
        timeout = math.ceil(maxHP / 3.5) * 3 + 30;
    end
    local fountain = Isaac.Spawn(self.Type, self.Variant, subtype, position, Vector.Zero, spawner):ToEffect();
    fountain.MaxHitPoints = maxHP;
    fountain.Timeout = timeout;
    fountain.TargetPosition = position;
    return fountain;
end

local function PostEffectInit(mod, effect)
    local spr = effect:GetSprite();
    spr:Play("Erupt");
end
RemainsFountain:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, RemainsFountain.Variant);


local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    --effect.Timeout = effect.Timeout - 1;
    effect.Velocity = effect.Position - effect.TargetPosition;


    if (effect.Timeout < 30) then
        if (spr:IsFinished("Die")) then
            if (effect.SubType == RemainsFountain.SubTypes.POOP) then
                local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOP_EXPLOSION, 0, effect.Position, Vector.Zero, effect);
                SFXManager():Play(SoundEffect.SOUND_PLOP);
            else
                local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, effect.Position, Vector.Zero, effect);
                exp.Color = effect.SplatColor;
            end
            effect:BloodExplode()
            effect:Remove();
        end
        spr:Play("Die");
    else
        local globalDamageMult = 0.2;
        if (effect.SubType == RemainsFountain.SubTypes.POOP) then
            -- Poop.
            local vel = THI.RandomFloat(5, 10) * RandomVector();
            local damageMulti = THI.RandomFloat(0.5, 1);
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, effect.Position, vel, effect):ToTear();
            tear:SetColor(Consts.Colors.PoopTear, -1, 0)
            tear.CollisionDamage = effect.MaxHitPoints * damageMulti * globalDamageMult;
            tear.Scale = damageMulti;
            tear.FallingSpeed = -THI.RandomFloat(5, 10)
            tear.FallingAcceleration = 1;
        elseif (effect.SubType == RemainsFountain.SubTypes.SPIDER) then
            -- Spider.
            if (effect:IsFrame(3, 0)) then
                local vel = THI.RandomFloat(5, 10) * RandomVector();
                local player = Isaac.GetPlayer();
                if (effect.SpawnerEntity) then
                    player = effect.SpawnerEntity:ToPlayer() or player;
                end
                player:ThrowBlueSpider (effect.Position, effect.Position + vel * 10 );
                SFXManager():Play(SoundEffect.SOUND_BOIL_HATCH);
            end
        elseif (effect.SubType == RemainsFountain.SubTypes.FLY) then
            -- Fly.
            if (effect:IsFrame(3, 0)) then
                local player = Isaac.GetPlayer();
                if (effect.SpawnerEntity) then
                    player = effect.SpawnerEntity:ToPlayer() or player;
                end
                player:AddBlueFlies (1, effect.Position, nil );
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01, 0, effect.Position, Vector.Zero, effect);
                SFXManager():Play(SoundEffect.SOUND_BOIL_HATCH);
            end
        elseif (effect.SubType == RemainsFountain.SubTypes.BONE) then
            -- Bone.
            local vel = THI.RandomFloat(5, 10) * RandomVector();
            local damageMulti = THI.RandomFloat(0.75, 1.5);
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, effect.Position, vel, effect):ToTear();
            tear:AddTearFlags(TearFlags.TEAR_BONE);
            tear.CollisionDamage = effect.MaxHitPoints * damageMulti * globalDamageMult;
            tear.Scale = damageMulti;
            tear.FallingSpeed = 0;
            tear.FallingAcceleration = -0.1;
        else
            -- Blood.
            local vel = THI.RandomFloat(5, 10) * RandomVector();
            local damageMulti = THI.RandomFloat(0.75, 1.5);
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, effect.Position, vel, effect):ToTear();
            tear.CollisionDamage = effect.MaxHitPoints * damageMulti * globalDamageMult;
            tear.Scale = damageMulti;
            tear.FallingSpeed = -THI.RandomFloat(5, 10)
            tear.FallingAcceleration = 1;
        end
    end
end
RemainsFountain:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, RemainsFountain.Variant);


return RemainsFountain;