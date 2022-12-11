return function(Addon)
    local Lib = CuerLib;
    local Rewind = Addon:NewClass();

    local function GetRewindData(mod, data, type, player)
        local Types = Lib.Rewind.DataTypes;
        local dataName = Addon.DataName;
        if (type == Types.GLOBAL) then
            data[dataName] = Addon:GetGlobalModData();
        else
            data[dataName] = Addon:GetEntityModData(player);
        end
    end
    Rewind:AddCallback(Lib.Callbacks.CLC_GET_REWIND_DATA, GetRewindData);


    local function SetRewindData(mod, data, type, player)
        local Types = Lib.Rewind.DataTypes;
        local dataName = Addon.DataName;
        if (type == Types.GLOBAL) then
            Addon:SetGlobalModData(data[dataName]);
        else
            Addon:SetEntityModData(player, data[dataName]);
        end
    end
    Rewind:AddCallback(Lib.Callbacks.CLC_SET_REWIND_DATA, SetRewindData);

    return Rewind;
end