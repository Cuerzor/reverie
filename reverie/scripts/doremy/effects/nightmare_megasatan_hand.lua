local Dream = GensouDream;
local Hand = {
    Type = Isaac.GetEntityTypeByName("Nightmare Megasatan Hand"),
    Variant = Isaac.GetEntityVariantByName("Nightmare Megasatan Hand"),
    SubType = 0
}

function Hand:StartSmash(effect, target)
    if (target == nil) then
        local room = Game():GetRoom();
        local center = room:GetCenterPos();
        target = center;
    end
    effect:ToEffect().State = 1;
    local spr = effect:GetSprite();
    spr:Play("SmashHand1")
    effect.TargetPosition = target;
end

local function PostEffectInit(mod, effect)
    local spr = effect:GetSprite();
    spr:Play("Appear");
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Hand.Variant);

local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    local game = Game();
    local room = game:GetRoom();
    local center = room:GetCenterPos();
    if (effect.State == 1) then
        local target = effect.TargetPosition;
        effect.Velocity = (target - effect.Position) * 0.1
        if (spr:IsEventTriggered("Smash")) then
            game:ShakeScreen(30);
            game:BombDamage(effect.Position, 100, 40, true, effect, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_CRUSH, false);
            SFXManager():Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)

            local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, effect.Position, Vector.Zero, effect):ToEffect();
            wave.Parent = effect;
            wave.Timeout = 30;
        end
        if (spr:IsFinished("SmashHand1")) then
            spr:Play("Idle");
            effect.State = 0;
        end
    else
        local offset = 160;
        if (effect.FlipX) then
            offset = -offset;
        end
        local target = Vector(center.X - offset, 200);
        effect.Velocity = (target - effect.Position) * 0.1
    end
    if (effect.FrameCount % 3 == 0) then
        local trail = Dream.Effects.NightmareTrail;
        trail:SpawnTrail(effect);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Hand.Variant);


return Hand;