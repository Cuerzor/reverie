local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local Halos = THI.Halos;
local Stats = CuerLib.Stats;

local DarkRibbon = ModItem("Dark Ribbon", "DarkRibbon");
DarkRibbon.DarkHaloEntity = Isaac.GetEntityTypeByName("Dark Halo");
DarkRibbon.DarkHaloEntityVariant = Isaac.GetEntityVariantByName("Dark Halo");

local function GetPlayerData(player)
    return DarkRibbon:GetData(player, true, function() return {
        BoostedCount = 0,
        BoostCount = 0
    } end);
end

local function HasHalo(player)
    return player:HasCollectible(DarkRibbon.Item);
end

local function PostHaloInit(mod, effect)
    local spr = effect:GetSprite();
    local color = spr.Color;
    spr.Color = Color(color.R, color.G, color.B, 0.5);
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostHaloInit, DarkRibbon.DarkHaloEntityVariant)

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
    
    -- Make halos damage enemies.
    if (effect:IsFrame(7, 0)) then
        for _, ent in pairs(Isaac.FindInRadius(effect.Position, 128, EntityPartition.ENEMY)) do
            if (Detection.IsValidEnemy(ent)) then
                ent:TakeDamage (2.5, 0, EntityRef(effect), 0)
            end
        end
    end
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostHaloUpdate, DarkRibbon.DarkHaloEntityVariant)

local function PostPlayerUpdate(mod, player)
    local ribbonData = GetPlayerData(player)
    ribbonData.Halo = Halos:CheckHalo(player, ribbonData.Halo, HasHalo(player), DarkRibbon.DarkHaloEntity, DarkRibbon.DarkHaloEntityVariant)
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

local function PostPlayerEffect(mod, player)
    local ribbonData = GetPlayerData(player)
    
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
        ribbonData.BoostedCount = boostCount;
    end
end
DarkRibbon:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local ribbonData = GetPlayerData(player);
        local targetCount = ribbonData.BoostCount;
        --player.Damage = player.Damage * 1.5^targetCount;
        if (THI.IsLunatic()) then
            Stats:MultiplyDamage(player, 1.2 ^ targetCount);
        else
            Stats:MultiplyDamage(player, 1.5 ^ targetCount);
        end
    end
end
DarkRibbon:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)




return DarkRibbon;