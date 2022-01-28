local Familiars = CuerLib.Familiars;
local Math = CuerLib.Math;
local Inputs = CuerLib.Inputs;
local Illusion = ModEntity("Rabbit Illusion", "Illusion")

function Illusion.GetIllusionData(illusion, init)
    return Illusion:GetData(illusion, init, function() return {
        Index = 0,
        Count = 0,
        Angle = 0,
        Interpolate = 0
    } end);
end

function Illusion.TryFireTears(illusion, shootingInput)
    if (Familiars:canFire(illusion)) then
        local tear = Isaac.Spawn(2, 1, 0, illusion.Position, shootingInput:Normalized() * 12 + illusion.Velocity / 3, illusion):ToTear();
        
        local damage = 3.5;
        if (illusion.Player) then
            if (illusion.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                damage = damage * 2;
            end

            if (illusion.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER)) then
                tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING;
                tear:SetColor(Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549), -1, 0, false, false);
            end
        end
        
        local sqrted = math.sqrt(damage);
        -- tear Scale.
        tear.Scale = sqrted * 0.23 + damage * 0.01 + 0.55;
        tear.CollisionDamage = damage;
        illusion.FireCooldown = 15;
    end
end


function Illusion:postIllusionUpdate(illusion)
    local player = illusion.Player;
    if (player) then
        local shootingInput = Inputs.GetRawShootingVector(player);
        local data = Illusion.GetIllusionData(illusion, true);
        local angle = 0;
        local shootAngle = 90;
        if (shootingInput:Length() > 0.1 and player:IsExtraAnimationFinished()) then
            Illusion.TryFireTears(illusion, shootingInput);
            shootAngle = shootingInput:GetAngleDegrees();
        end
        if (data.Count > 0) then
            angle = data.Index / data.Count * 360 + shootAngle;
        end
        angle = angle % 360;
        local currentAngle = data.Angle;

        local angleDiff = (angle - currentAngle) % 360;

        if (angleDiff >= 180) then
            angleDiff = angleDiff - 360;
        end
        local targetAngle = (currentAngle + angleDiff / 6) % 360;
        local targetPos = player.Position + Vector.FromAngle(targetAngle) * 80;
        illusion.Velocity = targetPos - illusion.Position;
        data.Angle = targetAngle;

        local moveDir = player:GetMovementDirection();
        
        local anim = "FaceDown";
        if (moveDir == Direction.RIGHT) then
            anim = "FaceRight";
        elseif (moveDir == Direction.DOWN) then
            anim = "FaceDown";
        elseif (moveDir == Direction.UP) then
            anim = "FaceUp";
        elseif (moveDir == Direction.LEFT) then
            anim = "FaceLeft";
        end
        illusion:GetSprite():SetAnimation(anim, false);

        Familiars:DoFireCooldown(illusion);
        local damage =  player.Damage * 0.6;
        illusion.CollisionDamage = damage;
    end
end
Illusion:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Illusion.postIllusionUpdate, Illusion.Variant);


return Illusion;