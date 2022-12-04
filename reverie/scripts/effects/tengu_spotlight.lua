local Spotlight = ModEntity("Tengu Spotlight", "TenguSpotlight");

local normalColor = Color(0,1,0,0.3,0,0,0);
local shotColor = Color(1,1,1,1,1,1,1);
local maxShotTime = 30;

function Spotlight:GetSpotlightData(spotlight, init)
    return Spotlight:GetData(spotlight, init, function() return {
        ShotTime = 0
    } end);
end

function Spotlight:PostEffectInit(effect)
    effect:GetSprite().Color = normalColor;
end
Spotlight:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Spotlight.PostEffectInit, Spotlight.Variant);

function Spotlight:PostEffectUpdate(effect)
    local data = Spotlight:GetSpotlightData(effect, true);
    local shotTime = (data and data.ShotTime) or 0;
    effect:GetSprite().Color = Color.Lerp(normalColor, shotColor, shotTime / maxShotTime);

    if (data and data.ShotTime > 0) then
        data.ShotTime = data.ShotTime - 1;
    end
end
Spotlight:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Spotlight.PostEffectUpdate, Spotlight.Variant);

return Spotlight;