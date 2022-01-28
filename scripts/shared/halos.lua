local SaveAndLoad = CuerLib.SaveAndLoad;

local Halos = {

}

function Halos:CheckHalo(player, data, has, type, variant)
    -- Create and Remove Halo
    local halo = data.Halo;
    if (halo ~= nil and not halo:Exists()) then
        halo = nil;
    end
    if (SaveAndLoad.GameStarted) then
        if (has) then

            if (halo == nil) then
                local newHalo = Isaac.Spawn(type, variant, 0, player.Position, Vector(0,0), player);
                newHalo:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
                newHalo.DepthOffset = 300000
                newHalo.Parent = player;
                halo = newHalo;
            end
            if (halo ~= nil) then
                -- Make Halo Follows Player
                halo.Position = player.Position + Vector(0, -16);
            end
        else
            if (halo ~= nil) then
                halo:Remove();
                halo.Parent = nil;
                halo = nil
            end
        end
    end
    
    return halo;
end

return Halos;