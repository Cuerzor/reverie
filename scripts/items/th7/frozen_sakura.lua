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

local function GetNPCData(npc, init)
    return FrozenSakura:GetData(npc, init, function() return {
        WillFreeze = false,
        FreezeTimeout = 0,
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
        local playerData = GetPlayerData(player);
        if (player and not CompareEntity(playerData.Halo, effect)) then
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
                local entData = GetNPCData(ent, true);
                entData.WillFreeze = true;
                entData.FreezeTimeout = 1;
            elseif (ent.Type == EntityType.ENTITY_PROJECTILE) then
                local projectile = ent:ToProjectile();
                projectile:AddProjectileFlags (ProjectileFlags.SLOWED);
            end
        end
    end
end
FrozenSakura:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostHaloUpdate, FrozenSakura.FreezeHalo.Variant)

local function PostNPCUpdate(mod, npc)
    local data = GetNPCData(npc, false);
    if (data and data.WillFreeze) then
        data.FreezeTimeout = data.FreezeTimeout - 1;
        if (data.FreezeTimeout < 0) then
            data.WillFreeze = false;
            npc:ClearEntityFlags(EntityFlag.FLAG_ICE);
        end
    end
end
FrozenSakura:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)


local function PostPlayerUpdate(mod, player)
    local data = GetPlayerData(player, true)
    data.Halo = Halos:CheckHalo(player, data.Halo, HasHalo(player), FrozenSakura.FreezeHalo.Type, FrozenSakura.FreezeHalo.Variant)
end
FrozenSakura:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

return FrozenSakura;