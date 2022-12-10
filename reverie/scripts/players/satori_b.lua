local Stats = CuerLib.Stats;
local SatoriB = ModPlayer("Tainted Satori", true, "SatoriB");
SatoriB.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b.anm2");
SatoriB.CostumeHair = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_hair.anm2");
SatoriB.CostumeFlying = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_satori_b_flying.anm2");
SatoriB.Sprite = "gfx/reverie/satori_b.anm2";
SatoriB.SpriteFlying = "gfx/reverie/satori_b_flying.anm2";

local Wheelchair = THI.Shared.Wheelchair;

local function GetPlayerTempData(player, init)
    return SatoriB:GetTempData(player, init, function()
        return {
            SpriteState = 0
        }
    end)
end


function SatoriB.GetPlayerData(player, init)
    local data = player:GetData();
    if (init) then
        if (not data._SATORI_B) then
            data._SATORI_B = {
                SpeedUp = 0,
                HasBirthright = false
            }
        end
    end
    return data._SATORI_B;
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


function SatoriB:PostPlayerInit(player)
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        player:AddHearts(-player:GetEffectiveMaxHearts() + 1);
        local itemPool = THI.Game:GetItemPool();
        local pillColor = itemPool:ForceAddPillEffect(PillEffect.PILLEFFECT_HEMATEMESIS);
        itemPool:IdentifyPill (pillColor);
        player:AddPill(pillColor);
        local data = SatoriB.GetPlayerData(player, true);
    end
end
SatoriB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SatoriB.PostPlayerInit)


function SatoriB:PostPlayerUpdate(player)
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        UpdatePlayerSprite(player);
        Wheelchair:PlayerUpdate(player);
    else
        
    end
end
SatoriB:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SatoriB.PostPlayerUpdate)

function SatoriB:PostPlayerEffect(player)
    
    local playerType = player:GetPlayerType();
    if (playerType == SatoriB.Type) then
        local data = SatoriB.GetPlayerData(player, true);
        local br = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT);
        if (data.HasBirthright ~= br) then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            data.HasBirthright = br;
        end
        Wheelchair:PlayerEffect(player);
    end
end

SatoriB:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SatoriB.PostPlayerEffect)

function SatoriB:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == SatoriB.Type) then
        if (cache == CacheFlag.CACHE_SPEED) then
            local limit = 1;
            local multi = 0.5;
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                limit = 1.25;
                multi = 0.675;
            end
            player.MoveSpeed = player.MoveSpeed * multi;
            Stats:SetSpeedLimit(player, limit);
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 0.8);
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
            if (player.MoveSpeed >= 1) then
                Isaac.Explode(player.Position, player, damage)
            end
        end

        player:SetMinDamageCooldown(60);
    end
end
Wheelchair:AddCallback(SatoriB, Wheelchair.Callbacks.WC_POST_CRUSH_NPC, SatoriB.PostCrushEnemy);

return SatoriB;