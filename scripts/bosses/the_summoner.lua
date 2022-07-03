local Detection = CuerLib.Detection;
local Maths = CuerLib.Math;
local Bosses = CuerLib.Bosses;
local Grids = CuerLib.Grids;
local Summoner = ModEntity("The Summoner", "SUMMONER");

-- Add Boss Room.
do
    local n = Grids.RoomGrids.Null;
    local t = Grids.RoomGrids.TallBlock;
    local b = Grids.RoomGrids.Block;

    local bossConfig = {
        Name = "The Summoner",
        StageAPI = {
            Stages = {
                {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE3_1, Weight = 1}
            }
        },
        Type = Summoner.Type,
        Variant = Summoner.Variant,
        PortraitPath = "gfx/reverie/ui/boss/portrait_585.0_summoner.png",
        PortraitOffset = Vector(0, -10),
        NamePaths = {
            en = "gfx/reverie/ui/boss/bossname_585.0_summoner.png",
            zh = "gfx/reverie/ui/boss/bossname_585.0_summoner_zh.png"
        }
    }

    local roomConfigs = {
        ID = "reverie:the_summoner",
        LuaRoomPath = "resources-dlc3/luarooms/reverie/the_summoner",
        CustomRooms = {
            SummonerAndImmortal1 = {
                ReplaceChance = 33,
                BossID = "reverie:the_summoner",
                Shape = RoomShape.ROOMSHAPE_1x1,
                Stages = {
                    {Type = StageType.STAGETYPE_REPENTANCE, Stage = LevelStage.STAGE3_1}
                },
                Music = Music.MUSIC_BOSS2,
                Grids = {
                    {t, n, n, n, n, n, n, n, n, n, n, n, t},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, b, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {n, n, n, n, n, n, n, n, n, n, n, n, n},
                    {t, n, n, n, n, n, n, n, n, n, n, n, t},
                },
                Bosses = {
                    {Type = Summoner.Type, Variant = Summoner.Variant, SubType = Summoner.SubType, Position = Vector(280, 280)},
                    {Type = Isaac.GetEntityTypeByName("The Immortal"), Variant = Isaac.GetEntityVariantByName("The Immortal"), SubType = 0, Position = Vector(360, 280)}
                }
            }
        }
    }
    Bosses:SetBossConfig("reverie:the_summoner", bossConfig, roomConfigs);
end


