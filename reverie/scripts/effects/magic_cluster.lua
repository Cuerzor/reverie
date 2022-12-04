local Cluster = ModEntity("Magic Cluster", "CLUSTER")
Cluster.SubTypes = {
    FADING = 0,
    HEAD = 1
}

-- Main.
do 
    local rng = RNG();
    rng:SetSeed(Random(), 0);
    function Cluster.GetClusterData(cluster, init)
        local function getter() 
            return {
                Gravity = 0,
                FallingSpeed = 0,
                Friction = 0,
                RotationSpeed = 0,
                LifeTime = 16,
                Acceleration = Vector.Zero,
                UpdateFunc = nil,
            }
        end
        return Cluster:GetData(cluster, init, getter);
    end

    function Cluster.SpawnCluster(head, position, velocity, spawner, params)
        local subType = Cluster.SubTypes.FADING;
        if (head) then
            subType = Cluster.SubTypes.HEAD;
        end
        local head = Isaac.Spawn(Cluster.Type, Cluster.Variant, subType, position, velocity, spawner);

        local color = params.Color;
        if (color) then
            head:SetColor(color, 0, 0);
        end

        local headData = Cluster.GetClusterData(head);
        headData.Gravity = params.Gravity or 0;
        headData.FallingSpeed = params.FallingSpeed  or 0;
        headData.Friction = params.Friction or 0;
        headData.RotationSpeed = params.RotationSpeed or 0;
        headData.LifeTime = params.LifeTime or 16;
        headData.UpdateFunc = params.UpdateFunc or nil;
        headData.Acceleration = params.Acceleration or Vector.Zero;

        return head;
    end

    function Cluster.SpawnTrail(spawner, position, velocity)
        position = position or spawner.Position;
        velocity = velocity or Vector.Zero;
        local trail = Isaac.Spawn(Cluster.Type, Cluster.Variant, Cluster.SubTypes.FADING, position, velocity, spawner);
        trail.PositionOffset = spawner.PositionOffset;
        trail:SetColor(spawner:GetColor(), 0, 0);
        trail.SpriteScale = spawner.SpriteScale;
        trail.DepthOffset = spawner.DepthOffset + 1;
        return trail;
    end

    local function PostClusterInit(mod, cluster)
        if (cluster.SubType == Cluster.SubTypes.FADING) then
            local spr = cluster:GetSprite()
            spr:Play("Fade");
        elseif (cluster.SubType == Cluster.SubTypes.HEAD) then
            cluster:GetSprite():Play("Idle");
        end
    end
    Cluster:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostClusterInit, Cluster.Variant);
    local function PostClusterUpdate(mod, cluster)
        if (cluster.SubType == Cluster.SubTypes.FADING or cluster.SubType == Cluster.SubTypes.HEAD) then

            local data = Cluster.GetClusterData(cluster);
            if (cluster.SubType == Cluster.SubTypes.FADING) then
                local spr = cluster:GetSprite();
                spr.PlaybackSpeed = 16 / data.LifeTime;
                if (spr:IsFinished("Fade")) then
                    cluster:Remove();
                end
            elseif (cluster.SubType == Cluster.SubTypes.HEAD) then
                if (cluster:IsFrame(2, 0)) then
                    Cluster.SpawnTrail(cluster);
                end
                if (cluster.FrameCount > 300) then
                    cluster:Remove();
                end
                
            end

            cluster.PositionOffset = cluster.PositionOffset + Vector(0, data.FallingSpeed);
            data.FallingSpeed = (data.FallingSpeed + data.Gravity) * (1- data.Friction);
            cluster:AddVelocity(data.Acceleration);
            cluster:MultiplyFriction(1- data.Friction);

            local func = data.UpdateFunc;
            if (func) then
                func(cluster);
            end

        end
    end
    Cluster:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostClusterUpdate, Cluster.Variant);
end


return Cluster;