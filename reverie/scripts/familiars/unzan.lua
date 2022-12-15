local Familiars = CuerLib.Familiars;
local Math = CuerLib.Math;
local Consts = CuerLib.Consts;

local Unzan = ModEntity("Unzan Familiar", "UNZAN_FAMILIAR")
Unzan.TearColor = Color(1,1,1,1,1,0.5,1);

function Unzan:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIST, 0, position, velocity, familiar):ToTear();
    
    tear:AddTearFlags(TearFlags.TEAR_PUNCH);
    tear.FallingAcceleration = 1
    local rng = player:GetCollectibleRNG(THI.Collectibles.Unzan.Item);
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_DEPRESSION)) then
        local range = 1 / math.max(2, 11-player.Luck);
        if (rng:RandomInt(100) < range * 100) then
            tear:AddTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN);
        end
    end
    local Thunder = THI.Collectibles.HolyThunder;
    if (player:HasCollectible(Thunder.Item)) then
        if (Thunder:RandomThunder(rng:Next(), player.Luck)) then
            Thunder:SetTearThunder(tear, true);
            tear:AddTearFlags(TearFlags.TEAR_JACOBS);
        end
    end
    
    tear.Mass = 0;
    tear.CollisionDamage = 0.5;
    tear:SetColor(Unzan.TearColor, -1, 0)
    Familiars.ApplyTearEffect(player, tear);
    tear:ResetSpriteScale();
    return tear;
end

local function PostUnzanInit(mod, familiar)
    familiar.PositionOffset = Vector(0, -10);
end
Unzan:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostUnzanInit, Unzan.Variant)

local function PostUnzanUpdate(mod, familiar)
    local player = familiar.Player;
    local dir = player:GetFireDirection();
    
    local fireDir = Familiars.GetFireVector(familiar, dir)
    Familiars.DoFireCooldown(familiar);

    local maxFireCooldown = 2;

    if (dir ~= Direction.NO_DIRECTION) then
        local tearOffset = fireDir:Rotated(90):Resized(24);
        tearOffset = tearOffset * Vector(familiar.SpriteScale.X, familiar.SpriteScale.Y * 0.5);
        local index = math.ceil(familiar:GetSprite():GetFrame() % 4 / 2)
        while (Familiars.CanFire(familiar)) do
            familiar.HeadFrameDelay = 2;
            familiar.FireCooldown = familiar.FireCooldown + maxFireCooldown;
            local tearPosition = familiar.Position;
            if (index == 1) then
                tearPosition = tearPosition + tearOffset;
            else
                tearPosition = tearPosition - tearOffset;
            end

            local vel = fireDir * 25;
            vel = vel + player:GetTearMovementInheritance(fireDir);
            Unzan:FireTear(familiar, tearPosition, vel);
            index = (index + 1) % 2;

            THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME, 0.2)
            familiar.ShootDirection = Math.GetDirectionByAngle(fireDir:GetAngleDegrees());
        end
    end

    if (Familiars.CanFire(familiar)) then
        familiar.ShootDirection = Direction.NO_DIRECTION;
    end
    
    if (fireDir:Length() < 0.1) then
        local moveDir = player:GetMovementDirection();
        if (moveDir ~= Direction.NO_DIRECTION) then
            fireDir = Consts.DirectionVectors[moveDir];
        else
            fireDir = Vector(0, 1);
        end
    end
    Familiars.AnimationUpdate(familiar, fireDir, "Float", "Shoot")
    
    -- Motion.
    local targetPos = player.Position + Vector(0, 3) - fireDir * 40;
    familiar.Velocity = familiar.Velocity * 0.5 + (targetPos - familiar.Position) / 5 * 0.5;
    
end
Unzan:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostUnzanUpdate, Unzan.Variant)

return Unzan;