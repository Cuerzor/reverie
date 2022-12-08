local Entities = CuerLib.Entities;
local LeafShieldRing = ModEntity("Leaf Shield Ring", "LeafShieldRing");

local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;

local leafColor = Color(0.8,0.8,0,1,0,0,0);

function LeafShieldRing.GetRingData(familiar, init)
    return LeafShieldRing:GetData(familiar, init, function() return {
        Fired = false
    } end)
end

function LeafShieldRing.FireRing(familiar)
    local data = LeafShieldRing.GetRingData(familiar, true);
    data.Fired = true;
end

function LeafShieldRing.IsFired(familiar)
    local data = LeafShieldRing.GetRingData(familiar, false);
    return data and data.Fired;
end

function LeafShieldRing:PostRingUpdate(familiar)
    if (familiar.Player) then
        familiar.Size = 36;
        if (familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
            familiar.Size = familiar.Size * 1.5;
        end
    end
    familiar.DepthOffset = 10;

    local game = THI.Game;
    local room = game:GetRoom();
    local data = LeafShieldRing.GetRingData(familiar, false);
    if (data and data.Fired and not room:IsPositionInRoom (familiar.Position, 0)) then
        game:SpawnParticles (familiar.Position, EffectVariant.WOOD_PARTICLE, 6, 3, leafColor);
        familiar:Die();
        THI.SFXManager:Play(SoundEffect.SOUND_SUMMON_POOF);
    end

end
LeafShieldRing:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LeafShieldRing.PostRingUpdate, LeafShieldRing.Variant);

function LeafShieldRing:PreRingCollision(familiar, other, low)
    if (other.Type == EntityType.ENTITY_PROJECTILE) then
        local proj = other:ToProjectile();
        if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
            proj:Die();
        end
    end
end
LeafShieldRing:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, LeafShieldRing.PreRingCollision, LeafShieldRing.Variant);

function LeafShieldRing:PostNewRoom()
    for i, ent in pairs(Isaac.FindByType(LeafShieldRing.Type, LeafShieldRing.Variant)) do
        local data = LeafShieldRing.GetRingData(ent, false);
        if (data and data.Fired) then
            ent:Remove();
        end
    end
end
LeafShieldRing:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LeafShieldRing.PostNewRoom);

return LeafShieldRing;