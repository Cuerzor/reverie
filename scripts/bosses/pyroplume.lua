local Math = CuerLib.Math;
local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local EntityExists = Detection.EntityExists;
local Bosses = CuerLib.Bosses;
local Grids = CuerLib.Grids;
local Pyroplume = ModEntity("Pyroplume", "PYROPLUME");

Pyroplume.Variants = {
    PHASE1 = Isaac.GetEntityVariantByName("Pyroplume"),
    PHASE2 = Isaac.GetEntityVariantByName("Pyroplume 2"),
    PHASE3 = Isaac.GetEntityVariantByName("Pyroplume 3"),
}

do
    local r = Grids.RoomGrids.Rock;
    local n = Grids.RoomGrids.Null;
    
    local roomConfig = {
        ID = "reverie:pyroplume",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/pyroplume",
        CustomRooms = {
            Pyroplume1 = {
                ReplaceChance = 20,
                BossID = "reverie:pyroplume",
                Shape = RoomShape.ROOMSHAPE_2x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                Grids = {
                    {r, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, r, n, n, r, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n, r, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {r, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, r},
                },
                Bosses = {
                    {Type = Pyroplume.Type, Variant = Pyroplume.Variant, SubType = Pyroplume.SubType, Position = Vector(580, 280)},
                },
                Entities = {
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(120, 160)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(80, 200)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(80, 360)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(120, 400)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(1040, 160)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(1080, 200)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(1080, 360)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(1040, 400)},
                }
            },
            Pyroplume2 = {
                ReplaceChance = 20,
                BossID = "reverie:pyroplume",
                Shape = RoomShape.ROOMSHAPE_1x2,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                Grids = {
                    {r, n, n, n, n, n, n, n, n, n, n, n, r},
                    {n, n, n, n, n, r, n, r, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, r, n, r, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, r, r, r, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, r, r, r, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, r, n, r, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, r, n, r, n, n, n, n, n},
                    {r, n, n, n, n, n, n, n, n, n, n, n, r},
                },
                Bosses = {
                    {Type = Pyroplume.Type, Variant = Pyroplume.Variant, SubType = Pyroplume.SubType,  Position = Vector(320, 400)},
                },
                Entities = {
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(120, 160)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(80, 200)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(80, 640)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(120, 680)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(520, 160)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(560, 200)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(560, 640)},
                    {Type = 33, Variant = 0, SubType = 0, Position = Vector(520, 680)},
                }
            },
            Pyroplume3 = {
                ReplaceChance = 20,
                BossID = "reverie:pyroplume",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
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
                    {Type = Pyroplume.Type, Variant = Pyroplume.Variant, SubType = Pyroplume.SubType,  Position = Vector(320, 280)},
                },
                Entities = {
                }
            }
        }
    }
    local bossConfig = {
        Name = "Pyroplume",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_1, Weight = 1},
                {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE2_2, Weight = 1}
            }
        },
        Type = Pyroplume.Type,
        Variant = Pyroplume.Variant,
        PortraitPath = "gfx/ui/boss/portrait_584.0_pyroplume.png",
        PortraitOffset = Vector(0, -30),
        NamePaths = {
            en = "gfx/ui/boss/bossname_584.0_pyroplume.png",
            zh = "gfx/ui/boss/bossname_584.0_pyroplume_zh.png"
        }
    }
    Bosses:SetBossConfig("reverie:pyroplume", bossConfig, roomConfig);
end

