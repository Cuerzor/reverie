local DragonNeckJewel = ModItem("Dragon Neck Jewel", "DragonNeckJewel");
local TearColors = {
    Color(1,1,1,1,1,0,0),
    Color(1,1,1,1,1,1,0),
    Color(1,1,1,1,0,1,0),
    Color(1,1,1,1,0,1,1),
    Color(1,1,1,1,0,0,1),
}

local maxLightTime = 90;

function DragonNeckJewel.GetPlayerData(player, init)
    return DragonNeckJewel:GetData(player, init, function() return {
        FistOfHeavenCooldown = maxLightTime;
    } end);
end

function DragonNeckJewel:PostPlayerUpdate(player)
    local jewelCount = player:GetCollectibleNum(DragonNeckJewel.Item);
    if (jewelCount > 0) then
        local playerData = DragonNeckJewel.GetPlayerData(player, true);
        if (playerData) then
            playerData.FistOfHeavenCooldown = playerData.FistOfHeavenCooldown - 1;
            while (playerData.FistOfHeavenCooldown <= 0) do
                local nearestDis = 10000;
                local nearest = nil;
                for i, ent in pairs(Isaac.FindInRadius(player.Position, 240, EntityPartition.ENEMY)) do
                    if (ent:IsVulnerableEnemy ( ) and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        local dis = ent.Position:Distance(player.Position);
                        if (nearest == nil or dis < nearestDis) then
                            nearest = ent;
                            nearestDis = dis;
                        end
                    end
                end

                if (nearest) then
                    local bolt = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, nearest.Position, Vector.Zero, player);
                    
                    for i=1,5 do
                        local angle = i * 72 + (player.Position - nearest.Position):GetAngleDegrees() + 36;
                        local dir = Vector.FromAngle(angle);
                        local velocity = dir * 8;
                        local tearEnt = Isaac.Spawn(2, 0, 0, nearest.Position + dir * 20, velocity, player);
                        tearEnt:SetColor(TearColors[i], -1, 0, false, true);
                        tearEnt.CollisionDamage = player.Damage;
                    end
                    playerData.FistOfHeavenCooldown = playerData.FistOfHeavenCooldown + maxLightTime / jewelCount;
                    
                else
                    playerData.FistOfHeavenCooldown = maxLightTime / jewelCount;
                end
            end
        end
    end
end
DragonNeckJewel:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DragonNeckJewel.PostPlayerUpdate);

return DragonNeckJewel;