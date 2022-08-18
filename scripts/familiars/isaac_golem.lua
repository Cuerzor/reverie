local Detection = CuerLib.Detection;
local Familiars = CuerLib.Familiars;
local Math = CuerLib.Math;
local Screen = CuerLib.Screen;

local IsaacGolem = ModEntity("Isaac Golem", "IsaacGolem")

local debugRender = false;
local maxCheckCooldown = 10;
local maxPathFindCooldown = 10;
local maxDamageCooldown = 30;
local preferedRange = 120;
local maxRange = 320;
function IsaacGolem.GetGolemData(golem)
    return IsaacGolem:GetData(golem, true, function() return {
        CheckCooldown = 0,
        State = 0,
        Damage = {
            Cooldown = 0,
            Invisible = false,
        },
        AttackData = {
            Target = nil,
            TargetPos = Vector.Zero,
            AttackDirection = 0,
            DestroyGrid = false,
            DestroyGridDir = 0
        },
        PressurePlateData = {
            Plates = {}
        },
        TrickChestData = {
            Chests = {}
        },
        PathFindData = {
            LastIndex = 0,
            LastTargetIndex = 0,
            Cooldown = 0,
            Node = nil,
            Nodes = {}
        },
        Sprites = {
            Head = {
                Animation = "ShootDown",
                Frame = 0
            },
            Body = {
                Animation = "WalkDown",
                Frame = 0
            }
        }
    } end);
end


