local Lib = CuerLib;
local Stats = {

}

function Stats.GetAddFireRate(firedelay, addition)
    return 30 / (30 / (firedelay + 1) + addition) - 1;
end

local function GetPlayerData(player, init)
    local data = Lib:GetData(player);
    if (init) then
        data.Stats = data.Stats or {
            Damage = {
                Multiplier = 1,
                DamageUp = 0,
                Flat = 0
            },
            Speed = {
                Limit = 2
            },
            Tears = {
                TearsUp = 0,
                Modifiers = {}
            }
        }
    end
    return data.Stats;
end

local function ResetDamageCaches(player)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = 1;
    data.Damage.DamageUp = 0;
    data.Damage.Flat = 0;
end

local function ResetTearsCaches(player)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = 0;
    data.Tears.Modifiers = {};
end

function Stats:GetDamageUp(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.DamageUp) or 0;
end
function Stats:SetDamageUp(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.DamageUp = value;
end
function Stats:AddDamageUp(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.DamageUp = data.Damage.DamageUp + value;
end

function Stats:GetFlatDamage(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.Flat) or 0;
end
function Stats:SetFlatDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Flat = value;
end
function Stats:AddFlatDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Flat = data.Damage.Flat + value;
end

function Stats:GetDamageMultiplier(player)
    local data = GetPlayerData(player, false);
    return (data and data.Damage.Multiplier) or 1;
end
function Stats:SetDamageMultiplier(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = value;
end
function Stats:MultiplyDamage(player, value)
    local data = GetPlayerData(player, true);
    data.Damage.Multiplier = data.Damage.Multiplier * value;
end
--Tears
function Stats:GetTearsUp(player)
    local data = GetPlayerData(player, false);
    return (data and data.Tears.TearsUp) or 0;
end
function Stats:SetTearsUp(player, value)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = value;
end
function Stats:AddTearsUp(player, value)
    local data = GetPlayerData(player, true);
    data.Tears.TearsUp = data.Tears.TearsUp + value;
end
function Stats:AddTearsModifier(player, func, priority)
    priority = priority or 0;
    local data = GetPlayerData(player, true);
    table.insert(data.Tears.Modifiers, {Func = func, Priority = priority} );
end


function Stats:GetSpeedLimit(player)
    local data = GetPlayerData(player, false);
    if (data)then
        return data.Speed.Limit;
    end
    return 2;
end
function Stats:SetSpeedLimit(player, value)
    local data = GetPlayerData(player, true);
    data.Speed.Limit = value;
end

function Stats:GetVanillaDamageMultiplier(player)
    local multiplier = 1;
    local effects = player:GetEffects();
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
        multiplier = multiplier * 0.75;
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) or player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)) then
        multiplier = multiplier * 1.5;
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART)) then
        multiplier = multiplier * 2.3
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_IMMACULATE_HEART)) then
        multiplier = multiplier * 1.2
    end

    if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT)) then
        multiplier = multiplier * 2
    end
    
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then
        multiplier = multiplier * 0.3
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)) then
        multiplier = multiplier * 0.2
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)) then
        multiplier = multiplier * 2
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)) then
        multiplier = multiplier * 2
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) then
        multiplier = multiplier * 2
    end
    return multiplier;
end


function Stats:GetEvaluatedDamage(player)
    
    local data = GetPlayerData(player, false);
    local originDamage = player.Damage;

    local characterDamage = 3.5;
    local oMulti = Stats:GetVanillaDamageMultiplier(player);
    local oFlat = 0;
    local oDamageUps = (((originDamage / oMulti - oFlat) / characterDamage) ^ 2 - 1 ) / 1.2;

    local totalDamage = oDamageUps;
    local flat = oFlat;
    local multiplier = oMulti;
    if (data) then
        totalDamage = totalDamage + data.Damage.DamageUp;
        flat = flat + data.Damage.Flat;
        multiplier = multiplier * data.Damage.Multiplier;
    end
    
    return (characterDamage * (totalDamage * 1.2 + 1) ^ 0.5 + flat) * multiplier;
end

function Stats:GetEvaluatedTears(player)
    
    local data = GetPlayerData(player, false);
    local origin = 30 / (player.MaxFireDelay + 1)
    local tears = origin;

    if (data) then
        -- if (tears < 5) then
        --     tears = math.min(5, tears + data.Tears.TearsUp);
        -- end
        
        local maxTearsUp = 2.27;
        local maxValue = 2.27;
        local a = -maxValue / maxTearsUp ^ 2;
        
        if (data.Tears.TearsUp > maxTearsUp) then
            tears = tears + maxValue;
        else
            tears = tears + (a * (data.Tears.TearsUp - maxTearsUp) ^ 2 + maxValue);
        end

        table.sort(data.Tears.Modifiers, function(a, b) 
            return a.Priority < b.Priority
        end)
        for _, modi in pairs(data.Tears.Modifiers) do
            tears = modi.Func(tears, origin);
        end
    end
    
    return tears;
end

function Stats:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        player.Damage = Stats:GetEvaluatedDamage(player);
        ResetDamageCaches(player);
    elseif (cache == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = 30 / Stats:GetEvaluatedTears(player) - 1;
        ResetTearsCaches(player);
    elseif (cache == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = math.min(Stats:GetSpeedLimit(player), player.MoveSpeed)
    end
end

function Stats:LateRegister()
    Lib.ModInfo.Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Stats.EvaluateCache);
end

return Stats;