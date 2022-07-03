local Lib = _TEMP_CUERLIB;

local Detection = Lib:NewClass();

function Detection.IsValidEnemy(entity, includeNoTarget)
    local valid =  entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
    if (not includeNoTarget) then
        valid = valid and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET);
    end
    return valid;
end


function Detection.CompareEntity(a, b)
    if (a and b) then
        return GetPtrHash(a) == GetPtrHash(b);
    end
    return false;
end

function Detection.EntityExists(ent)
    return ent and ent:Exists();
end

function Detection.IsFinalBoss(ent)
    return ent.Type == EntityType.ENTITY_MOM or 
    ent.Type == EntityType.ENTITY_MOMS_HEART or 
    ent.Type == EntityType.ENTITY_ISAAC or
    ent.Type == EntityType.ENTITY_SATAN or
    ent.Type == EntityType.ENTITY_THE_LAMB or
    ent.Type == EntityType.ENTITY_MEGA_SATAN or
    ent.Type == EntityType.ENTITY_MEGA_SATAN_2 or
    ent.Type == EntityType.ENTITY_HUSH or
    ent.Type == EntityType.ENTITY_DELIRIUM or
    ent.Type == EntityType.ENTITY_MOTHER or
    ent.Type == EntityType.ENTITY_MOTHERS_SHADOW or
    ent.Type == EntityType.ENTITY_ULTRA_GREED or
    ent.Type == EntityType.ENTITY_DOGMA or
    ent.Type == EntityType.ENTITY_BEAST;
    
end

function Detection.IsActivePlayer(player)
    if (player:IsCoopGhost ( )) then
        return false;
    end

    if (player.Variant ~= 0) then
        return false;
    end
    return true;
end

function Detection.PlayerPairs(includePlayer, includeBaby)
    if (includePlayer == nil) then
        includePlayer = true;
    end
    
    if (includeBaby == nil) then
        includeBaby = false;
    end

    local game = Game();
    local num = game:GetNumPlayers();
    local p = 0;
    local indexList = {};
    local function iter()
        while (p < num) do
            local player = game:GetPlayer(p);
            p = p + 1;
            local variant = player.Variant;
            if ((includePlayer and variant == 0) or (includeBaby and variant == 1)) then
                local curIndex = indexList[variant] or 0;
                indexList[variant] = curIndex + 1;
                return curIndex + variant * 16, player;
            end
        end
        return nil;
    end
    return iter, nil, nil;
end


do
    local function CheckCapsuleCollide(startA, endA, axeA, verticalA, radiusA, startB, endB, axeB, verticalB, radiusB)

        local radiusSum = radiusA + radiusB;
        local lessA = math.min(startA, endA);
        local largerA = math.max(startA, endA);
        local lessB = math.min(startB, endB);
        local largerB = math.max(startB, endB);
        if (verticalA == verticalB) then
            -- 如果两条线轴之间的距离小于距离之和
            local axeDiff = math.abs(axeA - axeB);
            if (axeDiff < radiusSum) then
                -- 找出最近的两点。
                if (largerA <= lessB) then
                    -- A is fully less than B.
                    local xDiff = lessB - largerA;
                    return (xDiff ^ 2 + axeDiff ^ 2) ^ 0.5 < radiusSum;
                elseif (lessA > largerB) then
                    -- A is fully larger than B.
                    local xDiff = lessA - largerB;
                    return (xDiff ^ 2 + axeDiff ^ 2) ^ 0.5 < radiusSum;
                end
                return true;
            end
        else
            local startAToB = axeB - startA;
            local endAToB = axeB - endA;

            local startBToA = axeA - startB;
            local endBToA = axeA - endB;
            if (startBToA * endBToA <= 0) then
                -- Axe A is between Start B and End B.
                if (startAToB * endAToB <= 0) then
                    -- Intersect.
                    return true;
                else
                    -- Line A is between Start B and End B, but doesn't intersect.
                    return math.min(math.abs(startAToB), math.abs(endAToB)) < radiusSum;
                end
            else
                -- Axe A is out of Start B and End B.
                if (startAToB * endAToB <= 0) then
                    -- Line B is between Start A and End A, but doesn't intersect.
                    return math.min(math.abs(startBToA), math.abs(endBToA)) < radiusSum;
                else
                    -- Line A and Line B are out of each other.
                    local AToB = math.min(math.abs(startAToB), math.abs(endAToB));
                    local BToA = math.min(math.abs(startBToA), math.abs(endBToA));
                    return (AToB ^ 2 + BToA ^ 2) ^ 0.5 < radiusSum;
                end
            end

            return false;
        end

        return false;
    end

    local function GetEntityCollideInfo(pos, size, sizeMulti)
        
        local start;
        local lineEnd;
        local axe;
        local radius;
        local vertical;
        if (sizeMulti.Y > sizeMulti.X) then
            vertical = true;
            local size = size * sizeMulti.Y;
            radius = size * sizeMulti.X;
            start = pos.Y - size + radius;
            lineEnd = pos.Y + size - radius;
            axe = pos.X;
        else
            vertical = false;
            local size = size * sizeMulti.X;
            radius = size * sizeMulti.Y;
            start = pos.X - size + radius;
            lineEnd = pos.X + size - radius;
            axe = pos.Y;
        end
        return start, lineEnd, axe, radius, vertical;
    end
    function Detection.CheckCollision(ent1, ent2)
        return Detection.CheckCollisionInfo(ent1.Position, ent1.Size, ent1.SizeMulti, ent2.Position, ent2.Size, ent2.SizeMulti);
    end

    function Detection.CheckCollisionInfo(pos1, size1, sizeMulti1, pos2, size2, sizeMulti2)
        if (pos1:Distance(pos2) > size1 + size2) then
            return false;
        end

        if (math.abs(sizeMulti1.X - sizeMulti1.Y) <= 0.01 and math.abs(sizeMulti2.X - sizeMulti2.Y) <= 0.01) then
            return true;
        end

        local startA, endA, axeA, radiusA, verticalA = GetEntityCollideInfo(pos1, size1, sizeMulti1);
        local startB, endB, axeB, radiusB, verticalB = GetEntityCollideInfo(pos2, size2, sizeMulti2);
        return CheckCapsuleCollide(startA, endA, axeA, verticalA, radiusA, startB, endB, axeB, verticalB, radiusB);
    end
end

-- PrePlayerCollision is broken, alternate method.
local function ExecutePrePlayerCollision(mod, player, collider, low)
    local Callbacks = Lib.Callbacks;
    for i, info in pairs(Callbacks.Functions.PrePlayerCollision) do
        if (info.OptionalArg == nil or info.OptionalArg == player.Variant) then
            local result = info.Func(mod, player, collider, low);
            if (result == true) then
                return true;
            elseif (result ~= nil) then
                return false;
            end
        end
    end

    for i, info in pairs(Callbacks.Functions.PostPlayerCollision) do
        info.Func(mod, player, collider, low);
    end
end
Detection:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, ExecutePrePlayerCollision);


return Detection;