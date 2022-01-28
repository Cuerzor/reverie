local Callbacks = CuerLib.Callbacks;

local Stages = {
    
}

local stageMetatable = {
    __eq = function(tbl, level) 
        return tbl.Stage == level.Stage and tbl.Type == level.Type 
    end
}
function Stages.Stage(stage, type)
    local value = { 
        Stage = stage, 
        Type = type
    };
    setmetatable(value, stageMetatable);
    return value;
end

Stages.Default = Stages.Stage(0, 0)
local StageCache = Stages.Default;
local IsNewStage = false;

function Stages.GetCurrentStage()
    local level = THI.Game:GetLevel();;
    local stage = level:GetStage();
    local stageType = level:GetStageType();
    if (stage ~= StageCache.Stage or stageType ~= StageCache.Type ) then
        StageCache = Stages.Stage(stage, stageType)
    end
    return StageCache;
end

function Stages:onUpdate()
    if (IsNewStage) then
        IsNewStage = false;
        for i, func in pairs(Callbacks.Functions.NewStage) do
            func.Func(func.Mod);
        end
    end
end

function Stages:onNewLevel()
    IsNewStage = true;
end

function Stages.GetDimension(roomDesc) -- By DeadInfinity.
    local level = THI.Game:GetLevel()
    local desc = roomDesc or level:GetCurrentRoomDesc()

    local hash = GetPtrHash(desc)
    for dimension = 0, 2 do
        local dimensionDesc = level:GetRoomByIdx(desc.SafeGridIndex, dimension)
        if GetPtrHash(dimensionDesc) == hash then
            return dimension
        end
    end
end

function Stages.IsInDimension(num)
    return Stages.GetDimension() == num
end

function Stages.IsInMinesEscape()
    local level = THI.Game:GetLevel()
    local stageType = level:GetStageType();
    if (level:GetStage() == LevelStage.STAGE2_2 and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B)) then
        return Stages.GetDimension() == 1
    end
    return false;
end


function Stages:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Stages.onUpdate);
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Stages.onNewLevel);
end


function Stages:Unregister(mod)
    mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, Stages.onUpdate);
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, Stages.onNewLevel);
end

return Stages;