local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local Halos = THI.Halos;

local FrozenSakura = ModItem("Frozen Sakura", "FrozenSakura");
FrozenSakura.FreezeHalo  = {
    Type = Isaac.GetEntityTypeByName("Freeze Halo"),
    Variant = Isaac.GetEntityVariantByName("Freeze Halo")
};
FrozenSakura.SlowColor = Color(1,1,1,1,0.2,0.2,0.2);

local function GetPlayerData(player, init)
    return FrozenSakura:GetData(player, init, function() return {
        Halo = nil
    } end);
end


local function HasHalo(player)
    return player:HasCollectible(FrozenSakura.Item);
end

local function PostHaloUpdate(mod, effect)
    local parent = effect.Parent;
    if (not parent) then
        effect:Remove();
        return;
    else
        local player = parent:ToPlayer();
        local playerData = GetPlayerData(player, false);
        local halo = playerData and playerData.Halo;
        if (player and not CompareEntity(halo, effect)) then
            effect:Remove();
            return;
        end
    end


    local ref = EntityRef(effect);
    -- Make halos damage enemies and slow bullets.
    if (effect:IsFrame(7, 0)) then
        for _, ent in pairs(Isaac.FindInRadius(effect.Position, 128, EntityPartition.ENEMY | EntityPartition.BULLET)) do
            if (Detection.IsValidEnemy(ent)) then
                ent:TakeDamage(1, 0, ref, 0)
                ent:AddEntityFlags(EntityFlag.FLAG_ICE);
                ent:AddSlowing (ref, 30, 0.5, FrozenSakura.SlowColor);
                local entData = ent:GetData();
                entData.Reverie_FreezeTimeout = 1;
            elseif (ent.Type == EntityType.ENTITY_PROJECTILE) then
                local projectile = ent:ToProjectile();
                projectile:AddProjectileFlags (ProjectileFlags.SLOWED);
            end
        end
    end
end
FrozenSakura:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostHaloUpdate, FrozenSakura.FreezeHalo.Variant)

local function PostNPCUpdate(mod, npc)
    local data = npc:GetData();
    if (data.Reverie_FreezeTimeout and data.Reverie_FreezeTimeout >= 0) then
        data.Reverie_FreezeTimeout = data.Reverie_FreezeTimeout - 1;
        if (data.Reverie_FreezeTimeout < 0) then
            npc:ClearEntityFlags(EntityFlag.FLAG_ICE);
            data.Reverie_FreezeTimeout = nil;
        end
    end
end
FrozenSakura:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)


local function PostPlayerUpdate(mod, player)
    local data = GetPlayerData(player, false);
    local prevHalo = not not (data and data.Halo);
    local hasHalo = HasHalo(player);
    if (prevHalo ~= hasHalo or prevHalo) then
        data = GetPlayerData(player, true);
        data.Halo = Halos:CheckHalo(player, data.Halo, hasHalo, FrozenSakura.FreezeHalo.Type, FrozenSakura.FreezeHalo.Variant)
    end
end
FrozenSakura:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

return FrozenSakura;