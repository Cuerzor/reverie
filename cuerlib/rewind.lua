local Lib = _TEMP_CUERLIB;

local Rewind = Lib:NewClass();
Rewind.Rewinding = false;
Rewind.RewindingData = nil;
Rewind.LastData = {
    Global = {},
    Players = {};
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
    local dataName = Lib.ModInfo.DataName;
    if (not dataName) then
        error("Trying to get data from entity while no mod is registered.");
    end

    local data = {};
    data.Global = Lib:GetModGlobalData();
    data.Players = {};
    for i, player in Lib.Detection.PlayerPairs(true, false) do 
        local playerData = {};
        playerData[dataName] = Lib:GetEntityModData(player);
        data.Players[tostring(i)] = playerData;
    end

    
    data.Ghosts = {};
    for i, player in Lib.Detection.PlayerPairs(false, true) do 
        local playerData = {};
        playerData[dataName] = Lib:GetEntityModData(player);
        data.Ghosts[tostring(i)] = playerData;
    end
    return data;
end

local function SetPlayersData(data)
    
    local dataName = Lib.ModInfo.DataName;
    if (not dataName) then
        error("Trying to get data from entity while no mod is registered.");
    end

    local playersData = data;
    for i, player in Lib.Detection.PlayerPairs() do 
        for index, playerData in pairs(playersData) do
            if (index == tostring(i)) then
                Lib:SetEntityModData(player, playerData[dataName]);
            end
        end
    end
end

local function SetGhostsData(data)
    
    local dataName = Lib.ModInfo.DataName;
    if (not dataName) then
        error("Trying to get data from entity while no mod is registered.");
    end

    local playersData = data;
    for i, player in Lib.Detection.PlayerPairs(false, true) do 
        for index, playerData in pairs(playersData) do
            if (index == tostring(i)) then
                Lib:SetEntityModData(player, playerData[dataName]);
                player:AddCacheFlags(CacheFlag.CACHE_ALL);
                player:EvaluateItems();
            end
        end
    end
end

local function SetRewindData(data, includePlayers, includeGhosts)

    local dataName = Lib.ModInfo.DataName;
    if (not dataName) then
        error("Trying to get data from entity while no mod is registered.");
    end

    Lib:SetModGlobalData(data.Global);
end

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
        SetRewindData(data, true, false);
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