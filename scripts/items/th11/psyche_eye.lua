
local Detection = CuerLib.Detection;
local PsycheEye = ModItem("Psyche Eye", "PsycheEye");

local itemConfig = Isaac.GetItemConfig();

local CompareEntity= Detection.CompareEntity;
local EntityExists = Detection.EntityExists;

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
        local playerData = EyeFam.GetPlayerData(player, true);
        playerData.EyeCount = index - 1;
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PsycheEye.OnEvaluateCache)

-- function PsycheEye:PostChangePsycheEye(player, item, diff)
--     THI:EvaluateCurses();
-- end
-- PsycheEye:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, PsycheEye.PostChangePsycheEye, PsycheEye.Item);

-- function PsycheEye:EvaluateCurse(curses)
--     for i, player in Detection.PlayerPairs(true, true) do
--         local effects = player:GetEffects();
--         if (player:HasCollectible(PsycheEye.Item) or effects:HasCollectibleEffect(PsycheEye.Item)) then
--             return curses & ~(LevelCurse.CURSE_OF_BLIND | LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_THE_UNKNOWN);    
--         end
--     end
-- end
-- PsycheEye:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, PsycheEye.EvaluateCurse, 0, -100);

return PsycheEye;