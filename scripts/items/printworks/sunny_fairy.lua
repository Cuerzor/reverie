local CompareEntity = CuerLib.Detection.CompareEntity;
local Sunny = ModItem("Sunny Fairy", "SUNNY_FAIRY");
local config = Isaac.GetItemConfig():GetCollectible(Sunny.Item);

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local Fairies = THI.Shared.LightFairies;
        local Familiar = THI.Familiars.SunnyFairy;
        local count = player:GetCollectibleNum(Sunny.Item) + player:GetEffects():GetCollectibleEffectNum(Sunny.Item) 

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
Sunny:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

THI.Shared.LightFairies:AddComboFairy(Sunny.Item, THI.Familiars.SunnyFairy.Variant);

return Sunny;