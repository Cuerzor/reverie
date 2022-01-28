local Detection = CuerLib.Detection;
local Familiars = CuerLib.Familiars;
local Math = CuerLib.Math;
local Screen = CuerLib.Screen;

local IsaacGolem = ModEntity("Isaac Golem", "IsaacGolem")

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
            AttackDirection = 0
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

----------------
-- Path Finding
----------------

local openGrids = {};
local closedGrids = {};
local gridSize = 40;


local function GetGridEsicost(index, targetIndex)
    local room = THI.Game:GetRoom();
    -- local width = room:GetGridWidth();
    -- local targetX = targetIndex % width;
    -- local targetY = math.ceil(targetIndex / width);
    -- local indexX = index % width;
    -- local indexY = math.ceil(index / width);
    -- return math.abs(targetX-indexX) + math.abs(targetY - indexY);
    return (room:GetGridPosition(targetIndex) - room:GetGridPosition(index)):Length() / gridSize;
end
local function GetLowestCostGrid()
    local cur = openGrids[1];
    local index = 1;
    for i = #openGrids, 1, -1 do
        local grid = openGrids[i];
        if (grid.Cost < cur.Cost) then
            cur = grid;
            index = i;
        end
    end
    return index, cur;
end
local function IsIndexOpen(index)
    for _, i in pairs(openGrids) do
        if (i.Index == index) then
            return true, i;
        end
    end
    return false;
end
local function IsIndexClosed(index)
    for _, i in pairs(closedGrids) do
        if (i == index) then
            return true;
        end
    end
    return false;
end
local function GetAdjacent(index, dir)
    local width = THI.Game:GetRoom():GetGridWidth();
    if (dir == Direction.UP) then
        return index - width;
    elseif (dir == Direction.DOWN) then
        return index + width;
    elseif (dir == Direction.LEFT) then
        return index - 1;
    elseif (dir == Direction.RIGHT) then
        return index + 1;
    elseif (dir == 4) then
        return index - width - 1;
    elseif (dir == 5) then
        return index - width + 1;
    elseif (dir == 6) then
        return index + width - 1;
    elseif (dir == 7) then
        return index + width + 1;
    end
    return nil;
end

