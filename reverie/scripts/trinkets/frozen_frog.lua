local Detection = CuerLib.Detection;

local FrozenFrog = ModTrinket("Frozen Frog", "FrozenFrog");

function FrozenFrog:preNPCCollision(npc, collider)
    local player = collider:ToPlayer();
    if (player ~= nil) then
        if (player:HasTrinket(FrozenFrog.Trinket, false)) then
            if (Detection.IsValidEnemy(npc) and not npc:IsBoss()) then
                npc:AddEntityFlags(EntityFlag.FLAG_ICE);
                npc.HitPoints = -10;
                npc:TakeDamage(1, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
            end
        end
    end
end

FrozenFrog:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, FrozenFrog.preNPCCollision);
return FrozenFrog;