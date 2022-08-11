local Math = CuerLib.Math;
local Consts = CuerLib.Consts;
local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local ItemPools = CuerLib.ItemPools;
local Note = ModEntity("Reverie", "REVERIE_NOTE");
Note.Room = {
    Type = RoomType.ROOM_LIBRARY,
    Variant = 5802
}

THI.Shared.SoftlockFix:AddModGotoRoom(Note.Room.Type, Note.Room.Variant);


Note.SubTypes = {
    WAKASAGIHIME = 0,
    SEKIBANKI = 1,
    KAGEROU = 2,
    BENBEN = 3,
    MERLIN = 4,
    LUNASA = 5,
    LYRICA = 6,
    YATSUHASHI = 7,
    FLANDRE1 = 8,
    FLANDRE2 = 9,
    FLANDRE3 = 10,
    FLANDRE4 = 11,
    REIMU = 12,
    MARISA = 13,
    HECATIA = 14
}
Note.States = {
    ACTIVE = 0,
    DORMANT = 3,
    ATTACK = 4,
    APPEAR = 5,
}
local MarisaLaserColor = Color(1,1,1,1,0.6,0.8,0.8);
MarisaLaserColor:SetColorize(1,1,1,1);



----
-- 私有函数
----

local function GetGlobalData(create)
    return Note:GetGlobalData(create, function ()
        return {
            StartedFight = false,
            FightOver = false
        };
    end)
end
local function GetTempGlobalData(create)
    return Note:GetTempGlobalData(create, function ()
        return {
            FrandreFrames = nil,
            Notes = {},
            FightLevel = 0,
            FightTimer = 0,
            PlayingOpening = true,
            OpeningFrame = 0
        };
    end)
end


local function GetLaserData(laser, create)
    return Note:GetTempData(laser, create, function()
        return {
            Thin = false,
            ReturnPosition = nil,
            MaxDistance = nil
        }
    end)
end
local function GetProjectileData(projectile, create)
    return Note:GetTempData(projectile, create, function()
        return {
            Lyrica = nil
        }
    end)
end
local function ClearTempGlobalData()
    local tempData = GetTempGlobalData(false);
    if (tempData and tempData.PlayingOpening) then
        local Opt = THI.Shared.Options;
        Opt:ResumePauseFocus();
    end
    Note:SetTempGlobalData(nil)
    
end

-- 设置细激光变量。
local function SetLaserThin(laser, value, returnPos)
    local laserData = GetLaserData(laser, true);
    laserData.Thin = value;
    laserData.ReturnPosition = returnPos
end
local function IsLaserThin(laser)
    local laserData = GetLaserData(laser, false);
    return laserData and laserData.Thin;
end
local function GetLaserReturnPosition(laser)
    local laserData = GetLaserData(laser, false);
    return laserData and laserData.ReturnPosition;
end
local function ClearLaserReturnPosition(laser)
    local laserData = GetLaserData(laser, true);
    laserData.ReturnPosition = nil;
end

-- 设置激光延长变量。
local function SetLaserExtending(laser, maxDistance)
    local laserData = GetLaserData(laser, true);
    laserData.MaxDistance = maxDistance;
end
local function GetLaserMaxDistance(laser)
    local laserData = GetLaserData(laser, false);
    return laserData and laserData.MaxDistance;
end


local function RunStateTime(note)
    local increase = true;
    if (note:HasEntityFlags(EntityFlag.FLAG_SLOW) and note.FrameCount % 2 == 1) then
        increase = false;
    end
    if (increase) then
        note.StateFrame = note.StateFrame + 1;
        
    end
end

local function MoveToTarget(note, velocity)
    velocity = velocity or 0.1;
    note.Velocity = (note.TargetPosition - note.Position) * velocity;
end

local function SpawnExplosionWaves(note)
    local Leaf = THI.Effects.SpellCardLeaf;
    local Wave =THI.Effects.SpellCardWave;
    
    local rng = RNG();
    rng:SetSeed(note.InitSeed, 0);
    local count = 10;
    for i = 1, count do
        local angle = rng:RandomFloat()* 360;
        local length = rng:RandomFloat() * 320 + 480;
        local sizeX = rng:RandomFloat()  + 0.5;
        local sizeY = rng:RandomFloat()  + 0.5;
        local rotation = rng:RandomFloat()* 360;
        local speed = rng:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(Leaf.Type, Leaf.Variant, 0, note.Position, offset / 21 * speed, note);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end
    local waveEnt = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, note.Position, Vector.Zero, note);
end

do -- 赤蛮奇子机。
    local Drone = ModEntity("Sekibanki Note Drone", "SEKIBANKI_DRONE")

    local function GetTempDroneData(drone, create)
        return Drone:GetTempData(drone, create, function()
            local rng = RNG();
            rng:SetSeed(drone.InitSeed, 0);
            return {
                StartAngle = 0,
                TargetAngle = 0,
                AimPosition = Vector.Zero,
                RNG = rng
            }
        end)
    end

    local function PostDroneInit(mod, drone)
        if (drone.Variant == Drone.Variant) then
            drone:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_STATUS_EFFECTS);
            drone.EntityCollisionClass = 0;
            drone.SplatColor = Consts.Colors.Clear;
        end
    end
    Drone:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostDroneInit, Drone.Type)

    local function PostDroneUpdate(mod, drone)
        if (drone.Variant == Drone.Variant) then

            if (drone.Parent and drone.Parent:IsDead()) then
                drone:Kill();
            end

            if (drone.FrameCount > 30) then
                local activeCount = Note:GetActiveNoteCount();
                local shootFrame = math.min(45, activeCount * 5 + 20);
                local endFrame = shootFrame + math.min(30, activeCount * 10);

                -- 生成激光瞄准光标。
                if ((not drone.Child or not drone.Child:Exists())) then
                    local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, drone.Position, Vector.Zero, drone);
                    tracer.Parent = drone;
                    tracer.PositionOffset = drone.PositionOffset;
                    tracer.Color = Color(0.5,0.5,1,0.1,0,0,0);
                    drone.Child = tracer;
                end

                local droneData = GetTempDroneData(drone, true);
                if (not drone.Target or drone.StateFrame > 75) then
                    drone.StateFrame = droneData.RNG:RandomInt(15) - 15;

                    -- 锁定目标。
                    drone.Target = drone:GetPlayerTarget();
                    local aim = drone.Target.Position;
                    local startAngle = (drone.Position - aim):GetAngleDegrees();
                    droneData.AimPosition = aim;
                    local targetAngle = droneData.RNG:RandomFloat() * 90 + 90 + startAngle;
                    droneData.StartAngle = startAngle
                    droneData.TargetAngle = targetAngle + targetAngle;
                    drone.TargetPosition = aim + Vector.FromAngle(targetAngle) * 160;
                end


                -- 旋转到目标地点。
                do
                    if (drone.Target) then
                        local aim = droneData.AimPosition;
                        local aim2This = drone.Position - aim;
                        local currentAngle = aim2This:GetAngleDegrees();
                        local includedAngle = Math.GetAngleDiff(droneData.TargetAngle, currentAngle);
                        local nextAngle = droneData.TargetAngle + 0.8 * includedAngle;
                        local distance = (aim2This):Length();
                        distance = (distance - 160) * 0.8 + 160;
                        local nextPosition = aim + Vector.FromAngle(nextAngle) * distance;
                        drone.Velocity = nextPosition - drone.Position;

                        --设置图像旋转。
                        local nextRotation = (drone.Position - aim):GetAngleDegrees() - 90;
                        local includedRot = Math.GetAngleDiff(drone.SpriteRotation, nextRotation);
                        drone.SpriteRotation = drone.SpriteRotation + includedRot * 0.5;
                    end
                end

                do -- 射击。
                    if (drone.StateFrame == shootFrame) then
                        local laser = EntityLaser.ShootAngle(2, drone.Position, drone.SpriteRotation - 90, 10, drone.PositionOffset, drone);
                        laser.TearFlags = TearFlags.TEAR_SPECTRAL;
                    end
                end

                local tracer = drone.Child;
                if (tracer) then
                    tracer.Velocity = drone.Velocity;
                    tracer.Position = drone.Position;
                    tracer.TargetPosition = Vector.FromAngle(drone.SpriteRotation - 90);
                    tracer.SpriteRotation = drone.SpriteRotation - 90;
                    if (drone:IsDead()) then
                        tracer:Remove();
                    end
                end

                RunStateTime(drone);

            end
            drone:MultiplyFriction(0.9);
        end
    end
    Drone:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostDroneUpdate, Drone.Type)
    Note.SekibankiDrone = Drone;
end

