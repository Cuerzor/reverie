local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local Bosses = CuerLib.Bosses;
local Revive = CuerLib.Revive;
local Grids = CuerLib.Grids;
local Players = CuerLib.Players;


local Devilcrow = ModEntity("Devilcrow", "DEVILCROW");


local GatlingParams = ProjectileParams();
GatlingParams.Color = Color(1,0.5,0,1,0.5,0.25,0);
GatlingParams.Variant = ProjectileVariant.PROJECTILE_ROCK;
GatlingParams.Scale = 0.01;

Devilcrow.Variants = {
    DEVILCROW = Isaac.GetEntityVariantByName("Devilcrow"),
    WASTE_BUCKET = Isaac.GetEntityVariantByName("Devilcrow Waste Bucket")
}

local BodyPositions = {
    Vector(0, -87),
    Vector(2, -86),
    Vector(3, -85),
    Vector(2, -84),
    Vector(0, -83),
    Vector(-2, -84),
    Vector(-3, -85),
    Vector(-2, -86),
    Vector(0, -87),
}
local LeftGatlingOffset = Vector(-28, 8);
local RightGatlingOffset = Vector(28, 8);
local NeckOffset = Vector(0, 19);
local RootOffset = Vector(0, 32);
local GreenColor = Color(1,1,1,1,0,0,0);
GreenColor:SetColorize(0,1,0,1);
local maxRadiation = 150;
local RadiationSprite = Sprite();
RadiationSprite:Load("gfx/reverie/ui/radiation_warning.anm2", true);
RadiationSprite:Play("Idle");
RadiationSprite.Scale = Vector.One * 0.5;

local IdleFrames = {
    -- Feet = {
    --     {Duration = 1,Position = Vector(0, 0)}
    -- },
    -- LeftLeg = {
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = 0},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = 5},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = 6},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = 5},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = 0},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = -5},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = -6},
    --     {Duration = 4, Position = Vector(-32, -6), Rotation = -5},
    --     {Duration = 1, Position = Vector(-32, -6), Rotation = 0}
    -- },
    -- RightLeg = {
    --     {Duration = 4, Position = Vector(32, -6), Rotation = 0},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = -5},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = -6},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = -5},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = 0},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = 5},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = 6},
    --     {Duration = 4, Position = Vector(32, -6), Rotation = 5},
    --     {Duration = 1, Position = Vector(32, -6), Rotation = 0}
    -- },
    -- Body = {
    --     {Duration = 4, Position = BodyPositions[1]},
    --     {Duration = 4, Position = BodyPositions[2]},
    --     {Duration = 4, Position = BodyPositions[3]},
    --     {Duration = 4, Position = BodyPositions[4]},
    --     {Duration = 4, Position = BodyPositions[5]},
    --     {Duration = 4, Position = BodyPositions[6]},
    --     {Duration = 4, Position = BodyPositions[7]},
    --     {Duration = 4, Position = BodyPositions[8]},
    --     {Duration = 1, Position = BodyPositions[9]}
    -- },
    LeftGatling = {
        {Duration = 4, Position = BodyPositions[1] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[2] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[3] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[4] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[5] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[6] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[7] + LeftGatlingOffset},
        {Duration = 4, Position = BodyPositions[8] + LeftGatlingOffset},
        {Duration = 1, Position = BodyPositions[9] + LeftGatlingOffset}
    },
    RightGatling = {
        {Duration = 4, Position = BodyPositions[1] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[2] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[3] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[4] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[5] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[6] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[7] + RightGatlingOffset},
        {Duration = 4, Position = BodyPositions[8] + RightGatlingOffset},
        {Duration = 1, Position = BodyPositions[9] + RightGatlingOffset}
    },
    -- Neck = {
    --     {Duration = 4, Position = BodyPositions[1] + NeckOffset, Rotation = 0},
    --     {Duration = 4, Position = BodyPositions[2] + NeckOffset, Rotation = -6},
    --     {Duration = 4, Position = BodyPositions[3] + NeckOffset, Rotation = -8},
    --     {Duration = 4, Position = BodyPositions[4] + NeckOffset, Rotation = -6},
    --     {Duration = 4, Position = BodyPositions[5] + NeckOffset, Rotation = 0},
    --     {Duration = 4, Position = BodyPositions[6] + NeckOffset, Rotation = 6},
    --     {Duration = 4, Position = BodyPositions[7] + NeckOffset, Rotation = 8},
    --     {Duration = 4, Position = BodyPositions[8] + NeckOffset, Rotation = 6},
    --     {Duration = 1, Position = BodyPositions[9] + NeckOffset, Rotation = 0}
    -- },
    Head = {
        {Duration = 4, Position = Vector(0, -100)},
        {Duration = 4, Position = Vector(-1, -101.5)},
        {Duration = 4, Position = Vector(-2, -102.8)},
        {Duration = 4, Position = Vector(-1, -103.8)},
        {Duration = 4, Position = Vector(0, -104)},
        {Duration = 4, Position = Vector(1, -103.8)},
        {Duration = 4, Position = Vector(2, -102.8)},
        {Duration = 4, Position = Vector(1, -101.5)},
        {Duration = 1, Position = Vector(0, -100)},
    }
}

