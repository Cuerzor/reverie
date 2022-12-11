local Entities = LIB:NewClass();

function Entities.IsValidEnemy(entity, includeNoTarget)
    local valid =  entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
    if (not includeNoTarget) then
        valid = valid and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET);
    end
    return valid;
end


function Entities.CompareEntity(a, b)
    if (a and b) then
        return GetPtrHash(a) == GetPtrHash(b);
    end
    return false;
end

function Entities.EntityExists(ent)
    return ent and ent:Exists();
end

function Entities.IsFinalBoss(ent)
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
    function Entities.CheckCollision(ent1, ent2)
        return Entities.CheckCollisionInfo(ent1.Position, ent1.Size, ent1.SizeMulti, ent2.Position, ent2.Size, ent2.SizeMulti);
    end

    function Entities.CheckCollisionInfo(pos1, size1, sizeMulti1, pos2, size2, sizeMulti2)
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

return Entities;