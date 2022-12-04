local Detection = CuerLib.Detection;
local Sword = ModTrinket("Sword of Loyalty", "LOYALTY_SWORD");


Sword.BlacklistFamiliars = {
    --{Variant = FamiliarVariant.DAMOCLES}
}

local function IsEntityFit(entity, info)
    if (not info.Variant or entity.Variant == info.Variant) then
        if (not info.SubType or entity.SubType == info.SubType) then
            return true;
        end
    end
    return false;
end

function Sword:AddBlacklistFamiliar(variant, subtype)
    assert(variant, "SwordOfLoyalty: Must provide familiar variant.");
    table.insert(Sword.BlacklistFamiliars, {Variant = variant, SubType = subtype});
end

do
    -- TODO Post Collision
    local function PostFamiliarCollision(mod, familiar, other, low)
        if (familiar:IsFrame(7, 0)) then
            if (Detection.IsValidEnemy(other)) then
                local player = familiar.Player;
                if (player) then
                    local multiplier = player:GetTrinketMultiplier(Sword.Trinket);
                    if (multiplier > 0) then
                        for _, info in pairs(Sword.BlacklistFamiliars) do
                            if (IsEntityFit(familiar, info)) then
                                goto skip;
                            end
                        end
                        
                        local damage = 3.5 * multiplier;
                        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                            damage = damage * 2;
                        end
                        other:TakeDamage(damage, 0, EntityRef(familiar), 0);

                        ::skip::
                    end
                end
            end
        end
    end
    Sword:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, PostFamiliarCollision)
end

return Sword;