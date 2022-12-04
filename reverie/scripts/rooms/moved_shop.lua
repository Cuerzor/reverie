local MovedShop = {};
MovedShop.Keyword = "Moved Shop"
function MovedShop:IsMovedShop(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return string.find(roomDesc.Data.Name, MovedShop.Keyword) ~= nil;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE and subtype == 1) then
        local room = Game():GetLevel():GetCurrentRoomDesc();
        if (MovedShop:IsMovedShop(room)) then
            return {id, variant, THI.Collectibles.ExchangeTicket.Item};
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)

return MovedShop;