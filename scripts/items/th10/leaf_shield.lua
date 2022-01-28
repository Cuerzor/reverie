local Detection = CuerLib.Detection;
local Inputs = CuerLib.Inputs;
local LeafShield = ModItem("Leaf Shield", "LeafShield");

local CompareEntity = Detection.CompareEntity;
local EntityExists = Detection.EntityExists;

LeafShield.MaxSpawnDelay = 90;

function LeafShield.GetPlayerData(player, init)
    return LeafShield:GetData(player, init, function() return {
        RingSpawnDelay = 0,
        Ring = nil
    } end)
end

function LeafShield:PostPlayerUpdate(player)
    local data = LeafShield.GetPlayerData(player, false);
    if (data) then
        local ring = data.Ring;
        if (not EntityExists(ring)) then
            local Ring = THI.Familiars.LeafShieldRing;
            for _, ent in pairs(Isaac.FindByType(Ring.Type, Ring.Variant)) do
                local familiar = ent:ToFamiliar();
                if (CompareEntity(familiar.Player, player) and not Ring.IsFired(familiar)) then
                    ring = familiar;
                    data.Ring = ring;
                    break;
                end
            end
        end

        if (EntityExists(ring)) then
            ring.Position = player.Position;
        end
    end
end
LeafShield:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LeafShield.PostPlayerUpdate);

function LeafShield:PostPlayerEffect(player)
    local num = player:GetCollectibleNum(LeafShield.Item);
    if (player:HasCollectible(LeafShield.Item)) then
        local Ring = THI.Familiars.LeafShieldRing;
        local data = LeafShield.GetPlayerData(player, true);
        if (not EntityExists(data.Ring)) then
            if (data.RingSpawnDelay < 0) then
                data.Ring = Isaac.Spawn(Ring.Type, Ring.Variant, 0, player.Position, Vector.Zero,nil);
                data.RingSpawnDelay = LeafShield.MaxSpawnDelay;
            end
        end
    else
        local data = LeafShield.GetPlayerData(player, false);
        if (data) then
            if (EntityExists(data.Ring)) then
                data.Ring:Remove();
            end
        end
    end

    
    local data = LeafShield.GetPlayerData(player, false);
    if (data) then
        
        local shootingVector = Inputs.GetRawShootingVector(player);
        if (shootingVector:Length() > 0.1) then
            if (EntityExists(data.Ring) and data.Ring.FrameCount > 20) then
                local Ring = THI.Familiars.LeafShieldRing;
                Ring.FireRing(data.Ring);
                data.Ring.Velocity = shootingVector * 10;
                data.Ring = nil;
            end
        end

        if (not EntityExists(data.Ring) and data.RingSpawnDelay >= 0) then
            data.RingSpawnDelay = data.RingSpawnDelay - 1 * num;
        end
    end
end
LeafShield:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LeafShield.PostPlayerEffect);

return LeafShield;