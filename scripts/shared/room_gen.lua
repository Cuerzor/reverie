local RoomGen = {
    AdditionalRooms = {}
}

function RoomGen:AddAdditionalRoom(type, variant, index, dimension)
    dimension = dimension or 0;
    self.AdditionalRooms[index] = {Type = type, Variant = variant, Dimension = dimension};
end
function RoomGen:ClearAdditionalRooms()
    local game = Game();
    local level = game:GetLevel();

    for index, roomInfo in pairs(self.AdditionalRooms) do
        local dimension = roomInfo.Dimension;

        local targetRoom = level:GetRoomByIdx(index, dimension); 
        targetRoom.Data = nil; 
        targetRoom.SpawnSeed = 0;
        targetRoom.AwardSeed = 0;
        targetRoom.DecorationSeed = 0;
        targetRoom.GridIndex = -1;
        targetRoom.SafeGridIndex = -1;
        targetRoom.ListIndex = -1;
        targetRoom.DisplayFlags = 0;
        targetRoom.Flags = 0;
        targetRoom.VisitedCount = 0;
    end
end

function RoomGen:GenerateAdditionalRooms()
    local game = Game();
    local level = game:GetLevel();
    local currentRoomIndex = level:GetCurrentRoomIndex();
    local seed = game:GetSeeds():GetStageSeed(level:GetStage());
    local rng = RNG();

    for index, roomInfo in pairs(self.AdditionalRooms) do
        local type = roomInfo.Type;
        local variant = roomInfo.Variant;
        local dimension = roomInfo.Dimension;

        local targetRoom = level:GetRoomByIdx(index, dimension); 
        rng:SetSeed(seed + index * 58123, 1);
        if (type) then
            Isaac.ExecuteCommand("goto s."..type.."."..variant);
        else
            Isaac.ExecuteCommand("goto d."..variant);
        end
        local currentRoom = level:GetRoomByIdx(-3);
        targetRoom.Data = currentRoom.Data; 
        targetRoom.SpawnSeed = rng:Next();
        targetRoom.AwardSeed = rng:Next();
        targetRoom.DecorationSeed = rng:Next();
        targetRoom.GridIndex = index;
        targetRoom.SafeGridIndex = index;
        targetRoom.ListIndex = 506-index;
        print(index, "Generated");
    end
    game:ChangeRoom(currentRoomIndex);
end

local function PostNewLevel(mod)
    RoomGen:GenerateAdditionalRooms();
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

return RoomGen;