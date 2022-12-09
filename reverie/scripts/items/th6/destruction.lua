

local Destruction = ModItem("Destruction", "Destruction");
Destruction.rng = RNG();
Destruction.Meteor = {
    Type = Isaac.GetEntityTypeByName("Meteor"),
    Variant = Isaac.GetEntityVariantByName("Meteor"),
    MaxTime = 90,
    MaxHeight = -3000,
    Damage = 495
};
Destruction.MeteorRing = {
    Type = Isaac.GetEntityTypeByName("Meteor Ring"),
    Variant = Isaac.GetEntityVariantByName("Meteor Ring"),
};
Destruction.MeteorFrag = {
    Type = Isaac.GetEntityTypeByName("Meteor Frag"),
    Variant = Isaac.GetEntityVariantByName("Meteor Frag"),
};

local WispExplosionColor = Color(0.2,0.2,0.2,1,0,0,0);


function Destruction.GetDestructionData(init)
    return Destruction:GetGlobalData(init, function() return {
        Spawner = nil,
        MeteorTime = 0,
        FallingMeteors = false
    }end);
end

function Destruction:GetMeteorData(meteor)
    return Destruction:GetData(meteor, true, function() return {
        Position = Vector.Zero,
        Height = 0,
        Time = 0
    } end);
end

function Destruction:GetMeteorRingData(ring)
    return Destruction:GetData(ring, true, function() return {
        Time = 0
    } end);
end

function Destruction.SpawnMeteor(position, spawner)
    
    local meteor = Isaac.Spawn(Destruction.Meteor.Type, Destruction.Meteor.Variant, 0, position + Vector(0, Destruction.Meteor.MaxHeight), Vector.Zero, spawner):ToEffect();
    meteor.Scale = 3;
    meteor.SpriteScale = Vector(3, 3);
    local meteorData = Destruction:GetMeteorData(meteor);
    meteorData.Position = position;
    meteorData.Time = 0;
    
    local ring = Isaac.Spawn(Destruction.MeteorRing.Type, Destruction.MeteorRing.Variant, 0, position, Vector(0, 0), spawner):ToEffect();
    ring.Scale = 1.5;
    ring.SpriteScale = Vector(1.5, 1.5);
    local ringData = Destruction:GetMeteorRingData(meteor);
    ringData.Time = 0;
end

function Destruction:onUseDestruction(t, RNG, player, flags, slot)
    local global = Destruction.GetDestructionData(true);
    global.Spawner = player;
    global.MeteorTime = 0;
    global.FallingMeteors = true;
    Destruction.SpawnMeteor(player.Position, player)
    
    return { ShowAnim = true }
end

function Destruction:MeteorBurst(effect)
    local data = Destruction:GetMeteorData(effect);
    Isaac.Explode (data.Position, effect, Destruction.Meteor.Damage)
    local game = Game();
    game:ShakeScreen(30);
    game:MakeShockwave(data.Position, 0.1, 0.02, 20);
    SFXManager():Play(SoundEffect.SOUND_EXPLOSION_STRONG);
    
    for i=0,9 do
        local rad = Destruction.rng:RandomFloat() * 2 * math.pi;
        local dir =Vector(-math.sin(rad), math.cos(rad));
        local velocity = dir * 15;
        local frag = Isaac.Spawn(Destruction.MeteorFrag.Type, Destruction.MeteorFrag.Variant, 0, data.Position, velocity, effect):ToTear();
        frag.CollisionDamage = 5;
        frag.SpriteScale = Vector(0.5, 0.5);
        frag.TearFlags = frag.TearFlags | TearFlags.TEAR_BURN | TearFlags.TEAR_ROCK;
    end
    
    for i=0,11 do
        local rad = Destruction.rng:RandomFloat() * 2 * math.pi;
        local dir = Vector(-math.sin(rad), math.cos(rad));
        local velocity = dir * (Destruction.rng:RandomFloat() + 0.5) * 10;
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HOT_BOMB_FIRE, 0, data.Position, velocity, effect);
    end
    
    
    
    
    effect:Kill();
    effect:Remove();
