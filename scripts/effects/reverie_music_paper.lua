local Paper = ModEntity("Reverie Music Paper", "REVERIE_MUSIC_PAPER");

local function PostEffectInit(mod, effect)
    effect.TargetPosition = effect.Position;
    effect:GetSprite():Play("Idle");
end
Paper:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Paper.Variant);


local function PostEffectUpdate(mod, effect)
    effect.Velocity = (effect.TargetPosition - effect.Position) * 0.1;
    if (effect.Position:Distance(effect.TargetPosition) < 2) then

        local musicBox = THI.Pickups.ReverieMusicBox;
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(effect.TargetPosition);
        Isaac.Spawn(musicBox.Type, musicBox.Variant, musicBox.SubType, pos, Vector.Zero, effect.SpawnerEntity);

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, effect);

        SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND);

        local item = THI.Collectibles.ReverieMusic;
        local player = effect.Parent and effect.Parent:ToPlayer();
        if (player) then
            player:RemoveCollectible(item.Item, true);
        end

        effect:Remove();
    end
end
Paper:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Paper.Variant);

return Paper;