local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;

local Lunar = ModEntity("Lunar Fairy", "LUNAR_FAIRY")


function Lunar:GetAwakedCount(player)
    local Fairies = THI.Shared.LightFairies;
    return Fairies:GetAwakedFairyNum(player, Lunar.Variant)
end

function Lunar:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, position, velocity, familiar):ToTear();
    
    tear:AddTearFlags(TearFlags.TEAR_BOUNCE);
    
    tear.CollisionDamage = 3;
    tear:SetColor(Consts.Colors.BounceTear, -1, 0)
    Familiars.ApplyTearEffect(player, tear);
    if (player:HasCollectible(THI.Collectibles.SunnyFairy.Item) and player:HasCollectible(THI.Collectibles.StarFairy.Item)) then
        tear.CollisionDamage = tear.CollisionDamage * 3;
    end
    tear:ResetSpriteScale();
    return tear;
end

Lunar.FairyInfo = {
    AwakeRoomTypes = { [RoomType.ROOM_SECRET] = true, [RoomType.ROOM_SUPERSECRET] = true, [RoomType.ROOM_ULTRASECRET] = true },
    AwakeAwards = { {Type = 5, Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_NORMAL, Count = 2} },
    FireTear = function(familiar, dir) Lunar:FireTear(familiar, familiar.Position, dir * 10) end;
}
THI.Shared.LightFairies:AddFairy(Lunar.Variant, Lunar.FairyInfo);

return Lunar;