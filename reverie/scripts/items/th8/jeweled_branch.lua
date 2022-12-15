local Inputs = CuerLib.Inputs;
local Players = CuerLib.Players;
local JeweledBranch = ModItem("Jeweled Branch", "JeweledBranch");
JeweledBranch.RemoveMode = true;
JeweledBranch.rng = RNG();
JeweledBranch.Colors = {
    Color(1,1,1,1,1,0,0),
    Color(1,1,1,1,1,1,0),
    Color(1,1,1,1,0,1,0),
    Color(1,1,1,1,0,1,1),
    Color(1,1,1,1,0,0,1),
};

local maxBullets = 5;

function JeweledBranch.GetPlayerData(player, init)
    return JeweledBranch:GetData(player, init, function() return {
        Bullets = {},
        Angle = 0,
        FireDelay = 0,
        Index = 1,
        Fired = false
    } end);
end

function JeweledBranch.GetTearData(tear, init)
    return JeweledBranch:GetData(tear, init, function() return {
        Jeweled = false;
    } end);
end

local function BulletValid(tear)
    return tear and tear:Exists() and not tear.StickTarget
end

function JeweledBranch:PostPlayerUpdate(player)
    if (player:HasCollectible(JeweledBranch.Item)) then
        local data = JeweledBranch.GetPlayerData(player, true);
        if (Inputs.GetRawShootingVector(player):Length() > 0.1 and player:IsExtraAnimationFinished()) then
            data.Fired = true;
        end
        
        if (Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
            data.Fired = false;
        end

        if (data.Fired) then
            data.FireDelay = data.FireDelay - 1;
            while (data.FireDelay <= -1) do
                local isFull = true;
                local tearCheckCount = 0;
                
                data.Index = (data.Index % 5) + 1;
                local currentBullet = data.Bullets[data.Index];
                while (isFull and tearCheckCount < maxBullets) do
                    if (not BulletValid(currentBullet)) then
                        isFull = false;
                    else
                        data.Index = (data.Index % 5) + 1;
                        currentBullet = data.Bullets[data.Index];
                        tearCheckCount = tearCheckCount + 1;
                    end
                end
                
                if (isFull) then
                    local hasEnemies = THI.Game:GetRoom():GetAliveEnemiesCount() > 0;
                    if (hasEnemies and BulletValid(currentBullet)) then
                        local nearest = nil;
                        local pos = currentBullet.Position;
                        for _, ent in pairs(Isaac.FindInRadius(pos, 320, EntityPartition.ENEMY)) do
                            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                if (not nearest or ent.Position:Distance(pos) < nearest.Position:Distance(pos)) then
                                    nearest = ent;
                                end
                            end
                        end
                        if (nearest) then
                            data.Bullets[data.Index] = nil;
                            currentBullet.Velocity = (nearest.Position - pos):Normalized() * 10 * player.ShotSpeed;
                            currentBullet.Height = player.TearHeight;
                            currentBullet.FallingSpeed = -player.TearFallingSpeed;
                            isFull = false;
                        end
                    end
                end
                
                if (not isFull) then
                    local newBullet = player:FireTear(player.Position, Vector.Zero, false, true, false, player, 1);
                    -- Set tear to jeweled.
                    local bulletData = JeweledBranch.GetTearData(newBullet, true);
                    bulletData.Jeweled = true;

                    newBullet.TearFlags = newBullet.TearFlags | TearFlags.TEAR_SPECTRAL;
                    newBullet:SetColor(JeweledBranch.Colors[data.Index], -1, 0, false, true);
                    data.Bullets[data.Index] = newBullet;
                end
                data.FireDelay = data.FireDelay + math.max(0.25, player.MaxFireDelay + 1) * 2;
            end

            data.Angle = data.Angle + 3 * player.ShotSpeed;
            for i, v in pairs(data.Bullets) do
                if (BulletValid(v)) then
                    local targetAngle = i * (360 / maxBullets) + data.Angle;
                    local targetPos = player.Position + Vector.FromAngle(targetAngle) * 40;
                    v.Velocity = (targetPos - v.Position ) / 2;
                    v.FallingSpeed = 0;
                    v.Height = player.TearHeight;
                else
                    data.Bullets[i] = nil;
                end
            end
        end
    end
end
JeweledBranch:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, JeweledBranch.PostPlayerUpdate);

function JeweledBranch:PostNewRoom()
    local game = THI.Game;
    for p, player in Players.PlayerPairs() do
        local data = JeweledBranch.GetPlayerData(player, false);
        if (data) then
            data.Fired = false;
        end
    end
end
JeweledBranch:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, JeweledBranch.PostNewRoom);

function JeweledBranch:PreTearCollision(tear, other, low)
    if (other.Type == EntityType.ENTITY_BOMBDROP) then
        local bulletData = JeweledBranch.GetTearData(tear, false);
        if (bulletData and bulletData.Jeweled) then
            return true;
        end
    end
end
JeweledBranch:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, JeweledBranch.PreTearCollision);

return JeweledBranch;