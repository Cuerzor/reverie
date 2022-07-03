local Math = _TEMP_CUERLIB:NewClass();

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
    local includedAngle = angle2 - angle1;
    includedAngle = includedAngle % 360
    if (includedAngle > 180) then
        includedAngle = includedAngle - 360;
    end 
    return includedAngle;
end

function Math.GetTearFlag(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end


function Math:HSVToRGB(h,s,v)
    local R, G, B = 0,0,0;
    if (s == 0) then
        R,G,B=v,v,v;
    else
        h = h / 60;
        local i = math.floor(h);
        local f = h - i;
        local a = v * ( 1 - s );
        local b = v * ( 1 - s * f );
        local c = v * ( 1 - s * (1 - f ) );
        if (i == 0) then
            R = v; G = c; B = a;
        elseif (i == 1) then
            R = b; G = v; B = a;
        elseif (i == 2) then
            R = a; G = v; B = c;
        elseif (i == 3) then
            R = a; G = b; B = v;
        elseif (i == 4) then
            R = c; G = a; B = v;
        elseif (i == 5) then
            R = v; G = a; B = b;
        end
    end
    return R,G,B
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