local Lib = LIB;
local Math = Lib.Math;
local Grids = Lib:NewClass();

Grids.Rocks = {
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_ALT2,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
    GridEntityType.GRID_ROCKT
}
Grids.RoomGrids = {
    Block = {Type = GridEntityType.GRID_ROCKB, Variant = 0},
    Rock = {Type = GridEntityType.GRID_ROCK, Variant = 0},
    TallBlock = {Type = GridEntityType.GRID_PILLAR, Variant = 0},
    FoolsGold = {Type = GridEntityType.GRID_ROCK_GOLD, Variant = 0},
    Null = {Type = GridEntityType.GRID_NULL, Variant = 0},
    Pits = {Type = GridEntityType.GRID_PIT, Variant = 0},
    Spiderweb = {Type = GridEntityType.GRID_SPIDERWEB, Variant = 0},
};
Grids.RockTearVariantMask = (1 << 16) - 1;

function Grids:IsRock(type)
    for _, t in ipairs(Grids.Rocks) do
        if (type == t) then
            return true;
        end
    end
    return false;
end

do -- GridData.
    local gridDataMeta = {
        Type = 0,
        Variant = 0,
        Entity = nil,
        State = 0,
        CollisionClass = 0,
        VarData = 0,
        Position = Vector.Zero,
        Seed = 1,
        Clone = function(self)
            local new = {};
            for k, v in pairs(self) do
                new[k] = v;
            end
            return new;
        end,
        Reset = function(self)
            for k, v in pairs(self) do
                self[k] = nil;
            end
        end,
        Wrap = function(self, gridEntity)
            if (gridEntity) then
                self.Type = gridEntity:GetType();
                self.Variant = gridEntity:GetVariant();
                self.Entity = gridEntity;
                self.State = gridEntity.State;
                self.CollisionClass = gridEntity.CollisionClass;
                self.VarData = gridEntity.VarData;
                self.Position = gridEntity.Position;
                self.Seed = gridEntity:GetSaveState().SpawnSeed;
            else
                self:Reset()
            end
        end,
        WrapTear = function(self, tear)
            if (tear) then
                self.Type = tear.SubType >> 16;
                self.Variant = tear.SubType & Grids.RockTearVariantMask;
                self.Entity = nil;
                self.State = 0;
                if (Grids:IsRock(self.Type)) then
                    self.State = 1;
                end
                self.CollisionClass = 0;
                self.VarData = 0;
                self.Position = tear.Position;
                self.Seed = tear.InitSeed;
            else
                self:Reset()
            end
        end
    }
    gridDataMeta.__index = gridDataMeta;
    function Grids:NewGridData()
        local data = {};
        setmetatable(data, gridDataMeta);
        return data;
    end

    local function GetData(create)
        local data = Lib:GetGlobalLibData(true);
        if (create and not data.GRID_DETECTION) then
            data.GRID_DETECTION = {
                GridDatas = {},
                Buffer = nil
            }
        end
        return data.GRID_DETECTION;
    end
    function Grids:GetBufferGridData()
        local data = GetData(true);
        if (not data.Buffer) then
            data.Buffer = Grids:NewGridData();
        end
        return data.Buffer;
    end
    function Grids:GetGridData(index)
        local data = GetData(true);
        local gridData = data.GridDatas[index];
        if (not gridData) then
            gridData = Grids:NewGridData();
            data.GridDatas[index] = gridData;
        end
        return gridData;
    end
    
    function Grids:ResetGridDatas()
        local data = GetData(true);
        for i, grid in ipairs(data.GridDatas) do
            grid:Reset();
        end
        Grids:GetBufferGridData():Reset();
    end
end

function Grids:UpdateGrid(index , prevData, gridData)
    local prevType = prevData.Type;
    
    if (Grids:IsRock(prevType)) then
        if (prevData.State == 1) then
            local newType = gridData.Type;
            local newRock = Grids:IsRock(newType);
            if ((newRock and gridData.State ~= 1) or newType == GridEntityType.GRID_STAIRS) then
                Isaac.RunCallbackWithParam(Lib.CLCallbacks.CLC_POST_GRID_DESTROYED, prevData.Type, prevData);
            end
        end
    end
end


function Grids:PushToBridge(center, gridIndex)
    local room = Game():GetRoom();
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


-- Events.
function Grids:PostUpdate()
    local game = Game();
    local room = game:GetRoom();
    local level = game:GetLevel();
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    for x = 0, width do
        for y = 0, height do
            local index = x + y * width;
            -- Check Changes.
            local gridEntity = room:GetGridEntity(index);
            local gridData = Grids:GetBufferGridData();
            local prevData = Grids:GetGridData(index);
            gridData:Wrap(gridEntity);
            Grids:UpdateGrid(index, prevData, gridData);
            Isaac.RunCallbackWithParam(Lib.CLCallbacks.CLC_POST_GRID_UPDATE, index, index, prevData, gridData);
            prevData:Wrap(gridEntity);
        end
    end
end
Grids:AddCallback(ModCallbacks.MC_POST_UPDATE, Grids.PostUpdate)


function Grids:PostNewRoom()
    Grids:ResetGridDatas();
end
Grids:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Grids.PostNewRoom)


function Grids:PostTearUpdate(tear)
    if (tear:IsDead()) then
        local gridData = Grids:GetBufferGridData();
        gridData:WrapTear(tear);
        Isaac.RunCallbackWithParam(Lib.CLCallbacks.CLC_POST_GRID_DESTROYED, gridData.Type, gridData);
    end
end
Grids:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Grids.PostTearUpdate, TearVariant.GRIDENT)
Grids:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, Grids.PostTearUpdate, ProjectileVariant.PROJECTILE_GRID)

return Grids;