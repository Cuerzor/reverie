local Stats = CuerLib.Stats;
local Jealousy = ModItem("Jealousy", "JEALOUSY");

function Jealousy:EvaluateStats(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local num = player:GetCollectibleNum(Jealousy.Item);
        if (num > 0) then
            Stats:AddDamageUp(player, num);
            Stats:MultiplyDamage(player, 0.95 ^ num);
        end
    elseif (flag == CacheFlag.CACHE_TEARCOLOR) then
        if (player:HasCollectible(Jealousy.Item)) then
            local c = player.TearColor;
            c:SetColorize(0.3, 1, 0.3, 1);
            player.TearColor = c;
            local c = player.LaserColor;
            c:SetColorize(0.3, 1, 0.3, 1);
            player.LaserColor = c;
        end
    end
end
Jealousy:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Jealousy.EvaluateStats);

function Jealousy:TakeDamage(entity, amount, flags, source, countdown)
    if (entity.Type == EntityType.ENTITY_PLAYER) then
        local player = entity:ToPlayer();
        if (flags & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) == 0) then
            if (player:HasCollectible(Jealousy.Item)) then
                player:AddCollectible(Jealousy.Item);
            end
        end
    end
end
Jealousy:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, Jealousy.TakeDamage);

return Jealousy;