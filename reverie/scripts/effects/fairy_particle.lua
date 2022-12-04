local Particle = ModEntity("Fairy Particle", "FAIRY_PARTICLE");

local function PostParticleInit(mod, effect)
    effect.FallingAcceleration = 1;
    effect.FallingSpeed = -10;
    effect.m_Height = -10;
end
Particle:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostParticleInit, Particle.Variant)

local function PostParticleUpdate(mod, effect)
    local scale = 1 - effect.FrameCount / 30;
    effect.SpriteScale = Vector(scale, scale)
    effect.FallingSpeed = effect.FallingSpeed + effect.FallingAcceleration;
    effect.m_Height = effect.m_Height + effect.FallingSpeed;
    effect.PositionOffset = Vector(0, effect.m_Height);
    if (effect.m_Height >= 0 or scale <= 0) then
        effect:Remove();
    end
end
Particle:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostParticleUpdate, Particle.Variant)

return Particle;