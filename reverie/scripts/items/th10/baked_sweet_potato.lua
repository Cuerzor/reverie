local Stats = CuerLib.Stats;
local SweetPotato = ModItem("Baked Sweet Potato", "SweetPotato");

SweetPotato.BuffDamage = 5;
SweetPotato.DecayTime = 3600;
SweetPotato.DecayInternal = 14;
SweetPotato.DecayTimes = math.ceil(SweetPotato.DecayTime / SweetPotato.DecayInternal);
SweetPotato.DecaySpeed = SweetPotato.BuffDamage / SweetPotato.DecayTimes;

function SweetPotato.GetPlayerData(player, init)
    return SweetPotato:GetData(player, init, function() return {
        Buffed = false,
        BuffDamage = 0,
    } end)
end


function SweetPotato:PostPlayerEffect(player)
    if (player.FrameCount % SweetPotato.DecayInternal == 0) then
        local data = SweetPotato.GetPlayerData(player, false);
        if (data) then
            if (data.Buffed) then
                data.BuffDamage = data.BuffDamage - SweetPotato.DecaySpeed;
                if (data.BuffDamage <= 0) then
                    data.BuffDamage = 0;
                    data.Buffed = false;
                end 
            end
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
            player:EvaluateItems();
        end
    end
end
SweetPotato:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SweetPotato.PostPlayerEffect);

function SweetPotato:OnEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_DAMAGE) then
        local data = SweetPotato.GetPlayerData(player, false);
        if (data) then
            if (data.Buffed) then
                Stats:AddFlatDamage(player, data.BuffDamage);
            end
        end
    end
end
SweetPotato:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SweetPotato.OnEvaluateCache);

function SweetPotato:PostGainPotato(player, item, count, touched)
    if (not touched) then
        local data = SweetPotato.GetPlayerData(player, true);
        data.Buffed = true;
        data.BuffDamage = 5;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
        player:EvaluateItems();
    end
end
SweetPotato:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, SweetPotato.PostGainPotato, SweetPotato.Item);

return SweetPotato;