local Players = CuerLib.Players;
local Wings = ModTrinket("Butterfly Wings", "BUTTERFLY_WINGS");

Wings.CostumeId = Isaac.GetCostumeIdByPath ("gfx/reverie/characters/costume_butterfly_wings.anm2" );

local function GetPlayerData(player, create)
    local function default()
        return {
            HasWings = false,
        }
    end
    return Wings:GetData(player, create, default);
end

local function GetPlayerTempData(player, create)
    local function default()
        return {
            KeepWings = false
        }
    end
    return Wings:GetTempData(player, create, default);
end

function Wings:HasWings(player)
    local data = GetPlayerData(player, false);
    return data and data.HasWings;
end

function Wings:SetHasWings(player, value)
    local data = GetPlayerData(player, true);
    data.HasWings = value;
end
function Wings:IsKeepWings(player)
    local data = GetPlayerTempData(player, false);
    return data and data.KeepWings;
end

function Wings:SetKeepWings(player, value)
    local data = GetPlayerTempData(player, true);
    data.KeepWings = value;
end
function Wings:ShouldHasWing(player)
    return (player:HasTrinket(Wings.Trinket) and self:HasWings(player)) or player:GetTrinketMultiplier(self.Trinket) > 1
end
function Wings:CanFly(player)
    return Wings:ShouldHasWing(player) or self:IsKeepWings(player);
end

function Wings:UpdateFlying(player)
    player:AddCacheFlags(CacheFlag.CACHE_FLYING);
    player:EvaluateItems();
end

function Wings:SwapAllPlayers()
    for i, player in Players.PlayerPairs() do
        if (player:HasTrinket(self.Trinket)) then
            self:SetHasWings(player, not self:HasWings(player));
            self:UpdateFlying(player);
        end
    end
end

do

    local function EvaluateCache(mod, player, flag)
        if (flag == CacheFlag.CACHE_FLYING) then
            if (Wings:CanFly(player)) then
                Wings:SetKeepWings(player, true);
                player.CanFly = true;
                player:AddNullCostume(Wings.CostumeId)
            else
                player:TryRemoveNullCostume(Wings.CostumeId)
            end
        end
    end
    Wings:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

    local function PreSpawnAward(mod, rng, pos)
        Wings:SwapAllPlayers();
    end
    Wings:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, PreSpawnAward)

    local function PostNewGreedWave(mod, wave)
        Wings:SwapAllPlayers();
    end
    Wings:AddCallback(CuerLib.Callbacks.CLC_POST_NEW_GREED_WAVE, PostNewGreedWave)

    local function PostNewRoom(mod)
        for i, player in Players.PlayerPairs() do
            if (Wings:IsKeepWings(player)) then
                local hasWings = Wings:ShouldHasWing(player);
                if (not hasWings) then
                    Wings:SetKeepWings(player, false);
                    Wings:UpdateFlying(player);
                end
            end
        end
    end
    Wings:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

end

return Wings;