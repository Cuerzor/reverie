return function(Addon)
    local Lib = CuerLib;
    local TEMP_DATA_SUFFIX = "_TEMP";
    --- Get an entity's data which is under the registered mod.
    ---@param entity Entity @Target entity.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Addon:GetEntityModData(entity, temp)
        local dataName = Addon.DataName;
        local data = Lib:GetEntityLibData(entity, temp);
        data[dataName] = data[dataName] or {};
        return data[dataName];
    end

    --- Set an entity's data which is under the registered mod.
    ---@param entity Entity @Target entity.
    ---@param source table @Setting data.
    ---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
    function Addon:SetEntityModData(entity, source, temp)
        local dataName = Addon.DataName;
        local data = Lib:GetEntityLibData(entity, temp);
        data[dataName] = source;
    end

    local GLOBAL_DATA_NAME = "CL_DATA";
    --- Get the global data which is under the registered mod.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Addon:GetGlobalModData(temp)
        local data = Lib:GetGlobalLibData(temp);
        local dataName = Addon.DataName;
        data[dataName] = data[dataName] or {};
        return data[dataName];
    end

    --- Set the global data which is under the registered mod.
    ---@param data table @Setting data.
    ---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
    function Addon:SetGlobalModData(source, temp)
        local data = Lib:GetGlobalLibData(temp);
        local dataName = Addon.DataName;
        data[dataName] = source;
    end
end