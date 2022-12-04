local Lib = _TEMP_CUERLIB;

local json = require("json")
local SaveAndLoad = Lib:NewClass();

----------------
-- Callbacks
----------------




local function GetModData(mod)
    if (mod:HasData()) then
        local jsonData = mod:LoadData();
        local loadedData;
        if pcall( function() loadedData = json.decode(jsonData) end ) then
            if (loadedData and loadedData.Persistent) then
                return loadedData;
            end
        end
    end

    return {
        Version = 1,
        Persistent = {},
        GameState = {}
    };
end

function SaveAndLoad.ReadPersistentData()
    local info = Lib.ModInfo;
    local mod = info.Mod;
    local data = GetModData(mod);
    return data.Persistent;
end

function SaveAndLoad.WritePersistentData(data)
    local info = Lib.ModInfo;
    local mod = info.Mod;
    local modData = GetModData(mod);
    modData.Persistent = data;

    local jsonText = json.encode(modData);
    mod:SaveData(jsonText);
end

function SaveAndLoad.ReadGameStateData()
    local info = Lib.ModInfo;
    local mod = info.Mod;
    local data = GetModData(mod);
    return data.GameState;
end

function SaveAndLoad.WriteGameStateData(data)
    local mod = Lib.ModInfo.Mod;
    local modData = GetModData(mod);
    modData.GameState = data;
    
    local jsonText = json.encode(modData);
    mod:SaveData(jsonText);
end

function SaveAndLoad.RemoveGameState()
    SaveAndLoad.WriteGameStateData(nil);
end



local function Save()
    local state = {};
    state.Global = Lib:GetModGlobalData();
    state.Players = {};
    for index, player in Lib.Detection.PlayerPairs(true, true) do
        state.Players[tostring(index)] = Lib:GetEntityModData(player);
    end

    SaveAndLoad.WriteGameStateData(state);
    
    for index, funcData in pairs(Lib.Callbacks.Functions.PostSave) do
        funcData.Func(funcData.Mod);
    end
end

local function RestartGame()

    local info = Lib.ModInfo;
    SaveAndLoad.RemoveGameState(info.Mod);
    
    for index, funcData in pairs(Lib.Callbacks.Functions.PostRestart) do
        funcData.Func(funcData.Mod);
    end
end

----------------
-- Events
----------------

function SaveAndLoad:preGameExit(ShouldSave)
    if (ShouldSave) then
        Save();
    else
        RestartGame();
    end
    for index, funcData in pairs(Lib.Callbacks.Functions.PostExit) do
        funcData.Func(funcData.Mod);
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveAndLoad.preGameExit)


function SaveAndLoad:onNewLevel()
    if (THI.Game:GetLevel():GetStage() > 1) then
        Save();
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaveAndLoad.onNewLevel)


function SaveAndLoad:onGameStarted(isContinued)
    --Loading Moddata--
    local info = Lib.ModInfo;
    local mod = info.Mod;
    if (mod:HasData()) then
        if (isContinued) then
            local state = SaveAndLoad.ReadGameStateData();
            
            if (state) then
                Lib:SetModGlobalData(state.Global);
                local game = THI.Game;
                for i, player in Lib.Detection.PlayerPairs(true, true) do
                    for k, v in pairs(state.Players) do
                        local index = tonumber(k);
                        if (i == index) then
                            Lib:SetEntityModData(player, v)
                        end
                    end
                end
                for index, funcData in pairs(Lib.Callbacks.Functions.PostLoad) do
                    funcData.Func(funcData.Mod);
                end
            end
        else
            SaveAndLoad.RemoveGameState(mod);
        end
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveAndLoad.onGameStarted)

return SaveAndLoad;