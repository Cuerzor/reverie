local Fix = {}

Fix.ModGotoRooms = {}

function Fix:AddModGotoRoom(type, variant)
    table.insert(Fix.ModGotoRooms, {Type = type, Variant = variant});
end

local function GetGlobalData(create)
    if (create) then
        THI.Data._SOFTLOCK_FIX = THI.Data._SOFTLOCK_FIX or {
            LastRoomIndex = nil;
        }
    end
    return THI.Data._SOFTLOCK_FIX
end

local function IsModGotoRoom(type, variant)
    for _, roomInfo in ipairs(Fix.ModGotoRooms) do
        if (type == roomInfo.Type and variant == roomInfo.Variant) then
            return true;
        end
    end
    return false;
end

local function PostNewRoom(mod)
    local game = Game();
    local room = game:GetRoom();
    local level = game:GetLevel();

    local data = GetGlobalData(true);
    local roomIndex = level:GetCurrentRoomIndex();
    if (roomIndex > 0) then
        data.LastRoomIndex = roomIndex;
    end
    -- Set door indexs.
    if (data and data.LastRoomIndex) then
        local doorIndex = data.LastRoomIndex;
        local doorType = RoomType.ROOM_NULL;
        local targetDesc = level:GetRoomByIdx(doorIndex);
        if (targetDesc and targetDesc.Data) then
            doorType = targetDesc.Data.Type;
        end

        for slot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = room:GetDoor(slot);
            if (door and door.TargetRoomIndex == -3) then
                local doorTarget = level:GetRoomByIdx(door.TargetRoomIndex);

                local isDangerRoom = false;
                if (doorTarget and doorTarget.Data) then
                    isDangerRoom = IsModGotoRoom(doorTarget.Data.Type, doorTarget.Data.Variant);
                else
                    isDangerRoom = true;
                end

                if (isDangerRoom) then
                    door.TargetRoomIndex = doorIndex;
                    door.TargetRoomType = doorType;
                end
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

local function PostNewLevel(mod)
    local data = GetGlobalData(false);
    if (data) then
        data.LastRoomIndex = nil;
    end
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);


-- local function PreGameExit(mod, shouldSave)
--     local game = Game();
--     local level = game:GetLevel();
--     local roomDesc = level:GetCurrentRoomDesc();

--     if (roomDesc and roomDesc.Data) then
--         local roomData = roomDesc.Data
--         if (IsModGotoRoom(roomData.Type, roomData.Variant)) then
--             local returnIndex = level:GetStartingRoomIndex();
--             local data = GetGlobalData(false);
--             if (data) then
--                 returnIndex = data.LastRoomIndex;
--             end
--             level:ChangeRoom(returnIndex);
--             game:ChangeRoom(returnIndex);
--         end
--     end
-- end
-- THI:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreGameExit);

return Fix;
