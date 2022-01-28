local Detection = CuerLib.Detection;
local Halos = THI.Halos;
local Stats = CuerLib.Stats;

local DarkRibbon = ModItem("Dark Ribbon", "DarkRibbon");
DarkRibbon.DarkHaloEntity = Isaac.GetEntityTypeByName("Dark Halo");
DarkRibbon.DarkHaloEntityVariant = Isaac.GetEntityVariantByName("Dark Halo");

function DarkRibbon:GetPlayerData(player)
    return DarkRibbon:GetData(player, true, function() return {
        BoostedCount = 0,
        BoostCount = 0
    } end);
end

function DarkRibbon:GetHaloData(halo)
    return DarkRibbon:GetData(halo, true, function() return {
        DamageCoolDown = 0,
        Player = nil
    } end);
end
function DarkRibbon.HasHalo(player)
    return player:HasCollectible(DarkRibbon.Item);
end

function DarkRibbon:PostHaloInit(effect)
    local spr = effect:GetSprite();
    local color = spr.Color;
    spr.Color = Color(color.R, color.G, color.B, 0.5);
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, DarkRibbon.PostHaloInit, DarkRibbon.DarkHaloEntityVariant)

function DarkRibbon:onHaloUpdate(effect)
    -- Make halos damage enemies.
    local haloData = DarkRibbon:GetHaloData(effect);
    local cooldown = haloData.DamageCoolDown;
    if (effect.Parent == nil) then
        effect:Remove();
        return;
    else
        local player = effect.Parent:ToPlayer();
        if (player and not DarkRibbon.HasHalo(player)) then
            effect:Remove();
            return;
        end
    end

    --local alpha = 0.5;
    -- if (THI.IsLunatic()) then
    --     --alpha = 0.75
    --     effect.Scale = 0.75;
    --     effect.SpriteScale = Vector(0.75, 0.75);
    -- else
    --     effect.Scale = 1;
    --     effect.SpriteScale = Vector(1, 1);
    -- end
    -- local spr = effect:GetSprite();
    -- local color = spr.Color;
    -- spr.Color = Color(color.R, color.G, color.B, alpha);

    
    cooldown = cooldown - 1
    if (cooldown <= 0) then
        for index, ent in pairs(Isaac:GetRoomEntities()) do
            if (Detection.IsValidEnemy(ent) and ent.Position:Distance(effect.Position) < 128 * effect.Scale + ent.Size / 2) then
                ent:TakeDamage (2.5, 0, EntityRef(effect), 0)
            end
        end
        cooldown = 7;
    end
    haloData.DamageCoolDown = cooldown;
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DarkRibbon.onHaloUpdate, DarkRibbon.DarkHaloEntityVariant)




function DarkRibbon:onPlayerUpdate(player)
    local ribbonData = DarkRibbon:GetPlayerData(player)
    ribbonData.Halo = Halos:CheckHalo(player, ribbonData, DarkRibbon.HasHalo(player), DarkRibbon.DarkHaloEntity, DarkRibbon.DarkHaloEntityVariant)
end

function DarkRibbon:onPlayerEffect(player)
    local ribbonData = DarkRibbon:GetPlayerData(player)
    local ribbon = DarkRibbon.HasHalo(player);
    
    -- Damage Boost
    local boostCount = 0;
    for i, e in pairs(Isaac.FindByType(DarkRibbon.DarkHaloEntity, DarkRibbon.DarkHaloEntityVariant)) do
        if (player.Position:Distance(e.Position) < 128) then
            boostCount = boostCount + 1;
        end
    end
    ribbonData.BoostCount = boostCount;
    if (boostCount ~= ribbonData.BoostedCount) then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        ribbonData.BoostedCount = targetCount
    end
end

function DarkRibbon:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local ribbonData = DarkRibbon:GetPlayerData(player);
        local targetCount = ribbonData.BoostCount;
        --player.Damage = player.Damage * 1.5^targetCount;
        if (THI.IsLunatic()) then
            Stats:MultiplyDamage(player, 1.2 ^ targetCount);
        else
            Stats:MultiplyDamage(player, 1.5 ^ targetCount);
        end
    end
end



DarkRibbon:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DarkRibbon.onEvaluateCache)
DarkRibbon:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DarkRibbon.onPlayerUpdate)
DarkRibbon:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DarkRibbon.onPlayerEffect)

return DarkRibbon;