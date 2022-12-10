local Lib = LIB;
local Rooms = Lib.Rooms;

local Bosses = Lib:NewClass();
Bosses.CustomRooms = {};
Bosses.BossConfigs = {};
Bosses.SplashSprite = Sprite();
Bosses.SplashSprite.PlaybackSpeed = 0.4978;
Bosses.SplashSprite:Load("gfx/ui/boss/cuerlib_versusscreen.anm2", true);
Bosses.PlayingSplashSprite = nil;
Bosses.BackgroundColor = Color.Default;
Bosses.ForceCustomBoss = false;
Bosses.StageBackgrounds = {
    
    {
        
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_1},
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_2}
        },
        --Color = Color(0.235714 * 0.5, 0.235714 * 0.5, 0.233333 * 0.53, 1,0, 0, 0),
        Color = Color(0.118, 0.118, 0.123, 1,0, 0, 0),
        --280
        --280
        --282
        --Color = Color(1, 1, 1, 1,- 0.118 * 3.05, - 0.118 * 3.05, - 0.124 * 2.88),
        --Color = Color(1, 1, 1, 1,0, -0.359, -0.357),
        --Color = Color(0.314, 0.314, 0.3333333, 1,-0.08, -0.08, -0.1),
        
        BossSpotPath = "gfx/ui/boss/bossspot_01x_downpour.png"
    },
    {
        
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_1},
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_2}
        },
        Color = Color(0.13, 0.13, 0.118, 1,0, 0, 0),
        BossSpotPath = "gfx/ui/boss/bossspot_02x_dross.png"
    },
    {
        
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_1},
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_2}
        },
        Color = Color(0.165 * 0.4, 0.15 * 0.39, 0.133 * 0.36, 1,0, 0, 0),
        BossSpotPath = "gfx/ui/boss/bossspot_03x_mines.png"
    },
    {
        
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_1},
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_2}
        },
        Color = Color(0.04, 0.04, 0.04, 1, 0, 0, 0),
        BossSpotPath = "gfx/ui/boss/bossspot_04x_ashpit.png"
    },
    {
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE3_1},
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE3_2}
        },
        Color = Color(0.06, 0.04, 0.06, 1,0,0,0),
        BossSpotPath = "gfx/ui/boss/bossspot_05x_mausoleum.png"
    },
    {
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE3_1},
            {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE3_2}
        },
        Color = Color(0.06, 0.016, 0.016, 1,0,0,0),
        BossSpotPath = "gfx/ui/boss/bossspot_06x_gehenna.png"
    },
    {
        Stages = {
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE4_1},
            {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE4_2}
        },
        Color = Color(0.05, 0.06, 0.04, 1,0,0,0),
        BossSpotPath = "gfx/ui/boss/bossspot_07x_corpse.png"
    },
}
Bosses.BossRoomType = {
    NO_BOSS_ROOM = 0,
    NORMAL = 1,
    FIRST_IN_LABYRINTH = 2,
    SECOND_IN_LABYRINTH = 3
}

local ReplacingGridConfig = nil;

local LayerOrders = {
    0, 1, 2, 9, 14, 13, 4, 5, 12, 11, 7, 8, 10, 15
}




local renderedObject = false;

local ClearColor = Color(0,0,0,0,0,0,0);
local function UpdatePlaceholderSprite(gridEnt)
    gridEnt:GetSprite().Scale = Vector.Zero;
end

-- Template.
-- local r = Grids.RoomGrids.Rock;
-- local t = Grids.RoomGrids.TallBlock;
-- local n = nil;
--local TemplateBoss = {
--     Type = 586, 
--     Variant = 0,
--     PortraitPath = "gfx/ui/boss/portrait_586.0_devilcrow.png",
--     PortraitOffset = Vector(0, -20),
--     NamePaths = {
--         en = "gfx/ui/boss/bossname_586.0_devilcrow.png",
--         zh = "gfx/ui/boss/bossname_586.0_devilcrow_zh.png"
--     },
--}
-- local TemplateRoom = {
--     ReplaceChance = 0,
--     Stages = {
--         {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE3_1}
--     },
--     Music = Music.MUSIC_BOSS2,
--     EnterAction = nil,
--     Grids = {
--         {r, r, r, r, r, r, n, r, r, r, r, r, r},
--         {r, r, r, r, r, n, n, n, r, r, r, r, r},
--         {n, n, n, n, n, n, n, n, n, n, n, n, n},
--         {n, n, n, n, n, n, n, n, n, n, n, n, n},
--         {t, n, n, n, n, n, n, n, n, n, n, n, t},
--         {n, t, n, n, n, n, n, n, n, n, n, t, n},
--         {n, n, n, n, n, n, n, n, n, n, n, n, n},
--     },
--     Entities = {
--         {Type = 586, Variant = 0, SubType = 0, Position = Vector(320, 240)}
--     }
-- }

