local NoBloodForCurse = ModChallenge("No Blood for Curse", "NO_BLOOD_FOR_CURSE");


function NoBloodForCurse:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == NoBloodForCurse.Id) then
            local player = Isaac.GetPlayer(0);
            local Collectibles = THI.Collectibles;
            local itemPool = Game():GetItemPool();

            player:AddCollectible(Collectibles.CursedBlood.Item);
            player:AddCollectible(Collectibles.CarnivalHat.Item);
            itemPool:RemoveCollectible(Collectibles.CursedBlood.Item);
            itemPool:RemoveCollectible(Collectibles.CarnivalHat.Item);
            itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_HOST_HAT);
            itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC);
            itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE);
        end
    end
end
NoBloodForCurse:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, NoBloodForCurse.PostGameStarted);

return NoBloodForCurse;