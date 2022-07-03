local Lib = _TEMP_CUERLIB;
local Players = Lib:NewClass();

Players.FullRedHeartPlayers = {
    [PlayerType.PLAYER_KEEPER] = true,
    [PlayerType.PLAYER_BETHANY] = true,
    [PlayerType.PLAYER_KEEPER_B] = true,
}
Players.FullBoneHeartPlayers = {
    [PlayerType.PLAYER_THEFORGOTTEN] = true
}

Players.FullSoulHeartPlayers = {
    [PlayerType.PLAYER_BETHANY_B] = true,
    [PlayerType.PLAYER_BLACKJUDAS] = true,
    [PlayerType.PLAYER_BLUEBABY] = true,
    [PlayerType.PLAYER_BLUEBABY_B] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
}

function Players:SetFullRedHeartPlayer(playerType, value)
    Players.FullRedHeartPlayers[playerType] = value;
end

function Players:IsFullRedHeartPlayer(playerType)
    return Players.FullRedHeartPlayers[playerType] ~= nil;
end

function Players:SetFullSoulHeartPlayer(playerType, value)
    Players.FullSoulHeartPlayers[playerType] = value;
end

function Players:IsFullSoulHeartPlayer(playerType)
    return Players.FullSoulHeartPlayers[playerType] ~= nil;
end

function Players:SetFullBoneHeartPlayer(playerType, value)
    Players.FullBoneHeartPlayers[playerType] = value;
end

function Players:IsFullBoneHeartPlayer(playerType)
    return Players.FullBoneHeartPlayers[playerType] ~= nil;
end

function Players:AddRawSoulHearts(player, value)
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, true)) then
        local alabasterCharges = {};
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                alabasterCharges[slot] = player:GetActiveCharge (slot) + player:GetBatteryCharge (slot);
                if (value > 0) then
                    player:SetActiveCharge(12, slot);
                else
                    player:SetActiveCharge(0, slot);
                end
            end
        end

        player:AddSoulHearts(value);

        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                player:SetActiveCharge(alabasterCharges[slot], slot);
            end
        end
    else
        player:AddSoulHearts(value);
    end
end


function Players:AddRawBlackHearts(player, value)
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, true)) then
        local alabasterCharges = {};
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                alabasterCharges[slot] = player:GetActiveCharge (slot) + player:GetBatteryCharge (slot);
                if (value > 0) then
                    player:SetActiveCharge(12, slot);
                else
                    player:SetActiveCharge(0, slot);        
                end
            end
        end

        player:AddBlackHearts(value);

        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                player:SetActiveCharge(alabasterCharges[slot], slot);
            end
        end
    else
        player:AddBlackHearts(value);
    end
end



function Players:IsDead(player)
    return player:IsDead() or Lib.Revive.IsReviving(player);
end

function Players.TeleportToPosition(player, pos)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position,Vector.Zero, nil);
    local spr = poof:GetSprite();
    spr:Load(player:GetSprite():GetFilename(), true);
    spr:Play("TeleportUp");
    THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL1);
    THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL2);
    player.Position = pos;
    player:AnimateTeleport(false);
    player:SetMinDamageCooldown(30);
end
local config = Isaac.GetItemConfig();

function Players.IsTIsaacExcluded(id)
    if (id == CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return true;
    end
    local collectible = config:GetCollectible(id);
    if (collectible ) then
        if (collectible.Type == ItemType.ITEM_ACTIVE or collectible:HasTags(ItemConfig.TAG_QUEST)) then
            return true;
        end
    end
    return false;
end

local function GetExceptedItems()
    local results = {};
    local size = config:GetCollectibles().Size
    for i = 1, size do
        if (Players.IsTIsaacExcluded(i)) then
            table.insert(results, i);
        end
    end

    return results;
end
local TIsaacExcepted = GetExceptedItems();



function Players.GetTIsaacItemSlots(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            return 12;
        end
        return 8;
    end
    return nil;
end
function Players.GetTIsaacRemainSpaces(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B) then
        local count = player:GetCollectibleCount();
        for i, quest in pairs(TIsaacExcepted) do
            count = count - player:GetCollectibleNum(quest);
        end

        local slots = Players.GetTIsaacItemSlots(player);
        return slots - count;
    end
    return nil;
end

function Players:SwapPillCards(player)
    local thisCard = player:GetCard(0);
    local thisPill = player:GetPill(0);
    local otherCard = player:GetCard(1);
    local otherPill = player:GetPill(1);
    local pos = Vector(-5800, -5800);
    player:DropPocketItem(0, pos)
    player:DropPocketItem(1, pos)

    if (thisCard > 0) then
        player:AddCard(thisCard)
    elseif (thisPill > 0) then
        player:AddPill(thisPill)
    end
    if (otherCard > 0) then
        player:AddCard(otherCard)
    elseif (otherPill > 0) then
        player:AddPill(otherPill)
    end

    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        if ((ent.Variant == PickupVariant.PICKUP_TAROTCARD or 
        ent.Variant == PickupVariant.PICKUP_PILL) and pos:Distance(ent.Position) < 1 and ent.FrameCount <= 0) then
            ent:Remove();
        end
    end

end

function Players:RemoveCardPill(player, slot)
    local card = player:GetCard(slot);
    local pill = player:GetPill(slot);
    local pos = Vector(-5800, -5800);
    player:DropPocketItem(slot, pos)

    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        if ((ent.Variant == PickupVariant.PICKUP_TAROTCARD or 
        ent.Variant == PickupVariant.PICKUP_PILL) and pos:Distance(ent.Position) < 1 and ent.FrameCount <= 0) then
            ent:Remove();
        end
    end
end

function Players.HasJudasBook(player)
    local playerType = player:GetPlayerType();
    return (playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT);
end

return Players;