-- Add Boss Room.
do
    local r = Grids.RoomGrids.Rock;
    local t = Grids.RoomGrids.TallBlock;
    local n = Grids.RoomGrids.Null;
    local roomConfigs = {
        ID = "reverie:devilcrow",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/devilcrow",
        CustomRooms = {
            {
                Name = "Devilcrow1",
                ReplaceChance = 33,
                BossID = "reverie:devilcrow",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE3_1}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                VanishingTwinTarget = Vector(320, 220),
                Grids = {
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, n, n, n, n, n, r, r, r, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {t, n, n, n, n, n, n, n, n, n, n, n, t},
                    {n, t, n, n, n, n, n, n, n, n, n, t, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                },
                Bosses = {
                    {Type = Devilcrow.Type, Variant = Devilcrow.Variant, SubType = Devilcrow.SubType, Position = Vector(320, 220)}
                }
            }
        }
    }
    local bossConfig = {
        Name = "Devilcrow",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE3_1, Weight = 1}
            }
        },
        Type = Devilcrow.Type,
        Variant = Devilcrow.Variant,
        VanishingTwinFunc = function(self, boss)
            local devilcrows = Isaac.FindByType(self.Type, self.Variant);
            local y = 220;
            for i, ent in ipairs(devilcrows) do
                local startingX = 320 - 40 * (#devilcrows - 1);
                local x = startingX + 80 * (i - 1);
                local pos = Vector(x, y);
                ent.Position = pos;
                ent.TargetPosition = pos;
            end
        end,
        PortraitPath = "gfx/reverie/ui/boss/portrait_586.0_devilcrow.png",
        PortraitOffset = Vector(0, -20),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_586.0_devilcrow.png",
            zh = "gfx/reverie/ui/boss/bossname_586.0_devilcrow_zh.png",
            jp = "gfx/reverie/ui/boss/bossname_586.0_devilcrow_jp.png"
        },
        IsEnabled = function(self)
            return THI.IsBossEnabled(self.Name);
        end
    }
    Bosses:SetBossConfig("reverie:devilcrow", bossConfig, roomConfigs);
end

-- Rocket.
local Rocket = ModEntity("Devilcrow Rocket (Up)", "DEVIL_ROCKET");
do 
    function Rocket:PostRocketInit(rocket)

        local spr = rocket:GetSprite();
        if (rocket.SubType == 0) then
            spr:Play("Flying");
        elseif (rocket.SubType ==1) then
            spr:Play("Fall");
        end
    end
    Rocket:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Rocket.PostRocketInit, Rocket.Variant)

    
    function Rocket:PostRocketUpdate(rocket)
        -- Up.
        if (rocket.SubType == 0) then
            local timeout = rocket.Timeout;
            rocket.PositionOffset = Vector(0, (60 - timeout) * -100);
            if (timeout == 0) then
                rocket:Remove();
            end
        elseif (rocket.SubType ==1) then
            local timeout = rocket.Timeout;
            rocket.PositionOffset = Vector(0, timeout * -100);
            if (timeout == 0) then
                local game = Game();
                game:BombExplosionEffects  (rocket.Position, 100, TearFlags.TEAR_NORMAL, GreenColor, rocket.SpawnerEntity, 1.5, true, false, DamageFlag.DAMAGE_EXPLOSION)
                game:ShakeScreen(15);
                rocket:Remove();
            end
        end
        if (rocket.Parent) then
            rocket.Position = rocket.Parent.Position;
        end
    end
    Rocket:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Rocket.PostRocketUpdate, Rocket.Variant)
end

