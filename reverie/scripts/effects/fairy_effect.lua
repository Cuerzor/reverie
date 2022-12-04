local Effect = ModEntity("Fairy Effect", "FAIRY_EFFECT");

local function PostEffectUpdate(mod, effect)
    local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer();
    if (player == nil) then
        effect:Remove();
        return
    end
    
    local maxTime = 120;
    local time = effect.FrameCount;
    local t = time ^ 2 / 3
    local dir = Vector.FromAngle(t);
    effect.Velocity = player.Position + player.Velocity + dir * 20 - effect.Position;
    local scale = (maxTime - time) / maxTime;
    effect.Size = scale;
    effect.SpriteScale = Vector(scale, scale);
    effect.PositionOffset = Vector(0, -time / 4);

    local Particle = THI.Effects.FairyParticle;
    
    local partVel = dir * (Random() % 1000 / 1000 * 5);
    local particle = Isaac.Spawn(Particle.Type, Particle.Variant, 0, effect.Position, partVel, effect):ToEffect();
    particle.m_Height = particle.m_Height + effect.PositionOffset.Y;
    particle.PositionOffset = particle.PositionOffset + effect.PositionOffset;
    if (scale <= 0) then
        effect:Remove();
    end
end
Effect:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Effect.Variant)


return Effect;