local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local Circle = ModEntity("Summoning Magic Circle", "MAGIC_CIRCLE")

Circle.SubTypes = {
    SUMMONING = 0,
    BONE_WALL = 1,
    BONE_TRAP = 2,
    EVIL_SPIRIT = 3,
    FEARNESS = 4,
    RESURRECTION = 5,
    CORPSE_EXPLOSION = 6,
}


-- Main.
do
    local sprites = {
        [Circle.SubTypes.SUMMONING] = "gfx/reverie/effects/magic_circle_summon.png",
        [Circle.SubTypes.BONE_WALL] = "gfx/reverie/effects/magic_circle_bone_wall.png",
        [Circle.SubTypes.BONE_TRAP] = "gfx/reverie/effects/magic_circle_bone_trap.png",
        [Circle.SubTypes.EVIL_SPIRIT] = "gfx/reverie/effects/magic_circle_evilspirit.png",
        [Circle.SubTypes.FEARNESS] = "gfx/reverie/effects/magic_circle_fearness.png",
        [Circle.SubTypes.RESURRECTION] = "gfx/reverie/effects/magic_circle_resurrection.png",
        [Circle.SubTypes.CORPSE_EXPLOSION] = "gfx/reverie/effects/magic_circle_corpse_explosion.png",
    }

    local function GetCircleFireSubType(subType)
        local MagicCircleFire = THI.Effects.MagicCircleFire;
        if (subType == Circle.SubTypes.BONE_WALL or subType == Circle.SubTypes.BONE_TRAP) then
            return MagicCircleFire.SubTypes.GREY;
        elseif (subType == Circle.SubTypes.EVIL_SPIRIT) then
            return MagicCircleFire.SubTypes.BLACK;
        elseif (subType == Circle.SubTypes.FEARNESS) then
            return MagicCircleFire.SubTypes.CURSE;
        elseif (subType == Circle.SubTypes.CORPSE_EXPLOSION) then
            return MagicCircleFire.SubTypes.RED;
        end
        return MagicCircleFire.SubTypes.PURPLE;
    end

    local function GetCircleData(circle, init)
        local function getter()
            return {
                Time = 0,
                Fires = {}
            }
        end
        return Circle:GetData(circle, init, getter);
    end
    local function PostCircleInit(mod, circle)
        local spr = circle:GetSprite();
        local gfxPath = sprites[circle.SubType];
        if (gfxPath) then
            spr:ReplaceSpritesheet(0, gfxPath);
            spr:ReplaceSpritesheet(1, gfxPath);
            spr:LoadGraphics();
        end
    end
    Circle:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostCircleInit, Circle.Variant);


    local function ClusterBurst(cluster)
        local Cluster = THI.Effects.MagicCluster;
        
        local rng = RNG();
        rng:SetSeed(cluster.InitSeed, 0);
        for i = 1, 10 do
            local angle = i * 36 + rng:RandomFloat() * 10 - 5;
            local vel = Vector.FromAngle(angle) * (rng:RandomFloat() * 10 + 5)
            
            local trail = Cluster.SpawnTrail(cluster, cluster.Position, vel);
            local trailData = Cluster.GetClusterData(trail);
            trailData.Friction = 0.1;
            trailData.LifeTime = rng:RandomFloat() * 10 + 10;
        end
        -- up smokes
        for i = 1, 10 do
            
            local vel = RandomVector() * rng:RandomFloat() * 5;
            local trail = Cluster.SpawnTrail(cluster, cluster.Position, vel);
            local trailData = Cluster.GetClusterData(trail);
            trailData.FallingSpeed = rng:RandomFloat() * -15 - 15;
            trailData.Gravity = 2;
            trailData.Friction = 0.1;
        end
        cluster:Remove();
    end
    local function ClusterBurstFunc(cluster, landFunc)
        if (cluster.PositionOffset.Y >= 0) then
            ClusterBurst(cluster);

            if (landFunc) then
                landFunc(cluster);
            end
        end
    end

    local function SummonClusterUpdate(cluster)
        local function land(cluster)
            local bony = Isaac.Spawn(EntityType.ENTITY_BONY, 0, 0, cluster.Position, Vector.Zero, cluster.SpawnerEntity);
            bony.HitPoints = 8;
            THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);
        end
        ClusterBurstFunc(cluster, land)
    end

    local function EvilSpiritClusterUpdate(cluster)
        local EvilSpirit = THI.Monsters.EvilSpirit;
        local function land(cluster)
            Isaac.Spawn(EvilSpirit.Type, EvilSpirit.Variant, 0, cluster.Position, Vector.Zero, cluster.SpawnerEntity);
            THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);
        end
        ClusterBurstFunc(cluster, land)
    end
    
    local function FearnessClusterUpdate(cluster)
        local target = cluster.Target;
        if (not target or not target:Exists()) then
            cluster:Remove();
        else
            cluster.Velocity = cluster.Velocity * 0.9 +  (target.Position - cluster.Position) * 0.3 * 0.1
            cluster.PositionOffset = cluster.PositionOffset * 0.9 + target.PositionOffset * 0.1
            if (cluster.Position:Distance(target.Position) < 30) then
                target:AddFear(EntityRef(cluster.SpawnerEntity), 540);
                ClusterBurst(cluster);
                if (target:HasEntityFlags(EntityFlag.FLAG_FEAR)) then
                    THI.SFXManager:Play(THI.Sounds.SOUND_CURSE_FEARNESS);
                end
            end
        end
    end

    
    local function GhostClusterUpdate(cluster, explosion)
        local target = cluster.Target;
        if (not target or not target:Exists()) then
            cluster:Remove();
        else
            cluster.Velocity = cluster.Velocity * 0.9 +  (target.Position - cluster.Position) * 0.3 * 0.1
            cluster.PositionOffset = cluster.PositionOffset * 0.9 + target.PositionOffset * 0.1
            if (cluster.FrameCount > 30 and cluster.Position:Distance(target.Position) < 30) then
                target:Remove();
                if (not explosion) then
                    local revenant = Isaac.Spawn(EntityType.ENTITY_REVENANT, 0, 0, target.Position, Vector.Zero, cluster.SpawnerEntity);
                    revenant.HitPoints = 10;
                    THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);
                else
                    --Game():BombDamage (target.Position, target.CollisionDamage, 80, true, cluster.SpawnerEntity, TearFlags.TEAR_NORMAL,0, false )
                    local dealer = cluster.SpawnerEntity;
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 1, target.Position, Vector.Zero, dealer);
                    effect.CollisionDamage = target.CollisionDamage;
                    effect:SetColor(target:GetColor(), 0, 0);
                    if (not dealer or not dealer:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        for i, player in pairs(Isaac.FindInRadius(target.Position, 80, EntityPartition.PLAYER)) do
                            player:TakeDamage(1, 0, EntityRef(dealer), 0);
                        end
                    end
                    THI.SFXManager:Play(SoundEffect.SOUND_DEMON_HIT);
                end
                ClusterBurst(cluster);
            end
        end
    end
    local function BoneTrapClusterUpdate(cluster)
        local EvilSpirit = THI.Monsters.EvilSpirit;
        local function land(cluster)
            Isaac.Spawn(EntityType.ENTITY_CULTIST, 10, 0, cluster.Position, Vector.Zero, cluster.SpawnerEntity);
            THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);
        end
        cluster.Velocity = cluster.Velocity * 0.5 +  (cluster.TargetPosition - cluster.Position) * 0.3 * 0.5
        ClusterBurstFunc(cluster, land)
    end
    
    local function PostCircleUpdate(mod, circle)
        local MagicCircleFire = THI.Effects.MagicCircleFire;
        local subType = circle.SubType;
        local spr = circle:GetSprite();
        if (spr:IsFinished("Appear")) then
            spr:Play("Idle");
        end
        local maxChargeTime = 1;
        local disappearTime = 20;
        local data = GetCircleData(circle, true);
        local idle = spr:IsPlaying("Idle");

        -- Follow Parent.
        local parent = circle.Parent;
        if (parent) then
            if (parent:Exists() and not parent:IsDead()) then
                circle.Position = parent.Position;
                circle.Velocity = parent.Velocity;
            else
                spr:Play("Disappear");
            end
        end
        
        if (idle) then
            data.Time = (data.Time or 0) + 1;

            -- Check Fires.
            local fireCount = math.min(6, math.ceil(data.Time / maxChargeTime * 6));
            for i = #data.Fires + 1, fireCount do
                local positionOffset = Vector(0, -78) : Rotated(i* 60) + Vector(0, 12);
                local fire = Isaac.Spawn(MagicCircleFire.Type, MagicCircleFire.Variant, GetCircleFireSubType(subType), circle.Position, Vector.Zero, circle);
                fire.PositionOffset = positionOffset + circle.PositionOffset;
                fire.Parent = circle;
                fire.DepthOffset = circle.DepthOffset + 1;
                data.Fires[i] = fire;
            end

            if (data.Time == maxChargeTime) then
                local rng = RNG();
                local Cluster = THI.Effects.MagicCluster;
                rng:SetSeed(circle.InitSeed, 0);
                if (subType == Circle.SubTypes.SUMMONING) then
                    for i = 1, circle.InitSeed % 2 + 1 do
                        local params = {
                            Color = Color(0.8,0,0.8,1,0,0,0),
                            Gravity = 1,
                            UpdateFunc = SummonClusterUpdate,
                            Acceleration = Vector(rng:RandomFloat() * 3 - 1.5, 0)
                        }
                        local cluster = Cluster.SpawnCluster(true, circle.Position, Vector(rng:RandomFloat() * 15 - 7.5, 3), circle.SpawnerEntity, params)
                        cluster.SpriteScale = Vector(0.75, 0.75);
                        cluster.PositionOffset = circle.PositionOffset;
                    end
                elseif (subType == Circle.SubTypes.EVIL_SPIRIT) then
                    local params = {
                        Color = Color(0,0,0,1,0,0,0),
                        Gravity = 1,
                        UpdateFunc = EvilSpiritClusterUpdate
                    }
                    local cluster = Cluster.SpawnCluster(true, circle.Position, Vector(rng:RandomFloat() * 15 - 7.5, 3), circle.SpawnerEntity, params)
                    cluster.SpriteScale = Vector(0.75, 0.75);
                    cluster.PositionOffset = circle.PositionOffset;
                elseif (subType == Circle.SubTypes.FEARNESS) then
                    local game = Game();
                    local targets = {}
                    if (circle:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        for i, ent in pairs(Isaac.GetRoomEntities()) do
                            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                table.insert(targets, ent);
                            end
                        end
                    else
                        for _, ent in Detection.PlayerPairs(true, false) do
                            table.insert(targets, ent);
                        end
                    end
                    for _, ent in pairs(targets) do
                    
                        local target = ent
                        local params = {
                            Color = Color(0.3,0,0.5,1,0,0,0),
                            UpdateFunc = FearnessClusterUpdate
                        }
                        local cluster = Cluster.SpawnCluster(true, circle.Position, RandomVector() * 30, circle.SpawnerEntity, params)
                        cluster.SpriteScale = Vector(0.75, 0.75);
                        cluster.PositionOffset = circle.PositionOffset;
                        cluster.Target = target
                    end
                    THI.SFXManager:Play(THI.Sounds.SOUND_CURSE_CAST);
                elseif (subType == Circle.SubTypes.RESURRECTION or subType == Circle.SubTypes.CORPSE_EXPLOSION) then
                    local ghosts = {};
                    local SummonerGhost = THI.Effects.SummonerGhost;
                    for i, ghost in pairs(Isaac.FindByType(SummonerGhost.Type, SummonerGhost.Variant)) do
                        table.insert(ghosts, ghost);
                    end
                    for i, ghost in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0)) do
                        table.insert(ghosts, ghost);
                    end

                    local params;
                    local sound = THI.Sounds.SOUND_REVIVE_SKELETON_CAST;
                    local count = math.min(circle.InitSeed % 2 + 1, #ghosts);
                    if (subType == Circle.SubTypes.RESURRECTION) then
                        params = {
                            Color = Color(0.3,0,0.5,1,0,0,0),
                            UpdateFunc = function(cluster) GhostClusterUpdate(cluster, false) end
                        }
                    else
                        params = {
                            Color = Color(1,0,0,1,0,0,0),
                            UpdateFunc = function(cluster) GhostClusterUpdate(cluster, true) end
                        }
                        count = #ghosts;
                        sound = THI.Sounds.SOUND_CORPSE_EXPLODE_CAST;
                    end
                    for i = 1, count do
                        local cluster = Cluster.SpawnCluster(true, circle.Position, RandomVector() * 30, circle.SpawnerEntity, params)
                        cluster.SpriteScale = Vector(0.75, 0.75);
                        cluster.PositionOffset = circle.PositionOffset;
                        cluster.Target = ghosts[i];
                    end
                    if (#ghosts > 0) then
                        THI.SFXManager:Play(sound);
                    end
                elseif (subType == Circle.SubTypes.BONE_TRAP) then
                    local selectedPositions = {};
                    local game = Game();
                    local target = game:GetRandomPlayer(circle.Position, 320);
                    for i = 1, 6 do
                        local pos = target.Position + Vector.FromAngle(i * 60) * 80;


                        local params = {
                            Color = Color(0.5,0.5,0.5,1,0,0,0),
                            Gravity = 2,
                            UpdateFunc = BoneTrapClusterUpdate,
                        }
                        local cluster = Cluster.SpawnCluster(true, circle.Position, Vector.Zero, circle.SpawnerEntity, params)
                        cluster.SpriteScale = Vector(0.75, 0.75);
                        cluster.PositionOffset = circle.PositionOffset;
                        cluster.TargetPosition = pos;
                    end
                end
            end

            if (data.Time > disappearTime) then
                spr:Play("Disappear");
            end
        end

        if (spr:IsPlaying("Disappear")) then
            for i, fire in pairs(data.Fires) do
                if (fire) then
                    fire:GetSprite():Play("Disappear");
                end
            end
        end
        if (spr:IsFinished("Disappear")) then
            circle:Remove();
        end
    end
    Circle:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostCircleUpdate, Circle.Variant);

end

return Circle;