local Stats = CuerLib.Stats;
local Players = CuerLib.Players;
local Satori = ModPlayer("Satori", false, "Satori");
Satori.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori.anm2");
Satori.CostumeHair = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_hair.anm2");


local game = THI.Game;


function Satori.GetPlayerData(player, init)
    local data = player:GetData();
    if (init) then
        if (not data._SATORI) then
            data._SATORI = {
                InitedType = -1,
            }
        end
    end
    return data._SATORI;
end



local function GetTempPlayerData(player, create)
    return Satori:GetTempData(player, create, function()
        return {
            LastFlying = nil
        }
    end)
end


function Satori:PostPlayerEffect(player)
    local SatoriB = THI.Players.SatoriB;
    local data = Satori.GetPlayerData(player, true);
    local initedType = data.InitedType;

    local playerType = player:GetPlayerType();
    if (playerType ~= initedType) then
        data = Satori.GetPlayerData(player, true);
        if (playerType == Satori.Type) then
            player:AddNullCostume(Satori.Costume);
            player:AddNullCostume(Satori.CostumeHair);
        else
            player:TryRemoveNullCostume(Satori.Costume);
            player:TryRemoveNullCostume(Satori.CostumeHair);
        end

        if (initedType == Satori.Type or playerType == Satori.Type) then
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
            player:EvaluateItems();
        end
        
        if (playerType == SatoriB.Type) then
            player:AddNullCostume(SatoriB.CostumeHair);
            player:GetSprite():Load("gfx/reverie/satori_b.anm2", true);
        else
            player:TryRemoveNullCostume(SatoriB.CostumeFlying);
            player:TryRemoveNullCostume(SatoriB.Costume);
            player:TryRemoveNullCostume(SatoriB.CostumeHair);
            
            local currentLimit = Stats:GetSpeedLimit(player);
            if (currentLimit > 0) then
                Stats:SetSpeedLimit(player, -1);
            end
            player:AddCacheFlags(CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end

        data.InitedType = playerType;
    end

    if (playerType == SatoriB.Type) then
        local tempData = GetTempPlayerData(player, true);
        if (tempData.LastFlying == nil or tempData.LastFlying ~= player.CanFly) then
            tempData.LastFlying = player.CanFly;
            if (player.CanFly) then
                player:AddNullCostume(SatoriB.CostumeFlying);
                player:TryRemoveNullCostume(SatoriB.Costume);
            else
                player:AddNullCostume(SatoriB.Costume);
                player:TryRemoveNullCostume(SatoriB.CostumeFlying);
            end
        end
    end

end
Satori:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Satori.PostPlayerEffect)

-- function Satori:PostNewRoom()
--     for p, player in Players.PlayerPairs() do
--         if (player:GetPlayerType() == Satori.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
--             -- Charm 3 enemies.
--             local entities = Isaac.GetRoomEntities();
--             local count = 0;
--             for i ,ent in pairs(entities) do
--                 if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
--                     local frames = 9000;
--                     if (ent:IsBoss()) then
--                         frames = 150;
--                     end
--                     ent:AddCharmed(EntityRef(player), frames);
--                     count = count + 1;
--                 end
--                 if (count >= 3) then
--                     return;
--                 end
--             end
--         end
--     end
-- end
-- Satori:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Satori.PostNewRoom)

local function EvaluateCache(mod, player, cache)
    if (player:GetPlayerType() == Satori.Type) then
        local PsycheEye = THI.Familiars.PsycheEye;
        local kills = PsycheEye:GetWaveKills(player) + PsycheEye:GetControlCount(player);
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            kills = kills * 2;
        end
        if (cache == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsModifier(player, function(tears)
                return tears * 0.8 + kills * 0.01;
            end)
        -- elseif (cache == CacheFlag.CACHE_SHOTSPEED) then
        --     player.ShotSpeed = player.ShotSpeed - 0.2;
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:AddFlatDamage(player, kills * 0.02);
            Stats:MultiplyDamage(player, 0.8);
        elseif (cache == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + kills * 1;
        end
    end
end
Satori:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)




return Satori;
