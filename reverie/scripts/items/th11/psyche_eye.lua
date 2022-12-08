
local Entities = CuerLib.Entities;
local PsycheEye = ModItem("Psyche Eye", "PsycheEye");

local itemConfig = Isaac.GetItemConfig();

local CompareEntity= Entities.CompareEntity;
local EntityExists = Entities.EntityExists;

function PsycheEye:OnEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_FAMILIARS) then
        local EyeFam = THI.Familiars.PsycheEye;
        local effects = player:GetEffects();
        local count = player:GetCollectibleNum(PsycheEye.Item) + effects:GetCollectibleEffectNum(PsycheEye.Item);
        if (player:GetPlayerType() == THI.Players.Satori.Type) then
            count = count + 1;
        end
        local sourceItem = itemConfig:GetCollectible(PsycheEye.Item);
        player:CheckFamiliar(EyeFam.Variant, count, RNG(), sourceItem);

        -- Check Eyes.
        local index = 1;
        for i, eye in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, EyeFam.Variant)) do
            if (CompareEntity(eye:ToFamiliar().Player, player) and eye:Exists()) then
                local data = EyeFam.GetFamiliarTempData(eye, true);
                data.Index = index;
                index = index + 1;
            end
        end
        local playerData = EyeFam.GetPlayerData(player, false);
        if (index > 1 or playerData) then
            playerData = EyeFam.GetPlayerData(player, true);
            playerData.EyeCount = index - 1;
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PsycheEye.OnEvaluateCache)

return PsycheEye;