local Hidden = {};
Hidden.Keyword = "Hidden Roukanken"
function Hidden:IsHiddenRoukanken(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return string.find(roomDesc.Data.Name, Hidden.Keyword) ~= nil;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE and subtype == CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        local room = Game():GetLevel():GetCurrentRoomDesc();
        if (Hidden:IsHiddenRoukanken(room)) then
            return {id, variant, THI.Collectibles.Roukanken.Item};
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)

return Hidden;