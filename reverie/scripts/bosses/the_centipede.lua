local Entities = CuerLib.Entities;
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;
local Bosses = CuerLib.Bosses;
local Grids = CuerLib.Grids;
local Centi = ModEntity("The Centipede", "CENTIPEDE");

do
    local RockParams = ProjectileParams();
    RockParams.Variant = ProjectileVariant.PROJECTILE_ROCK;
    Centi.RockParams = RockParams;
end

local SegmentPrice = 5;
function Centi.GetCentipedeData(centipede, init)
    local getter = function ()
        return {
            LastPositions = {},
            ChildCount = 5,
            RNG = RNG()
        }
    end;
    return Centi:GetData(centipede, init, getter);
end

local randomSet = {};
function Centi:MoveRandomly(centipede, speed)
    local data = self.GetCentipedeData(centipede, true);
    if (not data.RNG) then
        local rng = RNG();
        rng:SetSeed(centipede.InitSeed, 1);
        data.RNG = rng;
    end

    for i = 1, 4 do
        randomSet[i] = i;
    end
    
    local room = Game():GetRoom();
    local vel = Vector.Zero;
    for i = 1, 4 do
        local index = data.RNG:RandomInt(#randomSet) + 1;
        local angle = randomSet[index] * 90;
        local v = Vector.FromAngle(angle) * speed;
        local grid = room:GetGridCollisionAtPos(centipede.Position + v);
        if (grid ~= GridCollisionClass.COLLISION_WALL and grid ~= GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER) then
            vel = v;
            break;
        else
            table.remove(randomSet, index);
        end
    end
    centipede.Velocity = vel;
end

-- Add Boss Room.
do
    local r = Grids.RoomGrids.Rock;
    local g = Grids.RoomGrids.FoolsGold;
    local n = Grids.RoomGrids.Null;
    local roomConfigs = {
        
        ID = "reverie:the_centipede",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/the_centipede",
        CustomRooms = {
            {
                Name = "TheCentipede1",
                ReplaceChance = 20,
                BossID = "reverie:the_centipede",
                Shape = RoomShape.ROOMSHAPE_2x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                VanishingTwinTarget = Vector(560, 280),
                Grids = {
                    {g, r, r, r, r, r, n, r, r, r, r, r, r, r, r, r, r, r, r, n, r, r, r, r, r, n},
                    {r, r, r, r, r, r, n, r, r, r, r, r, n, n, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, r, n, n, n, r, r, r, r, n, n, r, r, r, r, n, n, n, r, r, r, r, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {r, r, r, r, r, n, n, n, r, r, r, r, n, n, r, r, r, r, n, n, n, r, r, r, r, r},
                    {r, r, r, r, r, r, n, r, r, r, r, r, n, n, r, r, r, r, r, n, r, r, r, r, r, r},
                    {n, r, r, r, r, r, n, r, r, r, r, r, r, r, r, r, r, r, r, n, r, r, r, r, r, g},
                },
                Bosses = {
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(560, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(600, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(600, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(560, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(560, 280)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(600, 280)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(600, 320)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(560, 320)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(560, 360)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(600, 360)},
                },
                Entities = {
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(80, 400)},
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(1080, 160)},
                }
            },
            {
                Name = "TheCentipede2",
                ReplaceChance = 20,
                BossID = "reverie:the_centipede",
                Shape = RoomShape.ROOMSHAPE_1x2,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                VanishingTwinTarget = Vector(320, 400),
                Grids = {
                    {r, r, r, r, r, r, n, r, r, r, r, r, n},
                    {r, n, n, n, g, r, n, r, r, r, r, r, r},
                    {r, n, n, n, r, n, n, n, r, r, r, r, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {r, r, r, r, r, n, n, n, r, r, r, r, r},
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, r, n, n, n, r, r, r, r, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {r, r, r, r, r, n, n, n, r, n, n, n, r},
                    {r, r, r, r, r, r, n, r, g, n, n, n, r},
                    {n, r, r, r, r, r, n, r, r, r, r, r, r},
                },
                Bosses = {
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(120, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(160, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(200, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(200, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(160, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(120, 240)},
                    
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(440, 600)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(480, 600)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(520, 600)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(520, 640)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(480, 640)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(440, 640)},
                },
                Entities = {
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(80, 680)},
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(560, 160)},
                }
            },
            {
                Name = "TheCentipede3",
                ReplaceChance = 20,
                BossID = "reverie:the_centipede",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_1},
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_2}
                },
                Music = Music.MUSIC_BOSS2,
                EnterAction = nil,
                VanishingTwinTarget = Vector(320, 280),
                Grids = {
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                    {r, n, n, n, g, r, n, r, r, r, r, n, r},
                    {r, n, n, n, r, n, n, n, r, r, r, r, r},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {r, r, r, r, r, n, n, n, r, r, r, r, r},
                    {r, n, r, r, r, r, n, r, r, r, r, r, r},
                    {r, r, r, r, r, r, n, r, r, r, r, r, r},
                },
                Bosses = {
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(120, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(160, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(200, 200)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(200, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(160, 240)},
                    {Type = Centi.Type, Variant = Centi.Variant, SubType = Centi.SubType,  Position = Vector(120, 240)},
                },
                Entities = {
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(120, 360)},
                    {Type = 5, Variant = 20, SubType = 2, Position = Vector(520, 200)},
                }
            }
        }
    }
    local bossConfig = {
        Name = "The Centipede",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_1, Weight = 1},
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE2_2, Weight = 1}
            }
        },
        Type = Centi.Type,
        Variant = Centi.Variant,
        VanishingTwinFunc = function(self, boss)
            for i = 1, 5 do 
                Isaac.Spawn(self.Type, self.Variant, self.SubType or 0, boss.Position, Vector.Zero, boss);
            end
        end,
        PortraitPath = "gfx/reverie/ui/boss/portrait_583.0_the centipede.png",
        PortraitOffset = Vector(0, 0),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_583.0_the centipede.png",
            zh = "gfx/reverie/ui/boss/bossname_583.0_the centipede_zh.png",
            jp = "gfx/reverie/ui/boss/bossname_583.0_the centipede_jp.png"
        },
        IsEnabled = function(self)
            return THI.IsBossEnabled(self.Name);
        end
    }
    Bosses:SetBossConfig("reverie:the_centipede", bossConfig, roomConfigs);
