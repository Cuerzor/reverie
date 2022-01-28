local Lib = CuerLib;
local Rooms = Lib.Rooms;

local Bosses = {
    CustomRooms = {

    },
    BossConfigs = {

    },
    SplashSprite = Sprite(),
    PlayingSplashSprite = nil,
    BackgroundColor = Color.Default,
    ForceCustomBoss = false
}
local ReplacingGridConfig = nil;

local LayerOrders = {
    0, 1, 2, 9, 14, 13, 4, 5, 12, 11, 7, 8, 10, 15
}
Bosses.SplashSprite.PlaybackSpeed = 0.4978;
Bosses.SplashSprite:Load("gfx/ui/boss/cuerlib_versusscreen.anm2", true);



Bosses.BossRoomType = {
    NO_BOSS_ROOM = 0,
    NORMAL = 1,
    FIRST_IN_LABYRINTH = 2,
    SECOND_IN_LABYRINTH = 3
}

local renderedObject = false;

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
    local data = Lib:GetModGlobalData();
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
        for name, roomConfig in pairs(Bosses.CustomRooms) do
            local bossID = roomConfig.BossID;
            if (not blacklist[tostring(bossID)]) then
                -- If current room fits.
                if (IsRoomFits(currentBossRoom.Index, currentBossRoom.Type, roomConfig)) then
                    local bossID = roomConfig.BossID;
                    local bossConfig = Bosses.BossConfigs[bossID];
                    local encountered = true;
                    if (bossConfig) then
                        encountered = game:HasEncounteredBoss (bossConfig.Type, bossConfig.Variant);
                    end
                    if (not encountered) then
                        local value = rng:RandomInt(100);
                        if (value < roomConfig.ReplaceChance or Bosses.ForceCustomBoss) then
                            table.insert(selectedList, name);
                        end
                    end
                end
            end
        end
        -- Select a random room config.
        if (#selectedList > 0) then
            local selectedIndex = rng:RandomInt(#selectedList) + 1;
            local selectedName = selectedList[selectedIndex]
            globalData.ReplacedBosses[tostring(currentBossRoom.Index)] = selectedName;
            local roomConfig = Bosses.CustomRooms[selectedName];
            local bossID = roomConfig.BossID;
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
    for n, room in pairs(roomConfigs.CustomRooms) do
        self.CustomRooms[n] = room;
    end
end

function Bosses:IsPlayingSplashSprite()
    return self.PlayingSplashSprite ~= nil;
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
            local name = globalData.ReplacedBosses[tostring(index)]
            if (name) then
                replacedBoss = Bosses.CustomRooms[name];
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

local function PostNewLevel(mod)
    ClearBossReplacements();
    CreateBossReplacements();
end
local function PostGameStarted(mod, isContinued)
    if (isContinued) then
        PostNewRoom(mod);
    end
end

--local IsOddFrame = nil;

local function PostRender(mod)
    
    --IsOddFrame = not IsOddFrame;
    local spr = Bosses.PlayingSplashSprite;
    -- for i = 1, 20000 do
    --     print("       ");
    -- end
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
                    -- function FindColor() 
                    --     for tint = 0.2, 0.03, -0.001 do
                    --         for offset = -1, 1, 0.01 do
                    --         --while (red > 0 or green > 0 or blue > 0) do
                    --             --offset = offset - 0.001;
                    --             spr.Color = Color(tint,tint,tint,1,offset, offset, offset);
                    --             local col = spr:GetTexel(Vector(0,0), Vector.Zero, 1, layer)
                    --             local bottomCol = spr:GetTexel(Vector(0,220), Vector.Zero, 1, layer)
                    --             local red = 1;
                    --             local blue = 1;
                    --             red = col.Red;
                    --             blue = col.Blue;
                    --             local bottomRed = bottomCol.Red;
                    --             local bottomBlue = bottomCol.Blue;
                    --             if (math.abs(red - 0.048) <= 0.001 and math.abs(bottomRed - 0.092) <= 0.002) then
                    --                 print("Red & Green", red, bottomRed, tint, offset);
                    --             end
                    --             if (math.abs(blue - 0.05) <= 0.001 and math.abs(bottomBlue - 0.097) <= 0.002) then
                    --                 print("Blue", blue, bottomBlue, tint, offset);
                    --             end
                    --         --end
                    --         end
                    --     end
                    -- end

                    -- function GetColors(maxX, maxY) 
                    --     for x = 0, maxX do
                    --         for y = 0, maxY do
                    --             local col = spr:GetTexel(Vector(x,y), Vector.Zero, 1, layer)
                    --             print(col.Red);
                    --         end
                    --     end
                    -- end
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
local function PostPlayerRender(mod, player)
    renderedObject = true;
end
local function ExecuteCMD(mod, cmd, params)
    if (cmd == "forcethboss" or cmd=="fthb") then
        Bosses.ForceCustomBoss = not Bosses.ForceCustomBoss;
        print( "Force Touhou Bosses has been set to "..tostring(Bosses.ForceCustomBoss)..".");
    end    
end
function Bosses:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender);
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, PostPlayerRender);
    mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, ExecuteCMD);
end

return Bosses;