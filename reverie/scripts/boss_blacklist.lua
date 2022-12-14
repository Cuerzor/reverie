local Lib = CuerLib;
local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;
local Bosses = {}
Bosses.Blacklist = {}

Bosses.BossList = {
    "The Abandoned",
    "Necrospyder",
    "The Centipede",
    "Pyroplume",
    "The Summoner",
    "Devilcrow",
    "Guppet",
    "Reverie",
    "Doremy"
}

function THI.IsBossEnabled(name)
    return Bosses.Blacklist[name] ~= true;
end
function THI.SetBossEnabled(name, enabled)
    local persistent = SaveAndLoad:ReadPersistentData();
    persistent.BossBlacklist = persistent.BossBlacklist or {};
    persistent.BossBlacklist[name] = not enabled;
    Bosses.Blacklist[name] = not enabled;
    Lib.SaveAndLoad:WritePersistentData(persistent);

    Lib.Bosses:UpdateBosses()
end

function Bosses.UpdateBlacklist()
    local persistent = SaveAndLoad:ReadPersistentData();
    if (persistent.BossBlacklist) then
        Bosses.Blacklist = {}
        for name, value in pairs(persistent.BossBlacklist) do
            Bosses.Blacklist[name] = value;
        end
        Lib.Bosses:UpdateBosses()
    end
end
Bosses.UpdateBlacklist();

local function PostGameStarted(mod, isContinued)
    Bosses.UpdateBlacklist()
end
THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);

return Bosses;