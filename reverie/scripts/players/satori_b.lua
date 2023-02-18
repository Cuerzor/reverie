local Stats = CuerLib.Stats;
local Players = CuerLib.Players;
local SatoriB = ModPlayer("Tainted Satori", true, "SatoriB");
SatoriB.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b.anm2");
SatoriB.CostumeHair = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_hair.anm2");
SatoriB.CostumeFlying = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_flying.anm2");
SatoriB.Sprite = "gfx/reverie/satori_b.anm2";
SatoriB.SpriteFlying = "gfx/reverie/satori_b_flying.anm2";
SatoriB.SpeedDownBase = 0.03;
SatoriB.SpeedDownPerRoomPerStage = 0.006;
SatoriB.SpeedUpPerPill = 0.3;
SatoriB.MaxSpeedUp = 2;
SatoriB.MinSpeedUp = -10000000;

local Wheelchair = THI.Shared.Wheelchair;

function SatoriB:GetPlayerData(player, init)
    return SatoriB:GetData(player, init, function()
        return {
            SpeedUp = 0
        }
    end)
end

local function GetPlayerTempData(player, init)
    return SatoriB:GetTempData(player, init, function()
        return {
            SpriteState = 0
        }
    end)
end

local function UpdatePlayerSprite(player)
    local data = GetPlayerTempData(player, true);
    local sprState = 1;
    local path = SatoriB.Sprite;
    if (player.CanFly) then
        path = SatoriB.SpriteFlying;
        sprState = 2;
    end
    if (data.SpriteState ~= sprState) then
        data.SpriteState = sprState;
        local spr = player:GetSprite();
        local animation = spr:GetAnimation();
        local frame = spr:GetFrame();
        local overlayAnimation = spr:GetOverlayAnimation();
        local overlayFrame = spr:GetOverlayFrame();
        spr:Load(path, true);
        spr:SetFrame(animation, frame);
        spr:SetOverlayFrame(overlayAnimation, overlayFrame);
    end
end

function SatoriB:AddSpeedUp(player, value)
    local data = SatoriB:GetPlayerData(player, true);
    data.SpeedUp = data.SpeedUp + value;
    data.SpeedUp = math.max(data.SpeedUp, SatoriB.MinSpeedUp);
    local maxSpeedUp = SatoriB.MaxSpeedUp;
    if (not (player:GetPlayerType() == SatoriB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))) then
        data.SpeedUp = math.min(data.SpeedUp, SatoriB.MaxSpeedUp);
    end
end

function SatoriB:PostPlayerInit(player)
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        player:AddHearts(-player:GetEffectiveMaxHearts() + 1);
        local itemPool = THI.Game:GetItemPool();
        local pillColor = itemPool:ForceAddPillEffect(PillEffect.PILLEFFECT_HEMATEMESIS);
        itemPool:IdentifyPill (pillColor);
        player:AddPill(pillColor);
    end
end
SatoriB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SatoriB.PostPlayerInit)


function SatoriB:PostPlayerUpdate(player)
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        UpdatePlayerSprite(player);
        Wheelchair:PlayerUpdate(player);
    end
end
SatoriB:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SatoriB.PostPlayerUpdate)

function SatoriB:PostPlayerEffect(player)
    
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        Wheelchair:PlayerEffect(player);
    end
end

SatoriB:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SatoriB.PostPlayerEffect)


function SatoriB:PreSpawnCleanAward(rng, spawnPos)
    for p, player in Players.PlayerPairs() do
        if (player:GetPlayerType() == SatoriB.Type) then
            SatoriB:AddSpeedUp(player, -(SatoriB.SpeedDownBase + SatoriB.SpeedDownPerRoomPerStage * Game():GetLevel():GetStage()));
            local speed = player.MoveSpeed;
            player:AddCacheFlags(CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            if (player.MoveSpeed < speed) then
                SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
            end
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, SatoriB.PreSpawnCleanAward)


function SatoriB:PostUsePill(effect, player, flags)
    if (player:GetPlayerType() == SatoriB.Type) then
        local data = SatoriB:GetPlayerData(player, true);
        local multi = 1;
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            multi = 2;
        end
        SatoriB:AddSpeedUp(player, SatoriB.SpeedUpPerPill * multi);
        player:AddCacheFlags(CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
        SFXManager():Play(SoundEffect.SOUND_POWERUP1);
    end
end
SatoriB:AddCallback(ModCallbacks.MC_USE_PILL, SatoriB.PostUsePill);


function SatoriB:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == SatoriB.Type) then
        if (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 0.8);
        elseif (cache == CacheFlag.CACHE_SPEED) then
            local data = SatoriB:GetPlayerData(player, false);
            player.MoveSpeed = player.MoveSpeed + ((data and data.SpeedUp) or 0);
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SatoriB.OnEvaluateCache)


function SatoriB:PreTakeDamage(tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        local player = tookDamage:ToPlayer();
        if (player and player:GetPlayerType() == SatoriB.Type) then
            local sourceType = source.Type;
            local variant = source.Variant;
            if (sourceType == EntityType.ENTITY_EFFECT and (
            variant == EffectVariant.CREEP_RED or
            variant == EffectVariant.CREEP_GREEN or
            variant == EffectVariant.CREEP_YELLOW or
            variant == EffectVariant.CREEP_WHITE or
            variant == EffectVariant.CREEP_BLACK)) then
                return false;
            end

            if (flags & DamageFlag.DAMAGE_SPIKES > 0 and flags & DamageFlag.DAMAGE_NO_PENALTIES <= 0) then
                return false;
            end
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SatoriB.PreTakeDamage);


function SatoriB:PostCrushEnemy(source, crushed, damage)
    local player = source:ToPlayer();
    if (player and player:GetPlayerType() == SatoriB.Type) then
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			Game():BombExplosionEffects (crushed.Position, 100,player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR);
        end

        player:SetMinDamageCooldown(60);
    end
end
Wheelchair:AddCallback(SatoriB, Wheelchair.Callbacks.WC_POST_CRUSH_NPC, SatoriB.PostCrushEnemy);

return SatoriB;