local WhosThatItem = ModChallenge("Who's that item?", "WHOS_THAT_ITEM");

function WhosThatItem:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == WhosThatItem.Id) then
            local player = Isaac.GetPlayer(0);
            local itemPool = Game():GetItemPool();
            local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME;
            player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);
            player:AddCollectible(Reverie.Collectibles.EyeOfChimera.Item, -1);
            player:AddTrinket(Reverie.Trinkets.SymmetryOCD.Trinket);
            itemPool:RemoveCollectible(Reverie.Collectibles.EyeOfChimera.Item)
            itemPool:RemoveTrinket(Reverie.Trinkets.SymmetryOCD.Trinket);
        end
    end
end
WhosThatItem:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, WhosThatItem.PostGameStarted);

return WhosThatItem;