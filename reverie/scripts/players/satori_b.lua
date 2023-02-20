local Stats = CuerLib.Stats;
local Players = CuerLib.Players;
local SatoriB = ModPlayer("Tainted Satori", true, "SatoriB");
SatoriB.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b.anm2");
SatoriB.CostumeHair = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_hair.anm2");
SatoriB.CostumeFlying = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_flying.anm2");
SatoriB.Sprite = "gfx/reverie/satori_b.anm2";
SatoriB.SpriteFlying = "gfx/reverie/satori_b_flying.anm2";
SatoriB.MaxAddiction = 65536;
SatoriB.MinAddiction = -65536;

local TextRNG = RNG();
local seed = Random()
if (seed == 0) then seed = 1; end
TextRNG:SetSeed(seed, 0)

-- TODO: Temporary, will be removed after ItemEffectPillEffect.EffectClass get fixed.
SatoriB.PillEffectConfigs = {
    [PillEffect.PILLEFFECT_BAD_GAS] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_BAD_TRIP] = { EffectClass = 2, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_BALLS_OF_STEEL] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_BOMBS_ARE_KEYS] = { EffectClass = 2 },
    [PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_FULL_HEALTH] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_HEALTH_DOWN] = { EffectClass = 3, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_HEALTH_UP] = { EffectClass = 3, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_I_FOUND_PILLS] = { EffectClass = 0 },
    [PillEffect.PILLEFFECT_PUBERTY] = { EffectClass = 0 },
    [PillEffect.PILLEFFECT_PRETTY_FLY] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_RANGE_DOWN] = { EffectClass = 3, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_RANGE_UP] = { EffectClass = 3, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_SPEED_DOWN] = { EffectClass = 3, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_SPEED_UP] = { EffectClass = 3, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_TEARS_DOWN] = { EffectClass = 3, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_TEARS_UP] = { EffectClass = 3, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_LUCK_DOWN] = { EffectClass = 3, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_LUCK_UP] = { EffectClass = 3, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_TELEPILLS] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_48HOUR_ENERGY] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_HEMATEMESIS] = { EffectClass = 2 },
    [PillEffect.PILLEFFECT_PARALYSIS] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_SEE_FOREVER] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_PHEROMONES] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_AMNESIA] = { EffectClass = 2, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_LEMON_PARTY] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_WIZARD] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_PERCS] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_ADDICTED] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_RELAX] = { EffectClass = 0 },
    [PillEffect.PILLEFFECT_QUESTIONMARK] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_LARGER] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_SMALLER] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_INFESTED_EXCLAMATION] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_INFESTED_QUESTION] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_POWER] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_RETRO_VISION] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_X_LAX] = { EffectClass = 0, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_SOMETHINGS_WRONG] = { EffectClass = 0, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_IM_DROWSY] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_IM_EXCITED] = { EffectClass = 1 },
    [PillEffect.PILLEFFECT_GULP] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_HORF] = { EffectClass = 0 },
    [PillEffect.PILLEFFECT_SUNSHINE] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_VURP] = { EffectClass = 2, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = { EffectClass = 1, EffectSubClass = -1 },
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = { EffectClass = 1, EffectSubClass = 1 },
    [PillEffect.PILLEFFECT_EXPERIMENTAL] = { EffectClass = 3 }
}

local Wheelchair = THI.Shared.Wheelchair;

