local ByteString = ModItem("Byte String", "BYTE_STRING");

function ByteString:PostGainBytes(player, item, count, touched)
    if (not touched) then
        local Seija = THI.Players.Seija;
        if (Seija:WillPlayerNerf(player)) then
            player:AddCoins(6 - player:GetNumCoins())
            player:AddBombs(6 - player:GetNumBombs())
            player:AddKeys(6 - player:GetNumKeys())
            for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
                player:SetActiveCharge (6, slot)
            end
            player:AddSoulCharge(6 - player:GetSoulCharge());
            player:AddBloodCharge(6 - player:GetBloodCharge());
            local Fan = THI.Collectibles.FanOfTheDead;
            Fan:AddLives(player, 6 - Fan:GetLives(player));
            Game().TimeCounter = 648000 + 10800 + 180;
        else
            for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
                local charge = player:GetActiveCharge(slot);
                player:SetActiveCharge (charge + 999, slot)
            end
            player:AddSoulCharge(999);
            player:AddBloodCharge(999);
            local Fan = THI.Collectibles.FanOfTheDead;
            Fan:AddLives(player, 999);
            Game().TimeCounter = 10800000;
        end
    end
end
ByteString:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, ByteString.PostGainBytes, ByteString.Item);

return ByteString;