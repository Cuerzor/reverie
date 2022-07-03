local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;

local Star = ModEntity("Star Fairy", "STAR_FAIRY")


function Star:GetAwakedCount(player)
    local Fairies = THI.Shared.LightFairies;
    return Fairies:GetAwakedFairyNum(player, Star.Variant)
end

function Star:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, position, velocity, familiar):ToTear();
    
    tear:AddTearFlags(TearFlags.TEAR_HOMING);
    
    tear.CollisionDamage = 2;
    tear:SetColor(Consts.Colors.HomingTear, -1, 0)
    Familiars.ApplyTearEffect(player, tear);
    if (player:HasCollectible(THI.Collectibles.SunnyFairy.Item) and player:HasCollectible(THI.Collectibles.LunarFairy.Item)) then
        tear.CollisionDamage = tear.CollisionDamage * 3;
    end
    tear:ResetSpriteScale();
    return tear;
end

Star.FairyInfo = {
    AwakeRoomTypes = { [RoomType.ROOM_TREASURE] = true, [RoomType.ROOM_PLANETARIUM] = true },
    AwakeAwards = { {Type = 5, Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_NORMAL, Count = 1} },
    FireTear = function(familiar, dir) Star:FireTear(familiar, familiar.Position, dir * 10) end;
}
THI.Shared.LightFairies:AddFairy(Star.Variant, Star.FairyInfo);

return Star;