local function GetPart(devilcrow, name, anim, flipX)
    local origin = devilcrow:GetSprite();
    local spr = Sprite();
    spr:Load(origin:GetFilename(), true);
    spr:Play(anim);
    spr.FlipX = flipX;
    spr:Update();

    local part = {
        Name = name,
        Sprite = spr,
        Position = Vector.Zero
    }
    return part;
end
local function GetLightSprite()
    local spr = Sprite();
    spr:Load("gfx/spotlight.anm2", true);
    spr.Rotation = 0;
    spr:Play("Idle");
    return spr;
end

function Devilcrow.GetDevilcrowData(devilcrow, init)
    local function getter()
        return {
            Parts = {
                -- GetPart(devilcrow, "Feet", "Feet"), GetPart(devilcrow, "LeftLeg", "Leg"),
                -- GetPart(devilcrow, "RightLeg", "Leg", true), GetPart(devilcrow, "Body", "Body"),
                GetPart(devilcrow, "LeftGatling", "Gatling"), GetPart(devilcrow, "RightGatling", "Gatling", true),
                --GetPart(devilcrow, "Neck", "Neck"), 
                GetPart(devilcrow, "Head", "Head")},
            HeadRotation = 0,
            EyeLaser = {
                Left = {
                    Timer = 130,
                    Target = Vector.Zero
                },
                Right = {
                    Timer = 100,
                    Target = Vector.Zero
                }
            },
            Gatlings = {
                Left = {
                    Frame = 0,
                    IsOpen = false,
                    Charge = 0,
                    Angle = 0;
                },
                Right = {
                    Frame = 0,
                    IsOpen = false,
                    Charge = 0,
                    Angle = 0;
                }
            },
            LightColor = Color(0.2, 1, 0, 0, 0.4, 0.5 ,0.2),
            LightSprite = GetLightSprite();
            Attacks = {
                Cycle = 0,
                Timer = 60,
                Rockets = {
                    RemainCount = 0,
                    Countdown = 0
                },
                Buckets = {
                    RemainCount = 0,
                    NextLeft = false,
                    Countdown = 0
                }
            }
        }
    end
    return Devilcrow:GetData(devilcrow, init, getter)
end
function Devilcrow.GetPlayerData(player, init)
    local function getter()
        return {
            NuclearRadiation = 0,
            Radiated = false,
            SignColorOffset = 0
        }
    end
    return Devilcrow:GetData(player, init, getter)
end
function Devilcrow:PostDevilcrowInit(devilcrow)
    if (devilcrow.Variant == Devilcrow.Variants.DEVILCROW) then
        devilcrow.TargetPosition = devilcrow.Position;
        devilcrow.SplatColor = Color(0,0,0,1,0,0,0);
    elseif (devilcrow.Variant == Devilcrow.Variants.WASTE_BUCKET) then
        devilcrow.SplatColor = GreenColor;
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Devilcrow.PostDevilcrowInit, Devilcrow.Type);

