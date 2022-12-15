return function(Addon)
    local Lib = CuerLib;
    local json = require("json")
    local SaveAndLoad = Addon:NewClass();

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

    --- Read the persistent data from savedata.
    function SaveAndLoad:ReadPersistentData()
        local mod = Addon.Mod;
        local data = GetModData(mod);
        return data.Persistent;
    end

    --- Write the persistent data to savedata.
    function SaveAndLoad:WritePersistentData(data)
        local mod = Addon.Mod;
        local modData = GetModData(mod);
        modData.Persistent = data;

        local jsonText = json.encode(modData);
        mod:SaveData(jsonText);
    end

    --- Read the game state data from savedata.
    function SaveAndLoad:ReadGameStateData()
        local mod = Addon.Mod;
        local data = GetModData(mod);
        return data.GameState;
    end

    --- Write the game state data to savedata.
    function SaveAndLoad:WriteGameStateData(data)
        local mod = Addon.Mod;
        local modData = GetModData(mod);
        modData.GameState = data;
        
        local jsonText = json.encode(modData);
        mod:SaveData(jsonText);
    end

    -- Remove game state data.
    function SaveAndLoad:RemoveGameState()
        SaveAndLoad:WriteGameStateData(nil);
    end



    local function Save()
        local state = {};
        state.Global = Addon:GetGlobalModData();
        state.Players = {};
        for index, player in CuerLib.Players.PlayerPairs(true, true) do
            state.Players[tostring(index)] = Addon:GetEntityModData(player);
        end

        SaveAndLoad:WriteGameStateData(state);
        
        Isaac.RunCallback(Addon.Callbacks.CLC_POST_SAVE);
    end

    local function RestartGame()

        SaveAndLoad:RemoveGameState();
        
        Isaac.RunCallback(Lib.Callbacks.CLC_POST_RESTART);
    end

    ----------------
    -- Events
    ----------------

    local function preGameExit(mod, ShouldSave)
        if (ShouldSave) then
            Save();
        else
            RestartGame();
        end
        Addon:SetGlobalModData({})
        Addon:SetGlobalModData({}, true)
        Isaac.RunCallback(Lib.Callbacks.CLC_POST_EXIT, ShouldSave);
    end
    SaveAndLoad:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, preGameExit)


    local function onNewLevel(mod)
        if (Game():GetLevel():GetStage() > 1) then
            Save();
        end
    end
    SaveAndLoad:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewLevel)


    local function onGameStarted(mod, isContinued)
        --Loading Moddata--
        local mod = Addon.Mod;
        if (mod:HasData()) then
            if (isContinued) then
                local state = SaveAndLoad:ReadGameStateData();
                
                if (state) then
                    Addon:SetGlobalModData(state.Global);
                    local game = Game();
                    for i, player in CuerLib.Players.PlayerPairs(true, true) do
                        for k, v in pairs(state.Players) do
                            local index = tonumber(k);
                            if (i == index) then
                                Addon:SetEntityModData(player, v)
                            end
                        end
                    end
                    Isaac.RunCallback(Addon.Callbacks.CLC_POST_LOAD);
                end
            else
                SaveAndLoad:RemoveGameState();
            end
        end
    end
    SaveAndLoad:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStarted)

    return SaveAndLoad;
end