do -- 赫卡提亚月球。
    local Moon = ModEntity("Hecatia Note Moon", "HECATIA_NOTE_MOON")
    Moon.States = {
        IDLE = 0,
        FLYING = 2
    }
    local MoonProjParams = ProjectileParams();
    MoonProjParams.Variant = ProjectileVariant.PROJECTILE_ROCK;

    local function GetTempMoonData(moon, create)
        return Moon:GetTempData(moon, create, function()
            local rng = RNG();
            rng:SetSeed(moon.InitSeed, 0);
            return {
                RNG = rng
            }
        end)
    end

    local function PostMoonInit(mod, moon)
        if (moon.Variant == Moon.Variant) then
            moon:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_STATUS_EFFECTS);
            moon.SplatColor = Consts.Colors.Clear;
        end
    end
    Moon:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostMoonInit, Moon.Type)

    local function PostMoonUpdate(mod, moon)
        if (moon.Variant == Moon.Variant) then

            if (moon.Size < 64) then
                moon.Size = math.min(moon.Size + 2, 64);
                local scale = moon.Size / 64;
                moon.Scale = scale;
            end

            if (moon.Parent and moon.Parent:IsDead()) then
                moon:Kill();
            end

            if (moon.FrameCount > 30) then

                --print("CheckPoint 1")
                do -- 寻找目标。
                    if (moon.State == Moon.States.IDLE) then
                        local data = GetTempMoonData(moon, true);
                        local value = data.RNG:RandomInt(10) + 20;
                        if (moon.StateFrame > value) then
                            moon.Target = moon:GetPlayerTarget();
                            moon.TargetPosition = (moon.Target.Position - moon.Position):Normalized();
                            moon.State = Moon.States.FLYING;
                            moon.StateFrame = 0;
                        end
                    end
                end

                do -- 砸向目标。
                    if (moon.State == Moon.States.FLYING) then
                        moon:AddVelocity(moon.TargetPosition * 2);
                        local game = Game();
                        local room = Game():GetRoom();
                        if (moon.StateFrame > 10 and (not room:IsPositionInRoom (moon.Position, moon.Size + 2))) then

                            --生成子弹。
                            for i = 1, 18 do
                                local angle = i * 20;
                                local pos = moon.Position + Vector.FromAngle(angle) * moon.Size;
                                if (room:IsPositionInRoom(pos, 16)) then
                                    local vel = Vector.FromAngle(angle) * 10;
                                    moon:FireProjectiles(pos, vel, 0, MoonProjParams)
                                end
                            end
                            

                            moon.Position = room:GetClampedPosition (moon.Position, moon.Size + 1)
                            THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                            game:ShakeScreen(15);
                            moon.Velocity = Vector.Zero;
                            moon.State = Moon.States.IDLE;
                            moon.StateFrame = 0;
                        end
                    end
                end
                RunStateTime(moon);

                --print("CheckPoint 2")
            end

            moon:MultiplyFriction(0.9);
        end
    end
    Moon:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostMoonUpdate, Moon.Type)

    
    local function PreMoonCollision(mod, npc, other, low)
        if (npc.Variant == Moon.Variant) then
            if ((other:IsEnemy() or other.Type ~= EntityType.ENTITY_PLAYER) and other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) ) then
                return true;
            end
        end
    end
    Moon:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreMoonCollision, Moon.Type)

    
    local function PreTearCollision(mod, tear, other, low)
        if (other.Type == Moon.Type and other.Variant == Moon.Variant) then
            return true;
        end
    end
    Moon:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, PreTearCollision)
    Note.HecatiaMoon = Moon;
end

do -- 魔理沙魔法阵。
    local Circle = ModEntity("Marisa Note Circle", "MARISA_NOTE_CIRCLE")


    local function PostCircleInit(mod, circle)
        circle:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_HIDE_HP_BAR);
        circle.SplatColor = Consts.Colors.Clear;
    end
    Circle:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostCircleInit, Circle.Variant)

    local function PostCircleUpdate(mod, circle)
        -- 移动。
        if (circle.State == 0) then
            local dir = (circle.TargetPosition - circle.Position):Normalized();
            local accel = dir * 2;
            circle:AddVelocity(accel);

            -- 碰撞墙壁。
            local room = Game():GetRoom();
            if (not room:IsPositionInRoom(circle.Position, 16)) then
                circle.State = 1;
                circle.Timeout = 60;
                circle.Position = room:GetClampedPosition(circle.Position, 17);
                circle.Velocity = Vector.Zero;

                local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, circle.Position, circle.Velocity, circle):ToEffect();
                tracer.LifeSpan = 60
                tracer.Timeout = 60;
                tracer.PositionOffset = Vector.Zero;
                tracer.SpriteScale = Vector(1.5, 1.5);
                tracer.TargetPosition = Vector.FromAngle(circle.SpriteRotation);
            end
        else
            if (circle.Timeout == 30) then
                -- local laser = Isaac.Spawn(7, 3,0, circle.Position, Vector.Zero, circle):ToLaser();
                -- laser.FirstUpdate = false;
                -- laser.Parent = circle;
                -- laser.Timeout = 30
                -- laser.PositionOffset = circle.PositionOffset;
                -- laser.AngleDegrees = circle.SpriteRotation;
                local laser = EntityLaser.ShootAngle(5, Vector(-5800,-5800), circle.SpriteRotation, 30, circle.PositionOffset, circle);
                SetLaserThin(laser, true);
                local color = Color(0.6,0.6,0.6,1,circle.Color.R,circle.Color.G,circle.Color.B);
                laser:SetColor(color, -1, 0);
            elseif (circle.Timeout < 30) then

                local col = circle.Color;
                circle.Color = Color(col.R,col.G,col.B,circle.Timeout / 30, col.RO, col.GO, col.BO);
                if (circle.Timeout == 0) then
                    circle:Remove();
                end
            end
        end
        circle:MultiplyFriction(0.9);
    end
    Circle:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostCircleUpdate, Circle.Variant)
    Note.MarisaCircle = Circle;
end

