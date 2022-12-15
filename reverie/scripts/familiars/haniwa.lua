local Consts = CuerLib.Consts;
local CompareEntity = CuerLib.Entities.CompareEntity;
local Familiars = CuerLib.Familiars;
local Haniwa = ModEntity("Haniwa Soldier", "HANIWA_SOLDIER");

local particleColor = Color(0.8,0.5,0,1,0,0,0);

Haniwa.MaxCount = 8;
Haniwa.SubTypes = {
    HANIWA_SOLDIER = 0,
    HANIWA_OFFICER = 1,
    HANIWA_GENERAL = 2,
    HANIWA_KAMIKAZE = 3,
    HANIWA_ARCHER = 4,
    HANIWA_BRASS = 5,
    HANIWA_TOMB = 6,
    HANIWA_MAGE = 7,
    HANIWA_SKELETON = 8,
    HANIWA_FLESH = 9,
}

local function MeleeAttack(haniwa, target)
    local info = Haniwa:GetHaniwaInfo(haniwa.SubType);
    if (haniwa.Position:Distance(target.Position) <= info.Distance + 20 + target.Size) then
        THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME)

        local Knife = THI.Knives.HaniwaKnife;
        local knife = Isaac.Spawn(Knife.Type, Knife.Variant, Knife.SubType, haniwa.Position, Vector.Zero, haniwa):ToKnife();
        knife.Parent = haniwa;
        knife.CollisionDamage = info.Damage;
        knife.Scale = 0.75;
        if (haniwa.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
            knife.CollisionDamage = knife.CollisionDamage * 2;
            knife.Scale = knife.Scale * 1.5;
        end
        local rotation = (target.Position - haniwa.Position):GetAngleDegrees();
        rotation = math.floor((rotation + 45) / 90) * 90;
        knife.SpriteRotation = rotation - 90;
        knife.PositionOffset = Vector.FromAngle(rotation) * Vector(-32, -32) * knife.Scale;
        haniwa.FireCooldown = haniwa.FireCooldown + (info.MaxFireCooldown or 11);
    end
end

local function Kamikaze(haniwa, target)
    local info = Haniwa:GetHaniwaInfo(haniwa.SubType);
    if (haniwa.Position:Distance(target.Position) <= haniwa.Size + target.Size) then
        haniwa:Kill();
    end
end

local function RangedAttack(haniwa, target)
    local info = Haniwa:GetHaniwaInfo(haniwa.SubType);

    local rotation = (target.Position - haniwa.Position):GetAngleDegrees();
    rotation = math.floor((rotation + 45) / 90) * 90;
    local vel = Vector.FromAngle(rotation) * 10 + haniwa.Velocity / 5;

    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, info.TearVariant or TearVariant.BLUE, 0, haniwa.Position, vel, haniwa):ToTear();
    tear.CollisionDamage = info.Damage;
    tear.Scale = 0.5;
    tear.Height = -5;
    tear.FallingSpeed = -2;
    if (haniwa.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
        tear.Scale = tear.Scale * 1.5;
    end
    Familiars.ApplyTearEffect(haniwa.Player, tear)

    if (haniwa.SubType == Haniwa.SubTypes.HANIWA_ARCHER) then
        tear:AddTearFlags(TearFlags.TEAR_PIERCING);
    elseif (haniwa.SubType == Haniwa.SubTypes.HANIWA_TOMB) then
        tear:AddTearFlags(TearFlags.TEAR_POISON);
        tear:SetColor(Consts.Colors.PoisonTear, -1, 0);
    elseif (haniwa.SubType == Haniwa.SubTypes.HANIWA_MAGE) then
        local random = Random() % 3;
        if (random == 0) then
            tear:AddTearFlags(TearFlags.TEAR_BURN);
            tear:ResetSpriteScale();
            tear:SetColor(Consts.Colors.BurnTear, -1, 0);
        elseif (random == 1) then
            tear:AddTearFlags(TearFlags.TEAR_ICE);
            tear:ChangeVariant(TearVariant.ICE);
        else
            tear:AddTearFlags(TearFlags.TEAR_JACOBS)
        end
    elseif (haniwa.SubType == Haniwa.SubTypes.HANIWA_SKELETON) then
        tear:AddTearFlags(TearFlags.TEAR_BONE);
    end

    haniwa.FireCooldown = haniwa.FireCooldown + (info.MaxFireCooldown or 11);
end

Haniwa.SubTypeInfos = {
    [Haniwa.SubTypes.HANIWA_SOLDIER] = {
        Sprite = "gfx/reverie/003.5831.0_haniwa soldier.anm2",
        HP = 5,
        Damage = 3,
        Distance = 28,
        Priority = 0,
        Attack = MeleeAttack
    },
    [Haniwa.SubTypes.HANIWA_OFFICER] = {
        Sprite = "gfx/reverie/003.5831.1_haniwa officer.anm2",
        HP = 10,
        Damage = 8,
        Distance = 28,
        Priority = 5,
        Attack = MeleeAttack
    },
    [Haniwa.SubTypes.HANIWA_GENERAL] = {
        Sprite = "gfx/reverie/003.5831.2_haniwa general.anm2",
        HP = 30,
        Damage = 20,
        Distance = 28,
        Priority = 10,
        Attack = MeleeAttack
    },
    [Haniwa.SubTypes.HANIWA_KAMIKAZE] = {
        Sprite = "gfx/reverie/003.5831.3_kamikaze haniwa.anm2",
        HP = 1,
        Damage = 185,
        Distance = 0,
        Priority = 1,
        Attack = Kamikaze;
    },
    [Haniwa.SubTypes.HANIWA_ARCHER] = {
        Sprite = "gfx/reverie/003.5831.4_haniwa archer.anm2",
        HP = 5,
        Damage = 5,
        Distance = 128,
        Priority = 2,
        Attack = RangedAttack,
        TearVariant = TearVariant.CUPID_BLUE
    },
    [Haniwa.SubTypes.HANIWA_BRASS] = {
        Sprite = "gfx/reverie/003.5831.5_brass haniwa.anm2",
        HP = 10,
        Damage = 1,
        Distance = 0,
        Priority = 2,
    },
    [Haniwa.SubTypes.HANIWA_TOMB] = {
        Sprite = "gfx/reverie/003.5831.6_tomb haniwa.anm2",
        HP = 5,
        Damage = 2,
        Distance = 64,
        Priority = 3,
        Attack = RangedAttack
    },
    [Haniwa.SubTypes.HANIWA_MAGE] = {
        Sprite = "gfx/reverie/003.5831.7_haniwa mage.anm2",
        HP = 5,
        Damage = 2,
        Distance = 64,
        Priority = 3,
        Attack = RangedAttack
    },
    [Haniwa.SubTypes.HANIWA_SKELETON] = {
        Sprite = "gfx/reverie/003.5831.8_skeleton haniwa.anm2",
        HP = 5,
        Damage = 3,
        Distance = 64,
        Priority = 3,
        Attack = RangedAttack,
        TearVariant = TearVariant.BONE
    },
    [Haniwa.SubTypes.HANIWA_FLESH] = {
        Sprite = "gfx/reverie/003.5831.9_flesh haniwa.anm2",
        HP = 5,
        Damage = 8,
        Distance = 64,
        Priority = 3,
        Attack = RangedAttack,
        TearVariant = TearVariant.BLOOD
    },
}

local function GetHaniwaData(haniwa, create)
    return Haniwa:GetData(haniwa, create, function()
        return {
            PathFind = {
                CachedNodes = nil
            }
        }
    end)
end

function Haniwa:GetHaniwaInfo(subtype)
    return self.SubTypeInfos[subtype] or self.SubTypeInfos[self.SubTypes.HANIWA_SOLDIER];
end

function Haniwa:TrySpawnHaniwa(position, subtype)

    local haniwas = Isaac.FindByType(Haniwa.Type, Haniwa.Variant);

    if (#haniwas < self.MaxCount) then
        return Isaac.Spawn(Haniwa.Type, Haniwa.Variant, subtype, position, Vector.Zero, nil);
    end

    local lowestOne = nil;
    local lowestPriority = 0;
    for _, ent in ipairs(haniwas) do
        if (ent:Exists()) then
            
            local priority = self:GetHaniwaInfo(ent.SubType).Priority or 0;
            if (not lowestOne or priority < lowestPriority) then
                lowestOne = ent;
                lowestPriority = priority;
            end
        end
    end

    local thisPriority = self:GetHaniwaInfo(subtype).Priority or 0;
    if (lowestOne and lowestPriority <= thisPriority) then
        lowestOne:Remove();
        return Isaac.Spawn(Haniwa.Type, Haniwa.Variant, subtype, position, Vector.Zero, nil);
    end
    return nil;
end
--------------------------------
-- Path Finding.
--------------------------------
local function CanPass(index)
    local room = Game():GetRoom();
    local gridEnt = room:GetGridEntity(index);
    if (not gridEnt) then
        return true;
    else
        if (gridEnt.CollisionClass == GridCollisionClass.COLLISION_NONE) then
            return true;
        end
    end
    return room:GetGridPath(index) < 900;
end
local enemyFindParams = {
    PassCheck = CanPass,
    MaxCost = 8;
}
local playerFindParams = {
    PassCheck = CanPass
}


local function FindPath(entIndex, targetIndex, params)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPath(entIndex, targetIndex, params or enemyFindParams);
end

local function FindPathInPos(entPos, targetPos, params)
    local PathFinding = THI.Shared.PathFinding;
    return PathFinding:FindPathInPos(entPos, targetPos, params or enemyFindParams);
end

local function MoveToTarget(haniwa, targetPos, minDistance)
    
    minDistance = minDistance or 0;
    local data = GetHaniwaData(haniwa, true);
    local room = Game():GetRoom();
    local target = targetPos;
    local canWalk, newPos = room:CheckLine(haniwa.Position, target, 0,900);
    -- If cannot directly walk to the target.
    if (not canWalk) then
        
        -- Search Path.
        local cachedNodes = data.PathFind.CachedNodes;
        local node;
        if (cachedNodes) then
            
            local num = #cachedNodes;
            node = cachedNodes[num];
            if (room:GetGridIndex(haniwa.Position) == node) then
                table.remove(cachedNodes, num);
                node = cachedNodes[#cachedNodes];
            end
        end
        if (node) then
            target = room:GetGridPosition(node);
        else
            -- Path is blocked.
            return false;
        end
    end

    local moveDir = (target - haniwa.Position):Normalized();
    local maxSpeed = 6;
    local speedMultiplier = 1;
    local dot = haniwa.Velocity:Dot(moveDir);
    local distance = (targetPos - haniwa.Position):Length();
    local moveSpeed = 0;
    if (distance >= minDistance) then
        moveSpeed = math.max(0, math.min(maxSpeed - dot, distance * speedMultiplier));
    end
    haniwa:AddVelocity(moveDir * moveSpeed);
    return true;
end


local function FindTarget(haniwa)
    local room = Game():GetRoom();
    local nearestEnemy = nil;
    local nearestDistance = 0;
    local nearestPlace = nil;
    local nearestNodes = nil;
    local info = Haniwa:GetHaniwaInfo(haniwa.SubType);
    local distance = info.Distance;

    local function CanReach(haniwa, target)
        if (haniwa.SubType == Haniwa.SubTypes.HANIWA_KAMIKAZE or haniwa.SubType == Haniwa.SubTypes.HANIWA_BRASS) then
            return room:CheckLine(haniwa.Position, target.Position, 0) or FindPathInPos(haniwa.Position, target.Position), Vector.Zero;
        end

        -- Find a suitable place to snipe.
        local nearestSnipePos = nil;
        local nearestDistance = 0;
        local nearestNodes = nil;
        for dir = Direction.LEFT, Direction.DOWN do
            local spare;
            local dirVec = Consts.DirectionVectors[dir];
            local pos = target.Position + dirVec * distance + (target.Size * target.SizeMulti * dirVec);
            spare, pos = room:CheckLine(target.Position, pos, 4)
            local distance = pos:Distance(haniwa.Position);
            if (not nearestSnipePos or distance < nearestDistance) then
                local nodes = FindPathInPos(haniwa.Position, pos);
                if (nodes) then
                    nearestNodes = nodes;
                    nearestSnipePos = pos;
                    nearestDistance = distance;
                end
            end
        end

        if (nearestSnipePos) then
            return true, nearestSnipePos, nearestNodes;
        end
        return false, Vector.Zero, nil;
        
    end

    --for _, ent in ipairs(Isaac.GetRoomEntities()) do
    for _, ent in ipairs(Isaac.FindInRadius(haniwa.Position, distance + 90, EntityPartition.ENEMY)) do
        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local distance = haniwa.Position:Distance(ent.Position)
            if (not nearestEnemy or distance < nearestDistance) then
                local canReach, nearPos, nodes = CanReach(haniwa, ent);
                if (canReach) then
                    nearestEnemy = ent;
                    nearestDistance = distance;
                    nearestPlace = nearPos;
                    nearestNodes = nodes;
                end
            end
        end
    end
    if (nearestEnemy) then
        return nearestEnemy, nearestPlace, nearestNodes;
    end

    return haniwa.Player, haniwa.Player.Position, FindPathInPos(haniwa.Position, haniwa.TargetPosition, playerFindParams);
end


local function AIRun(haniwa)

    local info = Haniwa:GetHaniwaInfo(haniwa.SubType);

    -- Find Target.
    if (haniwa:IsFrame(10, 0)) then
        local data = GetHaniwaData(haniwa, true);
        haniwa.Target, haniwa.TargetPosition, data.PathFind.CachedNodes = FindTarget(haniwa);
    end

    local targetEnt = haniwa.Target;
    if (haniwa.TargetPosition:Distance(Vector.Zero) < 0.1) then
        haniwa.TargetPosition = (targetEnt and targetEnt.Position) or haniwa.Position;
    end

    local data = GetHaniwaData(haniwa, false);
    if (data) then
        local minDistance = 20;
        if (haniwa.SubType == Haniwa.SubTypes.HANIWA_BRASS or 
        haniwa.SubType == Haniwa.SubTypes.HANIWA_KAMIKAZE ) then
            minDistance = 0;
        end
        if (targetEnt and targetEnt.Type == EntityType.ENTITY_PLAYER) then
            minDistance = 40;
        end
        MoveToTarget(haniwa, haniwa.TargetPosition, minDistance)
    end


    -- Attack.
    if (targetEnt) then
        -- Attack Target.
        if (targetEnt:IsVulnerableEnemy()) then
            if (Familiars.CanFire(haniwa)) then
                if (info.Attack) then
                    info.Attack(haniwa, targetEnt);
                end
            end
        end
    end

    Familiars.DoFireCooldown(haniwa)



    -- Sprite Update.
    local spr = haniwa:GetSprite();
    if (haniwa.Velocity:Length() > 3) then
        spr:Play("Move");
    else
        spr:Play("Idle");
    end
    
    if (targetEnt) then
        spr.FlipX = targetEnt.Position.X > haniwa.Position.X;
    end

end

local function PostFamiliarInit(mod, familiar)
    local info = Haniwa:GetHaniwaInfo(familiar.SubType);
    familiar:GetSprite():Load(info.Sprite, true);
    familiar.MaxHitPoints = info.HP;
    familiar.HitPoints = info.HP;
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND;
    familiar.SplatColor = Consts.Colors.Clear;
end
Haniwa:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostFamiliarInit, Haniwa.Variant)

local function PreFamiliarCollision(mod, familiar, other, low)
    if (familiar.SubType == Haniwa.SubTypes.HANIWA_BRASS) then
        if (other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local damage = Haniwa:GetHaniwaInfo(familiar.SubType).Damage or 1;
            if (familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                damage = damage * 2;
            end
            other:TakeDamage(damage, 0, EntityRef(familiar), 0)
            THI.SFXManager:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 2)
            Game():SpawnParticles (familiar.Position, EffectVariant.BLOOD_PARTICLE,1, 5);
        end
    end
end
Haniwa:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PreFamiliarCollision, Haniwa.Variant)

local function PreNPCCollision(mod, npc, other, low)
    if (npc.CollisionDamage > 0 and other.Type == Haniwa.Type and other.Variant == Haniwa.Variant) then
        if (npc:IsEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local damage = 1;
            other:TakeDamage(damage, 0, EntityRef(npc), 30)
        end
    end
end
Haniwa:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, PreNPCCollision)

local function PreProjectileCollision(mod, proj, other, low)
    if (proj.CollisionDamage > 0 and other.Type == Haniwa.Type and other.Variant == Haniwa.Variant) then
        if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
            local damage = 1;
            other:TakeDamage(damage, 0, EntityRef(proj), 30)
            proj:Die();
            return false;
        end
    end
end
Haniwa:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.LATE, PreProjectileCollision)

local damageLock = false;
local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == Haniwa.Type and tookDamage.Variant == Haniwa.Variant) then
        if (amount ~= 1 and not damageLock) then
            damageLock = true;
            tookDamage:TakeDamage(1, flags, source, countdown);
            damageLock = false;
            return false;
        else
            if (tookDamage.FrameCount < 15) then
                return false;
            end
            tookDamage:SetColor(Consts.Colors.HitColor, 2, 0);
        end
    end
