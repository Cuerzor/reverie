local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;

local Sunny = ModEntity("Sunny Fairy", "SUNNY_FAIRY")


function Sunny:GetAwakedCount(player)
    local Fairies = THI.Shared.LightFairies;
    return Fairies:GetAwakedFairyNum(player, Sunny.Variant)
end

function Sunny:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, position, velocity, familiar):ToTear();
    
    tear:AddTearFlags(TearFlags.TEAR_BURN);
    
    tear.CollisionDamage = 4;
    tear:SetColor(Consts.Colors.BurnTear, -1, 0)
    Familiars.ApplyTearEffect(player, tear);
    if (player:HasCollectible(THI.Collectibles.LunarFairy.Item) and player:HasCollectible(THI.Collectibles.StarFairy.Item)) then
        tear.CollisionDamage = tear.CollisionDamage * 3;
    end
    tear:ResetSpriteScale();
    return tear;
end

Sunny.FairyInfo = {
    AwakeRoomTypes = { [RoomType.ROOM_BOSS] = true },
    AwakeAwards = { {Type = 5, Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_FULL, Count = 3} },
    FireTear = function(familiar, dir) Sunny:FireTear(familiar, familiar.Position, dir * 10) end;
}
THI.Shared.LightFairies:AddFairy(Sunny.Variant, Sunny.FairyInfo);

local function PostUseTheSun(mod, card, player, flags)
    local Fairies = THI.Shared.LightFairies;
    for i, ent in pairs(Isaac.FindByType(Sunny.Type, Sunny.Variant, Fairies.SubTypes.DORMANT)) do
        THI.SFXManager:Play(SoundEffect.SOUND_POWERUP_SPEWER);
        Fairies:WakeFairy(ent:ToFamiliar());
    end
end
Sunny:AddCallback(ModCallbacks.MC_USE_CARD, PostUseTheSun, Card.CARD_SUN);

return Sunny;