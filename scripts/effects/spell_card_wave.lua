
local Wave = ModEntity("Spell Card Wave", "SPELL_CARD_WAVE");
Wave.RNG = RNG();
Wave.SubTypes = {
    SHRINK = 0,
    BURST = 1
}

function Wave.Shrink(position, count)
    count = count or 15;
    position = position or Vector(320, 280);
    
    local Leaf = THI.Effects.SpellCardLeaf;
    local rng = Wave.RNG;
    for i = 1, count do
        local angle = rng:RandomFloat()* 360;
        local length = rng:RandomFloat() * 80 + 160;
        local sizeX = rng:RandomFloat()  + 0.5;
        local sizeY = rng:RandomFloat()  + 0.5;
        local rotation = rng:RandomFloat()* 360;
        local speed = rng:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(Leaf.Type, Leaf.Variant, 0, position + offset, -offset/ 21 * speed, nil);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end

    local waveEnt = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.SHRINK, position, Vector.Zero, nil);
    --THI.SFXManager:Play(SoundEffect.SOUND_FRAIL_CHARGE, 1, 2, false, 1.2);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE);
end

function Wave.Burst(position, count)
    count = count or 20;
    position = position or Vector(320, 280);
    
    local Leaf = THI.Effects.SpellCardLeaf;
    local rng = Wave.RNG;
    for i = 1, count do
        local angle = rng:RandomFloat()* 360;
        local length = rng:RandomFloat() * 320 + 480;
        local sizeX = rng:RandomFloat()  + 0.5;
        local sizeY = rng:RandomFloat()  + 0.5;
        local rotation = rng:RandomFloat()* 360;
        local speed = rng:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(Leaf.Type, Leaf.Variant, 0, position, offset/ 21 * speed, nil);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end
    

    local waveEnt = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, position, Vector.Zero, nil);
    --THI.SFXManager:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 1, 2, false, 0.5);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE);
end


local function PostEffectInit(mod, effect)
    local spr = effect:GetSprite();
    if (effect.SubType == Wave.SubTypes.BURST) then
        spr:Play("Burst");
    else
        spr:Play("Shrink");
    end
end
Wave:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Wave.Variant);

local function PostWaveUpdate(mod, effect)
    if (effect.Parent and effect.Parent:Exists()) then
        effect.Position = effect.Parent.Position;
    end
    local spr = effect:GetSprite();
    local animation = spr:GetAnimation();
    if (spr:IsFinished(animation)) then
        effect:Remove();
    end
end
Wave:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostWaveUpdate, Wave.Variant);


return Wave;