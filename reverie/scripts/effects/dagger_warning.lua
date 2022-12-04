local DaggerWarning = ModEntity("Dagger Warning", "DAGGER_WARNING");


local function PostEffectInit(mod, effect)
    effect:GetSprite():Play("Idle");
end
DaggerWarning:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, DaggerWarning.Variant);

local function PostEffectUpdate(mod, effect)
    if (effect.Parent) then
        local DaggerOfServants = THI.Collectibles.DaggerOfServants;
        local player = effect.Parent:ToPlayer();
        if (not DaggerOfServants:ReadyToStab(effect.Parent) or not player or not player:HasCollectible(DaggerOfServants.Item)) then
            effect:Remove();
        end
    else
        effect:Remove();
    end
end
DaggerWarning:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, DaggerWarning.Variant);

return DaggerWarning;