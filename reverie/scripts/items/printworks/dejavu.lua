local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;
local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local Dejavu = ModItem("Dejavu", "DEJAVU");

local function GetGlobalData(create)
    return Dejavu:GetGlobalData(create, function () return {
        SpawnedLootCount = 0,
    }end)
end


function Dejavu:SpawnCorpse(data)
    local game = Game();
    local room = game:GetRoom();
    local Corpse = THI.Effects.DejavuCorpse;
    Isaac.Spawn(Corpse.Type, Corpse.Variant, 0, data.Position, Vector.Zero, nil);
end

local itemConfig = Isaac.GetItemConfig();
function Dejavu:GetRandomPlayerCollectibles(player, seed, count)
    local collectibleList = {};
    local collectibleCount = 0;
    for i = 1, THI.MaxCollectibleID do
        local config = itemConfig:GetCollectible(i);
        if (config) then
            if (not config:HasTags(ItemConfig.TAG_QUEST)) then
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
    local data = {};

    --当前层数（4位0-15）
    --层类型（4位0-15）
    --房间类型（8位0-255）
    --玩家类型（16位）
    data[1] = (level:GetStage() << 28 & stageMask) | 
    (level:GetStageType() << 24 & stageTypeMask) | 
    (room:GetType() << 16 & roomMask) | 
    (player:GetPlayerType() & playerMask); 

    --房间变种（32位）
    data[2] = level:GetCurrentRoomDesc().Data.Variant & roomVariantMask;
     
    --死亡位置X值（16位）
    --死亡位置Y值（16位）
    data[3] = (math.floor(player.Position.X) << 16 & posXMask) | 
    (math.floor(player.Position.Y) & posYMask);
    
    --3个随机道具（32位x3=96位）
    local randomItems = Dejavu:GetRandomPlayerCollectibles(player, seed, 3);
    for i = 1, #randomItems do
        data[i + 3] = randomItems[i]; 
    end
end

function Dejavu:PostGameEnd(gameOver)
    if (gameOver) then
        for p, player in Players.PlayerPairs() do
            print(require("json").encode(self:GetCorpseData(player)));
        end
    end
end
Dejavu:AddCallback(ModCallbacks.MC_POST_GAME_END, Dejavu.PostGameEnd)

function Dejavu:PostGameStarted(isContinued)
end
Dejavu:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Dejavu.PostGameStarted)

function Dejavu:PostNewRoom()
end
Dejavu:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dejavu.PostNewRoom)

return Dejavu;