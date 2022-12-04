local Dream = GensouDream;
local Collectibles = CuerLib.Collectibles;

local DreamCatcher = Dream.SpellCard();
DreamCatcher.NameKey = "#SPELL_CARD_DREAM_CATCHER"

local dreamLasers = {};
local dreamLaserBuffer = {};
local catcherProjColor = Color(1,1,1,1,0,0,1); 
    
local ProjParams = ProjectileParams();
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = catcherProjColor;
ProjParams.FallingAccelModifier = -0.15;
--ProjParams.FallingSpeedModifier = -0.05;

local function AddDreamLaser(laser) 
    table.insert(dreamLasers, {
        Laser = laser,
        TargetLength = 0,
        BounceLaser = nil
    });
end

local function TryBounce(startPoint, endPoint)
    -- Get bounce angle.
    
    local angle = (endPoint - startPoint):GetAngleDegrees();
    --- Get Grid.
    local room = THI.Game:GetRoom();
    local width = room:GetGridWidth();
    local gridIndex = room:GetGridIndex(endPoint);
    local grid = room:GetGridEntity(gridIndex);
    if (not grid) then
        return false, 0;
    end

    local gridPos = grid.Position;


    -- Get incident state.
    local state = -1;
    if ((gridPos - endPoint):Length() <= 0.03) then
        -- Equal.
        state = 4;
    else
        if (math.abs(gridPos.X - endPoint.X) <= 0.01) then
            -- Vertical.
            if (gridPos.Y < endPoint.Y) then
                -- Down.
                state = 1;
            else
                -- Up.
                state = 3;
            end
        elseif (math.abs(gridPos.Y - endPoint.Y) <= 0.01) then
            -- Horizontal.
            if (gridPos.X < endPoint.X) then
                -- Right.
                state = 0;
            else
                -- Left.
                state = 2;
            end
        else
            print("Warning: End point not in the line of grid position.");
            print("endPoint: "..tostring(endPoint)..", gridPos: "..tostring(gridPos));
        end
    end

    -- Wall Check.
    local function IsWall(index)
        local grid = room:GetGridEntity(index);
        return grid ~= nil and (grid.CollisionClass == GridCollisionClass.COLLISION_WALL or grid.CollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER);
    end
    local function IsUpWall() return IsWall(gridIndex - width); end
    local function IsDownWall() return IsWall(gridIndex + width); end
    local function IsLeftWall() 
        if (gridIndex % width == 0) then
            return false;
        end
        return IsWall(gridIndex - 1); 
    end
    local function IsRightWall() 
        if ((gridIndex + 1) % width == 0) then
            return false;
        end
        return IsWall(gridIndex + 1); 
    end

    local normalAngle = 0;
    local canBounce = false;

    if (state == 0) then
        -- Right.
        if (IsRightWall()) then
            canBounce = true;
            normalAngle = 0;
        end
    elseif (state == 1) then
        -- Down.
        if (IsDownWall()) then
            canBounce = true;
            normalAngle = 90;
        end
    elseif (state == 2) then
        -- Left.
        if (IsLeftWall()) then
            canBounce = true;
            normalAngle = 180;
        end
    elseif (state == 3) then
        -- Up.
        if (IsUpWall()) then
            canBounce = true;
            normalAngle = -90;
        end
    elseif (state == 4) then
        -- Equal.
        if (startPoint.X > gridPos.X ) then
            if (startPoint.Y > gridPos.Y)  then
                -- Incident from right-bottom.
                local right = IsRightWall();
                local down = IsDownWall();
                if (right == down) then
                    -- 45 degrees.
                    canBounce = true;
                    normalAngle = 45;
                elseif (not down) then
                    -- Horizontal.
                    canBounce = true;
                    normalAngle = 90;
                else
                    -- Vertical.
                    canBounce = true;
                    normalAngle = 0;
                end
            else
                -- Incident from right-top.
                local right = IsRightWall();
                local up = IsUpWall();
                if (right == up) then
                    -- 45 degrees.
                    canBounce = true;
                    normalAngle = -45;
                elseif (not up) then
                    -- Horizontal.
                    canBounce = true;
                    normalAngle = -90;
                else
                    -- Vertical.
                    canBounce = true;
                    normalAngle = 0;
                end
            end
        else
            
            if (startPoint.Y > gridPos.Y)  then
                -- Incident from left-bottom.
                local left = IsLeftWall();
                local down = IsDownWall();
                if (left == down) then
                    -- 45 degrees.
                    canBounce = true;
                    normalAngle = 135;
                elseif (not down) then
                    -- Horizontal.
                    canBounce = true;
                    normalAngle = 90;
                else
                    -- Vertical.
                    canBounce = true;
                    normalAngle = 180;
                end
            else
                -- Incident from left-top.
                local left = IsLeftWall();
                local up = IsUpWall();
                if (left == up) then
                    -- 45 degrees.
                    canBounce = true;
                    normalAngle = -135;
                elseif (not up) then
                    -- Horizontal.
                    canBounce = true;
                    normalAngle = -90;
                else
                    -- Vertical.
                    canBounce = true;
                    normalAngle = 180;
                end
            end
        end
    end

    if (not canBounce) then
        
        print("Warning: Cannot bounce.");
        print("endPoint: "..tostring(endPoint)..", gridPos: "..tostring(gridPos));
        print("normalAngle: "..tostring(normalAngle)..", state: "..tostring(state));
        print("startPoint: "..tostring(startPoint));
    end
    return canBounce, normalAngle * 2 - angle;
