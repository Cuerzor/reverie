local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;

local Koakuma = ModItem("Koakuma Baby", "Koakuma");
Koakuma.Baby = Isaac.GetEntityTypeByName("Koakuma Baby");
Koakuma.BabyVariant = Isaac.GetEntityVariantByName("Koakuma Baby");
Koakuma.rng = RNG();

function Koakuma:GetKoakumaData(familiar) 
    return Koakuma:GetData(familiar, true, function() return {
        IsFollowing = false,
        rng = RNG()
    } end);
end


function Koakuma:onEvaluateCache(player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local item = Isaac.GetItemConfig():GetCollectible(Koakuma.Item);
        local count = player:GetCollectibleNum(Koakuma.Item) + player:GetEffects():GetCollectibleEffectNum(Koakuma.Item) 
        player:CheckFamiliar(Koakuma.BabyVariant, count, Koakuma.rng, item);
    end
end
Koakuma:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Koakuma.onEvaluateCache)

function Koakuma:FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 1, 0, position, velocity, familiar):ToTear();
    
    tear.CollisionDamage = 3;
    
    Familiars.ApplyTearEffect(player, tear);

    local Grimoire = THI.Collectibles.Grimoire;
    Grimoire:ApplyTearEffects(player, tear);
    
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
        tear.Scale = 4;
    else
        tear.Scale = 2;
    end
    return tear;
end



function Koakuma:onKoakumaUpdate(familiar)
    local player = familiar.Player;
    local data = Koakuma:GetKoakumaData(familiar);
    local dir = player:GetFireDirection();
    
    if (not data.IsFollowing) then
        familiar:AddToFollowers();
        data.IsFollowing = true;
    end
    
    local fireDir = Familiars.GetFireVector(familiar, dir)
    local direction = familiar.ShootDirection;
    Familiars.DoFireCooldown(familiar);
    if (dir ~= Direction.NO_DIRECTION and Familiars.CanFire(familiar) and (player == nil or player:IsExtraAnimationFinished())) then
        
        familiar.HeadFrameDelay = 7;
        familiar.FireCooldown = 10;
        if (player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM)) then
            local offset = fireDir:Rotated(90) * 7;
            if (data.rng:RandomInt(4) < 1) then
                Koakuma:FireTear(familiar, familiar.Position + offset, fireDir * 10);
            end
            Koakuma:FireTear(familiar, familiar.Position - offset, fireDir * 10);
        else
            Koakuma:FireTear(familiar, familiar.Position, fireDir * 10);
        end
        familiar.ShootDirection = Math.GetDirectionByAngle(fireDir:GetAngleDegrees());
        direction = familiar.ShootDirection;
    end

    if (Familiars.CanFire(familiar)) then
        familiar.ShootDirection = Direction.NO_DIRECTION;
    end
    
    Familiars.AnimationUpdate(familiar, Consts.DirectionVectors[direction]);
    
    familiar:FollowParent();
end
Koakuma:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Koakuma.onKoakumaUpdate, Koakuma.BabyVariant)

return Koakuma;