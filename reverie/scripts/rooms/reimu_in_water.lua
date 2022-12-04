local Base = {};
Base.ID = 5803;
function Base:IsReimuInWater(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Base.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Base:IsReimuInWater(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE) then
            if (subtype == CollectibleType.COLLECTIBLE_SAD_ONION) then
                return {id, variant, THI.Collectibles.YinYangOrb.Item};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)

return Base;