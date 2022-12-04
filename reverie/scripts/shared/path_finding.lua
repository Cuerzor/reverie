local PathFinding = {};

local gridSize = 40;

local function GetGridEsicost(index, targetIndex)
    -- local room = Game():GetRoom();
    -- return (room:GetGridPosition(targetIndex) - room:GetGridPosition(index)):Length() / gridSize;
    local room = Game():GetRoom();
    local width = room:GetGridWidth();
    local x = index % width;
    local y = math.floor(index / width);
    local targetX = targetIndex % width;
    local targetY = math.floor(targetIndex / width);

    return math.abs(targetX - x) + math.abs(targetY - y);
end
local function GetAdjacent(index, dir)
    local room = Game():GetRoom();
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    local x = index % width;
    local y = math.floor(index / width);
    if (dir == Direction.UP) then
        y = y - 1;
    elseif (dir == Direction.DOWN) then
        y = y + 1;
    elseif (dir == Direction.LEFT) then
        x = x - 1;
    elseif (dir == Direction.RIGHT) then
        x = x + 1;
    elseif (dir == 4) then
        y = y - 1;
        x = x - 1;
    elseif (dir == 5) then
        y = y - 1;
        x = x + 1;
    elseif (dir == 6) then
        y = y + 1;
        x = x - 1;
    elseif (dir == 7) then
        y = y + 1;
        x = x + 1;
    end
    if (x >= 0 and x < width and y >= 0 and y < height) then
        return x + y * width;
    end
    return -1;
end

function PathFinding:CanPass(index)
    local room = Game():GetRoom();
    local gridEnt = room:GetGridEntity(index);
    if (not gridEnt or gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
        return true, 1;
    end
    return room:GetGridPath(index) < 900, 1;
end
local function CanPass(index)
    return PathFinding:CanPass(index);
end

local defaultParams = {
    PassCheck = CanPass,
    MaxStartCost = -1,
    MaxCost = -1,
}

function PathFinding:FindPath(entityIndex, targetIndex, params)

    params = params or defaultParams;
    
    ---@class GridPathInfo
    ---@field Index integer @Grid's index.
    ---@field GCost integer @Grid's G Cost.
    ---@field FCost integer @Grid's F Cost. F = G + H.
    ---@field Parent integer @Grid's index.

    local passFunction = params.PassCheck or CanPass;
    local maxStartCost = params.MaxStartCost or -1;
    local maxCost = params.MaxCost or -1;

    -- Pathfinding Failed, if target location cannot be passed.
    if (targetIndex < 0 or not passFunction(targetIndex)) then
        return nil;
    end

    -- Initalization.
    local openGrids = {};
    local openCount = 0;
    local closedGrids = {};
    local room = Game():GetRoom();
    local width = room:GetGridWidth();

    -- Functions.

    --- Get the grid index which has the lowest grid cost.
    --- @return integer index
    local function GetLowestCostGrid()
        local gridInfo = nil;
        local index = -1;
        for idx, grid in pairs(openGrids) do
            if (not gridInfo or grid.FCost < gridInfo.FCost) then
                gridInfo = grid;
                index = idx;
            end
        end
        return index;
    end

    --- Check if a grid is open.
    --- @param gridIndex integer
    --- @return boolean open
    --- @return GridPathInfo gridInfo
    local function IsGridOpen(gridIndex)
        -- for idx, i in pairs(openGrids) do
        --     if (i.Index == gridIndex) then
        --         return true, i;
        --     end
        -- end
        local info = openGrids[gridIndex];
        if (info) then
            return true, info;
        end
        return false;
    end

    --- Check if a grid is Closed.
    --- @param gridIndex integer
    --- @return boolean closed
    local function IsGridClosed(gridIndex)
        -- for _, i in pairs(closedGrids) do
        --     if (i == gridIndex) then
        --         return true;
        --     end
        -- end
        return closedGrids[gridIndex] ~= nil;
    end

    -- Add current grid to open list.
    openGrids[entityIndex] =
    { 
        Index = entityIndex, 
        GCost = 0, 
        FCost = 0,
        Parent = nil
    };
    openCount = openCount + 1;

    ---@type GridPathInfo @Current grid info
    local curInfo;
    while (openCount > 0) do
        -- Find and get the grid which has the lowest cost grid.
        ---@type integer @Current list index.
        local curIndex = GetLowestCostGrid();

        -- Update current GridPathInfo.
        curInfo = openGrids[curIndex];

        -- Move current GridInfo into close list.
        openGrids[curIndex] = nil;
        openCount = openCount - 1;


        closedGrids[curIndex] = true;
        if (curIndex < 0) then
            return false;
        end

        -- If current grid's index is target index:
        if (curIndex == targetIndex) then
            -- Path has been successfully found.
            local results = {};
            -- Add all grids by the parents to the result list.
            repeat
                table.insert(results, curInfo.Index);
                curInfo = curInfo.Parent;
            until not curInfo
            return results;

        else -- If current grid's index is not target index:

            -- Search from all adjacent grids.
            for i = 0, 3 do 
                local adjacentIndex = GetAdjacent(curIndex, i);
                if (adjacentIndex < 0) then
                    goto continue;
                end

                -- If this adjacent grid can be passed, and is not closed.
                if (not IsGridClosed(adjacentIndex)) then
                    local canPass, cost = passFunction(adjacentIndex);
                    cost = cost or 1;
                    if (canPass) then
                        local newGCost = curInfo.GCost + cost;
                        local newFCost = newGCost + GetGridEsicost(adjacentIndex, targetIndex)
                        if ((maxStartCost < 0 or newGCost <= maxStartCost) and (maxCost < 0 or newFCost <= maxCost)) then
                            local isOpen, gridInfo = IsGridOpen(adjacentIndex);
                            
                            -- if this grid is open.
                            if (isOpen) then
                                -- If current grid's start cost + 1 is less than this grid's start cost
                                -- Then set this grid's start cost to the lower start cost
                                -- And set the grid's parent grid info to current grid info.
                                if (newGCost < gridInfo.GCost) then
                                    gridInfo.FCost = newFCost;--gridInfo.FCost + (newGCost - gridInfo.GCost);
                                    gridInfo.GCost = newGCost;
                                    gridInfo.Parent = curInfo;
                                end
                            else -- if this grid is not open.

                                -- Add this grid to open grids.
                                openGrids[adjacentIndex] = {
                                    Index = adjacentIndex,
                                    GCost = newGCost,
                                    FCost = newFCost,
                                    Parent = curInfo
                                };
                                openCount = openCount + 1;
                            end
                        end
                    end
                end
                ::continue::
            end
        end
    end
end

function PathFinding:FindPathInPos(entityPos, targetPos, params)
    local room = Game():GetRoom();
    return self:FindPath(room:GetGridIndex(entityPos), room:GetGridIndex(targetPos), params);
end

return PathFinding;