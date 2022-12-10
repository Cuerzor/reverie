local Lib = LIB;
local Players = Lib:NewClass();

Players.OnlyRedHeartPlayers = {
    [PlayerType.PLAYER_KEEPER] = true,
    [PlayerType.PLAYER_BETHANY] = true,
    [PlayerType.PLAYER_KEEPER_B] = true,
}
Players.OnlyBoneHeartPlayers = {
    [PlayerType.PLAYER_THEFORGOTTEN] = true
}

Players.OnlySoulHeartPlayers = {
    [PlayerType.PLAYER_BETHANY_B] = true,
    [PlayerType.PLAYER_BLACKJUDAS] = true,
    [PlayerType.PLAYER_BLUEBABY] = true,
    [PlayerType.PLAYER_BLUEBABY_B] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
}

function Players:SetOnlyRedHeartPlayer(playerType, value)
    self.OnlyRedHeartPlayers[playerType] = value;
end

function Players:IsOnlyRedHeartPlayer(playerType)
    return self.OnlyRedHeartPlayers[playerType] ~= nil;
end

function Players:SetOnlySoulHeartPlayer(playerType, value)
    self.OnlySoulHeartPlayers[playerType] = value;
end

function Players:IsOnlySoulHeartPlayer(playerType)
    return self.OnlySoulHeartPlayers[playerType] ~= nil;
end

function Players:SetOnlyBoneHeartPlayer(playerType, value)
    self.OnlyBoneHeartPlayers[playerType] = value;
end

function Players:IsOnlyBoneHeartPlayer(playerType)
    return self.OnlyBoneHeartPlayers[playerType] ~= nil;
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

function Players:PlayerPairs(includePlayer, includeBaby)
    if (includePlayer == nil) then
        includePlayer = true;
    end
    
    if (includeBaby == nil) then
        includeBaby = false;
    end

    local game = Game();
    local num = game:GetNumPlayers();
    local p = 0;
    local indexList = {};
    local function iter()
        while (p < num) do
            local player = game:GetPlayer(p);
            p = p + 1;
            local variant = player.Variant;
            if ((includePlayer and variant == 0) or (includeBaby and variant == 1)) then
                local curIndex = indexList[variant] or 0;
                indexList[variant] = curIndex + 1;
                return curIndex + variant * 16, player;
            end
        end
        return nil;
    end
    return iter, nil, nil;
end

function Players:IsDead(player)
    return player:IsDead() or Lib.Revive.IsReviving(player);
end

function Players.TeleportToPosition(player, pos)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position,Vector.Zero, nil);
    local spr = poof:GetSprite();
    spr:Load(player:GetSprite():GetFilename(), true);
    spr:Play("TeleportUp");
    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1);
    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2);
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

local function GetTIsaacExceptedItems()
    local results = {};
    local size = config:GetCollectibles().Size
    for i = 1, size do
        if (Players.IsTIsaacExcluded(i)) then
            table.insert(results, i);
        end
    end

    return results;
end
local TIsaacExcepted = GetTIsaacExceptedItems();



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
    return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE);
end

