local Collectibles = CuerLib.Collectibles;
local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local Players = CuerLib.Players;
local Envy = ModItem("Green Eyed Envy", "EnvyCurse");

Envy.Blacklist = {
    {Type = EntityType.ENTITY_GIDEON },
    {Type = EntityType.ENTITY_LARRYJR, Variant = 2 },
    {Type = EntityType.ENTITY_LARRYJR, Variant = 3 }
}

local divideNPCs = {};

local function IsBlacklisted(ent)
    for i, info in pairs(Envy.Blacklist) do
        if (info.Type and ent.Type == info.Type) then
            if (not info.Variant or ent.Variant == info.Variant) then
                if (not info.SubType or ent.SubType == info.SubType) then
                    return true;
                end
            end
        end
    end
    return false;
end

function Envy:PostNewRoom()
    divideNPCs = {};
    if (Collectibles.IsAnyHasCollectible(Envy.Item, false)) then
        for i, ent in pairs(Isaac.GetRoomEntities()) do

            if (not Detection.IsFinalBoss(ent) and ent:IsActiveEnemy() 
            and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) 
            and not IsBlacklisted(ent)
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
        local Seija = THI.Players.Seija;
        local seijaPlayer;
        for p, player in Players.PlayerPairs() do
            if (not seijaPlayer and Seija:WillPlayerBuff(player)) then
                seijaPlayer = player;
            end
        end
        for i = 1, 2 do
            local pos =  npc.Position + Vector((i*2-3) * 10, 0);
            local new = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, pos, Vector.Zero, npc.SpawnerEntity):ToNPC();
            if (seijaPlayer) then
                new:AddCharmed(EntityRef(seijaPlayer), 9000);
            end
            new.HitPoints = new.HitPoints * 0.2;
            new.Scale = new.Scale * 0.5;
        end
    end
end
Envy:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Envy.PostNPCDeath);

return Envy;