local Mod = SINGLETON;

local Rewind = Mod:NewClass();
Rewind.Rewinding = false;
Rewind.RewindingData = nil;
Rewind.LastData = {
    Global = {},
    Players = {};
}
Rewind.DataTypes = {
    GLOBAL = 0,
    PLAYER = 1,
    GHOST = 2
}

local function Clone(origin)
    local orig_type = type(origin)
    local clone;
    if (orig_type == "table") then
        clone = {}
        for orig_key, orig_value in pairs(origin) do
            clone[Clone(orig_key)] = Clone(orig_value)
        end
    else -- number, string, boolean, etc
        clone = origin
    end
    return clone
end

local function GetRewindData()
    local dataName = Mod.DataName;

    local data = {};
    data.Global = {};
    data.Global[dataName] = Mod:GetGlobalModData();
    Isaac.RunCallback(Mod.Callbacks.CLC_GET_REWIND_DATA, data.Global, Rewind.DataTypes.GLOBAL);

    data.Players = {};
    for i, player in Mod.Players.PlayerPairs(true, false) do 
        local playerData = {};

        playerData[dataName] = Mod:GetEntityModData(player);
        Isaac.RunCallback(Mod.Callbacks.CLC_GET_REWIND_DATA, playerData, Rewind.DataTypes.PLAYER, player);

        data.Players[tostring(i)] = playerData;
    end
    
    data.Ghosts = {};
    for i, player in Mod.Players.PlayerPairs(false, true) do 
        local playerData = {};

        playerData[dataName] = Mod:GetEntityModData(player);
        Isaac.RunCallback(Mod.Callbacks.CLC_GET_REWIND_DATA, playerData, Rewind.DataTypes.GHOST, player);

        data.Ghosts[tostring(i)] = playerData;
    end
    return data;
end

local function SetPlayersData(data)
    local dataName = Mod.DataName;

    local playersData = data;
    for i, player in Mod.Players.PlayerPairs() do 
        for index, playerData in pairs(playersData) do
            if (index == tostring(i)) then
                Mod:SetEntityModData(player, playerData[dataName]);
                Isaac.RunCallback(Mod.Callbacks.CLC_SET_REWIND_DATA, playerData, Rewind.DataTypes.PLAYER, player);
            end
        end
    end
end

local function SetGhostsData(data)
    
    local dataName = Mod.DataName;

    local playersData = data;
    for i, player in Mod.Players.PlayerPairs(false, true) do 
        for index, playerData in pairs(playersData) do
            if (index == tostring(i)) then
                Mod:SetEntityModData(player, playerData[dataName]);
                Isaac.RunCallback(Mod.Callbacks.CLC_SET_REWIND_DATA, playerData, Rewind.DataTypes.GHOST, player);
                player:AddCacheFlags(CacheFlag.CACHE_ALL);
                player:EvaluateItems();
            end
        end
    end
end

local function SetGlobalData(data)

    local dataName = Mod.DataName;

    Mod:SetGlobalModData(data.Global[dataName]);
    Isaac.RunCallback(Mod.Callbacks.CLC_SET_REWIND_DATA, data.Global, Rewind.DataTypes.GLOBAL);
end


-- Events.
local function useHourglass(mod, item, rng, player, flags, slot, data)
    Rewind.Rewinding = true;
    Rewind.RewindingData = Clone(Rewind.LastData);
end
Rewind:AddCallback(ModCallbacks.MC_USE_ITEM, useHourglass, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS);

local function postNewRoom(mod)
    if (not Rewind.Rewinding) then
        Rewind.LastData = Clone(GetRewindData());
    else
        local data = Rewind.RewindingData;
        SetGlobalData(data);
        SetPlayersData(data.Players);
    end
end
Rewind:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom);


local function PostUpdate()
    local game = Game();
    local room = game:GetRoom();
    if (room:GetFrameCount() == 1) then
        if (Rewind.Rewinding) then
            SetGhostsData(Rewind.RewindingData.Ghosts);
            Rewind.Rewinding = false;
            Rewind.RewindingData = nil;
        end
    end
end
Rewind:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

local function postGameStarted(mod, isContinued)
    Rewind.LastData = Clone(GetRewindData());
end
Rewind:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted);


return Rewind;