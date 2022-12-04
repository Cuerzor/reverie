local Mallet = ModEntity("Miracle Mallet Replica", "MIRACLE_MALLET_REPLICA");

Mallet.SubTypeDirections = {
    [0] = "Left",
    [1] = "Up",
    [2] = "Right",
    [3] = "Down",
}
local function PostEffectInit(mod, effect)
    local spr = effect:GetSprite();
    local anim = "Hammer"..(Mallet.SubTypeDirections[effect.SubType] or Mallet.SubTypeDirections[0]);
    spr:Play(anim);
end
Mallet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Mallet.Variant);


local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();

    if (spr:IsEventTriggered("Hammer")) then
        THI.SFXManager:Play(SoundEffect.SOUND_BULLET_SHOT);
        THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
        Game():ShakeScreen(15);
        Game():BombDamage(effect.Position, 80, 40, true, effect.SpawnerEntity, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_IGNORE_ARMOR, false);

        local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, effect.Position, Vector.Zero, effect.SpawnerEntity):ToEffect();
        shockwave.Parent = effect.SpawnerEntity;
        shockwave.Timeout = 10;
        shockwave:SetRadii(20, 40);

        for i, ent in pairs(Isaac.FindInRadius(effect.Position, 80, EntityPartition.PLAYER)) do
            local player = ent:ToPlayer();
            if (player) then
                if (not player.CanFly and player.PositionOffset.Y <= 0) then
                    player.PositionOffset = player.PositionOffset + Vector(0, -16);
                end
            end
        end

    end

    local anim = "Hammer"..(Mallet.SubTypeDirections[effect.SubType] or Mallet.SubTypeDirections[0]);

    if (spr:IsFinished(anim)) then
        effect:Remove();
    end
end
Mallet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Mallet.Variant);

return Mallet;