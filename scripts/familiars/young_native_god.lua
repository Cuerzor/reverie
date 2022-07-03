local Snake = ModEntity("Young Native God", "YOUNG_NATIVE_GOD");

Snake.States = {
    IDLE = 0,
    CHASE = 1,
    ATTACK = 2,
    CHASE_ROCK = 3,
    DESTROY = 4
}

local function GetSnakeData(snake, create)
    return Snake:GetData(snake, create, function()
        return {
            Pile = nil,
            LastPilePosition = Vector.Zero,
            PathFind = {
                --Nodes = nil,
                Node = nil
            }
        }
    end)
end


local function SpawnPile(snake)
    local data = GetSnakeData(snake, true);
    data.Pile = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PILE, 0, snake.Position, Vector.Zero, snake):ToEffect();
    data.LastPilePosition = data.Pile.Position;
end

function Snake:GetBitePosition(snake)
    local bitePosition = snake.Position;
    local offset = Vector(32,0);
    if (snake:GetSprite().FlipX) then
        offset.X = -offset.X;
    end
    bitePosition = bitePosition + offset;
    return bitePosition;
end

local destructibleGrids = {
    GridEntityType.GRID_POOP,
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_ALT2,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
    GridEntityType.GRID_ROCKT,
    GridEntityType.GRID_TNT,
}

local function CanDestroyGridType(type)
    for _, t in ipairs(destructibleGrids) do
        if (type == t) then
            return true;
        end
    end
    return false;
end