-- Main.
do
    Summoner.States = {
        IDLE = 0,
        CASTING = 10,
    }
    local ghostColor = Color(1,1,1,1,0,0,0);
    ghostColor:SetColorize(1,0,1,1);
    local function GetSummonerData(summoner, init)
        local function getter()
            return {
                TeleportCooldown = 0
            }
        end
        return Summoner:GetData(summoner, init, getter);
    end

    local function TeleportTo(summoner, pos)
        local data = GetSummonerData(summoner, true);
        data.TeleportCooldown = 150;
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, summoner.Position,Vector.Zero, nil);
        local spr = poof:GetSprite();
        local summonerSpr = summoner:GetSprite();
        spr:Load(summonerSpr:GetFilename(), true);
        spr:Play("TeleportUp");
        THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL1);
        THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL2);
        summoner.Position = pos;
        summoner.Velocity = Vector.Zero;
        summonerSpr:Play("TeleportDown");
    end

    local function Thunder(summoner)
        local game = Game();
        -- Find valid Enemies.
        local validEnemy;
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if (ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:IsBoss()) then
                validEnemy = ent;
                goto outOfFinding;
            end
        end
        ::outOfFinding::
        local pos;
        if (validEnemy) then
            pos = validEnemy.Position;
        else
            local room = game:GetRoom();
            pos = room:GetRandomPosition (20);
        end
        local HolyThunder = THI.Effects.HolyThunder;
        local thunder = Isaac.Spawn(HolyThunder.Type, HolyThunder.Variant, HolyThunder.SubType, pos, Vector.Zero, nil);
        thunder.CollisionDamage = 0;

        for _, ent in pairs(Isaac.FindInRadius(pos, 80, EntityPartition.ENEMY)) do
            if (ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:IsBoss()) then
                ent:Die();
            end
        end
    end

    ---------------------------
    -- Events
    ---------------------------

    local function PostUpdate(mod)
        for i, summoner in pairs(Isaac.FindByType(Summoner.Type, Summoner.Variant)) do
            if (summoner:IsDead()) then
                local spr = summoner:GetSprite();

                if (not spr:WasEventTriggered("StopLightning")) then
                    if (summoner:IsFrame(3, 0)) then
                        Thunder(summoner)
                    end
                end
            end
        end
    end
    Summoner:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);


    local function PostNPCInit(mod, npc)
        if (npc.Variant == Summoner.Variant) then
        end
    end
    Summoner:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostNPCInit, Summoner.Type);

    
    local function PostSummonerUpdate(summoner)
        local game = Game();
        local room = game:GetRoom();
        local centerPos = room:GetCenterPos();

        local spr = summoner:GetSprite();
        local data = GetSummonerData(summoner, true);
        -- Play Sprites.
        if (spr:IsFinished("Appear") or spr:IsFinished("TeleportUp") or spr:IsFinished("TeleportDown")) then
            spr:Play("Idle");
        end
        
        -- Countdowns.
        if (data.TeleportCooldown > 0) then
            data.TeleportCooldown = data.TeleportCooldown - 1;
        end

        -- States.

        local function StartState(state)
            summoner.State = state;
            summoner.StateFrame = 0;
            summoner.I1 = 0;
            summoner.I2 = 0;
        end
        local function RunStateFrame() 
            if (not summoner:HasEntityFlags(EntityFlag.FLAG_SLOW) or summoner:IsFrame(2, 0)) then
                summoner.StateFrame = summoner.StateFrame + 1;
            end
        end

        local function GetCircleType()
            
            local Circle = THI.Effects.MagicCircle;

            -- Fear.
            local damagedHP = 1 - (summoner.HitPoints /  summoner.MaxHitPoints);
            local dps = damagedHP * 30 / summoner.FrameCount;
            local fearChance = dps / 0.1 * 100;
            -- If player's DPS is much higher, reduce the chance.
            if (dps > 0.1) then
                fearChance = 100 - fearChance;
            end

            
            if (Random() % 100 < fearChance) then

                local canFear = true;
                for i, player in Detection.PlayerPairs(true) do
                    if (player:HasEntityFlags(EntityFlag.FLAG_FEAR)) then
                        canFear = false;
                        break;
                    end
                end
                if (canFear) then
                    return Circle.SubTypes.FEARNESS;
                end
            end

            -- Corpse Explosion.
            local SummonerGhost = THI.Effects.SummonerGhost;
            local ghostCount = #Isaac.FindByType(SummonerGhost.Type, SummonerGhost.Variant) + #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST);
            
            if (ghostCount >= 6) then
                return Circle.SubTypes.CORPSE_EXPLOSION;
            end

            -- Summon or Resurrection.
            local bonyCount = #Isaac.FindByType(EntityType.ENTITY_BONY) + #Isaac.FindByType(EntityType.ENTITY_REVENANT);
            if (Random() % 6 > bonyCount) then
                if (ghostCount >= 3 and Random() % 7 <= ghostCount) then
                    return Circle.SubTypes.RESURRECTION;
                else
                    return Circle.SubTypes.SUMMONING;
                end
            end
            -- Evil Spirit.
            
            local EvilSpirit = THI.Monsters.EvilSpirit;
            if (#Isaac.FindByType(EvilSpirit.Type, EvilSpirit.Variant) <= 0) then
                return Circle.SubTypes.EVIL_SPIRIT;
            end

            -- Bone Trap.
            return Circle.SubTypes.BONE_TRAP;
        end
        local lastVelocity = summoner.Velocity;
        local pathfinder = summoner.Pathfinder;
        local maxSpeed = 5;

        if (summoner.State == Summoner.States.IDLE) then
            -- Idle.
            local nearestPlayer = nil;
            local farestPlayer = nil;
            local nearestDis = 0;
            local farestDis = 0;
            local playerCount = 0;
            local playerPositionSum = Vector.Zero;
            for i, player in Detection.PlayerPairs(true) do
                local dis = player.Position:Distance(summoner.Position);
                if (not nearestPlayer or dis < nearestDis) then
                    nearestPlayer = player;
                    nearestDis = dis;
                end
                if (not farestPlayer or dis > farestDis) then
                    farestPlayer = player;
                    farestDis = dis;
                end
                playerPositionSum = playerPositionSum + player.Position;
                playerCount = playerCount + 1;
            end

            local playerAveragePosition = playerPositionSum / playerCount;

            if (nearestDis < 100 and nearestPlayer) then
                if (nearestDis < 80 and data.TeleportCooldown <= 0) then
                    -- Evaded to the corner.
                    local playersAngle = (playerAveragePosition - centerPos):GetAngleDegrees();
                    local teleportPos = centerPos + Vector.FromAngle(-playersAngle) * 120;
                    TeleportTo(summoner, teleportPos);
                else
                    local acceleration = (nearestPlayer.Position - summoner.Position):Resized(2);
                    summoner:AddVelocity(-acceleration);
                end
            elseif (nearestDis > 120) then
                maxSpeed = 1;
                local acceleration = (nearestPlayer.Position - summoner.Position):Resized(0.2);
                summoner:AddVelocity(acceleration);
            end

            RunStateFrame();
            if (summoner.StateFrame > 75) then
                StartState(Summoner.States.CASTING);
                summoner.I1 = GetCircleType();
                local playersAngle = (playerAveragePosition - centerPos):GetAngleDegrees();
                summoner.TargetPosition = centerPos + -Vector.FromAngle(playersAngle) * 120;
                spr:Play("Cast");
            end
        
        elseif (summoner.State == Summoner.States.CASTING) then

            RunStateFrame();
            maxSpeed = 10;
            local target2Summoner = summoner.TargetPosition - summoner.Position;
            local acceleration =  target2Summoner:Resized(math.min(2, (target2Summoner:Length() - 30) / 30 * 2));
            summoner.Velocity = summoner.Velocity + acceleration;
            if (not summoner.Child) then
                if (summoner.StateFrame == 30) then
                    local Circle = THI.Effects.MagicCircle;
                    local subType = summoner.I1;
                    THI.SFXManager:Play(THI.Sounds.SOUND_BONE_CAST, 3);
                    local circle = Isaac.Spawn(Circle.Type, Circle.Variant, subType, summoner.Position + Vector(0, -5), summoner.Velocity, summoner);
                    circle.PositionOffset = Vector(0, -64);
                    circle.Parent = summoner;
                    summoner.Child = circle;

                    -- Spawn The Immortal.
                    local Immortal = THI.Monsters.Immortal;
                    local immortalCount = #Isaac.FindByType(Immortal.Type, Immortal.Variant);
                    local summonerCount = #Isaac.FindByType(Summoner.Type, Summoner.Variant);
                    local spawn = immortalCount < summonerCount;
                    if (spawn) then
                        Isaac.Spawn(Immortal.Type, Immortal.Variant, Immortal.SubType, summoner.Position + Vector(0, 40), Vector.Zero, summoner);
                        THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);
                    end
                elseif (summoner.StateFrame > 60) then
                    StartState(Summoner.States.IDLE);
                    spr:Play("Idle");
                end
            end
        end

        local speed = summoner.Velocity:Length();
        if (speed > maxSpeed) then
            speed = maxSpeed + (speed - maxSpeed) * 0.2;
            summoner.Velocity = summoner.Velocity:Resized(speed);
        end
        

        summoner:MultiplyFriction(0.9);

        -- Death.
        if (summoner:IsDead()) then
            THI.SFXManager:Play(THI.Sounds.SOUND_SUMMONER_DEATH, 3);
            game:Darken(1, 150);
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, summoner.Position, Vector.Zero, nil);
            summoner:BloodExplode();
        end
    end
    local function PostEntityKill(mod, entity)
        if (entity:IsEnemy()) then
            local canSpawn = false;
            local spawner = nil;
            
            for i, summoner in pairs(Isaac.FindByType(Summoner.Type, Summoner.Variant)) do
                if (not summoner:IsDead()) then
                    canSpawn = true;
                    spawner = summoner;
                    break;
                end
            end
            if (canSpawn) then
                local SummonerGhost = THI.Effects.SummonerGhost;
                local ghost = Isaac.Spawn(SummonerGhost.Type, SummonerGhost.Variant, 0, entity.Position, RandomVector(), spawner):ToEffect();
                ghost:SetColor(ghostColor, 0, 0);
                ghost.CollisionDamage = entity.MaxHitPoints / 3;
            end
        end
    end
    Summoner:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);

    local function PostNPCUpdate(mod, npc)
        if (npc.Variant == Summoner.Variant) then
            PostSummonerUpdate(npc);
        end
    end
    Summoner:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate, Summoner.Type);
end

return Summoner;