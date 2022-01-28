local Lib = CuerLib;
local Callbacks = Lib.Callbacks;

local Pickups = {
}

local ChestVariants = {
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_HAUNTEDCHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_REDCHEST,
    PickupVariant.PICKUP_MOMSCHEST
}

function Pickups.SpawnFixedCollectible(id, pos, vel, spawner)
    local col = Isaac.Spawn(5, 100, 1, pos, vel, spawner):ToPickup();
    col:Morph(5, 100, id, false, false, true);
    return col;
end

function Pickups.IsChest(variant)
    for _, var in pairs(ChestVariants) do
        if (var == variant) then
            return true;
        end
    end
    return false;
end
function Pickups.IsSpecialPickup(variant)
    return variant == PickupVariant.PICKUP_TROPHY or
    variant == PickupVariant.PICKUP_BIGCHEST or
    variant == PickupVariant.PICKUP_BED;
end

function Pickups.CanCollect(player, pickup)
    local variant = pickup.Variant;
    local subType = pickup.SubType;

    if (pickup:IsShopItem()) then
        return false;
    end
    if (variant == PickupVariant.PICKUP_HEART) then
        if (subType == HeartSubType.HEART_BLACK) then
            return player:CanPickBlackHearts();
        elseif (subType == HeartSubType.HEART_BONE) then
            return player:CanPickBoneHearts();
        elseif (subType == HeartSubType.HEART_GOLDEN) then
            return player:CanPickGoldenHearts();
        elseif (subType == HeartSubType.HEART_FULL or subType == HeartSubType.HEART_HALF or subType == HeartSubType.HEART_DOUBLEPACK or subType == HeartSubType.HEART_SCARED) then
            return player:CanPickRedHearts();
        elseif (subType == HeartSubType.HEART_ROTTEN) then
            return player:CanPickRottenHearts();
        elseif (subType == HeartSubType.HEART_SOUL or subType == HeartSubType.HEART_HALF_SOUL) then
            return player:CanPickSoulHearts();
        elseif (subType == HeartSubType.HEART_BLENDED) then
            return player:CanPickSoulHearts() or player:CanPickRedHearts();
        else
            return true;
        end
    elseif (variant == PickupVariant.PICKUP_LIL_BATTERY) then
        return player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2) or player:NeedsCharge(3);
    elseif (variant == PickupVariant.PICKUP_COIN) then
        return subType ~= CoinSubType.COIN_STICKYNICKEL;
    elseif (variant == PickupVariant.PICKUP_KEY or
    variant == PickupVariant.PICKUP_BOMB or
    variant == PickupVariant.PICKUP_THROWABLEBOMB or
    variant == PickupVariant.PICKUP_POOP or
    variant == PickupVariant.PICKUP_GRAB_BAG or
    variant == PickupVariant.PICKUP_PILL or
    variant == PickupVariant.PICKUP_TAROTCARD or
    variant == PickupVariant.PICKUP_TRINKET) then
        return true;
    elseif (variant ~= PickupVariant.PICKUP_HAUNTEDCHEST and 
    variant ~= PickupVariant.PICKUP_MOMSCHEST and 
    Pickups.IsChest(variant)) then
        return true;
    end

    for i, func in pairs(Callbacks.Functions.CanCollect) do
        local result = func.Func(func.Mod, player, pickup);
        if (result ~= nil) then
            return result;
        end
    end

    return false;
end

function Pickups.TryCollect(player, pickup)
    if (Pickups.CanCollect(player, pickup)) then
        Pickups.Collect(player, pickup)
    end
end

function Pickups:GetPickupData(pickup) 
    local data = Lib:GetData(pickup);
    data._PICKUP = data._PICKUP or {
        FakeCollected = false,
        Moved = false,
        OriginPosition = pickup.Position
    }
    return data._PICKUP;
end

function Pickups.Collect(player, pickup)
    if (Pickups.IsChest(pickup.Variant)) then
        pickup:TryOpenChest(player);
    else
        local beforePos = pickup.Position;
        pickup.Position = player.Position;
        local pickupData = Pickups:GetPickupData(pickup) ;
        pickupData.Moved = true;
        pickupData.OriginPosition = beforePos;
    end
end

local function PostCollectPickup(player, pickup)
    
    local pickupData = Pickups:GetPickupData(pickup) ;
    if (pickupData.Moved) then
        pickup.Position = pickupData.OriginPosition;
    end

    for i, info in pairs(Callbacks.Functions.PostPickupCollected) do
        if (info.OptionalArg == nil or info.OptionalArg < 0 or info.OptionalArg == pickup.Variant) then
            info.Func(info.Mod, player, pickup);
        end
    end
    --pickupData.FakeCollected = true;
end

function Pickups.SetCollected(pickup, value)

    if (value) then
        pickup:GetSprite():Play("Collect");
        PostCollectPickup(pickup);
    end
end

function Pickups.AddCoinsOrCoinHearts(player, value)

    if (player:GetPlayerType() == PlayerType.PLAYER_KEEPER or 
    player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B) then
        local maxHearts = player:GetMaxHearts();
        local hearts = player:GetHearts();
        local empty = math.ceil((maxHearts - hearts) / 2);

        local costCoins = math.min(value, empty);
        player:AddHearts(costCoins * 2);
        value = value - costCoins;
    end

    player:AddCoins(value);
end

function Pickups:PostPickupUpdate(pickup)
    local pickupData = Pickups:GetPickupData(pickup);
    if (pickupData.FakeCollected) then
        if (pickup:GetSprite():IsFinished("Collect")) then
            pickup:Remove();
        end
    end
end

function Pickups:onPickupCollision(pickup, collider, low)
    local pickupData = Pickups:GetPickupData(pickup);
    if (pickupData.FakeCollected) then
        return true;
    else

        for i, info in pairs(Callbacks.Functions.PrePickupCollision) do
            if (info.OptionalArg == nil or info.OptionalArg < 0 or info.OptionalArg == pickup.Variant) then
                local result = info.Func(info.Mod, pickup, collider, low);
                if (result ~= nil) then
                    return result;
                end
            end
        end

        local player = collider:ToPlayer();
        if (player) then
            if (Pickups.CanCollect(player, pickup)) then
                PostCollectPickup(player, pickup);
            end
        end
    end
end

function Pickups:Register(mod)
    mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Pickups.onPickupCollision);
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Pickups.PostPickupUpdate);
end

function Pickups:Unregister(mod)
    mod:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Pickups.onPickupCollision);
    mod:RemoveCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Pickups.PostPickupUpdate);
end


return Pickups;