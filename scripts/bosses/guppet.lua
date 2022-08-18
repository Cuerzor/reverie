local Bosses = CuerLib.Bosses;
local EntityExists = CuerLib.Detection.EntityExists;
local Grids = CuerLib.Grids;
local Guppet = ModEntity("Guppet", "GUPPET")

do
    local MaggotParams = ProjectileParams();
    MaggotParams.FallingAccelModifier = 1;
    MaggotParams.BulletFlags = ProjectileFlags.EXPLODE;
    MaggotParams.Color = Color(0,1,0,1,0,0,0);
    Guppet.MaggotParams = MaggotParams;

    local DevilParams = ProjectileParams();
    DevilParams.BulletFlags = ProjectileFlags.SIDEWAVE;
    Guppet.DevilParams = DevilParams;

    local NormalParams = ProjectileParams();
    Guppet.NormalParams = NormalParams;
end

-- Add Boss Room.
do
    local n = Grids.RoomGrids.Null;
    local roomConfig = {
        ID = "reverie:guppet",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/guppet",
        CustomRooms = {
            {
                Name = "Guppet1",
                ReplaceChance = 25,
                BossID = "reverie:guppet",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE4_1}
                },
                Music = Music.MUSIC_BOSS2,
                VanishingTwinTarget = Vector(320, 280),
                Grids = {
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                },
                Bosses = {
                    { Type = Guppet.Type, Variant = Guppet.Variant, SubType = 0, Position = Vector(320, 280)}
                }
            }
        }
    }
    local bossConfig = {
        Name = "Guppet",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE4_1, Weight = 1}
            }
        },
        Type = Guppet.Type,
        Variant = Guppet.Variant,
        PortraitPath = "gfx/reverie/ui/boss/portrait_587.0_guppet.png",
        PortraitOffset = Vector(0, -30),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_587.0_guppet.png",
            zh = "gfx/reverie/ui/boss/bossname_587.0_guppet_zh.png",
            jp = "gfx/reverie/ui/boss/bossname_587.0_guppet_jp.png"
        },
        IsEnabled = function(self)
            return THI.IsBossEnabled(self.Name);
        end
    }
    Bosses:SetBossConfig("reverie:guppet", bossConfig, roomConfig);
end

