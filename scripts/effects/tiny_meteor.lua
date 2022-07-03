local TinyMeteor = ModEntity("Tiny Meteor", "TINY_METEOR");

local function PostEffectInit(mod, effect)
    effect.PositionOffset = effect.Timeout * Vector(0, -2000);
end
TinyMeteor:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, TinyMeteor.Variant)
local function PostEffectUpdate(mod, effect)
    effect.Timeout = effect.Timeout - 1;
    effect.PositionOffset = effect.Timeout * Vector(0, -20):Rotated(effect.SpriteRotation);
    if (effect.Timeout < 0) then
        effect:Remove();
        Game():BombExplosionEffects(effect.Position, effect.CollisionDamage, TearFlags.TEAR_NORMAL, Color.Default, effect.SpawnerEntity, 1, true, false);
        Game():ShakeScreen(3);
    end
end
TinyMeteor:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, TinyMeteor.Variant)

return TinyMeteor;