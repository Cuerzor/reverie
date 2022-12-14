local Stats = CuerLib.Stats;
local Actives = CuerLib.Actives;
local Players = CuerLib.Players;

local PeerlessElixir = ModItem("Peerless Elixir", "PeerlessElixir");

local maxUseTime = 4;
function PeerlessElixir.GetPlayerData(player, init)
    local data = THI.GetData(player);
    if (init) then
        data.PeerlessElixir = data.PeerlessElixir or {
            UsedTime = 0
        }
    end
    return data.PeerlessElixir;
end

function PeerlessElixir:onUseElixir(item,rng,player,flags,slot,data)
    local playerData = PeerlessElixir.GetPlayerData(player, true);
    THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP, 1, 2,false, 1 + playerData.UsedTime / (maxUseTime));
    if (playerData.UsedTime + 1 < maxUseTime) then
        playerData.UsedTime = playerData.UsedTime + 1;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
    else
        player:Kill();
        local room = THI.Game:GetRoom();
        room:MamaMegaExplosion(player.Position);
        
    end
    player:AddCacheFlags(CacheFlag.CACHE_COLOR);
    player:EvaluateItems();
    return {ShowAnim = true };
end
PeerlessElixir:AddCallback(ModCallbacks.MC_USE_ITEM, PeerlessElixir.onUseElixir, PeerlessElixir.Item)


function PeerlessElixir:onEvaluateCache(player, cache)
    local playerData = PeerlessElixir.GetPlayerData(player, false);
    if (playerData) then
        if (cache == CacheFlag.CACHE_COLOR) then
            if (playerData.UsedTime > 0) then
                
                local currentColor = player:GetColor();
                local otherComp = 1 - playerData.UsedTime / maxUseTime;
                
                local newColor = Color(otherComp, 1,otherComp, 1);
                player:SetColor(newColor, -1, 49, false, true);
            end
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            -- bonus = ((((damage / multi - flat)/character)^2)-1)/1.2
            -- damage = (character * (bonus * 1.2 + 1) ^ 0.5 + flat) * multi

            -- local multi = 1;
            -- local flat = 0;
            -- local character = 3.5;
            -- local bounsSqrt = (player.Damage / multi - flat)/character;
            -- local bonus = ((bounsSqrt * bounsSqrt)-1)/1.2
            -- bonus = bonus + playerData.UsedTime * 0.6;

            -- player.Damage = (character * math.sqrt(bonus * 1.2 + 1) + flat) * multi;
            Stats:AddDamageUp(player, playerData.UsedTime * 0.6);
        elseif (cache == CacheFlag.CACHE_FIREDELAY) then
            Stats:AddTearsUp(player, 0.6 * playerData.UsedTime)
        elseif (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.3 * playerData.UsedTime;
        end
    end
end
PeerlessElixir:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PeerlessElixir.onEvaluateCache);

function PeerlessElixir:onNewLevel()
    local game = THI.Game;
    for p, player in Players.PlayerPairs() do
        local playerData = PeerlessElixir.GetPlayerData(player);
        if (playerData) then
            playerData.UsedTime = 0;
            player:AddCacheFlags(CacheFlag.CACHE_COLOR | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end
    end
end
PeerlessElixir:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PeerlessElixir.onNewLevel);


local WispExplosionColor = Color(1,1,1,1,0,1,0);
function PeerlessElixir:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == PeerlessElixir.Item) then
        THI.Game:BombExplosionEffects (familiar.Position, 20, TearFlags.TEAR_NORMAL, WispExplosionColor, familiar, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
    end
end
PeerlessElixir:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PeerlessElixir.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);



function PeerlessElixir:GetShaderParams(name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        Actives:RenderActivesCount(PeerlessElixir.Item, function(player) 
            local data = PeerlessElixir.GetPlayerData(player);
            return (data and data.UsedTime) or 0;
        end);
    end
end
PeerlessElixir:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, PeerlessElixir.GetShaderParams);

return PeerlessElixir;