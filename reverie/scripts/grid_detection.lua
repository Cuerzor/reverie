local Mod = THI;
local GridDetection = {};

GridDetection.Rocks = {
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_ALT2,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
    GridEntityType.GRID_ROCKT
}
GridDetection.RockTearVariantMask = (1 << 16) - 1;

function GridDetection:IsRock(type)
    for _, t in ipairs(self.Rocks) do
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
                self.Variant = tear.SubType & GridDetection.RockTearVariantMask;
                self.Entity = nil;
                self.State = 0;
                if (GridDetection:IsRock(self.Type)) then
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
    function GridDetection:NewGridData()
        local data = {};
        setmetatable(data, gridDataMeta);
        return data;
    end

    local function GetData(create)
        local data = Mod:GetGlobalData(true);
        if (create and not data.GRID_DETECTION) then
            data.GRID_DETECTION = {
                GridDatas = {},
                Buffer = nil
            }
        end
        return data.GRID_DETECTION;
    end
    function GridDetection:GetBufferGridData()
        local data = GetData(true);
        if (not data.Buffer) then
            data.Buffer = self:NewGridData();
        end
        return data.Buffer;
    end
    function GridDetection:GetGridData(index)
        local data = GetData(true);
        local gridData = data.GridDatas[index];
        if (not gridData) then
            gridData = self:NewGridData();
            data.GridDatas[index] = gridData;
        end
        return gridData;
    end
    
    function GridDetection:ResetGridDatas()
        local data = GetData(true);
        for i, grid in ipairs(data.GridDatas) do
            grid:Reset();
        end
        self:GetBufferGridData():Reset();
    end
end


local GridCallbacks = {
    GRID_UPDATE = 1,
    GRID_DESTROYED = 2
}
do -- Callbacks
    GridDetection.Callbacks = {};
    local sorter = function(a, b)
        return a.Priority > b.Priority;
    end
    function GridDetection:AddCallback(callback, func, optionalArg, priority)
        priority = priority or 0;
        local info = {Func = func, OptArg = optionalArg, Priority = priority};
        if (not self.Callbacks[callback]) then
            self.Callbacks[callback] = {};
        end
        local funcs = self.Callbacks[callback];
        table.insert(funcs, info)
        table.sort(funcs, sorter)
    end
    function GridDetection:RemoveCallback(callback, func)
        local funcs = self.Callbacks[callback];
        if (funcs) then
            for i, info in pairs(funcs) do
                if (info.Func == func) then
                    table.remove(funcs, i)
                end
            end
        end
    end
    
    function GridDetection:CallUpdateCallbacks(index, prevData, newData)
        local callbacks = self.Callbacks[GridCallbacks.GRID_UPDATE];
        if (callbacks) then
            for _, info in pairs(callbacks) do
                local optArg = info.OptArg;
                if (not optArg or optArg < 0 or optArg == index) then
                    info.Func(index, prevData, newData);
                end
            end
        end
    end
    function GridDetection:CallDestroyCallbacks(data)
        local callbacks = self.Callbacks[GridCallbacks.GRID_DESTROYED];
        if (callbacks) then
            for _, info in pairs(callbacks) do
                local optArg = info.OptArg;
                if (not optArg or optArg < 0 or optArg == data.Type) then
                    info.Func(data);
                end
            end
        end
    end
end

function GridDetection:UpdateGrid(index , prevData, gridData)
    local prevType = prevData.Type;
    
    if (self:IsRock(prevType)) then
        if (prevData.State == 1) then
            local newType = gridData.Type;
            local newRock = self:IsRock(newType);
            if ((newRock and gridData.State ~= 1) or newType == GridEntityType.GRID_STAIRS) then
                GridDetection:CallDestroyCallbacks(prevData);
            end
        end
    end
end

function GridDetection:PostUpdate()
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
            local gridData = GridDetection:GetBufferGridData();
            local prevData = GridDetection:GetGridData(index);
            gridData:Wrap(gridEntity);
            GridDetection:UpdateGrid(index, prevData, gridData);
            GridDetection:CallUpdateCallbacks(index, prevData, gridData);
            prevData:Wrap(gridEntity);
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, GridDetection.PostUpdate)


function GridDetection:PostNewRoom()
    GridDetection:ResetGridDatas();
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GridDetection.PostNewRoom)


function GridDetection:PostTearUpdate(tear)
    if (tear:IsDead()) then
        local gridData = GridDetection:GetBufferGridData();
        gridData:WrapTear(tear);
        GridDetection:CallDestroyCallbacks(gridData);
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, GridDetection.PostTearUpdate, TearVariant.GRIDENT)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, GridDetection.PostTearUpdate, ProjectileVariant.PROJECTILE_GRID)


function Mod:OnGridUpdate(func, optionalArg, priority)
    GridDetection:AddCallback(GridCallbacks.GRID_UPDATE, func, optionalArg, priority)
end
function Mod:OnGridDestroyed(func, optionalArg, priority)
    GridDetection:AddCallback(GridCallbacks.GRID_DESTROYED, func, optionalArg, priority)
end
function Mod:IsGridTypeRock(type)
    return GridDetection:IsRock(type);
end

return GridDetection;