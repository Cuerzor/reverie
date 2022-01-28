local Detection = CuerLib.Detection;
local Halos = THI.Halos;

local FrozenSakura = ModItem("Frozen Sakura", "FrozenSakura");
FrozenSakura.FreezeHalo  = {
    Type = Isaac.GetEntityTypeByName("Freeze Halo"),
    Variant = Isaac.GetEntityVariantByName("Freeze Halo")
};
FrozenSakura.SlowColor = Color(1,1,1,1,0.2,0.2,0.2);

function FrozenSakura:GetPlayerData(player, init)
    return FrozenSakura:GetData(player, init, function() return {
        Halo = nil
    } end);
end

function FrozenSakura:GetNPCData(npc, init)
    return FrozenSakura:GetData(npc, init, function() return {
        WillFreeze = false,
        UnfreezeTime = 0,
    } end);
end

function FrozenSakura:GetHaloData(halo, init)
    return FrozenSakura:GetData(halo, init, function() return {
        DamageCoolDown = 0
    } end);
end

function FrozenSakura.HasHalo(player)
    return player:HasCollectible(FrozenSakura.Item);
end

function FrozenSakura:onHaloUpdate(effect, variant)
    -- Make halos damage enemies.
    local haloData = FrozenSakura:GetHaloData(effect, true);
    local cooldown = haloData.DamageCoolDown;
    if (effect.Parent == nil) then
        effect:Remove();
        return;
    else
        if (effect.Type == EntityType.ENTITY_PLAYER and not FrozenSakura.HasHalo(effect:ToPlayer())) then
            effect:Remove();
            return;
        end
    end
    cooldown = cooldown - 1
    local ref = EntityRef(effect);
    if (cooldown <= 0) then
        for index, ent in pairs(Isaac:GetRoomEntities()) do
            if (ent.Position:Distance(effect.Position) < 128 + ent.Size / 2) then
                if (Detection.IsValidEnemy(ent)) then
                    ent:TakeDamage(1, 0, ref, 0)
                    ent:AddEntityFlags(EntityFlag.FLAG_ICE);
                    ent:AddSlowing (ref, 30, 0.5, FrozenSakura.SlowColor);
                    local entData = FrozenSakura:GetNPCData(ent, true);
                    entData.WillFreeze = true;
                    entData.UnfreezeTime = 2;
                end
            end
        end
        cooldown = 7;
    end
    haloData.DamageCoolDown = cooldown;

    for index, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
        if (ent.Position:Distance(effect.Position) < 128 + ent.Size / 2) then
            local projectile = ent:ToProjectile();
            projectile:AddProjectileFlags (ProjectileFlags.SLOWED);
        end
    end
end

function FrozenSakura:onNPCUpdate(npc)
    local data = FrozenSakura:GetNPCData(npc, false);
    if (data and data.WillFreeze) then
        data.UnfreezeTime = data.UnfreezeTime - 1;
        if (data.UnfreezeTime <= 0) then
            data.WillFreeze = false;
            npc:ClearEntityFlags(EntityFlag.FLAG_ICE);
        end
    end
end


function FrozenSakura:onPlayerUpdate(player)
    local data = FrozenSakura:GetPlayerData(player, true)
    data.Halo = Halos:CheckHalo(player, data, FrozenSakura.HasHalo(player), FrozenSakura.FreezeHalo.Type, FrozenSakura.FreezeHalo.Variant)
end


FrozenSakura:AddCallback(ModCallbacks.MC_NPC_UPDATE, FrozenSakura.onNPCUpdate)
FrozenSakura:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FrozenSakura.onHaloUpdate, FrozenSakura.FreezeHalo.Variant)
FrozenSakura:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, FrozenSakura.onPlayerUpdate)

return FrozenSakura;