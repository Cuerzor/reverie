local CompareEntity = CuerLib.Entities.CompareEntity;
local Star = ModItem("Star Fairy", "STAR_FAIRY");
local config = Isaac.GetItemConfig():GetCollectible(Star.Item);

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_FAMILIARS) then 
        local Fairies = THI.Shared.LightFairies;
        local Familiar = THI.Familiars.StarFairy;
        local count = player:GetCollectibleNum(Star.Item) + player:GetEffects():GetCollectibleEffectNum(Star.Item) 

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
Star:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

THI.Shared.LightFairies:AddComboFairy(Star.Item, THI.Familiars.StarFairy.Variant);

return Star;