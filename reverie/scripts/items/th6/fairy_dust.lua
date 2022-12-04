local Detection = CuerLib.Detection;
local EntityExists = Detection.EntityExists;
local FairyDust = ModItem("Fairy Dust", "FAIRY_DUST");

FairyDust.CostumeId = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_fairy_dust.anm2");

function FairyDust:GetTempPlayerData(player, create)
    return FairyDust:GetTempData(player, create, function()
        return {
            HasCostume = false
        }
    end)
end

function FairyDust:PostEntityKill(entity)
    local npc = entity:ToNPC();
    if (npc) then
        if (not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD)) then

            local hasDust = false;
            local luck = 0;
            for p, player in Detection.PlayerPairs() do
                luck = luck + player.Luck;
                local dustCount = player:GetCollectibleNum(FairyDust.Item);
                if (dustCount > 0 and dustCount < 3) then
                    hasDust = true;
                end
            end


            if (hasDust) then
                local isBoss = npc:IsBoss() and not EntityExists(npc.ParentNPC) and not EntityExists(npc.ChildNPC);
                local chance = math.max(1, math.min(10, luck));
                if (isBoss) then
                    chance = chance * 10;
                end
                if (npc.DropSeed % 100 < chance) then
                    local room = Game():GetRoom();
                    local pos = room:FindFreePickupSpawnPosition(npc.Position);
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, FairyDust.Item, pos, Vector.Zero, npc):ToPickup();
                end
            end
        end
    end
end
FairyDust:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, FairyDust.PostEntityKill);

function FairyDust:PostPlayerUpdate(player)
    local dustCount = player:GetCollectibleNum(FairyDust.Item);
    local data = FairyDust:GetTempPlayerData(player, false);
    local hasCostume = data and data.HasCostume;
    local flying = dustCount >= 3;
    if (flying ~= hasCostume) then
        data = FairyDust:GetTempPlayerData(player, true);
        data.HasCostume = flying;
        if (flying) then
            player:AddNullCostume(FairyDust.CostumeId)
        else
            player:TryRemoveNullCostume(FairyDust.CostumeId)
        end
    end
end
FairyDust:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, FairyDust.PostPlayerUpdate);

function FairyDust:EvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_FLYING) then
        local dustCount = player:GetCollectibleNum(FairyDust.Item);
        if (dustCount >= 3) then
            player.CanFly = true;
        end
    end
end
FairyDust:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FairyDust.EvaluateCache);


return FairyDust;