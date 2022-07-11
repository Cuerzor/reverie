local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Bosses = CuerLib.Bosses;
local Grids = CuerLib.Grids;
local Kogasa = ModEntity("The Abandoned", "KOGASA_ABANDONED");

Kogasa.Variants = {
    KOGASA = Isaac.GetEntityVariantByName("The Abandoned"),
    WATERBALL = Isaac.GetEntityVariantByName("Abandoned Water Ball"),
}
Kogasa.States = {
    IDLE = 0,
    FLING1 = 1,
    FLING2 = 2,
    WATER_BALL = 3,
    WATER_GUN_DOWN = 11,
    WATER_GUN_UP = 12,
    WATER_GUN_RIGHT = 13,
    WATER_GUN_LEFT = 14,
    CHARGE_PREPARE = 21,
    CHARGE_DOWN = 22,
    CHARGE_UP = 23,
    CHARGE_DROP = 24,
}

do
    local TearParams = ProjectileParams();
    TearParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
    Kogasa.TearParams = TearParams;

    
    local DropParams = ProjectileParams();
    DropParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
    DropParams.BulletFlags = ProjectileFlags.ACCELERATE_EX;
    DropParams.HeightModifier = -10;
    DropParams.FallingAccelModifier = -0.1;
    DropParams.Acceleration = 0.8;
    Kogasa.DropParams = DropParams;
end
-- BooText.

local BooText = ModEntity("Abandoned Boo Text", "BOO");
do

    local function PostBooTextInit(mod, text)
        local spr = text:GetSprite();
        spr:ReplaceSpritesheet(0, "gfx/reverie/effects/kogasa_boo_"..Options.Language..".png");
        spr:LoadGraphics();
        text:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_NO_REMOVE_ON_TEX_RENDER);
    end
    Kogasa:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostBooTextInit, BooText.Variant);


    local function PostBooTextUpdate(mod, text)
        local spr = text:GetSprite();
        if (spr:IsFinished("Idle")) then
            text:Remove();
        end
    end
    Kogasa:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostBooTextUpdate, BooText.Variant);
end


-- Add Boss Room.
do
    local n = Grids.RoomGrids.Null;
    local p = Grids.RoomGrids.Pits;
    local roomConfigs = {
        ID = "reverie:the_abandoned",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/the_abandoned",
        CustomRooms = {

            TheAbandoned1 = {
                ReplaceChance = 8,
                BossID = "reverie:the_abandoned",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_2}
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
                    {Type = Kogasa.Type, Variant = Kogasa.Variant, SubType = Kogasa.SubType, Position = Vector(320, 280)},
                }
            },
            TheAbandoned2 = {
                ReplaceChance = 8,
                BossID = "reverie:the_abandoned",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                Grids = {
                    {n, p, p, p, n, n, n, n, n, p, p, p, n},
                    {n, n, p, n, n, n, n, n, n, n, p, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, p, n, n, n, n, n, n, n, p, n, n},
                    {n, p, p, p, n, n, n, n, n, p, p, p, n},
                },
                Bosses = {
                    {Type = Kogasa.Type, Variant = Kogasa.Variant, SubType = Kogasa.SubType,  Position = Vector(320, 280)},
                }
            },
            TheAbandoned3 = {
                ReplaceChance = 8,
                BossID = "reverie:the_abandoned",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                Grids = {
                    {p, p, p, p, p, p, n, p, p, p, p, p, p},
                    {p, p, p, p, n, n, n, n, n, p, p, p, p},
                    {p, p, n, n, n, n, n, n, n, n, n, p, p},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                },
                Bosses = {
                    {Type = Kogasa.Type, Variant = Kogasa.Variant, SubType = Kogasa.SubType, Position = Vector(320, 280)},
                }
            }
        }
    }
    local bossConfig = {
        Name = "The Abandoned",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_1, Weight = 1},
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE1_2, Weight = 1}
            }
        },
        Type = Kogasa.Type,
        Variant = Kogasa.Variant,
        PortraitPath = "gfx/reverie/ui/boss/portrait_581.0_the abandoned.png",
        PortraitOffset = Vector(0, 0),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_581.0_the abandoned.png",
            zh = "gfx/reverie/ui/boss/bossname_581.0_the abandoned_zh.png",
            jp = "gfx/reverie/ui/boss/bossname_581.0_the abandoned_jp.png"
        }
    }
    Bosses:SetBossConfig("reverie:the_abandoned", bossConfig, roomConfigs);
end


local RoomBorder = 40;
local RenderLayers = {
    3,4,0,1,2
}
local ClearColor = Color(1,1,1,0,0,0,0);

