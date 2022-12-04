local Mod = THI;
local Stats = CuerLib.Stats;
local TemporaryDamage = {};

local function GetData(player, create)
    local data = THI.GetData(player);
    if (create and not data.TemporaryDamage) then
        data.TemporaryDamage = {
            DamageUp = 0,
            DamageTime = 0,
            DamageMaxTime = 0
        }
    end
    return data.TemporaryDamage;
end

function Mod:AddTemporaryDamage(player, damage, time, addTime)
    local data = GetData(player, true);
    data.DamageUp = data.DamageUp + damage
    if (addTime) then
        data.DamageTime = data.DamageTime + time;
        data.DamageMaxTime = data.DamageMaxTime + time;
    else
        data.DamageTime = math.max(data.DamageTime, time);
        data.DamageMaxTime = math.max(data.DamageMaxTime, time);
    end
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:EvaluateItems();
end

function TemporaryDamage:PostPlayerUpdate(player)
    if (player:IsFrame(14, 0)) then
        local data = GetData(player, false);
        if (data) then
            if (data.DamageTime > 0) then
                data.DamageTime = data.DamageTime - 7;
                if (data.DamageTime <= 0) then
                    data.DamageUp = 0
                    data.DamageTime = 0
                    data.DamageMaxTime = 0
                end
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();
            end
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TemporaryDamage.PostPlayerUpdate)


function TemporaryDamage:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        local data = GetData(player, false);
        if (data) then
            if (data.DamageTime > 0 and data.DamageMaxTime > 0) then
                local damage = data.DamageUp * data.DamageTime / data.DamageMaxTime;
                Stats:AddDamageUp(player, damage);
            end
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TemporaryDamage.EvaluateCache)


return TemporaryDamage;