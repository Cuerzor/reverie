local FoodPickup = ModEntity("Cheese Food", "Food");

FoodPickup.SubTypes = {
    CHEESE = 1,
    BREAD = 2,
    STEAK = 3
}


----------------
-- Foods
----------------
function FoodPickup:GetFeedHunger(pickup)
    if (pickup.SubType == self.SubTypes.CHEESE) then
        return 0.5;
    elseif (pickup.SubType == self.SubTypes.BREAD) then
        return 1;
    elseif (pickup.SubType == self.SubTypes.STEAK) then
        return 2;
    end
    return 0;
end

local function PostPickupUpdate(mod, pickup)
    if (pickup.SubType == 0) then
        local chance = pickup.DropSeed % 6;
        local type = pickup.Type;
        local variant = pickup.Variant;
        local subType = FoodPickup.SubTypes.CHEESE;
        if (chance >= 5) then
            subType = FoodPickup.SubTypes.STEAK;
        elseif(chance >= 3) then
            subType = FoodPickup.SubTypes.BREAD;
        end
        pickup:Morph (type, variant, subType, false, true, true );
        return;
    end
end
FoodPickup:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, FoodPickup.Variant);


function FoodPickup:PrePickupCollision(pickup, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local player = other:ToPlayer();
        local Hunger = THI.Collectibles.Hunger;
        if (player:HasCollectible(Hunger.Item)) then
            local feed = FoodPickup:GetFeedHunger(pickup);
            Hunger:Feed(player, feed);


            local pickupEffect = THI.Effects.PickupEffect;
            local effect = Isaac.Spawn(pickupEffect.Type, pickupEffect.Variant, 0, pickup.Position, Vector.Zero, pickup);
            local spr = effect:GetSprite();
            spr:Load(pickup:GetSprite():GetFilename(), true)
            spr:Play("Collect");

            
            pickup:Remove();
            return true;
        end
    end
end
FoodPickup:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, FoodPickup.PrePickupCollision, FoodPickup.Variant);


return FoodPickup;