local Consts = CuerLib.Consts;
local Detection = CuerLib.Detection;
local MathTool = CuerLib.Math;
local Familiars = CuerLib.Familiars;
local CompareEntity = CuerLib.Detection.CompareEntity;
local ChenBaby = ModItem("Chen Baby", "ChenBaby");
ChenBaby.Baby = {
    Type = Isaac.GetEntityTypeByName("Chen Baby"),
    Variant = Isaac.GetEntityVariantByName("Chen Baby")
};
ChenBaby.rng = RNG();
ChenBaby.Damage = 3.5;
ChenBaby.Speed = 15;

function ChenBaby:GetChenData(familiar) 
    return ChenBaby:GetData(familiar, true, function() return {
        IsFollowing = false,
        IsCharging = false,
        IsChargeOver = false,
        ChargeCooldown = 30,
        ChargeRestoreTime = 30,
        DamagedEnemy = nil;
    } end);
end


function ChenBaby:onEvaluateCache(player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(ChenBaby.Item);
        
        local count = player:GetCollectibleNum(ChenBaby.Item) + player:GetEffects():GetCollectibleEffectNum(ChenBaby.Item) 
        player:CheckFamiliar(ChenBaby.Baby.Variant, count, ChenBaby.rng, item);
    end
end
function ChenBaby:Charge(familiar, dir)
    local data = ChenBaby:GetChenData(familiar);
    data.IsCharging = true;
    familiar:RemoveFromFollowers();
    local velocity = Familiars:GetFireVector(familiar, dir, false, 1000) * ChenBaby.Speed;
    familiar.Velocity = velocity;
end

function ChenBaby:Collided(familiar)
    local room = THI.Game:GetRoom();
    local radius = familiar.Size / 2;
    for i=0,3 do 
        local position = familiar.Position + Consts.DirectionVectors[i] * radius;
        local collision = room:GetGridCollisionAtPos(position);
        if (collision == GridCollisionClass.COLLISION_WALL or collision == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER) then
            return true;
        end
    end
    return false;
end

function ChenBaby:FindEnemy(familiar)
    local data = ChenBaby:GetChenData(familiar);
    local distance = 100000;
    local target = nil;
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        local dis = (ent.Position - familiar.Position):Length();
        if (dis < distance) then
            if (Detection.IsValidEnemy(ent) and not CompareEntity(data.DamagedEnemy, ent)) then
                distance = dis;
                target = ent;
            end
        end
    end
    return target;
end
function ChenBaby:preChenCollision(familiar, collider, low)
    local data = ChenBaby:GetChenData(familiar);
    if (data.IsCharging) then
        if (Detection.IsValidEnemy(collider)) then
            if (not CompareEntity(data.DamagedEnemy, collider)) then
                local damage = ChenBaby.Damage;
                if (familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    damage = damage * 2;
                end
                if (familiar.Player:HasCollectible(THI.Collectibles.OneOfNineTails.Item)) then
                    damage = damage * 2;
                end
                collider:TakeDamage(damage, 0, EntityRef(familiar), 0);
                data.DamagedEnemy = collider;
                local target = ChenBaby:FindEnemy(familiar);
                if (target ~= nil) then
                    local velocity = (target.Position - familiar.Position):Normalized() * ChenBaby.Speed;
                    familiar.Velocity = velocity;
                else
                    data.IsChargeOver = true;
                end
            end
        end
    end
end

function ChenBaby:UpdateAnimation(familiar)
    local data = ChenBaby:GetChenData(familiar);

    if (data.IsCharging) then
        local velocity = familiar.Velocity;
        if (velocity.X ~= 0 or velocity.Y ~= 0) then
            local dir = MathTool.GetDirectionByAngle(velocity:GetAngleDegrees());
            Familiars:PlayShootAnimation(familiar, dir);
        end
    else
        Familiars:PlayNormalAnimation(familiar, Direction.DOWN);
    end
end

function ChenBaby:onChenUpdate(familiar)
    local player = familiar.Player;
    local data = ChenBaby:GetChenData(familiar);
    local dir = player:GetFireDirection();
    
    if (not data.IsCharging) then
        if (data.ChargeCooldown <= 0) then
            if (dir ~= Direction.NO_DIRECTION) then
                ChenBaby:Charge(familiar, dir);
            end
        else
            if (data.ChargeCooldown > 0) then
                data.ChargeCooldown = data.ChargeCooldown - 1;
            end
        end
    else
        if (ChenBaby:Collided(familiar)) then
            data.IsChargeOver = true;
        end
        if (data.IsChargeOver) then
            familiar.Velocity = Vector(0,0);
            if (data.ChargeRestoreTime > 0) then
                data.ChargeRestoreTime = data.ChargeRestoreTime - 1;
            end
            if (data.ChargeRestoreTime <= 0) then
                data.IsCharging = false;
                data.ChargeRestoreTime = 30;
                data.IsChargeOver = false;
                data.DamagedEnemy = nil;
                data.ChargeCooldown = 30;
            end
        end
    end
    ChenBaby:UpdateAnimation(familiar)
    
    if (data.IsCharging == data.IsFollowing) then
        data.IsFollowing = not data.IsCharging;
        if (data.IsFollowing) then
            familiar:AddToFollowers();
        end
    end
    
    if (data.IsFollowing) then
        familiar:FollowParent();
    end
end
ChenBaby:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, ChenBaby.preChenCollision, ChenBaby.Baby.Variant);
ChenBaby:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ChenBaby.onChenUpdate, ChenBaby.Baby.Variant);
ChenBaby:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ChenBaby.onEvaluateCache);
return ChenBaby;