local function DevilcrowUpdate(devilcrow)
    local spr = devilcrow:GetSprite();
    if (devilcrow.FrameCount == 0) then
        THI.SFXManager:Play(THI.Sounds.SOUND_SCIFI_MECH);
    end

    if (spr:IsFinished("Appear")) then
        spr:Play("Idle");
    end
    local data = Devilcrow.GetDevilcrowData(devilcrow, true);

    devilcrow.Position = devilcrow.TargetPosition;

    -- Target Locking.
    devilcrow.Target = devilcrow:GetPlayerTarget ( );

    local target = devilcrow.Target;
    local targetDegrees = (target.Position - devilcrow.Position):GetAngleDegrees() % 360;

    -- Radiation Light.
    do
        local function isInRange(source, ent)
            local angleDegrees = 30;
            local maxLength = 360;
            local dir = Vector(0, 1);
            local entToPlayer = ent.Position  - (source.Position+ Vector(0, -40));
            if (entToPlayer:Length() > maxLength) then
                return false;
            end
            local entToPlayerNormalized = entToPlayer:Normalized();
        
            local dot = entToPlayerNormalized:Dot(dir);
            local angle = math.acos(dot) / math.pi * 180;
            return angle <= angleDegrees;
        end
        
        if (not devilcrow:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and spr:IsPlaying("Idle")) then
            data.LightColor.A = math.min(0.5, data.LightColor.A + 0.03);
            if (data.LightColor.A >= 0.49) then
                for p, player in Detection.PlayerPairs() do
                    local Rebecha = THI.Monsters.Rebecha;
                    local defended = Rebecha:GetPlayerMecha(player) ~= nil;
                    if (not player:IsCoopGhost ( ) and not Players:IsDead(player) and isInRange(devilcrow, player) and not defended) then
                        local playerData = Devilcrow.GetPlayerData(player, true);
                        playerData.Radiated = true;
                    end
                end
            end
        else
            data.LightColor.A = math.max(0, data.LightColor.A - 0.03);
        end
    end

    -- Watch Target Position.
    do
        local degrees = targetDegrees - 90;
        local sign = 1;
        local abs = math.abs(degrees);
        if (degrees < 0 or degrees > 180) then
            sign = -1;
        end
        if (abs > 45) then
            abs = 45;
        end
        local targetRotation = sign * (abs) ^ 0.5 * 3;
    
        data.HeadRotation = data.HeadRotation  * 2 / 3 + targetRotation / 3;
    end
    -- Shoot Eye Laser.
    do
        local function GetEyePos(left)
            local xOffset = -16;
            if (left) then
                xOffset = 16;
            end
            local offset = (Vector(0, -100) + Vector(xOffset, 0):Rotated(data.HeadRotation)) :Rotated(devilcrow.SpriteRotation);
            offset.X = offset.X * devilcrow.SpriteScale.X;
            offset.Y = offset.Y * devilcrow.SpriteScale.Y;
            local pos = devilcrow.Position + offset;
            return pos, -offset.Y + 10;
        end
        local function shootEyeLaser(left, targetPosition)
            local laserPos, depthOffset = GetEyePos(left);
            local angle = (targetPosition - laserPos):GetAngleDegrees();
            local laser = EntityLaser.ShootAngle(1, laserPos, angle, 20, Vector.Zero, devilcrow);
            THI.SFXManager:Play(THI.Sounds.SOUND_SCIFI_LASER);
            Game():ShakeScreen(15);
            laser.DepthOffset = depthOffset;
        end
        local function ChargeBrimstone(left)
            
            local Wave = THI.Effects.SpellCardWave;
            THI.SFXManager:Play(SoundEffect.SOUND_FRAIL_CHARGE);
            local wavePos, depthOffset = GetEyePos(left);
            local wave = Isaac.Spawn(Wave.Type,  Wave.Variant, Wave.SubTypes.SHRINK, wavePos, Vector.Zero, nil);
            wave:SetColor(Color(1,0,0,0.5,0,0,0), -1, 0);
            wave.DepthOffset = depthOffset;
        end
        local eyeLaserData = data.EyeLaser;

        for i = 0, 1 do
            local left = i == 0;
            local laserData = eyeLaserData.Right;
            if (left) then
                laserData = eyeLaserData.Left;
            end

            if (laserData.Timer > 0) then
                laserData.Timer = laserData.Timer - 1;
                if (laserData.Timer == 30) then
                    ChargeBrimstone(left);
                end
                if (laserData.Timer == 15) then
                    laserData.Target = target.Position;
                end
            else
                shootEyeLaser(left, laserData.Target);
                if (left) then
                    laserData.Timer = 450;
                else
                    laserData.Timer = 450;
                end
            end
        end
    end

    local attackData = data.Attacks;

    -- Attacks
    do 
        if (attackData.Timer > 0) then
            attackData.Timer = attackData.Timer - 1;
        else
            -- Switch State.
            local i1 = devilcrow.I1;
            if (i1 == 0) then
                -- Idle State End.
                if (attackData.Cycle == 0 or not attackData.Cycle) then
                    -- Start firing rockets.
                    i1 = 1;
                    attackData.Timer = 120;
                    attackData.Rockets.RemainCount = 3;
                    attackData.Cycle = 1;
                else
                    -- Start Rolling Buckets
                    i1 = 2;
                    attackData.Timer = 90;
                    attackData.Buckets.RemainCount = 6;
                    attackData.Cycle = 0;
                end
            elseif (i1 == 1 or i1 == 2) then
                -- Rocket State End.
                -- Ready for Gatlings.
                i1 = 10;
                attackData.Timer = 150;
            elseif (i1 == 10) then
                -- Gatling Preparation End.
                -- Return to Idle state.
                i1 = 0;
                attackData.Timer = 30;
            end
            devilcrow.I1 = i1;
        end

        local function fallRocket(position)
            local target = Isaac.Spawn(1000, EffectVariant.TARGET, 0, position, Vector.Zero, devilcrow):ToEffect();
            local rocketUp = Isaac.Spawn(1000, Rocket.Variant, 0, devilcrow.Position, Vector.Zero, devilcrow):ToEffect();
            local rocket = Isaac.Spawn(1000, Rocket.Variant, 1, position, Vector.Zero, devilcrow):ToEffect();
            local scale = Vector(2, 2);
            target.SpriteScale = scale;
            target:SetTimeout(70);

            rocket:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 1, 0, false, true);
            rocket.SpriteScale = scale;
            rocket.Parent = target;
            rocket:SetTimeout(70);

            rocketUp.SpriteScale = scale;
            rocketUp:SetTimeout(60);
            THI.SFXManager:Play(SoundEffect.SOUND_ROCKET_LAUNCH);
        end
        local function spawnBucket(left)
            local speed = Random() % 10000 / 1000 + 0;
            local dir = Vector(1, 0);
            if (left) then
                dir = Vector(-1, 0);
            end
            local vel = dir * speed;
            local bucket = Isaac.Spawn(Devilcrow.Type, Devilcrow.Variants.WASTE_BUCKET, 0, devilcrow.Position + dir * 70 + Vector(0, -10), vel, devilcrow);
            bucket:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
            THI.SFXManager:Play(SoundEffect.SOUND_BLOODBANK_SPAWN);
        end

        -- Run State.
        local i1 = devilcrow.I1;
        if (i1 == 1) then
            -- Rockets.
            local rockets = attackData.Rockets;
            if (rockets.Countdown > 0) then
                rockets.Countdown = rockets.Countdown - 1;
            else
                if (rockets.RemainCount > 0) then
                    fallRocket(target.Position);
                    rockets.RemainCount = rockets.RemainCount - 1;
                    rockets.Countdown = 20;
                end
            end
        elseif (i1 == 2) then
            -- Buckets.
            local buckets = attackData.Buckets;
            if (buckets.Countdown > 0) then
                buckets.Countdown = buckets.Countdown - 1;
            else
                if (buckets.RemainCount > 0) then
                    spawnBucket(buckets.NextLeft);
                    buckets.RemainCount = buckets.RemainCount - 1;
                    buckets.Countdown = (Random() % 1000) / 100 + 10;
                    buckets.NextLeft = not buckets.NextLeft;
                end
            end
        end
            
        -- Fire Gatlings.
        do
            local gatlingsData = data.Gatlings;
            local gatlingInterval = 300;
            
            local function GetGatlingPos(left)
                local xOffset = 72;
                if (left) then
                    xOffset = -72;
                end
                local offset = Vector(xOffset, -32) :Rotated(devilcrow.SpriteRotation);
                offset.X = offset.X * devilcrow.SpriteScale.X;
                offset.Y = offset.Y * devilcrow.SpriteScale.Y;
                local pos = devilcrow.Position + offset;
                return pos, -offset.Y + 10;
            end


            for i = 0, 1 do
            
                local left = i == 0;
                local gatlingData = nil;
                local isAtThisSide = false;
                if (left) then
                    gatlingData = gatlingsData.Left;
                    isAtThisSide = targetDegrees > 110 and targetDegrees < 270;
                else
                    gatlingData = gatlingsData.Right;
                    isAtThisSide = targetDegrees < 70 or targetDegrees > 270;
                end
                
                
                if (not gatlingData.IsOpen) then
                    -- Closed.
                    gatlingData.Frame = math.max(gatlingData.Frame - 1, 0);

                    if (isAtThisSide and devilcrow.I1 == 10) then
                        gatlingData.IsOpen = true;
                        devilcrow.I1 = 11;
                        THI.SFXManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN);
                        gatlingData.Charge = gatlingInterval;
                    end
                else
                    -- Open.
                    if (gatlingData.Charge > 0) then
                        -- Cost the charges..
                        if (not isAtThisSide) then
                            gatlingData.Charge = gatlingData.Charge - 5;
                        else
                            gatlingData.Charge = gatlingData.Charge - 1;
                        end
        
                        local pos, depthOffset = GetGatlingPos(left);
                        local degrees = (target.Position - pos):GetAngleDegrees() % 360;
        
                        -- Limit the degrees.
                        if (left) then
                            degrees = math.max(90, math.min(270, degrees));
                        else
                            if (degrees < 180) then
                                degrees = math.min(90, degrees);
                            else
                                degrees = math.max(270, degrees);
                            end
                        end
        
                        local sideAngle = gatlingData.Angle or 0;
                        
                        local sideDegrees = degrees - 90;
                        if (not left) then
                            sideDegrees = 90 - degrees;
                        end
                        sideDegrees = sideDegrees % 360;
                        sideAngle = sideAngle + (sideDegrees - sideAngle) / 3;

                        local currentAngle = sideAngle + 90;
                        if (not left) then
                            currentAngle = 90 - sideAngle; 
                        end
                        currentAngle = currentAngle % 360;
        
                        -- Shoot bullets.
                        if (gatlingData.Charge <= gatlingInterval - 30) then
                            if (gatlingData.Charge % 2 == 0) then
        
                                pos = pos + Vector(20, 0) :Rotated(currentAngle);
                                local vel = Vector.FromAngle(currentAngle) * 30;

                                GatlingParams.DepthOffset = depthOffset;
                                devilcrow:FireProjectiles (pos, vel, 0, GatlingParams)
                                GatlingParams.DepthOffset = 0;

                                -- local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_ROCK, 0, pos, vel, devilcrow):ToProjectile();
                                -- proj:SetColor(Color(1,0.5,0,1,0.5,0.25,0), -1, 0);
                                -- proj.DepthOffset = depthOffset;
                                -- proj.Scale = 0.01;


                                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, pos, Vector.Zero, devilcrow);
                                effect.SpriteRotation = currentAngle + 90;
                                effect.SpriteScale = Vector(0.3, 0.3);
                                effect.DepthOffset = depthOffset
                                THI.SFXManager:Play(SoundEffect.SOUND_BULLET_SHOT, 1, 0, false, 1.5, 0);
                            end
                        end
        
                        
                        -- Set Sprite Frame.
                        if (gatlingData.Charge > gatlingInterval - 4) then
                            local diff = gatlingInterval - gatlingData.Charge;
                            gatlingData.Frame = math.min(diff, 4);
                        else
                            gatlingData.Frame = math.max(0, math.min(5, sideAngle / 36)) + 2.5;
                        end
        
                        gatlingData.Angle = sideAngle;
                    else
                        gatlingData.IsOpen = false;
                        -- return to Idle state.
                        devilcrow.I1 = 0;
                        attackData.Timer = 30;
                        THI.SFXManager:Play(SoundEffect.SOUND_METAL_DOOR_CLOSE);
                    end
                end
            end
        end
    end