function Kogasa.GetKogasaData(kogasa, init)
    local function getter()
        return {
            StateTime = 0,
            GhostAlpha = 0,
            NextState = 1,
            SpawningWaterBall = nil,
            WaterGunUsed = true,
            ChargeUsed = false,
            LastIsCharge = false
        }
    end
    return Kogasa:GetData(kogasa, init, getter)
end
local function PostAbandonedInit(mod, abandoned)
    if (abandoned.Variant == Kogasa.Variants.WATERBALL) then
        local color = Color(0, 0, 0, 1, 0.6, 0.6, 1);
        abandoned.SplatColor = color;
    else
        local color = Color(0, 0, 0, 1, 0.6, 0.6, 1);
        abandoned.SplatColor = color;
    end
end
Kogasa:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostAbandonedInit, Kogasa.Type);

local function PostKogasaUpdate(mod, kogasa)
    local spr = kogasa:GetSprite();
    local simSpeed = 1;
    if (kogasa:HasEntityFlags(EntityFlag.FLAG_SLOW)) then
        simSpeed = 0.5;
    end
    local room = Game():GetRoom();
    local roomWidth = room:GetGridWidth() * 40;
    local roomHeight = room:GetGridHeight() * 40;

    if (spr:IsFinished("Appear")) then
        spr:Play("Idle");
    end

    
    local data = Kogasa.GetKogasaData(kogasa, true);
    if (data.GhostAlpha > 0) then
        data.GhostAlpha = data.GhostAlpha - 0.08;
    end

    local pathfinder = kogasa.Pathfinder;
    local i1 = kogasa.I1;

    local function RunStateTime() data.StateTime = (data.StateTime or 0) + simSpeed; end

    local function SetState(state)
        kogasa.I2 = 0;
        if (state == Kogasa.States.IDLE) then
            spr:Play("Idle");
        elseif (state == Kogasa.States.FLING1 or state == Kogasa.States.FLING2) then
            spr:Play("Fling", true);
            kogasa.I2 = Random() % 2;
        elseif (state == Kogasa.States.WATER_BALL) then
            spr:Play("WaterBallSpawn");
        elseif (state == Kogasa.States.CHARGE_DOWN) then
            kogasa.Position = Vector(roomWidth / 4, -RoomBorder);
        elseif (state == Kogasa.States.CHARGE_UP) then
            kogasa.Position = Vector(roomWidth * 3 / 4, roomHeight + 120 + RoomBorder);
        elseif (state == Kogasa.States.CHARGE_DROP) then
            kogasa.Position = room:GetCenterPos();
            spr:Play("ChargeDrop");
            kogasa.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
        end
        kogasa.I1 = state;
        data.StateTime = 0;
    end

    local function GetNextState()
        
        local target = kogasa:GetPlayerTarget();
        local targetPos = target.Position;
        local kogasaPos = kogasa.Position;
        if (kogasa.HitPoints <= kogasa.MaxHitPoints / 2 and not data.LastIsCharge) then
            if (not data.ChargeUsed or Random() % 4 == 0) then
                return Kogasa.States.CHARGE_PREPARE;
            end
        end

        if (not data.WaterGunUsed) then
            if (math.abs(targetPos.X - kogasaPos.X) <= 20) then
                if (targetPos.Y > kogasaPos.Y) then
                    return Kogasa.States.WATER_GUN_DOWN;
                else
                    return Kogasa.States.WATER_GUN_UP;
                end
            elseif (math.abs(targetPos.Y - kogasaPos.Y) <= 20) then
                if (targetPos.X > kogasaPos.X) then
                    return Kogasa.States.WATER_GUN_RIGHT;
                    
                else
                    return Kogasa.States.WATER_GUN_LEFT;
                end
            end
        end

        local state = Kogasa.States.FLING1;
        local nextState = data.NextState or 1;
        if (nextState == 2) then
            state = Kogasa.States.WATER_BALL;
        end
        
        if (state == Kogasa.States.FLING2) then
            state = Kogasa.States.FLING1;
        elseif (state == Kogasa.States.WATER_BALL) then
            if (#Isaac.FindByType(Kogasa.Type, Kogasa.Variants.WATERBALL) >= 3) then
                data.NextState = Kogasa.States.FLING1;
                state = Kogasa.States.FLING1;
            end
        end
        data.NextState = Random() % 2 + 1;
        return state;
    end

    local function NextState()
        local state = GetNextState();
        
        data.WaterGunUsed = state >= Kogasa.States.WATER_GUN_DOWN and state <= Kogasa.States.WATER_GUN_LEFT;
        data.LastIsCharge = state >= Kogasa.States.CHARGE_PREPARE and state <= Kogasa.States.CHARGE_DROP;
        if (data.LastIsCharge) then
            data.ChargeUsed = true;
        end
        SetState(state);
    end

    local function Charge(up)
            
        local umbrellaOffset;
        local accel;
        if (up) then
            spr:Play("ChargeUp");
            umbrellaOffset = Vector(0, -64);
            accel = Vector(0, -20);
        else
            spr:Play("ChargeDown");
            umbrellaOffset = Vector(0, 64);
            accel = Vector(0, 20);
        end
        local umbrellaPos = kogasa.Position + umbrellaOffset
        local center = room:GetCenterPos();
        if (kogasa.Velocity:Length() < 20) then
            kogasa:AddVelocity(accel);
            kogasa.Velocity = kogasa.Velocity:Resized(20);
        end

        if (room:IsPositionInRoom(umbrellaPos, 0)) then
            if (kogasa:IsFrame(2, 0)) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, umbrellaPos,Vector.Zero, kogasa);
                THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION);
            end
            if (kogasa:IsFrame(4, 0)) then
                THI.SFXManager:Play(SoundEffect.SOUND_TEARS_FIRE);
                for side = 0, 1 do
                    for i = 1, 3 do
                        local dir;
                        if (side == 0) then
                            dir = Vector(-1, 0);
                        else
                            dir = Vector(1, 0);
                        end
                        local vel = dir * (i * 1 + 5);
                        kogasa:FireProjectiles(umbrellaPos, vel, 0, Kogasa.TearParams);
                        --local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, umbrellaPos, vel, kogasa):ToProjectile();
                    end
                end
            end
        end
    end


    if (i1 == Kogasa.States.IDLE) then
        -- Idle.
        local target = kogasa:GetPlayerTarget();
        kogasa.Target = target;
        if (kogasa.Target) then
            kogasa:AddVelocity((kogasa.Target.Position - kogasa.Position):Normalized() * 0.5);
        end

        if( not room:IsPositionInRoom(kogasa.Position, 40)) then
            kogasa:AddVelocity((kogasa.Target.Position - kogasa.Position):Normalized() * 2);
        end

        if (data.StateTime > 45) then
            NextState();
        else
            RunStateTime();
        end
    elseif (i1 == Kogasa.States.FLING1 or i1 == Kogasa.States.FLING2) then
        -- Fling.

        local frame = data.StateTime;
        RunStateTime();
        if (frame % 2 == kogasa.I2) then
            local percent = frame / 24;
            local angle = -120 + percent * -400;
            local dir = Vector.FromAngle(angle);
            local pos = kogasa.Position + dir * 24;
            THI.SFXManager:Play(SoundEffect.SOUND_TEARS_FIRE);
            for i = 1, 3 do
                local vel = dir * (0.5 * i + 6);
                
                kogasa:FireProjectiles(pos, vel, 0, Kogasa.TearParams);
                --Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, 0, pos, vel, kogasa);
            end
        end

        if (spr:IsFinished("Fling")) then
            local state = kogasa.I1 + 1;
            if (state > 2) then
                state = 0;
            end
            data.StateTime = 0;
            SetState(state);
        end
    elseif (i1 == Kogasa.States.WATER_BALL) then
        -- WaterBall.
        RunStateTime();
        if (not data.SpawningWaterBall) then
            local waterball = Isaac.Spawn(Kogasa.Type, Kogasa.Variants.WATERBALL, 0, kogasa.Position, Vector.Zero, kogasa);
            waterball.Parent = kogasa;
            waterball.PositionOffset = Vector(0, -128);
            waterball:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
            waterball.Size = 0;
            waterball.SpriteScale = Vector.Zero;
            waterball:GetSprite():Play("Spawn")
            data.SpawningWaterBall = waterball;
        elseif (data.SpawningWaterBall:Exists()) then
            local waterball = data.SpawningWaterBall;
            local size = math.min(1, data.StateTime / 30);
            if (data.StateTime < 8) then
                THI.SFXManager:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
            end
            waterball.Size = size * 13;
            if (spr:IsPlaying("WaterBallThrow")) then
                
                local frame = spr:GetFrame();
                if (frame > 6 and frame< 10) then
                    waterball.PositionOffset = Vector(0, 96 * (frame - 6) / 4 - 128);
                elseif (frame == 10) then
                    waterball.Velocity = Vector(0, 10);
                    waterball.PositionOffset = Vector(0, -32);
                    waterball.Parent = nil;
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, waterball.Position, Vector.Zero, kogasa);

                    THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION);
                end
            end
        end
        if (spr:IsFinished("WaterBallSpawn")) then
            spr:Play("WaterBallThrow");
        end
        
        if (spr:IsFinished("WaterBallThrow")) then
            SetState(0);
            data.SpawningWaterBall = nil;
        end
    elseif (i1 >= Kogasa.States.WATER_GUN_DOWN and i1 <= Kogasa.States.WATER_GUN_LEFT) then
        -- Water Gun.
        local anim;
        local dirString = "Down";
        local dir = Vector(0,1);
        local angle = 90;
        if (i1 == 12) then
            dirString = "Up";
            dir = Vector(0, -1);
            angle = -90;
        elseif (i1 == 13) then
            dirString = "Right";
            dir = Vector(1, 0);
            angle = 0;
        elseif (i1 == 14) then
            dirString = "Left";
            dir = Vector(-1, 0);
            angle = 180;
        end

        if (kogasa.I2 == 0) then
            anim = "WaterGun"..dirString;
            spr:Play(anim);
            RunStateTime();
            if (data.StateTime > 30) then
                kogasa.I2 = 1;
                data.StateTime = 0;
                local offset = Vector(0, -40);
                local posOffset = Vector(dir.X, dir.Y / 3);
                local laser = EntityLaser.ShootAngle (3, kogasa.Position + posOffset * 64, angle, 30, offset, kogasa);
                laser.Parent = kogasa;
                laser.Size = 8;
                laser.SpriteScale = Vector(0.5, 1);
                local endPoint = EntityLaser.CalculateEndPoint(laser.Position, dir, offset, kogasa, 20);
                
                THI.SFXManager:Play(SoundEffect.SOUND_TEARS_FIRE);
                for i = 1, 16 do
                    
                    local proj=kogasa:FireBossProjectiles(1, kogasa.Position - dir * 280, 0, Kogasa.TearParams);
                    proj.Position = endPoint;
                end
                kogasa:AddVelocity(-dir * 20);
            end
        elseif (kogasa.I2 == 1) then
            RunStateTime();
            if (data.StateTime > 30) then
                kogasa.I2 = 2;
                data.StateTime = 0;
            end
        elseif (kogasa.I2 == 2) then
            anim = "WaterGunEnd"..dirString;
            spr:Play(anim);

            if (spr:IsFinished(anim)) then
                SetState(0);
            end
        end
    elseif (i1 == Kogasa.States.CHARGE_PREPARE) then
        -- Charge Prepare.
        local center = Game():GetRoom():GetCenterPos();
        if (kogasa.Velocity:Length() < 20) then
            kogasa:AddVelocity(Vector((center.X - kogasa.Position.X) / 4, -100):Normalized() * 3);
            kogasa.Velocity = kogasa.Velocity:Resized(math.min(kogasa.Velocity:Length(), 12));
        end
        
        if (kogasa.Position.Y <= -RoomBorder) then
            SetState(Kogasa.States.CHARGE_DOWN);
        end
    elseif (i1 == Kogasa.States.CHARGE_DOWN) then
        -- Charge Down.
        RunStateTime();
        Charge(false);
        if (kogasa.Position.Y >= roomHeight + RoomBorder and data.StateTime > 45) then
            SetState(Kogasa.States.CHARGE_UP);
        end
    elseif (i1 == Kogasa.States.CHARGE_UP) then
        -- Charge Up.
        RunStateTime();
        Charge(true);
        if (kogasa.Position.Y <= -RoomBorder and data.StateTime > 45) then
            SetState(Kogasa.States.CHARGE_DROP);
        end
        
    elseif (i1 == Kogasa.States.CHARGE_DROP) then
        -- Charge Drop.
        RunStateTime();
        spr:Play("ChargeDrop");
        kogasa.Velocity = Vector.Zero;
        if (spr:IsEventTriggered("Drop")) then
            kogasa.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            Game():ShakeScreen(15);

            THI.SFXManager:Play(SoundEffect.SOUND_MOTHER_LAND_SMASH);
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, kogasa.Position,Vector.Zero, kogasa);
            THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION);
            
            THI.SFXManager:Play(SoundEffect.SOUND_TEARS_FIRE);
            for i = 1, 32 do
                local dir = RandomVector();
                local vel = dir * (Random() % 1000 + 1000) / 100;

                kogasa:FireProjectiles(kogasa.Position, vel, 0, Kogasa.DropParams);

                
            end
        end
        
        if (spr:IsFinished("ChargeDrop")) then
            SetState(Kogasa.States.IDLE);
        end
    end
    kogasa:MultiplyFriction(0.8);
