local Detection = CuerLib.Detection;
local Collectibles = CuerLib.Collectibles;
local ItemPools = CuerLib.ItemPools;
local Arm = ModItem("Ethereal Arm", "ETHEREAL_ARM");

Arm.Hands = {
    Three = Isaac.GetCardIdByName ("VoidHandThree"),
    Two = Isaac.GetCardIdByName ("VoidHandTwo"),
    One = Isaac.GetCardIdByName ("VoidHandOne"),
}
function Arm:GetMaxHandTimes() return 3; end

local function GetPlayerData(player, create)
    local function getter()
        return {
            HandTimes = 0,
        }
    end
    return Arm:GetData(player,create, getter);
end

local PocketWhiteList = {
    Cards = {
        Arm.Hands.Three,
        Arm.Hands.Two,
        Arm.Hands.One
    },
    Pills = {}
}
function Arm:IsCardVoidHand(id)
    for i, item in pairs(self.Hands) do
        if (id == item) then
            return true;
        end
    end
    return false;
end
function Arm:WillPocketDrop(pill, id)
    local list = PocketWhiteList.Cards;
    if (pill) then
        list = PocketWhiteList.Pills;
    end
    for i, item in pairs(list) do
        if (id == item) then
            return false;
        end
    end
    return true;
end


function Arm:GetHandUseTimes(player)
    local data = GetPlayerData(player, false);
    if (data) then
        return data.HandTimes;
    end
    return 0;
end
function Arm:AddHandUseTimes(player, value)
    local data = GetPlayerData(player, true);
    data.HandTimes = (data.HandTimes or 0) + value;
end
function Arm:CanPickupPocket(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B) then
        return not player:GetOtherTwin():HasCollectible(Arm.Item)
    else
        return not player:HasCollectible(Arm.Item)
    end
    -- or self:GetHandUseTimes(player) >= self:GetMaxHandTimes()
end
function Arm:ResetHandUseTimes(player)
    local data = GetPlayerData(player, false);
    if (data) then
        data.HandTimes = 0;
    end
end