-- Main.
do

    Guppet.States = {
        IDLE = 0,
        FLY = 11,
        SPIDER = 12,
        MAGGOT = 13,
        ANGEL = 14,
        DEVIL = 15,
    }
    local RottenLaserColor = Color(1,1,1,1,0,0,0);
    RottenLaserColor:SetColorize(1.5,1.8,1,1);
    function Guppet.GetGuppetData(guppet, init)
        local function getter()
            return {
                ChargeCooldown = 0,
                Brimstones = {},
                StatePool = {}
            }
        end
        return Guppet:GetData(guppet, init, getter);
    end

    local function PostGuppetInit(mod, guppet)
        
        if (guppet.Variant == Guppet.Variant) then
            guppet.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end
    Guppet:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostGuppetInit, Guppet.Type);

    
    local validStates = {
        Guppet.States.FLY,
        Guppet.States.SPIDER,
        Guppet.States.ANGEL,
        Guppet.States.DEVIL
    }

    local function PostGuppetUpdate(mod, guppet)
        if (guppet.Variant == Guppet.Variant) then
            local rng = RNG();
            rng:SetSeed(Random(), 0);
            local slowed = guppet:HasEntityFlags(EntityFlag.FLAG_SLOW);

            -- State.
            local state = guppet.State;
            local function RunStateFrame()
                if (not slowed or guppet:IsFrame(2, 0)) then
                    guppet.StateFrame = guppet.StateFrame + 1;
                end
            end
            local function SetState(value)
                guppet.State = value;
                guppet.I1 = 0;
                guppet.I2 = 0;
                guppet.StateFrame = 0;
            end
            local spr = guppet:GetSprite();
            if (spr:IsFinished("Appear")) then
                spr:Play("Idle");
                SetState(Guppet.States.IDLE);
                guppet.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            end

            local data = Guppet.GetGuppetData(guppet, true);


            if (state == Guppet.States.IDLE) then
                -- Idle.

                local anim = spr:GetAnimation();
                if (anim ~= "Idle" and spr:IsFinished(anim)) then
                    spr:Play("Idle");
                end
                RunStateFrame()
                if (guppet.StateFrame > 30) then
                    data.StatePool = data.StatePool or {};
                    -- Refill StatePool.
                    if (#data.StatePool <= 0) then
                        for i, state in pairs(validStates) do
                            table.insert(data.StatePool, state);
                        end
                    end
                    local statePool = data.StatePool;
                    local stateIndex = rng:RandomInt(#statePool) + 1;
                    local nextState = statePool[stateIndex];
                    table.remove(statePool, stateIndex);
                    SetState(nextState);
                end
            elseif (state == Guppet.States.FLY) then
                -- Fly Form.
                if (spr:IsPlaying("Idle")) then
                    spr:Play("FlyCombine");
                end

                if (spr:IsFinished("FlyCombine")) then
                    spr:Play("FlyForm");
                end

                if (spr:IsFinished("FlySpit")) then
                    spr:Play("FlyForm", true);
                end
                RunStateFrame();
                if (spr:IsPlaying("FlyForm") or spr:IsPlaying("FlySpit")) then

                    -- Spit.
                    if (guppet.StateFrame % 30 == 0) then
                        spr:Play("FlySpit");
                    end

                    if (guppet.StateFrame > 300) then
                        spr:Stop();
                    end

                    if (spr:IsEventTriggered("Spit")) then
                        THI.SFXManager:Play(SoundEffect.SOUND_WHEEZY_COUGH);
                        local boomflyCount = #Isaac.FindByType(EntityType.ENTITY_BOOMFLY, 5);
                        if (boomflyCount >= 1 or rng:RandomInt(2) == 0) then
                            if (rng:RandomInt(2) == 0) then
                                -- 50% Chance to spawn Army flies.
                                for i = 0, 5 do
                                Isaac.Spawn(868, 0, 0, guppet.Position, Vector.Zero, guppet);
                                end
							else
                                -- 50% Chance to fire proectiles.
                                local player = guppet:GetPlayerTarget()
                                local targetAngle = 0;
                                if (player) then
                                    targetAngle = (player.Position - guppet.Position):GetAngleDegrees();
                                end
                                for i = 1, 6 do
                                    local angle = i * 60 + targetAngle;
                                    local dir = Vector.FromAngle(angle);
                                    local vel = dir * 10;
                                    
                                    guppet:FireProjectiles (guppet.Position, vel, 0, Guppet.NormalParams)
                                    --Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, guppet.Position, vel, guppet);
                                end
							end
                        else
                            -- Spawn Boomflies.
                            Isaac.Spawn(EntityType.ENTITY_BOOMFLY, 5, 0, guppet.Position, Vector.Zero, guppet);
                        end
                    end

                    -- Movement.
                    do 
                        
                        local maxSpeed = 10;
                        if (guppet.Velocity:Length() < maxSpeed) then
                            local dir = guppet.Velocity:Normalized()
                            if (dir:Length() <= 0.1) then
                                dir = Vector.FromAngle(rng:RandomInt(4) * 90 + 45);
                            end
                            guppet:AddVelocity(dir * 3);
                            local vel = guppet.Velocity
                            guppet.Velocity = vel:Resized(math.min(vel:Length(), maxSpeed));
                        end

                        local angle = guppet.Velocity:GetAngleDegrees() % 360;
                        local speed = guppet.Velocity:Length();
                        angle = math.floor(angle / 90) * 90 + 45;
                        guppet.Velocity = Vector.FromAngle(angle) * speed;
                    end
                end

                
                if (guppet.StateFrame > 315) then
                    SetState(Guppet.States.IDLE);
                    spr:Play("FlyReturn");
                end
            elseif (state == Guppet.States.SPIDER) then
                -- Spider Form.
                RunStateFrame();
                if (spr:IsPlaying("Idle")) then
                    spr:Play("SpiderCombine");
                end

                if (guppet.StateFrame % 30 == 0 and guppet.StateFrame < 300) then
                    spr:Play("SpiderJump", true);
                end
                if (spr:IsPlaying("SpiderJump") and guppet.StateFrame < 300) then
                    if (spr:IsEventTriggered("Jump")) then
                        guppet.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS_LITE_ROAR);
                        local player = guppet:GetPlayerTarget()
                        guppet.TargetPosition = (player and player.Position) or Vector.Zero;
                    end
                    if (spr:IsEventTriggered("Land")) then
                        guppet.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
                        guppet.TargetPosition = Vector.Zero;
                        THI.SFXManager:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS);

                        local player = guppet:GetPlayerTarget()
                        local targetAngle = 0;
                        if (player ) then
                            targetAngle = (player.Position - guppet.Position):GetAngleDegrees();
                        end
                        for i = 1, 6 do
                            local angle = i * 60 + targetAngle;
                            local dir = Vector.FromAngle(angle);
                            local vel = dir * 10;
                            
                            guppet:FireProjectiles (guppet.Position, vel, 0, Guppet.NormalParams)
                            -- Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, guppet.Position, vel, guppet);
                        end
						if (rng:RandomInt(4) == 0) then
                            -- Only have 25% chance to spawn boils.
                            Isaac.Spawn(EntityType.ENTITY_BOIL, 2, 0, guppet.Position, Vector.Zero, nil);
						end
                        guppet.Velocity = Vector.Zero;
                    end

                    -- Move.
                    if (guppet.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE) then
                        if (guppet.Velocity:Length() < 20) then
                            guppet:AddVelocity((guppet.TargetPosition - guppet.Position):Normalized() * 5);
                            local vel = guppet.Velocity
                            guppet.Velocity = vel:Resized(math.min(20, vel:Length()));
                        end
                        if (guppet.TargetPosition:Distance(guppet.Position) < guppet.Size) then
                            guppet.Velocity = guppet.Velocity * 0.5;
                        end
                    end
                end

                
                if (guppet.StateFrame > 315) then
                    SetState(Guppet.States.IDLE);
                    spr:Play("SpiderReturn");
                    guppet.Velocity = Vector.Zero;
                end
            elseif (state == Guppet.States.MAGGOT) then
                -- Maggot Form. (Obsoleted)
                RunStateFrame();
                if (spr:IsPlaying("Idle")) then
                    spr:Play("MaggotCombine");
                end

                local function PlayCreepAnimation()
                    local angle = guppet.Velocity:GetAngleDegrees() % 360;
                    local chargeDir = "Down";
                    if (angle < 22.5 or angle > 337.5) then
                        chargeDir = "Right";
                    elseif (angle < 57.5) then
                        chargeDir = "RightDown";
                    elseif (angle < 112.5) then
                        chargeDir = "Down";
                    elseif (angle < 157.5) then
                        chargeDir = "LeftDown";
                    elseif (angle < 202.5) then
                        chargeDir = "Left";
                    elseif (angle < 247.5) then
                        chargeDir = "LeftUp";
                    elseif (angle < 292.5) then
                        chargeDir = "Up";
                    elseif (angle < 337.5) then
                        chargeDir = "RightUp";
                    end
                    local anim = "MaggotCreep"..chargeDir;
                    spr:Play(anim);
                    spr.Rotation = 0;
                end
                
                local function StartCharge() 
                    local player = guppet:GetPlayerTarget();
                    local targetPosition = Vector.Zero;
                    if (player) then
                        targetPosition = player.Position;
                    end

                    guppet.TargetPosition = targetPosition;
                    guppet.I1 = 1;
                    local dir =  (targetPosition - guppet.Position):Normalized();
                    guppet.V1 = dir;
                end

                if (guppet.StateFrame > 20) then

                    if (guppet.I1 == 0) then
                        data.GuppetChargeCooldown = data.GuppetChargeCooldown or 0;
                        if (data.GuppetChargeCooldown > 0) then
                            data.GuppetChargeCooldown = data.GuppetChargeCooldown - 1
                        else
                            StartCharge();
                            data.GuppetChargeCooldown = 30;
                        end 
                    elseif (guppet.I1 == 1) then
                        local maxSpeed = 15;
                        local dir = guppet.V1;
                        local acceleration = 3;
                        
                        if (guppet.Velocity:Length() < maxSpeed) then
                            guppet:AddVelocity(dir * acceleration);
                            local vel = guppet.Velocity;
                            guppet.Velocity = vel:Resized(math.min(maxSpeed, vel:Length()));
                        end
                        PlayCreepAnimation()

                        local target2This = guppet.TargetPosition - guppet.Position;
                        if (target2This:Dot(dir) < 20) then
                            if (guppet:CollidesWithGrid()) then
                                Game():ShakeScreen(10);
                                THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                                Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, guppet.Position, Vector.Zero, guppet);
                                -- ipecac projectiles.
                                for i = 1, 3 do 
                                    local angle = rng:RandomFloat() * 60 - 30;
                                    local projDir = (-dir):Rotated(angle);
                                    local vel = projDir * (rng:RandomFloat() * 5 + 5);

                                    Guppet.MaggotParams.FallingSpeedModifier = -(rng:RandomFloat() * 20 + 20);
                                    guppet:FireProjectiles (guppet.Position, vel, 0, Guppet.MaggotParams)

                                    -- local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, guppet.Position + vel, vel, guppet):ToProjectile();
                                    -- proj.FallingAccel = 1;
                                    -- proj.FallingSpeed = -(rng:RandomFloat() * 20 + 20);
                                    -- proj:AddProjectileFlags(ProjectileFlags.EXPLODE);
                                    -- proj:SetColor(Color(0,1,0,1,0,0,0), 0, 0);

                                end
                                guppet.I1 = 0;
                                guppet.V1 = Vector.Zero;
                                guppet.Velocity = Vector.Zero;
                            end
                        end
                    end
                end

                
                if (guppet.StateFrame > 315) then
                    SetState(Guppet.States.IDLE);
                    spr:Play("MaggotReturn");
                    guppet.Velocity = Vector.Zero;
                end
            elseif (state == Guppet.States.ANGEL) then
                -- Angel Form.
                RunStateFrame();
                if (spr:IsPlaying("Idle")) then
                    spr:Play("AngelCombine");
                end

                if (spr:IsFinished("AngelCombine")) then
                    spr:Play("AngelForm");
                end

                local room = Game():GetRoom();
                local center = room:GetCenterPos();

                -- Move.
                local sin = guppet.StateFrame - 30
                local lerp = math.max(0, math.min(0.7, sin / 150));
                local xOffset = math.sin(sin / 180 * math.pi * 3) * 80;
                local yOffset = math.sin(sin / 90 * math.pi * 3) * 30;
                local targetPosition = center + Vector(xOffset, yOffset);
                guppet.Velocity = guppet.Velocity * (1 - lerp) + (targetPosition - guppet.Position) * 0.3 * lerp;
                -- Projectiles.
                for i = 0, 4 do
                    local posOffset = Vector.Zero;
                    if (i == 1) then
                        posOffset = Vector(-52, 0);
                    elseif (i == 2) then
                        posOffset = Vector(52, 0);
                    elseif (i == 3) then
                        posOffset = Vector(-104, 0);
                    elseif (i == 4) then
                        posOffset = Vector(104, 0);
                    end
                    local pos = guppet.Position + posOffset;
                    if (guppet.StateFrame % 120 == i * 20) then
                        local target = guppet:GetPlayerTarget();
                        local targetPosition = Vector.Zero;
                        if (target) then
                            targetPosition = target.Position;
                        end
                        for ang = 0, 2 do
                            local dir = (targetPosition - pos):Normalized():Rotated(ang * 20 - 40);
                            local vel = dir * 8;
                            local projectile = guppet:FireProjectiles(pos, vel, 0, Guppet.NormalParams);

                            --local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, pos, vel, guppet):ToProjectile();
                        end
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, guppet.Position, Vector.Zero, guppet);
                        THI.SFXManager:Play(SoundEffect.SOUND_HEARTOUT);
                    end
                end
                
                if (guppet.StateFrame > 315) then
                    SetState(Guppet.States.IDLE);
                    spr:Play("AngelReturn");
                    guppet.Velocity = Vector.Zero;
                end
            elseif (state == Guppet.States.DEVIL) then
                -- Devil Form.
                RunStateFrame();
                if (spr:IsPlaying("Idle")) then
                    spr:Play("DevilCombine");
                end

                if (spr:IsFinished("DevilCombine")) then
                    spr:Play("DevilCharge");
                    THI.SFXManager:Play(SoundEffect.SOUND_LOW_INHALE);
                end
                if (spr:IsEventTriggered("Brimstone")) then
                    THI.SFXManager:Play(SoundEffect.SOUND_GHOST_ROAR);
                    -- Fire Brimstones.
                    for i = 1, 2 do
                        if (not EntityExists(data.Brimstones[i])) then
                            local sign = (i * 2 - 3);
                            local angle = 90 - sign * 30;
                            local laser = EntityLaser.ShootAngle (1, guppet.Position, angle, 100, Vector(0, -24), guppet);
                            laser:SetColor(RottenLaserColor, 0, 0);
                            laser.DepthOffset = 25;
                            laser.Parent = guppet;
                            laser.ParentOffset = Vector(sign * 96, 0);
                            data.Brimstones[i] = laser;
                        end
                    end
                end
                if (spr:IsFinished("DevilCharge") or spr:IsFinished("DevilSpit")) then
                    spr:Play("DevilForm");
                end

                if (spr:IsEventTriggered("Spit")) then
                    local target = guppet:GetPlayerTarget();
                    local targetPosition = Vector.Zero;
                    if (target) then
                        targetPosition = target.Position;
                    end
                    local dir = (targetPosition - guppet.Position):Normalized();
                    local vel = dir * 10;

                    local projectile = guppet:FireProjectiles(guppet.Position, vel, 0, Guppet.DevilParams);

                    --local projectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, guppet.Position, vel, guppet):ToProjectile();
                    --projectile:AddProjectileFlags(ProjectileFlags.SIDEWAVE);
                    THI.SFXManager:Play(SoundEffect.SOUND_HEARTOUT);
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, guppet.Position, Vector.Zero, guppet);
                    effect.DepthOffset = 3;
                end

                if (guppet.StateFrame < 350) then
                    
                    -- Update Brimstone.
                    for i, laser in pairs(data.Brimstones) do
                        laser.Timeout = 31;
                        local sign = (i * 2 - 3);
                        local angle = 90 - sign * 30;
                        local lerp = (guppet.StateFrame - 50 )/ 300;
                        laser.Angle = angle * (1- lerp) + 90 * lerp;
                    end

                    
                    -- Move.
                    local targetPosition = Game():GetRoom():GetCenterPos() ;
                    targetPosition.Y = 120;
                    guppet.Velocity = guppet.Velocity * 0.5 + (targetPosition - guppet.Position) * 0.1 * 0.5;
                    -- Fire.
                    if (guppet.StateFrame > 50 and guppet.StateFrame % 40 == 0) then
                        spr:Play("DevilSpit", true);
                    end
                end

                if (guppet.StateFrame > 410) then
                    SetState(Guppet.States.IDLE);
                    spr:Play("DevilReturn");
                    guppet.Velocity = Vector.Zero;
                end
            end



            guppet:MultiplyFriction(0.9);
        end
    end
    Guppet:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostGuppetUpdate, Guppet.Type);

    local function PostUpdate(mod)
        
        for i, guppet in pairs(Isaac.FindByType(Guppet.Type, Guppet.Variant)) do
        
            local spr = guppet:GetSprite();
            if (spr:IsEventTriggered("BloodExplosion1")) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position + Vector(-48, -64), Vector.Zero, nil);
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position+ Vector(48, -64), Vector.Zero, nil);
                guppet:BloodExplode();
            end
            if (spr:IsEventTriggered("BloodExplosion2")) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position + Vector(-32, 0), Vector.Zero, nil);
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position+ Vector(32, 0), Vector.Zero, nil);
                guppet:BloodExplode();
            end
            if (spr:IsEventTriggered("BloodExplosion3")) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position + Vector(0, -16), Vector.Zero, nil);
                guppet:BloodExplode();
            end
            
            if (spr:IsEventTriggered("BloodExplosion4")) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, guppet.Position + Vector(0, -64), Vector.Zero, nil);
                guppet:BloodExplode();
            end
        end
    end
    Guppet:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);
end

return Guppet;