do -- 各类音符的行动AI。
    Note.AIList = {};

    local SubType;

    do -- 若鹭姬。
        local WakasagihimeParams = ProjectileParams();
        WakasagihimeParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
        SubType = Note.SubTypes.WAKASAGIHIME;
        local function WakasagihimeAI(note)
            note.Target = note:GetPlayerTarget();
            local target = note.Target;

            if (target) then
                local spr = note:GetSprite();
                local state = note.State;
                
                if (state == Note.States.ACTIVE) then -- 默认状态。
                    note.State = Note.States.ATTACK;
                elseif (state == Note.States.ATTACK) then -- 攻击状态。

                    if (spr:IsFinished("Jump")) then
                        spr:Play("Attack");
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, note.Position, Vector.Zero, note);
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION,0.5)
                    elseif (spr:IsPlaying("Attack")) then
                        
                        local acceleration;
                        local nextPosition;

                        do --绕着玩家转圈。
                            local maxDistance = 200;
                            local maxSpeed = 10;
                            -- 计算出下一次要到达的位置。
                            local target2This = (note.Position - target.Position):Rotated(10);
                            if (target2This:Length() > maxDistance) then
                                target2This = target2This:Resized(maxDistance);
                            end
                            nextPosition = target2This + target.Position;

                            local next2This = nextPosition - note.Position;
                            local dot = note.Velocity:Dot(next2This:Normalized());
                            local speed = math.min(5, maxSpeed - dot);
                            acceleration = (next2This):Resized(speed);
                            note:AddVelocity(acceleration);
                        end

                        do -- 生成子弹。
                            if (note:IsFrame(7,0)) then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, note.Position, Vector.Zero, note);
                                THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION,0.5)
                            end

                            local interval = math.min(7, Note:GetActiveNoteCount() * 2 +1);
                            if (note:IsFrame(interval, 0)) then
                                for i = 0, 1 do
                                    local angle = -135;
                                    if (i == 1) then
                                        angle = 135;
                                    end
                                    local vel = Vector.FromAngle(note.SpriteRotation + 90 + angle):Resized(10);
                                    note:FireProjectiles(note.Position, vel, 0, WakasagihimeParams)
                                end
                            end
                        end

                        --设置图像旋转。
                        local targetRotation = note.Velocity:GetAngleDegrees() - 90;
                        local includedAngle = Math.GetAngleDiff(note.SpriteRotation, targetRotation);
                        local nextRotation = note.SpriteRotation + includedAngle * 0.3;
                        note.SpriteRotation = nextRotation;
                    else
                        spr:Play("Jump");
                    end
                end
            end
            RunStateTime(note);
        end
        Note.AIList[SubType] = WakasagihimeAI;
    end

    do -- 赤蛮奇
        SubType = Note.SubTypes.SEKIBANKI;
        local function SekibankiAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 攻击状态。
                spr:Play("Active");
                if (note:IsFrame(30, 0)) then
                    local headCount = 0;
                    local maxHeadCount = math.min(7, 9 -Note:GetActiveNoteCount() * 2);
                    local Drone = Note.SekibankiDrone;
                    for _, ent in ipairs(Isaac.FindByType(Drone.Type, Drone.Variant)) do
                        if (CompareEntity(ent.Parent, note)) then
                            headCount = headCount + 1;
                        end
                    end
                    local spawnCount = maxHeadCount - headCount;
                    if (spawnCount > 0) then
                        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_BOON);
                    end
                    for i = 1, spawnCount do
                        local angle = 90 / (spawnCount + 1) * i - 135;
                        local vel = Vector.FromAngle(angle) * 20;
                        local drone = Isaac.Spawn(Drone.Type, Drone.Variant, Drone.SubType, note.Position, vel, note);
                        drone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        drone.Parent = note;
                    end
                end
                MoveToTarget(note, 0.3);
            end
            RunStateTime(note);
        end
        Note.AIList[SubType] = SekibankiAI;
    end

    do-- 影狼
        SubType = Note.SubTypes.KAGEROU;

        local function KagerouAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            local activeCount = Note:GetActiveNoteCount();
            local cooldown = math.min(90, activeCount * 40-30);
            local interval = math.min(30, activeCount * 3.333+20);
            local speed = math.max(0.2, 0.35-activeCount * 0.05);

            if (state == Note.States.ACTIVE) then -- 活动状态。
                spr:Play("Active")
                if (note.StateFrame > cooldown) then
                    Note:SetState(note, Note.States.ATTACK)
                end
            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                if (note.StateFrame == 1) then
                    spr:Play("TransformWolf")
                    note.I1 = 0;
                end

                local function Retarget()
                    note.Target = note:GetPlayerTarget();
                    local this2Target = note.Target.Position - note.Position;
                    note.TargetPosition = note.Position + this2Target:Resized(math.min(math.max(this2Target:Length(), 240), 360));
                    note.FlipX = this2Target.X < 0;
                    local rot = this2Target:GetAngleDegrees();
                    if (note.FlipX) then
                        rot = 180 - rot
                    end
                    note.SpriteRotation = rot;
                    note.StateFrame = 1;
                    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_KAGEROU_ROAR);
                end
                local attackEnd = note.I1 >= 2 and note.StateFrame >= interval;
                if (not attackEnd) then
                    
                    if (spr:IsFinished("TransformWolf")) then
                        spr:Play("Attack");
                        Retarget()
                        note.I1 = 0;
                    elseif (spr:IsPlaying("Attack")) then
                        note.Size = 24;
                        MoveToTarget(note, 0.2);
                        --生成拖影。
                        local PlayerTrail = THI.Effects.PlayerTrail;
                        local trail = Isaac.Spawn(PlayerTrail.Type, PlayerTrail.Variant, PlayerTrail.SubTypes.KAGEROU, note.Position, Vector.Zero, note):ToEffect();
                        
                        local trailSprite = trail:GetSprite();
                        trailSprite:Load(spr:GetFilename(), true);
                        trailSprite:SetFrame(spr:GetAnimation(), spr:GetFrame())
                        trail.FlipX = note.FlipX;
                        trail.SpriteRotation = note.SpriteRotation;

                        if(note.StateFrame > interval) then
                            Retarget()
                            note.I1 = note.I1 + 1;
                        end
                    end
                end

                if (attackEnd) then
                    note.SpriteRotation = note.SpriteRotation * 0.8;
                    note.FlipX = false;
                    note.Size = 16;
                    spr:Play("TransformBack")
                    if (spr:IsFinished("TransformBack")) then
                        Note:SetState(note, Note.States.ACTIVE)
                    end
                end
            end
            RunStateTime(note)
        end
        Note.AIList[SubType] = KagerouAI;
    end

    do -- 弁弁
        local BenbenParams = ProjectileParams()
        BenbenParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        BenbenParams.Color = Color(1,1,1,1,0.5,0.5,0);
        BenbenParams.FallingAccelModifier = -0.2;
        BenbenParams.FallingSpeedModifier = 3;

        local function BenbenAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                Note:SetState(note, Note.States.ATTACK);
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                if (note.StateFrame == 1) then
                    spr:Play("Attack")
                end
                local rageStage = 5 - Note:GetActiveNoteCount();

                local angleRange = 360;
                local anglePerBullet = 37 - rageStage * 3;
                local interval = angleRange / anglePerBullet;
                local layerCount = rageStage + 1;
                if (note.StateFrame % ((8 - rageStage)) == 0) then
                    
                    local angle = note.StateFrame % interval * anglePerBullet;
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
                    for dir = -1, 1, 2 do
                        for i = 1, layerCount do
                            local vel = Vector.FromAngle(angle + i) * dir * (5 + i * 0.3);
                            note:FireProjectiles(note.Position, vel, 0, BenbenParams);
                        end
                    end
                end

                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[Note.SubTypes.BENBEN] = BenbenAI;
    end

    do -- 梅露兰

        local MerlinParams = ProjectileParams()
        MerlinParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        MerlinParams.Color = Color(1,1,1,1,0.5,0,0.5);
        MerlinParams.FallingAccelModifier = -0.2;
        MerlinParams.FallingSpeedModifier = 3;
        local function MerlinAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                if (note.StateFrame == 1) then
                    spr:Play("Active");
                end

                if (note.StateFrame > 30) then
                    Note:SetState(note, Note.States.ATTACK);
                end
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                local activeNotes = Note:GetActiveNoteCount();
                if (note.StateFrame == 1) then
                    spr:Play("Attack");
                end

                local rageStage = 5 - activeNotes;

                local maxCount = 5 + rageStage * 3;
                local interval = (30 - rageStage * 3) * 2;

                local anglePerBullet = 28 - rageStage * 2;
                local frame = note.StateFrame % interval;
                if (frame == 0) then
                    note.Target = note:GetPlayerTarget();
                end

                if (frame <= maxCount) then
                    
                    local angleRange = anglePerBullet * maxCount;
                    local groupCount = 6;
                    local countPerLine = 3;
                    local target = note.Position;
                    if (note.Target) then
                        target = note.Target.Position;
                    end
                    local sourcePos = note.Position;
                    local angle = frame * anglePerBullet + (target - sourcePos):GetAngleDegrees() - angleRange / 2
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
                    for i = 1, countPerLine do
                        local vel = Vector.FromAngle(angle + anglePerBullet / 2) * (3 + i);
                        note:FireProjectiles(sourcePos, vel, 0, MerlinParams);
                    end

                    -- Fire Laser.
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_LASER, 0.5);
                    local laser = EntityLaser.ShootAngle(3, Vector(-5800,-5800), angle, 60, Vector.Zero, note);
                    laser.Velocity = Vector.FromAngle(angle) * 8;
                    laser.MaxDistance = 1;
                    laser.Parent = nil;
                    SetLaserThin(laser, true, note.Position);
                    SetLaserExtending(laser, 120);
                end
                MoveToTarget(note)
            end
            RunStateTime(note)
        end

        Note.AIList[Note.SubTypes.MERLIN] = MerlinAI;
    end

    do -- 露娜萨
        
        local flags = ProjectileFlags.DECELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT;
        local LunasaParams = ProjectileParams()
        LunasaParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        LunasaParams.Color = Color(1,1,1,1,0.5,0,0);
        LunasaParams.FallingAccelModifier = -0.2;
        LunasaParams.FallingSpeedModifier = 3;
        LunasaParams.Acceleration = 1.2;
        
        local function SpawnProjectiles(note, position, layerCount)
            local maxCount = 12;
            local groupCount = 4;
            local anglePerBullet = 360 / maxCount
            local bulletsPerGroup = math.floor(maxCount / groupCount);
            layerCount = layerCount or 1;
            SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
            for l = 1, layerCount do
                local randomValue = Random() % 360;
                for i = 1, maxCount do
                    local angle = i * anglePerBullet + randomValue;
                    if (l % 2 == 0) then
                        angle = -angle;
                    end
                    local vel = Vector.FromAngle(angle) * 10;
                    local changeVel = (i % bulletsPerGroup + 3) * -1;

                    LunasaParams.BulletFlags = flags;
                    LunasaParams.ChangeTimeout = 20 + l * 5;
                    LunasaParams.ChangeFlags = 0;
                    if (note:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        LunasaParams.ChangeFlags = LunasaParams.ChangeFlags | ProjectileFlags.CANT_HIT_PLAYER;
                    end
                    if (note:HasEntityFlags(EntityFlag.FLAG_CHARM)) then
                        LunasaParams.ChangeFlags = LunasaParams.ChangeFlags | ProjectileFlags.HIT_ENEMIES;
                    end
                    LunasaParams.ChangeVelocity = changeVel;
                    note:FireProjectiles(position, vel, 0, LunasaParams);
                end
            end
        end

        
        local function LunasaAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                Note:SetState(note, Note.States.ATTACK);
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                local activeNotes = Note:GetActiveNoteCount();
                if (note.StateFrame == 1) then
                    spr:Play("Attack");
                end

                local rageStage = 5 - activeNotes;
                local interval = 30 + rageStage * 10;
                if (note.StateFrame % interval == 0) then
                    SpawnProjectiles(note, note.Position, rageStage + 1);
                end
                MoveToTarget(note)
            end
            RunStateTime(note)
        end

        Note.AIList[Note.SubTypes.LUNASA] = LunasaAI;
    end

    do -- 莉莉卡

        local flags = ProjectileFlags.DECELERATE | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT;
        local LyricaParams = ProjectileParams()
        LyricaParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
        LyricaParams.Color = Color(1,1,1,1,0.5,0,0);
        LyricaParams.BulletFlags = flags;
        LyricaParams.ChangeTimeout = 10000;
        LyricaParams.FallingAccelModifier = -0.2;
        LyricaParams.FallingSpeedModifier = 3;
        LyricaParams.Acceleration = 1.2;

        local function SpawnProjectiles(note, position, rageStage)
            local maxCount = 12;
            local groupCount = 6;
            local angleRange = 180;
            local anglePerBullet = angleRange / maxCount
            local bulletsPerGroup = math.floor(maxCount / groupCount);

            rageStage = rageStage or 0;
            local layerCount = rageStage + 2;
            local randomValue = Random() % 360 / 360 * anglePerBullet;
            local targetPos = note.TargetPosition;

            
            local function FireProjectile(vel, changeVel, homingStrength)
                LyricaParams.ChangeVelocity = changeVel;
                LyricaParams.HomingStrength = homingStrength;
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
                note:FireProjectiles(position, vel, 0, LyricaParams);
            end

            local targetAngle = 0;
            if (note.Target) then
                targetAngle = (note.Target.Position - note.Position):GetAngleDegrees();
            end

            -- 发射半圆敌弹。
            for i = 1, maxCount do
                local angle = i * anglePerBullet - angleRange / 2 + targetAngle + randomValue;
                local vel = Vector.FromAngle(angle) * 10;
                local changeVel = 6;

                FireProjectile(vel, changeVel, -(i % 5));
            end
            
            -- 发射长条敌弹。
            for layer = 1, layerCount do
                for i = 1, 5 do
                    local angle = randomValue + targetAngle;
                    local vel = Vector.FromAngle(angle) * 10;
                    local changeVel = 6 + 0.2 * layer;

                    FireProjectile(vel, changeVel, -(i % 5));
                end
            end

            for i, ent in ipairs(Isaac.FindByType(9)) do
                if (ent.FrameCount == 0 and CompareEntity(ent.SpawnerEntity, note)) then
                    local proj = ent:ToProjectile();
                    local targetPosition = Vector.Zero;
                    if (note.Target) then
                        local target2Note = note.Target.Position - note.Position;
                        local index = -proj.HomingStrength;
                        local sign = index % 2 * 2 - 1;
                        local angle = math.ceil(index / 2) * 30;
                        target2Note = target2Note:Rotated(angle * sign);
                        targetPosition = note.Position + target2Note;
                    end
                    local data = GetProjectileData(ent, true);
                    data.Lyrica = {
                        TargetPosition = targetPosition,
                        Timeout =  30 - rageStage * 5,
                    }

                    proj.HomingStrength = 1;
                end
            end
        end

        local function LyricaAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                Note:SetState(note, Note.States.ATTACK);
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                if (note.StateFrame == 1) then
                    spr:Play("Attack")
                end
                local rageStage = 5 - Note:GetActiveNoteCount();

                local interval = 60 - rageStage * 7;
                if (note.StateFrame % interval == 0) then
                    note.Target = note:GetPlayerTarget();
                    SpawnProjectiles(note, note.Position, rageStage);
                end
                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        

        Note.AIList[Note.SubTypes.LYRICA] = LyricaAI;

        local function PostProjectileUpdate(mod, proj)
            local data = GetProjectileData(proj, false);
            if (data and data.Lyrica) then
                if (proj:HasProjectileFlags(ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT)) then
                    if (proj.FrameCount % (data.Lyrica.Timeout or 30) == 0) then
                        proj.Velocity = (data.Lyrica.TargetPosition - proj.Position):Resized(proj.ChangeVelocity);
                        proj.ProjectileFlags = proj.ProjectileFlags & ~flags;
                    end
                end
            end
        end
        Note:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, PostProjectileUpdate);
    end

    do --八桥
        local YatsuhashiParams = ProjectileParams()
        YatsuhashiParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        YatsuhashiParams.Color = Color(1,1,1,1,0.5,0.5,0);
        YatsuhashiParams.FallingAccelModifier = -0.2;
        YatsuhashiParams.FallingSpeedModifier = 3;

        
        local DecelerateParams = ProjectileParams()
        DecelerateParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        DecelerateParams.Color = Color(1,1,1,1,0.8,0,0.8);
        DecelerateParams.FallingAccelModifier = -0.15;
        DecelerateParams.FallingSpeedModifier = 3;
        DecelerateParams.BulletFlags = ProjectileFlags.ACCELERATE_EX;
        DecelerateParams.Acceleration = 0.95;

        local function YatsuhashiAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                Note:SetState(note, Note.States.ATTACK);
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                if (note.StateFrame == 1) then
                    spr:Play("Attack")
                end
                local rageStage = 5 - Note:GetActiveNoteCount();

                local angleRange = 360;
                local anglePerBullet = 37 - rageStage * 6;
                local interval = angleRange / anglePerBullet;
                local layerCount = rageStage / 2 + 1;

                if (note.StateFrame % ((9 - rageStage)) == 0) then
                    
                    local angle = note.StateFrame % interval * anglePerBullet;
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
                    for dir = -1, 1, 2 do
                        local vel = Vector.FromAngle(angle) * dir * 3;
                        note:FireProjectiles(note.Position, vel, 0, YatsuhashiParams);

                        local vel = Vector.FromAngle(angle + anglePerBullet / 2) * dir * 8;
                        note:FireProjectiles(note.Position, vel, 0, DecelerateParams);
                    end
                end

                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[Note.SubTypes.YATSUHASHI] = YatsuhashiAI;
    end

    -- 为乐队音符分组。
    local function PostUpdate(mod)
        local instruments = {
            Groups = {},
            HitPoints = {},
            MaxHitPoints = {},
            Lonely = {
                Entities = {},
                HitPoints = 0,
                MaxHitPoints = 0,
                Dead = false,
            }
        };
        for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
            local npc = ent:ToNPC();
            if (Note:IsNoteActive(npc)) then
                for i = Note.SubTypes.BENBEN, Note.SubTypes.YATSUHASHI do
                    if (ent.SubType == i) then
                        local groupIdx = npc.GroupIdx;
                        local group = nil;
                        if (groupIdx < 0) then
                            group = instruments.Lonely
                        else
                            instruments.Groups[groupIdx] = instruments.Groups[groupIdx] or {
                                Entities = {},
                                HitPoints = 0,
                                MaxHitPoints = 0,
                                Dead = false,
                            };
                            group = instruments.Groups[groupIdx];
                        end
                        table.insert(group.Entities, npc);
                        group.HitPoints = group.HitPoints + ent.HitPoints;
                        group.MaxHitPoints = group.MaxHitPoints + ent.MaxHitPoints;
                        group.Dead = group.Dead or ent:IsDead();

                    end
                end
            end
        end

        --分配未分组的音符。
        local spareGroupIdx = 0;
        while (instruments.Groups[spareGroupIdx]) do
            spareGroupIdx = spareGroupIdx + 1;
        end

        instruments.Groups[spareGroupIdx] = instruments.Lonely;
        instruments.Lonely = nil;

        for idx, group in pairs(instruments.Groups) do
            local count = #group.Entities;
            if (count > 0) then
                local hpPercent = group.HitPoints / group.MaxHitPoints;

                local room = Game():GetRoom();
                local center = room:GetCenterPos();
                local angleRange = 180;
                local anglePerNote = 0;
                if (count > 1)then
                    anglePerNote = angleRange / (count - 1);
                end


                -- 每隔一段时间交换位置。
                if (Game().TimeCounter % 150 == 0) then
                    table.sort(group.Entities, function(a, b) return a.I1 < b.I1 end)
                    for i, ent in ipairs(group.Entities) do
                        local otherIndex = Random() % 2 * 2 - 1; 
                        local other = group.Entities[otherIndex];
                        if (other) then
                            local i1 = ent.I1;
                            ent.I1 = other.I1;
                            other.I1 = i1;
                        end
                    end
                end


                for i, ent in ipairs(group.Entities) do
                    -- 初始化I1。
                    if (ent.I1 == 0) then
                        ent.I1 = i;
                    end
                    local vector = Vector.Zero;
                    if (anglePerNote ~= 0) then
                        vector = Vector.FromAngle(anglePerNote * (ent.I1 - 1) - 180);
                    end

                    ent.TargetPosition = center + vector * 240;
                    ent.HitPoints = hpPercent* ent.MaxHitPoints;

                    if (group.Dead and not ent:IsDead()) then
                        ent:Kill();
                        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
                            ent:Die();
                        end
                    end
                end
            end
        end
    end
    Note:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

    do -- 芙兰朵露

        local FlandreTrailParams = ProjectileParams()
        FlandreTrailParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
        FlandreTrailParams.Color = Color(1,0,0,1,0,0,0);

        local function FrandreAI(note)
            local spr = note:GetSprite();
            local state = note.State;


            local laserAngle = note.V1:GetAngleDegrees() - 135;
            local function ShootLaser()
                local laser = EntityLaser.ShootAngle(1, note.Position, laserAngle, 60, note.PositionOffset, note);
                note.Child = laser;
                return laser;
            end
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                if (note.StateFrame == 1) then
                    spr:Play("Active");
                end
                if (note.StateFrame == 30) then
                    spr:Play("Charge");
                    THI.SFXManager:Play(SoundEffect.SOUND_LOW_INHALE);
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, note.Position, Vector.Zero, note):ToEffect();
                    effect.Parent = note;
                    effect.Timeout = 30;
                    effect.LifeSpan = 30;
                    effect.TargetPosition = note.V1:Rotated(-135);
                    effect:FollowParent(note);
                end
                if (note.StateFrame == 60) then
                    spr:Play("Attack");
                    THI.SFXManager:Play(SoundEffect.SOUND_GHOST_ROAR);
                    ShootLaser();

                end
                if (note.StateFrame == 90) then
                    Note:SetState(note, Note.States.ATTACK);
                end
                MoveToTarget(note)

            elseif (state == Note.States.ATTACK) then -- 攻击状态。

                if (not note.Child or not note.Child:Exists()) then
                    ShootLaser()
                else
                    local laser = note.Child:ToLaser();
                    laser.Timeout = 15;
                    laser.Angle = laserAngle;

                    if (note:IsFrame(15, 0)) then
                        local room = Game():GetRoom();
                        local pos = note.Position + Vector.FromAngle(laserAngle) * 120;
                        while (room:IsPositionInRoom(pos, 0)) do
                            local vel = Vector.Zero;
                            note:FireProjectiles(pos, vel, 0, FlandreTrailParams);
                            pos = pos + Vector.FromAngle(laserAngle) * 120;
                        end
                    end
                end
                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[Note.SubTypes.FLANDRE1] = FrandreAI;
        Note.AIList[Note.SubTypes.FLANDRE2] = FrandreAI;
        Note.AIList[Note.SubTypes.FLANDRE3] = FrandreAI;
        Note.AIList[Note.SubTypes.FLANDRE4] = FrandreAI;



        local function PostUpdate(mod)
            local frandres = {
                Groups = {},
                HitPoints = {},
                MaxHitPoints = {},
                Lonely = {
                    Entities = {},
                    HitPoints = 0,
                    MaxHitPoints = 0,
                    Dead = false,
                }
            };
            for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
                local npc = ent:ToNPC();
                if (Note:IsNoteActive(npc)) then
                    for i = Note.SubTypes.FLANDRE1, Note.SubTypes.FLANDRE4 do
                        if (ent.SubType == i) then
                            local groupIdx = npc.GroupIdx;
                            local group = nil;
                            if (groupIdx < 0) then
                                group = frandres.Lonely
                            else
                                frandres.Groups[groupIdx] = frandres.Groups[groupIdx] or {
                                    Entities = {},
                                    HitPoints = 0,
                                    MaxHitPoints = 0,
                                    Dead = false,
                                };
                                group = frandres.Groups[groupIdx];
                            end
                            table.insert(group.Entities, npc);
                            group.HitPoints = group.HitPoints + ent.HitPoints;
                            group.MaxHitPoints = group.MaxHitPoints + ent.MaxHitPoints;
                            group.Dead = group.Dead or ent:IsDead();

                        end
                    end
                end
            end

            --分配未分组的音符。
            local spareGroupIdx = 0;
            while (frandres.Groups[spareGroupIdx]) do
                spareGroupIdx = spareGroupIdx + 1;
            end

            frandres.Groups[spareGroupIdx] = frandres.Lonely;
            frandres.Lonely = nil;

            local tempGlobalData;
            for idx, group in pairs(frandres.Groups) do
                local count = #group.Entities;
                if (count > 0) then
                    tempGlobalData = tempGlobalData or GetTempGlobalData(true);
                    local shouldIncreaseFrame = false;
                    local hpPercent = group.HitPoints / group.MaxHitPoints;
                    tempGlobalData.FrandreFrames = tempGlobalData.FrandreFrames or {};
                    local frames = tempGlobalData.FrandreFrames;
                    local frameCount = frames[idx] or 0;

                    local rotation = frameCount * 0.6 % 360;
    
                    local room = Game():GetRoom();
                    local center = room:GetCenterPos();
                    local offsetX = math.sin(math.rad(frameCount * 0.8 % 360)) * (math.max(0, center.X - 80 - 240));
                    local offsetY = math.cos(math.rad(frameCount * 0.6 % 360 )) * (math.max(0, center.Y - 120 - 240));
                    center = center + Vector(offsetX, offsetY);
                    for i, ent in ipairs(group.Entities) do
                        local vector = Vector.FromAngle(rotation + i * (360 / count));
                        ent.TargetPosition = center + vector * 120;
                        vector = Vector.FromAngle(rotation + frameCount *0.5 % 360 + i * (360 / count));
                        ent.V1 = vector;
                        ent.HitPoints = hpPercent* ent.MaxHitPoints;
                        if (ent.State == Note.States.ATTACK) then
                            shouldIncreaseFrame = true;
                        end

                        if (group.Dead and not ent:IsDead()) then
                            ent:Kill();
                            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
                                ent:Die();
                            end
                        end
                    end
                    if (shouldIncreaseFrame) then
                        frames[idx] = frameCount + 1;
                    else
                        frames[idx] = 0;
                    end
                end
            end
        end
        Note:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

        local function PostNewRoom(mod)
            local tempGlobalData = GetTempGlobalData(false);
            if (tempGlobalData) then
                tempGlobalData.FrandreFrames = nil;
            end
        end
        Note:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)
    end

    do -- 灵梦
        SubType = Note.SubTypes.REIMU;
        do
        
            local YinYangOrb = ModEntity("Yin-Yang Orb Projectile", "YIN_YANG_ORB_PROJECTILE");
            local function GetProjectileData(proj, create)
                return Note:GetData(proj, create, function ()
                    return {
                        Enlarging = true;
                    }
                end)
            end
            function YinYangOrb:SetEnlarging(proj, value)
                local data = GetProjectileData(proj, true);
                data.EnLarging = value;
            end
            function YinYangOrb:IsEnlarging(proj)
                local data = GetProjectileData(proj, false);
                return data and data.EnLarging;
            end
            
            local function PostProjectileInit(mod, proj)
                proj:GetSprite():Play("Idle");
            end
            YinYangOrb:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, PostProjectileInit, YinYangOrb.Variant)
            local function PostProjectileUpdate(mod, proj)
                if (YinYangOrb:IsEnlarging(proj)) then
                    proj.Size = proj.Size + 0.5;
                    proj.SpriteScale = Vector(proj.Size, proj.Size) / 11;
                end

                if (proj.Variant == YinYangOrb.Variant) then
                    if (proj:IsDead()) then
                        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, proj.Position, Vector.Zero, proj);
                        poof.Color = proj.Color;
                        poof.SpriteScale = proj.SpriteScale;
                    end
                end
            end
            YinYangOrb:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, PostProjectileUpdate)
    
            Note.YinYangOrbProjectile = YinYangOrb;
        end

        local ReimuYinYangOrbParams = ProjectileParams();
        ReimuYinYangOrbParams.Variant = Note.YinYangOrbProjectile.Variant;
        ReimuYinYangOrbParams.FallingAccelModifier = -0.2;
        ReimuYinYangOrbParams.FallingSpeedModifier = 3;
        
        local HomingParams = ProjectileParams();
        HomingParams.Variant = Note.YinYangOrbProjectile.Variant;
        HomingParams.FallingAccelModifier = -0.1;
        HomingParams.FallingSpeedModifier = 2;
        HomingParams.BulletFlags = ProjectileFlags.SMART;
        HomingParams.Color = Consts.Colors.HomingTear;

        local function ReimuAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                spr:Play("Active");

                local interval = 30;
                local rage = Note:GetActiveNoteCount() < 2;
                if (rage) then
                    interval = 15;
                end
                if (note:IsFrame(interval, 0)) then
                    note.I1 = note.I1 + 10;
                    for i = 1, 6 do
                        local vel = Vector.FromAngle(i * 60 + note.I1) * 7;
                        note:FireProjectiles(note.Position, vel, 0, ReimuYinYangOrbParams)
                    end
                    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
                        if (CompareEntity(ent.SpawnerEntity, note) and ent.FrameCount == 0) then
                            Note.YinYangOrbProjectile:SetEnlarging(ent, true);
                        end
                    end
                    
                    if (rage) then
                        for i = 1, 8 do
                            local vel = Vector.FromAngle(i * 45 - note.I1) * 7;
                            note:FireProjectiles(note.Position, vel, 0, HomingParams)
                        end
                    end
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.2);
                end
                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[SubType] = ReimuAI;

        

    end

    do -- 魔理沙
        SubType = Note.SubTypes.MARISA;

        local function MarisaAI(note)
            local spr = note:GetSprite();
            local state = note.State;
            
            local rage = Note:GetActiveNoteCount() < 2;
            if (state == Note.States.ACTIVE) then -- 活动状态。
                spr:Play("Active");

                
                local interval = 120;
                if (rage) then
                    interval = 40;
                end
                local endFrame = interval * 3 -1
                if (note.StateFrame > endFrame) then
                    Note:SetState(note, Note.States.ATTACK);

                else
                    -- 发射地球射线。
                    local time = 0;
                    local frame = note.StateFrame % interval;
                    if (frame == 1) then
                        local before = note.I1;
                        repeat
                            note.I1 = Random() % 4;
                        until note.I1 % 2 ~= before % 2;
                    end
                    local room = Game():GetRoom();
                    local horizontal = note.I1 % 2 == 0;
                    local negative = note.I1 > 1;
                    local width = room:GetGridWidth();
                    local height = room:GetGridHeight();
                    if (frame % 2 == 0) then
                        local i = math.floor(frame / 2);
                        local x, y;
                        local inRoom;
                        local length;
                        local offset = i * 2 - time;
                        if (not rage) then
                            offset = i * 3 - time;
                        end
                        if (horizontal) then
                            if (negative) then
                                x = 1;
                                y = height - 1 - offset;
                            else
                                x = width - 1;
                                y = offset;
                            end
                            inRoom = y > 0 and y < height - 1;
                            length = width;
                        else
                            if (negative) then
                                x = offset;
                                y = 1;
                            else
                                x = width - 1 - offset;
                                y = height - 1;
                            end
                            inRoom = x > 0 and x < width - 1;
                            length = height;
                        end
                        if (inRoom) then
                            local index = x + y * width;
                            local pos = room:GetClampedPosition(room:GetGridPosition(index), 8);
                            local Circle = Note.MarisaCircle;
                            local circle = Isaac.Spawn(Circle.Type, Circle.Variant, Circle.SubType, note.Position, Vector.Zero, note):ToEffect();
                            circle.TargetPosition = pos;
                            circle.SpriteRotation = note.I1 * 90 - 180

                            --设置魔法阵颜色。
                            local hue = (i / ((length - 4) / 2)) % 1 * 360;
                            local r, g, b = Math:HSVToRGB(hue,1,1);
                            
                            circle.Color = Color(r,g,b,1,0,0,0);
                        end
                    end
                end

                MoveToTarget(note)
            elseif (state == Note.States.ATTACK) then -- 魔炮状态。
                if (note.StateFrame == 1) then
                    spr:Play("Charge");

                    -- 瞄准玩家。
                    local target = note:GetPlayerTarget();
                    note.Target = target;
                    note.V1 = (target.Position - note.Position):Normalized();
                    THI.SFXManager:Play(SoundEffect.SOUND_FRAIL_CHARGE, 1)
                    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_LASER, 0.5)

                    local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, note.Position, Vector.Zero, note):ToEffect();
                    note.Child = tracer;
                    tracer.Parent = note;
                    tracer:FollowParent(note);
                    tracer.TargetPosition = note.V1;
                    tracer.LifeSpan = 60;
                    tracer.Timeout = 60;
                end


                local laser = note.Child and note.Child:ToLaser();
                if (laser) then
                    if (laser.Timeout > 30) then
                        local size = math.min(1, (60 - laser.Timeout) / 30);
                        laser.Size = size * 60;
                        laser.SpriteScale = Vector(size, 1);
                    end
                    
                    if (laser.FrameCount > 1) then
                        laser.ParentOffset = Vector.Zero;
                    end
                end

                if (note.StateFrame == 30) then
                    spr:Play("Attack");
                    local laser = EntityLaser.ShootAngle(6, Vector(-5800, -5800), note.V1:GetAngleDegrees(), 60, note.PositionOffset, note):ToLaser();
                    laser.Parent = note;
                    laser:SetColor(MarisaLaserColor, -1, 0);

                    local tracer = note.Child and note.Child:ToEffect();
                    if (tracer) then
                        tracer.Timeout = 1;
                    end

                    note.Child = laser;
                end
                
                if (note.StateFrame > 90) then
                    Note:SetState(note, Note.States.ACTIVE);
                end

                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[SubType] = MarisaAI;

    end

    do-- 赫卡提亚
        SubType = Note.SubTypes.HECATIA;

        local function HecatiaAI(note)
            local spr = note:GetSprite();
            local state = note.State;

            local function CheckMoon()
                local moonCount = 0;
                local maxMoonCount = 3;
                local Moon = Note.HecatiaMoon;
                for _, ent in ipairs(Isaac.FindByType(Moon.Type, Moon.Variant)) do
                    if (CompareEntity(ent.Parent, note)) then
                        moonCount = moonCount + 1;
                    end
                end
                local spawnCount = maxMoonCount - moonCount;
                if (spawnCount > 0) then
                    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_BOON);
                end
                for i = 1, spawnCount do
                    local angle = 90 / (spawnCount + 1) * i - 135;
                    local vel = Vector.FromAngle(angle) * 20;
                    local moon = Isaac.Spawn(Moon.Type, Moon.Variant, Moon.SubType, note.Position, vel, note);
                    moon.Size = 0;
                    moon.SpriteScale = Vector(0, 0);
                    moon:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    moon.Parent = note;
                end
            end
            
            if (state == Note.States.ACTIVE) then -- 活动状态。
                spr:Play("Active");
                if (note.StateFrame % 60 == 1) then
                    CheckMoon();
                    local room = Game():GetRoom();
                    note.TargetPosition = room:GetCenterPos() + RandomVector() * 60 * Vector(1, 0.3);
                end

                MoveToTarget(note)
            end
            RunStateTime(note)
        end
        Note.AIList[SubType] = HecatiaAI;
    end
