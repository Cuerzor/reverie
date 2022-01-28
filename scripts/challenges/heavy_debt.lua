local HeavyDebt = ModChallenge("Heavy Debt", "HeavyDebt");

function HeavyDebt:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == HeavyDebt.Id) then
            local player = Isaac.GetPlayer(0);
            local iou = THI.Collectibles.MomsIOU;
            local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME;
            player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);
            player:AddCollectible(iou.Item);
            THI.Game:GetItemPool():RemoveCollectible(iou.Item)
        end
    end
end
HeavyDebt:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, HeavyDebt.PostGameStarted);

function HeavyDebt:GetCard(rng,card,includePlayingCards,includeRunes,onlyRunes)
    if (Isaac.GetChallenge() == HeavyDebt.Id) then
        if (card == Card.CARD_DIAMONDS_2) then
            return Card.CARD_ACE_OF_DIAMONDS;
        end
    end
end
HeavyDebt:AddCallback(ModCallbacks.MC_GET_CARD, HeavyDebt.GetCard);

return HeavyDebt;