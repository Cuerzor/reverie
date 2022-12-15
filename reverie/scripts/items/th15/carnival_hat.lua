local Stats = CuerLib.Stats;
local Collectibles = CuerLib.Collectibles;
local Hat = ModItem("Carnival Hat", "CARNIVAL_HAT");

local function GetPlayerData(player, create)
    return Hat:GetData(player, create, function()
        return {
            BlownUpCount = 0
        }
    end)
end

--- Get the player's blown up count.
---@param player EntityPlayer
---@return integer count
function Hat:GetPlayerBlownUpCount(player)
    local data = GetPlayerData(player, false);
    return (data and data.BlownUpCount) or 0;
end

--- Set the player's blown up count.
---@param player EntityPlayer
---@param count integer
function Hat:SetPlayerBlownUpCount(player, count)
    local data = GetPlayerData(player, true);
    data.BlownUpCount = count;
end

--- Add the player's blown up count.
---@param player EntityPlayer
---@param count integer
function Hat:AddPlayerBlownUpCount(player, count)
    self:SetPlayerBlownUpCount(player, self:GetPlayerBlownUpCount(player) + count);
end

local function PostEntityKill(mod, entity)
    if (entity:IsActiveEnemy(true) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if (Collectibles:IsAnyHasCollectible(Hat.Item)) then
            Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_TROLL, 0, entity.Position, Vector.Zero, entity);
        end
    end
end
Hat:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill)

local function PostPlayerTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (flags & DamageFlag.DAMAGE_EXPLOSION > 0) then
        local player = tookDamage:ToPlayer();
        if (player and player:HasCollectible(Hat.Item)) then
            Hat:AddPlayerBlownUpCount(player, 1);
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
            player:EvaluateItems();
        end
    end
end
Hat:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostPlayerTakeDamage, EntityType.ENTITY_PLAYER);


local function EvaluateCache(mod, player, flag)
    local num = player:GetCollectibleNum(Hat.Item);
    if (num > 0) then
        if (flag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.01 * num;
        elseif (flag == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsModifier(player, function(tears) return tears + 0.01 * num end);
        elseif (flag == CacheFlag.CACHE_DAMAGE) then
            Stats:AddFlatDamage(player, 0.01 * num + 0.1 * Hat:GetPlayerBlownUpCount(player));
        elseif (flag == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + 0.4 * num;
        elseif (flag == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed + 0.01 * num;
        elseif (flag == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + 0.01 * num;
        end
    end
end
Hat:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)


local function PostGainHat(mod, player, item, count, touched)
    if (not touched) then
        for i = 1, count do
            local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_JOKER, pos, Vector.Zero, player);
        end
    end
end
Hat:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainHat, Hat.Item)

return Hat;