end

local BossFight = {};
do --战斗。
    
    BossFight.NoteLevels = {
        { 
            SubTypes = { [Note.SubTypes.HECATIA] = true },
            Backdrop = BackdropType.DARKROOM,
            ItemPool = ItemPoolType.POOL_PLANETARIUM,
        },
        { 
            SubTypes = { [Note.SubTypes.REIMU] = true, [Note.SubTypes.MARISA] = true },
            Backdrop = BackdropType.CHEST,
            ItemPool = ItemPoolType.POOL_TREASURE,
        },
        { 
            SubTypes = { [Note.SubTypes.WAKASAGIHIME] = true, [Note.SubTypes.SEKIBANKI] = true, [Note.SubTypes.KAGEROU] = true },
            Backdrop = BackdropType.SECRET,
            ItemPool = ItemPoolType.POOL_SECRET,
        },
        { 
            SubTypes = { [Note.SubTypes.FLANDRE1] = true, [Note.SubTypes.FLANDRE2] = true, [Note.SubTypes.FLANDRE3] = true, [Note.SubTypes.FLANDRE4] = true },
            Backdrop = BackdropType.SHEOL,
            ItemPool = ItemPoolType.POOL_DEVIL,
        },
        { 
            SubTypes = { [Note.SubTypes.BENBEN] = true, [Note.SubTypes.MERLIN] = true, [Note.SubTypes.LUNASA] = true, [Note.SubTypes.LYRICA] = true, [Note.SubTypes.YATSUHASHI] = true },
            Backdrop = BackdropType.CATHEDRAL,
            ItemPool = ItemPoolType.POOL_ANGEL,
        },
    }

    BossFight.NotePositions = {
        Vector(-336,60),
        Vector(-288,48),
        Vector(-240,0),
        Vector(-192,60),
        Vector(-144,48),
        Vector(-96,12),
        Vector(-48,60),
        Vector(0,48),
        Vector(96,12),
        Vector(144,60),
        Vector(192,48),
        Vector(240,0),
        Vector(288,60),
        Vector(336,48),
        Vector(384,12),
    }


    local PauseFocusBefore = nil;
    function BossFight:StartOpeningAnimation()
        local room = Game():GetRoom();

        local tempData = GetTempGlobalData(true);
        if (not tempData.PlayingOpening) then
            tempData.PlayingOpening = true;
            tempData.OpeningFrame = 0;
            local Opt = THI.Shared.Options;
            Opt:CancelPauseFocus();
        end
    end
    function BossFight:StartBossFight()
        local room = Game():GetRoom();
        --播放音乐。
        local music = MusicManager()
        if (music:GetCurrentMusicID() ~= THI.Music.REVERIE) then
            music:Play(THI.Music.REVERIE, 0);
            music:UpdateVolume();
            
        end

        -- 生成音符。
        for _ ,ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
            ent:Remove();    
        end

        ClearTempGlobalData();
        local tempData = GetTempGlobalData(true);
        tempData.PlayingOpening = false;
        tempData.OpeningFrame = 0;
        local center = room:GetCenterPos();
        for i = 0, #self.NotePositions - 1 do
            local pos = Vector(center.X, 160) + self.NotePositions[i + 1];
            local note = Isaac.Spawn(Note.Type, Note.Variant, i, pos, Vector.Zero, nil):ToNPC();
            note.SpriteOffset = Vector(0, -80);
            Note:DormantNote(note);
            table.insert(tempData.Notes, note);
        end

        

        
        local data = GetGlobalData(true);
        data.StartedFight = true;

        
        --更新玩家的射程。
        for p, player in Detection.PlayerPairs() do
            player:AddCacheFlags(CacheFlag.CACHE_RANGE);
            player:EvaluateItems();
        end

    end

    
    local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
        if (BossFight:IsBossRoom() and pool == ItemPoolType.POOL_LIBRARY and loopCount <= 1) then
            local itemPool = Game():GetItemPool();
            local newPool = ItemPools:GetPoolForRoom(RoomType.ROOM_ERROR, seed)
            local item = itemPool:GetCollectible(newPool, decrease, seed);
            return item
        end
    end
    Note:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, PreGetCollectible, nil, 0);

    local function PostNewRoom()
        if (BossFight:IsBossRoom()) then
            -- 关闭所有门。
            local room = Game():GetRoom();
            for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(slot);
                if (door) then
                    room:RemoveDoor(slot);
                end
            end
            
            if (not BossFight:IsBossFightStarted()) then
                for p, player in Detection.PlayerPairs(true, true) do
                    player:PlayExtraAnimation("Appear");
                end
            end
        end
    end
    Note:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

    local function InputAction(mod, entity, hook, action)
        if (hook == InputHook.IS_ACTION_TRIGGERED and 
        (action == ButtonAction.ACTION_MENUBACK or
        action == ButtonAction.ACTION_PAUSE or 
        action == ButtonAction.ACTION_CONSOLE)) then
            if (BossFight:IsPlayingOpening()) then
                return false;
            end
        end
    end
    Note:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)

    function BossFight:SpawnExitDoor()
        local game = Game();
        local room = game:GetRoom();
        local center = room:GetCenterPos() ;
        center = center + Vector(0, -120);
        local pos;
        pos = room:FindFreePickupSpawnPosition(center + Vector(-40, 0));
        local gridIndex = room:GetGridIndex(pos);
        room:SpawnGridEntity (gridIndex, GridEntityType.GRID_TRAPDOOR, 0, 1, 0);
        pos = room:FindFreePickupSpawnPosition(center + Vector(40, 0));
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 0, pos, Vector.Zero, nil);

        pos = room:FindFreePickupSpawnPosition(center + Vector(0, 80));
        local portalEntity = Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 1, pos, true)
        portalEntity.VarData = 1
        local sprite = portalEntity:GetSprite()
        sprite:Load("gfx/grid/voidtrapdoor.anm2", true)
    end

    function BossFight:IsBossRoom()
        local level = Game():GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        if (roomDesc and roomDesc.Data) then
            return roomDesc.Data.Type == Note.Room.Type and roomDesc.Data.Variant == Note.Room.Variant;
        end
        return false;
    end

    function BossFight:IsBossFightStarted()
        local data = GetGlobalData(false);
        return data and data.StartedFight;
    end
    function BossFight:IsBossFightOver()
        local data = GetGlobalData(false);
        return data and data.FightOver;
    end

    function BossFight:IsPlayingOpening()
        local data = GetTempGlobalData(false);
        return data and data.PlayingOpening;
    end


    BossFight.ShakeTimes = {
        20,
        110,
        180,
        220,
        260,
        280,
        300,
        310,
        320,
        330,
        335,
        340,
        345,
        350,
        355,
        360,
        
    }

    function BossFight:Update()
        -- 生成音符。
        if (BossFight:IsBossRoom()) then
            local tempData = GetTempGlobalData(false);


            --将音调设为普通。
            local game = Game();
            local room = game:GetRoom();
            local music = MusicManager()



            if (tempData) then
                if (self:IsPlayingOpening()) then -- 播放开场动画。
                    local center = room:GetCenterPos();
                    local frame = tempData.OpeningFrame;
                    local Prop = THI.Effects.ReverieProp;
                    if (frame == 0) then
                        local black = Isaac.Spawn(Prop.Type, Prop.Variant, Prop.SubTypes.BLACK, center, Vector.Zero, nil);
                        black:SetColor(Color(0,0,0,0,0,0,0), 30, 0, true);
                        music:Fadeout();

                    end
                    
                    if (frame >= 60 and frame < 150) then
                        
                        if (frame == 60) then
                            --播放音乐。
                            if (music:GetCurrentMusicID() ~= THI.Music.REVERIE) then
                                music:Play(THI.Music.REVERIE, 0);
                                music:UpdateVolume();
                            end
                        end
                        for i = 1, #self.NotePositions do
                            if (frame == 60 + i * 5) then
                                local position = center + BossFight.NotePositions[i];
                                local scale = Vector(1.5, 1.5);
                                local note = Isaac.Spawn(Note.Type, Note.Variant, i - 1, position, Vector.Zero, nil):ToNPC();
                                note.Scale = 1.5;
                                Note:SetState(note, Note.States.APPEAR);

                                local Wave = THI.Effects.ReverieNoteWave;
                                Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubType, position, Vector.Zero, note);
                            end
                        end
                    end

                    --音符震动。
                    for i = 1, #BossFight.ShakeTimes do
                        local time = BossFight.ShakeTimes[i] + 60;
                        if (frame == time) then
                            for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
                                local npc = ent:ToNPC();
                                if (npc.State == Note.States.APPEAR) then
                                    local scale = Vector(1.5, 1.5);
                                    npc.Scale = 1.5;
                                    local Wave = THI.Effects.ReverieNoteWave;
                                    local wave = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubType, npc.Position, Vector.Zero, npc);
                                    wave.SpriteScale = scale;
                                end
                            end
                            game:ShakeScreen(20);
                        end
                    end
                    if (frame == 375) then
                        local center = room:GetCenterPos();
                        local flash = Isaac.Spawn(Prop.Type, Prop.Variant, Prop.SubTypes.FLASH, center, Vector.Zero, nil);
                    end
                    

                    tempData.OpeningFrame = tempData.OpeningFrame + 1;


                elseif (self:IsBossFightStarted() and not self:IsBossFightOver()) then -- 开始作战。
                    tempData.FightLevel = tempData.FightLevel or 0;
                    local levelInfo = self.NoteLevels[tempData.FightLevel + 1];


                    

                    if (levelInfo) then
                        if ((tempData.FightTimer > 120 and Note:GetActiveNoteCount() <= 0) or #Isaac.FindByType(Note.Type, Note.Variant) <= 0) then
                            tempData.FightLevel = tempData.FightLevel + 1;
                            tempData.FightTimer = 0;
                        elseif (tempData.FightTimer == 30) then --移动到场地中。
                            local center = room:GetCenterPos();
                            local notes = {};
                            for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
                                if (levelInfo.SubTypes[ent.SubType] and ent:ToNPC().State == Note.States.DORMANT) then
                                    table.insert(notes, ent);
                                end
                            end
                            
                            local count = #notes;
                            local anglePerNote = 0;
                            if (count > 1) then
                                anglePerNote = 180 / (count - 1);
                            end

                            
                            if (count > 0) then
                                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_BOON)
                            end
                            for i, ent in ipairs(notes) do
                                local pos = center;
                                if (anglePerNote ~= 0) then
                                    pos = pos + Vector.FromAngle(anglePerNote * (i - 1) - 180) * 200;
                                end
                                ent.TargetPosition = pos;
                            end
                        elseif (tempData.FightTimer == 60) then
                            local sfx = SFXManager();
                            game:ShowHallucination (30, levelInfo.Backdrop)
                            sfx:Stop(SoundEffect.SOUND_DEATH_CARD);
                            sfx:Play(THI.Sounds.SOUND_TOUHOU_SPELL_CARD)
                        elseif (tempData.FightTimer == 120) then
                            for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
                                if (levelInfo.SubTypes[ent.SubType] and ent:ToNPC().State == Note.States.DORMANT) then
                                    Note:ActivateNote(ent:ToNPC());
                                end
                            end
                        end

                        --如果在播放图书馆BGM，则改为播放BOSS音乐。
                        if (music:GetCurrentMusicID() == Music.MUSIC_LIBRARY_ROOM) then
                            music:Play(THI.Music.REVERIE, 0);
                            music:UpdateVolume();
                        end

                    elseif(tempData.FightLevel >= #self.NoteLevels) then
                        if (tempData.FightTimer == 1) then --停下BGM。
                            music:Fadeout();
                        elseif (tempData.FightTimer > 90 and tempData.FightTimer < 90 + #self.NoteLevels * 30) then --生成星象房道具。
                            
                            for i = 0, #self.NoteLevels - 1 do
                                local time = 91 + i * 30
                                if (tempData.FightTimer == time) then
                                    local info = self.NoteLevels[i + 1];
                                    game:ShowHallucination (10, info.Backdrop);
                                    local itemPoolType = info.ItemPool;
                                    local itemPool = game:GetItemPool();
                                    local id = itemPool:GetCollectible(itemPoolType, true);
            
                                    local center = room:GetCenterPos() ;
                                    center = center + Vector(0, 120);
                                    local x, y = -1, -1;
                                    x = x + i * 2;
                                    y = y + math.ceil((x - 1) / 3);
                                    x = (x + 1) % 3 - 1
                                    local pos = room:FindFreePickupSpawnPosition(center + Vector(x * 40, y * 40));
                                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, nil);
                                end
                            end
                        elseif (tempData.FightTimer == 120 + #self.NoteLevels * 30) then
                            game:ShowHallucination (30, BackdropType.LIBRARY);
                            
                        elseif (tempData.FightTimer > 180 + #self.NoteLevels * 30) then
                            music:Play(Music.MUSIC_LIBRARY_ROOM, 1);
                            music:UpdateVolume();
                            room:TriggerClear();
                            
                            self:SpawnExitDoor();

                            local data = GetGlobalData(true);
                            data.FightOver = true;
                        end
                    end
                    tempData.FightTimer = (tempData.FightTimer or 0) + 1;
                end
            end

            
            if (music:GetCurrentMusicID() == THI.Music.REVERIE) then
                music:ResetPitch()
            end
        end
    end
end

local function UpdateBossBattle() BossFight:Update(); end
function StartReverieBossFight() BossFight:StartBossFight(); end
function Note:StartOpeningAnimation() BossFight:StartOpeningAnimation(); end
function Note:StartBossFight() BossFight:StartBossFight(); end
function Note:IsBossRoom() return BossFight:IsBossRoom(); end
function Note:IsBossFightStarted() return BossFight:IsBossFightStarted(); end

----
-- 公共函数
----

-- 设置一个音符的状态。
function Note:SetState(note, state)
    note.State = state;
    note.StateFrame = 0;
end

--激活一个音符。
function Note:ActivateNote(note)
    self:SetState(note, Note.States.ACTIVE);
end

-- 检测指定音符是否激活。
function Note:IsNoteActive(note)
    if (note.Type == Note.Type and note.Variant == Note.Variant) then
        local state  = note:ToNPC().State
        return state ~= Note.States.DORMANT and state ~= Note.States.APPEAR;
    end
    return false;
end

--使一个音符休眠。
function Note:DormantNote(note)
    self:SetState(note, Note.States.DORMANT);
    note.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
end

local ActiveNotecount = 0;
-- 获取当前激活的音符数量。
function Note:GetActiveNoteCount()
    return ActiveNotecount;
end

----
-- 事件
----

--音符在创建后读取Sprite。
local function PostNoteInit(mod, note)
    if (note.Variant == Note.Variant) then
        note.SplatColor = Consts.Colors.Clear;

        note.TargetPosition = note.Position;
    end
end
Note:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostNoteInit, Note.Type)
--音符行动。
local function PostNoteUpdate(mod, note)
    if (note.Variant == Note.Variant) then
        -- 运行AI。
        local ai = Note.AIList[note.SubType];
        if (ai) then
            ai(note);
            note:MultiplyFriction(0.9);
        end 

        if (note.State == Note.States.APPEAR) then --出现。
            note:GetSprite():Play("Idle");
            note:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP);
            note.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
            note.DepthOffset = -200;
            local scale = note.Scale;
            note.Scale = (scale - 1) * 0.8 + 1;
        elseif (note.State == Note.States.DORMANT) then-- 休眠。
            if (note.StateFrame == 1) then
                note:GetSprite():Play("Dormant");
                note:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP);
            end

            MoveToTarget(note, 0.3);
            note.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
            note.SpriteOffset = Vector(note.SpriteOffset.X, -80 + (-80 - note.SpriteOffset.Y) * 0.9);
        else -- 活动。
            if (note.StateFrame == 1) then
                note.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
                note:ClearEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP);
            end
            note.SpriteOffset = Vector(note.SpriteOffset.X, note.SpriteOffset.Y * 0.8);
        end
    end
