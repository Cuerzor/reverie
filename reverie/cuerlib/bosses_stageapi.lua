local Bosses = _TEMP_CUERLIB:NewClass();
Bosses.ForceCustomBoss = false;

Bosses.BossConfigs = {}
Bosses.RoomConfigs = {}

local function UpdateStageAPI()
    for name, bossConfig in pairs(Bosses.BossConfigs) do
        local config = bossConfig.Config;
        local stages = config.StageAPI.Stages;
        for i, stage in pairs(stages) do
            local floorInfo = StageAPI.GetBaseFloorInfo(stage.Stage, stage.Type, false);
            if (floorInfo.Bosses) then
                for i, poolEntry in ipairs(floorInfo.Bosses.Pool) do
                    if (poolEntry.BossID == name) then
                        local weight = stage.Weight or 1;
                        if (Bosses.ForceCustomBoss) then
                            weight = 65535;
                        end
                        if (not config:IsEnabled()) then
                            weight = 0;
                        end
                        poolEntry.Weight = weight;
                    end
                end
            end
        end
    end
end

function Bosses:SetBossConfig(name, config, roomConfigs)
    self.BossConfigs[name] = {Config = config, Rooms = roomConfigs};
    for i, room in pairs(roomConfigs.CustomRooms) do
        self.RoomConfigs[room.Name] = room;
    end
    
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

    UpdateStageAPI();
end


function Bosses:UpdateBosses()
    UpdateStageAPI();
end

function Bosses:IsForceCustomBosses()
    return self.ForceCustomBoss;
end
function Bosses:SetForceCustomBosses(value)
    self.ForceCustomBoss = value;
    UpdateStageAPI();
end
function Bosses:IsPlayingSplashSprite()
    return false;
end

local function GetRoomConfigForCurrent()
    local curRoom = StageAPI:GetCurrentRoom();
    if (curRoom and curRoom.Layout) then
        local roomName = curRoom.Layout.Name;
        if (roomName) then
            local roomConfig = Bosses.RoomConfigs[roomName];
            if (roomConfig) then
                return roomConfig;
            end
        end
    end
    return nil;
end

do -- Vanishing Twin
    local function PostNewRoom(mod)
        local replacedBoss = GetRoomConfigForCurrent();
        if (replacedBoss) then
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.VANISHING_TWIN)) do
                local familiar = ent:ToFamiliar();
                if (familiar.Coins > 0) then
                    local bossConfig = Bosses.BossConfigs[replacedBoss.BossID].Config;
                    familiar.Coins = bossConfig.Type;
                    familiar.Hearts = bossConfig.Variant or 0;
                    familiar.Keys = bossConfig.SubType or 0;
                    if (replacedBoss.VanishingTwinTarget) then
                        familiar.TargetPosition = replacedBoss.VanishingTwinTarget;
                    end
                end
            end
        end
    end
    Bosses:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

    local function PostFamiliarUpdate(mod, familiar)
        if (familiar.Variant == FamiliarVariant.VANISHING_TWIN) then
            local replacedBoss = GetRoomConfigForCurrent();
            if (replacedBoss) then
                local bossConfig = Bosses.BossConfigs[replacedBoss.BossID].Config;

                local boss = familiar.Target;
                if (boss and boss:Exists()) then
                    if (boss.FrameCount == 0) then
                        if (bossConfig.VanishingTwinFunc) then
                            bossConfig:VanishingTwinFunc(boss);
                        end
                    end
                elseif (boss and not boss:Exists()) then
                    if (bossConfig.VanishingTwinFindTarget) then
                        familiar.Target = bossConfig:VanishingTwinFindTarget(boss, familiar.Target);
                    end
                end
            end
        end
    end
    Bosses:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFamiliarUpdate)
end


return Bosses;