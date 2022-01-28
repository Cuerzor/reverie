local CompareEntity = CuerLib.Detection.CompareEntity;
local ViciousCurse = ModItem("Vicious Curse", "DamoclesCurse");

function ViciousCurse:PostGainCurse(player, item, count, touched)
    if (not touched) then
        if (not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE, true)) then
            player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE);
        end
        local game = THI.Game;
        game:ShakeScreen(10);
        THI.SFXManager:Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
        game:SpawnParticles (player.Position, EffectVariant.BLOOD_PARTICLE, 10, 5);
        player:TakeDamage(2 * count, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(nil), 0);
    end
end
ViciousCurse:AddCustomCallback(CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, ViciousCurse.PostGainCurse, ViciousCurse.Item);

function ViciousCurse:PostPlayerEffect(player)
    if (player:HasCollectible(ViciousCurse.Item)) then
        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DAMOCLES)) do
            if (CompareEntity(ent:ToFamiliar().Player, player)) then
                for i = 2, 2 do
                    ent:Update();
                end
            end
        end
    end
end
ViciousCurse:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ViciousCurse.PostPlayerEffect);

return ViciousCurse;