end
Note:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNoteUpdate, Note.Type)

local function PostUpdate(mod)
    -- 更新当前激活的音符数量。
    ActiveNotecount = 0;
    for _, ent in ipairs(Isaac.FindByType(Note.Type, Note.Variant)) do
        if (Note:IsNoteActive(ent)) then
            ActiveNotecount = ActiveNotecount + 1;
        end
    end

    UpdateBossBattle();

    local room = Game():GetRoom();
    if (room:GetFrameCount() == 1 and Note:IsBossRoom()) then
        if (not BossFight:IsBossFightOver() and BossFight:IsBossFightStarted()) then
            BossFight:StartBossFight();
        end
    end
end
Note:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)


local function PostNewRoom(mod)
    -- 清除战斗内容。
    local tempData = GetTempGlobalData(false);
    local evaluateRange = false;
    if (tempData) then
        ClearTempGlobalData();
        evaluateRange = true;
    end
    if (Note:IsBossRoom()) then
        evaluateRange = true;

        if (BossFight:IsBossFightOver()) then
            BossFight:SpawnExitDoor()
        elseif(not BossFight:IsBossFightStarted()) then
            local room = Game():GetRoom();
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
            local Box = THI.Pickups.ReverieMusicBox;
            Isaac.Spawn(Box.Type, Box.Variant, Box.SubType, pos, Vector.Zero, nil);
        end
    end

    if (evaluateRange) then
        for p, player in Detection.PlayerPairs() do
            player:AddCacheFlags(CacheFlag.CACHE_RANGE);
            player:EvaluateItems();
        end
    end
