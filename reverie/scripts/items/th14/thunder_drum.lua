local Screen = CuerLib.Screen;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;
local Familiars = CuerLib.Familiars
local Detection = CuerLib.Detection;
local Drum = ModItem("Thunder Drum", "THUNDER_DRUM")

Drum.ItemConfig = Isaac.GetItemConfig():GetCollectible(Drum.Item);


function Drum.HasDrum(player)
    local effects = player:GetEffects();
    if (player:HasCollectible(Drum.Item) or effects:HasCollectibleEffect(Drum.Item)) then
        return true;
    end
    return false;
end

function Drum.GetDrumNum(player)
    local effects = player:GetEffects();
    return player:GetCollectibleNum(Drum.Item) + effects:GetCollectibleEffectNum(Drum.Item);
end

do
    local function EvaluateCache(mod, player, flags)
        if (flags == CacheFlag.CACHE_FAMILIARS) then 
            local count = Drum.GetDrumNum(player);
            local Familiar = THI.Familiars.ThunderDrum;
            player:CheckFamiliar(Familiar.Variant, count, RNG(), Drum.ItemConfig);
        end
    end
    Drum:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);
end
return Drum;