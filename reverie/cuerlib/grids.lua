local Lib = LIB;
local Math = Lib.Math;
local Grids = Lib:NewClass();

Grids.RoomGrids = {
    Block = {Type = GridEntityType.GRID_ROCKB, Variant = 0},
    Rock = {Type = GridEntityType.GRID_ROCK, Variant = 0},
    TallBlock = {Type = GridEntityType.GRID_PILLAR, Variant = 0},
    FoolsGold = {Type = GridEntityType.GRID_ROCK_GOLD, Variant = 0},
    Null = {Type = GridEntityType.GRID_NULL, Variant = 0},
    Pits = {Type = GridEntityType.GRID_PIT, Variant = 0},
    Spiderweb = {Type = GridEntityType.GRID_SPIDERWEB, Variant = 0},
};
function Grids:PushToBridge(center, gridIndex)
    local room = THI.Game:GetRoom();
    local pos = center;
    local index = gridIndex;

    -- Make Bridge.
    local gridEntity = room:GetGridEntity(index);
    if (gridEntity and (gridEntity:ToRock() or gridEntity:ToPoop())) then
        local width = room:GetGridWidth();
        local size = room:GetGridSize();
        local gridPos = gridEntity.Position;

        local angle = (gridPos - center):GetAngleDegrees();
        local direction = Math.GetDirectionByAngle(angle);

        local pit;
        if (direction == Direction.RIGHT) then
            if (index % width ~= 0) then
                local right = room:GetGridEntity(index + 1);
                if (right and right:ToPit()) then
                    pit = right;
                end
            end
        elseif (direction == Direction.DOWN) then
            local downIndex = index + width;
            if (downIndex >= 0 and downIndex <= size) then
                local down = room:GetGridEntity(downIndex);
                if (down and down:ToPit()) then
                    pit = down;
                end
            end
        elseif (direction == Direction.LEFT) then
            if ((index - 1) % 15 ~= 0) then
                local left = room:GetGridEntity(index - 1);
                if (left and left:ToPit()) then
                    pit = left;
                end
            end
        elseif (direction == Direction.UP) then
            local upIndex = index - width;
            if (upIndex >= 0 and upIndex <= size) then
                local up = room:GetGridEntity(upIndex);
                if (up and up:ToPit()) then
                    pit = up;
                end
            end
        end
        room:TryMakeBridge (pit, gridEntity)
    end
end

return Grids;