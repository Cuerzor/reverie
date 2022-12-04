local Tentacles = {};
Tentacles.ID = 5808;
function Tentacles:IsRoom(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Tentacles.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Tentacles:IsRoom(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE) then
            if (subtype == CollectibleType.COLLECTIBLE_LEMEGETON) then
                return {id, variant, THI.Collectibles.Grimoire.Item};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)
return Tentacles;