end

local function WasteBucketUpdate(bucket)
    if (bucket.Velocity.Y < 9) then
        bucket.Velocity = bucket.Velocity + Vector(0, 0.3);
    end
    local spr = bucket:GetSprite();
    spr:Play("Roll");
    if (bucket.FrameCount > 30) then
        if (bucket:CollidesWithGrid()) then
            local game = Game();
            bucket:Die();
        end
    end
end

function Devilcrow:PostDevilcrowUpdate(devilcrow)
    local variant = devilcrow.Variant;
    if (variant == Devilcrow.Variants.DEVILCROW) then
        DevilcrowUpdate(devilcrow)
    elseif (variant == Devilcrow.Variants.WASTE_BUCKET) then
        WasteBucketUpdate(devilcrow)
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_NPC_UPDATE, Devilcrow.PostDevilcrowUpdate, Devilcrow.Type);

function Devilcrow:PostPlayerEffect(player)
    local playerData = Devilcrow.GetPlayerData(player, false);
    if (playerData) then
        local radiation = playerData.NuclearRadiation;
        local radiated = playerData.Radiated;
        local alive = not Players:IsDead(player);
        if (radiated) then
            if (alive)then
                radiation = math.min(maxRadiation, radiation + 1);
                local playSound = false;
                local signAlpha = 0;
                local ceilRad = math.ceil(radiation);
                local beepTimes = math.max(1, math.min(30, math.ceil(2 ^ math.floor(radiation / 25))))
                for i = 1, beepTimes do
                    local interval = math.ceil(30 / i);
                    if (ceilRad % interval == 0) then
                        playSound = true;
                    end
                    local alp = ceilRad / interval % 1;
                    alp = math.abs(0.5 - alp) * 2;
                    signAlpha = math.max(alp, signAlpha);
                end
                if (playSound) then
                    THI.SFXManager:Play(SoundEffect.SOUND_POISON_WARN, 2, 0, false, 1 + radiation / maxRadiation * 0.8);
                    THI.SFXManager:Play(SoundEffect.SOUND_BEEP, 2, 0, false, 1 + radiation / maxRadiation * 0.8);
                end
                playerData.Radiated = false;
                playerData.SignAlpha = signAlpha;
            end
        else
            radiation = math.max(0, radiation - 0.5);
            playerData.SignAlpha = radiation / maxRadiation;
        end
        if (radiation > 0) then
            if (alive) then
                local color;
                if (math.ceil(radiation) % 2 == 0 and radiation > maxRadiation - 45) then
                    color = Color(1,1,1,1,2,2, 2);
                    playerData.SignColorOffset = 1;
                else
                    color = Color(1,1,1,1,0,radiation / maxRadiation, 0)
                    playerData.SignColorOffset = 0;
                end
                player:SetColor(color, 1, 6);
                if (radiation >= maxRadiation) then
                    player:Kill();
                    player:SetColor(Color(1,1,1,1,0,1, 0), 60, 6, true);
                    radiation = 0;
                    playerData.SignAlpha = 0;
                end
            end
            playerData.NuclearRadiation = radiation;
        end
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Devilcrow.PostPlayerEffect);


