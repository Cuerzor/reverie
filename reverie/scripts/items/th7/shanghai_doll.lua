local Detection = CuerLib.Detection;
local MathTool = CuerLib.Math;

local ShanghaiDoll = ModItem("Shanghai Doll", "ShanghaiDoll");
ShanghaiDoll.Doll = {
    Type = Isaac.GetEntityTypeByName("Shanghai Doll"),
    Variant = Isaac.GetEntityVariantByName("Shanghai Doll"),
    DirectionAnimations = {
        [Direction.NO_DIRECTION] = "Down",
        [Direction.LEFT] = "Left",
        [Direction.UP] = "Up",
        [Direction.RIGHT] = "Right",
        [Direction.DOWN] = "Down"
    }
};
local soundRNG = RNG();
ShanghaiDoll.rng = RNG();
ShanghaiDoll.Damage = 3;
ShanghaiDoll.ChargeRange = 90;

ShanghaiDoll.ItemConfig = Isaac.GetItemConfig():GetCollectible(ShanghaiDoll.Item);


function ShanghaiDoll:GetDollData(familiar, init) 
    return ShanghaiDoll:GetData(familiar, init, function() return {
        IsOrbiting = false,
        IsCharging = false,
        targetPosition = Vector.Zero,
        ChargeTime = 0,
        Direction = Direction.NO_DIRECTION,
    } end);
end


function ShanghaiDoll:onEvaluateCache(player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local effects = player:GetEffects();
        local count = player:GetCollectibleNum(ShanghaiDoll.Item) + effects:GetCollectibleEffectNum(ShanghaiDoll.Item);
        player:CheckFamiliar(ShanghaiDoll.Doll.Variant, count, ShanghaiDoll.rng, ShanghaiDoll.ItemConfig);
    end
end

function ShanghaiDoll:CheckCharge(familiar) 
    local player = familiar.Player;
    local data = ShanghaiDoll:GetDollData(familiar, true);
    if (not data.IsCharging) then
        for _,ent in pairs(Isaac.GetRoomEntities()) do
            if (Detection.IsValidEnemy(ent) and player.Position:Distance(ent.Position) <= ShanghaiDoll.ChargeRange + ent.Size) then
                data.IsCharging = true;
                local distance = ent.Position - familiar.Position;
                data.targetPosition = ent.Position + distance:Normalized() * 75;
                data.ChargeTime = 5;
                data.Direction = MathTool.GetDirectionByAngle(distance:GetAngleDegrees());
                THI.SFXManager:Play(SoundEffect.SOUND_KNIFE_PULL, 0.8, 0, false, 1.25 + soundRNG:RandomFloat() * 0.5);
            end
        end
    end
end

function ShanghaiDoll:PostDollCollision(familiar, collider, low)
    
    local player = familiar.Player;
    if (low) then
        if (Detection.IsValidEnemy(collider)) then 
            local damage = ShanghaiDoll.Damage;
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                damage = damage * 2;
            end
            collider:TakeDamage(damage, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(familiar), 5);
            return
        end
        if (collider.Type == EntityType.ENTITY_PROJECTILE) then
            collider:Die();
        end
    end
end

function ShanghaiDoll:onDollUpdate(familiar)
    local player = familiar.Player;
    local data = ShanghaiDoll:GetDollData(familiar, true);
    local sprite = familiar:GetSprite();

    if (not data.IsOrbiting) then
        data.IsOrbiting = true;
        if (data.IsOrbiting) then
            familiar:AddToOrbit(0);
            familiar.OrbitDistance = EntityFamiliar.GetOrbitDistance (0);
            familiar.OrbitSpeed = 0.045;
        end
    end

    ShanghaiDoll:CheckCharge(familiar);

    local targetPosition = familiar:GetOrbitPosition(player.Position + player.Velocity);
    if (data.IsCharging) then
        targetPosition = data.targetPosition;
        
        sprite:Play("Charge"..ShanghaiDoll.Doll.DirectionAnimations[data.Direction])
        if (data.ChargeTime <= 0) then
            data.IsCharging = false;
            data.ChargeTime = 0;
        end
        data.ChargeTime = data.ChargeTime - 1;
    else
        local moveDir = player:GetMovementDirection();
        sprite:Play("Float"..ShanghaiDoll.Doll.DirectionAnimations[moveDir])
    end

    familiar.Velocity = (targetPosition - familiar.Position) * 0.3;
end

ShanghaiDoll:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, ShanghaiDoll.PostDollCollision, ShanghaiDoll.Doll.Variant);
ShanghaiDoll:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ShanghaiDoll.onDollUpdate, ShanghaiDoll.Doll.Variant);
ShanghaiDoll:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ShanghaiDoll.onEvaluateCache);

return ShanghaiDoll;