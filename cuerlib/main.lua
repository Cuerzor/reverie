local Lib = {
    ModInfo = {
        Mod = nil,
        DataName = nil,
        GlobalDataGetter = nil,
        GlobalDataSetter = nil
    },
    Loaded = {}
}

CuerLib = Lib;

function CuerLib.Require(filename)
    if (not CuerLib.Loaded[filename]) then
        local file = include(filename);
        CuerLib.Loaded[filename] = file;
        return file;
    end
    return CuerLib.Loaded[filename];
end

function CuerLib:GetModEntityData(entity, temp)
    
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

function CuerLib:SetModEntityData(entity, data, temp)
    
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

function CuerLib:GetData(entity, temp)
    local modData = self:GetModEntityData(entity, temp);
    modData._CUERLIB = modData._CUERLIB or {};
    return modData._CUERLIB;
end

function CuerLib:GetModGlobalData()
    local getter = self.ModInfo.GlobalDataGetter;
    if (not getter) then
        error("Trying to get global data while no mod is registered.");
    end

    if (type(getter) == "function") then
        return getter();
    else
        return getter;
    end
end

function CuerLib:SetModGlobalData(data)
    local setter = self.ModInfo.GlobalDataSetter;
    if (not setter) then
        error("Trying to set global data while no mod is registered.");
    end

    if (type(setter) == "function") then
        setter(data);
    elseif (type(setter) == "table") then
        for k, v in pairs(setter) do
            rawset(setter, k, nil);
        end

        for k, v in pairs(data) do
            rawset(setter, k, v);
        end
    else
        error("Trying to set global data that is not a table.");
    end
end

function CuerLib:GetGlobalData()
    local globalData = self:GetModGlobalData();
    globalData._CUERLIB = globalData._CUERLIB or {};
    return globalData._CUERLIB;
end

local function Require(filename) 
    return CuerLib.Require(filename);
end



local Utility = Require("cuerlib/utility");

CuerLib.UTF8 = Require("cuerlib/utf8");
CuerLib.Consts = Require("cuerlib/consts");
CuerLib.Callbacks = Require("cuerlib/callbacks");
CuerLib.Detection = Require("cuerlib/detection");
CuerLib.Inputs = Require("cuerlib/inputs");
CuerLib.Math = Require("cuerlib/math");
CuerLib.Synergies = Require("cuerlib/synergies");
CuerLib.Screen = Require("cuerlib/screen");
CuerLib.Stats = Require("cuerlib/stats");
CuerLib.Damages = Require("cuerlib/damages");
CuerLib.Shields = Require("cuerlib/shield");
CuerLib.ItemPools = Require("cuerlib/item_pools");
CuerLib.Greed = Require("cuerlib/greed");
CuerLib.Rooms = Require("cuerlib/rooms");
CuerLib.Grids = Require("cuerlib/grids");
CuerLib.Players = Require("cuerlib/players");

CuerLib.Explosion = Require("cuerlib/explosion");
CuerLib.Familiars = Require("cuerlib/familiars");
CuerLib.ModComponents = Require("cuerlib/mod_components");
CuerLib.Tears = Require("cuerlib/tears");

CuerLib.Actives = Require("cuerlib/actives");
CuerLib.Pickups = Require("cuerlib/pickups");
CuerLib.HoldingActive = Require("cuerlib/holding_active");
CuerLib.PlayerForms = Require("cuerlib/player_forms");
CuerLib.SaveAndLoad = Require("cuerlib/save_and_load");
CuerLib.Collectibles = Require("cuerlib/collectibles");
CuerLib.Revive = Require("cuerlib/revive");
CuerLib.Rewind = Require("cuerlib/rewind");
CuerLib.Stages = Require("cuerlib/stages");
CuerLib.Weapons = Require("cuerlib/weapons");

if (StageAPI) then
    CuerLib.Bosses = Require("cuerlib/bosses_stageapi");
else
    CuerLib.Bosses = Require("cuerlib/bosses");
end

function CuerLib:Register(mod, dataName, getGlobalData, setGlobalData)
    self.ModInfo = {
        Mod = mod,
        DataName = dataName,
        GlobalDataGetter = getGlobalData,
        GlobalDataSetter = setGlobalData
    }
    self.Actives:Register(mod);
    self.Pickups:Register(mod);
    self.HoldingActive:Register(mod);
    self.PlayerForms:Register(mod);
    self.Greed:Register(mod);
    self.SaveAndLoad:Register(mod);
    self.Collectibles:Register(mod);
    self.Revive:Register(mod);
    self.Rewind:Register(mod);
    self.Stages:Register(mod);
    self.Weapons:Register(mod);
    self.Damages:Register(mod);
    self.Shields:Register(mod);
    self.Detection:Register(mod);
    self.Inputs:Register(mod);
    self.Bosses:Register(mod);
    self.Tears:Register(mod);
end

function CuerLib:LateRegister()
    self.Stats:LateRegister();
end

CuerLib = nil

return Lib;