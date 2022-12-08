local CompareEntity = CuerLib.Entities.CompareEntity;
local Lunar = ModItem("Lunar Fairy", "LUNAR_FAIRY");
local config = Isaac.GetItemConfig():GetCollectible(Lunar.Item);

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local Fairies = THI.Shared.LightFairies;
        local Familiar = THI.Familiars.LunarFairy;
        local count = player:GetCollectibleNum(Lunar.Item) + player:GetEffects():GetCollectibleEffectNum(Lunar.Item) 

        player:CheckFamiliar(Familiar.Variant, count, RNG(), config);
        local awakedNum = Familiar:GetAwakedCount(player);
        for i, ent in pairs(Isaac.FindByType(Familiar.Type, Familiar.Variant)) do
            if (awakedNum <= 0) then
                break;
            end

            local familiar = ent:ToFamiliar();
            if (CompareEntity(familiar.Player, player)) then
                if (familiar.SubType == Fairies.SubTypes.DORMANT) then
                    familiar.SubType = Fairies.SubTypes.AWAKED
                end
                awakedNum = awakedNum - 1;
            end
        end
    end
end
Lunar:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

THI.Shared.LightFairies:AddComboFairy(Lunar.Item, THI.Familiars.LunarFairy.Variant);

return Lunar;