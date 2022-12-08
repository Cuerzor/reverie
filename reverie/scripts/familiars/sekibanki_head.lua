local Familiars = CuerLib.Familiars;
local Math = CuerLib.Math;
local Consts = CuerLib.Consts;
local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local Head = ModEntity("Sekibanki Head", "SEKIBANKI_HEAD");

Head.DirectionAnimations = {
    [Direction.NO_DIRECTION] = "Down",
    [Direction.LEFT] = "Left",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Right",
    [Direction.DOWN] = "Down"
}
Head.Mode = {
    ORBITAL = 0,
    FIXED = 1,
    THROWN = 2
}
local HeadFloatOffset =  Vector(0, -10);

function Head.GetHeadData(head, init)
    local function getter()
        return {
            Orbiting = false,
            Mode = Head.Mode.ORBITAL,
            Gravity = 0,
            FallingSpeed = 0,
            ReturnFrames = 0,
            ReturnPos = Vector.Zero,
            ReturnOffset = Vector.Zero;
        }
    end
    return Head:GetData(head, init, getter);
end
function Head.FireLaser(spawner, position, fireDir, positionOffset)
    local laser = EntityLaser.ShootAngle (2, position, fireDir:GetAngleDegrees(), 2, positionOffset + spawner.PositionOffset + Vector(0, -20), spawner);
    laser.Parent = spawner;

    local player;
    local familiar = spawner:ToFamiliar();
    if (familiar) then
        player = familiar.Player;
    end

    laser.CollisionDamage = 3.5 / 2;
    if (player) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
            laser.CollisionDamage = 3.5;
        end
        
        if (player:HasTrinket(TrinketType.TRINKET_BABY_BENDER)) then
            laser:AddTearFlags(TearFlags.TEAR_HOMING)
            laser:SetColor(Consts.Colors.HomingTear, 0, 0)
        end
    end
    return laser;
end
function Head.FireLasers(head, headDir, fireDir, offset)
    offset = offset or Vector.Zero;
    local laserStartOffset = Consts.DirectionVectors[headDir];
    local laserOffset = laserStartOffset:Rotated(90) * 8;
    local positionOffset;
    positionOffset = laserOffset;
    Head.FireLaser(head, head.Position + laserStartOffset * 8 + positionOffset, fireDir, offset);

    positionOffset = -laserOffset;
    Head.FireLaser(head, head.Position + laserStartOffset * 8 + positionOffset, fireDir, offset);
end

local function SetOrbital(head, value)
    local data = Head.GetHeadData(head, true);
    if (data.IsOrbiting ~= value) then
        data.IsOrbiting = value;
        if (value) then
            head:ToFamiliar():AddToOrbit(5);
            head.OrbitDistance = EntityFamiliar.GetOrbitDistance (1);
            head.OrbitSpeed = 0.045;
            head.PositionOffset = HeadFloatOffset
        else
            head:ToFamiliar():RemoveFromOrbit();
        end
    end
end

function Head.SetMode(head, mode)
    local data = Head.GetHeadData(head, true);
    data.Mode = mode;
    SetOrbital(head, mode == Head.Mode.ORBITAL);
    if (mode == Head.Mode.FIXED) then
        head.PositionOffset =HeadFloatOffset;
    end
    if (mode == Head.Mode.THROWN) then
        data.Gravity = 1;
        data.FallingSpeed = -5;
        head.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
    else
        head.GridCollisionClass = GridCollisionClass.COLLISION_NONE
    end
end

function Head.GetMode(head)
    local data = Head.GetHeadData(head, false);
    return (data and data.Mode) or Head.Mode.ORBITAL;
end

