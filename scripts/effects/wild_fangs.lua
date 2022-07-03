local WildFangs = ModEntity("Wild Fangs", "WILD_FANGS");

WildFangs.SubTypes = {
    NORMAL = 0,
    BITE = 1,
}

local function PostEffectInit(mod, effect)
    if (effect.SubType == WildFangs.SubTypes.BITE) then
        effect:GetSprite():Play("Bite");
    end
end
WildFangs:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, WildFangs.Variant);

local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    if (spr:IsFinished(spr:GetAnimation())) then
        effect:Remove();
    end
end
WildFangs:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, WildFangs.Variant);

return WildFangs;