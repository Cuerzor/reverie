local CompareEntity = CuerLib.Detection.CompareEntity;
local Hekate = ModItem("Hekate", "HEKATE");

local config = Isaac.GetItemConfig():GetCollectible(Hekate.Item);

do
    local function EvaluateCache(mod, player, flag)
        if (flag == CacheFlag.CACHE_FAMILIARS) then
            local HellPlanets = THI.Familiars.HellPlanets;
            local effects = player:GetEffects();
            local count = player:GetCollectibleNum(Hekate.Item) + effects:GetCollectibleEffectNum(Hekate.Item);
            player:CheckFamiliar(HellPlanets.Variant, count, RNG(), config, HellPlanets.SubTypes.OTHERWORLD);
            player:CheckFamiliar(HellPlanets.Variant, count, RNG(), config, HellPlanets.SubTypes.EARTH);
            player:CheckFamiliar(HellPlanets.Variant, count, RNG(), config, HellPlanets.SubTypes.MOON);

            local otherworld = {};
            local earth = {};
            for i, ent in pairs(Isaac.FindByType(HellPlanets.Type, HellPlanets.Variant, HellPlanets.SubTypes.OTHERWORLD)) do
                local familiar = ent:ToFamiliar();
                if (CompareEntity(familiar.Player, player) and not familiar.Child) then
                    table.insert(otherworld, familiar);
                end
            end

            for i, ent in pairs(Isaac.FindByType(HellPlanets.Type, HellPlanets.Variant, HellPlanets.SubTypes.EARTH)) do
                local familiar = ent:ToFamiliar();
                if (CompareEntity(familiar.Player, player) and not familiar.Child) then
                    if (not familiar.Parent) then
                        local parent = otherworld[1];
                        if (parent) then
                            familiar.Parent = parent;
                            parent.Child = familiar;
                        end
                        table.remove(otherworld, 1);
                    end
                    table.insert(earth, familiar);
                end
            end
            

            for i, ent in pairs(Isaac.FindByType(HellPlanets.Type, HellPlanets.Variant, HellPlanets.SubTypes.MOON)) do
                local familiar = ent:ToFamiliar();
                if (CompareEntity(familiar.Player, player)) then
                    if (not familiar.Parent) then
                        local parent = earth[1];
                        if (parent) then
                            familiar.Parent = parent;
                            parent.Child = familiar;
                        end
                        table.remove(earth, 1);
                    end
                end
            end
        end
    end
    Hekate:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)
end

return Hekate;