end 

local function PostWaterBallUpdate(mod, waterball)
    local parent = waterball.Parent;
    local spr = waterball:GetSprite()
    if (not spr:IsPlaying("Spawn") or spr:IsFinished("Spawn")) then
        spr:Play("Idle");
    end
    if (parent and parent:Exists()) then
        if (parent:IsDead()) then
            waterball:Die();
        else
            waterball.Velocity = parent.Position - waterball.Position;
        end
    else
        waterball.Target = waterball:GetPlayerTarget();
        if (waterball.Target) then
            local targetPos = waterball.Target.Position;
            local angleDiff = Math.GetIncludedAngle( waterball.Velocity, targetPos - waterball.Position);
            local angle = waterball.Velocity:GetAngleDegrees() + angleDiff * 0.5;
            waterball:AddVelocity(Vector.FromAngle(angle) * 1);
            waterball:MultiplyFriction(0.8);
        end
    end
end

local function PostAbandonedUpdate(mod, abandoned)
    if (abandoned.Variant == Kogasa.Variants.KOGASA) then
        PostKogasaUpdate(mod, abandoned);
    elseif (abandoned.Variant == Kogasa.Variants.WATERBALL) then
        PostWaterBallUpdate(mod, abandoned);
    end
end
Kogasa:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostAbandonedUpdate, Kogasa.Type);