local pathFindingParams = {
    PassCheck = function(index)
        local room = Game():GetRoom();
        local gridEnt = room:GetGridEntity(index);
        if (not gridEnt) then
            return true;
        else
            if (gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
                return true;
            end

            local gridType = gridEnt:GetType();
            if (CanDestroyGridType(gridType)) then
                return true;
            end
        end
        return room:GetGridPath(index) < 1000;
    end
}

local function FindPath(entIndex, targetIndex)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPath(entIndex, targetIndex, pathFindingParams);
end

local function FindPathInPos(entPos, targetPos)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPathInPos(entPos, targetPos, pathFindingParams);
end

local function MoveToTarget(snake, targetPos, minDistance)
    
    minDistance = minDistance or 0;
    local data = GetSnakeData(snake);
    local room = Game():GetRoom();
    local target = targetPos;
    local canWalk, newPos = room:CheckLine(snake.Position, target, 1, 0, false, true);
    -- If cannot directly walk to the target.
    if (not canWalk) then
        
        local targetIndex = room:GetGridIndex(target);
        -- Search Path.
        local currentIndex = room:GetGridIndex(snake.Position);
        if (snake:IsFrame(7, 0)) then
            local nodes = FindPath(currentIndex, targetIndex);
            --data.PathFind.Nodes = nodes
            local node = nil;
            if (nodes) then
                local num = #nodes;
                node =  nodes[num - 2] or nodes[num - 1] or nodes[num];
            end
            data.PathFind.Node = node;
        end

        if (data.PathFind.Node) then
            target = room:GetGridPosition(data.PathFind.Node);
        else
            -- Path is blocked.
            return false;
        end
    end

    local moveDir = (target - snake.Position):Normalized();
    local maxSpeed = 8;
    local speedMultiplier = 1;
    local dot = snake.Velocity:Dot(moveDir);
    local moveSpeed = math.max(0, math.min(maxSpeed - dot, ((targetPos - snake.Position):Length() - minDistance) * speedMultiplier));
    snake:AddVelocity(moveDir * moveSpeed);
    return true;
end

-- Change Snake's State.
local function CheckState(snake)
    local room = Game():GetRoom();
    local nearestEnemy = nil;
    local nearestDistance = 0;
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        local distance = snake.Position:Distance(ent.Position)
        if (not nearestEnemy or distance < nearestDistance) then
            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                if (room:CheckLine(snake.Position, ent.Position, 1, 0, false, true) or FindPathInPos(snake.Position, ent.Position)) then
                    nearestEnemy = ent;
                    nearestDistance = distance;
                end
            end
        end
    end
    if (nearestEnemy) then
        snake.Target = nearestEnemy;
        return Snake.States.CHASE;
    end

    local nearestPosition = nil;
    local nearestDistance = 0;
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    for x = 0, width do
        for y = 0, height do
            local index = y * width + x;
            local gridPos = room:GetGridPosition(index);
            local distance = gridPos:Distance(snake.Position);
            if (not nearestPosition or distance < nearestDistance) then
                local gridEnt = room:GetGridEntity(index);
                if (gridEnt) then
                    local gridType = gridEnt:GetType();
                    if (((gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_SS) and gridEnt.State == 1) 
                    or (index == room:GetDungeonRockIdx () and CanDestroyGridType(gridType))) then
                        if (room:CheckLine(snake.Position, gridPos, 1, 0, false, true) or FindPathInPos(snake.Position, gridPos)) then
                            nearestPosition = gridPos;
                            nearestDistance = distance;
                        end
                    end
                end
            end
        end
    end
    if (nearestPosition) then
        snake.TargetPosition = nearestPosition;
        return Snake.States.CHASE_ROCK;
    end

    return Snake.States.IDLE;
end

-- Update Snake based on its state.
local function UpdateState(snake, state)
    local room = Game():GetRoom();
    local spr = snake:GetSprite();
    if (state == Snake.States.IDLE) then -- Follow player.
        spr:Play("Hide");
        local player = snake.Player;
        if (player) then
            MoveToTarget(snake, player.Position, 40)
        end
        if (snake:IsFrame(7, 0)) then
            snake.State = CheckState(snake);
        end

    elseif (state == Snake.States.CHASE) then -- Chase.
        local target = snake.Target;
        local targetValid = target and not target:IsDead() and target:Exists();
        if (targetValid) then
            local targetPosition = target.Position + target.Velocity * 25;
            local enemyAtLeft = targetPosition.X < snake.Position.X;
            local moveTarget = targetPosition;
            if (enemyAtLeft) then
                moveTarget = moveTarget + Vector(20, 0);
            else
                moveTarget = moveTarget - Vector(20, 0);
            end
            moveTarget = room:GetClampedPosition (moveTarget, snake.Size);
            MoveToTarget(snake, moveTarget, 0)
            
            if (snake.Position:Distance(moveTarget) <= 32) then
                spr.FlipX = enemyAtLeft;
                snake.State = Snake.States.ATTACK;
                SpawnPile(snake)
            end
        end
        if (not targetValid or snake:IsFrame(7, 0)) then
            snake.State = CheckState(snake);
        end

    elseif (state == Snake.States.ATTACK) then -- Attack.
        spr:Play("Bite");
        snake.Velocity = Vector.Zero;

        if (spr:IsEventTriggered("Hiss")) then
            THI.SFXManager:Play(SoundEffect.SOUND_BOSS_LITE_HISS);
        end

        if (spr:IsEventTriggered("Bite")) then
            local playSound = false;
            local bitePosition = Snake:GetBitePosition(snake);
            for _, ent in ipairs(Isaac.FindInRadius(bitePosition, 32, EntityPartition.ENEMY)) do
                if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    local damage = 35;
                    -- if (snake.Player) then
                    --     damage = snake.Player.Damage * 10;
                    -- end

                    -- BFFs Synergy.
                    if (snake.Player and snake.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                        damage = damage * 2;
                    end

                    -- Onbashira Synergy.
                    local Onbashira = THI.Effects.Onbashira;
                    for _, onbashira in ipairs(Isaac.FindByType(Onbashira.Type, Onbashira.Variant)) do
                        if (Onbashira:IsInRange(onbashira, snake.Position)) then
                            damage = damage * 3;
                            break;
                        end
                    end

                    ent:TakeDamage(damage, 0, EntityRef(snake), 0);
                    ent:AddPoison(EntityRef(snake), 180, damage / 3);
                    playSound = true;
                end
            end
            if (playSound) then
                THI.SFXManager:Play(SoundEffect.SOUND_MEATY_DEATHS);
            end
        end


        if (spr:IsFinished("Bite")) then
            snake.TargetPosition = Vector.Zero;
            snake.State = Snake.States.IDLE;
            spr.FlipX = false;
        end

    -- Chase Rock.
    elseif (state == Snake.States.CHASE_ROCK) then 
        local targetPos = snake.TargetPosition;
        local gridEnt = room:GetGridEntityFromPos(targetPos);
        local targetValid = gridEnt;
        if (targetValid) then
            
            MoveToTarget(snake, targetPos, 0)
            
            if (snake.Position:Distance(targetPos) <= 20) then
                spr.FlipX = false;
                snake.State = Snake.States.DESTROY;
                SpawnPile(snake)
            end
        end
        if (not targetValid) then
            snake.State = CheckState(snake);
        end

    -- Destroy Rock.   
    elseif (state == Snake.States.DESTROY) then 
        spr:Play("Destroy");
        snake.Velocity = Vector.Zero;
        if (spr:IsFinished("Destroy")) then
            snake.TargetPosition = Vector.Zero;
            snake.State = Snake.States.IDLE;
        end
    end
end


local function PostSnakeInit(mod, snake)
    snake.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS;
end
Snake:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostSnakeInit, Snake.Variant)

local function PostSnakeUpdate(mod, snake)

    for _, ent in ipairs(Isaac.FindInRadius(snake.Position, snake.Size, EntityPartition.FAMILIAR)) do
        if (ent.Variant == Snake.Variant and ent.Velocity:Length() < snake.Size) then
            snake:AddVelocity(snake.Position - ent.Position);
            break;
        end
    end
    UpdateState(snake, snake.State);

    local data = GetSnakeData(snake, true);

    -- Update Piles.
    if (not data.Pile or data.LastPilePosition:Distance(snake.Position) > 20) then
        SpawnPile(snake);
    end

    if (data.Pile) then
        local pile = data.Pile;
        pile.DepthOffset = 5;
        pile.Timeout = 30;
    end

    -- Destroy Rocks
    local room = Game():GetRoom();
    for i = 1, 8 do
        local angle = i * 45;
        local pos = snake.Position + Vector.FromAngle(angle) * snake.Size;
        local gridEnt = room:GetGridEntityFromPos(pos);
        if (gridEnt) then
            if (CanDestroyGridType(gridEnt:GetType())) then
                gridEnt:Destroy(false);
            end
        end
    end



    snake:MultiplyFriction(0.9);
    
end
Snake:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostSnakeUpdate, Snake.Variant)

