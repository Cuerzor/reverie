local Collectibles = CuerLib.Collectibles;
local Detection = CuerLib.Detection;
local Envy = ModItem("Green Eyed Envy", "EnvyCurse");

local CompareEntity = Detection.CompareEntity;
local divideNPCs = {};

function Envy:PostNewRoom()
    divideNPCs = {};
    if (Collectibles.IsAnyHasCollectible(Envy.Item, false)) then
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if (not Detection.IsFinalBoss(ent) and ent:IsActiveEnemy(false)
            -- and ent.Type ~= EntityType.ENTITY_MOVABLE_TNT
            -- and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) 
            and ent.Type ~= THI.GensouDream.Doremy.Type
        ) then
                ent.HitPoints = ent.HitPoints * 0.4;
                table.insert( divideNPCs, ent);
            end
        end
    end
end
Envy:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Envy.PostNewRoom);

function Envy:PostNPCDeath(npc)
    local canDivide = false;
    for i, ent in pairs(divideNPCs) do
        if (CompareEntity(ent, npc)) then
            canDivide = true;
            table.remove(divideNPCs, i);
            break;
        end
    end

    if (canDivide) then
        for i = 1, 2 do
            local pos =  npc.Position + Vector((i*2-3) * 10, 0);
            local new = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, pos, Vector.Zero, npc.SpawnerEntity):ToNPC();
            new.HitPoints = new.HitPoints * 0.2;
            new.Scale = new.Scale * 0.5;
        end
    end
end
Envy:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Envy.PostNPCDeath);

return Envy;