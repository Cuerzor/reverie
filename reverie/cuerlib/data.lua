local Lib = CuerLib;
local TEMP_DATA_SUFFIX = "_TEMP";
Lib.DataName = "_CUERLIB";
--- Get an entity's data which is under the registered mod.
---@param entity Entity @Target entity.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetEntityLibData(entity, temp)
    local dataName = Lib.DataName;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX
    end
    local data = entity:GetData();
    data[dataName] = data[dataName] or {};
    return data[dataName];
end

--- Set an entity's data which is under the registered mod.
---@param entity Entity @Target entity.
---@param source table @Setting data.
---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
function Lib:SetEntityLibData(entity, source, temp)
    local entData = entity:GetData();
    local dataName = Lib.DataName;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX
    end
    entData[dataName] = source;
end

local GLOBAL_DATA_NAME = "CL_DATA";
--- Get the global data which is under the registered mod.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetGlobalLibData(temp)
    if (temp == nil) then
        temp = false;
    end
    
    local mod = Lib;
    local dataName = GLOBAL_DATA_NAME;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX;
    end
    mod[dataName] = mod[dataName] or {};
    return mod[dataName];
end

--- Set the global data which is under the registered mod.
---@param data table @Setting data.
---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
function Lib:SetGlobalLibData(data, temp)
    if (temp == nil) then
        temp = false;
    end
    local mod = Lib;
    local dataName = GLOBAL_DATA_NAME;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX;
    end
    mod[dataName] = data;
end