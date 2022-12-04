local Prop = ModEntity("Reverie Prop", "REVERIE_PROP");

Prop.SubTypes = {
    BLACK = 0,
    FLASH = 1
}
local function PostEffectInit(mod, effect)
    if (effect.SubType == Prop.SubTypes.BLACK) then
        effect:GetSprite():Play("Black");
    elseif (effect.SubType == Prop.SubTypes.FLASH) then
        local spr = effect:GetSprite();
        spr:Play("Flash")
    end
end
Prop:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Prop.Variant);


local function PostEffectUpdate(mod, effect)
    if (effect.SubType == Prop.SubTypes.BLACK) then
        effect.DepthOffset = -(effect.Position.Y + effect.Velocity.Y) + 5;
    elseif (effect.SubType == Prop.SubTypes.FLASH) then
        local spr = effect:GetSprite();
        if (spr:IsEventTriggered("Trigger")) then
            local Note = THI.Bosses.ReverieNote;
            for _, ent in ipairs(Isaac.FindByType(Prop.Type, Prop.Variant, Prop.SubTypes.BLACK)) do
                ent:Remove();
            end
            Note:StartBossFight();
        end

        if (spr:IsFinished(spr:GetAnimation())) then
            effect:Remove();
        end
        effect.DepthOffset = 1000;
    end
end
Prop:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Prop.Variant);

return Prop;