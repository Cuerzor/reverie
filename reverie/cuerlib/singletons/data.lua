local Mod = SINGLETON;
local TEMP_DATA_SUFFIX = "_TEMP";
Mod.DataName = "_CUERLIB";
--- Get an entity's data which is under the registered mod.
---@param entity Entity @Target entity.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Mod:GetEntityModData(entity, temp)
    local dataName = self.DataName;
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
function Mod:SetEntityModData(entity, source, temp)
    local entData = entity:GetData();
    local dataName = self.DataName;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX
    end
    entData[dataName] = source;
end

local GLOBAL_DATA_NAME = "CL_DATA";
--- Get the global data which is under the registered mod.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Mod:GetGlobalModData(temp)
    if (temp == nil) then
        temp = false;
    end
    
    local mod = Mod;
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
function Mod:SetGlobalModData(data, temp)
    if (temp == nil) then
        temp = false;
    end
    local mod = Mod;
    local dataName = GLOBAL_DATA_NAME;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX;
    end
    mod[dataName] = data;
end