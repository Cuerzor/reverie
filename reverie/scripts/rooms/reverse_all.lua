local Room = {};
Room.ID = 5807;
function Room:IsRoom(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Room.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Room:IsRoom(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_TAROTCARD) then
            if (subtype == Card.CARD_FOOL) then
                return {id, variant, THI.Cards.SoulOfSeija.ID};
            elseif (subtype == Card.CARD_REVERSE_FOOL) then
                return {id, variant, THI.Cards.SoulOfSeija.ReversedID};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)
return Room;