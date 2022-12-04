local Collectibles = CuerLib.Collectibles;
local Detection = CuerLib.Detection;
local Unzan = ModItem("Unzan", "UNZAN");

-- local sourceItem = Isaac.GetItemConfig():GetCollectible(Unzan.Item);
-- function Unzan:EvaluateCache(player, cache)
--     if (cache == CacheFlag.CACHE_FAMILIARS) then
--         local familiar = THI.Familiars.Unzan;
--         local hasUnzan = player:HasCollectible(Unzan.Item) or player:GetEffects():HasCollectibleEffect(Unzan.Item);
--         local count = 0;
--         if (hasUnzan) then
--             count = 1;
--         end
--         player:CheckFamiliar(familiar.Variant, count, RNG(), sourceItem);
--     end
-- end
-- Unzan:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Unzan.EvaluateCache);



local function PostUpdate(mod)
    local room = Game():GetRoom();
    if (room:GetFrameCount() == 1 and room:GetAliveEnemiesCount() > 0) then
        local unzanPlayer;
        for p, player in Detection.PlayerPairs() do
            if (player:HasCollectible(Unzan.Item)) then
                unzanPlayer = player;
                break;
            end
        end
        if (unzanPlayer) then
            local Face = THI.Effects.UnzanFace;
            local face = Isaac.Spawn(Face.Type, Face.Variant, 0, Vector(-5800, -5800), Vector.Zero, unzanPlayer);
            face.Parent = unzanPlayer;
        end
    end
end
Unzan:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostNewGreedWave(mod, wave)
    local room = Game():GetRoom();
    local Face = THI.Effects.UnzanFace;
    if (#Isaac.FindByType(Face.Type, Face.Variant) <= 0 and room:GetAliveEnemiesCount() > 0) then
        local unzanPlayer;
        for p, player in Detection.PlayerPairs() do
            if (player:HasCollectible(Unzan.Item)) then
                unzanPlayer = player;
                break;
            end
        end
        if (unzanPlayer) then
            local face = Isaac.Spawn(Face.Type, Face.Variant, 0, Vector(-5800, -5800), Vector.Zero, unzanPlayer);
            face.Parent = unzanPlayer;
        end
    end
end
Unzan:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_NEW_GREED_WAVE, PostNewGreedWave);

return Unzan;