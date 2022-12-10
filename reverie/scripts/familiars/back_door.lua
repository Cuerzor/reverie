local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;

local Door = ModEntity("Back Door", "BACK_DOOR");
Door.Distance = Vector(40, 30);
Door.AttractRadius = 120;



local function PostDoorInit(mod, familiar)
    familiar.PositionOffset = Vector(0, -10);
end
Door:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostDoorInit, Door.Variant)

local function PostDoorUpdate(mod, familiar)
    local player = familiar.Player;
    if (player) then
        local targetAngle = (180 + player:GetSmoothBodyRotation ( )) % 360;
        local currentAngle = (familiar.Position - player.Position):GetAngleDegrees() % 360;

        local includedAngle = targetAngle - currentAngle;
        if (includedAngle > 180) then
            includedAngle = includedAngle - 360;
        elseif (includedAngle < -180) then
            includedAngle = 360 + includedAngle;
        end
        local angle = includedAngle * 0.5 + currentAngle;
        familiar.SpriteRotation = angle - 90;
        local offset = Vector.FromAngle(angle) * Door.Distance;
        familiar.Velocity = familiar.Velocity * 0.5 + (player.Position + offset - familiar.Position) * 0.5;
    end

    -- -- Attract Bullets.
    -- for i, ent in pairs(Isaac.FindInRadius(familiar.Position, Door.AttractRadius, EntityPartition.BULLET)) do
    --     local proj = ent:ToProjectile();
    --     if (proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
    --         -- Check included angle.
    --         local doorAxis = Vector.FromAngle(familiar.SpriteRotation + 90);
    --         local familiarPos = familiar.Position;
    --         local projToDoor = (proj.Position - familiarPos):Normalized();
    --         local rad = math.acos(doorAxis:Dot(projToDoor))
    --         local includedAngle = rad * math.deg(rad);

    --         if (includedAngle < 30) then
    --             local vel = proj.Velocity;
    --             local speed = vel:Dot(-projToDoor);
    --             if (speed < 5) then 
    --                 proj:AddVelocity((familiarPos - proj.Position):Resized(math.min(1, 5 - speed)));
    --             end
    --         end
    --     end
    -- end
end
Door:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostDoorUpdate, Door.Variant)

local function PostDoorCollision(mod, familiar, other, low)
    local proj = other:ToProjectile();
    if (proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
        proj:Remove();
    end
end
Door:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PostDoorCollision, Door.Variant)

return Door;