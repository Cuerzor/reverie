local Lib = LIB;
local Consts = Lib.Consts; 
local Math = Lib.Math;
local Synergies = Lib.Synergies;
local Entities = Lib.Entities;

local Familiars = Lib:NewClass();
Familiars.AnimationNames = {
    [Direction.NO_DIRECTION] = "Down",
    [Direction.LEFT] = "Side",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Side",
    [Direction.DOWN] = "Down"
}


function Familiars.GetFireVector(familiar, shootDirection, noModifiers, shootRange)
    shootRange = shootRange or 200;
    local player = familiar.Player;
    if (not noModifiers) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY)) then
            local enemies = Isaac.FindInRadius(familiar.Position, shootRange, EntityPartition.ENEMY);
            local enemy = nil;
            local Entities = Lib.Entities;
            for i, ent in pairs(enemies) do
                if (Entities.IsValidEnemy(ent) and (not enemy or familiar.Position:Distance(ent.Position) < familiar.Position:Distance(enemy.Position))) then
                    enemy = ent;
                end
            end
            if (enemy) then
                return (enemy.Position - familiar.Position):Normalized();
            end
        else
            local target = Synergies.GetMarkedTarget(player);
            if (target) then
                return (target.Position - familiar.Position):Normalized();
            end
        end
    end

    if (shootDirection ~= Direction.NO_DIRECTION) then
      if (shootDirection == Direction.LEFT) then
        return Vector(-1, 0);
      elseif (shootDirection == Direction.UP) then
        return Vector(0, -1);
      elseif (shootDirection == Direction.RIGHT) then
        return Vector(1, 0);
      elseif (shootDirection == Direction.DOWN) then
        return Vector(0, 1);
      end
    end
    
    return Vector.Zero;
end

function Familiars.ApplyTearEffect(player, tear)

    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
        tear.CollisionDamage = tear.CollisionDamage * 2;
    end

    if (player:HasTrinket(TrinketType.TRINKET_BABY_BENDER)) then
        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING;
        tear:SetColor(Consts.Colors.HomingTear, -1, 0, false, false);
    end
end

function Familiars.RunFireDelay(familiar, timer)
    if (timer >= 0) then
        local player = familiar.Player;
        local reduction = 1;
        if (player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY)) then
            reduction = reduction * 2;
        end
        timer = timer - reduction;
    end
    return timer;
end
function Familiars.DoFireCooldown(familiar)
    familiar.FireCooldown = Familiars.RunFireDelay(familiar, familiar.FireCooldown);
    familiar.HeadFrameDelay = familiar.HeadFrameDelay - 1;
end

function Familiars.CanFire(familiar)
    return familiar.FireCooldown < 0;
end

function Familiars.AnimationUpdate(familiar, vector, normalAnim, shootAnim)

    local angle = vector:GetAngleDegrees();
    if (vector:Length() <= 1e-08) then
        angle = 90;
    end
    local spriteDir = Math.GetDirectionByAngle(angle);
    
    if (familiar.HeadFrameDelay > 0) then
        Familiars.PlayShootAnimation(familiar, spriteDir, shootAnim);
    else
        Familiars.PlayNormalAnimation(familiar, spriteDir, normalAnim);
    end
end

function Familiars.PlayShootAnimation(familiar, dir, shootAnim)
    shootAnim = shootAnim or "FloatShoot";
    local sprite = familiar:GetSprite();
    if (dir ~= Direction.NO_DIRECTION) then
        sprite:Play(shootAnim..Familiars.AnimationNames[dir]);
        familiar.FlipX = dir == Direction.LEFT;
    end
end

function Familiars.PlayNormalAnimation(familiar, dir, normalAnim)
    normalAnim = normalAnim or "Float";
    local sprite = familiar:GetSprite();
    if (dir ~= Direction.NO_DIRECTION) then
        sprite:Play(normalAnim..Familiars.AnimationNames[dir]);
        familiar.FlipX = dir == Direction.LEFT;
    end
end

return Familiars;