local Inputs = CuerLib.Inputs;
local Math = CuerLib.Math;
local ASmallStone = ModCard("ASmallStone", "A_SMALL_STONE");

local function GetGlobalData(create)
    return ASmallStone:GetGlobalData(create, function()
        return {
            Times = 0
        }
    end);
end

function ASmallStone:GetUsedTimes()
    local data = GetGlobalData(false);
    return (data and data.Times) or 0;
end

function ASmallStone:SetUsedTimes(value)
    local data = GetGlobalData(true);
    data.Times = value;
end
function ASmallStone:AddUsedTimes(value)
    self:SetUsedTimes(self:GetUsedTimes() + value);
end


local function PostUseCard(mod, card, player, flags)
    local times = ASmallStone:GetUsedTimes();
    local vel = Vector(0, 10);
    local shooting = Inputs:GetShootingVector(player);
    if (shooting:Length() > 0.1) then
        vel = shooting:Resized(10);
    end
    vel = vel + player:GetTearMovementInheritance(vel);
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, player.Position, vel, player):ToTear();
    tear.CollisionDamage = times;
    tear.Scale = Math.GetTearScaleByDamage(tear.CollisionDamage);
    ASmallStone:SetUsedTimes(times + 1)


    if (flags & UseFlag.USE_MIMIC <= 0) then
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
        Isaac.Spawn(5, 300, ASmallStone.ID, pos, Vector.Zero, player);
    end 
    return {ShowAnim = false};
end
ASmallStone:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard, ASmallStone.ID);

return ASmallStone;