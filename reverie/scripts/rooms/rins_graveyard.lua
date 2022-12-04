local Base = {};
Base.ID = 5802;
function Base:IsGraveyard(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Base.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Base:IsGraveyard(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE) then
            if (subtype == CollectibleType.COLLECTIBLE_UNDEFINED) then
                return {id, variant, THI.Collectibles.DeletedErhu.Item};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)

return Base;