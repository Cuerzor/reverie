local Illusion = ModItem("Illusion", "Illusion");
Illusion.rng = RNG();

function Illusion:onEvaluateCache(player, flag)

    if (flag == CacheFlag.CACHE_FAMILIARS) then 
        local Familiar = THI.Familiars.Illusion;
        local item = Isaac.GetItemConfig():GetCollectible(Illusion.Item);
        
        local count = player:GetCollectibleNum(Illusion.Item) + player:GetEffects():GetCollectibleEffectNum(Illusion.Item) 
        count = count * 4;
        player:CheckFamiliar(Familiar.Variant, count, Illusion.rng, item);

        local illusions =Isaac.FindByType(EntityType.ENTITY_FAMILIAR, Familiar.Variant);
        for i = #illusions, 1, -1 do
            if (not illusions[i]:Exists()) then
                table.remove(illusions, i);
            end
        end
        for i, ent in pairs(illusions) do
            if (ent:ToFamiliar().Player.InitSeed == player.InitSeed) then
                local familiarData = Familiar.GetIllusionData(ent, true);
                familiarData.Index = i;
                familiarData.Count = #illusions;
            end
        end
    end
end
Illusion:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Illusion.onEvaluateCache);

return Illusion;