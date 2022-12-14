local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;
local Pickups = CuerLib.Pickups;
local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local Collectibles = CuerLib.Collectibles;
local Dejavu = ModItem("Deja vu", "DEJA_VU");

local itemConfig = Isaac.GetItemConfig();
local function GetGlobalData(create)
    return Dejavu:GetGlobalData(create, function () return {
        SpawnedLoots = {},
    }end)
end


function Dejavu:SpawnCorpse(data)
    local game = Game();
    local room = game:GetRoom();
    local Corpse = THI.Effects.DejavuCorpse;
    return Isaac.Spawn(Corpse.Type, Corpse.Variant, 0, Vector(data.X, data.Y), Vector.Zero, nil);
end
function Dejavu:SpawnCorpseLoots(data, corpse, index)
    local game = Game();
    local room = game:GetRoom();
    local pos = Vector(data.X, data.Y);
    local globalData = GetGlobalData(true);
    globalData.SpawnedLoots = globalData.SpawnedLoots or {};

    local uniqueOptionsIndex = Pickups:GetUniqueOptionsIndex();

    for i = 1, 3 do
        local id = data.Items[i]
        if (id > 0 and itemConfig:GetCollectible(id)) then
            local item = Pickups:SpawnFixedCollectible(id, room:FindFreePickupSpawnPosition(pos), Vector.Zero, corpse):ToPickup();
            item:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);
            item.OptionsPickupIndex = uniqueOptionsIndex;
            table.insert(globalData.SpawnedLoots, index);
        end
    end