end

local function UpdateChildrenCount(centipede)
    local count = 0;
    local child = centipede.ChildNPC;
    while (count < 5 and EntityExists(child)) do
        count = count + 1;
        child = child.ChildNPC;
    end
    local data = Centi.GetCentipedeData(centipede, true);
    data.ChildCount = count;
end

local function UpdateCentipedeSprite(centipede)
    local velocity = centipede.Velocity;
    local spr = centipede:GetSprite();
    local anim = "Head";
    local isBody = EntityExists(centipede.Parent);
    if (isBody) then
        velocity = centipede.Parent.Position - centipede.Position;
    else
        if (centipede.I1 == 1) then
            spr.PlaybackSpeed = 2;
        else
            spr.PlaybackSpeed = 1;
        end
    end
    local velX = velocity.X;
    local velY = velocity.Y;
    if (math.abs(velX) >= math.abs(velY)) then
        if (isBody) then
            anim = "WalkBodyHori"
            spr.FlipX = false;
        else
            anim = "WalkHeadHori";
            if (velX ~= 0) then
                spr.FlipX = velX < 0;
            end
        end
    else
        if (velY < 0) then
            if (isBody) then
                anim = "WalkBodyUp"
                if (not EntityExists(centipede.ChildNPC)) then
                    anim = "Butt"
                end
            else
                anim = "WalkHeadUp";
            end
        else
            if (isBody) then
                anim = "WalkBodyDown"
            else
                anim = "WalkHeadDown";
            end
        end
    end
    spr:Play(anim);
