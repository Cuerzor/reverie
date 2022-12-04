local Wave = ModEntity("Reverie Note Wave", "REVERIE_NOTE_WAVE");


local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    if (spr:IsFinished(spr:GetAnimation())) then
        effect:Remove();
    end
end
Wave:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Wave.Variant);

return Wave;