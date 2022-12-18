local Inputs = CuerLib.Inputs;
local Math = CuerLib.Math;
local Gun = ModItem("Lunatic Gun", "LUNATIC_GUN")

local function GetPlayerData(player, create)
    return Gun:GetData(player, create, function()
        return {
            ShootTime = 0
        }
    end);
end

local function GetTearData(tear, create)
    return Gun:GetData(tear, create, function()
        return {
            OffsetVelocity = nil
        }
    end);
end

---@param position Vector @Cluster's spawn position.
---@param direction Vector @Cluster's fly direction.
---@param damage number @Cluster's tear damage.
---@param spawner Entity @Cluster's spawner entity.
function Gun:ShootCluster(position, direction, damage, spawner);
    damage = damage or 3.5;
    for i = 0, 7 do
        for time = 0, i do
            local half = i / 2;
            local offset = (-half + time) * 1;
            local speed = 20 - i ^ 2 / 5 + math.abs(time - half) ^ 2 / 10;
            local startVelocity = direction * speed + direction:Rotated(90) * offset;
            local targetVelocity = direction * 10;
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.CUPID_BLUE, 0, position, startVelocity, spawner):ToTear();
            tear.FallingAcceleration = -0.07;
            tear.CollisionDamage = damage;
            tear.Scale = Math.GetTearScaleByDamage(damage);
            tear.Scale = tear.Scale * 0.8;
            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING);
            tear.Mass = 0;
            local tearData = GetTearData(tear, true);
            tearData.OffsetVelocity = targetVelocity - startVelocity;
        end
    end
end

local function PostTearUpdate(mod ,tear)
    local tearData = GetTearData(tear, false);
    if (tearData) then
        local changedVelocity = tearData.OffsetVelocity / 10;
        tear.Velocity = tear.Velocity + changedVelocity;
        tearData.OffsetVelocity = tearData.OffsetVelocity - changedVelocity;
    end
end
Gun:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate)

local function PostPlayerEffect(mod, player)
    
    local num = player:GetCollectibleNum(Gun.Item);
    if (num > 0) then
        local shooting = Inputs.GetShootingVector(player);
        local data = GetPlayerData(player, true);
        if (player:CanShoot() and shooting:Length() > 0.1) then
            data.ShootTime = data.ShootTime + 1;
        else
            data.ShootTime = 0;
        end

        if (data.ShootTime >= 60 / num) then
            Gun:ShootCluster(player.Position, shooting, player.Damage * 0.2, player);
            data.ShootTime = 0;
        end
    end

end
Gun:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

return Gun;