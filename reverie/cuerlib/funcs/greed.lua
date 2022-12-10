local Lib = LIB;
local Greed = Lib:NewClass();

local GreedState = {
    GREED_NOT_CLEARED = 0,
    GREED_MONSTER_CLEARED = 1,
    GREED_BOSS_CLEARED = 2,
    GREED_DEAL_CLEARED = 3,
}
Greed.GreedState = GreedState;
local function GetGlobalData(init)
    local data = Lib:GetGlobalModData();
    if (init) then
        data._GREED = data._GREED or {
            Cleared = false,
            LastGreedWave = 0
        }
    end
    return data._GREED;
end
local function PostUpdate(mod)
    local game = Game();
    local room = game:GetRoom();
    if (game:IsGreedMode()) then
        local data = GetGlobalData(true);
        local level = game:GetLevel();
        local wave = level.GreedModeWave;
        if (wave > data.LastGreedWave) then
            Isaac.RunCallback(Lib.CLCallbacks.CLC_POST_NEW_GREED_WAVE, wave);
        end

        local clear = room:IsClear();
        if (clear and clear ~= data.Cleared) then
            local bossWave = game:GetGreedBossWaveNum () - 1;
            local totalWave = game:GetGreedWavesNum() - 1;
            if (wave == bossWave or wave == totalWave) then
                local state = GreedState.GREED_NOT_CLEARED;
                if (wave == bossWave) then
                    state = GreedState.GREED_MONSTER_CLEARED;
                elseif (wave == totalWave) then
                    state = GreedState.GREED_BOSS_CLEARED;
                elseif (wave == totalWave + 1) then
                    state = GreedState.GREED_DEAL_CLEARED;
                end
                Isaac.RunCallback(Lib.CLCallbacks.CLC_POST_GREED_WAVE_END, state);
            end
        end

        data.LastGreedWave = wave;
        data.Cleared = clear;
    end
end
Greed:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

return Greed;