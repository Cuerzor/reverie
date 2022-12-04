local Collectibles = CuerLib.Collectibles
local SaveAndLoad = CuerLib.SaveAndLoad;
local Stages = CuerLib.Stages;
local Callbacks = CuerLib.Callbacks;
local Stats = CuerLib.Stats;
local Detection = CuerLib.Detection;


local OneOfNineTails = ModItem("One of Nine Tails", "OneOfNineTails");

local maxFamiliarCount = 9;

local function GetFamiliarList()
    local config = Isaac:GetItemConfig();
    local collectibles = config:GetCollectibles();
    local size = collectibles.Size;
    local result = {};
    for i=1, size do
        local item = config:GetCollectible(i);
        if (item ~= nil and item.Type == ItemType.ITEM_FAMILIAR) then
            table.insert(result, item.ID);
        end
    end
    return result;
end

local FamiliarsId = GetFamiliarList();


local function GetPlayerData(player, init)
    return OneOfNineTails:GetData(player, init, function() return {
        FamiliarCount = 0 
    } end);
end

local function GetDamageMultiplier(familiarCount)
    local maxMultiplier = 1.5;
    local familiarCount = math.min(familiarCount, maxFamiliarCount);
    
    return -(maxMultiplier - 1) / (maxFamiliarCount^2) * (familiarCount-maxFamiliarCount) ^ 2 + maxMultiplier;
end

------------------
-- Public Methods
------------------
function OneOfNineTails.SpawnItem(spawner, position)
    local room = THI.Game:GetRoom();
    local itemPool = THI.Game:GetItemPool();
    local pos = room:FindFreePickupSpawnPosition(position, 0, true);
    local seed = THI.Game:GetRoom():GetSpawnSeed();
    local item = itemPool:GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, seed, CollectibleType.COLLECTIBLE_BROTHER_BOBBY)
    local entity = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, pos, Vector.Zero, spawner);
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, entity);
end

function OneOfNineTails.GetFamiliarCount(player)
    local count = 0
    for _,id in pairs(FamiliarsId) do
        local addition = player:GetCollectibleNum(id);
        if (id == THI.Collectibles.ChenBaby.Item) then
            addition = addition * 3;
        end
        count = count + addition;
    end
    return count;
end

------------------
-- Events
------------------
function OneOfNineTails:onPlayerEffect(player)
    if (Game():GetFrameCount() > 0) then
        local level = THI.Game:GetLevel();
        local num = player:GetCollectibleNum(OneOfNineTails.Item);

        if (num > 0) then
            local playerData = GetPlayerData(player, false);
            local curCount = (playerData and playerData.FamiliarCount) or 0;
            local familiarCount = OneOfNineTails.GetFamiliarCount(player);
            if (curCount ~= familiarCount) then
                playerData = playerData or GetPlayerData(player, true);
                playerData.FamiliarCount = familiarCount;
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();
            end
        end
    end
end
OneOfNineTails:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, OneOfNineTails.onPlayerEffect)

function OneOfNineTails:onNewStage()
    if (THI.Game:GetFrameCount() > 1) then
        for p, player in Detection.PlayerPairs() do

            local canSpawn = true;
            if (THI.IsLunatic()) then
                canSpawn = canSpawn and OneOfNineTails.GetFamiliarCount(player) < maxFamiliarCount;
            end

            if (canSpawn) then
                local num = player:GetCollectibleNum(OneOfNineTails.Item);
                    
                if (num > 0) then
                    for i=1,num do
                        OneOfNineTails.SpawnItem(player, player.Position);
                    end
                    THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
                end
            end
        end
    end
end
OneOfNineTails:AddCustomCallback(CuerLib.CLCallbacks.CLC_NEW_STAGE, OneOfNineTails.onNewStage)

function OneOfNineTails:postPickCollectible(player, item, count, touched)
    if (not touched) then
        if (count > 0) then
            for i=1,count do
                OneOfNineTails.SpawnItem(player, player.Position);
            end
            THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
        end
    end
end
OneOfNineTails:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, OneOfNineTails.postPickCollectible, OneOfNineTails.Item);

function OneOfNineTails:postChangeCollectibles(player, item, diff)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:EvaluateItems();
end
OneOfNineTails:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, OneOfNineTails.postChangeCollectibles, OneOfNineTails.Item);


function OneOfNineTails:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        if (player:HasCollectible(OneOfNineTails.Item)) then
            local count = OneOfNineTails.GetFamiliarCount(player);
            local multiplier = GetDamageMultiplier(count);
            --player.Damage = player.Damage * multiplier;
            Stats:MultiplyDamage(player, multiplier);
        end
    end
end
OneOfNineTails:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OneOfNineTails.onEvaluateCache)

return OneOfNineTails;