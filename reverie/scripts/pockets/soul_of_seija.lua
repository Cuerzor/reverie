local Detection = CuerLib.Detection;
local Players = CuerLib.Players;
local SeijaSoul = ModCard("SoulOfSeija", "SOUL_SEIJA");
SeijaSoul.ReversedID = Isaac.GetCardIdByName("SoulOfSeijaReversed");


local function PostUseCard(mod, card, player, flags)
    if (card == SeijaSoul.ID or card == SeijaSoul.ReversedID) then

        player:UseActiveItem(THI.Collectibles.DFlip.Item, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME);
        if (card == SeijaSoul.ID and flags & UseFlag.USE_OWNED > 0) then
            player:AddCard(SeijaSoul.ReversedID);
        end
    end
end
SeijaSoul:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard);


-- local function PostNewRoom(mod)
--     for p, player in Detection.PlayerPairs() do
--         for slot = 3, 0, -1 do
--             if (player:GetCard(slot) == SeijaSoul.ReversedID) then
--                 Players:RemoveCardPill(player, slot)
--             end
--         end
--     end
-- end
-- SeijaSoul:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);


-- Avoid Reversed SeijaSoul from spawning.
local function GetCard(mod, RNG,card, IncludePlayingCards,IncludeRunes,OnlyRunes)
    if (card == SeijaSoul.ReversedID) then
        local itemPool = Game():GetItemPool();
        return itemPool:GetCard(RNG:Next(), IncludePlayingCards, IncludeRunes, OnlyRunes);
    end
end
SeijaSoul:AddCallback(ModCallbacks.MC_GET_CARD, GetCard);

THI:AddAnnouncer(SeijaSoul.ID, THI.Sounds.SOUND_SOUL_OF_SEIJA, 0)
THI:AddAnnouncer(SeijaSoul.ReversedID, THI.Sounds.SOUND_SOUL_OF_SEIJA, 0)

return SeijaSoul;