function Devilcrow:PostPlayerKill(entity)
    
    local playerData = Devilcrow.GetPlayerData(entity, false);
    if (playerData) then
        playerData.NuclearRadiation = 0;
        playerData.SignAlpha = 0;
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Devilcrow.PostPlayerKill, EntityType.ENTITY_PLAYER);


function Devilcrow:PostDevilcrowKill(entity)
    if (entity.Variant == Devilcrow.Variants.DEVILCROW) then
        THI.SFXManager:Play(SoundEffect.SOUND_DOGMA_TV_BREAK);
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Devilcrow.PostDevilcrowKill, Devilcrow.Type);

local function DevilcrowRender(devilcrow, offset)
    local spr = devilcrow:GetSprite();
    if (spr:IsPlaying("Idle") and devilcrow.Visible) then
        local frame = spr:GetFrame() % 32;
        local data = Devilcrow.GetDevilcrowData(devilcrow, false);
        if (data) then

            local spriteScaleX = devilcrow.SpriteScale.X;
            local spriteScaleY = devilcrow.SpriteScale.Y;
            local spriteRotation = devilcrow.SpriteRotation;
            local game = Game();
            local room = game:GetRoom();
            local renderMode = room:GetRenderMode();
            local pos = Screen.GetEntityOffsetedRenderPosition(devilcrow, offset, Vector.Zero);
            for _, part in pairs(data.Parts) do

                local name = part.Name;
                -- Get Last Keyframe and next Keyframe.
                local partKeyframes = IdleFrames[name];
                local lastTime = -1;
                local lastFrame = nil;
                local nextTime = -1;
                local nextFrame = nil;
                if (partKeyframes) then
                    local t = 0;
                    for i, keyframe in pairs(partKeyframes) do
                        local duration = keyframe.Duration;
                        if (frame >= t) then
                            lastTime = t;
                            lastFrame = keyframe;
                            if (frame < t + duration) then
                                nextTime = t + duration;
                                nextFrame = partKeyframes[i + 1];
                            end
                        else
                            break;
                        end
                        t = t + duration;
                    end
                end

                local currentPosition = Vector.Zero;
                local currentRotation = 0;
                if (lastFrame) then
                    local lastPosition = lastFrame.Position or Vector.Zero;
                    local lastRotation = lastFrame.Rotation or 0;
                    if (nextFrame) then
                        local nextPosition = nextFrame.Position or Vector.Zero;
                        local nextRotation = nextFrame.Rotation or 0
                        local percent = (frame - lastTime) / (nextTime - lastTime);
                        currentPosition = lastPosition * (1 - percent) + nextPosition * percent
                        currentRotation = lastRotation + (nextRotation - lastRotation) * percent;
                    else
                        currentPosition = lastPosition;
                        currentRotation = lastRotation;
                    end
                end
                -- Rotation.
                local partSpr = part.Sprite;
                local flipX = partSpr.FlipX;
                if (flipX) then
                    currentRotation = currentRotation - spriteRotation;
                else
                    currentRotation = currentRotation + spriteRotation;
                end
                if (name == "Head") then
                    currentRotation = currentRotation + data.HeadRotation;
                end

                partSpr.Rotation = currentRotation;

                partSpr.Scale = devilcrow.SpriteScale;
                partSpr.Color = devilcrow:GetColor();

                -- Frames.
                if (name == "LeftGatling") then
                    partSpr:SetFrame(math.ceil(data.Gatlings.Left.Frame));
                end
                if (name == "RightGatling") then
                    partSpr:SetFrame(math.ceil(data.Gatlings.Right.Frame));
                end

                -- Position.
                local renderPos = pos;
                local renderOffset = currentPosition + RootOffset;
                renderOffset = renderOffset:Rotated(devilcrow.SpriteRotation)
                renderOffset.X = renderOffset.X * spriteScaleX;
                renderOffset.Y = renderOffset.Y * spriteScaleX;
                if (renderMode == RenderMode.RENDER_WATER_REFLECT) then
                    renderOffset = -renderOffset;
                    partSpr.FlipX = not partSpr.FlipX;
                end
                renderPos = renderPos + renderOffset;
                partSpr:Render(renderPos, Vector.Zero, Vector.Zero);
                partSpr.FlipX = flipX;
            end

            local lightPos = Screen.GetEntityOffsetedRenderPosition(devilcrow, offset, Vector(0, -40));
            data.LightSprite.Color = data.LightColor;
            data.LightSprite:Render(lightPos, Vector.Zero, Vector.Zero);
        end
    end

    

    if (spr:IsEventTriggered("ShakeScreen")) then
        Game():ShakeScreen(15);
        THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
    end

    if (spr:IsEventTriggered("Alert")) then
        THI.SFXManager:Play(THI.Sounds.SOUND_NUCLEAR_ALERT);
    end
    if (spr:WasEventTriggered("Alert")) then
        Game():ShakeScreen(30);
    end