end
Haniwa:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDamage)


local function PostEntityKill(mod ,entity)
    
    if (entity.Type == Haniwa.Type and entity.Variant == Haniwa.Variant) then
        local familiar = entity:ToFamiliar();
        THI.SFXManager:Play(SoundEffect.SOUND_POT_BREAK_2, 0.5);
        Game():SpawnParticles (entity.Position, EffectVariant.ROCK_PARTICLE,1, 5, particleColor);

        if (entity.SubType == Haniwa.SubTypes.HANIWA_KAMIKAZE) then
            local info = Haniwa:GetHaniwaInfo(entity.SubType);
            
            local damage = info.Damage;
            local scale = 1;
            if (familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                damage = damage * 2;
                scale = scale * 1.5;
            end


            Game():BombExplosionEffects(entity.Position, damage, TearFlags.TEAR_NORMAL, Color.Default, familiar.Player, scale, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR);
        end
    end
end
Haniwa:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill, Haniwa.Type)

local function PostFamiliarUpdate(mod, familiar)
    AIRun(familiar)

    -- Push each other.
    for _, ent in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.FAMILIAR)) do
        if (ent.Variant == Haniwa.Variant and not CompareEntity(familiar, ent)) then
            local dir = (ent.Position - familiar.Position):Normalized();
            if (dir:Length() <= 0.1) then
                dir = Vector(0, 1);
            end
            ent:AddVelocity(dir * 1)
        end
    end
    familiar:MultiplyFriction(0.8);
end
Haniwa:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFamiliarUpdate, Haniwa.Variant)

return Haniwa;