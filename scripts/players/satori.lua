local Stats = CuerLib.Stats;
local Detection = CuerLib.Detection;
local Satori = ModPlayer("Satori", false, "Satori");
Satori.Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_satori.anm2");
Satori.CostumeHair = Isaac.GetCostumeIdByPath("gfx/characters/costume_satori_hair.anm2");


local game = THI.Game;


function Satori.GetPlayerData(player, init)
    local data = player:GetData();
    if (init) then
        if (not data._SATORI) then
            data._SATORI = {
                InitedType = -1
            }
        end
    end
    return data._SATORI;
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
            player:AddNullCostume(SatoriB.Costume);
            player:AddNullCostume(SatoriB.CostumeFlying);
            player:GetSprite():Load("gfx/satori_b.anm2", true);
        else
            player:TryRemoveNullCostume(SatoriB.CostumeHair);
            player:TryRemoveNullCostume(SatoriB.Costume);
            player:TryRemoveNullCostume(SatoriB.CostumeFlying);
        end

        data.InitedType = playerType;
    end

end
Satori:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Satori.PostPlayerEffect)

function Satori:PostNewRoom()
    for p, player in Detection.PlayerPairs() do
        if (player:GetPlayerType() == Satori.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            -- Charm 3 enemies.
            local entities = Isaac.GetRoomEntities();
            local count = 0;
            for i ,ent in pairs(entities) do
                if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)) then
                    local frames = 9000;
                    if (ent:IsBoss()) then
                        frames = 150;
                    end
                    ent:AddCharmed(EntityRef(player), frames);
                    count = count + 1;
                end
                if (count >= 3) then
                    return;
                end
            end
        end
    end
end
Satori:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Satori.PostNewRoom)

function Satori:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == Satori.Type) then
        if (cache == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsModifier(player, function(tears)
                return tears * 1.25;
            end)
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 0.8);
        end
    end
end
Satori:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Satori.OnEvaluateCache)



return Satori;
