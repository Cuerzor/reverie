local ItemPools = CuerLib.ItemPools;
local Teller = {};
Teller.Keyword = "Fortune Teller"
function Teller:IsFortuneTeller(roomDesc)
    if (roomDesc and roomDesc.Data) then
        return string.find(roomDesc.Data.Name, Teller.Keyword) ~= nil;
    end
    return false;
end

function Teller:SpawnItem(pos, seed)
    local room = Game():GetRoom();
    local id = room:GetSeededCollectible(seed);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,id, pos, Vector.Zero, nil);
end

local function PostNewRoom(mod)
    local room = Game():GetLevel():GetCurrentRoomDesc();
    if (Teller:IsFortuneTeller(room)) then
        local StarseekerBall = THI.Pickups.StarseekerBall;

        local maxIndex = 0;
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            local pickup = ent:ToPickup();
            if (maxIndex < pickup.OptionsPickupIndex) then
                maxIndex = pickup.OptionsPickupIndex;
            end
        end

        for _, ent in pairs(Isaac.FindByType(StarseekerBall.Type, StarseekerBall.Variant)) do
            local pickup = ent:ToPickup();
            pickup.OptionsPickupIndex = maxIndex + 1;
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


local function GridUpdate(index, prevGrid, newGrid)
    local plate = GridEntityType.GRID_PRESSURE_PLATE;
    local var = 10;
    if (prevGrid.Type == plate and prevGrid.Variant == var and prevGrid.State == 0 and
    (newGrid.Type == plate and newGrid.Variant == var and newGrid.State == 3)) then
        local game = Game();
        local room = game:GetRoom();
        local roomDesc = game:GetLevel():GetCurrentRoomDesc();
        if (Teller:IsFortuneTeller(roomDesc)) then
            Teller:SpawnItem(room:GetCenterPos(), room:GetSpawnSeed());
        end
    end
end
THI:OnGridUpdate(GridUpdate, 97)
return Teller;