local function GetGlobalData(init)
    local data = Lib:GetGlobalModData();
    if (init) then
        if (not data._BOSSES) then
            data._BOSSES = {
                ReplacedBosses = {
                }
            }
        end
    end
    return data._BOSSES;
end

local function GetLabyrinthBossRoomType(index)
    local game = Game();
    local level = game:GetLevel();
    local currentRoom = level:GetRoomByIdx (index);
    if (currentRoom.Data and currentRoom.Data.Type == RoomType.ROOM_BOSS) then
        local startIndex = currentRoom.GridIndex;
        local roomData = currentRoom.Data;
        local shape = roomData.Shape;

        local adjacentIndexes = Rooms.GetAdjacentIndexes(startIndex, shape)
        local nearBosses = {};
        local nearDefaults = {};
        
        for _, idx in pairs(adjacentIndexes) do
            local room = level:GetRoomByIdx(idx);
            if (room and room.Data) then
                if (room.Data.Type == RoomType.ROOM_BOSS) then
                    nearBosses[tostring(idx)] = true;
                end
                if (room.Data.Type == RoomType.ROOM_DEFAULT) then
                    nearDefaults[tostring(idx)] = true;
                end
            end
        end

        local adjBossCount = 0;
        local adjDefaultCount = 0;
        for key, exists in pairs(nearBosses) do
            if (exists) then
                adjBossCount = adjBossCount + 1;
            end
        end
        for key, exists in pairs(nearDefaults) do
            if (exists) then
                adjDefaultCount = adjDefaultCount + 1;
            end
        end

        if (adjBossCount <= 0) then
            return Bosses.BossRoomType.NORMAL
        else
            if (adjDefaultCount > 0) then
                return Bosses.BossRoomType.FIRST_IN_LABYRINTH
            else
                return Bosses.BossRoomType.SECOND_IN_LABYRINTH
            end 
        end

        return Bosses.BossRoomType.NORMAL
    end
    return Bosses.BossRoomType.NO_BOSS_ROOM
end

local function IsRoomFits(index, bossRoomType, config)
    local game = Game();
    local level = game:GetLevel();
    local stageType = level:GetStageType();
    local stage = level:GetStage();

    local roomShape = config.Shape or RoomShape.ROOMSHAPE_1x1;

    local roomDesc = level:GetRoomByIdx(index);
    if (not roomDesc.Data or roomShape ~= roomDesc.Data.Shape) then
        return false;
    end

    local roomStages = config.Stages;
    local labyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH > 0;
    for _, roomStage in pairs(roomStages) do
        
        if (roomStage.Type == stageType) then

            if (bossRoomType == Bosses.BossRoomType.SECOND_IN_LABYRINTH) then
                if (stage == LevelStage.STAGE1_1 or
                stage == LevelStage.STAGE2_1 or 
                stage == LevelStage.STAGE3_1 or 
                stage == LevelStage.STAGE4_1) then
                    stage = stage + 1;
                end
            end
            if (roomStage.Stage == stage) then
                return true;
            end
        end
    end
end