local function CheckState(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local state = 0;
    local room = THI.Game:GetRoom();
    if (room:GetAliveEnemiesCount() > 0) then
        -- Attack State.
        data.AttackData.Target, data.AttackData.TargetPos, data.AttackData.AttackDirection = IsaacGolem.FindAttackTarget(golem);
    end

    if (data.AttackData.Target) then
        state = 1;
    end

    local shouldPress = IsaacGolem.FindPressurePlates(golem, state == 1);
    if (shouldPress) then
        state = 2;
        data.PressurePlateData.Next = true;
    else
        if (state == 0) then
            local shouldOpenChests = IsaacGolem.FindTrickChests(golem);
            if (shouldOpenChests) then
                state = 3;
                data.TrickChestData.Next = true;
                
            end
        end
    end
    data.State = state;
end

local function IsValidPoop(gridEnt)
    return gridEnt and gridEnt:GetType() == GridEntityType.GRID_POOP and gridEnt.CollisionClass == GridCollisionClass.COLLISION_SOLID;
end

local function CheckAllDestructable(pos, pos2)
    local room = THI.Game:GetRoom();
    local distance = pos:Distance(pos2);
    
    local hasPoop = false;
    local vector = (pos2 - pos):Normalized();
    for i = 0, distance, 40 do
        local targetPos = pos + vector * i;
        local gridEntity = room:GetGridEntityFromPos(targetPos);
        if (gridEntity) then
            local noStand = false;
            local isPoop = IsValidPoop(gridEntity);
            if (isPoop) then
                hasPoop = true;
            end
            if (not isPoop and gridEntity.CollisionClass ~= GridCollisionClass.COLLISION_NONE) then
                return 0;
            end 
        end
    end
    if (hasPoop) then
        return 1;
    end
    return 2;
end

----------------
-- Path Finding
----------------

local Params = {
    PassCheck = function(index)

        local room = Game():GetRoom();
        local gridEnt = room:GetGridEntity(index);
        if (IsValidPoop(gridEnt)) then
            return true, 2;
        end

        local PathFinding = THI.Shared.PathFinding;
        return PathFinding:CanPass(index);
    end,
    MaxStartCost = -1,
    MaxCost = -1,
}

local gridSize = 40;
local function FindPath(entIndex, targetIndex)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPath(entIndex, targetIndex, Params);
end

local function FindPathInPos(entityPos, targetPos)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPathInPos(entityPos, targetPos, Params);
end


local function MoveToTarget(golem, moveTarget, maxCooldown, targetDistance)
    maxCooldown = maxCooldown or maxPathFindCooldown;
    targetDistance = targetDistance or 0;
    local data = IsaacGolem.GetGolemData(golem);
    local room = THI.Game:GetRoom();
    local target = moveTarget;
    local canDirectlyWalk, newPos = room:CheckLine(golem.Position, target, 0);
    -- If cannot directly walk to the target.
    if (not canDirectlyWalk) then
        
        local targetIndex = room:GetGridIndex(target);
        -- Search Path.
        local currentIndex = room:GetGridIndex(golem.Position);
        if (
        data.PathFindData.Cooldown <= 0) then
            data.PathFindData.Cooldown = maxCooldown;
            local nodes = FindPath(currentIndex, targetIndex);
            data.PathFindData.Nodes = nodes
            local node = nil;
            if (nodes) then
                local num = #nodes;
                for i = num - 2, num do
                    local index = nodes[i];
                    if (index) then
                        local gridEnt = room:GetGridEntity(index);
                        if (not gridEnt or gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
                            node = index;
                            break;
                        end
                    end
                end
            end
            data.PathFindData.Node = node;
        end


        local cancelMove = false;
        if (data.PathFindData.Node and data.PathFindData.Node ~= room:GetGridIndex(golem.Position)) then
            target = room:GetGridPosition(data.PathFindData.Node);
        else
            -- Path is blocked.
            cancelMove = true;
        end

        -- Destroy Destructables.
        local nodes = data.PathFindData.Nodes;
        if (nodes) then
            local num = #nodes;
            for i = num, num - 2, -1 do
                local index = nodes[i];
                if (index) then
                    if (IsValidPoop(room:GetGridEntity(index))) then
                        data.AttackData.DestroyGrid = true;
                        data.AttackData.DestroyGridDir = Math.GetDirectionByAngle((golem.Position - room:GetGridPosition(index)):GetAngleDegrees())
                        break;
                    end
                end
            end
        end
        if (cancelMove) then
            return false;
        end
    end

    local moveDir = (target - golem.Position):Normalized();
    local moveSpeed = math.max(0, math.min(8 - golem.Velocity:Length(), ((moveTarget - golem.Position):Length() - targetDistance)  / 5));
    golem:AddVelocity(moveDir * moveSpeed);
    return true;
end

------------------
-- Follow
------------------

local function UpdateFollowState(golem)
    local player = golem.Player;
    if (player) then
        MoveToTarget(golem, player.Position, maxPathFindCooldown, 40)
    end
end

------------------
-- Attack
------------------

local maxGridAway = math.ceil((maxRange - preferedRange) / gridSize);

local function GetAttackStandPos(targetPos, direction)
    local room = THI.Game:GetRoom();
    local pos = targetPos;
    
    local vector;
    if (direction == Direction.LEFT) then
        vector = Vector(-1, 0);
    elseif (direction == Direction.UP) then
        vector = Vector(0, -1);
    elseif (direction == Direction.DOWN) then
        vector = Vector(0, 1);
    elseif (direction == Direction.RIGHT) then
        vector = Vector(1, 0);
    end
    pos = pos + vector * preferedRange;
    local gridAway = 0;
    local gridEntity = room:GetGridEntityFromPos(pos);
    while (gridAway < maxGridAway and (gridEntity and gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT)) do
        pos = pos + vector * gridSize;
        gridEntity = room:GetGridEntityFromPos(pos);
        gridAway = gridAway + 1;
    end
    return pos;
end

local function CheckAttackDirectionValid(golem, target, direction)
    if (direction == Direction.NO_DIRECTION) then
        return false;
    end

    local room = THI.Game:GetRoom();
    local standPos = GetAttackStandPos(target.Position, direction);
    local noObstacles, newPos = room:CheckLine(target.Position, standPos, 3);
    if (not noObstacles and CheckAllDestructable(target.Position, standPos) > 0) then
        noObstacles = true;
        newPos = standPos;
    end
    -- There's obstacles on the way.
    if (not noObstacles) then
        -- Avoid too close to target if target has collision Damage.
        if (target.CollisionDamage > 0) then
            if (newPos:Distance(target.Position) <= 30) then
                return false, newPos;
            end
        end
    end
    -- No obstacles on the way.
    local gridEntity = room:GetGridEntityFromPos(newPos);
    if (gridEntity and gridEntity.CollisionClass ~= GridCollisionClass.COLLISION_NONE and not IsValidPoop(gridEntity)) then
        return false, newPos;
    end
    return true, newPos;
end

function IsaacGolem.FindAttackTarget(golem)
    local maxWeight = -10000;
    local target = nil;
    local standPos = Vector.Zero;
    local targetDir = 0;
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        local npc = ent:ToNPC();
        if (npc) then
            if (Detection.IsValidEnemy(npc) and not npc:IsDead()) then
                local room = THI.Game:GetRoom();
                local weight = 0;
                weight = weight - npc.Position:Distance(golem.Position);
                local noObstacles, newPos = room:CheckLine(golem.Position, npc.Position, 3);
                if (not noObstacles) then
                    weight = weight - 160;
                end
                if (npc.Type == EntityType.ENTITY_BISHOP) then
                    weight = weight + 10000;
                end
                
                -- if it has the max Weight.
                if (weight > maxWeight) then
                    -- Accessable Test.
                    local targetToGolem = npc.Position - golem.Position;

                    -- Check whether if golem can on this direction.
                    local nearest = nil;
                    local nearestDis = 0;
                    local nearestDir = nil;
                    for dir = 0, 3 do
                        local canStand, newStandPos = CheckAttackDirectionValid(golem, npc, dir);
                        if (canStand) then
                            local dis = newStandPos:Distance(golem.Position);
                            if (not nearest or dis < nearestDis) then
                                nearest = newStandPos;
                                nearestDis = dis;
                                nearestDir = dir;
                            end
                        end
                    end

                    -- if Can stand in the shooting direction.
                    ::checkTarget::
                    if (nearest) then
                        target = npc;
                        maxWeight = weight;
                        standPos = nearest;
                        targetDir = nearestDir;
                    end
                end
            end
        end
    end
    return target, standPos, targetDir;
end

local function FireCheck(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local room = THI.Game:GetRoom();

    local target = data.AttackData.Target;
    local fireTear = false;
    local direction = data.AttackData.AttackDirection;
    if (target) then
        local standPos = data.AttackData.TargetPos;
        MoveToTarget(golem, standPos);

        local canSeeTarget, blockedPos = room:CheckLine(target.Position, golem.Position, 3);
        fireTear = canSeeTarget and golem.Position:Distance(target.Position) < maxRange;
        direction = data.AttackData.AttackDirection;
        if (not fireTear) then
            if (CheckAllDestructable(golem.Position, target.Position) == 1) then
                fireTear = true;
            end
        end
    end
    -- Destroy poops on the way.
    if (not fireTear) then
        if (data.AttackData.DestroyGrid) then
            fireTear = true;
            direction = data.AttackData.DestroyGridDir;
            data.AttackData.DestroyGrid = false;
        end
    end

    if (fireTear) then
        
        local fireDir = Vector(-1, 0);
        local headAnim = "ShootDown";
        if (direction == Direction.LEFT) then
            fireDir = Vector(1, 0);
            headAnim = "ShootRight";
        elseif (direction == Direction.UP) then
            fireDir = Vector(0, 1);
            headAnim = "ShootDown";
        elseif (direction == Direction.DOWN) then
            fireDir = Vector(0, -1);
            headAnim = "ShootUp";
        elseif (direction == Direction.RIGHT) then
            fireDir = Vector(-1, 0);
            headAnim = "ShootLeft";
        end
        if (Familiars:canFire(golem)) then
            local tear = Isaac.Spawn(2, 0, 0, golem.Position, fireDir * 12 + golem.Velocity / 3, golem):ToTear();
            local stage = THI.Game:GetLevel():GetStage();
            
            local damage = 3.5 + (stage - 1) * 0.9;
            if (golem.Player) then
                if (golem.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    damage = damage * 2;
                end

                if (golem.Player:HasTrinket(TrinketType.TRINKET_BABY_BENDER)) then
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING;
                    tear:SetColor(Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549), -1, 0, false, false);
                end
            end
            
            -- tear Scale.
            tear.Scale = Math.GetTearScaleByDamage(damage);
            tear.CollisionDamage = damage;
            golem.FireCooldown = math.floor(10 - (stage - 1) * 0.25);
            data.Sprites.Head.Animation = headAnim;
            data.Sprites.Head.Frame = 0;
        end
    end
end


------------------
-- Pressure Plate
------------------

function IsaacGolem.FindPressurePlates(golem, isAttacking)
    local room = THI.Game:GetRoom();
    local data = IsaacGolem.GetGolemData(golem);
    local hasButton = false;
    local tbl = data.PressurePlateData.Plates;

    for i = #tbl, 1, -1 do
        table.remove(tbl, i);
    end
    
    for i = 0, room:GetGridSize() do
        local gridEntity = room:GetGridEntity(i);
        if (gridEntity and gridEntity:GetType() == GridEntityType.GRID_PRESSURE_PLATE) then
            
            local variant = gridEntity:GetVariant();
            -- if not reward button or greed button.
            if ((variant ~= 1 and variant ~= 2) and gridEntity.State == 0) then
                -- if not in combat, or this is a red button.
                if (not isAttacking or variant == 9) then
                    if (FindPathInPos(golem.Position, gridEntity.Position)) then
                        table.insert(tbl, gridEntity:ToPressurePlate());
                        hasButton = true;
                    end
                end
            end
        end
    end
    return hasButton;
end

local function UpdatePressurePlateState(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local nearestDis = 100000;
    local nearest = nil;
    local nearestIndex = 0;
    for i, plate in pairs(data.PressurePlateData.Plates) do 
        if (plate.State == 0) then
            local dis = plate.Position:Distance(golem.Position);
            if (dis < nearestDis) then
                nearestDis = dis;
                nearest = plate;
                nearestIndex = i;
            end
        end
    end
    if (nearest) then

        MoveToTarget(golem, nearest.Position)

        if (nearestDis <= 16) then
            nearest:Reward();
            nearest.State = 3;
            nearest:GetSprite():Play("On");
            THI.SFXManager:Play(SoundEffect.SOUND_BUTTON_PRESS);
            table.remove(data.PressurePlateData.Plates, nearestIndex);
            data.PathFindData.Cooldown = 0;
        end
    end
end

------------------
-- Trap Chest
------------------
function IsaacGolem.FindTrickChests(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local tbl = data.TrickChestData.Chests;
    local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP);
    
    for i = #tbl, 1, -1 do
        table.remove(tbl, i);
    end
    for i, pickup in pairs(pickups) do
        local variant = pickup.Variant;
        if (variant == PickupVariant.PICKUP_SPIKEDCHEST or
        variant == PickupVariant.PICKUP_HAUNTEDCHEST or 
        variant == PickupVariant.PICKUP_MIMICCHEST) then


            if (pickup.SubType == 1) then
                if (FindPathInPos(golem.Position, pickup.Position)) then
            
                    table.insert(tbl, pickup:ToPickup());
                end
            end
        end
    end
    return #tbl > 0;
end

local function UpdateTrickChestState(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local nearestDis = 100000;
    local nearest = nil;
    local nearestIndex = 0;
    for i, chest in pairs(data.TrickChestData.Chests) do 
        if (chest:Exists() and chest.SubType == 1) then
            if (chest.SubType == 1) then
                local dis = chest.Position:Distance(golem.Position);
                if (dis < nearestDis) then
                    nearestDis = dis;
                    nearest = chest;
                    nearestIndex = i;
                end
            end
        else
            table.remove(data.TrickChestData.Chests, i);
        end
    end
    if (nearest) then
        MoveToTarget(golem, nearest.Position)

        if (nearestDis <= 24 and nearest.SubType == 1) then
            nearest:TryOpenChest(golem.Player);
            table.remove(data.TrickChestData.Chests, nearestIndex);
            data.PathFindData.Cooldown = 0;
        end
    end
end


function IsaacGolem:postGolemInit(golem)
    golem:GetSprite():Play("Empty");
    golem.GridCollisionClass = 5;

end
IsaacGolem:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, IsaacGolem.postGolemInit, IsaacGolem.Variant);

function IsaacGolem:postGolemUpdate(golem)
    local data = IsaacGolem.GetGolemData(golem);
    data.CheckCooldown = data.CheckCooldown - 1;
    if (data.CheckCooldown <= 0) then
        CheckState(golem);
        data.CheckCooldown = maxCheckCooldown;

        if (data.State == 1) then
            data.AttackData.Target = IsaacGolem.FindAttackTarget(golem);
        end
    end


    if (data.State == 0) then
        -- Following State.
        UpdateFollowState(golem);
    elseif (data.State == 1) then
        -- Attack State.
    elseif (data.State == 2) then
        -- Pressure Plate State.
        UpdatePressurePlateState(golem);
    elseif (data.State == 3) then
        -- Trick Chest State.
        UpdateTrickChestState(golem);
    end
    FireCheck(golem);


    -- push other golems.
    for _, g in pairs(Isaac.FindByType(IsaacGolem.Type, IsaacGolem.Variant)) do
        if (g.InitSeed ~= golem.InitSeed) then
            local diff = g.Position - golem.Position;
            local distance = diff:Length();
            if (distance < 7) then
                g.Velocity = g.Velocity + math.min(7 - distance, 0.5) * diff:Normalized();
            end
        end
    end

    local dir = golem.Velocity:Normalized();
    local speed = golem.Velocity:Length();
    local friction = 1;
    if (speed > 0) then
        speed = speed - friction;
        if (speed < 0) then
            speed = 0;
        end
    elseif (speed < 0) then
        speed = speed + friction;
        if (speed > 0) then
            speed = 0;
        end
    end
    golem.Velocity = dir * speed;


    local walkDirString = "Down"
    local walkDirection = Math.GetDirectionByAngle(golem.Velocity:GetAngleDegrees());
    if (walkDirection == Direction.UP) then
        walkDirString = "Up";
    elseif (walkDirection == Direction.DOWN) then
        walkDirString = "Down";
    elseif (walkDirection == Direction.LEFT) then
        walkDirString = "Left";
    elseif (walkDirection == Direction.RIGHT) then
        walkDirString = "Right";
    end

    local bodyFrame = data.Sprites.Body.Frame;
    bodyFrame = (bodyFrame + 1) % 20;
    if (golem.Velocity:Length() <= 3) then
        walkDirString = "Down";
        bodyFrame = 1;
    end
    data.Sprites.Body.Frame = bodyFrame;
    data.Sprites.Body.Animation = "Walk"..walkDirString;

    if (golem.FireCooldown < 0) then
        data.Sprites.Head.Animation = "Shoot"..walkDirString;
    end
    if (golem.FireCooldown < 5) then
        data.Sprites.Head.Frame = 3;
    end

    if (data.Damage.Cooldown > 0) then
        data.Damage.Cooldown = data.Damage.Cooldown - 1;
        data.Damage.Invisible = not data.Damage.Invisible;
        if (data.Damage.Invisible) then
            golem:SetColor(Color(1,1,1,0,0,0,0), 2, 0, false, true);
        end
    else
        data.Damage.Invisible = false;
    end


    Familiars:DoFireCooldown(golem);

    data.PathFindData.Cooldown = data.PathFindData.Cooldown - 1;

    -- Push other golems.
    for _, ent in ipairs(Isaac.FindInRadius(golem.Position, 26, EntityPartition.FAMILIAR)) do
        if (ent.Variant == IsaacGolem.Variant) then
            local vector = ent.Position - golem.Position;
            local distance = vector:Length()
            local dot = vector:Normalized():Dot(ent.Velocity);
            local speed = math.max(0, math.min((26 - distance) / 10 - dot, 2));
            ent:AddVelocity(vector:Resized(speed));
        end
    end
end
IsaacGolem:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, IsaacGolem.postGolemUpdate, IsaacGolem.Variant);


function IsaacGolem:postGolemRender(golem, offset)
    local data = IsaacGolem.GetGolemData(golem);

    local sprite = golem:GetSprite();    
    local pos = Screen.GetEntityOffsetedRenderPosition(golem, offset);;
    sprite:SetFrame(data.Sprites.Body.Animation, data.Sprites.Body.Frame);
    sprite:SetOverlayFrame (data.Sprites.Head.Animation, data.Sprites.Head.Frame)
    sprite.Color = golem:GetColor();

    if (debugRender) then
        
        local targePos = Isaac.WorldToScreen(data.AttackData.TargetPos);
        Isaac.RenderText("Here!", targePos.X, targePos.Y, 1,1,1,1);
        Isaac.RenderText(data.State..", Chests: "..#data.TrickChestData.Chests, pos.X, pos.Y - 40, 1,1,1,1);

        if (data.PathFindData.Node) then
            local screen = Isaac.WorldToScreen(THI.Game:GetRoom():GetGridPosition(data.PathFindData.Node));
            Isaac.RenderText("Node", screen.X, screen.Y, 1,1,1,1);
        end

        if (data.PathFindData.Nodes) then
            for k, v in pairs(data.PathFindData.Nodes) do
                local screen = Isaac.WorldToScreen(THI.Game:GetRoom():GetGridPosition(v));
                Isaac.RenderText(k, screen.X, screen.Y, 1,1,1,1);
            end
        end
    end
end
IsaacGolem:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, IsaacGolem.postGolemRender, IsaacGolem.Variant);

return IsaacGolem;