end
Note:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

local function PreTakeDamage(mod, ent, amount, flags, source, countdown)
    if (ent.Type == Note.Type and ent.Variant == Note.Variant) then
        if (not Note:IsNoteActive(ent)) then
            return false;
        end
    end
end
Note:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage, Note.Type)

local function PostEntityKill(mod, ent)
    if (ent.Type == Note.Type and ent.Variant == Note.Variant) then
        SpawnExplosionWaves(ent);

        Game():ShakeScreen(10);
        local sfx = SFXManager();
        sfx:Play(THI.Sounds.SOUND_TOUHOU_DESTROY, 0.35);
    end
end
Note:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill)
Note:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, PostEntityKill)


local function PostLaserUpdate(mod, laser)
    if (laser.FrameCount == 2 and IsLaserThin(laser)) then
        laser.SpriteScale = Vector(0.5,1);
        laser.Size = laser.Size / 2;
        laser.ParentOffset = Vector.Zero;
        local returnPos = GetLaserReturnPosition(laser);
        if (returnPos) then
            laser.Position = returnPos;
            ClearLaserReturnPosition(laser);
        elseif (laser.Parent) then
            laser.Position = laser.Parent.Position;
        end

    end
    
    local maxDistance = GetLaserMaxDistance(laser);
    local currentDistance = laser.MaxDistance;
    if (maxDistance and currentDistance < maxDistance) then
        local vec = Vector.FromAngle(laser.Angle);
        local added = vec:Dot(laser.Velocity);
        added = math.min(added, maxDistance - currentDistance);
        laser:SetMaxDistance(currentDistance + added);
        laser.Position = laser.Position - vec * added;
    end
end
Note:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, PostLaserUpdate)

local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_RANGE) then
        if (Note:IsBossFightStarted() and Note:IsBossRoom()) then
            if (not player:HasWeaponType ( WeaponType.WEAPON_BONE)) then
                player.TearRange = math.max(player.TearRange, 800);
            end
        end
    end
end
Note:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Variant == Note.Variant) then
        if ((source.Type == Note.Type and source.Variant == Note.Variant) or
        (source.SpawnerType == Note.Type and source.SpawnerVariant == Note.Variant)) then
            return false;
        end
    end
end
Note:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage, Note.Type)

return Note;