local function CreateBossReplacements()
    
    local game = Game();
    local level = game:GetLevel();
    local stage = level:GetStage();
    local seeds = game:GetSeeds();
    
    local rng = RNG();
    local seed = seeds:GetStageSeed (stage);
    rng:SetSeed(seed, 0);

    local rooms = level:GetRooms();
    local bossRooms = {};
    for i = 0, rooms.Size - 1 do
        local room = rooms:Get(i);
        if (room and room.Data.Type == RoomType.ROOM_BOSS) then
            local index = room.GridIndex;
            local type = GetLabyrinthBossRoomType(index);
            table.insert(bossRooms, {Index = index, Type = type});
        end
    end

    local globalData = GetGlobalData(true);
    local blacklist = {};
    for i = 1, #bossRooms do
        local currentBossRoom = bossRooms[i];
        local selectedList = {};
        -- Get valid room configs.
        for index, roomConfig in pairs(Bosses.CustomRooms) do
            local config = roomConfig.Room;
            local bossID = config.BossID;
            if (not blacklist[tostring(bossID)]) then
                -- If current room fits.
                if (IsRoomFits(currentBossRoom.Index, currentBossRoom.Type, config)) then
                    local bossConfig = Bosses.BossConfigs[bossID];
                    if (not bossConfig.IsEnabled or bossConfig:IsEnabled()) then
                        local encountered = true;
                        if (bossConfig) then
                            encountered = game:HasEncounteredBoss (bossConfig.Type, bossConfig.Variant);
                        end
                        if (not encountered) then
                            local value = rng:RandomInt(100);
                            if (value < config.ReplaceChance or Bosses.ForceCustomBoss) then
                                table.insert(selectedList, index);
                            end
                        end
                    end
                end
            end
        end
        -- Select a random room config.
        if (#selectedList > 0) then
            local listIndex = rng:RandomInt(#selectedList) + 1;
            local roomIndex = selectedList[listIndex];
            local roomConfig = Bosses.CustomRooms[roomIndex];
            globalData.ReplacedBosses[tostring(currentBossRoom.Index)] = roomIndex;
            local bossID = roomConfig.Room.BossID;
            local selectedName = roomConfig.Name;
            blacklist[tostring(bossID)] = true;
        end
    end
end

local function ReplaceGrids(config)
    local game = Game();
    local room = game:GetRoom();
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();

    local updatedIndexes = {};

    for x = 1, width - 2 do
        for y = 1, height - 2 do
            local index = y * width + x;
            local gridEnt = room:GetGridEntity(index);
            local cell = config.Grids[y] and config.Grids[y][x];
            if (gridEnt) then
                room:RemoveGridEntity(index, 0, false);
                updatedIndexes[index] = true;
            end 
        end
    end
    room:Update();

    
    for x = 1, width - 2 do
        for y = 1, height - 2 do
            local index = y * width + x;
            local cell = config.Grids[y] and config.Grids[y][x];
            if (cell) then
                if (cell.Type == GridEntityType.GRID_NULL) then
                    room:SpawnGridEntity(index, 1, 58115310, 1, 0);
                    local gridEnt = room:GetGridEntity(index);
                    if (gridEnt) then
                        UpdatePlaceholderSprite(gridEnt);
                    end
                    updatedIndexes[index] = true;
                else
                    room:SpawnGridEntity(index, cell.Type, cell.Variant, 1, 0)
                    updatedIndexes[index] = true;
                end
            end
        end
    end

    for index, updated in pairs(updatedIndexes) do
        if (updated) then
            local gridEnt = room:GetGridEntity(index);
            if (gridEnt) then
                gridEnt:PostInit();
            end
        end
    end

    ReplacingGridConfig = config;
end

local RemoveBlacklist = {
    {Type = EntityType.ENTITY_DARK_ESAU},
    {Type = EntityType.ENTITY_BLOOD_PUPPY}
}
local RemoveWhitelist = {
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_THROWABLEBOMB},
    {Type = EntityType.ENTITY_FIREPLACE},
    {Type = EntityType.ENTITY_MINECART},
    {Type = EntityType.ENTITY_EFFECT, Variant = EffectVariant.POOF01},
    {Type = EntityType.ENTITY_EFFECT, Variant = EffectVariant.HERETIC_PENTAGRAM}
}
local function TryRemoveEntity(ent, initialize)
    local remove = false;
    local inRange = ent.Type > 6 and ent.Type < 1000;
    if (initialize) then
        inRange = ent.Type > 3 and ent.Type < 1000;
    end
    for _, types in pairs(RemoveBlacklist) do
        if (ent.Type == types.Type and 
        (ent.Variant == types.Variant or not types.Variant) and 
        (ent.SubType == types.SubType or not types.SubType)) then
            goto next;
        end
    end
    for _, types in pairs(RemoveWhitelist) do
        if (ent.Type == types.Type and 
        (ent.Variant == types.Variant or not types.Variant) and 
        (ent.SubType == types.SubType or not types.SubType)) then
            remove = true;
            goto next;
        end
    end
    
    if (inRange) then
        
        if (not ent:ToNPC()) then
            remove = true;
        elseif (not ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            remove = true;
        end
    end

    ::next::
    if (remove) then
        ent:Remove();
    end
end
-- Clear the room when first visit the boss room.
local function ClearRoomEntities()
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        TryRemoveEntity(ent, true);
    end
end
-- Remove room temporary entities, monsters and bosses.
local function RemoveEntities()
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        TryRemoveEntity(ent);
    end
end
local function SpawnRoomEntities(config)
    if (config.Entities) then
        local game = Game();
        local room = game:GetRoom();
        local center = room:GetCenterPos();
        for _, ent in ipairs(config.Entities) do
            Isaac.Spawn(ent.Type, ent.Variant or 0, ent.SubType or 0, ent.Position or center, Vector.Zero, nil);
        end
    end
end
local function SpawnRoomBosses(config)
    if (config.Bosses) then
        local game = Game();
        local room = game:GetRoom();
        local center = room:GetCenterPos();
        for _, ent in ipairs(config.Bosses) do
            Isaac.Spawn(ent.Type, ent.Variant or 0, ent.SubType or 0, ent.Position or center, Vector.Zero, nil);
        end
    end
end


local function InitBossSplash(bossConfig)
    local game = Game();
    local portraitPath = ""
    local namePath = ""
    if (bossConfig) then
        portraitPath = bossConfig.PortraitPath
        local namePaths = bossConfig.NamePaths;
        namePath = namePaths[Options.Language] or namePaths.en;
        Bosses.BossPortraitOffset = bossConfig.PortraitOffset;
    end

    local level = game:GetLevel();
    local stageType = level:GetStageType();
    local stage = level:GetStage();
    local groundColor = Color.Default;
    local bossSpot = "";
    for _, bg in pairs(Bosses.StageBackgrounds) do
        for _, validStage in pairs(bg.Stages) do
            if (validStage.Type == stageType and validStage.Stage == stage) then
                groundColor = bg.Color;
                bossSpot = bg.BossSpotPath;
                break;
            end
        end
    end
    Bosses.SplashSprite:ReplaceSpritesheet(2, bossSpot);
    Bosses.SplashSprite:ReplaceSpritesheet(4, portraitPath);
    Bosses.SplashSprite:ReplaceSpritesheet(5, "");
    Bosses.SplashSprite:ReplaceSpritesheet(12, "");
    Bosses.SplashSprite:ReplaceSpritesheet(7, namePath);
    Bosses.SplashSprite:LoadGraphics();
    Bosses.BackgroundColor = groundColor;
    Bosses.SplashSprite:Play("Scene", true);
    Bosses.PlayingSplashSprite = Bosses.SplashSprite;
    renderedObject = false;
end

local function LoadBossRoom(roomConfig)
    local game = Game();
    local room = game:GetRoom();

    local firstVisit = room:IsFirstVisit();
    local cleared = room:IsClear();
    if (firstVisit) then
        ClearRoomEntities();
        ReplaceGrids(roomConfig);
        -- local bossID = roomConfig.BossID;
        -- local bossConfig = Bosses.BossConfigs[bossID];
        -- if (bossConfig) then
        --     game:AddEncounteredBoss (bossConfig.Type, bossConfig.Variant);
        -- end
    elseif (not cleared) then
        RemoveEntities();
    end

    Bosses.RemovingEntities = false;
    if (firstVisit) then
        SpawnRoomEntities(roomConfig);
    end
    if (not cleared) then
        SpawnRoomBosses(roomConfig);
        InitBossSplash(Bosses.BossConfigs[roomConfig.BossID]);
    end
    
    local size = room:GetGridSize();
    for i = 0, size - 1 do
        
        local gridEnt = room:GetGridEntity(i);
        if (gridEnt and gridEnt:GetType() == GridEntityType.GRID_DECORATION and gridEnt:GetVariant() == 58115310) then
            UpdatePlaceholderSprite(gridEnt);
        end
    end

    if (roomConfig.PostEnter) then
        roomConfig.PostEnter(firstVisit, cleared);
    end
end

function Bosses:SetBossConfig(name, config, roomConfigs)
    self.BossConfigs[name] = config;
    for index, room in pairs(roomConfigs.CustomRooms) do
        table.insert(self.CustomRooms, {Name = room.Name, Room = room})
    end
end

function Bosses:IsPlayingSplashSprite()
    return self.PlayingSplashSprite ~= nil;
end

function Bosses:UpdateBosses()
    -- Empty Function.
end

function Bosses:IsForceCustomBosses()
    return self.ForceCustomBoss;
end
function Bosses:SetForceCustomBosses(value)
    self.ForceCustomBoss = value;
end

local function ClearBossReplacements()
    local globalData = GetGlobalData(false);
    if (globalData and globalData.ReplacedBosses) then
        globalData.ReplacedBosses = {};
    end
end

local function GetRoomConfigForCurrent()
    if (Bosses.ReplacingRoom) then
        return Bosses.ReplacingRoom;
    end
    local game = Game();
    local level = game:GetLevel();
    local room = game:GetRoom();
    local roomDesc = level:GetCurrentRoomDesc();
    local roomType = roomDesc.Data.Type;
    -- If current room is boss room.
    if (roomType == RoomType.ROOM_BOSS) then
        
        local index = roomDesc.GridIndex;

        local globalData = GetGlobalData(false);
        local replacedBoss = nil;
        if (globalData and globalData.ReplacedBosses) then
            local roomIndex = globalData.ReplacedBosses[tostring(index)]
            if (roomIndex) then
                replacedBoss = Bosses.CustomRooms[roomIndex].Room;
            end
        end
        if (replacedBoss) then
            Bosses.ReplacingRoom = replacedBoss;
            Bosses.RemovingEntities = true;
            return replacedBoss;
        end
    end
end



local function PostNewRoom(mod)
    Bosses.ReplacingRoom = nil;
    Bosses.RemovingEntities = false;
    local replacedBoss = GetRoomConfigForCurrent();
    if (replacedBoss) then
        LoadBossRoom(replacedBoss);
    end
end
Bosses:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

local function PostNewLevel(mod)
    ClearBossReplacements();
    CreateBossReplacements();
end
Bosses:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

local function PostGameStarted(mod, isContinued)
    if (isContinued) then
        PostNewRoom(mod);
    end
end
Bosses:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);

--local IsOddFrame = nil;

local function PostRender(mod)
    
    local spr = Bosses.PlayingSplashSprite;
    if (spr) then
        local game = Game();
        local room = game:GetRoom();
        local musicID = MusicManager():GetCurrentMusicID() ;
        if (musicID == Music.MUSIC_JINGLE_BOSS or musicID == -1) then
            local width = Isaac.GetScreenWidth();
            local height = Isaac.GetScreenHeight();
            local center = Vector(width / 2, height / 2);
            --if (not IsOddFrame) then
                spr:Update();
            --end
            --spr:SetFrame(60);
            for _, layer in pairs(LayerOrders) do
                local clamp = Vector.Zero
                local offset = Vector.Zero
                if (layer == 4) then
                    offset = Bosses.BossPortraitOffset;
                end
                if (layer == 0) then
                    spr.Color = Bosses.BackgroundColor;
                end
                spr:RenderLayer(layer, center + offset, clamp, Vector.Zero);
                spr.Color = Color(1,1,1,1,0,0,0);
            end
        else
            Bosses.PlayingSplashSprite = nil;
            Bosses.BackgroundColor = Color.Default;
            Bosses.BossPortraitOffset = Vector.Zero;
            renderedObject = false;
        end
    end
end
Bosses:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender);

local function PostPlayerRender(mod, player)
    renderedObject = true;
end
Bosses:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, PostPlayerRender);

local function ExecuteCMD(mod, cmd, params)
    print(cmd);
    if (cmd == "forcethboss" or cmd=="fthb") then
        Bosses.ForceCustomBoss = not Bosses.ForceCustomBoss;
        print( "Force Touhou Bosses has been set to "..tostring(Bosses.ForceCustomBoss)..".");
    end    
end
Bosses:AddCallback(ModCallbacks.MC_EXECUTE_CMD, ExecuteCMD);

do -- Vanishing Twin
    
    local function PostNewRoom(mod)
        local replacedBoss = GetRoomConfigForCurrent();
        if (replacedBoss) then
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.VANISHING_TWIN)) do
                local familiar = ent:ToFamiliar();
                if (familiar.Coins > 0) then
                    local bossConfig = Bosses.BossConfigs[replacedBoss.BossID];
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
                local bossConfig = Bosses.BossConfigs[replacedBoss.BossID];

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