local Lib = LIB;
local TEMP_DATA_SUFFIX = "_TEMP";
--- Get an entity's data which is under the registered mod.
---@param entity Entity @Target entity.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetEntityModData(entity, temp)
    local dataName = self.DataName;
    if (not dataName) then
        error("Trying to get data from entity while CuerLib is not inited.");
    end
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
function Lib:SetEntityModData(entity, source, temp)
    local entData = entity:GetData();
    local dataName = self.DataName;
    if (not dataName) then
        error("Trying to set data to entity while CuerLib is not inited.");
    end
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX
    end
    entData[dataName] = source;
end

local GLOBAL_DATA_NAME = "CL_DATA";
--- Get the global data which is under the registered mod.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetGlobalModData(temp)
    if (temp == nil) then
        temp = false;
    end
    
    local mod = self.Mod;
    if (not mod) then
        error("Trying to get global data while CuerLib is not inited.");
    end
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
function Lib:SetGlobalModData(data, temp)
    if (temp == nil) then
        temp = false;
    end
    local mod = self.Mod;
    if (not mod) then
        error("Trying to set global data while CuerLib is not inited.");
    end
    local dataName = GLOBAL_DATA_NAME;
    if (temp) then
        dataName = dataName..TEMP_DATA_SUFFIX;
    end
    mod[dataName] = data;
end

--- Get an entity's data used by this lib which is under the registered mod.
---@param entity Entity @Target entity.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetEntityLibData(entity, temp)
    local modData = self:GetEntityModData(entity, temp);
    modData._CUERLIB = modData._CUERLIB or {};
    return modData._CUERLIB;
end

--- Get the global data data used by this lib which is under the registered mod.
---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
---@return table Data @Returned data.
function Lib:GetGlobalLibData(temp)
    local globalData = self:GetGlobalModData(temp);
    globalData._CUERLIB = globalData._CUERLIB or {};
    return globalData._CUERLIB;
end