end

function DreamCatcher:GetDefaultData(doremy)
    return {
        Time = 0,
        Index = 0,
        Position = Vector.Zero,
        Projectiles = {}
    }
end

function DreamCatcher:CanCast(frame)
    return frame % 180 == 40
end
    
function DreamCatcher:CanWarning(frame)
    return self:CanCast(frame + 30);
end

function DreamCatcher:CanMove(frame)
    return frame % 60 == 0 and not self:CanCast(frame)
end

function DreamCatcher:GetDuration()
    return 1200;
end


function DreamCatcher:PostUpdate(doremy)
    local data = self:GetData(doremy);

    -- Fire bouncing projectiles.
    if (not Collectibles.IsAnyHasCollectible(CollectibleType.COLLECTIBLE_DREAM_CATCHER)) then
        if (data.Index > 0) then
            data.Time = data.Time - 1;
            if (data.Time <= 0) then
                data.Time = 5;
                local angleOffset = 0;
                if (data.Index % 2 == 0) then
                    angleOffset = 15;
                end
                for i =1, 8 do 
                    local angle = i * 45 + angleOffset;
                    local dir = Vector.FromAngle(angle);
                    local sourcePos = data.Position - dir * 90;
                    
                    ProjParams.BulletFlags = self:GetProjectileFlags(doremy) | ProjectileFlags.BOUNCE;
                    doremy:FireProjectiles (sourcePos, -dir * 4, 0, ProjParams);
                    ProjParams.BulletFlags = ProjectileFlags.BOUNCE;

                    -- local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, -dir * 4, doremy);
                    -- tearEntity:SetColor(catcherProjColor, -1, 0, false, true);
                    -- local proj = tearEntity:ToProjectile();
                    -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy) | ProjectileFlags.BOUNCE;
                    -- table.insert(data.Projectiles, proj);
                end
                data.Index = data.Index - 1;
            end
        end
    end

    -- -- Make projectiles float.
    -- for i, proj in pairs(data.Projectiles) do
    --     if (proj:Exists()) then
    --         proj.FallingSpeed = 0.05;
    --     else
    --         data.Projectiles[i] = nil;
    --     end
    -- end
