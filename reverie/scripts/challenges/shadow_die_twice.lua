local Sekiro = ModChallenge("Shadow Die Twice", "TouhouSekiro");

function Sekiro:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == Sekiro.Id) then
            local player = Isaac.GetPlayer(0);
            local Collectibles = THI.Collectibles;
            local Trinkets = THI.Trinkets;
            local itemPool = THI.Game:GetItemPool();


            local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME;
            player:AddTrinket(TrinketType.TRINKET_OLD_CAPACITOR);
            player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);
            -- player:AddTrinket(TrinketType.TRINKET_WATCH_BATTERY);
            -- player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);

            player:AddCollectible(Collectibles.Roukanken.Item, 12);
            itemPool:RemoveCollectible(Collectibles.Roukanken.Item)
            player:AddTrinket(Trinkets.AromaticFlower.Trinket);
            itemPool:RemoveTrinket(Trinkets.AromaticFlower.Trinket);
            player:SetPocketActiveItem (Collectibles.PsychoKnife.Item, ActiveSlot.SLOT_POCKET, false);
        end
    end
end
Sekiro:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Sekiro.PostGameStarted);




function Sekiro:PostPlayerEffect(player)
    if (Isaac.GetChallenge() == Sekiro.Id) then
        local Collectibles = THI.Collectibles;
        if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= Collectibles.PsychoKnife.Item) then
            player:SetPocketActiveItem (Collectibles.PsychoKnife.Item, ActiveSlot.SLOT_POCKET, false);
        end
    end
end
Sekiro:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Sekiro.PostPlayerEffect);

return Sekiro;