do 
    -- Avoid void hand from spawning.
    local function GetCard(mod, RNG,card, IncludePlayingCards,IncludeRunes,OnlyRunes)
        if (Arm:IsCardVoidHand(card)) then
            local itemPool = Game():GetItemPool();
            return itemPool:GetCard(RNG:Next(), IncludePlayingCards, IncludeRunes, OnlyRunes);
        end
    end
    Arm:AddCallback(ModCallbacks.MC_GET_CARD, GetCard);


    local function PostPickupInit(mod, pickup)
        if (pickup.Variant == PickupVariant.PICKUP_TAROTCARD and Arm:IsCardVoidHand(pickup.SubType)) then
            pickup:Remove();
        end
    end
    Arm:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInit);


    
    local function PostPickupUpdate(mod, pickup)
        if (pickup.FrameCount == 1) then
            local isFool = pickup.Variant == PickupVariant.PICKUP_TAROTCARD and pickup.SubType == Card.CARD_FOOL;
            local isTelepill = false;
            if (pickup.Variant == PickupVariant.PICKUP_PILL)  then
                local effect = Game():GetItemPool():GetPillEffect(pickup.SubType, Isaac.GetPlayer());
                isTelepill = effect == PillEffect.PILLEFFECT_TELEPILLS;
            end
            if (isFool or isTelepill) then
                if (not pickup.SpawnerEntity and pickup.SpawnerType == 5 and pickup.SpawnerVariant == 69)then
                    local hasArm = Collectibles.IsAnyHasCollectible(Arm.Item);
                    if (hasArm) then
                        local room = Game():GetRoom();
                        local gridEntity = room:GetGridEntityFromPos(pickup.Position);
                        if (gridEntity and gridEntity:GetType() == GridEntityType.GRID_ROCK_ALT2 and gridEntity.State == 2) then
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_TELEPORT, true, true, true);
                        end
                    end
                end
            end
        end
    end
    Arm:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate);

    local function PostUseCard(mod, card, player, flags)
        if (Arm:IsCardVoidHand(card)) then
            if (flags & UseFlag.USE_OWNED > 0) then
                Arm:AddHandUseTimes(player, 1)
            end

            local game = Game();
            local room = game:GetRoom();
            local ItemPool = game:GetItemPool();
            local pocketCount = 0;
            local itemCount = 0;
            local pocketIndex = 0;
            for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
                if (ent.Variant == PickupVariant.PICKUP_TAROTCARD or ent.Variant == PickupVariant.PICKUP_PILL) then
                    pocketCount = pocketCount + 1;
                    pocketIndex = pocketIndex + 1;
                    local neededPocketCount = 1--math.ceil((itemCount + 1) / 2);

                    local seed = ent.DropSeed;
                    local pickup = ent:ToPickup();
                    if (pocketIndex >= neededPocketCount) then
                        pocketIndex = 0;
                        itemCount = itemCount + 1;
                        -- Collectible.
                        local poolType = ItemPools:GetPoolForRoom(RoomType.ROOM_ERROR, seed);
                        local id = ItemPool:GetCollectible(poolType, true, seed, CollectibleType.COLLECTIBLE_BREAKFAST);
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, true, false, false);
                        pickup.Touched = false;
                        pickup.TargetPosition = pickup.Position
                        --if (THI.IsLunatic()) then
                            break;
                        --end
                    else
                        -- Pickups.
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, true, false, false);
                    end
                end
            end

            -- if (pocketCount <= 0) then
            --     local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
            --     if (Random() % 2 == 0) then
            --         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, pos, Vector.Zero, nil);
            --     else
            --         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, pos, Vector.Zero, nil);
            --     end
            -- end
        end
    end
    Arm:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard);

    local function PostPlayerUpdate(mod, player)
        local handCount = 0;
        local handTimes = Arm:GetHandUseTimes(player);
        local canPickUp = Arm:CanPickupPocket(player);
        if (not canPickUp) then
            handCount = 1;
            -- Drop other pocket items.
            for slot = 1, 0, -1 do
                local card = player:GetCard (slot);
                local pill = player:GetPill (slot);
                local willDrop = false;
                if (card > 0) then
                    willDrop = Arm:WillPocketDrop(false, card);
                elseif (pill > 0) then
                    local effect = Game():GetItemPool():GetPillEffect (pill, player);
                    willDrop = Arm:WillPocketDrop(true, effect);
                end
                if (willDrop) then
                    player:DropPocketItem (slot, player.Position);
                end
            end
        end


        -- Replace pocket item to Void Hand.
        local handID = nil;
        if (handTimes == 0) then
            handID = Arm.Hands.Three;
        elseif (handTimes == 1) then
            handID = Arm.Hands.Two;
        elseif (handTimes == 2) then
            handID = Arm.Hands.One;
        end

        if (not handID) then
            handCount = 0;
        end
        if (canPickUp) then
            handCount = 0;
        end

        local handNum = 0;
        for slot = 0, 1 do
            local active = player:GetActiveItem (slot + 2);
            local card = player:GetCard (slot);
            local isHand = Arm:IsCardVoidHand(card);
            if (handNum >= handCount) then
                if (isHand) then
                    player:SetCard(slot, 0);
                end
            else
                if (isHand and card ~= handID) then
                    player:SetCard(slot, 0);
                    handNum = handNum - 1;
                end
                if (card <= 0 and active <= 0) then
                    player:AddCard(handID);
                    handNum = handNum + 1;
                elseif (isHand) then
                    handNum = handNum + 1;
                end
            end
        end
    end
    Arm:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

    -- Prevent picking up pocket items.
    local function PrePickupCollision(mod, pickup, other, low)
        local isCard = pickup.Variant == PickupVariant.PICKUP_TAROTCARD;
        local isPill = pickup.Variant == PickupVariant.PICKUP_PILL;

        if (isCard or isPill) then
            local player = other:ToPlayer();
            if (player and not Arm:CanPickupPocket(player)) then
                local noPickup = Arm:WillPocketDrop(isPill, pickup.SubType);
                if (noPickup) then
                    return false;
                end
            end
        end
    end
    Arm:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PrePickupCollision);

    local function PostNewLevel(mod)
        for p, player in Detection.PlayerPairs() do
            Arm:ResetHandUseTimes(player);
        end
    end
    Arm:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);
end

return Arm;