end
function DreamCatcher:OnCast(doremy)
    local data = self:GetData(doremy);
    
    -- Fire lasers.
    local player = self.GetRandomPlayer();
    for i = 0,17 do
        local angle = i * 20;
        local sourcePos = player.Position - Vector.FromAngle(angle) * 120;
        local laserDir = angle + 30;
        local laser = EntityLaser.ShootAngle(3, sourcePos, laserDir, 90, Vector.Zero, doremy);
        laser.SubType =LaserSubType.LASER_SUBTYPE_NO_IMPACT;
        laser.DisableFollowParent = true;
        laser:SetOneHit(false);
        laser.MaxDistance = 1;
        laser:GetData().Doremy = doremy;
        AddDreamLaser(laser);
    end
    data.Position = player.Position;
    data.Time = 5;
    data.Index = 3;
    THI.Effects.SpellCardWave.Burst(doremy.Position);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_LASER);
    THI.Game:ShakeScreen(10);

    
    if (not Collectibles.IsAnyHasCollectible(CollectibleType.COLLECTIBLE_DREAM_CATCHER)) then

        local room = Game():GetRoom();

        THI.Game:ShakeScreen(30);
        SFXManager():Play(SoundEffect.SOUND_BEAST_INTRO_SCREAM, 2);

        local Soul = THI.Monsters.NightmareSoul;
        local margin = 80;
        local bottomRight = room:GetBottomRightPos ( )
        local vel = Vector(0, -1);
        for i = 0, 4 do
            local pos = room:GetRandomPosition (40);
            pos.Y = bottomRight.Y;
            local soul = Isaac.Spawn(Soul.Type, Soul.Variant, Soul.SubType, pos, vel, doremy);
            soul:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
            soul:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
        end
    end
end


function DreamCatcher:End(doremy)
    local Soul = THI.Monsters.NightmareSoul;
    for _, ent in ipairs(Isaac.FindByType(Soul.Type, Soul.Variant, Soul.SubType)) do
        ent:Die();
    end
end

local function dreamCatcherUpdate(mod)
    local room = THI.Game:GetRoom();
    for i, laserInfo in pairs(dreamLasers) do
        local laser = laserInfo.Laser;
        if (laser:Exists()) then
            
            if (not laser.Shrink) then
                laser.Size = 4;
                laser.SpriteScale = Vector(0.25, 1);
            end

            local dir = Vector.FromAngle(laser.Angle);
            if (laserInfo.TargetLength < 160) then
                laserInfo.TargetLength = laserInfo.TargetLength + 8;
            else 

                laser.Velocity = dir * 8;
            end
            laser:SetMaxDistance(laserInfo.TargetLength);

            
            local endPoint = EntityLaser.CalculateEndPoint(laser.Position, dir, Vector.Zero, nil, 20);
            local end2Start = endPoint - laser.Position;
            local length = end2Start:Length();
            -- if touched walls.
            if (length < laser.MaxDistance) then
                -- Create Bounced Dream Laser.
                if (laserInfo.BounceLaser == nil and laser.Timeout > 0) then
                    
                    local canBounce, bouncedAngle = TryBounce(laser.Position, endPoint);
                    --local bouncedAngle = GetBounceAngle(laser.Position, endPoint, gridPos, laser.Angle);
                    if (canBounce) then
                        local bouncedLaser = EntityLaser.ShootAngle(3, endPoint + end2Start:Normalized() * 3, bouncedAngle, laser.Timeout, Vector.Zero, laser.SpawnerEntity);
                        
                        bouncedLaser.SubType =LaserSubType.LASER_SUBTYPE_NO_IMPACT;
                        laserInfo.BounceLaser = bouncedLaser;
                        bouncedLaser.DisableFollowParent = true;
                        bouncedLaser:SetOneHit(false);
                        bouncedLaser:GetData().Doremy = laser:GetData().Doremy;
                        bouncedLaser.MaxDistance = 1;
                        table.insert(dreamLaserBuffer, bouncedLaser);
                    end
                end
                if (length <= 10) then
                    laser:Remove();
                    dreamLasers[i] = nil;
                end
            end
        else
            dreamLasers[i] = nil;
        end
    end


    -- Apply dream laser buffer.
    for k,v in pairs(dreamLaserBuffer) do
        AddDreamLaser(v);
        dreamLaserBuffer[k] = nil;
    end
end

Dream:AddCallback(ModCallbacks.MC_POST_UPDATE, dreamCatcherUpdate);

return DreamCatcher;