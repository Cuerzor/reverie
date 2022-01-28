local Ghost = ModEntity("Summoner Ghost", "SUMMONER_GHOST")
-- Main.
do 
    local function PostGhostInit(mod, ghost)
        local spr = ghost:GetSprite()
        spr:Play("Idle"..(ghost.InitSeed % 4 + 1));
    end
    Ghost:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostGhostInit, Ghost.Variant);
    local function PostGhostUpdate(mod, ghost)
        local player = Game():GetNearestPlayer (ghost.Position);
        if (player.Position:Distance(ghost.Position) <= 160) then
            ghost:AddVelocity((player.Position - ghost.Position):Resized(player.Velocity:Length() * 0.15));
        end
        ghost:MultiplyFriction(0.9);
    end
    Ghost:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostGhostUpdate, Ghost.Variant);
end


return Ghost;