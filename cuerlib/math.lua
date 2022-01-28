local Math = {

}

function Math.GetDirectionByAngle(angle)
    angle = angle % 360;
    local dir = Direction.NO_DIRECTION;
    if (math.abs(angle - 0) < 45 or math.abs(angle - 360) < 45) then
        dir = Direction.RIGHT;
    elseif (math.abs(angle - 270) < 45) then
        dir = Direction.UP;
    elseif (math.abs(angle - 180) < 45) then
        dir = Direction.LEFT;
    elseif (math.abs(angle - 90) < 45) then
        dir = Direction.DOWN;
    end
    return dir;
end

function Math.GetTearScaleByDamage(damage)
    return damage ^ 0.5 * 0.23 + damage * 0.01 + 0.55;
end

function Math.RandomRange(rng, min, max)
    return rng:RandomFloat() * (max - min) + min;
end

-- Only Works if Falling Acceleration is smaller than 0.
function Math.GetTearHeightPositionOffset(height)
    if (height > -8.5) then
        return height ^ 2 + 17.4 * height + 57.25
    end
    return 0.4 * height - 15;
end

-- Only Works if Falling Acceleration is smaller than 0.
function Math.GetTearPositionOffsetHeight(offset)
    if (offset > -18.4) then
        return (x+18.44)^0.5-8.7;
    end
    return offset / 0.4 + 37.25;
end

function Math.Sign(x)
    if (x > 0) then
        return 1
    elseif (x < 0) then
        return -1;
    end
    return 0;
end

function Math.LerpVector(vec1, vec2, percent)
    return vec1 * (1 - percent) + vec2 * percent
end

function Math.GetIncludedAngle(vec1, vec2)
    local angle1 = vec1:GetAngleDegrees();
    local angle2 = vec2:GetAngleDegrees();
    return Math.GetAngleDiff(angle1, angle2);
end

function Math.GetAngleDiff(angle1, angle2)
    
    local diff = angle2 - angle1;
    if (diff > 0) then
        if (math.abs(diff) <= math.abs(diff - 360)) then
            return diff;
        else
            return diff - 360;
        end
    else
        if (math.abs(diff) <= math.abs(diff + 360)) then
            return diff;
        else
            return diff + 360;
        end
    end
    return diff;
end

function Math.GetTearFlag(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end






function Math.EaseIn(value)
    return value * value;
end
function Math.EaseOut(value)
    local x = value - 1;
    return 1 - x * x;
end
function Math.EaseInAndOut(value)
    if (value <= 0.5) then
        return Math.EaseIn(value * 2) / 2;
    else
        return Math.EaseOut((value - 0.5) * 2) / 2 + 0.5;
    end
end

return Math;