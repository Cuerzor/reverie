
local Bosses = CuerLib.Bosses;
local Detection = CuerLib.Detection;
local Grids = CuerLib.Grids;
local Necrospyder = ModEntity("Necrospyder", "NECROSPYDER");

local NecrospyderHole = ModEntity("Necrospyder Hole", "NECROSPYDER_HOLE");
do

    local BulletParams = ProjectileParams();
    BulletParams.BulletFlags = ProjectileFlags.ACCELERATE_EX | ProjectileFlags.BURST8;
    BulletParams.Scale = 2;
    BulletParams.Variant = ProjectileVariant.PROJECTILE_PUKE;
    Necrospyder.BulletParams = BulletParams;
end

-- Hole.
do



    local function PostHoleInit(mod, hole)
        hole.SpriteRotation = hole.SubType * 90;
        hole:GetSprite():SetFrame(hole.InitSeed % 3);
        hole:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
        hole:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_NO_REMOVE_ON_TEX_RENDER);
    end
    NecrospyderHole:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostHoleInit, NecrospyderHole.Variant);

    local function PostHoleRender(mod, hole)
        if (hole.FrameCount == 1) then
            hole:SetColor(Color(1,1,1,0,0,0,0), -1, 9999);
        end
    end
    NecrospyderHole:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, PostHoleRender, NecrospyderHole.Variant);
end

-- Add Boss Room.
do
    local n = Grids.RoomGrids.Null;
    local p = Grids.RoomGrids.Pits;
    local w = Grids.RoomGrids.Spiderweb;
    local roomConfig = {
        ID = "reverie:necrospyder",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/necrospyder",
        CustomRooms = {
            Necrospyder1 = {
                ReplaceChance = 20,
                BossID = "reverie:necrospyder",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_1},
                    {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                PostEnter = function(firstVisit, cleared)
                    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION)) do
                        ent:Remove();
                    end
                end,
                Grids = {
                    {p, p, p, w, p, n, n, n, p, w, p, p, p},
                    {w, n, n, n, n, n, n, n, n, n, n, n, w},
                    {p, p, p, n, n, n, n, n, n, n, p, p, p},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {p, p, p, n, n, n, n, n, n, n, p, p, p},
                    {w, n, n, n, n, n, n, n, n, n, n, n, w},
                    {p, p, p, w, p, n, n, n, p, w, p, p, p},
                },
                Bosses = {
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 0, Position = Vector(200, 120)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 0, Position = Vector(440, 120)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 1, Position = Vector(600, 200)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 1, Position = Vector(600, 360)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 2, Position = Vector(200, 440)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 2, Position = Vector(440, 440)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 3, Position = Vector(40, 200)},
                    { Type = NecrospyderHole.Type, Variant = NecrospyderHole.Variant, SubType = 3, Position = Vector(40, 360)},
                    { Type = Necrospyder.Type, Variant = Necrospyder.Variant, SubType = Necrospyder.SubType, Position = Vector(0, 0)},
                }
            }
        }
    }
    local bossConfig = {
        Name = "Necrospyder",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_1, Weight = 1},
                {Type = StageType.STAGETYPE_REPENTANCE_B, Stage = LevelStage.STAGE1_2, Weight = 1}
            }
        },
        Type = Necrospyder.Type,
        Variant = Necrospyder.Variant,
        PortraitPath = "gfx/reverie/ui/boss/portrait_582.0_necrospyder.png",
        PortraitOffset = Vector(0, 0),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_582.0_necrospyder.png",
            zh = "gfx/reverie/ui/boss/bossname_582.0_necrospyder_zh.png",
            jp = "gfx/reverie/ui/boss/bossname_582.0_necrospyder_jp.png"
        }
    }
    Bosses:SetBossConfig("reverie:necrospyder", bossConfig, roomConfig);
    
    -- Stage API setup.
    if (StageAPI) then
        local holes = {
            {SubType = 0, Position = Vector(200, 120)},
            {SubType = 0, Position = Vector(440, 120)},
            {SubType = 1, Position = Vector(600, 200)},
            {SubType = 1, Position = Vector(600, 360)},
            {SubType = 2, Position = Vector(200, 440)},
            {SubType = 2, Position = Vector(440, 440)},
            {SubType = 3, Position = Vector(40, 200)},
            {SubType = 3, Position = Vector(40, 360)},
        }
        local function PostNewRoom() 

            -- Remove wall decorations.
            for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION)) do
                ent:Remove();
            end
            -- Create Holes.
            local currentRoom = StageAPI.GetCurrentRoom();
            if (currentRoom and not currentRoom.IsClear) then
                local roomsListName = currentRoom.RoomsListName;
                if (roomsListName == "reverie:necrospyder") then
                    
                    local layoutName = currentRoom.Layout.Name;
                    if (layoutName == "Necrospyder1") then
                        for _, hole in pairs(holes) do
                            Isaac.Spawn(NecrospyderHole.Type, NecrospyderHole.Variant, hole.SubType, hole.Position, Vector.Zero, nil);
                        end
                    end
                end
            end
        end
        StageAPI.AddCallback(THI.Name, "POST_STAGEAPI_NEW_ROOM", 0, PostNewRoom);
    end
