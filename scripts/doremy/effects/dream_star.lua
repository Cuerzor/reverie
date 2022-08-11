local Dream = GensouDream;
local Detection = CuerLib.Detection;
local DreamStar = {
    Type = Isaac.GetEntityTypeByName("Doremy Dream Star"),
    Variant = Isaac.GetEntityVariantByName("Doremy Dream Star"),
    SubType = 0
}

function DreamStar:GetColor()
    return Color(1, 1, 1, 1, 0, 0 ,0);
end

local function PostEffectInit(mod, effect)
    effect:SetColor(DreamStar:GetColor(), -1, 0);
    effect.LifeSpan = 30;
    effect.Timeout = 30;
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, DreamStar.Variant);

local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    local color = DreamStar:GetColor();
    color.A = effect.Timeout / effect.LifeSpan;
    spr.Color = color;

    -- if (not effect.Child) then
    --     local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
    --     trail.MinRadius = 0.1;
    --     trail.MaxRadius = 0.15;
    --     trail.SpriteScale = Vector(1,1);
    --     trail.Parent = effect;
    --     trail:SetColor(color, -1, 0);
    --     effect.Child = trail;
    -- else 
    --     local child = effect.Child:ToEffect();
    --     child.Position = effect.Position + effect.PositionOffset + effect.SpriteOffset * 1.5;
    --     child:SetColor(color, -1, 0);
    --     child.Timeout = 30;
    -- end

    local starData = effect:GetData();
    effect.Velocity = effect.Velocity * (starData.StarAcceleration or 1);
    effect.Velocity = effect.Velocity:Rotated(starData.StarRotation or 0);
    if (effect.Timeout <= 0)then
        effect:Remove();
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, DreamStar.Variant);

return DreamStar;