end

local function GetHeadTarget(centipede)
    
    local room = Game():GetRoom();
    local nearestCoin = nil
    local nearestDistance = 0;
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)) do
        local dis = ent.Position:Distance(centipede.Position)
        if (ent:Exists() and not nearestCoin or dis < nearestDistance) then
            nearestCoin = ent;
            nearestDistance = dis;
        end
    end
    if (nearestCoin) then
        return nearestCoin, nearestCoin.Position;
    end
        
    local nearestFoolsGold = nil;
    local nearestGoldDis = 0;
    local width = room:GetGridWidth();
    for x = 1, width - 2 do
        for y = 1, room:GetGridHeight() - 2 do
            local index = y * width + x;
            local gridEnt = room:GetGridEntity(index);
            if (gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_GOLD and gridEnt.State == 1) then
                local dis = gridEnt.Position:Distance(centipede.Position)
                if (not nearestFoolsGold or dis < nearestGoldDis) then
                    nearestFoolsGold = gridEnt;
                    nearestGoldDis = dis;
                end
            end
        end 
    end 

    if (nearestFoolsGold) then
        return nil, nearestFoolsGold.Position;
    end

    local player = centipede:GetPlayerTarget();
    return player, player.Position;
end

local function FindParents(centipede)
    
    local child = centipede.Child;
    local parent = centipede.Parent;
    if (not child and not parent) then
        
                    -- Find a parent for this.
        for _, ent in pairs(Isaac.FindByType(Centi.Type, Centi.Varianyt)) do
            if (ent.Position:Distance(centipede.Position) <= 80 and not CompareEntity(ent, centipede) and ent.FrameCount <= centipede.FrameCount +1) then
                if (not centipede.Parent) then
                    -- This has no parent.
                    local currentSegment = ent;
                    while (currentSegment.Child) do
                        currentSegment = currentSegment.Child;
                    end
                    centipede.Parent = currentSegment;
                    currentSegment.Child = centipede;

                    local curNPC = currentSegment:ToNPC();
                    if (curNPC) then
                        
                        if (curNPC.GroupIdx < 0) then
                            curNPC.GroupIdx = GetPtrHash(currentSegment);
                        end
                        centipede.GroupIdx = curNPC.GroupIdx;
                    end
                end
            end
        end
    end

    UpdateCentipedeSprite(centipede);
end

local function PostCentipedeInit(mod, centipede)
    if (centipede.Variant == Centi.Variant) then
        local room = Game():GetRoom();
        if (room:GetType() == RoomType.ROOM_DUNGEON) then
            centipede.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS;
        end
        
        FindParents(centipede);
    end
end
Centi:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostCentipedeInit, Centi.Type)


