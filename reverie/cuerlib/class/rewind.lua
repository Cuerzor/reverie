local Lib = LIB;

local Rewind = Lib:NewClass();
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
        setmetatable(clone, getmetatable(origin));
    else -- number, string, boolean, etc
        clone = origin
    end
    return clone
end

local function GetRewindData()
    local data = {};
    data.Global = Lib:GetGlobalLibData();
    data.Global_TEMP = Lib:GetGlobalLibData(true);

    data.Players = {};
    data.Players_TEMP = {};
    for i, player in Lib.Players.PlayerPairs(true, false) do 
        local key = tostring(i);
        
        local playerData = {};
        playerData = Lib:GetEntityLibData(player);
        data.Players[key] = playerData;

        local tempData = {};
        tempData = Lib:GetEntityLibData(player, true);
        data.Players_TEMP[key] = tempData;
    end
    
    data.Ghosts = {};
    data.Ghosts_TEMP = {};
    for i, player in Lib.Players.PlayerPairs(false, true) do 
        local key = tostring(i);

        local playerData = {};
        playerData = Lib:GetEntityLibData(player);
        data.Ghosts[key] = playerData;

        local tempData = {};
        tempData = Lib:GetEntityLibData(player, true);
        data.Ghosts_TEMP[key] = tempData;
    end
    return data;
end

local function SetPlayersData(data);
    for i, player in Lib.Players.PlayerPairs() do 
        for index, playerData in pairs(data.Players) do
            if (index == tostring(i)) then
                Lib:SetEntityLibData(player, playerData);
            end
        end
        for index, playerData in pairs(data.Players_TEMP) do
            if (index == tostring(i)) then
                Lib:SetEntityLibData(player, playerData, true);
            end
        end
    end
end

local function SetGhostsData(data)
    for i, player in Lib.Players.PlayerPairs(false, true) do 
        for index, playerData in pairs(data.Ghosts) do
            if (index == tostring(i)) then
                Lib:SetEntityLibData(player, playerData);
            end
        end
        
        for index, playerData in pairs(data.Ghosts_TEMP) do
            if (index == tostring(i)) then
                Lib:SetEntityLibData(player, playerData, true);
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL);
        player:EvaluateItems();
    end
end

local function SetGlobalData(data)

    Lib:SetGlobalLibData(data.Global);
    Lib:SetGlobalLibData(data.Global_TEMP, true);
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
        SetPlayersData(data);
    end
end
Rewind:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom);


local function PostUpdate()
    local game = Game();
    local room = game:GetRoom();
    if (room:GetFrameCount() == 1) then
        if (Rewind.Rewinding) then
            SetGhostsData(Rewind.RewindingData);
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