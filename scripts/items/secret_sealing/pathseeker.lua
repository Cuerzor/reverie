local SaveAndLoad = CuerLib.SaveAndLoad;
local Collectibles = CuerLib.Collectibles;
local Callbacks = CuerLib.Callbacks;

local GapFloor = THI.GapFloor;

local Pathseeker = ModItem("Pathseeker", "Pathseeker");

---------------------------------
-- Events
---------------------------------

function Pathseeker:onNewStage()
    if (Collectibles.IsAnyHasCollectible(Pathseeker.Item)) then
    
        local levelLength = 13;
        local roomSize = levelLength * levelLength;
        
        local room = THI.Game:GetRoom();
        local level = THI.Game:GetLevel();
        
        local currentGridIndex = room:GetGridIndex(room:GetCenterPos());

        local currentRoomIndex = level:GetCurrentRoomDesc().SafeGridIndex;
        
        local minX = levelLength;
        local maxX = -levelLength;
        
        local minY = levelLength;
        local maxY = -levelLength;

        local curRoomX, curRoomY = GapFloor.GetRoomPos(currentRoomIndex);

        for i=0,roomSize - 1 do
            local descriptor = level:GetRoomByIdx(i)
            if (descriptor.Data ~= nil) then
                local roomIndex = descriptor.SafeGridIndex;
                local roomX, roomY = GapFloor.GetRoomPos(roomIndex);
                local roomType = descriptor.Data.Type;
                
                --if (not (roomType == RoomType.ROOM_ULTRASECRET and descriptor.VisitedCount <= 0)) then
                    local roomDiffX = roomX - curRoomX;
                    local roomDiffY = roomY - curRoomY;
                    minX = math.min(roomDiffX, minX);
                    maxX = math.max(roomDiffX, maxX);
                    minY = math.min(roomDiffY, minY);
                    maxY = math.max(roomDiffY, maxY);
                --end
            end
        end

        -- Exclude the walls.
        local roomWidth = room:GetGridWidth();
        local xOffset = math.floor((maxX - minX) / 2) + minX;
        local yOffset = math.floor((maxY - minY) / 2) + minY;
        local index = currentGridIndex - xOffset - roomWidth * yOffset;
        GapFloor.GenerateMaps(index);
    end
end
Pathseeker:AddCustomCallback(CLCallbacks.CLC_NEW_STAGE, Pathseeker.onNewStage);

return Pathseeker;