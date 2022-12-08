local Entities = CuerLib.Entities;
local Math = CuerLib.Math;

local RobeFire = ModEntity("Robe Fire", "RobeFire");

function RobeFire.GetRobeFireData(familiar, init)
    return RobeFire:GetData(familiar, init, function() return {
        Inited = false
    } end)
end

-- function RobeFire:PostRobeFireInit(robeFire)
--     robeFire:AddToOrbit(2);
--     robeFire.Size = robeFire.Size / 2;
-- end
-- RobeFire:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, RobeFire.PostRobeFireInit, RobeFire.Variant);

function RobeFire:PostRobeFireUpdate(robeFire)
    local data = RobeFire.GetRobeFireData(robeFire, true);
    if (not data.Inited) then
        robeFire:AddToOrbit(2);
        data.Inited = true;
    end
    
    local spr = robeFire:GetSprite();
    spr.Scale = Vector(0.5, 0.5);
    robeFire.Velocity = (robeFire:GetOrbitPosition(robeFire.Player.Position + robeFire.Player.Velocity) - robeFire.Position ) /3;

    local robe = THI.Collectibles.RobeOfFirerat;
    for _, ent in pairs(Isaac.FindInRadius(robeFire.Position, robeFire.Size, EntityPartition.TEAR)) do
        local tear = ent:ToTear()
        if (tear) then
            robe.MakeFire(tear);
        end
    end
end
RobeFire:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, RobeFire.PostRobeFireUpdate, RobeFire.Variant);


function RobeFire:PreRobeFireCollision(fire, other, low)
    if (Entities.IsValidEnemy(other)) then
        other:TakeDamage(10, DamageFlag.DAMAGE_FIRE, EntityRef(fire), 0);
    end
end
RobeFire:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, RobeFire.PreRobeFireCollision, RobeFire.Variant);
return RobeFire;
