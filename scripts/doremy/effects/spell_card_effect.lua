local Dream = GensouDream;
local SpellCardEffect = {
    Leaf = {
        Type = Isaac.GetEntityTypeByName("Spell Card Leaf"),
        Variant = Isaac.GetEntityVariantByName("Spell Card Leaf"),
    },
    Wave = {
        Type = Isaac.GetEntityTypeByName("Spell Card Wave"),
        Variant = Isaac.GetEntityVariantByName("Spell Card Wave"),
    },
    RNG = RNG()
}
function SpellCardEffect.Absorb(position, count)
    count = count or 15;
    position = position or Vector(320, 280);
    
    for i = 1, count do
        local angle = SpellCardEffect.RNG:RandomFloat()* 360;
        local length = SpellCardEffect.RNG:RandomFloat() * 80 + 160;
        local sizeX = SpellCardEffect.RNG:RandomFloat()  + 0.5;
        local sizeY = SpellCardEffect.RNG:RandomFloat()  + 0.5;
        local rotation = SpellCardEffect.RNG:RandomFloat()* 360;
        local speed = SpellCardEffect.RNG:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(SpellCardEffect.Leaf.Type, SpellCardEffect.Leaf.Variant, 0, position + offset, -offset/ 21 * speed, nil);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end

    local waveEnt = Isaac.Spawn(SpellCardEffect.Wave.Type, SpellCardEffect.Wave.Variant, 0, position, Vector.Zero, nil);
    waveEnt:GetSprite():Play("Shrink");
    --THI.SFXManager:Play(SoundEffect.SOUND_FRAIL_CHARGE, 1, 2, false, 1.2);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE);
end

function SpellCardEffect.Burst(position, count)
    count = count or 20;
    position = position or Vector(320, 280);
    
    for i = 1, count do
        local angle = SpellCardEffect.RNG:RandomFloat()* 360;
        local length = SpellCardEffect.RNG:RandomFloat() * 320 + 480;
        local sizeX = SpellCardEffect.RNG:RandomFloat()  + 0.5;
        local sizeY = SpellCardEffect.RNG:RandomFloat()  + 0.5;
        local rotation = SpellCardEffect.RNG:RandomFloat()* 360;
        local speed = SpellCardEffect.RNG:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(SpellCardEffect.Leaf.Type, SpellCardEffect.Leaf.Variant, 0, position, offset/ 21 * speed, nil);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end
    

    local waveEnt = Isaac.Spawn(SpellCardEffect.Wave.Type, SpellCardEffect.Wave.Variant, 0, position, Vector.Zero, nil);
    waveEnt:GetSprite():Play("Burst");
    --THI.SFXManager:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 1, 2, false, 0.5);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE);
end

function SpellCardEffect.postInit(mod, effect)
    local index = SpellCardEffect.RNG:RandomInt(2);
    effect:GetSprite():Play("Idle"..index);
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, SpellCardEffect.postInit, SpellCardEffect.Leaf.Variant);

function SpellCardEffect.postUpdate(mod, effect)
    if (effect:GetSprite():WasEventTriggered("Destroy")) then
        effect:Remove();
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SpellCardEffect.postUpdate, SpellCardEffect.Leaf.Variant);


function SpellCardEffect.postWaveUpdate(mod, effect)
    local spr = effect:GetSprite();
    local animation = spr:GetAnimation();
    if (spr:IsFinished(animation)) then
        effect:Remove();
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SpellCardEffect.postUpdate, SpellCardEffect.Wave.Variant);


return SpellCardEffect;