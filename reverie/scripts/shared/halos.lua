local Halos = {

}

function Halos:CheckHalo(player, halo, has, type, variant)
    -- Create and Remove Halo
    if (halo and not halo:Exists()) then
        halo = nil;
    end

    if (Game():GetFrameCount() > 0) then
        if (has) then
            if (not halo) then
                local newHalo = Isaac.Spawn(type, variant, 0, player.Position, Vector(0,0), player);
                newHalo:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
                newHalo.DepthOffset = 300000
                newHalo.Parent = player;
                halo = newHalo;
            end
            if (halo) then
                -- Make Halo Follows Player
                halo.Position = player.Position + Vector(0, -16);
            end
        else
            if (halo) then
                halo:Remove();
                halo.Parent = nil;
                halo = nil;
            end
        end
    end
    
    return halo;
end

return Halos;