-- Pyroplume.
do
    Pyroplume.States = {
        AWAKE = 0,
        CHARGE = 1,
        RELEASE = 2,
        DANCE = 3,
    }

    local renderRNG = RNG();
    
    local phase1 = Pyroplume.Variants.PHASE1;
    local phase2 = Pyroplume.Variants.PHASE2;
    local phase3 = Pyroplume.Variants.PHASE3;

    function Pyroplume.GetBirdData(bird, init)
        local function getter()
            return {
                ChargeTimes = 0,
                Light = nil,
                StateTime = 0
            }
        end
        return Pyroplume:GetData(bird, init, getter);
    end

    local function StartState(bird, state)
        local spr = bird:GetSprite();
        if (state == Pyroplume.States.CHARGE) then
            local player = bird:GetPlayerTarget();
            if (player) then
                bird.TargetPosition = player.Position;
                bird.V1 = (bird.TargetPosition - bird.Position):Normalized();
                bird.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            else
                StartState(bird, staPyroplume.States.RELEASE)
                return;
            end
        elseif (state == Pyroplume.States.RELEASE) then
            spr:Play("Awake");
        elseif (state == Pyroplume.States.DANCE) then
            spr:Play("TurnBack");
            bird.GridCollisionClass = GridCollisionClass.COLLISION_NONE;
        end
        bird.I1 = state;
        bird.I2 = 0;
        local data = Pyroplume.GetBirdData(bird, true);
        data.StateTime = 0;
    end


    local function PlayRoarSound(bird)
        local variant = bird.Variant;
        local pitch = 1
        if (variant == phase1) then
            pitch = 1;
        elseif (variant == phase2) then
            pitch = 1
        end
        THI.SFXManager:Play(SoundEffect.SOUND_GHOST_ROAR, 1, 0, false, pitch);
    end
    
    local function SpawnFeather(pos, velocity, bird)
        local feather = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_WING, 0, pos, velocity, bird):ToProjectile();
        feather:SetColor(Color(1,1,1,1,1,0.5,0), -1, 0);
        feather:SetColor(Color(0,0,0,0,0,0,0), 5, 1, true, true);
        feather:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE);
        return feather;
    end
    
    local function PostPyroplumeInit(mod, bird)
        local variant = bird.Variant;
        if (variant == phase1 or variant == phase2 or variant == phase3) then
            local spr = bird:GetSprite();
            spr:Play("Revive");
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, bird.Position, Vector.Zero, bird);
            bird.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
            bird.SplatColor = Color(0,0,0,1, 1, 0.5, 0);
        end
    end

    Pyroplume:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostPyroplumeInit, Pyroplume.Type);
    local function PostPyroplumeUpdate(mod, bird)
        local variant = bird.Variant;
        if (variant == phase1 or variant == phase2 or variant == phase3) then

            local canCharge = true;
            local canReleaseFire = variant == phase2 or variant == phase3;
            local canDance = variant == phase3;

            local i1 = bird.I1;
            local data = Pyroplume.GetBirdData(bird, true);


            local simSpeed = 1;
            if (bird:HasEntityFlags(EntityFlag.FLAG_SLOW)) then
                simSpeed = 0.5;
            end
            local function RunStateTime() data.StateTime = (data.StateTime or 0) + simSpeed; end
            -- Create Light.
            if (not EntityExists(data.Light)) then
                data.Light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LIGHT, 0, bird.Position,bird.Velocity, bird);
                local light = data.Light;
                
                light:SetColor(Color(1,1,1,1,1,0.5,0), -1, 0);
                light.SpriteScale = Vector(3, 3);
            else
                local light = data.Light;
                light.Parent = bird;
                light.Position = bird.Position;
                light.Velocity = bird.Velocity;
            end

            local spr = bird:GetSprite();
            if (i1 == Pyroplume.States.AWAKE) then
                if (spr:IsFinished("Revive")) then
                    spr:Play("Awake");
                end

                
                if (spr:IsFinished("Awake")) then
                    spr:Play("Release");
                    PlayRoarSound(bird);
                end
                if (spr:IsPlaying("Release")) then
                    if (bird:IsFrame(3, 0)) then
                        if (canReleaseFire) then
                            
                            for a = 1, 4 do
                                local angle = a * 90 + bird.FrameCount * 3;
                                local dir = Vector.FromAngle(angle);
                                local vel = dir * 5;
                                Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, bird.Position, vel, bird);
                            end
                        end
                        
                        if (canDance) then
                            Game():ShakeScreen(10);
                            for a = 1, 6 do
                                local angle = a * 60 + bird.FrameCount * 5 + 15;
                                local dir = Vector.FromAngle(angle);
                                local vel = dir * 7;
                                local feather = SpawnFeather(bird.Position, vel, bird);
                            end
                        end
                    end
                end

                if (spr:IsFinished("Release")) then
                    spr:Play("TurnBack");
                    StartState(bird, Pyroplume.States.CHARGE);
                end
            elseif (i1 == Pyroplume.States.CHARGE) then

                -- Charge.


                if (not spr:IsPlaying("Fly")) then
                    if (spr:IsFinished("TurnBack")) then
                        spr:Play("Fly");
                    end
                else
                    if (bird.I2 == 0) then
                        local dir = bird.V1;
                        local maxSpeed = 15;
                        if (bird.Velocity:Length() < maxSpeed) then
                            bird:AddVelocity(dir * 3);
                            bird.Velocity:Resize(math.min(maxSpeed, bird.Velocity:Length()));

                            
                            local angleDiff = Math.GetAngleDiff(bird.SpriteRotation, dir:GetAngleDegrees() + 90);
                            local lerp = 0.3
                            bird.SpriteRotation = bird.SpriteRotation + (angleDiff) * lerp;
                            bird.SpriteRotation = bird.SpriteRotation % 360;
                        end
                        
                        local emberPos = bird.Position + (renderRNG:RandomFloat() * 192 -96) * Vector.FromAngle(bird.SpriteRotation);
                        local ember = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, emberPos, -bird.Velocity:Normalized() * 3, nil);
                        local e = ember:ToEffect(); 
                        e.Scale = renderRNG:RandomFloat()*5 + 10;
                        e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
                        e.Timeout = e.LifeSpan;
                        
                        if (canDance and bird:IsFrame(3, 0)) then
                            local feather = bird.Position + (renderRNG:RandomFloat() * 128 -64) * Vector.FromAngle(bird.SpriteRotation);
                            SpawnFeather(feather, bird.Velocity * 0.2, bird);
                        end
        
                        local gotOver = (bird.TargetPosition - bird.Position):Dot(dir) < 40;
                        if (gotOver) then
                            
                            bird.GridCollisionClass = GridCollisionClass.COLLISION_SOLID;
                            if (bird:CollidesWithGrid()) then
                                local game = Game();
                                game:BombExplosionEffects (bird.Position, 20, TearFlags.TEAR_NORMAL, Color.Default, bird, 1, true, false, DamageFlag.DAMAGE_EXPLOSION )
                                game:ShakeScreen(10);
                                bird.Velocity = Vector.Zero;
                                bird.I2 = 1;

                                if (canReleaseFire) then
                                    Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, bird.Position, Vector.Zero, bird);
                                    local angleOffset = 0;
                                    if (canDance) then
                                        angleOffset = 45;
                                    end
                                    for i = 1, 4 do
                                        local angle = i * 90 + angleOffset;
                                        local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, bird.Position, Vector.Zero, bird);  
                                        local wave = waveEnt:ToEffect();
                                        wave.Rotation = angle;
                                    end
                                end

                                for i = 0, 20 do
                                    local dust = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, bird.Position, RandomVector() * renderRNG:RandomFloat() * 10, nil);
                                    local e = dust:ToEffect(); 
                                    e.Scale = 2;
                                    e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
                                    e.Timeout = e.LifeSpan;
                                end

                                
                                for i = 0, 20 do
                                    local ember = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, bird.Position, RandomVector() * renderRNG:RandomFloat() * 10, nil);
                                    local e = ember:ToEffect(); 
                                    e.Scale = 5;
                                    e.LifeSpan = math.floor(renderRNG:RandomFloat() * 10 + 20);
                                    e.Timeout = e.LifeSpan;
                                end
                            end
                        end
                    elseif (bird.I2 == 1) then
                        RunStateTime();
                        local chargeTimes = data.ChargeTimes or 0;
                        if (data.StateTime > 5) then
                            chargeTimes = chargeTimes + 1;
                            data.ChargeTimes = chargeTimes;

                            local maxChargeTime = 3;
                            if (canDance) then
                                maxChargeTime = 4;
                            end
                            if (chargeTimes >= maxChargeTime and canReleaseFire) then
                                StartState(bird, Pyroplume.States.RELEASE);
                                data.ChargeTimes = 0;
                            else
                                spr:Play("TurnBack");
                                StartState(bird, Pyroplume.States.CHARGE);
                            end
                        end
                    end
                end
            elseif (i1 == Pyroplume.States.RELEASE) then
                if (spr:IsFinished("Awake")) then
                    spr:Play("Release");
                    PlayRoarSound(bird);
                    local circles = 2;
                    local count = 5;
                    local angleInterval =  360 / count;
                    for i = 1, circles do
                        for a = 1, count do
                            local angle = a * angleInterval + i * angleInterval / 2;
                            local dir = Vector.FromAngle(angle);
                            local vel = dir * i * 5;
                            local fire = Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 10, 0, bird.Position, vel, bird);
                            fire.HitPoints = 4;
                        end
                    end

                    if (canDance) then
                        for a = 1, 8 do
                            local angle = a * 45 + (bird.FrameCount % 2)* 22.5;
                            local dir = Vector.FromAngle(angle);
                            local vel = dir * 10
                            SpawnFeather(bird.Position, vel, bird);
                        end
                    end

                    for i = 1, 6 do
                        local angle = i * 60 + 0;
                        local waveEnt = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_WAVE,0, bird.Position, Vector.Zero, bird);  
                        local wave = waveEnt:ToEffect();
                        wave.Rotation = angle;
                    end
                end
                if (spr:IsFinished("Release")) then
                    spr:Play("TurnBack");
                    if (canDance) then
                        StartState(bird, Pyroplume.States.DANCE);
                    else
                        StartState(bird, Pyroplume.States.CHARGE);
                    end
                end
            elseif (i1 == Pyroplume.States.DANCE) then
                if (not spr:IsPlaying("Fly")) then
                    if (spr:IsFinished("TurnBack")) then
                        spr:Play("Fly");
                    end
                else
                    local player = bird:GetPlayerTarget();
                    if (player) then
                        RunStateTime();

                        bird.Target = player;
                        local target = bird.Target;
                        local minDistance = 240;
                        local speedMultiplier = 5;
                        local maxTime = 150;
                        local decelerateTime =  30;
                        local rotateSpeed = data.StateTime / 30 * speedMultiplier;
                        if (data.StateTime > maxTime) then
                            rotateSpeed = math.max(0, maxTime / 30 * speedMultiplier * ((maxTime + decelerateTime - data.StateTime) / decelerateTime));
                        end

                        local bird2Target = bird.Position - target.Position;
                        local currentAngle = bird2Target:GetAngleDegrees();
                        local currentDis = bird2Target:Length();
                        local targetAngle = currentAngle + rotateSpeed;
                        local disSpeed = math.min(1, rotateSpeed / speedMultiplier);
                        if (rotateSpeed == 0) then
                            disSpeed = 0;
                        end
                        local targetDistance = currentDis + (minDistance - currentDis) * disSpeed;

                        local targetPosition = target.Position + Vector.FromAngle(targetAngle) * targetDistance;
                        bird.Velocity = targetPosition - bird.Position;

                        local targetRotation = bird.Velocity:GetAngleDegrees() + 90
                        local angleDiff = Math.GetAngleDiff(bird.SpriteRotation, targetRotation);
                        bird.SpriteRotation = bird.SpriteRotation + angleDiff * disSpeed;

                        -- Fire Feathers.
                        if (data.StateTime <= maxTime) then
                            if (data.StateTime % 2 == 0) then
                                local featherPos = bird.Position + Vector.FromAngle(bird.SpriteRotation) * (renderRNG:RandomFloat() * 128 - 64)
                                local featherVel = (bird.Velocity):Resized(5):Rotated(renderRNG:RandomFloat() * 60 - 30);
                                SpawnFeather(featherPos, featherVel, bird);
                            end
                            if (data.StateTime % 10 == 0) then
                                THI.SFXManager:Play(SoundEffect.SOUND_CANDLE_LIGHT);
                            end
                            if (data.StateTime % 15 == 0) then
                                SpawnFeather(bird.Position, -bird2Target:Resized(10), bird);
                                THI.SFXManager:Play(SoundEffect.SOUND_CANDLE_LIGHT);
                            end
                        end

                        if (data.StateTime > maxTime + decelerateTime) then
                            StartState(bird, Pyroplume.States.CHARGE);
                            bird.Velocity = -bird2Target:Resized(20);
                        end
                    else
                        StartState(Pyroplume.States.RELEASE);
                    end
                    
                end
            end

            bird:MultiplyFriction(0.9);
        end
    end
    Pyroplume:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostPyroplumeUpdate, Pyroplume.Type);
    
    local function PostPyroplumeRender(mod, bird, offset)
        
        local variant = bird.Variant;
        if (variant == phase1 or variant == phase2 or variant == phase3) then
            local spr = bird:GetSprite();
            if (not spr:IsPlaying("Fly") and not spr:IsPlaying("TurnBack")) then
                bird.SpriteRotation = 0;
            end

            if (bird:IsDead() and bird:Exists() and spr:IsFinished("Death")) then
                if (variant == phase1 or variant == phase2) then
                    local targetVariant = phase2;
                    if (variant == phase2) then
                        targetVariant = phase3;
                    end
                    local new = Isaac.Spawn(bird.Type, targetVariant, bird.SubType, bird.Position, bird.Velocity, bird.SpawnerEntity);
                    new:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
                    bird:Remove();
                end
            end
        end
    end
    Pyroplume:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, PostPyroplumeRender, Pyroplume.Type);

    local function PostPyroplumeKill(mod, bird)
        local variant = bird.Variant;
        if (variant == phase1 or variant == phase2 or variant == phase3) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0, bird.Position, Vector.Zero, bird);
        end
    end
    Pyroplume:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPyroplumeKill, Pyroplume.Type);
    
    local function PrePyroplumeTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        local variant = tookDamage.Variant;
        if (variant == phase1 or variant == phase2 or variant == phase3) then
            local sourceEntity = source.Entity;
            local sourceEntitySpawner = sourceEntity and sourceEntity.SpawnerEntity;

            if (flags & (DamageFlag.DAMAGE_FIRE | DamageFlag.DAMAGE_EXPLOSION) > 0) then
                if (CompareEntity(sourceEntity, tookDamage) or CompareEntity(sourceEntitySpawner, tookDamage)) then
                    return false;
                else
                    local canAbsorb = true;
                    if (source.Type == EntityType.ENTITY_PLAYER or 
                    (sourceEntity and sourceEntity.SpawnerType == EntityType.ENTITY_PLAYER)) then
                        canAbsorb = false;
                    end
                    if (canAbsorb) then
                        tookDamage.HitPoints = math.min(tookDamage.MaxHitPoints, tookDamage.HitPoints + amount);
                        return false;
                    end
                end
            end
        end
    end
    Pyroplume:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PrePyroplumeTakeDamage, Pyroplume.Type);
end

return Pyroplume;