local function PostAbandonedKill(mod, abandoned)
    if (abandoned.Variant == Kogasa.Variants.KOGASA) then
        --local pos = abandoned.Position;
        local room = Game():GetRoom();
        local gridIndex = 3;
        local pos = room:GetGridPosition(gridIndex);
        --local roomWidth = room:GetGridWidth () * 40;
        --local roomHeight = room:GetGridHeight () * 40;
        --pos = Vector(math.max(0, math.min(pos.X + 200, roomWidth)), math.max(0, math.min(pos.Y - 120, roomHeight)));
        Isaac.Spawn(BooText.Type, BooText.Variant, 0, pos, Vector.Zero, abandoned);
    elseif (abandoned.Variant == Kogasa.Variants.WATERBALL) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, abandoned.Position,Vector.Zero, abandoned);
        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION);
        
        THI.SFXManager:Play(SoundEffect.SOUND_TEARS_FIRE);
        for i = 1, 16 do
            local dir = RandomVector();
            local vel = dir * (Random() % 500 + 500) / 100;


            local npc = abandoned:ToNPC();
            if (npc) then
                npc:FireProjectiles(abandoned.Position, vel, 0, Kogasa.DropParams);
            end
        end
    end
end
Kogasa:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostAbandonedKill, Kogasa.Type);

