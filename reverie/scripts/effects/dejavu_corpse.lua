local DejavuCorpse = ModEntity("Dejavu Corpse", "DEJAVU_CORPSE");

local function PostEffectInit(mod ,effect)
    effect.DepthOffset = 5;
end
DejavuCorpse:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, DejavuCorpse.Variant);

return DejavuCorpse;