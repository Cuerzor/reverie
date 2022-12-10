local Lib = LIB;
local Rewind = Lib:NewClass();

local function GetRewindData(mod, data, type, player)
    local Singleton = Lib:GetSingleton();
    local Types = Singleton.Rewind.DataTypes;
    local dataName = Lib.DataName;
    if (type == Types.GLOBAL) then
        data[dataName] = Lib:GetGlobalModData();
    else
        data[dataName] = Lib:GetEntityModData(player);
    end
end
Rewind:AddCallback(Lib.Callbacks.CLC_GET_REWIND_DATA, GetRewindData);


local function SetRewindData(mod, data, type, player)
    local Singleton = Lib:GetSingleton();
    local Types = Singleton.Rewind.DataTypes;
    local dataName = Lib.DataName;
    if (type == Types.GLOBAL) then
        Lib:SetGlobalModData(data[dataName]);
    else
        Lib:SetEntityModData(player, data[dataName]);
    end
end
Rewind:AddCallback(Lib.Callbacks.CLC_SET_REWIND_DATA, SetRewindData);

return Rewind;