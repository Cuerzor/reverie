local GapFloor = {
    Map = {
        Sprite = "gfx/reverie/grid/gap_map.anm2",
        Animations = {
            [1] = "normal",
            [2] = "narrowH",
            [3] = "narrowV",
            [4] = "longV",
            [5] = "longNarrowV",
            [6] = "longH",
            [7] = "longNarrowH",
            [8] = "big",
            [9] = "longTopLeft",
            [10] = "longTopRight",
            [11] = "longBottomLeft",
            [12] = "longBottomRight"
        },
        Type = 1,
        Variant = 5810
    },
    Effect = {
        Type = Isaac.GetEntityTypeByName("Gap");
        Variant = Isaac.GetEntityVariantByName("Gap");
    },
    TeleportCooldown = 5
}



----- Public Functions -----------

function GapFloor.GetRoomPos(roomIndex)
    return roomIndex % 13, math.floor(roomIndex / 13);
end


function GapFloor.IsGridGap(grid)
    return grid:GetType() == GapFloor.Map.Type and grid:GetVariant() == GapFloor.Map.Variant
end

function GapFloor.RemoveMaps(excluded)
    excluded = excluded or {};
    local room = THI.Game:GetRoom();
    local roomSize = room:GetGridSize();
    for i=0,roomSize - 1 do
        if (excluded[tostring(i)] ~= true) then
            local entity = room:GetGridEntity(i);
            if (entity ~= nil) then
                if (GapFloor.IsGridGap(entity)) then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil);
                    room:RemoveGridEntity(i, 0, false);
                end
            end
        end
    end
end

function GapFloor.UpdateMapSprite(ent)
    local level = THI.Game:GetLevel();
    local currentRoomIndex = level:GetCurrentRoomDesc().SafeGridIndex;
    local desc = level:GetRoomByIdx(ent.State, -1);
    local roomData = desc.Data;

    local sprite = ent:GetSprite();
    sprite:Load(GapFloor.Map.Sprite, true);
    local roomShape = RoomShape.ROOMSHAPE_1x1;
    local roomType = RoomType.ROOM_ERROR;
    if (roomData) then
        roomShape = roomData.Shape;
        roomType = roomData.Type;
        if (ent.State == currentRoomIndex) then
            roomType = 0;
        end
    end
    sprite:SetFrame(GapFloor.Map.Animations[roomShape] or "normal", roomType);
end

