local Actives = CuerLib.Actives;
local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local CompareEntity = Entities.CompareEntity;
local Pipe = ModItem("Delusion Pipe", "DELUSION_PIPE");

Pipe.DecaySpeed = 10 / 900 * 7;

local function GetGlobalData(create)
    local function getter()
        return {
            SeeingQuad = 0
        }
    end
    return Pipe:GetGlobalData(create, getter);
end

local function GetPlayerData(player, create)
    local function getter()
        return {
            LuckUp = 0,
            JudasDamageUp = 0,
        }
    end
    return Pipe:GetData(player, create, getter);
end



local function PostUpdate(mod)
    local seeingQuad = 0;
    for p, player in Players.PlayerPairs() do
        local playerData = GetPlayerData(player, false);
        if (playerData and playerData.LuckUp > 0) then
            if (player:IsFrame(7, 0)) then
                playerData.LuckUp =  math.max(0, playerData.LuckUp - Pipe.DecaySpeed);
                player:AddCacheFlags(CacheFlag.CACHE_LUCK);
                player:EvaluateItems()
            end
            
            seeingQuad = math.max(seeingQuad, playerData.LuckUp / 30);
        end
    end
    if (seeingQuad > 0) then
        local globalData = GetGlobalData(true);
        local targetQuad = globalData.SeeingQuad;
        if (seeingQuad > targetQuad) then
            targetQuad = math.min(seeingQuad, targetQuad + 0.01);
        elseif (seeingQuad < targetQuad) then
            targetQuad = math.max(seeingQuad, targetQuad - 0.01);
        end
        globalData.SeeingQuad = targetQuad;
    end
end
Pipe:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

local function PostUsePipe(mod, item, rng, player, flags, slot, varData)
    local playerData = GetPlayerData(player, true);
    playerData.LuckUp = math.min(100, playerData.LuckUp + 10);
    player:AddCacheFlags(CacheFlag.CACHE_LUCK);

    THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);

    -- if (Actives:CanSpawnWisp(player, flags)) then
    --     local hasWisp = false;
    --     for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Pipe.Item)) do
    --         if (CompareEntity(ent:ToFamiliar().Player, player)) then
    --             hasWisp = true;
    --             break;
    --         end
    --     end
    --     if (not hasWisp) then
    --         player:AddWisp(Pipe.Item, player.Position);
    --     end
    -- end
    
    
    if (Players.HasJudasBook(player)) then
        local playerData = GetPlayerData(player, true);
        playerData.JudasDamageUp = math.max(playerData.JudasDamageUp or 0, playerData.LuckUp / 10 );
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    end
    player:EvaluateItems()
    return {ShowAnim = true;}
end
Pipe:AddCallback(ModCallbacks.MC_USE_ITEM, PostUsePipe, Pipe.Item);

local function PostWispUpdate(mod, familiar)
    if (familiar.SubType == Pipe.Item) then
        local player = familiar.Player;
        if (player) then
            local playerData = GetPlayerData(player, false);
            local hp = (playerData and playerData.LuckUp / 10 * 2) + 2 or 2;
            local diff = hp - familiar.MaxHitPoints;
            familiar.MaxHitPoints = hp;
            if (diff > 0) then
                familiar.HitPoints = familiar.HitPoints + diff;
            end
            familiar.HitPoints = math.min(familiar.HitPoints, hp);
            if (hp <= 0) then
                familiar:Die();
            end
        end
    end
end
Pipe:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostWispUpdate, FamiliarVariant.WISP);

local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_LUCK) then
        local playerData = GetPlayerData(player, false);
        if (playerData) then
            player.Luck = player.Luck + playerData.LuckUp;
        end
    elseif (flag == CacheFlag.CACHE_DAMAGE) then
        local playerData = GetPlayerData(player, false);
        if (playerData) then
            Stats:AddDamageUp(player, playerData.JudasDamageUp);
        end
    end
end
Pipe:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

local function PostNewLevel(mod)
    for p, player in Players.PlayerPairs() do
        local playerData = GetPlayerData(player, false);
        if (playerData) then
            playerData.JudasDamageUp = 0;
            
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
            player:EvaluateItems();
        end
    end
end
Pipe:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

local function GetShaderParams(mod, name)
    if (name == "Reverie Delusion Pipe") then
        local seeingQuad = 0;
        local globalData = GetGlobalData(false);
        if (globalData) then
            seeingQuad = globalData.SeeingQuad;
        end
        return {
            Offset = seeingQuad ^ 0.5,
            Alpha = math.min(1, seeingQuad ^ 0.5),
        }
    end
end
Pipe:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);

return Pipe;