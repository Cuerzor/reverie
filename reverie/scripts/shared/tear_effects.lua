local Effects = ModPart("TearEffects", "TEAR_EFFECTS");

local function GetTearData(tear, create)
    return Effects:GetData(tear, create, function() return {
        Rain = false;
    } end);
end

function Effects:SetTearRain(tear, value)
    local tearData = GetTearData(tear, true);
    tearData.Rain = value;
end

function Effects:IsTearRain(tear)
    local tearData = GetTearData(tear, false);
    return (tearData and tearData.Rain);
end


local function PreTearCollision(mod, tear, other, low)
    if (Effects:IsTearRain(tear)) then
        if (other.Type == EntityType.ENTITY_BOMBDROP) then
            return true;
        else
            if (-tear.Height > other.Size) then
                return true;
            end
        end
    end
end
Effects:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, PreTearCollision);

return Effects;