end
function Dejavu:ShouldCorpseSpawnItems(index)
    local globalData = GetGlobalData(false);
    if (globalData) then
        if (#globalData.SpawnedLoots >= 3) then
            return false;
        else
            for _, i in ipairs(globalData.SpawnedLoots) do
                if (i == index) then
                    return false;
                end
            end
        end
    end
    return true;
end

function Dejavu:GetRandomPlayerCollectibles(player, seed, count)
    local collectibleList = {};
    local collectibleCount = 0;
    for i = 1, THI.MaxCollectibleID do
        local config = itemConfig:GetCollectible(i);
        if (config) then
            if (not config:HasTags(ItemConfig.TAG_QUEST) and not config.Hidden) then
                local collectibleNum = player:GetCollectibleNum(i, true);
                if (collectibleNum > 0) then
                    collectibleList[i] = collectibleNum;
                    collectibleCount = collectibleCount + collectibleNum;
                end
            end
        end
    end

    local rng = RNG();
    rng:SetSeed(seed, Dejavu.Item);
    local results = {};
    for i = 1, count do
        local value = rng:RandomInt(collectibleCount) + 1;
        for id, num in pairs(collectibleList) do
            value = value - 1;
            if (value <= 0) then
                collectibleList[id] = num - 1;
                if (num <= 1) then
                    collectibleList[id] = nil;
                end
                collectibleCount = collectibleCount - 1;
                table.insert(results, id);
                break;
            end
        end
    end
    return results;
end

local stageMask = 0xF0000000;
local stageTypeMask = 0x0F000000;
local roomMask = 0x00FF0000;
local playerMask = 0x0000FFFF;

local roomVariantMask = 0xFFFFFFFF;

local posXMask = 0xFFFF0000;
local posYMask = 0x0000FFFF;

function Dejavu:GetCorpseData(player, seed)
    local game = Game();
    local level = game:GetLevel();
    local room = game:GetRoom();
    local roomType = room:GetType();
    if (level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
        roomType = 0;
    end

    local randomItems = Dejavu:GetRandomPlayerCollectibles(player, seed, 3);
    return {
        Stage = level:GetStage(),
        StageType = level:GetStageType(),
        RoomType = roomType,
        RoomVariant = level:GetCurrentRoomDesc().Data.Variant,
        PlayerType = player:GetPlayerType(),
        X = player.Position.X,
        Y = player.Position.Y,
        Items = randomItems;
    };
end

Dejavu.CharMap = {
    [1] = 'A', [2] = 'B', [3] = 'C', [4] = 'D', [5] = 'E', [6] = 'F', [7] = 'G', [8] = 'H', 
    [9] = 'I', [10] = 'J', [11] = 'K', [12] = 'L', [13] = 'M', [14] = 'N', [15] = 'O', [16] = 'P',
    [17] = 'Q', [18] = 'R', [19] = 'S', [20] = 'T', [21] = 'U', [22] = 'V', [23] = 'W', [24] = 'X',
    [25] = 'Y', [26] = 'Z', [27] = 'a', [28] = 'b', [29] = 'c', [30] = 'd', [31] = 'e', [32] = 'f',
    [33] = 'g', [34] = 'h', [35] = 'i', [36] = 'j', [37] = 'k', [38] = 'l', [39] = 'm', [40] = 'n',
    [41] = 'o', [42] = 'p', [43] = 'q', [44] = 'r', [45] = 's', [46] = 't', [47] = 'u', [48] = 'v',
    [49] = 'w', [50] = 'x', [51] = 'y', [52] = 'z', [53] = '0', [54] = '1', [55] = '2', [56] = '3',
    [57] = '4', [58] = '5', [59] = '6', [60] = '7', [61] = '8', [62] = '9', [63] = '+', [64] = '=',
}
Dejavu.RevCharMap = {};
for k,v in pairs(Dejavu.CharMap) do
    Dejavu.RevCharMap[v] = k;
end

function Dejavu:EncodeData(data)

    local intList = {};
    --当前层数（4位0-15）
    --层类型（4位0-15）
    --房间类型（8位0-255）
    --玩家类型（16位）
    intList[1] = (data.Stage << 28 & stageMask) | 
    (data.StageType << 24 & stageTypeMask) | 
    (data.RoomType << 16 & roomMask) | 
    (data.PlayerType & playerMask); 

    --房间变种（32位）
    intList[2] = data.RoomVariant & roomVariantMask;
     
    --死亡位置X值（16位）
    --死亡位置Y值（16位）
    intList[3] = (math.floor(data.X) << 16 & posXMask) | 
    (math.floor(data.Y) & posYMask);
    
    --3个随机道具（32位x3=96位）
    for i = 1, #data.Items do
        intList[i + 3] = data.Items[i]; 
    end
    local str = "";
    local bits = 192;
    local bufferBits = 0;
    local intIndex = 1;
    local intOffset = 31;
    for char = 1, 32 do
        local buffer = 0;
        for i = 1, 6 do
            buffer = buffer << 1 | (((intList[intIndex] or 0) >> intOffset) & 1)
            intOffset = intOffset - 1;
            if (intOffset < 0) then
                intIndex = intIndex + 1;
                intOffset = 31;
            end
        end
        str = str..self.CharMap[buffer + 1];
    end
    return str;
end

function Dejavu:DecodeData(str)

    local intList = {};
    local intOffset = 32;
    local buffer = 0;
    for c = 1, string.len(str) do
        local char = string.sub(str, c,c);
        local charValue = Dejavu.RevCharMap[char] - 1;
        intOffset = intOffset - 6;
        if (intOffset < 0) then
            buffer = buffer | (charValue >> -intOffset);
            table.insert(intList, buffer);
            intOffset = 32 + intOffset;
            buffer = 0;
        end
        buffer = buffer | ((charValue << intOffset) & 0xFFFFFFFF)
    end
    table.insert(intList, buffer);

    local data = {};
    data.Stage = (intList[1] & stageMask) >> 28;
    data.StageType = (intList[1] & stageTypeMask) >> 24;
    data.RoomType = (intList[1] & roomMask) >> 16;
    data.PlayerType = intList[1] & playerMask;

    data.RoomVariant = intList[2] & roomVariantMask;
     
    data.X = (intList[3] & posXMask) >> 16
    data.Y = intList[3] & posYMask;
    
    data.Items = {};
    --3个随机道具（32位x3=96位）
    for i = 4, #intList do
        data.Items[i - 3]  = intList[i];
    end
    return data;
end

function Dejavu:PostGameEnd(gameOver)
    if (gameOver) then
        local game = Game();
        local seeds = game:GetSeeds();
        if (not seeds:IsCustomRun()) then
            local persistentData = SaveAndLoad:ReadPersistentData();
            persistentData.Dejavu = persistentData.Dejavu or {};
            local data = persistentData.Dejavu;
            for p, player in Players.PlayerPairs() do
                if (#data > 256) then
                    table.remove(data, 0);
                end
                local corpseData = self:GetCorpseData(player, seeds:GetStartSeed());
                local str = self:EncodeData(corpseData);
                table.insert(data, str);
            end
            SaveAndLoad:WritePersistentData(persistentData);
        end
    end
end
Dejavu:AddCallback(ModCallbacks.MC_POST_GAME_END, Dejavu.PostGameEnd)


local corpseDatas = nil;

function Dejavu:SpawnRoomCorpses()
    if (corpseDatas and Collectibles.IsAnyHasCollectible(self.Item)) then
        local game = Game();
        local level = game:GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        local roomType = roomDesc.Data.Type; 
        if (level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
            roomType = 0;
        end
        local roomVariant = roomDesc.Data.Variant; 
        for i, data in ipairs(corpseDatas) do
            if (data.Stage == level:GetStage() and data.StageType == level:GetStageType() and data.RoomType == roomType and data.RoomVariant == roomVariant) then
                local corpse = self:SpawnCorpse(data);
                if (self:ShouldCorpseSpawnItems(i)) then
                    Dejavu:SpawnCorpseLoots(data, corpse, i);
                end
            end
        end
    end
end

function Dejavu:PostGameStarted(isContinued)
    corpseDatas = nil;
    local persistentData = SaveAndLoad:ReadPersistentData();
    if (persistentData.Dejavu) then
        corpseDatas = {};
        for i, data in ipairs(persistentData.Dejavu) do
            corpseDatas[i] = self:DecodeData(data);
        end
    end
    self:SpawnRoomCorpses();
end
Dejavu:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Dejavu.PostGameStarted)

function Dejavu:PreGameExit(shouldSave)
    corpseDatas = nil;
end
Dejavu:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Dejavu.PreGameExit)

function Dejavu:PostNewRoom()
    self:SpawnRoomCorpses();
end
Dejavu:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dejavu.PostNewRoom)

return Dejavu;