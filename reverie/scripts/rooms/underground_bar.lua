local Bar = {};
Bar.Type = RoomType.ROOM_DUNGEON;
Bar.ID = 5810
function Bar:IsBar(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == self.Type and roomDesc.Data.Variant == self.ID;
    end
    return false;
end

function Bar:PostEntityRemove(entity)
    local DoorKeeper = THI.Slots.DoorKeeper;
    if (entity.Type == DoorKeeper.Type and entity.Variant == DoorKeeper.Variant) then
        local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
        if (Bar:IsBar(roomDesc)) then
            local room = Game():GetRoom();
            local index = 208;
            local grid = room:GetGridEntity(index);
            if (grid) then
                room:RemoveGridEntity(index, 0, false);
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Bar.PostEntityRemove)


local function GridUpdate(mod, index, prevGrid, newGrid)
    if (prevGrid.Type == GridEntityType.GRID_WALL and prevGrid.Variant == 0 and
    (newGrid.Type == 0 and newGrid.Variant == 0)) then
        local game = Game();
        local roomDesc = game:GetLevel():GetCurrentRoomDesc();
        if (Bar:IsBar(roomDesc)) then
            local room = game:GetRoom();
            room:SpawnGridEntity(index, GridEntityType.GRID_GRAVITY, 0, math.max(1, Random()), 0);
            SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE);
            game:SpawnParticles (room:GetGridPosition(index), EffectVariant.ROCK_PARTICLE, 3, 5, Color.Default);
        end
    end
end
THI:AddCallback(CuerLib.Callbacks.CLC_POST_GRID_UPDATE, GridUpdate, 208);

return Bar;