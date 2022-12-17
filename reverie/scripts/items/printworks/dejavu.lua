local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;
local Pickups = CuerLib.Pickups;
local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local Collectibles = CuerLib.Collectibles;
local Base64 = CuerLib.Base64;
local NetCoop = CuerLib.NetCoop;
local Dejavu = ModItem("Deja vu", "DEJA_VU");

local itemConfig = Isaac.GetItemConfig();
local function GetGlobalData(create)
    return Dejavu:GetGlobalData(create, function () return {
        SpawnedLoots = {},
    }end)
end


local function FindMostFitCollectible(id, name, lastName)
    
    local config = itemConfig:GetCollectible(id);
    local lastConfigName = "";
    local lastConfig = itemConfig:GetCollectible(id - 1);
    if (lastConfig) then
        lastConfigName = lastConfig.Name;
    end

    local trueID = 0;
    if (config and config.Name == name and lastConfigName == lastName) then
        return id;
    else
        local sameNameItems = {};
        local lastItemId = 0;
        for c = itemConfig:GetCollectibles().Size - 1, 1, -1 do
            local conf = itemConfig:GetCollectible(c);
            if (conf) then
                if (conf.Name == lastName) then
                    lastItemId = c;
                end

                local lastConfName = "";
                local lastConf = itemConfig:GetCollectible(c - 1);
                if (lastConf) then
                    lastConfName = lastConf.Name;
                end
                if (conf.Name == name) then
                    if (lastConfName == lastName) then
                        -- Found the collectible.
                        return c;
                    else
                        table.insert(sameNameItems, c);
                    end
                end
            end
        end
        
        -- Fallback.
        if (#sameNameItems == 1) then
            return sameNameItems[1]
        elseif (#sameNameItems > 1) then
            -- Multiple Items, find the nearest item of last name.
            if (lastItemId > 0) then
                local nearest = nil;
                for _, c in pairs(sameNameItems) do
                    if (not nearest or c - lastItemId > nearest - lastItemId) then
                        nearest = c;
                    end
                end
                return nearest;
            else
                return sameNameItems[1];
            end
        else
            -- No Item called this name
            return CollectibleType.COLLECTIBLE_UNDEFINED;
        end
    end
    return nil;
end

Dejavu.CustomPlayerGfx = {
    ["Eika"] = "gfx/reverie/effects/corpses/eika.png",
    ["Tainted Eika"] = "gfx/reverie/effects/corpses/eika_b.png",
    ["Satori"] = "gfx/reverie/effects/corpses/satori.png",
    ["Tainted Satori"] = "gfx/reverie/effects/corpses/satori_b.png",
    ["Seija"] = "gfx/reverie/effects/corpses/seija.png",
    ["Tainted Seija"] = "gfx/reverie/effects/corpses/seija_b.png",
}
function Dejavu:SetCustomPlayerGfx(playerName, gfx)
    self.CustomPlayerGfx[playerName] = gfx;
end



function Dejavu:SpawnCorpse(data)
    local game = Game();
    local room = game:GetRoom();
    local Corpse = THI.Effects.DejavuCorpse;
    local corpse = Isaac.Spawn(Corpse.Type, Corpse.Variant, 0, Vector(data.X, data.Y), Vector.Zero, nil);
    local spr = corpse:GetSprite()
    local flyAnim = (data.Generated and "GenFly") or "Fly";
    if (data.PlayerType <= 40) then
        spr:SetFrame("Players", data.PlayerType)
    else
        spr:SetFrame("ModPlayer", 0)
        local gfx = self.CustomPlayerGfx[data.PlayerName];
        if (gfx) then
            spr:ReplaceSpritesheet(0, gfx);
            spr:LoadGraphics();
        end
    end
    spr:PlayOverlay(flyAnim);
    return corpse;
end

function Dejavu:SpawnCorpseLoots(data, corpse, index)
    local game = Game();
    local room = game:GetRoom();
    local pos = Vector(data.X, data.Y - 40);
    local globalData = GetGlobalData(true);
    globalData.SpawnedLoots = globalData.SpawnedLoots or {};

    local uniqueOptionsIndex = Pickups:GetUniqueOptionsIndex();

    for _, id in pairs(data.Items) do
        if (id > 0 and itemConfig:GetCollectible(id)) then
            local item = Pickups:SpawnFixedCollectible(id, room:FindFreePickupSpawnPosition(pos), Vector.Zero, corpse):ToPickup();
            item:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);
            item.OptionsPickupIndex = uniqueOptionsIndex;
        end
    end
    if (#data.Items > 0) then
        table.insert(globalData.SpawnedLoots, index);
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
    local function filter(id, config, num)
        if (config:HasTags(ItemConfig.TAG_QUEST) or config.Hidden) then
            return 0;
        end
        return num;
    end
    local collectibleList, collectibleCount = Collectibles:GetPlayerCollectibles(player, filter);

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

do -- Generation.
    local PlayerTypeList = {}
    for i = 0, 40 do
        if (i ~= PlayerType.PLAYER_LAZARUS and i ~= PlayerType.PLAYER_ESAU and i ~= PlayerType.PLAYER_THESOUL_B) then
            table.insert(PlayerTypeList, i);
        end
    end
    local PlayerActiveList = {
        [PlayerType.PLAYER_ISAAC] = CollectibleType.COLLECTIBLE_D6,
        [PlayerType.PLAYER_MAGDALENA] = CollectibleType.COLLECTIBLE_YUM_HEART,
        [PlayerType.PLAYER_BLUEBABY] = CollectibleType.COLLECTIBLE_POOP,
        [PlayerType.PLAYER_JUDAS] = CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
        [PlayerType.PLAYER_EVE] = CollectibleType.COLLECTIBLE_RAZOR_BLADE,
        [PlayerType.PLAYER_THELOST] = CollectibleType.COLLECTIBLE_ETERNAL_D6,
        [PlayerType.PLAYER_LILITH] = CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS,
        [PlayerType.PLAYER_KEEPER] = CollectibleType.COLLECTIBLE_WOODEN_NICKEL,
        [PlayerType.PLAYER_APOLLYON] = CollectibleType.COLLECTIBLE_VOID,
    }
    local PlayerPassives = {
        [PlayerType.PLAYER_CAIN] = {CollectibleType.COLLECTIBLE_LUCKY_FOOT},
        [PlayerType.PLAYER_EVE] = {CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, CollectibleType.COLLECTIBLE_DEAD_BIRD},
        [PlayerType.PLAYER_SAMSON] = {CollectibleType.COLLECTIBLE_BLOODY_LUST},
        [PlayerType.PLAYER_LAZARUS] = {CollectibleType.COLLECTIBLE_ANEMIC},
        [PlayerType.PLAYER_LAZARUS2] = {CollectibleType.COLLECTIBLE_ANEMIC},
        [PlayerType.PLAYER_LILITH] = {CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION},
        [PlayerType.PLAYER_BETHANY] = {CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES},
        [PlayerType.PLAYER_MAGDALENA_B] = {CollectibleType.COLLECTIBLE_YUM_HEART},
        [PlayerType.PLAYER_CAIN_B] = {CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING},
        [PlayerType.PLAYER_JUDAS_B] = {CollectibleType.COLLECTIBLE_DARK_ARTS},
        [PlayerType.PLAYER_EVE_B] = {CollectibleType.COLLECTIBLE_SUMPTORIUM},
        [PlayerType.PLAYER_LAZARUS_B] = {CollectibleType.COLLECTIBLE_FLIP},
        [PlayerType.PLAYER_LAZARUS2_B] = {CollectibleType.COLLECTIBLE_FLIP},
        [PlayerType.PLAYER_APOLLYON_B] = {CollectibleType.COLLECTIBLE_ABYSS},
        [PlayerType.PLAYER_BETHANY_B] = {CollectibleType.COLLECTIBLE_LEMEGETON},
        [PlayerType.PLAYER_JACOB_B] = {CollectibleType.COLLECTIBLE_ANIMA_SOLA},
        [PlayerType.PLAYER_JACOB2_B] = {CollectibleType.COLLECTIBLE_ANIMA_SOLA},
    }
    local Items = {};
    local function GetItemConfigs()
        local size = itemConfig:GetCollectibles().Size;
        for i = 1, size do
            local config = itemConfig:GetCollectible(i);
            if (config and not config:HasTags(ItemConfig.TAG_QUEST) and not config.Hidden) then
                Items[i] = config;
            end
        end
    end
    GetItemConfigs();
    
    local function GetRandomPlayerType(seed)
        local random = seed % #PlayerTypeList;
        return PlayerTypeList[random + 1];
    end
    local function GetRandomCollectibles(playerType, seed)
        -- Tainted Forgotten's Soul has no items.
        if (playerType == PlayerType.PLAYER_THESOUL_B) then
            return {};
        else
            local game = Game();
            local rng = RNG();
            local maxCount = 3;
            rng:SetSeed(seed, Dejavu.Item);
            local level = game:GetLevel();
            local active = PlayerActiveList[playerType] or 0;
            local activeConfig = itemConfig:GetCollectible(active)
            local activeQuality = (activeConfig and activeConfig.Quality) or -1; 
            local totalItemCount = ((level:GetStage() - 1) * 2) + 1;
            local itemCount = math.min(totalItemCount, maxCount);
            local count = 0;

            -- Weights.
            local totalWeight = 0

            local function GetConfigWeight(config)
                local weight = 1;
                if (playerType == PlayerType.PLAYER_THELOST_B) then
                    -- Tainted Lost has better items.
                    if (not config:HasTags(ItemConfig.TAG_OFFENSIVE)) then
                        return 0;
                    end
                    if (config.Quality == 0) then
                        weight = 0.4;
                    elseif (config.Quality == 1) then
                        weight = 0.8
                    elseif (config.Quality == 4) then
                        weight = 0.1;
                    end
                else
                    if (config.Quality == 0 or config.Quality == 3) then
                        weight = 0.5;
                    elseif (config.Quality == 4) then
                        weight = 0.1;
                    end
                end
                return weight;
            end

            for i, config in pairs(Items) do
                totalWeight = totalWeight + GetConfigWeight(config);
            end

            -- Get Random Collectibles.
            local items = {};

            while(count < itemCount) do
                local randomValue = rng:RandomFloat() * totalWeight;
                for i, config in pairs(Items) do
                    randomValue = randomValue - GetConfigWeight(config);
                    if (randomValue <= 0) then
                        if (config.Type == ItemType.ITEM_ACTIVE) then
                            -- If new active's quality is larger than the item.
                            if (activeQuality <= config.Quality) then
                                active = i;
                                activeQuality = config.Quality;
                            end
                        else
                            -- Passive Item.
                            table.insert(items, i);
                            count = count + 1;
                        end
                        break;
                    end
                end
            end

            -- Replace the first passive item with active item.
            local index = 1;
            if (activeQuality >= 0 and rng:RandomFloat() <= maxCount / totalItemCount) then
                if (#items < maxCount) then
                    table.insert(items, active);
                else
                    items[index] = active
                    index = index + 1;
                end
            end
            local passives = PlayerPassives[playerType];
            if (passives) then
                for i = 1, #passives do
                    if (rng:RandomFloat() <= maxCount / (totalItemCount + #passives)) then
                        local passive = passives[i];
                        if (#items < maxCount) then
                            table.insert(items, passive);
                        else
                            items[index] = passive;
                            index = index + 1;
                        end
                    end
                end
            end
            return items;
        end
    end

    function Dejavu:GenerateCorpse(seed, playerType)
        local game = Game();
        local level = game:GetLevel();
        local room = game:GetRoom();
        local roomType = room:GetType();
        if (level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
            roomType = 0;
        end

        local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(20));
        playerType = playerType or GetRandomPlayerType(seed);
        local randomItems = GetRandomCollectibles(playerType, seed);
        return {
            Stage = level:GetStage(),
            StageType = level:GetStageType(),
            RoomType = roomType,
            RoomVariant = level:GetCurrentRoomDesc().Data.Variant,
            PlayerType = playerType,
            PlayerName = "",
            X = pos.X,
            Y = pos.Y,
            Items = randomItems,
            Generated = true,
            GreedMode = game:IsGreedMode()
        };
    end
end

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
        PlayerName = (player:GetPlayerType() <= 40 and "") or player:GetName(),
        X = player.Position.X,
        Y = player.Position.Y,
        Items = randomItems,
        Generated = false,
        GreedMode = game:IsGreedMode()
    };
end

do -- Encoding && Decoding.
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

    local stageMask = 0xF0000000;
    local stageTypeMask = 0x0F000000;
    local roomMask = 0x00FF0000;
    local playerMask = 0x0000FFFF;

    local roomVariantMask = 0xFFFFFFFF;

    local posXMask = 0xFFFF0000;
    local posYMask = 0x0000FFFF;
    -- Obsoleted.
    function Dejavu:EncodeDataV1(data)

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
        
        local items = {};
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
    -- Obsoleted.
    function Dejavu:EncodeDataV14(data)
        local charSet = "";
        local function AddBytes(value, byteLength)
            byteLength = byteLength or 1;
            for i = byteLength, 1, -1 do
                local offset = (i - 1) * 8
                charSet = charSet..string.char((value >> offset) & 0xFF);
            end
        end
        -- Version.
        AddBytes(14, 1);
        --当前层数（4位0-15）
        --层类型（4位0-15）
        --房间类型（8位0-255）
        --玩家类型（16位）
        AddBytes(data.Stage, 1);
        AddBytes(data.StageType, 1);
        AddBytes(data.RoomType, 2);
        AddBytes(data.PlayerType, 2);

        --房间变种（32位）
        AddBytes(data.RoomVariant, 4);
        
        --死亡位置X值（16位）
        --死亡位置Y值（16位）
        AddBytes(math.floor(data.X), 2);
        AddBytes(math.floor(data.Y), 2);
        
        --3个随机道具（32位x3=96位）
        
        AddBytes(#data.Items, 1);
        local items = {};
        for _, id in ipairs(data.Items) do
            local config = itemConfig:GetCollectible(id)
            local name = "";
            local lastName = "";
            if (config) then
                name = config.Name;
            end
            local lastConfig = itemConfig:GetCollectible(id - 1);
            if (lastConfig) then
                lastName = lastConfig.Name;
            end
            
            AddBytes(id, 4);
            AddBytes(string.len(name), 1);
            charSet = charSet..name;
            AddBytes(string.len(lastName), 1);
            charSet = charSet..lastName;
        end

        return Base64.Encode(charSet);
    end
    function Dejavu:EncodeDataV2(data)
        local charSet = "";
        local function AddBytes(value, byteLength)
            byteLength = byteLength or 1;
            for i = byteLength, 1, -1 do
                local offset = (i - 1) * 8
                charSet = charSet..string.char((value >> offset) & 0xFF);
            end
        end
        -- Version.
        AddBytes(2, 1);
        --当前层数（4位0-15）
        --层类型（4位0-15）
        --房间类型（8位0-255）
        --玩家类型（16位）
        AddBytes(data.Stage, 1);
        AddBytes(data.StageType, 1);
        AddBytes(data.RoomType, 2);
        AddBytes(data.PlayerType, 2);
        AddBytes(string.len(data.PlayerName), 1);
        charSet = charSet..data.PlayerName;

        --房间变种（32位）
        AddBytes(data.RoomVariant, 4);
        
        --死亡位置X值（16位）
        --死亡位置Y值（16位）
        AddBytes(math.floor(data.X), 2);
        AddBytes(math.floor(data.Y), 2);
        
        --3个随机道具（32位x3=96位）
        
        AddBytes(#data.Items, 1);
        local items = {};
        for _, id in ipairs(data.Items) do
            local config = itemConfig:GetCollectible(id)
            local name = "";
            local lastName = "";
            if (config) then
                name = config.Name;
            end
            local lastConfig = itemConfig:GetCollectible(id - 1);
            if (lastConfig) then
                lastName = lastConfig.Name;
            end
            
            AddBytes(id, 4);
            AddBytes(string.len(name), 1);
            charSet = charSet..name;
            AddBytes(string.len(lastName), 1);
            charSet = charSet..lastName;
        end

        AddBytes((data.Generated and 1) or 0, 1);
        AddBytes((data.GreedMode and 1) or 0, 1);
        return Base64.Encode(charSet);
    end
    -- Obsoleted.
    function Dejavu:DecodeDataV1(str)

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
        data.Generated = false;
        data.GreedMode = false;
        return data;
    end
    -- Obsoleted.
    function Dejavu:DecodeDataV14(str)

        local decoded = Base64.Decode(str);
        local decoding = decoded;
        local function ReadBytes(byteLength)
            local value = 0;
            for i = byteLength, 1, -1 do
                local offset = (i - 1) * 8;
                value = value | (string.byte(decoding, 1, 1) << offset);
                decoding = string.sub(decoding, 2);
            end
            return value;
        end

        local version = ReadBytes(1);

        local data = {};
        data.Stage = ReadBytes(1);
        data.StageType = ReadBytes(1);
        data.RoomType = ReadBytes(2);
        data.PlayerType = ReadBytes(2);

        data.RoomVariant = ReadBytes(4);
        
        data.X = ReadBytes(2);
        data.Y = ReadBytes(2);
        
        local count = ReadBytes(1);
        data.Items = {};
        --3个随机道具（32位x3=96位）
        for i = 1, count do
            local id = ReadBytes(4);
            local nameLength = ReadBytes(1);
            local name = string.sub(decoding, 1, nameLength);
            decoding = string.sub(decoding, 1 + nameLength);
            local lastNameLength = ReadBytes(1);
            local lastName = string.sub(decoding, 1, lastNameLength);
            decoding = string.sub(decoding, 1 + lastNameLength);

            data.Items[i] = FindMostFitCollectible(id, name, lastName);
        end
        data.Generated = false;
        data.GreedMode = false;
        return data;
    end
    function Dejavu:DecodeDataV2(str)

        local decoded = Base64.Decode(str);
        local function ReadBytes(byteLength)
            local value = 0;
            for i = byteLength, 1, -1 do
                local offset = (i - 1) * 8;
                value = value | (string.byte(decoded, 1, 1) << offset);
                decoded = string.sub(decoded, 2);
            end
            return value;
        end
        local function ReadString(length)
            local str = string.sub(decoded, 1, length);
            decoded = string.sub(decoded, 1 + length);
            return str
        end

        local version = ReadBytes(1);

        local data = {};
        data.Stage = ReadBytes(1);
        data.StageType = ReadBytes(1);
        data.RoomType = ReadBytes(2);
        data.PlayerType = ReadBytes(2);
        local playerNameLength = ReadBytes(1);
        data.PlayerName = ReadString(playerNameLength);

        data.RoomVariant = ReadBytes(4);
        
        data.X = ReadBytes(2);
        data.Y = ReadBytes(2);
        
        local count = ReadBytes(1);
        data.Items = {};
        --3个随机道具（32位x3=96位）
        for i = 1, count do
            local id = ReadBytes(4);
            local nameLength = ReadBytes(1);
            local name = ReadString(nameLength);
            local lastNameLength = ReadBytes(1);
            local lastName = ReadString(lastNameLength);

            data.Items[i] = FindMostFitCollectible(id, name, lastName);
        end
        data.Generated = ReadBytes(1) > 0;
        data.GreedMode = ReadBytes(1) > 0;
        return data;
    end
    function Dejavu:EncodeData(data)
        return self:EncodeDataV2(data)
    end

    function Dejavu:DecodeData(str)
        local b64value1 = Dejavu.RevCharMap[string.sub(str, 1, 1)] - 1;
        local b64value2 = Dejavu.RevCharMap[string.sub(str, 2, 2)] - 1;
        local version = (b64value1 << 6 | b64value2) >> 4;
        local data;
        if (version >= 16) then
            -- V1.
            data = self:DecodeDataV1(str)
        elseif (version == 14) then
            -- V14
            data = self:DecodeDataV14(str)
        else
            -- V2.
            data = self:DecodeDataV2(str)
        end
        return data, version;
    end
end


local corpseDatas = nil;
function Dejavu:AddCorpse(corpseData)
    local persistentData = SaveAndLoad:ReadPersistentData();
    persistentData.Dejavu = persistentData.Dejavu or {};
    local data = persistentData.Dejavu;
    if (#data > 256) then
        table.remove(data, 0);
        local globalData = GetGlobalData(false);
        if (globalData and globalData.SpawnedLoots) then
            for i, index in pairs(globalData.SpawnedLoots) do
                globalData.SpawnedLoots[i] = index - 1;
            end
        end
    end

    local str = self:EncodeData(corpseData);
    local duplicated = false;
    for _, entry in ipairs(data) do
        if (str == entry) then
            duplicated = true;
            break;
        end
    end

    if (not duplicated) then
        table.insert(data, str);
        SaveAndLoad:WritePersistentData(persistentData);
    end
end


function Dejavu:PostGameEnd(gameOver)
    if (gameOver) then
        local game = Game();
        local seeds = game:GetSeeds();
        if (not seeds:IsCustomRun() and not NetCoop.IsNetCoop()) then
            for p, player in Players.PlayerPairs() do
                local corpseData = self:GetCorpseData(player, seeds:GetStartSeed());
                Dejavu:AddCorpse(corpseData)
            end
        end
    end
end
Dejavu:AddCallback(ModCallbacks.MC_POST_GAME_END, Dejavu.PostGameEnd)

local RoomTypeChance = {
    [RoomType.ROOM_ANGEL] = 5,
    [RoomType.ROOM_BLACK_MARKET] = 10,
    [RoomType.ROOM_BLUE] = 10,
    [RoomType.ROOM_BOSS] = 10,
    [RoomType.ROOM_BOSSRUSH] = 20,
    [RoomType.ROOM_CHALLENGE] = 10,
    [RoomType.ROOM_CURSE] = 10,
    [RoomType.ROOM_DEVIL] = 10,
    [RoomType.ROOM_MINIBOSS] = 10,
    [RoomType.ROOM_SACRIFICE] = 10,

    [RoomType.ROOM_DEFAULT] = 1,
}
function Dejavu:GenerateRoomCorpses()
    local game = Game();
    local seeds = game:GetSeeds();
    local room = game:GetRoom();
    if (room:IsFirstVisit() and not seeds:IsCustomRun() and not NetCoop.IsNetCoop() and Collectibles:IsAnyHasCollectible(self.Item)) then
        local globalData = GetGlobalData(false);
        if (globalData and globalData.SpawnedLoots and #globalData.SpawnedLoots >= 3) then
            return;
        end
        local roomType = room:GetType()
        local chance = RoomTypeChance[roomType];
        if (roomType == RoomType.ROOM_DEFAULT and room:IsClear()) then
            chance = 0;
        end
        if (chance) then
            local rng = RNG();
            rng:SetSeed(room:GetSpawnSeed(), Dejavu.Item);
            if (rng:RandomInt(100) < chance) then
                corpseDatas = corpseDatas or {};
                local corpseData = Dejavu:GenerateCorpse(rng:Next());
                if (corpseData.PlayerType == PlayerType.PLAYER_JACOB) then
                    local esauData = Dejavu:GenerateCorpse(rng:Next(), PlayerType.PLAYER_ESAU);
                    table.insert(corpseDatas, esauData);
                elseif (corpseData.PlayerType == PlayerType.PLAYER_THEFORGOTTEN_B) then
                    local soulBData = Dejavu:GenerateCorpse(rng:Next(), PlayerType.PLAYER_THESOUL_B);
                    table.insert(corpseDatas, soulBData);
                end
                table.insert(corpseDatas, corpseData);
            end
        end
    end
end

function Dejavu:SpawnRoomCorpses()
    local game = Game();
    local seeds = game:GetSeeds();
    if (corpseDatas and not seeds:IsCustomRun() and not NetCoop.IsNetCoop() and Collectibles:IsAnyHasCollectible(self.Item)) then
        local level = game:GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        local roomType = roomDesc.Data.Type; 
        if (level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
            roomType = 0;
        end
        local roomVariant = roomDesc.Data.Variant; 
        for index, data in ipairs(corpseDatas) do
            local roomFits = data.RoomType == roomType and data.RoomVariant == roomVariant;
            local stageFits = true
            if (roomType <= 1) then
                stageFits = data.Stage == level:GetStage() and data.StageType == level:GetStageType();
            end
            if (stageFits and roomFits and (not not data.GreedMode) == game:IsGreedMode()) then
                local corpse = self:SpawnCorpse(data);
                if (self:ShouldCorpseSpawnItems(index)) then
                    Dejavu:SpawnCorpseLoots(data, corpse, index);
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
        local modified = false;
        for i, data in ipairs(persistentData.Dejavu) do
            local corpseData, version = self:DecodeData(data);
            corpseDatas[i] = corpseData;
            if (version >= 14) then
                persistentData.Dejavu[i] = self:EncodeData(corpseData);
                modified = true;
            end
        end
        if (modified) then
            SaveAndLoad:WritePersistentData(persistentData);
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
    -- Generate Random Corpse.
    self:GenerateRoomCorpses();
    self:SpawnRoomCorpses();
end
Dejavu:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dejavu.PostNewRoom)

return Dejavu;