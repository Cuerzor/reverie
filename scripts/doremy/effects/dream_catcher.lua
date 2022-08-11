local Dream = GensouDream;
local DreamCatcher = {
    Type = Isaac.GetEntityTypeByName("Doremy Dream Catcher"),
    Variant = Isaac.GetEntityVariantByName("Doremy Dream Catcher"),
    SubType = 0
}

function DreamCatcher:TurnRed(entity)
    local effect = entity:ToEffect();
    if (effect) then
        
        local spr = effect:GetSprite();
        spr:Play("Disappear");
    end
end

local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    effect.DepthOffset = 50-effect.Position.Y 
    if (spr:IsPlaying("Appear")) then
        SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.5);
    end
    if (spr:IsFinished("Appear")) then
        spr:Play("Shine");
        local Choice = Dream.Effects.NightmareChoice;
        local count = #Dream.SpellCards;
        SFXManager():Play(THI.Sounds.SOUND_TOUHOU_BOON, 1);
        for i = 1, count do
            if (not Dream:IsSpellCardCleared(i)) then
                local angle = i / count * 360 - 90;
                local pos = effect.Position + Vector.FromAngle(angle) * 120;
                local choice = Isaac.Spawn(Choice.Type, Choice.Variant, i, pos, Vector.Zero, effect):ToEffect();
                choice.State = 1;
                choice.SpriteOffset = Vector(0, -240);
                choice.Rotation = angle;
                choice.Parent = effect;
            end
        end
    end
    if (spr:IsFinished("Disappear")) then
        effect:Remove();
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, DreamCatcher.Variant);


return DreamCatcher;