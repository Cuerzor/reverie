local Room = {};
Room.ID = 5806;
function Room:IsStake(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Room.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Room:IsStake(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE) then
            if (subtype == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then
                return {id, variant, THI.Collectibles.MarisasBroom.Item};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)

return Room;