local Inputs = CuerLib.Inputs;
local HoldingActive = CuerLib.HoldingActive;

local YinYangOrb = ModItem("Yin-Yang Orb", "YinYangOrb");

YinYangOrb.TearEntity = Isaac.GetEntityTypeByName("Yin-Yang Orb");
YinYangOrb.TearVariant = Isaac.GetEntityVariantByName("Yin-Yang Orb");
YinYangOrb.Config = {
    Damage = 20
}

function YinYangOrb:onUseItem(t, RNG, player, flags, slot)
    if (flags & UseFlag.USE_CARBATTERY <= 0) then
        return HoldingActive:SwitchHolding(t, player, slot, flags);
    end
end
YinYangOrb:AddCallback(ModCallbacks.MC_USE_ITEM, YinYangOrb.onUseItem, YinYangOrb.Item)

local function PostPlayerEffect(mod, player)
    HoldingActive:ReleaseOnShoot(player, YinYangOrb.Item)
end
YinYangOrb:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

function YinYangOrb:FireOrb(player, item, direction)
    local speed = direction * 15;
    THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
    local tearEnt = Isaac.Spawn(YinYangOrb.TearEntity, YinYangOrb.TearVariant, 0, player.Position, speed, player)
    local tear = tearEnt:ToTear();
    tear.FallingAcceleration = 3
    tear.FallingSpeed = -50
    tear.Size = 11
    tear.Height = -tear.Size
    tear.Scale = 3
    tear.CollisionDamage = YinYangOrb.Config.Damage;
    tear.TearFlags = TearFlags.TEAR_BOUNCE;
end
YinYangOrb:AddPriorityCallback(CuerLib.CLCallbacks.CLC_RELEASE_HOLDING_ACTIVE, CallbackPriority.LATE, YinYangOrb.FireOrb, YinYangOrb.Item);

function YinYangOrb:PostTearUpdate(tear)
    -- Bounce Orb
    if tear.Height >= -tear.Size then
        tear.FallingSpeed = -30
        tear.Height = -tear.Size
    end
    
    local spr = tear:GetSprite();
    spr.Rotation = spr:GetFrame() * 36
end


YinYangOrb:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, YinYangOrb.PostTearUpdate, YinYangOrb.TearVariant)
return YinYangOrb;