local PickupEffect = ModEntity("Pickup Effect", "PickupEffect");

local function PostEffectUpdate(mod, effect)
    if (effect:GetSprite():IsFinished("Collect")) then
        effect:Remove();
    end
end
PickupEffect:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, PickupEffect.Variant);

return PickupEffect;