do -- Devil deal.

    Players.DealResults = {
        INVALID = -1,
        NOT_DEALT = 0,
        DEALT = 1,
        LOST_DEALT = 2
    }


    function Players:GetItemPrice(player, devilprice, variant, ignorePoundOfFlesh)
        variant = variant or 100;
        if (ignorePoundOfFlesh or not player:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH)) then
            if (variant == PickupVariant.PICKUP_COLLECTIBLE) then -- Collectible.
                
                local maxHearts = player:GetMaxHearts() + player:GetBoneHearts() * 2;
                local playerType = player:GetPlayerType();
                if (player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL)) then
                    return PickupPrice.PRICE_SOUL;
                elseif (playerType == PlayerType.PLAYER_BLUEBABY) then -- Blue Baby.
                    if (devilprice == 2) then
                        return -8
                    else
                        return -7
                    end
                else -- Other Characters.
                    if (devilprice == 2) then
                        if (maxHearts >= 4) then
                            return PickupPrice.PRICE_TWO_HEARTS;
                        elseif (maxHearts >= 2) then
                            return PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS;
                        else
                            return PickupPrice.PRICE_THREE_SOULHEARTS;
                        end
                    else
                        if (maxHearts >= 2) then
                            return PickupPrice.PRICE_ONE_HEART;
                        else
                            return PickupPrice.PRICE_THREE_SOULHEARTS;
                        end
                    end
                end
            else
                return PickupPrice.PRICE_SPIKES;
            end
        else -- Pound of flesh.
            if (variant == PickupVariant.PICKUP_COLLECTIBLE) then
                return devilprice * 15;
            else 
                return 5;
            end
        end
    end

    function Players:CostCoins(player, price)
        local coins = player:GetNumCoins();
        local results = self.DealResults;
        if (price == PickupPrice.PRICE_FREE) then
            player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT);
            return results.DEALT;
        elseif (price > 0) then
            if (coins >= price) then
                player:AddCoins(-price);
                return results.DEALT;
            end
            return results.NOT_DEALT;
        end
        return results.INVALID;
    end

    -- Cost hearts for deal.
    -- Returns -1 for invalid price, 0 for not dealt, 1 for hearts, 2 for lost to take,.
    function Players:DealHearts(player, price)
        
        local results = self.DealResults;
        local playerType = player:GetPlayerType()
        -- Free for lost.
        if (playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or playerType == PlayerType.PLAYER_JACOB2_B) then
            return results.LOST_DEALT;
        end
        -- Lost's curse.
        local effects = player:GetEffects();
        if (effects:HasNullEffect(NullItemID.ID_LOST_CURSE) or effects:HasNullEffect(NullItemID.ID_JACOBS_CURSE)) then
            return results.LOST_DEALT;
        end

        local maxHearts = player:GetMaxHearts();
        local boneHearts = player:GetBoneHearts();
        local soulHearts = player:GetSoulHearts();
        if (price == PickupPrice.PRICE_ONE_HEART) then -- 1 Heart
            if (maxHearts >= 2) then
                player:AddMaxHearts(-2);
                return results.DEALT;
            elseif (boneHearts >= 1) then
                player:AddBoneHearts(-1);
                return results.DEALT;
            end
            return results.NOT_DEALT;
        elseif (price == PickupPrice.PRICE_TWO_HEARTS) then -- 2 Hearts.
            local dealt = -1;
            for i = 1, 2 do
                if (maxHearts >= 2) then
                    player:AddMaxHearts(-2);
                    dealt = 1;
                elseif (boneHearts >= 1) then
                    player:AddBoneHearts(-1);
                    dealt = 1;
                end
            end
            return dealt;
        elseif (price == PickupPrice.PRICE_THREE_SOULHEARTS) then
            player:AddSoulHearts(-6);
            return results.DEALT;
        elseif (price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS) then
            if (maxHearts >= 2) then
                player:AddMaxHearts(-2);
                player:AddSoulHearts(-4);
                return results.DEALT;
            elseif (boneHearts >= 1) then
                player:AddBoneHearts(-1);
                player:AddSoulHearts(-4);
                return results.DEALT;
            end
            return results.NOT_DEALT;
        elseif (price == PickupPrice.PRICE_SPIKES) then
            local flags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_SPIKES;
            player:TakeDamage(2, flags, EntityRef(nil), 30);
            return results.DEALT;
        elseif (price == PickupPrice.PRICE_SOUL) then
            if (player:TryRemoveTrinket(TrinketType.TRINKET_YOUR_SOUL)) then
                return results.DEALT;
            end
            return results.NOT_DEALT;
        elseif (price == -7) then --One Soulheart
            player:AddSoulHearts(-2);
            return results.DEALT;
        elseif (price == -8) then --Two Soulhearts
            player:AddSoulHearts(-4);
            return results.DEALT;
        elseif (price == -9) then --One Heart and one Soulheart
            if (maxHearts >= 2) then
                player:AddMaxHearts(-2);
                player:AddSoulHearts(-2);
                return results.DEALT;
            elseif (boneHearts >= 1) then
                player:AddBoneHearts(-1);
                player:AddSoulHearts(-2);
                return results.DEALT;
            end
            return results.NOT_DEALT;
        elseif (price < -9) then --Free.
            return results.DEALT;
        end
        return results.INVALID;
    end

    function Players:Buy(player, price)
        local coinResult = self:CostCoins(player, price);
        if (coinResult > -1) then
            return coinResult;
        else
            return self:DealHearts(player, price);
        end
    end
end

return Players;