local function PostCentipedeUpdate(mod, centipede)
    if (centipede.Variant == Centi.Variant) then
        local room = Game():GetRoom();
        local child = centipede.Child;
        local parent = centipede.Parent;
        if (centipede.FrameCount >= 0) then
             FindParents(centipede)
        end

        if (not EntityExists(centipede.Child) and not EntityExists(centipede.Parent)) then
            centipede:Kill();
            return;
        end

        local data =  Centi.GetCentipedeData(centipede, true);
        local simSpeed = 1;
        if (centipede:HasEntityFlags(EntityFlag.FLAG_SLOW)) then
            simSpeed = 0.5;
        end
        data.StateTime = data.StateTime or 0;
        local function RunStateTime() data.StateTime = data.StateTime + simSpeed; end

        local pathFinder = centipede.Pathfinder;
        local i1 = centipede.I1;
        
        UpdateCentipedeSprite(centipede);


        if (EntityExists(parent)) then
            -- Body.
            local parentData =  Centi.GetCentipedeData(parent, false);
            if (parentData) then
                
                local target = parentData.LastPositions[#parentData.LastPositions];
                target = target or centipede.Position;
                centipede.Velocity = (target - centipede.Position) * 0.8;
            end
        else
            -- Head.

            -- Crush Rocks.
            if (room:GetType() == RoomType.ROOM_DUNGEON) then
                pathFinder:SetCanCrushRocks (false);
            else
                pathFinder:SetCanCrushRocks (true);
            end
            for i = 1, 8 do
                local angle = i * 45;
                local dir = Vector.FromAngle(angle) * centipede.Size;
                local gridIndex = room:GetGridIndex(centipede.Position + dir);
                local gridEnt = room:GetGridEntity(gridIndex);
                if (gridEnt) then
                    room:DestroyGrid(gridIndex, true);
                end
            end

            -- Eat Coins.
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)) do
                local dis = ent.Position:Distance(centipede.Position)
                if (dis <= centipede.Size + ent.Size and ent.FrameCount >= 30) then
                    local pickup = ent:ToPickup();
                    pickup:PlayPickupSound();
                    pickup:Remove();
                    
                    local value = pickup:GetCoinValue();
                    local child = centipede;
                    local count = 0;
                    while (count < 16 and EntityExists(child)) do
                        count = count + 1;
                        for i = 1, value do
                            if (child.HitPoints < child.MaxHitPoints) then
                                child.HitPoints = math.min(child.MaxHitPoints, child.HitPoints + child.MaxHitPoints / SegmentPrice);
                                value = value - 1;
                            elseif (not EntityExists(child.Child)) then
                                value = value - 1;
                                local newSegment = Isaac.Spawn(Centi.Type, Centi.Variant, 0, child.Position, Vector.Zero, centipede):ToNPC();
                                newSegment:ClearEntityFlags(EntityFlag.FLAG_APPEAR);

                                child.Child = newSegment;
                                newSegment.Parent = child;
                                newSegment.HitPoints = newSegment.MaxHitPoints / SegmentPrice;
                                
                            end
                        end
                        child = child.Child;
                    end
                end
            end
                
            local speed = 5;
            if (i1 == 1) then
                speed = 8;
            elseif (i1 == 2) then
                speed = 0;
            end
            local boost =  1 - (math.min(5, math.max(0, data.ChildCount or 5)) - 1) / 4
            speed = (boost * 0.2 + 1 )* speed;
            if (i1 == 0) then -- Wandering.

                -- Update Target.
                local target = centipede.Target;
                local targetJustChanged = false;
                -- Update the target every second, or when target is not exists.
                if (not EntityExists(target) or centipede:IsFrame(30, 0)) then
                    centipede.Target, centipede.TargetPosition = GetHeadTarget(centipede);

                    -- if target is changed.
                    if (not CompareEntity(target, centipede.Target) or 
                    ((target == nil or centipede.Target == nil) and target ~= centipede.Target)) then
                        targetJustChanged = true;
                    end
                end

                target = centipede.Target;


                local targetPos = centipede.TargetPosition;
                local pos = centipede.Position;
                local playSound = false;
                
                if (not target or target.Type == EntityType.ENTITY_PICKUP) then -- Found a coin or fool's gold.
                    speed = speed * 1.5;
                    if (targetJustChanged or centipede:IsFrame(math.ceil(40 / speed), 0)) then
                        centipede.Velocity = targetPos - centipede.Position;
                    end
                else -- Found its enemy
                    local tp = target.Position;
                    if (math.abs(tp.X - pos.X) <= 30) then -- centipede and its enemy is vertically Aligned.
                        -- Charges.
                        i1 = 1;
                        playSound = true;
                        if (tp.Y < pos.Y) then
                            centipede.V1 = Vector(0, -1);
                        else
                            centipede.V1 = Vector(0, 1);
                        end
                    elseif (math.abs(tp.Y - pos.Y) <= 30) then -- centipede and its enemy is horizontally Aligned.
                        -- Charges.
                        i1 = 1;
                        playSound = true;
                        if (tp.X < pos.X) then
                            centipede.V1 = Vector(-1, 0);
                        else
                            centipede.V1 = Vector(1, 0);
                        end
                    else    -- centipede and its enemy is not aligned.
                        if (centipede:IsFrame(math.ceil(80 / speed), 0) ) then
                            pathFinder:MoveRandomlyBoss(false);
                            pathFinder:MoveRandomlyAxisAligned (speed, false);

                            --Centi:MoveRandomly(centipede, speed);
                        end
                    end
                end
                if (playSound) then
                    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0)
                end
            elseif (i1 == 1) then -- Charging.
                if (centipede:CollidesWithGrid()) then
                -- local collided = false;
                -- local vel = centipede.Velocity;
                -- vel = vel:Resized(vel:Length() + centipede.Size);
                -- if (room:GetGridCollisionAtPos(centipede.Position + vel) == GridCollisionClass.COLLISION_WALL) then
                --     collided = true;
                -- end
                -- if (collided) then
                    i1 = 2;
                    Game():ShakeScreen(10);
                    THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);

                    centipede:FireBossProjectiles(math.floor(1 * speed), centipede.Position - centipede.V1 * 160, 10, Centi.RockParams)
                else
                    if (Random() % 5 == 0) then
                        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, centipede.Position, Vector.Zero, centipede):ToEffect();
                        creep.Timeout = 150;
                        creep.Scale = 1;
                    end
                    centipede.Velocity = centipede.V1 * speed;
                end
            elseif (i1 == 2) then -- Stunned.
                
                centipede.Velocity = Vector.Zero;
                if (data.StateTime < math.ceil(data.ChildCount * 6)) then
                    RunStateTime();
                else
                    data.StateTime = 0;
                    i1 = 0;
                    centipede.Velocity = -centipede.V1;
                end
            end
            
            local angle = centipede.Velocity:GetAngleDegrees();
            centipede.Velocity = Vector.FromAngle(math.ceil((angle - 45) / 90) *90);
            centipede.Velocity = centipede.Velocity:Resized(speed);

            -- Update Children.
            if (centipede:IsFrame(15, 0)) then
                UpdateChildrenCount(centipede);
            end
        end
        
        local lastPositions = data.LastPositions;
        local distance = (lastPositions[1] and lastPositions[1]:Distance(centipede.Position)) or 5;
        while (distance > 1) do
            table.insert(lastPositions, 1, centipede.Position);
            while (#lastPositions > 5) do
                table.remove(lastPositions, #lastPositions);
            end 
            distance = distance - 3;
        end

        centipede.I1 = i1;
    end
end
Centi:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostCentipedeUpdate, Centi.Type)

local function PostPlayerDamage(mod, tookDamage, amount, flags, source, countdown)
    if (source.Type == Centi.Type and source.Variant == Centi.Variant) then
        local player = tookDamage:ToPlayer();
        local coins = player:GetNumCoins()
        local seed = player.DropSeed;
        local count = math.min(coins, seed % 3 + 1);
        for i = 1, count do
            player:AddCoins(-1);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, player.Position, RandomVector(), player);
        end
    end
end
Centi:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostPlayerDamage, EntityType.ENTITY_PLAYER)


local function PostCentipedeKill(mod, npc)
    if (npc.Variant == Centi.Variant) then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, npc.Position, Vector.Zero, npc):ToEffect();
        creep.Timeout = 300;
        creep.Scale = 2;

        for i = 1, 3 do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, npc.Position, RandomVector(), npc)
        end
        
        local count = 0;
        local head = npc;
        while (count < 64 and EntityExists(head.ParentNPC) and not head.ParentNPC:IsDead()) do
            count = count + 1;
            head = head.ParentNPC;
        end
        UpdateChildrenCount(head)
    end
end
Centi:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostCentipedeKill, Centi.Type)

local function PostCentipedeCollision(mod, npc, other, low)
    if (npc.Variant == Centi.Variant and other.Type == Centi.Type and other.Variant == Centi.Variant) then
        if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            return true;
        end
    end
end
Centi:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PostCentipedeCollision, Centi.Type)

return Centi;