local function PostKogasaRender(mod, kogasa, offset)
    if (kogasa.Variant == Kogasa.Variants.KOGASA) then
        local spr = kogasa:GetSprite();
        local room = Game():GetRoom();
        if (kogasa.Visible) then
            local oriColor = kogasa:GetColor();
            local col = oriColor;
            col = Color(col.R,col.G,col.B, 1, col.RO,col.GO,col.BO);
            local data = Kogasa.GetKogasaData(kogasa, false);
            
            local pos = Screen.GetEntityOffsetedRenderPosition(kogasa, offset);
            if (spr:IsPlaying("Death")) then
                local frame = spr:GetFrame() - 32;
                local player = Isaac.GetPlayer(0);
                if (player and player:HasEntityFlags(EntityFlag.FLAG_INTERPOLATION_UPDATE)) then
                    frame = frame + 0.5;
                end
                if (frame > 0) then
                    pos = pos + Vector(frame * 10, -(frame / 2) ^ 2);
                end
            end
            for i, layer in pairs(RenderLayers) do
                if (layer == 0) then
                    local alpha = (data and data.GhostAlpha) or 0;
                    if (room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT) then
                        alpha = 0;
                    end
                    spr.Color = Color(1,1,1, alpha, 1,1,1);
                else
                    spr.Color = col;
                end
                spr:RenderLayer(layer, pos, Vector.Zero, Vector.Zero);
                spr.Color = col;
            end

            
            col = Color(col.R,col.G,col.B, 0, col.RO,col.GO,col.BO);
            spr.Color = col;
        end

    end
end
Kogasa:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, PostKogasaRender, Kogasa.Type);

local function PostKogasaDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Variant == Kogasa.Variants.KOGASA) then
        local data = Kogasa.GetKogasaData(tookDamage, true);
        data.GhostAlpha = 1;
    end
end
Kogasa:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostKogasaDamage, Kogasa.Type);




return Kogasa;