local Stats = CuerLib.Stats;
local Dangos = ModTrinket("Dangos", "DANGOS")

function Dangos:GetEatenDangoMultiplier(player)
    local trinketMult = player:GetTrinketMultiplier(Dangos.Trinket);
    if (trinketMult <= 0) then
        return 0;
    end

    local hasMomsBox  = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX);

    local excludedMult = 0;
    for i = 0, 1 do
        local trinket = player:GetTrinket(i);
        if (trinket == Dangos.Trinket or trinket == Dangos.Trinket + 32768) then
            excludedMult = excludedMult + 1;
        end
    end

    local queued = player.QueuedItem;
    if (queued.Item and queued.Item:IsTrinket ( )) then
        local trinket = queued.Item.ID;
        if (trinket == Dangos.Trinket) then
            excludedMult = excludedMult + 1;
        end
    end
    
    local trueTrinketMultiplier = trinketMult - excludedMult;
    -- if (trueTrinketMultiplier <= 1 and hasMomsBox) then
    --     trueTrinketMultiplier = trueTrinketMultiplier - 1;
    -- end

    return math.max(0, trueTrinketMultiplier);
end

local function GetPlayerData(player, create)
    return Dangos:GetData(player, create, function()
        return {
            CurrentMult = 0
        }
    end)
end


local function PostPlayerEffect(mod, player)
    if (player:HasTrinket(Dangos.Trinket)) then
        local data = GetPlayerData(player, false);
        local multi = (data and data.CurrentMult) or 0;
        local nowMult = Dangos:GetEatenDangoMultiplier(player);
        if (multi ~= nowMult) then
            data = GetPlayerData(player, true);
            data.CurrentMult = nowMult
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK);
            player:EvaluateItems();
        end
    else
        
        local data = GetPlayerData(player, false);
        if (data) then
            data.CurrentMult = 0;
        end
    end
end
Dangos:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

local function EvaluateCache(mod, player, flag)
    local multiplier = Dangos:GetEatenDangoMultiplier(player);
    if (multiplier > 0) then
        if (flag == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsUp(player, 0.5 * multiplier);
        elseif (flag == CacheFlag.CACHE_DAMAGE) then
            Stats:AddDamageUp(player, 1 * multiplier);
        elseif (flag == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + 60 * multiplier;
        elseif (flag == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed + 0.2 * multiplier;
        elseif (flag == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + 1 * multiplier;
        end
    end
end
Dangos:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

return Dangos;