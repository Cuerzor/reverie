local CompareEntity = CuerLib.Entities.CompareEntity;
local MimicTear = ModItem("Mimic Tear", "MIMIC_TEAR");

local cache = {};

function MimicTear:PostPlayerEffect(player)
    for i = #cache, 1, -1 do
        local info = cache[i];
        if (info and CompareEntity(info.player, player)) then
            local Seija = THI.Players.Seija;
            local nerfed = Seija:WillPlayerNerf(player);
            local rng = player:GetCollectibleRNG(MimicTear.Item);
            local tearCount = info.tearCount;
            local item = info.item;
            if (nerfed and rng:RandomInt(100) < 50) then
                for j = 1, tearCount do
                    player:RemoveCollectible(item, true);
                    SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
                end
            else
                for j = 1, tearCount do
                    player:AddCollectible(item, 0, true);
                end
            end
            table.remove(cache, i);
        end
    end
end
MimicTear:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MimicTear.PostPlayerEffect);

function MimicTear:PostGainCollectible(player, item, count, touched, queued)
    if (not touched and queued) then
        if (item ~= MimicTear.Item) then
            local itemConfig = Isaac.GetItemConfig();
            local config = itemConfig:GetCollectible(item)
            if (config and config.Type ~= ItemType.ITEM_ACTIVE) then
                local tearCount = player:GetCollectibleNum(MimicTear.Item);
                for i = 1, count do
                    table.insert(cache, {player = player, item = item, tearCount = tearCount});
                end
            end
        end
    end
end
MimicTear:AddPriorityCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, CallbackPriority.EARLY, MimicTear.PostGainCollectible);

return MimicTear;