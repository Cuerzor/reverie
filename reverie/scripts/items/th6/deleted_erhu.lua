local SaveAndLoad = CuerLib.SaveAndLoad
local EntityTags = THI.Shared.EntityTags;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;

local DeletedErhu = ModItem("DELETED ERHU", "DeletedErhu");


function DeletedErhu.GetErhuData(init)
    return DeletedErhu:GetGlobalData(init, function() return {
        Deleted = {
            Entities = {}, 
            Grids = {}
        }
    }end);
end

function DeletedErhu:GetPlayerData(player, init)
    return DeletedErhu:GetData(player, init, function() return {
        BelialCount = 0
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
    local data = DeletedErhu.GetErhuData(true)
    local list = data.Deleted.Entities;
    local key = tostring(npc.Type).."."..tostring(npc.Variant);
    if (not list[key]) then
        list[key] = true;  
        return true;
    end
    return false;
end

local function RemoveNPC(npc)
    if (npc:Exists()) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector(0, 0), nil);
        npc:Remove();
    end
end

local function DeleteNPCs()
    local deletedCount = 0;
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        local npc = ent:ToNPC();
        if (npc and not EntityTags:EntityFits(ent, "RemoveBlacklist")) then
            if (DeleteNPC(npc)) then
                deletedCount = deletedCount + 1;
            end
            RemoveNPC(npc);
        end
    end
    return deletedCount;
end




function DeletedErhu:onUseErhu(t, rng, player, flags, slot, vardata)
    local room = Game():GetRoom();

    local judasBook = Players.HasJudasBook(player);

    local deletedCount = 0;
    local erhuData = DeletedErhu.GetErhuData(true);
    local deletedData = erhuData.Deleted;
    local gridList = deletedData.Grids;
    for i = 0,room:GetGridSize() - 1 do
        local entity = room:GetGridEntity(i);
        if (entity ~= nil) then
            local type = entity:GetType();
            local key = tostring(type);
            local collision = entity.CollisionClass;
            if (DeletedErhu.CanGridRemove(type, collision))then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, room:GetGridPosition(i), Vector(0, 0), nil);
                room:RemoveGridEntity(i, 0, true);
                if (not gridList[key]) then
                    gridList[key] = true;
                    deletedCount = deletedCount + 1;
                end
            end
        end
    end

    deletedCount = deletedCount + DeleteNPCs();
    if (judasBook) then
        local playerData = DeletedErhu:GetPlayerData(player, true);
        playerData.BelialCount = playerData.BelialCount + deletedCount;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
        player:EvaluateItems();
    end

    return { Discharge = false, Remove = true, ShowAnim = true }
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

function DeletedErhu:EvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local data = DeletedErhu:GetPlayerData(player, false);
        if (data) then
            Stats:AddDamageUp(player, 0.2 * data.BelialCount);
        end
    end
end

function DeletedErhu:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == DeletedErhu.Item) then
        DeleteNPCs();
    end
end

DeletedErhu:AddCallback(ModCallbacks.MC_USE_ITEM, DeletedErhu.onUseErhu, DeletedErhu.Item);
DeletedErhu:AddCallback(ModCallbacks.MC_NPC_UPDATE, DeletedErhu.onNPCUpdate);
DeletedErhu:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DeletedErhu.onNewRoom);
DeletedErhu:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DeletedErhu.EvaluateCache);
DeletedErhu:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, DeletedErhu.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);
return DeletedErhu;