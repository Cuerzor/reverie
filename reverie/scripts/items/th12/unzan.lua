local Collectibles = CuerLib.Collectibles;
local Players = CuerLib.Players;
local Unzan = ModItem("Unzan", "UNZAN");

local function PostUpdate(mod)
    local room = Game():GetRoom();
    if (room:GetFrameCount() == 1 and room:GetAliveEnemiesCount() > 0) then
        local unzanPlayer;
        for p, player in Players.PlayerPairs() do
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
        for p, player in Players.PlayerPairs() do
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
Unzan:AddCallback(CuerLib.Callbacks.CLC_POST_NEW_GREED_WAVE, PostNewGreedWave);

return Unzan;