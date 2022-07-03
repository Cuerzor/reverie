local Statue = ModTrinket("Bundled Statue", "BUNDLED_STATUE");


Statue.TrinketMultiplier = 0;

do
    local function EvaluateCache(mod, player, flag)
        if (player:HasTrinket(Statue.Trinket)) then
            if (flag == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed - 0.15;
            end
        end
    end
    Statue:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

    
    local function PostUpdate(mod)
        Statue.TrinketMultiplier = 0;
    end
    Statue:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

    local function PostPlayerEffect(mod, player)
        if (player:HasTrinket(Statue.Trinket)) then
            Statue.TrinketMultiplier = Statue.TrinketMultiplier + player:GetTrinketMultiplier(Statue.Trinket);
        end
    end
    Statue:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

    local function PostProjectileUpdate(mod, proj)
        local mult =  Statue.TrinketMultiplier ;
        if (mult > 0) then
            if (proj.Height < -10) then
                proj:AddFallingSpeed (0.08 * 2 ^ (mult - 1))
            end
        end
    end
    Statue:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, PostProjectileUpdate)
end

return Statue;