end

function Destruction:onMeteorRingUpdate(effect)
    local data = Destruction:GetMeteorRingData(effect);
    data.Time = data.Time + 1;
    
    if (data.Time >= Destruction.Meteor.MaxTime) then
        effect:Remove();
    end
end

function Destruction:PostUpdate()
    local global = Destruction.GetDestructionData(false);
    if (global) then
        if (global.FallingMeteors) then
            global.MeteorTime = (global.MeteorTime or 0) + 1;
            if (global.MeteorTime >= 90) then
                global.MeteorTime = 0;
                local pos;
                if (global.Spawner) then
                    pos = global.Spawner.Position
                else
                    pos = THI.Game:GetRoom():GetRandomPosition(0);
                end
                Destruction.SpawnMeteor(pos, global.Spawner)
            end
        end
    end
end
Destruction:AddCallback(ModCallbacks.MC_POST_UPDATE, Destruction.PostUpdate)

function Destruction:PostNewRoom()
    local global = Destruction.GetDestructionData(false);
    if (global) then
        global.FallingMeteors = false;
        global.MeteorTime = 0;
        global.Spawner = nil;
    end
end
Destruction:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Destruction.PostNewRoom)

function Destruction:onMeteorFragUpdate(tear)
    tear:GetSprite().Rotation = tear.Velocity:GetAngleDegrees() - 90;
end

function Destruction:onMeteorUpdate(effect)
    local data = Destruction:GetMeteorData(effect);
    data.Time = data.Time + 1;
    --effect.Position.Y =  data.Position.Y + (1 - data.Time / Destruction.Meteor.MaxTime) * Destruction.Meteor.MaxHeight;
    
    effect.Velocity = data.Position + Vector(0, (1 - data.Time / Destruction.Meteor.MaxTime) * Destruction.Meteor.MaxHeight) - effect.Position;
    if (effect.Position.Y >= data.Position.Y) then
        Destruction:MeteorBurst(effect);
    end
end

function Destruction:onMeteorRender(effect)
    local data = Destruction:GetMeteorData(effect);
    effect.DepthOffset = data.Position.Y - effect.Position.Y
end

function Destruction:onMeteorFragRemove(tear)
    if (tear.Variant == Destruction.MeteorFrag.Variant) then
        local player = THI.Game:GetPlayer(0);
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_POOF, 0, tear.Position, Vector(0, 0), tear);
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, tear.Position, Vector(0, 0), tear):ToEffect();
        poof.Color = Color(1,1,1,1,1,0.5,0)
        THI.SFXManager:Play(SoundEffect.SOUND_STONE_IMPACT, math.min(1, 1 - math.max(0, tear.Position:Distance(player.Position)/600)));
    end
end

function Destruction:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == Destruction.Item) then
        THI.Game:BombExplosionEffects (familiar.Position, 20, TearFlags.TEAR_NORMAL, WispExplosionColor, familiar.Player, 0.5, true, false, DamageFlag.DAMAGE_EXPLOSION )
    end
end
Destruction:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Destruction.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);

Destruction:AddCallback(ModCallbacks.MC_USE_ITEM, Destruction.onUseDestruction, Destruction.Item);
Destruction:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Destruction.onMeteorRender, Destruction.Meteor.Variant);
Destruction:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Destruction.onMeteorRingUpdate, Destruction.MeteorRing.Variant);
Destruction:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Destruction.onMeteorUpdate, Destruction.Meteor.Variant);
Destruction:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Destruction.onMeteorFragUpdate, Destruction.MeteorFrag.Variant);
Destruction:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Destruction.onMeteorFragRemove, Destruction.MeteorFrag.Type);


return Destruction;