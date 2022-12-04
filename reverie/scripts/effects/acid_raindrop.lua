local AcidRaindrop = ModEntity("Acid Raindrop", "ACID_RAINDROP");
local ClearColor = Color(1,1,1,0,0,0,0);
local yellowColor = Color(1,1,0,1,0,0,0)
local yellowTransparentColor = Color(1,1,0,0.3,0,0,0)

local function PostEffectInit(mod, effect)
    effect.PositionOffset = effect.Timeout * Vector(0, -2000);
end
AcidRaindrop:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, AcidRaindrop.Variant)
local function PostEffectUpdate(mod, effect)
    effect.Timeout = effect.Timeout - 1;
    effect.PositionOffset = effect.Timeout * Vector(0, -20):Rotated(effect.SpriteRotation);
    if (effect.Timeout < 0) then
        effect:Remove();
        local mishap = Isaac.Spawn(1000,32,0,effect.Position, Vector.Zero, nil):ToEffect();
        mishap:SetColor(yellowTransparentColor, -1, 0);
        mishap:SetColor(ClearColor, 1, 0);
        mishap.Scale = 0.2;
        mishap.Timeout = 60;

        local room = Game():GetRoom();
        room:DestroyGrid (room:GetGridIndex(effect.Position), false);

        local poof = Isaac.Spawn(1000,EffectVariant.TEAR_POOF_A,10,effect.Position, Vector.Zero, nil):ToEffect();
        poof:SetColor(yellowColor, -1, 0);
        SFXManager():Play(SoundEffect.SOUND_SPLATTER, 0.5, 2, false, 1.2);
    end
end
AcidRaindrop:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, AcidRaindrop.Variant)

return AcidRaindrop;