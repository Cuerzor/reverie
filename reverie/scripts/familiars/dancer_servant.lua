local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;

local Dancer = ModEntity("Dancer Servant", "DANCER_SERVANT");

Dancer.SubTypes = {
    MAI = 0,
    SANATO = 1,
}
Dancer.MaiColor = Color(0,1,0,1,0,0,0);
Dancer.SanatoColor = Color(1,0,1,1,0,0,0);

local function GetNPCData(npc, create)
    return Dancer:GetData(npc, create, function ()
        return {
            RedHeartTimeout = -1,
            SoulHeartTimeout = -1
        }
    end)
end

function Dancer:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 1, 0, position, velocity, familiar):ToTear();
    
    tear.CollisionDamage = 3;
    if (familiar.SubType == Dancer.SubTypes.SANATO) then
        tear.CollisionDamage = 2;
        tear:SetColor(Dancer.SanatoColor, -1, 0);
    else
        tear:SetColor(Dancer.MaiColor, -1, 0);
    end

    
    Familiars.ApplyTearEffect(player, tear);


    tear.Scale = Math.GetTearScaleByDamage(tear.CollisionDamage);
    return tear;
end

local AnimationNames = {
    [Direction.LEFT] = "Left",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Right",
    [Direction.DOWN] = "Down",
}
local function AnimationUpdate(familiar, direction)

    if (direction == Direction.NO_DIRECTION) then
        direction = Direction.DOWN;
    end
    local sprite = familiar:GetSprite();
    if (familiar.HeadFrameDelay > 0) then
        sprite:Play("FloatShoot"..AnimationNames[direction]);
    else
        sprite:Play("Float"..AnimationNames[direction]);
    end
end

local function PostDancerInit(mod, familiar)
    if (familiar.SubType == Dancer.SubTypes.SANATO) then
        local sprite = familiar:GetSprite();
        sprite:Load("gfx/reverie/003.5828.1_dancer servant sanato.anm2")
    end


end
Dancer:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostDancerInit, Dancer.Variant)

local function PostDancerUpdate(mod, familiar)
    local player = familiar.Player;
    local dir = player:GetFireDirection();
    
    if (familiar.OrbitLayer < 0) then
        familiar:AddToOrbit(581);
    end
    familiar.OrbitSpeed = 0.2;
    familiar.OrbitDistance = EntityFamiliar.GetOrbitDistance (1);
    
    local fireDir = -Familiars:GetFireVector(familiar, dir)
    Familiars:DoFireCooldown(familiar);

    local maxFireCooldown = 15;
    if (familiar.SubType == Dancer.SubTypes.SANATO) then
        maxFireCooldown = 10;
    end

    if (dir ~= Direction.NO_DIRECTION and Familiars:canFire(familiar)) then
        familiar.HeadFrameDelay = 7;
        familiar.FireCooldown = maxFireCooldown;
        Dancer:FireTear(familiar, familiar.Position, fireDir * 10);
        familiar.ShootDirection = Math.GetDirectionByAngle(fireDir:GetAngleDegrees());
    end

    if (Familiars:canFire(familiar)) then
        familiar.ShootDirection = Direction.NO_DIRECTION;
    end
    
    AnimationUpdate(familiar, familiar.ShootDirection);
    
    local parent = familiar.Parent or player;
    familiar.Velocity = parent.Position + familiar:GetOrbitPosition(Vector.Zero) - familiar.Position;
    
end
Dancer:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostDancerUpdate, Dancer.Variant)

local function PostNPCTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage:IsActiveEnemy(true)) then
        local sourceEnt = source.Entity;
        local servant = nil;
        if (sourceEnt) then
            if (sourceEnt.Type == Dancer.Type and sourceEnt.Variant == Dancer.Variant) then
                servant = sourceEnt;
            elseif (sourceEnt.SpawnerEntity) then
                local spawner = sourceEnt.SpawnerEntity;
                if (spawner.Type == Dancer.Type and spawner.Variant == Dancer.Variant) then
                    servant = spawner;
                end
            end
        end
        if (servant) then
            local data = GetNPCData(tookDamage, true)
            if (sourceEnt.SubType == Dancer.SubTypes.SANATO) then
                if (Random() % 100 < 20) then
                    data.RedHeartTimeout = 2;
                end
            else
                if (Random() % 100 < 10) then
                    data.SoulHeartTimeout = 2;
                end
            end
        end
    end
end
Dancer:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostNPCTakeDamage);

local function PostNPCUpdate(mod, npc)
    local data = GetNPCData(npc, false)
    if (data) then
        local dead = npc:IsDead();
        if (data.RedHeartTimeout >= 0) then
            data.RedHeartTimeout = data.RedHeartTimeout - 1;
            if (dead) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, npc.Position, Vector.Zero, npc);
                data.RedHeartTimeout = -1;
            end
        end
        
        if (data.SoulHeartTimeout >= 0) then
            data.SoulHeartTimeout = data.SoulHeartTimeout - 1;
            if (dead) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, npc.Position, Vector.Zero, npc);
                data.SoulHeartTimeout = -1;
            end
        end
    end
end
Dancer:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)

return Dancer;