function SatoriB:GetPlayerData(player, init)
    return SatoriB:GetData(player, init, function()
        return {
            Addiction = 0
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

function SatoriB:AddAddiction(player, value)
    local data = SatoriB:GetPlayerData(player, true);
    data.Addiction = (data.Addiction or 0) + value;
    data.Addiction = math.max(data.Addiction, SatoriB.MinAddiction);
    data.Addiction = math.min(data.Addiction, SatoriB.MaxAddiction);
end

function SatoriB:GetAddiction(player)
    local data = SatoriB:GetPlayerData(player, false);
    return (data and data.Addiction) or 0;
end

function SatoriB:GetDamageMultiplerByAddiction(addiction)
    if (addiction > 0) then
        return 0.9 ^ addiction
    elseif (addiction < 0) then
        return 2 - 0.9 ^ (-addiction);
    end
    return 1;
end

function SatoriB:GetSpeedUpByAddiction(addiction)
    return 1 - 2 ^ (addiction / 10);
end

function SatoriB:ShowHappyText(addiction)
    local hud = Game():GetHUD();
    local title, desc = "", "";
    local key = "#SATORI_ADDICTION_HAPPY";
    if (addiction < -6) then
        key = key.."_1";
    else
        key = key.."_2";
    end
    local titleKey = key.."_TITLE";
    local titleKeys = {};
    local titleIndex = 1;
    while (true) do
        local nextKey = titleKey.."_"..titleIndex;
        if (THI.GetText(nextKey, "en")) then
            table.insert(titleKeys, nextKey);
        else
            break;
        end
        titleIndex = titleIndex + 1;
    end
    local randomIndex = TextRNG:RandomInt(#titleKeys) + 1;
    title = THI.GetText(titleKeys[randomIndex]);
    --hud:ShowItemText(title, desc);
end

function SatoriB:ShowSadText(addiction)
    local hud = Game():GetHUD();
    local title, desc = "", "";
    local key = "#SATORI_ADDICTION_SAD";
    if (addiction <= 6) then
        key = key.."_1";
    else
        key = key.."_2";
    end
    local titleKey = key.."_TITLE";
    local titleKeys = {};
    local titleIndex = 1;
    while (true) do
        local nextKey = titleKey.."_"..titleIndex;
        if (THI.GetText(nextKey, "en")) then
            table.insert(titleKeys, nextKey);
        else
            break;
        end
        titleIndex = titleIndex + 1;
    end
    title = THI.GetText(titleKeys[TextRNG:RandomInt(#titleKeys) + 1]);
    --hud:ShowItemText(title, desc);
end

function SatoriB:GetPillEffectAddictionCure(effect)
    local multiplier = 1;
    local class, subclass = 0, 0;
    -- -- This is Broken.
    -- local config = Isaac.GetItemConfig():GetPillEffect(effect);
    local config = self.PillEffectConfigs[effect];
    if (config) then
        class = config.EffectClass;
        subclass = config.EffectSubClass;
    end

    if (subclass == -1) then
        multiplier = 2;
    elseif (subclass == 0) then
        multiplier = 1.5;
    end
    return class * multiplier;
end

function SatoriB:PostPlayerInit(player)
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        --player:AddHearts(-player:GetEffectiveMaxHearts() + 1);

        local game = Game();
        if (not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0)) then
            player:SetPocketActiveItem(THI.Collectibles.FinalPlan.Item, ActiveSlot.SLOT_POCKET, false);
        end
        local itemPool = game:GetItemPool();
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
            local addiction = 1;
            local curAddiction = SatoriB:GetAddiction(player);
            if (curAddiction <= -6) then
                addiction = 1-(6 + curAddiction) * 0.4;
            end
            SatoriB:AddAddiction(player, addiction);
            local speed = player.MoveSpeed;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            local addiction = SatoriB:GetAddiction(player);
            if (addiction > 0) then
                SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
                player:AnimateSad();
                SatoriB:ShowSadText(addiction);
            end
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, SatoriB.PreSpawnCleanAward)

function SatoriB:PostUseItem(item, rng, player, flags, slot, varData)
    if (player:GetPlayerType() == SatoriB.Type) then
        local addictionCure = 0;
        if (item == Reverie.Collectibles.PeerlessElixir.Item) then
            addictionCure = 4;
        end

        if (addictionCure ~= 0) then
            local lastAddiction = SatoriB:GetAddiction(player);
            SatoriB:AddAddiction(player, -addictionCure);
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            if (lastAddiction >= -6) then
                SFXManager():Play(SoundEffect.SOUND_POWERUP1);
                player:AnimateHappy();
                --SatoriB:ShowHappyText(SatoriB:GetAddiction(player));
            end
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_USE_ITEM, SatoriB.PostUseItem);

function SatoriB:PostUsePill(effect, player, flags)
    if (player:GetPlayerType() == SatoriB.Type) then
        local addictionCure = SatoriB:GetPillEffectAddictionCure(effect);

        if (addictionCure ~= 0) then
            local lastAddiction = SatoriB:GetAddiction(player);
            SatoriB:AddAddiction(player, -addictionCure);
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            if (lastAddiction >= -6) then
                SFXManager():Play(SoundEffect.SOUND_POWERUP1);
                player:AnimateHappy();
                --SatoriB:ShowHappyText(SatoriB:GetAddiction(player));
            end
        end
    end
end
SatoriB:AddCallback(ModCallbacks.MC_USE_PILL, SatoriB.PostUsePill);


function SatoriB:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == SatoriB.Type) then
        if (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, SatoriB:GetDamageMultiplerByAddiction(SatoriB:GetAddiction(player)));
        elseif (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + SatoriB:GetSpeedUpByAddiction(SatoriB:GetAddiction(player));
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