do
    local function PostHeadInit(mod, head)
        Head.SetMode(head, Head.Mode.ORBITAL);
    end
    Head:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostHeadInit, Head.Variant);

    local function PostHeadUpdate(mod, familiar)

        local player = familiar.Player;
        local data = Head.GetHeadData(familiar, true);
        local sprite = familiar:GetSprite();
    
        local orbitalTargetPos = player.Position + player.Velocity+ familiar:GetOrbitPosition(Vector.Zero);
        
        local dir = player:GetFireDirection();
        local fireDir = Familiars:GetFireVector(familiar, dir, false, 1000);
        Familiars:DoFireCooldown(familiar);
        if (dir ~= Direction.NO_DIRECTION and Familiars:canFire(familiar) and (player == nil or player:IsExtraAnimationFinished())) then
            
            familiar.HeadFrameDelay = 5;
            familiar.FireCooldown = 10;

            Head.FireLasers(familiar, dir, fireDir);
            familiar.ShootDirection = Math.GetDirectionByAngle(fireDir:GetAngleDegrees());
        end
    
        if (Familiars:canFire(familiar)) then
            familiar.ShootDirection = player:GetHeadDirection();
        end
        local direction = familiar.ShootDirection;
        
        Familiars:AnimationUpdate(familiar, Consts.DirectionVectors[direction], "Idle", "Shoot");
    
        -- Motion.
        if (data.Mode == Head.Mode.ORBITAL) then
            familiar.Velocity = (orbitalTargetPos - familiar.Position);
        elseif (data.Mode == Head.Mode.THROWN) then
            local hasDecap = false;
            for i, decap in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DECAP_ATTACK)) do
                if (CompareEntity(decap.SpawnerEntity,player)) then
                    hasDecap = true;
                    break;
                end
            end
            if (hasDecap) then
                SetOrbital(familiar,false);
                data.FallingSpeed = data.FallingSpeed or 0;
                if (familiar.PositionOffset.Y < 0) then
                    familiar.PositionOffset = familiar.PositionOffset + Vector(0, data.FallingSpeed);
                else
                    if (familiar.PositionOffset.Y > 0) then
                        familiar.PositionOffset = Vector(familiar.PositionOffset.X, 0);
                    end
                    familiar:MultiplyFriction(0.85);
                end
                data.Gravity = data.Gravity or 0;
                data.FallingSpeed = data.FallingSpeed + data.Gravity;
                data.ReturnFrames = 0;
                data.ReturnPos = familiar.Position;
                data.ReturnOffset = familiar.PositionOffset;
            else
                SetOrbital(familiar, true);
                local maxFrames = 10;
                data.ReturnFrames = (data.ReturnFrames or 0) + 1;
                local lerp = math.min((data.ReturnFrames / maxFrames) ^ 2, 1);
                local aPos = data.ReturnPos;
                local bPos = orbitalTargetPos;
                familiar.Velocity = ((bPos) * lerp + (aPos) * (1 - lerp)) - familiar.Position;
                familiar.PositionOffset = (HeadFloatOffset) * lerp + (data.ReturnOffset or Vector.Zero) * (1 - lerp);
                if (data.ReturnFrames > maxFrames) then
                    Head.SetMode(familiar, Head.Mode.ORBITAL);
                end
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostHeadUpdate, Head.Variant);


    -- Decap Attack.
    local function PostDecapUpdate(mod, familiar)
        if (familiar.FrameCount == 1) then
            
            local player = familiar.SpawnerEntity:ToPlayer();
            if (player) then
                for i, head in pairs(Isaac.FindByType(Head.Type, Head.Variant)) do
                    local mode = Head.GetMode(head);
                    if (mode == Head.Mode.ORBITAL) then
                        head.Velocity = familiar.Velocity;
                        Head.SetMode(head, Head.Mode.THROWN);
                    end
                end
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostDecapUpdate, FamiliarVariant.DECAP_ATTACK);

    local function PostNewRoom(mod)
        for i, head in pairs(Isaac.FindByType(Head.Type, Head.Variant)) do
            local mode = Head.GetMode(head);
            if (mode == Head.Mode.THROWN) then
                Head.SetMode(head, Head.Mode.ORBITAL);
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

    
    local function PostHeadCollision(mod, head, other, low)
        if (other.Type == EntityType.ENTITY_PROJECTILE) then
            local proj = other:ToProjectile();
            if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                proj:Die();
            end
        end
    end
    Head:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, PostHeadCollision, Head.Variant);
end

return Head;