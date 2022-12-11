local Lib = LIB;

local Pickups = Lib:NewClass();

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

local PickingCard = nil;
local function PostCollectPickup(player, pickup)
    
    local pickupData = Pickups:GetPickupData(pickup);
    if (pickupData.Moved) then
        pickup.Position = pickupData.OriginPosition;
        pickupData.Move = false;
    end

    if (pickup.Variant == PickupVariant.PICKUP_TAROTCARD) then
        PickingCard = pickup;
    end

    Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_PICKUP_COLLECTED, pickup.Variant, player, pickup);
end

function Pickups:GetPickupData(pickup) 
    local data = Lib:GetEntityLibData(pickup);
    data._PICKUP = data._PICKUP or {
        Moved = false,
        OriginPosition = pickup.Position
    }
    return data._PICKUP;
end

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
        local condition = player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2) or player:NeedsCharge(3);
        -- Mega Battery.
        if (subType == BatterySubType.BATTERY_MEGA) then
            local config = Isaac.GetItemConfig();
            for slot = 0, 3 do
                local itemConfig = config:GetCollectible(player:GetActiveItem(slot));
                if (itemConfig and itemConfig.ChargeType ~= 2) then
                    local maxCharges = itemConfig.MaxCharges;
                    local battery = player:GetBatteryCharge(slot);
                    condition = condition or battery < maxCharges;
                end
                if (condition) then
                    break;
                end
            end
        end
        return condition;
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

    
    return Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_CAN_PICKUP_COLLECT, pickup.Variant, player, pickup);
end
function Pickups.Collect(player, pickup)
    if (Pickups.IsChest(pickup.Variant)) then
        pickup:TryOpenChest(player);
    else
        local beforePos = pickup.Position;
        pickup.Position = player.Position;

        local pickupData = Pickups:GetPickupData(pickup);
        pickupData.Moved = true;
        pickupData.OriginPosition = beforePos;
    end
end
function Pickups.TryCollect(player, pickup)
    if (Pickups.CanCollect(player, pickup)) then
        Pickups.Collect(player, pickup)
        return true;
    end
    return false;
end
-- From Fiend Folio.
function Pickups.GetBoneSwingPickupPlayer(pickup)
	--try to get a player from bone club swings
	if pickup:IsShopItem() then return nil end

	for _, knife in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, -1, 4, false, false)) do
		if knife.FrameCount > 0 and knife.Parent then
			local parent = knife.Parent
			if parent:ToPlayer() then
				local player = parent:ToPlayer()

				--find the center of the swing object
				knife = knife:ToKnife()
				local position = knife.Position
				local scale = 30
                -- Bone Scythe or Spirit Sword.
				if knife.Variant == 2 or knife.Variant == 10 then 
					scale = 42
				end
				scale = scale * knife.SpriteScale.X
				local offset = Vector(scale,0)
				offset = offset:Rotated(knife.Rotation)
				position = position + offset

				--do player checks
				if (position - pickup.Position):Length() < pickup.Size + scale and (not pickup:GetSprite():IsPlaying("Collect")) then --check if the player is touching it
					return player
				end
			end
		end
	end

	return nil
end



-- Events.
function Pickups:PostPickupUpdate(pickup)
    local data = Pickups:GetPickupData(pickup);
    if (data.Moved) then
        pickup.Position = data.OriginPosition;
        data.Moved = false;
    end
    
    local player = Pickups.GetBoneSwingPickupPlayer(pickup);
    if (player) then
        Pickups.TryCollect(player, pickup);
    end
end
Pickups:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Pickups.PostPickupUpdate);

function Pickups:PostPickupCollision(pickup, collider, low)
    local player = collider:ToPlayer();
    if (player) then
        if (Pickups.CanCollect(player, pickup)) then
            PostCollectPickup(player, pickup)
        end
    end
end
Pickups:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, Pickups.PostPickupCollision);

function Pickups:PostUpdate()
    if (PickingCard) then
        local pickup = PickingCard;
        PickingCard = nil;
        if (not pickup:Exists() or pickup:IsDead()) then
            for p, player in Lib.Players.PlayerPairs() do
                for slot = 0, 3 do
                    local card = player:GetCard(slot);
                    if (card == pickup.SubType) then
                        Isaac.RunCallbackWithParam(Lib.Callbacks.CLC_POST_PICK_UP_CARD, card, player, card);
                        return;
                    end
                end
            end
        end
    end
end
Pickups:AddCallback(ModCallbacks.MC_POST_UPDATE, Pickups.PostUpdate);


return Pickups;