end

do

    Necrospyder.States = {
        HIDDEN = 0,
        IDLE = 1,
        CREEP = 2,
        SHOOT = 3,
        SUMMON = 4,
        POISON = 5,
        SLAP = 6,
        GET_OUT = 10,
        GET_IN = 11
    }
    local MovesPerHole = 3;
    local CreepTimeout = 300;
    local GasTimeout = 120;

    function Necrospyder.GetSpiderData(spider, init)
        local getter = function ()
            return {
                RemainedMoves = MovesPerHole,
                StateTime = 0
            }
        end
        return Necrospyder:GetData(spider, init, getter);
    end

    local function SetState(spider, state)
        spider.Visible = true;
        spider.SizeMulti = Vector.One;
        if (state == Necrospyder.States.HIDDEN) then
            spider.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
            spider.Visible = false;
        elseif (state == Necrospyder.States.IDLE) then
            spider.TargetPosition = spider.Position;
            spider:GetSprite():Play("Idle");
            spider.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
        elseif (state == Necrospyder.States.GET_OUT) then
            spider:GetSprite():Play("SqueezeOut", true);
        elseif (state == Necrospyder.States.SUMMON or 
        state == Necrospyder.States.SHOOT or 
        state == Necrospyder.States.CREEP or 
        state == Necrospyder.States.POISON) then
            spider:GetSprite():Play("Charge");
        elseif (state == Necrospyder.States.GET_IN) then
            spider:GetSprite():Play("SqueezeIn", true);
        elseif (state == Necrospyder.States.SLAP) then
            spider:GetSprite():Play("Legs", true);
            spider.SizeMulti = Vector(0.666, 1.8);
            spider.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            THI.SFXManager:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS);
        end
        spider.I1 = state;
        spider.I2 = 0;
        
        local data = Necrospyder.GetSpiderData(spider, true);
        data.StateTime = 0;
    end

    local function GetOut(spider)
        
        local holes = {};
        for _, ent in pairs(Isaac.FindByType(NecrospyderHole.Type, NecrospyderHole.Variant)) do
            if (not ent.Child or not ent.Child:Exists()) then
                table.insert(holes, ent);
            end
        end
        if (#holes > 0) then
            local playerNearHole = nil;
            for i, ent in pairs(holes) do
                local angle = ent.SpriteRotation;
                local holeDir = Vector.FromAngle(angle + 90);
                local holeNormal = Vector.FromAngle(angle);
                for p, player in Detection.PlayerPairs(true, true) do
                    local holeToPlayer = player.Position - ent.Position;
                    if (math.abs(holeNormal:Dot(holeToPlayer)) <= 20 and math.abs(holeDir:Dot(holeToPlayer)) <= 80) then
                        playerNearHole = ent;
                        break;
                    end
                end
            end

            local hole = nil;
            local state = Necrospyder.States.GET_OUT;
            if (playerNearHole) then
                hole = playerNearHole;
                state = Necrospyder.States.SLAP;
            else
                hole = holes[Random() % #holes + 1];
            end
            local rotation = hole.SpriteRotation;
            local offset = Vector.FromAngle(rotation + 90) * 26;


            if (spider.Parent and spider.Parent:Exists()) then
                spider.Parent.Child = nil;
            end

            spider.Position = hole.Position + offset;
            spider.Parent = hole;
            hole.Child = spider;
            spider.TargetPosition = spider.Position;
            spider.SpriteRotation = rotation;
            SetState(spider, state);
        end
    end
    
    
    local function PostNecrospyderInit(mod, spider)
        if (spider.Variant == Necrospyder.Variant) then
            spider:ClearEntityFlags(EntityFlag.FLAG_APPEAR); 
            SetState(spider, Necrospyder.States.HIDDEN);
        end
    end
    Necrospyder:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostNecrospyderInit, Necrospyder.Type);
    local function PostNecrospyderUpdate(mod, spider)
        if (spider.Variant == Necrospyder.Variant) then

            local simSpeed = 1;
            if (spider:HasEntityFlags(EntityFlag.FLAG_SLOW)) then
                simSpeed = 0.5;
            end
            
            spider.Velocity = spider.TargetPosition - spider.Position;

            local data = Necrospyder.GetSpiderData(spider, true);


            --State Time.
            local function RunStateTime() data.StateTime = (data.StateTime or 0) + simSpeed end

            local spr = spider:GetSprite();
            local i1 = spider.I1;
            if (i1 == Necrospyder.States.HIDDEN) then
                RunStateTime();
                if (data.StateTime > 50) then
                    GetOut(spider);
                end 
            elseif (i1 == Necrospyder.States.IDLE) then
                RunStateTime();
                data.RemainedMoves = data.RemainedMoves or MovesPerHole;
                if (data.RemainedMoves > 0) then
                    if (data.StateTime > 12) then
                        local statePool = {
                            Necrospyder.States.SHOOT
                        };
                        if (#Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE) <= 0) then
                            table.insert(statePool, Necrospyder.States.CREEP);
                        end
                        if (#Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD) <= 0) then
                            table.insert(statePool, Necrospyder.States.POISON);
                        end
                        if (#Isaac.FindByType(EntityType.ENTITY_HOPPER, 1) < 1) then
                            table.insert(statePool, Necrospyder.States.SUMMON);
                        end
                        local nextState
                        if (#statePool == 0) then
                            nextState = Necrospyder.States.GET_IN;
                        else
                            nextState = statePool[Random() % #statePool + 1];
                        end
                        SetState(spider, nextState);
                        data.RemainedMoves = data.RemainedMoves - 1;
                    end
                else
                    if (data.StateTime > 30) then
                        SetState(spider, Necrospyder.States.GET_IN);
                        data.RemainedMoves = MovesPerHole;
                    end
                end
            elseif (i1 == Necrospyder.States.CREEP) then
                -- Shoot Creeps.
               RunStateTime();
               if (spider.I2 == 0) then
                   -- Before Shoot.
                   if (data.StateTime > 10) then
                       spider.I2 = 1;
                       THI.SFXManager:Play(SoundEffect.SOUND_HEARTOUT);
                       local dir = Vector.FromAngle(spider.SpriteRotation + 90);
                       local pos = spider.Position + dir;
                       local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, spider);
                       local whiteColor = Color(0,0,0,1,1,1,1);
                       exp:SetColor(whiteColor, -1, 0);
                       local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE, 0, spider.Position + dir, Vector.Zero, spider) :ToEffect();
                       creep.Timeout = CreepTimeout;

                       spr:Play("Spit");
                       data.StateTime = 0;
                   end
               else
                    if (data.StateTime <= 8) then
                        for d = -1, 1 do
                            for i = 0, 2 do
                                local offset = (data.StateTime - 1) * 3 + i;
                                local dir = Vector.FromAngle(spider.SpriteRotation + 90 + d * 30);
                                local pos = spider.Position + dir * offset * 20;
                                if (Game():GetRoom():IsPositionInRoom(pos, 0)) then
                                    
                                    local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, spider);
                                    local whiteColor = Color(0,0,0,1,1,1,1);
                                    exp:SetColor(whiteColor, -1, 0);
                                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE, 0, pos, Vector.Zero, spider) :ToEffect();
                                    creep.Timeout = CreepTimeout;
                                end
                            end
                        end
                    end

                    if (spr:IsFinished("Spit")) then
                       SetState(spider, Necrospyder.States.IDLE);
                    end
               end
           
            elseif (i1 == Necrospyder.States.SHOOT) then
                 -- Shot Bullet.
                RunStateTime();
                if (spider.I2 == 0 or spider.I2 == 1) then
                    -- Before Shoot.
                    if (data.StateTime > 10) then
                        spider.I2 = spider.I2 + 1;
                        local dir = Vector.FromAngle(spider.SpriteRotation + 90)
                        local vel = dir * (2 + spider.I2* 8) * Vector(1, 0.6);
                        THI.SFXManager:Play(SoundEffect.SOUND_LITTLE_SPIT);

                        Necrospyder.BulletParams.HeightModifier = (spider.I2 * -1) - 2 +23.5;
                        spider:FireProjectiles(spider.Position, vel, 0, Necrospyder.BulletParams)
                        Necrospyder.BulletParams.HeightModifier = 0;

                        -- local bullet = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 3, 0, spider.Position, vel, spider) :ToProjectile();
                        -- bullet:AddProjectileFlags(ProjectileFlags.ACCELERATE_EX | ProjectileFlags.BURST8);
                        -- bullet.Scale = 2;

                        -- -- Projectile range depends on player distance.
                        -- local dis = spider:GetPlayerTarget().Position - (spider.Position + vel);
                        -- local distance = dis:Dot(dir);
                        -- local time = distance / vel:Length() / 2;
                        -- bullet.Height = -(time + 9 * (1 - 0.9 ^ time) );

                        -- Projectile range is fixed.
                        -- bullet.Height = -6 + (spider.I2 * -2);

                        spr:Play("Spit", true);
                        data.StateTime = 0;
                    end
                else
                    if (spr:IsFinished("Spit")) then
                        SetState(spider, Necrospyder.States.IDLE);
                    end
                end
            elseif (i1 == Necrospyder.States.SUMMON) then
                -- Summon Trides.
                RunStateTime();
                if (spider.I2 == 0) then
                    -- Before Summon.
                    if (data.StateTime > 10) then
                        spider.I2 = 1;
                        local vel = Vector.FromAngle(spider.SpriteRotation + 90) * 10;
                        THI.SFXManager:Play(SoundEffect.SOUND_WHEEZY_COUGH);
                        for i = 1, 1 do
                        
                            local trite = Isaac.Spawn(EntityType.ENTITY_HOPPER, 1, 0, spider.Position + vel * 2, vel, spider);
                            trite:ClearEntityFlags(EntityFlag.FLAG_APPEAR); 
                        end
                        spr:Play("Spit");
                        data.StateTime = 0;
                    end
                else
                    if (spr:IsFinished("Spit")) then
                        SetState(spider, Necrospyder.States.IDLE);
                    end
                end
            elseif (i1 == Necrospyder.States.POISON) then
                -- Summon Gas.
                RunStateTime();
                if (spider.I2 == 0) then
                    -- Before Summon.
                    if (data.StateTime > 10) then
                        spider.I2 = 1;
                        THI.SFXManager:Play(SoundEffect.SOUND_WHEEZY_COUGH);
                        for layer = 1, 2 do
                            for i = 0, 6 do
                                local dir = Vector.FromAngle(spider.SpriteRotation + i / 6 * 180);
                                local gas = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, spider.Position + dir * 80 * layer, Vector.Zero, spider):ToEffect();
                                gas.Timeout = GasTimeout;
                            end
                        end
                        spr:Play("Spit");
                        data.StateTime = 0;
                    end
                else
                    if (spr:IsFinished("Spit")) then
                        SetState(spider, Necrospyder.States.IDLE);
                    end
                end
            elseif (i1 == Necrospyder.States.GET_OUT) then
                if (spr:IsFinished("SqueezeOut")) then
                    SetState(spider, Necrospyder.States.IDLE);
                end 
            elseif (i1 == Necrospyder.States.GET_IN) then
                if (spr:IsFinished("SqueezeIn")) then
                    SetState(spider, Necrospyder.States.HIDDEN);
                end 
            elseif (i1 == Necrospyder.States.SLAP) then
                if (spr:IsFinished("Legs")) then
                    SetState(spider, Necrospyder.States.HIDDEN);
                end 
            end
            
            if (spr:IsEventTriggered("Squeeze")) then
                THI.SFXManager:Play(SoundEffect.SOUND_SKIN_PULL);
                Game():ShakeScreen(5);
            end
        end
    end
    Necrospyder:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNecrospyderUpdate, Necrospyder.Type);

    local function PostNecrospyderKill(mod, spider)
        if (spider.Variant == Necrospyder.Variant) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, spider.Position, Vector.Zero, nil);
        end
    end
    Necrospyder:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostNecrospyderKill, Necrospyder.Type);
end

return Necrospyder;