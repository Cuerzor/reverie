local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local ParasiticMushroom = ModItem("Parasitic Mushroom", "PARASITIC_MUSHROOM");

function ParasiticMushroom:EvaluateCache(player, flag)
    local num = player:GetCollectibleNum(ParasiticMushroom.Item);
    if (num > 0) then
        if (flag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.1 * num;
        elseif (flag == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsUp(player, 0.5 * num);
        elseif (flag == CacheFlag.CACHE_DAMAGE) then
            Stats:AddDamageUp(player, 0.5 * num);
        elseif (flag == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange + 60 * num;
        end
    end
end 
ParasiticMushroom:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ParasiticMushroom.EvaluateCache);

function ParasiticMushroom:PreGetCollectible(pool, decrease, seed, loopCount)
    if (loopCount == 1) then
        local itemCount = 0;
        for p, player in Players.PlayerPairs() do
            itemCount = itemCount + player:GetCollectibleNum(ParasiticMushroom.Item);
        end
        if (itemCount > 0) then
            local chance = 100 / (8 - math.min(7,itemCount));
            local rng = RNG();
            rng:SetSeed(seed, ParasiticMushroom.Item);
            if (rng:RandomInt(100) < chance) then
                return ParasiticMushroom.Item;
            end
        end
    end
end
ParasiticMushroom:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_GET_COLLECTIBLE, -50, ParasiticMushroom.PreGetCollectible)

function ParasiticMushroom:PostLoseCollectible(player, item, count)
    local maxHearts = player:GetMaxHearts();
    local boneHearts = player:GetBoneHearts();
    local soulHearts = player:GetSoulHearts();
    local boneOnly = Players.IsOnlyBoneHeartPlayer(player:GetPlayerType());
    if (boneOnly) then
        player:AddBoneHearts(-math.min(boneHearts - 1, count));
    else
        if (soulHearts <= 0 and boneHearts <= 0) then
            player:AddMaxHearts(-math.min(maxHearts - 2, 2 * count));
        end
    end
end
ParasiticMushroom:AddCallback(CuerLib.Callbacks.CLC_POST_LOSE_COLLECTIBLE, ParasiticMushroom.PostLoseCollectible, ParasiticMushroom.Item)

return ParasiticMushroom;