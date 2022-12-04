local Dream = GensouDream;
local Trail = {
    Type = Isaac.GetEntityTypeByName("Nightmare Trail"),
    Variant = Isaac.GetEntityVariantByName("Nightmare Trail"),
    SubType = 0
}

function Trail:SpawnTrail(entity, velocity)
    velocity = velocity or RandomVector();
    local spr = entity:GetSprite();
    local trail = Isaac.Spawn(self.Type, self.Variant, self.SubType, entity.Position + entity.PositionOffset, velocity, entity):ToEffect();
    local trailSpr = trail:GetSprite();
    trailSpr:Load(spr:GetFilename(), true);
    trailSpr:SetFrame(spr:GetAnimation(), spr:GetFrame());
    trailSpr:SetOverlayFrame(spr:GetOverlayAnimation(), spr:GetOverlayFrame());
    trailSpr.FlipX = spr.FlipX;
    trailSpr.PlaybackSpeed = 0;
    trail.LifeSpan = 10;
    trail.Timeout = trail.LifeSpan;
    trail.DepthOffset = 20 - entity.PositionOffset.Y;
    return trail;
end

local function PostEffectUpdate(mod, effect)
    effect.Velocity = effect.Velocity:Rotated(3);
    local spr = effect:GetSprite();
    local color = spr.Color;
    local color = spr.Color;
    spr.Color = Color(color.R, color.G, color.B, effect.Timeout / effect.LifeSpan / 2);
    if (effect.Timeout <= 0) then
        effect:Remove();
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Trail.Variant);


return Trail;