function GapFloor.CanSpawnOn(grid)
    local type = grid:GetType();
    if (type == 1 or type == GridEntityType.GRID_SPIDERWEB) then 
        return true;
    elseif (type == GridEntityType.GRID_ROCK or 
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
        if (collisionClass ~= GridCollisionClass.COLLISION_SOLID and 
        collisionClass ~= GridCollisionClass.COLLISION_OBJECT and
        collisionClass ~= GridCollisionClass.COLLISION_PIT) then
            return true;
        end
    end
    
    return false;
end

function GapFloor.SpawnSingleMap(index, roomIndex, roomShape, roomType)
    local room = THI.Game:GetRoom();
    local origin = room:GetGridEntity(index);
    if (origin ~= nil and not GapFloor.CanSpawnOn(origin)) then
        return;
    end 

    if (room:SpawnGridEntity(index, GapFloor.Map.Type, GapFloor.Map.Variant, 0, roomType)) then
        local ent = room:GetGridEntity(index);
        if (ent ~= nil and ent:GetType() == 1) then
            ent.State = roomIndex;
            GapFloor.UpdateMapSprite(ent);
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
        end
    end
end

function GapFloor.IsStandingOnMap(player)
    local level = THI.Game:GetLevel();
    local room = THI.Game:GetRoom();
    local roomWidth = room:GetGridWidth();
    local playerGridIndex = room:GetGridIndex(player.Position);
    local index = playerGridIndex;
    local entity = room:GetGridEntity(index);
    if (entity ~= nil and GapFloor.IsGridGap(entity)) then
        return entity;
    else
        
        local function IsRoomShapeFits(entity, ...)
            if (entity ~= nil and GapFloor.IsGridGap(entity)) then
                local roomData = level:GetRoomByIdx(entity.State).Data;
                local shape = (roomData and roomData.Shape) or RoomShape.ROOMSHAPE_1x1;
                for i, shp in pairs{...} do
                    if (shape == shp) then
                        return true;
                    end
                end
            end
            return false;
        end

        -- Up
        index = playerGridIndex - roomWidth;
        entity = room:GetGridEntity(index);

        -- if Shape is Veritcal long
        if (IsRoomShapeFits(entity, 
        RoomShape.ROOMSHAPE_1x2, 
        RoomShape.ROOMSHAPE_IIV, 
        RoomShape.ROOMSHAPE_2x2, 
        RoomShape.ROOMSHAPE_LTL, 
        RoomShape.ROOMSHAPE_LTR, 
        RoomShape.ROOMSHAPE_LBR)) then
            return entity;
        end
        -- Left
        index = playerGridIndex - 1;
        entity = room:GetGridEntity(index);
        
        -- if Shape is Horizontal long
        if (IsRoomShapeFits(entity, 
        RoomShape.ROOMSHAPE_2x1, 
        RoomShape.ROOMSHAPE_IIH, 
        RoomShape.ROOMSHAPE_2x2, 
        RoomShape.ROOMSHAPE_LBL, 
        RoomShape.ROOMSHAPE_LBR)) then
            return entity;
        end
        -- Left Up
        index = playerGridIndex  - roomWidth - 1;
        entity = room:GetGridEntity(index);
        
        -- if Shape is big
        if (IsRoomShapeFits(entity, 
        RoomShape.ROOMSHAPE_2x2, 
        RoomShape.ROOMSHAPE_LBL, 
        RoomShape.ROOMSHAPE_LTR)) then
            return entity;
        end
        
        -- Right Up
        index = playerGridIndex  - roomWidth + 1;
        entity = room:GetGridEntity(index);
        -- if Shape is LTL
        if (IsRoomShapeFits(entity, 
        RoomShape.ROOMSHAPE_LTL)) then
            return entity;
        end
    end
    return nil;
end

function GapFloor.GetPlayerGapEffectData(player) 
    local data = player:GetData();
    data._GAP_EFFECT_DATA = data._GAP_EFFECT_DATA or {
        effect = nil,
        lastGridIndex = 0
    }

    return data._GAP_EFFECT_DATA;
end

function GapFloor.GenerateMaps(currentGridIndex)
    local room = THI.Game:GetRoom();
    local roomWidth = room:GetGridWidth();
    local roomSize = room:GetGridSize();
    local level = THI.Game:GetLevel();
    local currentRoomIndex = level:GetCurrentRoomDesc().SafeGridIndex;
    if (currentRoomIndex < 0) then
        local lastIndex = level:GetLastRoomDesc ( ).SafeGridIndex;
        if (lastIndex >= 0) then
            currentRoomIndex = lastIndex;
        end
    end

    if (currentRoomIndex < 0) then
        return {ShowAnim = true};
    end

    local curRoomX, curRoomY = GapFloor.GetRoomPos(currentRoomIndex);

    local spawned = {};
    local levelSize = 13*13
    for i=0,levelSize - 1 do
        local descriptor = level:GetRoomByIdx(i)
        if (descriptor.Data ~= nil) then
            local roomIndex = descriptor.SafeGridIndex;
            local roomX, roomY = GapFloor.GetRoomPos(roomIndex);
            local roomType = descriptor.Data.Type;
            
            --if (not (roomType == RoomType.ROOM_ULTRASECRET and descriptor.VisitedCount <= 0)) then
                local roomDiffX = roomX - curRoomX;
                local roomDiffY = roomY - curRoomY;

                local gridIndex = currentGridIndex + roomDiffY * roomWidth;
                if (math.floor(gridIndex / roomWidth) == math.floor((gridIndex + roomDiffX)/roomWidth)) then
                    gridIndex = gridIndex + roomDiffX
                    if (gridIndex > 0 and gridIndex < roomSize) then
                        GapFloor.SpawnSingleMap(gridIndex, roomIndex, descriptor.Data.Shape, roomType);
                        spawned[tostring(gridIndex)] = true;
                    end
                end
            --end
        end
    end

    GapFloor.RemoveMaps(spawned);
    GapFloor.TeleportCooldown = 5
end


function GapFloor:onUpdate()
    if (GapFloor.TeleportCooldown > 0) then
        GapFloor.TeleportCooldown = GapFloor.TeleportCooldown - 1;
    end
end

THI:AddCallback(ModCallbacks.MC_POST_UPDATE, GapFloor.onUpdate)


function GapFloor:onNewRoom()
    local room = THI.Game:GetRoom();
    local roomSize = room:GetGridSize();
    for i=0,roomSize - 1 do
        local entity = room:GetGridEntity(i);
        if (entity ~= nil and GapFloor.IsGridGap(entity)) then
            GapFloor.UpdateMapSprite(entity);
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GapFloor.onNewRoom);

-- Gap Effect --
function GapFloor:onGapEffectUpdate(effect)
    local sprite = effect:GetSprite();
    if (sprite:IsFinished("Open Animation") and not sprite:IsPlaying("Close Animation")) then
        sprite:Play("Opened");
    end
    if (sprite:IsEventTriggered("Vanish")) then
        effect:Remove();
    end
end
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, GapFloor.onGapEffectUpdate, GapFloor.Effect.Variant);

return GapFloor;