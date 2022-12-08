local Players = CuerLib.Players;
local Players = CuerLib.Players;

local Hairpin = ModItem("Warping Hairpin", "WarpHairpin");

local isWarpped = false;
local warpPlayer = nil;
local appearPos = Vector(0, 0);
local warpDir = Direction.NO_DIRECTION;

function Hairpin.GetRoomChunk(pos)
    local chunk = 0;
    if (pos.X > 580) then
        chunk = chunk | 1;
    end
    if (pos.Y > 420) then
        chunk = chunk | 2;
    end
    return chunk;
end

function Hairpin.GetGlobalPosFromRoom(pos, roomIndex)
    local chunk = Hairpin.GetRoomChunk(pos);
    local roomX = roomIndex % 13;
    local roomY = math.floor(roomIndex / 13);
    if (chunk & 1 > 0) then
        pos.X = pos.X - 520;
        roomX = roomX + 1;
    end
    if (chunk & 2 > 0) then
        pos.Y = pos.Y - 280;
        roomY = roomY + 1;
    end
    return pos + Vector(roomX * 520, roomY * 280);
end

function Hairpin.GetRoomPosFromGlobal(pos, roomIndex)
    local roomX = roomIndex % 13;
    local roomY = math.floor(roomIndex / 13);
    local roomPos = pos - Vector(roomX * 520, roomY * 280);

    return roomPos;
end

function Hairpin.GetChunkedRoomIndex(index, chunk)
    -- Get player's standing Chunk.
    if (chunk == 1) then
        index = index + 1;
    elseif (chunk == 2) then
        index = index + 13;
    elseif (chunk == 3) then
        index = index + 14;
    end
    return index;
end

function Hairpin:UseHairpin(item, rng, player, flags, slot, varData)
    local moveDir = player:GetMovementDirection();
    local game = THI.Game;
    if (moveDir ~= Direction.NO_DIRECTION) then
        local room = game:GetRoom();
        local posOffset;
        local roomIndexOffset;
        if (moveDir == Direction.RIGHT) then
            posOffset = Vector(40, 0);
            roomIndexOffset = 1;
        elseif (moveDir == Direction.DOWN) then
            posOffset = Vector(0, 40);
            roomIndexOffset = 13;
        elseif (moveDir == Direction.LEFT) then
            posOffset = Vector(-40, 0);
            roomIndexOffset = -1;
        elseif (moveDir == Direction.UP) then
            posOffset = Vector(0, -40);
            roomIndexOffset = -13;
        end

        local targetGrid = room:GetGridEntityFromPos(player.Position + posOffset);
        if (targetGrid and (targetGrid:GetType() == GridEntityType.GRID_WALL or targetGrid:GetType() == GridEntityType.GRID_DOOR)) then
            local level = game:GetLevel();
            local roomDesc = level:GetCurrentRoomDesc();
            local playerChunk = Hairpin.GetRoomChunk(player.Position);
            local curRoomIndex = Hairpin.GetChunkedRoomIndex(roomDesc.GridIndex, playerChunk);
            local targetRoomIndex = curRoomIndex + roomIndexOffset;

            local targetRoomDesc = level:GetRoomByIdx (targetRoomIndex);
            if (targetRoomDesc.GridIndex >= 0) then
                appearPos = Hairpin.GetGlobalPosFromRoom(player.Position, roomDesc.GridIndex);
                warpDir = moveDir;
                isWarpped = true;
                warpPlayer = player;
                game:StartRoomTransition(targetRoomIndex, -1, RoomTransitionAnim.WALK, player)
                THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL1);

                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
                    player:AddWisp(Hairpin.Item, player.Position);
                end
                return {ShowAnim = true};
            end
        end
    end

    return {ShowAnim = true, Discharge = false};
end
Hairpin:AddCallback(ModCallbacks.MC_USE_ITEM, Hairpin.UseHairpin, Hairpin.Item);



function Hairpin:PostNewRoom()
    if (isWarpped) then
        local game = THI.Game;
        local room = game:GetRoom();
        local level = game:GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        local curRoomIndex = roomDesc.GridIndex;
        local playerPos = Hairpin.GetRoomPosFromGlobal(appearPos, curRoomIndex);

        -- if (warpDir == Direction.RIGHT) then
        --     playerPos.X = -10000;
        -- elseif (warpDir == Direction.DOWN) then
        --     playerPos.Y = -10000;
        -- elseif (warpDir == Direction.LEFT) then
        --     playerPos.X = 10000;
        -- elseif (warpDir == Direction.UP) then
        --     playerPos.Y = 10000;
        -- end
        playerPos = room:GetClampedPosition( playerPos, 0);

        for p, player in Players.PlayerPairs(true, true) do
            player.Position = playerPos;
        end

        if (warpPlayer) then
            if (Players.HasJudasBook(warpPlayer)) then
                local flags = UseFlag.USE_NOANIM;
                warpPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, flags);
            end
        end

        isWarpped = false;
        warpPlayer = nil;
        appearPos = Vector.Zero;
        warpDir = Direction.NO_DIRECTION;
    end

end
Hairpin:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Hairpin.PostNewRoom);

return Hairpin;