local Lib = CuerLib;
Lib.ClassPaths = {
    -- Tools
    UTF8 = "helpers/utf8",
    Consts = "helpers/consts",
    Entities = "helpers/entities",
    Inputs = "helpers/inputs",
    Math = "helpers/math",
    Synergies = "helpers/synergies",
    Screen = "helpers/screen",
    Damages = "helpers/damages",
    Rooms = "helpers/rooms",
    Players = "helpers/players",
    Familiars = "helpers/familiars",

    Stats = "stats",
    Shields = "shield",
    Greed = "greed",
    Tears = "tears",
    Actives = "actives",
    Pickups = "pickups",
    ItemPools = "item_pools",
    HoldingActive = "holding_active",
    PlayerForms = "player_forms",
    Collectibles = "collectibles",
    Rewind = "rewind",
    Stages = "stages",
    Weapons = "weapons",
    Bosses = "bosses",
    Curses = "curses",
    Grids = "grids",
    Revive = "revive",
}
if (StageAPI) then
    Lib.ClassPaths.Bosses="bosses_stageapi";
end

local classMetatable = {
    Mod = Lib
}
classMetatable.__index = classMetatable;

function Lib:NewClass()
    local class = {};
    setmetatable(class, classMetatable);
    class.Callbacks = {};
    function class:AddCallback(callback, func, param)
        self:AddPriorityCallback(callback, CallbackPriority.DEFAULT, func, param)
    end
    function class:AddPriorityCallback(callback, priority, func, param)
        table.insert(self.Callbacks, {Mod = Lib, Callback = callback, Priority = priority, Function = func, Param = param})
    end
    function class:Register()
        for _, callback in pairs(self.Callbacks) do
            callback.Mod:AddPriorityCallback(callback.Callback, callback.Priority, callback.Function, callback.Param);
        end
    end
    function class:Unregister()
        for _, callback in pairs(self.Callbacks) do
            callback.Mod:RemoveCallback(callback.Callback, callback.Function);
        end
    end
    return class;
end