local function CanPass(index)
    local room = THI.Game:GetRoom();
    local gridEnt = room:GetGridEntity(index);
    if (not gridEnt or gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
        return true;
    end
    return room:GetGridPath(index) < 900;
end
local function FindPath(golemIndex, targetIndex)
    local room = THI.Game:GetRoom();
    local width = room:GetGridWidth();

    if (not CanPass(targetIndex)) then
        return nil, nil;
    end

    -- Clear open and closed list.
    for i = #openGrids, 1, -1 do
        table.remove(openGrids, i);
    end
    for i = #closedGrids, 1, -1 do
        table.remove(closedGrids, i);
    end

    -- Add current grid to open.
    table.insert(openGrids, 
        { 
            Index = golemIndex, 
            StartCost = 0, 
            Cost = 0,
            Parent = nil
        }
    );

    local current;
    while (#openGrids > 0) do
        local listIndex;
        listIndex, current = GetLowestCostGrid();
        table.remove(openGrids, listIndex);
        table.insert(closedGrids, current.Index);

        if (current.Index == targetIndex) then
            -- Found path.
            local results = {};
            local lastOne = nil;
            local thridLastOne = nil;
            while (current.Parent) do
                thridLastOne = lastOne;
                lastOne = current.Index;
                table.insert(results, current.Parent.Index);
                current = current.Parent;
            end
            local result = thridLastOne or lastOne or current.Index;
            return result, results;
        end

        for i = 0, 3 do 
            local adjacentIndex = GetAdjacent(current.Index, i);
            if (CanPass(adjacentIndex) and not IsIndexClosed(adjacentIndex)) then
                local isOpen, gridInfo = IsIndexOpen(adjacentIndex);
                if (not isOpen) then
                    local adj = {};
                    adj.Index = adjacentIndex;
                    adj.StartCost = current.StartCost + 1;--room:GetGridPosition(adjacentIndex):Distance(room:GetGridPosition(golemIndex)) / gridSize;
                    adj.Cost = adj.StartCost + GetGridEsicost(adjacentIndex, targetIndex);
                    adj.Parent = current;
                    table.insert(openGrids, adj);
                else
                    local newStartCost = current.StartCost + 1;--room:GetGridPosition(adjacentIndex):Distance(room:GetGridPosition(golemIndex)) / gridSize;
                    if (newStartCost < gridInfo.StartCost) then
                        gridInfo.StartCost = newStartCost;
                        gridInfo.Cost = gridInfo.Cost - gridInfo.StartCost + newStartCost;
                        gridInfo.Parent = current;
                    end
                end
            end
        end
    end
end
local function FindPathInPos(golemPos, targetPos)
    local room = THI.Game:GetRoom();
    return FindPath(room:GetGridIndex(golemPos), room:GetGridIndex(targetPos));
end


local function MoveToTarget(golem, moveTarget, maxCooldown, targetDistance)
    maxCooldown = maxCooldown or maxPathFindCooldown;
    targetDistance = targetDistance or 0;
    local data = IsaacGolem.GetGolemData(golem);
    local room = THI.Game:GetRoom();
    local target = moveTarget;
    local canWalk, newPos = room:CheckLine(golem.Position, target, 0);
    -- If cannot directly walk to the target.
    if (not canWalk) then
        
        local targetIndex = room:GetGridIndex(target);
        -- Search Path.
        local currentIndex = room:GetGridIndex(golem.Position);
        if (
        data.PathFindData.Cooldown <= 0) then
            data.PathFindData.Cooldown = maxCooldown;
            data.PathFindData.Node, data.PathFindData.Nodes = FindPath(currentIndex, targetIndex);
        end

        if (data.PathFindData.Node) then
            target = room:GetGridPosition(data.PathFindData.Node);
        else
            -- Path is blocked.
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
    if (not noObstacles) then
        -- Avoid too close to target if target has collision Damage.
        if (target.CollisionDamage > 0) then
            if (newPos:Distance(target.Position) <= 30) then
                return false, newPos;
            end
        end
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

                    -- Get Stand Direction.
                    local direction = Direction.NO_DIRECTION;
                    if (math.abs(targetToGolem.X) > math.abs(targetToGolem.Y)) then
                        if (targetToGolem.X > 0) then
                            direction = Direction.LEFT;
                        else
                            direction = Direction.RIGHT;
                        end
                    else
                        if (targetToGolem.Y > 0) then
                            direction = Direction.UP;
                        else
                            direction = Direction.DOWN;
                        end
                    end

                    -- Check whether if golem can on this direction.
                    local canStandInDirection, newStandPos = CheckAttackDirectionValid(golem, npc, direction);
                    if (not canStandInDirection) then
                        -- Try other 3 directions.
                        for dir = 0, 3 do
                            if (direction ~= dir) then
                                canStandInDirection, newStandPos = CheckAttackDirectionValid(golem, npc, dir);
                                if (canStandInDirection) then
                                    goto checkTarget;
                                end
                            end
                        end
                    end

                    -- if Can stand in the shooting direction.
                    ::checkTarget::
                    if (canStandInDirection) then
                        target = npc;
                        maxWeight = weight;
                        standPos = newStandPos;
                        targetDir = direction;
                    end
                end
            end
        end
    end
    
    return target, standPos, targetDir;
end

local function UpdateAttackState(golem)
    local data = IsaacGolem.GetGolemData(golem);
    local room = THI.Game:GetRoom();

    if (not (data.AttackData.Target and data.AttackData.Target:Exists())) then
        data.AttackData.Target, data.AttackData.TargetPos, data.AttackData.AttackDirection = IsaacGolem.FindAttackTarget(golem);
    end

    local target = data.AttackData.Target;
    if (target) then
        local standPos = data.AttackData.TargetPos;
        MoveToTarget(golem, standPos);

        local canSeeTarget, blockedPos = room:CheckLine(target.Position, golem.Position, 2);
        if (canSeeTarget and golem.Position:Distance(target.Position) < maxRange) then
            
            local direction = data.AttackData.AttackDirection;
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
        UpdateAttackState(golem);
    elseif (data.State == 2) then
        -- Pressure Plate State.
        UpdatePressurePlateState(golem);
    elseif (data.State == 3) then
        -- Trick Chest State.
        UpdateTrickChestState(golem);
    end


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

    if (golem.FireCooldown <= 0) then
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
end
IsaacGolem:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, IsaacGolem.postGolemUpdate, IsaacGolem.Variant);

function IsaacGolem:postGolemRender(golem, offset)
    local data = IsaacGolem.GetGolemData(golem);

    


    local sprite = golem:GetSprite();    
    local pos = Screen.GetEntityOffsetedRenderPosition(golem, offset);;
    sprite:SetFrame(data.Sprites.Body.Animation, data.Sprites.Body.Frame);
    sprite:SetOverlayFrame (data.Sprites.Head.Animation, data.Sprites.Head.Frame)
    sprite.Color = golem:GetColor();

    --local targePos = Isaac.WorldToScreen(data.AttackData.TargetPos);
    --Isaac.RenderText("Here!", targePos.X, targePos.Y, 1,1,1,1);
    --Isaac.RenderText(data.State..", Chests: "..#data.TrickChestData.Chests, pos.X, pos.Y - 40, 1,1,1,1);

    -- if (data.PathFindData.Node) then
    --     local screen = Isaac.WorldToScreen(THI.Game:GetRoom():GetGridPosition(data.PathFindData.Node));
    --     Isaac.RenderText("Node", screen.X, screen.Y, 1,1,1,1);
    -- end

    -- if (data.PathFindData.Nodes) then
    --     for k, v in pairs(data.PathFindData.Nodes) do
    --         local screen = Isaac.WorldToScreen(THI.Game:GetRoom():GetGridPosition(v));
    --         Isaac.RenderText(k, screen.X, screen.Y, 1,1,1,1);
    --     end
    -- end
end
IsaacGolem:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, IsaacGolem.postGolemRender, IsaacGolem.Variant);

return IsaacGolem;