local function PostNewRoom(mod)
    for _, ent in ipairs(Isaac.FindByType(Snake.Type, Snake.Variant)) do
        local snake = ent:ToFamiliar();
        snake.State = Snake.States.IDLE;
    end
end
Snake:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


local debugRender = false;
if (debugRender) then
        
    local function PostSnakeRender(mod, snake, offset)
        if (snake.Target) then
            
            local targePos = Isaac.WorldToScreen(snake.Target.Position);
            Isaac.RenderText("Here!", targePos.X, targePos.Y, 1,1,1,1);
        end
        local data = GetSnakeData(snake, false)
        if (data) then
            local room = Game():GetRoom();
            if (data.PathFind.Node) then
                local screen = Isaac.WorldToScreen(room:GetGridPosition(data.PathFind.Node));
                Isaac.RenderText("Node", screen.X, screen.Y, 1,1,1,1);
            end

            -- if (data.PathFind.Nodes) then
            --     for k, v in pairs(data.PathFind.Nodes) do
            --         local screen = Isaac.WorldToScreen(room:GetGridPosition(v));
            --         Isaac.RenderText(k, screen.X, screen.Y, 1,1,1,1);
            --     end
            -- end
        end
    end
    Snake:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, PostSnakeRender, Snake.Variant);
end

return Snake;