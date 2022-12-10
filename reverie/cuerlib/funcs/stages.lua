local Lib = LIB;

local Stages = Lib:NewClass();

local IsNewStage = false;

function Stages:onUpdate()
    if (IsNewStage) then
        IsNewStage = false;
        Isaac.RunCallback(Lib.CLCallbacks.CLC_POST_NEW_STAGE);
    end
end
Stages:AddCallback(ModCallbacks.MC_POST_UPDATE, Stages.onUpdate);

function Stages:onNewLevel()
    IsNewStage = true;
end
Stages:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Stages.onNewLevel);

function Stages.GetDimension(roomDesc) -- By DeadInfinity.
    for dimension = 0, 2 do
        if Stages.IsInDimension(dimension) then
            return dimension
        end
    end
    return -1;
end

function Stages.IsInDimension(num)
    local level = Game():GetLevel()
    local desc = roomDesc or level:GetCurrentRoomDesc()

    local hash = GetPtrHash(desc)
    local dimensionDesc = level:GetRoomByIdx(desc.SafeGridIndex, num)
    if GetPtrHash(dimensionDesc) == hash then
        return true
    end
    return false;
end



return Stages;