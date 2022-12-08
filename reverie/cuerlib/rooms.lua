local Rooms = LIB.NewClass();
Rooms.Cells = {
    CELL_TOP_LEFT = 1,
    CELL_TOP_RIGHT = 2,
    CELL_BOTTOM_LEFT = 4,
    CELL_BOTTOM_RIGHT= 8,
}
local ShapeCells = {
    [RoomShape.ROOMSHAPE_1x1] = 1,
    [RoomShape.ROOMSHAPE_IH] = 1,
    [RoomShape.ROOMSHAPE_IV] = 1,
    [RoomShape.ROOMSHAPE_1x2] = 5,
    [RoomShape.ROOMSHAPE_IIV] = 5,
    [RoomShape.ROOMSHAPE_2x1] = 3,
    [RoomShape.ROOMSHAPE_IIH] = 3,
    [RoomShape.ROOMSHAPE_2x2] = 15,
    [RoomShape.ROOMSHAPE_LTL] = 14,
    [RoomShape.ROOMSHAPE_LTR] = 13,
    [RoomShape.ROOMSHAPE_LBL] = 11,
    [RoomShape.ROOMSHAPE_LBR] = 7,

}
local roomWidth = 13;
local roomHeight = 13;
local maxRoomSize = roomWidth * roomHeight;

function Rooms.GetShapeCells(shape)
    return ShapeCells[shape] or 1;
end

function Rooms.GetCellPosOffset(cell)
    local x = 0;
    local y = 0;
    if (cell == Rooms.Cells.CELL_TOP_RIGHT or cell == Rooms.Cells.CELL_BOTTOM_RIGHT) then
        x = 1;
    end
    if (cell == Rooms.Cells.CELL_BOTTOM_LEFT or cell == Rooms.Cells.CELL_BOTTOM_RIGHT) then
        y = 1;
    end
    return x, y;
end

function Rooms.GetRoomPos(index)
    if (index >= 0 and index < maxRoomSize) then
        return index % roomWidth, math.floor(index / roomWidth);
    end
    return -1, -1;
end
function Rooms.IsRoomPosValid(x, y)
    return x >= 0 and x < roomWidth and y >= 0 and y < roomHeight;
end
function Rooms.GetRoomIndex(x, y)
    if (Rooms.IsRoomPosValid(x, y)) then
        return y * roomWidth + x;
    end
    return -1;
end

function Rooms.GetAdjacentIndexes(index, shape)
    
    local results = {}
    local cells = Rooms.GetShapeCells(shape);
    local cellPositions = {};

    local function IsIndexInCells(x, y)
        for _, pos in pairs(cellPositions) do
            if (pos.X == x and pos.Y == y) then
                return true;
            end
        end
        return false;
    end

    local curX, curY = Rooms.GetRoomPos(index);
    
    for i = 0, 3 do
        local cell = cells & (1 << i);
        if (cell > 0) then
            -- Has this cell.
            local x, y = Rooms.GetCellPosOffset(cell);
            table.insert(cellPositions, {X = x, Y = y});
        end
    end

    for _, pos in pairs(cellPositions) do
        -- Loop for each adjacent rooms.
        for dir = 0, 3 do
            local x, y = 1, 0;
            if (dir == 1) then
                x = 0; y = 1;
            elseif (dir == 2) then
                x = -1; y = 0;
            elseif (dir == 3) then
                x = 0; y = -1;
            end
            local adjX, adjY = pos.X + x, pos.Y + y;

            if (not IsIndexInCells(adjX, adjY)) then
                local adjIndex = Rooms.GetRoomIndex(curX + adjX, curY + adjY);
                if (adjIndex > 0) then
                    table.insert(results, adjIndex);
                end
            end
        end
    end
    return results;
end


return Rooms;