local Damages = CuerLib.Damages;
local Entities = CuerLib.Entities;
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;
local Players = CuerLib.Players;
local Sunflower = ModItem("Sunflower Pot", "Sunflower");

local Familiar = ModEntity("Sunflower Pot", "Sunflower");
local sourceItem = Isaac.GetItemConfig():GetCollectible(Sunflower.Item);

local function SearchFlowers()
    for i, ent in pairs(Isaac.FindByType(Familiar.Type, Familiar.Variant)) do
        local fam = ent:ToFamiliar();
        if (EntityExists(fam.Player)) then
            local player = fam.Player;
            local data = Sunflower.GetPlayerData(player, true);
            if (data.FlowerState >= 0) then
                data.Sunflower = fam;
                if (data.FlowerState == 1) then
                    Sunflower.Kill(fam);
                end
                break;
            else
                fam:Remove();
            end
        end
    end
end

function Sunflower.GetPlayerData(player, init)
    return Sunflower:GetData(player, init, function() return {
        FlowerState = 0,
        Sunflower = nil
    } end)
end

function Sunflower.GetFlowerData(flower, init)
    local data = flower:GetData();
    if (init) then
        data._SUNFLOWER_POT = data._SUNFLOWER_POT or {
            Dead = false,
            KillTimer = 0
        }
    end
    return data._SUNFLOWER_POT;
end

function Sunflower.Kill(flower)
    if (flower.Type == Familiar.Type and flower.Variant == Familiar.Variant) then
        local data = Sunflower.GetFlowerData(flower, true);
        if (not data.Dead) then
            THI.SFXManager:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 1, 0, false, 1.5);
            THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES, 1, 0, false, 1.5);
            flower:GetSprite():Play("Death");
            data.Dead = true;
            data.KillTimer = 60;
        end
    end
end

function Sunflower.SpawnAward(rng, flower)
    flower:GetSprite():Play("Award");
    THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
    local game =THI.Game;
    local room = game:GetRoom();
    local times = 1;
    local player = flower.Player;
    if (EntityExists(player)) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
            times = 2;
        end
    end

    for i = 1, times do
        local pos = room:FindFreePickupSpawnPosition(flower.Position, 0, true);
        --local value = rng:RandomInt(4);
        local variant = 0;--10 + value * 10;
        Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, 0, pos, Vector.Zero, flower);
    end
end

function Sunflower.Revive(player)
    local playerData = Sunflower.GetPlayerData(player, true);
    playerData.FlowerState = 0;
    local flower = playerData.Sunflower;
    if (flower) then
        local flowerData = Sunflower.GetFlowerData(flower, true);
        flowerData.Dead = false;
        flowerData.KillTimer = 0;
        flower:GetSprite():Play("Idle");
    else
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
        player:EvaluateItems();
    end
end

function Sunflower:OnEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_FAMILIARS) then
        local hasSunflower = player:HasCollectible(Sunflower.Item) or player:GetEffects():HasCollectibleEffect(Sunflower.Item);
        local data = Sunflower.GetPlayerData(player, false);
        if (data) then
            hasSunflower = hasSunflower and data.FlowerState >= 0;
        end
        local count = 0;
        if (hasSunflower) then
            count = 1;
        end
        player:CheckFamiliar(Familiar.Variant, count, RNG(), sourceItem);

        SearchFlowers();
    end
end
Sunflower:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Sunflower.OnEvaluateCache);

function Sunflower:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        local player = tookDamage:ToPlayer()
        local data = Sunflower.GetPlayerData(player, false);
        if (data and not Damages.IsSelfDamage(tookDamage, flags, source)) then
            if (EntityExists(data.Sunflower)) then
                Sunflower.Kill(data.Sunflower);
                data.FlowerState = 1;
            end
        end
    end
end
Sunflower:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, Sunflower.PostTakeDamage);

function Sunflower:PostPlayerUpdate(player)
    local playerData = Sunflower.GetPlayerData(player, false);
    if (playerData) then
        local flower = playerData.Sunflower;
        if (EntityExists(flower)) then
            flower.Velocity = player.Position - flower.Position;
            local offsetY = -40 * player.SpriteScale.Y + player:GetFlyingOffset ( ).Y;
            flower.PositionOffset = player.PositionOffset + Vector(0, offsetY);
            flower.DepthOffset = 2;
        elseif (player:HasCollectible(Sunflower.Item)) then
            SearchFlowers();
        end
    end
end
Sunflower:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Sunflower.PostPlayerUpdate);

function Sunflower:PostGameStarted(isContinued)
    SearchFlowers();
end
Sunflower:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Sunflower.PostGameStarted);

function Sunflower:PostSunflowerUpdate(familiar)
    
    local spr = familiar:GetSprite();
    if (spr:IsFinished("Award")) then
        spr:Play("Idle")
    end

    local data = Sunflower.GetFlowerData(familiar, false);
    if (data) then
        if (data.KillTimer > 0) then
            data.KillTimer = data.KillTimer - 1;
            if (data.KillTimer <= 0) then
                local game =THI.Game;
                local room = game:GetRoom();
                room:MamaMegaExplosion (familiar.Position);
                local player = familiar.Player;
                if (EntityExists(player)) then
                    local playerData = Sunflower.GetPlayerData(player, true);
                    playerData.FlowerState = -1;
                    playerData.Sunflower = nil;
                    player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_EXPLOSION, EntityRef(familiar), 0);
                end
                familiar:Remove();
            end
        end
    end
end
Sunflower:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Sunflower.PostSunflowerUpdate, Familiar.Variant);

function Sunflower:PreSpawnCleanAward(rng, pos)
    
    for i, ent in pairs(Isaac.FindByType(Familiar.Type, Familiar.Variant)) do
        local flower = ent:ToFamiliar();
        local data = Sunflower.GetFlowerData(flower, true);
        if (not data.Dead) then
            Sunflower.SpawnAward(rng, flower);
        end
    end
end
Sunflower:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Sunflower.PreSpawnCleanAward);

function Sunflower:PostNewLevel()
    local game =THI.Game;
    for p, player in Players.PlayerPairs() do
        local playerData = Sunflower.GetPlayerData(player, false);
        if (playerData) then
            if (playerData.FlowerState ~= 0) then
                Sunflower.Revive(player);
            end
        end
    end
end
Sunflower:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Sunflower.PostNewLevel);

return Sunflower;