end
function Devilcrow:PostDevilcrowRender(devilcrow, offset)
    local variant = devilcrow.Variant;
    if (variant == Devilcrow.Variants.DEVILCROW) then
        DevilcrowRender(devilcrow, offset)
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Devilcrow.PostDevilcrowRender, Devilcrow.Type);

function Devilcrow:PostPlayerRender(player, offset)
    local playerData = Devilcrow.GetPlayerData(player, false);
    if (playerData) then
        local alpha = playerData.SignAlpha;
        if (alpha and alpha > 0) then
            local o = playerData.SignColorOffset;
            local pos = Screen.GetEntityOffsetedRenderPosition(player, offset, Vector(0, -player.SpriteScale.Y * 16));
            RadiationSprite.Color = Color(1,1,1,alpha, o,o,o);
            RadiationSprite:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Devilcrow.PostPlayerRender);

function Devilcrow:PostDevilcrowDeath(devilcrow)
    
    local variant = devilcrow.Variant;
    local game = Game();
    if (variant == Devilcrow.Variants.DEVILCROW) then
        game:GetRoom():MamaMegaExplosion(devilcrow.Position);
        game:BombDamage (devilcrow.Position, 1000, 10000, true, devilcrow, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_EXPLOSION, false );
        devilcrow:BloodExplode();
    elseif (variant == Devilcrow.Variants.WASTE_BUCKET) then
        game:BombExplosionEffects  (devilcrow.Position, 50, TearFlags.TEAR_POISON, GreenColor, devilcrow, 1, true, false, DamageFlag.DAMAGE_EXPLOSION);
        for x = -1, 1 do
            for y = -1, 1 do
                local offset = Vector(x, y):Normalized() * 15;
                local pos = devilcrow.Position + offset;
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, pos, Vector.Zero, devilcrow):ToEffect();
                creep.Timeout = 90;
            end
        end
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Devilcrow.PostDevilcrowDeath,Devilcrow.Type);

local function TryTransferPlayers()
    
    local hasDevilcrow = false;
    for _, ent in pairs(Isaac.FindByType(Devilcrow.Type, Devilcrow.Variants.DEVILCROW)) do
        if (ent:IsActiveEnemy()) then
            hasDevilcrow = true;
            break;
        end
    end
    if (hasDevilcrow) then
        local center = Game():GetRoom():GetCenterPos();
        for p, player in Detection.PlayerPairs(true, true) do
            local pos = center + Vector(0, 160);
            for _, ent in ipairs(Isaac.FindByType(3)) do
                if (ent.Position:Distance(player.Position) < 40) then
                    ent.Position = pos;
                end
            end
            player.Position = pos;
            
        end
    end
end

local function PreNPCCollision(mod, npc, other, low)
    -- 防止BOSS立刻击杀迷失游魂跟班。
    if (Game():GetRoom():GetFrameCount() < 1) then
        return true;
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNPCCollision);

function Devilcrow:PostNewRoom()
    TryTransferPlayers()
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Devilcrow.PostNewRoom);

function Devilcrow:PostGameStarted(isContinued)
    if (isContinued) then
        TryTransferPlayers()
    end
end
Devilcrow:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Devilcrow.PostGameStarted);

return Devilcrow;
