local SaveAndLoad = CuerLib.SaveAndLoad
local Callbacks = CuerLib.Callbacks;
local EntityTags = THI.Shared.EntityTags;

local DeletedErhu = ModItem("DELETED ERHU", "DeletedErhu");


function DeletedErhu.GetErhuData(init)
    return DeletedErhu:GetGlobalData(init, function() return {
        Deleted = {
            Entities = {}, 
            Grids = {}
        }
    }end);
end

function DeletedErhu.CanGridRemove(type, collisionClass)
    if (type == GridEntityType.GRID_ROCK or 
    type == GridEntityType.GRID_ROCKB or 
    type == GridEntityType.GRID_ROCKT or 
    type == GridEntityType.GRID_ROCK_BOMB or 
    type == GridEntityType.GRID_ROCK_ALT or 
    type == GridEntityType.GRID_LOCK or 
    type == GridEntityType.GRID_TNT or 
    type == GridEntityType.GRID_POOP or 
    type == GridEntityType.GRID_STATUE or
    type == GridEntityType.GRID_ROCK_SS or
    type == GridEntityType.GRID_ROCK_SPIKED or
    type == GridEntityType.GRID_ROCK_ALT2 or
    type == GridEntityType.GRID_ROCK_GOLD) then
        if (collisionClass == GridCollisionClass.COLLISION_SOLID or 
        collisionClass == GridCollisionClass.COLLISION_OBJECT or
        collisionClass == GridCollisionClass.COLLISION_PIT) then
            return true;
        end
    end
    if (type == GridEntityType.GRID_PIT or 
    type == GridEntityType.GRID_SPIKES or 
    type == GridEntityType.GRID_SPIKES_ONOFF or 
    type == GridEntityType.GRID_PILLAR or
    type == GridEntityType.GRID_SPIDERWEB or 
    type == GridEntityType.GRID_GRAVITY) 
    then
        return true;
    end
    return false;
end

function DeletedErhu.IsGridRemoved(type)
    local data = DeletedErhu.GetErhuData();
    return data and data.Deleted.Grids[tostring(type)];
end

function DeletedErhu.IsNPCRemoved(npc)
    local data = DeletedErhu.GetErhuData();
    return data and data.Deleted.Entities[tostring(npc.Type).."."..tostring(npc.Variant)];
end

local function DeleteNPC(npc)
    DeletedErhu.GetErhuData(true).Deleted.Entities[tostring(npc.Type).."."..tostring(npc.Variant)] = true;
end

local function RemoveNPC(npc)
    if (npc:Exists()) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector(0, 0), nil);
        npc:Remove();
    end
end

local function DeleteNPCs()
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        local npc = ent:ToNPC();
        if (npc and not EntityTags:EntityFits(ent, "RemoveBlacklist")) then
            DeleteNPC(npc);
            RemoveNPC(npc);
        end
    end
end




function DeletedErhu:onUseErhu(t, rng, player, flags, slot, vardata)
    local room = THI.Game:GetRoom();

    for i = 0,room:GetGridSize() - 1 do
        local entity = room:GetGridEntity(i);
        if (entity ~= nil) then
            local type = entity:GetType();
            local variant = entity:GetVariant();
            local collision = entity.CollisionClass;
            if (DeletedErhu.CanGridRemove(type, collision))then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(i), Vector(0, 0), nil);
                room:RemoveGridEntity(i, 0, true);
                DeletedErhu.GetErhuData(true).Deleted.Grids[tostring(type)] = true;
            end
        end
    end

    DeleteNPCs();
    return { Remove = true, ShowAnim = true }
end

function DeletedErhu:onNPCInit(npc)
    if (DeletedErhu.IsNPCRemoved(npc))then
        RemoveNPC(npc);
    end
end
DeletedErhu:AddCallback(ModCallbacks.MC_POST_NPC_INIT, DeletedErhu.onNPCInit);

function DeletedErhu:onNPCUpdate(npc)
    if (DeletedErhu.IsNPCRemoved(npc))then
        RemoveNPC(npc);
    end
end

local function CheckRoom()
    local room = THI.Game:GetRoom();
    local size = room:GetGridSize();
    for i = 0,size - 1 do
        local entity = room:GetGridEntity(i);
        if (entity) then
            local type = entity:GetType();
            if (DeletedErhu.IsGridRemoved(type))then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(i), Vector(0, 0), nil);
                room:RemoveGridEntity(i, 0, false);
            end
        end
    end
end

function DeletedErhu:onNewRoom()
    CheckRoom();
end


function DeletedErhu:PostGameStarted(isContinued)
    CheckRoom();
end
DeletedErhu:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DeletedErhu.PostGameStarted);


function DeletedErhu:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == DeletedErhu.Item) then
        DeleteNPCs();
    end
end

DeletedErhu:AddCallback(ModCallbacks.MC_USE_ITEM, DeletedErhu.onUseErhu, DeletedErhu.Item);
DeletedErhu:AddCallback(ModCallbacks.MC_NPC_UPDATE, DeletedErhu.onNPCUpdate);
DeletedErhu:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DeletedErhu.onNewRoom);
DeletedErhu:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, DeletedErhu.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);
return DeletedErhu;