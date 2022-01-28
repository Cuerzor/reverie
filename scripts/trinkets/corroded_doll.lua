local Stats = CuerLib.Stats;
local CorrodedDoll = ModTrinket("Corroded Doll", "CorrodedDoll");

function CorrodedDoll:PostPlayerEffect(player)
    if (player:HasTrinket(CorrodedDoll.Trinket)) then
        local multiplier = player:GetTrinketMultiplier(CorrodedDoll.Trinket);
        if (player.FrameCount % 7 == 0) then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, nil) : ToEffect();
            creep.Timeout = 30;
            creep.CollisionDamage = player.Damage * 0.2 * multiplier;
        end
    end
end
CorrodedDoll:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CorrodedDoll.PostPlayerEffect);

return CorrodedDoll;