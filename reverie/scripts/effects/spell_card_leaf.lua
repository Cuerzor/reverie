local Leaf = ModEntity("Spell Card Leaf", "SPELL_CARD_LEAF");
Leaf.RNG = RNG();

local function PostLeafInit(mod, effect)
    local index = Leaf.RNG:RandomInt(2);
    effect:GetSprite():Play("Idle"..index);
    effect.Timeout = 30;
end
Leaf:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostLeafInit, Leaf.Variant);

local function PostLeafUpdate(mod, effect)
    local spr = effect:GetSprite();
    if (effect.Timeout <= 0) then
        effect:Remove();
    end
end
Leaf:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostLeafUpdate, Leaf.Variant);


return Leaf;