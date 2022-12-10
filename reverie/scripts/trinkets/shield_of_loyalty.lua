local Shield = ModTrinket("Shield of Loyalty", "LOYALTY_SHIELD");

Shield.DeathFamiliars = {
    {Variant = FamiliarVariant.BLUE_FLY},
    {Variant = FamiliarVariant.BLUE_SPIDER},
}


Shield.BlacklistFamiliars = {
    {Variant = FamiliarVariant.DAMOCLES}
}

local function IsEntityFit(entity, info)
    if (not info.Variant or entity.Variant == info.Variant) then
        if (not info.SubType or entity.SubType == info.SubType) then
            return true;
        end
    end
    return false;
end

function Shield:AddDeathFamiliar(variant, subtype)
    assert(variant, "ShieldOfLoyalty: Must provide familiar variant.");
    table.insert(Shield.DeathFamiliars, {Variant = variant, SubType = subtype});
end
function Shield:AddBlacklistFamiliar(variant, subtype)
    assert(variant, "ShieldOfLoyalty: Must provide familiar variant.");
    table.insert(Shield.BlacklistFamiliars, {Variant = variant, SubType = subtype});
end

do
    local function PostFamiliarCollision(mod, familiar, other, low)
        if (other.Type == EntityType.ENTITY_PROJECTILE) then
            local proj = other:ToProjectile();
            if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                local player = familiar.Player;
                if (player) then
                    if (player:HasTrinket(Shield.Trinket)) then
                        for _, info in pairs(Shield.BlacklistFamiliars) do
                            if (IsEntityFit(familiar, info)) then
                                goto skip;
                            end
                        end
                        other:Die();
                        
                        for _, info in pairs(Shield.DeathFamiliars) do
                            if (IsEntityFit(familiar, info)) then
                                familiar:Die();
                                break;
                            end
                        end

                        ::skip::
                    end
                end
            end
        end
    end
    Shield:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PostFamiliarCollision)
end

return Shield;