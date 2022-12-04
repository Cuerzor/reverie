local Plasyers = CuerLib.Players;
local Centi = ModItem("Curse of Centipede", "CentiCurse");



function Centi.TryAddCollectible(player, collectible)
    local playerType = player:GetPlayerType();
    if (playerType == PlayerType.PLAYER_ISAAC_B) then
        if (Plasyers.GetTIsaacRemainSpaces(player) <= 0) then
            local room = THI.Game:GetRoom();
            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, pos, Vector.Zero, nil);
            return;
        end
    end
    player:AddCollectible(collectible);
end
function Centi:PostPlayerEffect(player)
    local num = player:GetCollectibleNum(Centi.Item, true);
    if (num > 0) then
        local Seija = THI.Players.Seija;
        local seijaNerf = Seija:WillPlayerNerf(player);
        for i = 1, num do
            player:RemoveCollectible(Centi.Item, true);
            Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER);
            Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_BELLY_BUTTON);
            Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_POLYDACTYLY);
            Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_SCHOOLBAG);
            Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_LUCKY_FOOT);

            if (seijaNerf) then
                Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_SACRED_HEART);
                Centi.TryAddCollectible(player, CollectibleType.COLLECTIBLE_POLYPHEMUS);
            end
        end
        THI.Game:ShakeScreen(10);
        THI.SFXManager:Play(THI.Sounds.SOUND_CENTIPEDE);
    end
end
Centi:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Centi.PostPlayerEffect);

return Centi;