---@class CuerLib

---@type CuerLib
local Lib = {
    ModInfo = {
        Mod = nil,
        DataName = nil,
        GlobalDataGetter = nil,
        GlobalDataSetter = nil
    },
    Loaded = {},
    Version = {1,0,0}
}


_TEMP_CUERLIB = Lib;


function Lib.Require(filename)
    if (not Lib.Loaded[filename]) then
        local file = include(filename);
        Lib.Loaded[filename] = file;
        return file;
    end
    return Lib.Loaded[filename];
end

local function Require(filename) 
    return Lib.Require(filename);
end


local Classes = {
    -- Tools
    UTF8 = "cuerlib/utf8",
    Consts = "cuerlib/consts",
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
    
    --Explosion = "cuerlib/explosion",
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
    Classes.Bosses="cuerlib/bosses_stageapi";
else
    Classes.Bosses="cuerlib/bosses";
end



do --Classes
    local classMetatable = {
        Lib = Lib
    }
    classMetatable.__index = classMetatable;

    local LibMetatable = {
        __index = function(self, key)
            -- Require the file if target file is not loaded.
            local class = Require(Classes[key]);
            if (class) then
                self[key] = class;
                return class;
            end
        end
    }
    setmetatable(Lib, LibMetatable);



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

    --- Get an entity's data which is under the registered mod.
    ---@param entity Entity @Target entity.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Lib:GetEntityModData(entity, temp)
        local dataName = self.ModInfo.DataName;
        if (not dataName) then
            error("Trying to get data from entity while no mod is registered.");
        end
        if (temp) then
            dataName = dataName.."_TEMP"
        end
        local data = entity:GetData();
        
        data[dataName] = data[dataName] or {};
        return data[dataName];
    end
    
    --- Set an entity's data which is under the registered mod.
    ---@param entity Entity @Target entity.
    ---@param data table @Setting data.
    ---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
    function Lib:SetEntityModData(entity, data, temp)
        
        local dataName = self.ModInfo.DataName;
        if (not dataName) then
            error("Trying to set data to entity while no mod is registered.");
        end
        if (temp) then
            dataName = dataName.."_TEMP"
        end
        local entData = entity:GetData();
        entData[dataName] = entData[dataName] or {};
        local modData = entData[dataName];
        
        for k, v in pairs(modData) do
            rawset(modData, k, nil);
        end
    
        for k, v in pairs(data) do
            rawset(modData, k, v);
        end
    end

    --- Get the global data which is under the registered mod.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Lib:GetModGlobalData(temp)
        if (temp == nil) then
            temp = false;
        end
        local getter = self.ModInfo.GlobalDataGetter;
        if (not getter) then
            error("Trying to get global data while no mod is registered.");
        end

        if (type(getter) == "function") then
            return getter(temp);
        else
            error("Trying to get global data by a value that is not a function.");
        end
    end

    --- Set the global data which is under the registered mod.
    ---@param data table @Setting data.
    ---@param temp boolean @If is true, sets the data which will not be saved after exiting the game.
    function Lib:SetModGlobalData(data, temp)
        if (temp == nil) then
            temp = false;
        end
        local setter = self.ModInfo.GlobalDataSetter;
        if (not setter) then
            error("Trying to set global data while no mod is registered.");
        end

        if (type(setter) == "function") then
            setter(data, temp);
        -- elseif (type(setter) == "table") then
        --     for k, v in pairs(setter) do
        --         rawset(setter, k, nil);
        --     end

        --     for k, v in pairs(data) do
        --         rawset(setter, k, v);
        --     end
        else
            error("Trying to set global data by a value that is not a function.");
        end
    end


    --- Get an entity's data used by this lib which is under the registered mod.
    ---@param entity Entity @Target entity.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Lib:GetLibData(entity, temp)
        local modData = self:GetEntityModData(entity, temp);
        modData._CUERLIB = modData._CUERLIB or {};
        return modData._CUERLIB;
    end

    --- Get the global data data used by this lib which is under the registered mod.
    ---@param temp boolean @If is true, returns the data which will not be saved after exiting the game.
    ---@return table Data @Returned data.
    function Lib:GetGlobalLibData(temp)
        local globalData = self:GetModGlobalData(temp);
        globalData._CUERLIB = globalData._CUERLIB or {};
        return globalData._CUERLIB;
    end

end




Lib.Callbacks = Require("cuerlib/callbacks");
for k,v in pairs(Classes) do
    Lib[k] = Require(v);
end

function Lib:Register(mod, dataName, getGlobalData, setGlobalData)
    self.ModInfo = {
        Mod = mod,
        DataName = dataName,
        GlobalDataGetter = getGlobalData,
        GlobalDataSetter = setGlobalData
    }
    for k,v in pairs(Classes) do
        local class = Lib[k];
        if (class.Register) then
            class:Register(mod);
        end
    end
    -- self.Actives:Register(mod);
    -- self.Pickups:Register(mod);
    -- self.HoldingActive:Register(mod);
    -- self.PlayerForms:Register(mod);
    -- self.Greed:Register(mod);
    -- self.SaveAndLoad:Register(mod);
    -- self.Collectibles:Register(mod);
    -- self.Revive:Register(mod);
    -- self.Rewind:Register(mod);
    -- self.Stages:Register(mod);
    -- self.Weapons:Register(mod);
    -- self.Damages:Register(mod);
    -- self.Shields:Register(mod);
    -- self.Detection:Register(mod);
    -- self.Bosses:Register(mod);
    -- self.Tears:Register(mod);
end

function Lib:LateRegister()
    for k,v in pairs(Classes) do
        local class = Lib[k];
        if (class.LateRegister) then
            class:LateRegister();
        end
    end
end

_TEMP_CUERLIB = nil

return Lib;