local Lib = {
    Mod = nil,
    DataName = nil,
    GlobalDataGetter = nil,
    GlobalDataSetter = nil,
    Loaded = {},
    Version = {1,0,0}
}
function Lib.Require(filename)
    if (not Lib.Loaded[filename]) then
        local file = include(filename);
        Lib.Loaded[filename] = file;
        return file;
    end
    return Lib.Loaded[filename];
end
local Require = Lib.Require;

do --Classes
    Lib.ClassPaths = {
        -- Tools
        UTF8 = "cuerlib/classes/utf8",
        Consts = "cuerlib/classes/consts",
        Detection = "cuerlib/detection",
        Inputs = "cuerlib/inputs",
        Math = "cuerlib/math",
        Synergies = "cuerlib/synergies",
        Screen = "cuerlib/screen",
        Stats = "cuerlib/stats",
        Damages = "cuerlib/damages",
        Shields = "cuerlib/shield",
        Greed = "cuerlib/greed",
        Rooms = "cuerlib/rooms",
        Grids = "cuerlib/grids",
        Players = "cuerlib/players",
        
        Familiars = "cuerlib/familiars",
        ModComponents = "cuerlib/mod_components",
        
        Tears = "cuerlib/tears",
        Actives = "cuerlib/actives",
        Pickups = "cuerlib/pickups",
        ItemPools = "cuerlib/item_pools",
        HoldingActive = "cuerlib/holding_active",
        PlayerForms = "cuerlib/player_forms",
        SaveAndLoad = "cuerlib/save_and_load",
        Collectibles = "cuerlib/collectibles",
        Revive = "cuerlib/revive",
        Rewind = "cuerlib/rewind",
        Stages = "cuerlib/stages",
        Weapons = "cuerlib/weapons",
    }
    if (StageAPI) then
        Lib.ClassPaths.Bosses="cuerlib/bosses_stageapi";
    else
        Lib.ClassPaths.Bosses="cuerlib/bosses";
    end
    
    local LibMetatable = {
        __index = function(self, key)
            -- Require the file if target file is not loaded.
            local class = Require(self.ClassPaths[key]);
            if (class) then
                self[key] = class;
                return class;
            end
        end
    }
    setmetatable(Lib, LibMetatable);

    local classMetatable = {
        Lib = Lib
    }
    classMetatable.__index = classMetatable;

    function Lib:NewClass()
        local class = {};
        setmetatable(class, classMetatable);
        class.Callbacks = {};
        class.CustomCallbacks = {};
        function class:AddCallback(callback, func, optionalArg)
            table.insert(self.Callbacks, {Callback = callback, Func = func, OptionalArg = optionalArg});
        end
        function class:AddCustomCallback(callback, func, optionalArg, priority)
            table.insert(self.CustomCallbacks, {Callback = callback, Func = func, OptionalArg = optionalArg, Priority = priority});
        end
        function class:Register(mod)
            for _, callback in pairs(self.Callbacks) do
                mod:AddCallback(callback.Callback, callback.Func, callback.OptionalArg);
            end
            for _, callback in pairs(self.CustomCallbacks) do
                self.Lib.Callbacks:AddCallback(callback.Callback, callback.Func, callback.OptionalArg, callback.Priority);
            end
        end
        function class:Unregister(mod)
            for _, callback in pairs(self.Callbacks) do
                mod:RemoveCallback(callback.Callback, callback.Func);
            end
            for _, callback in pairs(self.CustomCallbacks) do
                self.Lib.Callbacks:RemoveCallback(callback.Callback, callback.Func);
            end
        end
        return class;
    end
end

do -- Data

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
end

function Lib:Init(mod, dataName, getGlobalData, setGlobalData)
    LIB = Lib;
    self.Mod = mod;
    self.DataName = dataName;
    self.GlobalDataGetter = getGlobalData;
    self.GlobalDataSetter = setGlobalData;

    Lib.Callbacks = Require("cuerlib/callbacks");

    for k,v in pairs(self.ClassPaths) do
        local class = Require(v);
        Lib[k] = class;
        if (class.Register) then
            class:Register(mod);
        end
    end
    LIB = nil
end

return Lib;