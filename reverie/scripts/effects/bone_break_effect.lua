local BoneBreakEffect = ModEntity("Bone Break Effect", "BONE_BREAK_EFFECT");

local function PostEffectInit(mod, effect)
    effect:GetSprite():Play("Idle");
end
BoneBreakEffect:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, BoneBreakEffect.Variant)

local function PostEffectUpdate(mod, effect)
    if (effect:GetSprite():IsFinished("Idle")) then
        effect:Remove();
    end
end
BoneBreakEffect:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, BoneBreakEffect.Variant)

return BoneBreakEffect;