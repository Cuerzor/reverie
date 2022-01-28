local Bosses = {
}

function Bosses:SetBossConfig(name, config, roomConfigs)
    local names = config.NamePaths;
    local bossName = names[Options.Language] or names.en;
    StageAPI.AddBossData(name, {
        Name = config.Name,
        Portrait = config.PortraitPath,
        Offset = config.PortraitOffset,
        Bossname = bossName,
        Rooms = StageAPI.RoomsList(roomConfigs.ID, require(roomConfigs.LuaRoomPath))
    })

    local stages = config.StageAPI.Stages;
    for i, stage in pairs(stages) do
        StageAPI.AddBossToBaseFloorPool({BossID = name, Weight = stage.Weight or 1}, stage.Stage, stage.Type, true);
    end
    
end

function Bosses:Register(mod)
end

return Bosses;