local Base = {};
Base.ID = 5800;
function Base:IsDrunkardsBase(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return roomDesc.Data.Type == RoomType.ROOM_ERROR and roomDesc.Data.Variant == Base.ID;
    end
    return false;
end

local function PreRoomEntitySpawn(mod, id, variant, subtype, index, seed)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Base:IsDrunkardsBase(room)) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE) then
            if (subtype == CollectibleType.COLLECTIBLE_SAD_ONION) then
                return {id, variant, THI.Collectibles.YinYangOrb.Item};
            elseif (subtype == CollectibleType.COLLECTIBLE_INNER_EYE) then
                return {id, variant, THI.Collectibles.MarisasBroom.Item};
            end
        end
    end
end
THI:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, PreRoomEntitySpawn)


local function PostNewRoom(mod)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Base:IsDrunkardsBase(room)) then
        local ZunKeeper = THI.Monsters.ZunKeeper;
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER, 3)) do
            ent.SubType = ZunKeeper.SubType;
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

return Base;