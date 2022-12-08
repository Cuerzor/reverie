local Entities = CuerLib.Entities;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;
local Mod = THI;
local TenguCamera = ModItem("Tengu Camera", "TenguCamera");


-- local LightSprite = Sprite();
-- LightSprite:Load("gfx/spotlight.anm2", true);
-- LightSprite:Play("Idle");
-- LightSprite.Color = normalColor;
local maxShotTime = 30;



function TenguCamera:GetPlayerData(player, init)
    return TenguCamera:GetData(player, init, function() return {
        Score = 0,
        ScoreTime = 0,
        Spotlight = nil
    } end)
end

function TenguCamera:GetPlayerScore(player)
    local data = self:GetPlayerData(player, false)
    return (data and data.Score) or 0;
end

local objList = {
    Projectiles = {},
    Enemies = {}
};

local function IsInRange(player, ent)
    local dir = Vector.FromAngle(player:GetSmoothBodyRotation()):Normalized();
    local entToPlayer = ent.Position - player.Position;
    if (entToPlayer:Length() > 360) then
        return false;
    end
    local entToPlayerNormalized = entToPlayer:Normalized();

    local dot = entToPlayerNormalized:Dot(dir);
    local angle = math.acos(dot) / math.pi * 180;
    return angle <= 30;
end

local function ClearObjList()
    for k, _ in pairs(objList.Projectiles) do
        objList.Projectiles[k] = nil;
    end

    for k, _ in pairs(objList.Enemies) do
        objList.Enemies[k] = nil;
    end
end
local function AddProjectile(projectile)
    
    local key = tostring(projectile.Variant);
    objList.Projectiles[key] = (objList.Projectiles[key] or 0) + 1;
end
local function AddEnemy(enemy)
    local key = enemy.Type.."."..enemy.Variant;
    objList.Enemies[key] = (objList.Enemies[key] or 0) + 1;
end
local function GetSameProjectileCount(projectile)
    local num = 0;
    for k, v in pairs(objList.Projectiles) do
        if (tostring(projectile.Variant) == k) then
            num = num + v;
        end
    end
    return num;
end


local function GetSameEnemyCount(enemy)
    local num = 0;
    for k, v in pairs(objList.Enemies) do
        if (enemy.Type.."."..enemy.Variant == k) then
            num = num + v;
        end
    end
    return num;
end

local function GetProjectileScore(projectile)
    local sameCount = GetSameProjectileCount(projectile);
    local base = 2;
    local multiplier = 0.1;
    return base/(sameCount*multiplier+1);
end

local function GetEnemyScore(enemy)
    local sameCount = GetSameEnemyCount(enemy);
    local base = 4;
    local multiplier = 0.1;
    if (enemy:IsBoss()) then
        base = 12;
        multiplier = 5;
    end
    return base/(sameCount*multiplier+1);
end

local function SpawnBonus(player, score)
    local room = Game():GetRoom();
    local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
    if (score >= 10) then
        if (score < 12) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, pos, Vector.Zero, player);
        elseif (score < 16) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 1, pos, Vector.Zero, player);
        elseif (score < 22) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 1, pos, Vector.Zero, player);
        elseif (score < 30) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, pos, Vector.Zero, player);
        elseif (score < 40) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, pos, Vector.Zero, player);
        elseif (score < 52) then            
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, pos, Vector.Zero, player);
        elseif (score < 66) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, player);
        elseif (score < 82) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_NEGATIVE, pos, Vector.Zero, player);
        elseif (score < 100) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_TORN_PHOTO, pos, Vector.Zero, player);
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, pos, Vector.Zero, player);
        end 
    end

    local sfx = SFXManager();
    if (score >= 60) then
        if (score < 100) then
            sfx:Play(SoundEffect.SOUND_THUMBSUP);
        else
            sfx:Play(SoundEffect.SOUND_THUMBSUP_AMPLIFIED);
        end
    end
end

function TenguCamera:PostUseCamera(item, rng, player, flags, slot, varData)
    local spotlight = Mod.Effects.TenguSpotlight;
    if (flags & UseFlag.USE_CARBATTERY <= 0) then
        local hasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY);
        local damage = 5;
        if (hasCarBattery) then
            damage = damage * 2;
        end

        local score = 0;
        local judasBook = Players.HasJudasBook(player);
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if (ent.Type == EntityType.ENTITY_PROJECTILE) then
                if (IsInRange(player, ent)) then
                    -- Projectile
                    ent:Remove();

                    score = score + GetProjectileScore(ent);
                    AddProjectile(ent);

                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
                        player:AddWisp (TenguCamera.Item, ent.Position)
                    end
                end
            elseif (Entities.IsValidEnemy(ent)) then
                -- Enemy.
                if (IsInRange(player, ent)) then
                    local ref = EntityRef(player);
                    local freezeTime = 150;
                    if (Mod.IsLunatic()) then
                        freezeTime = 120;
                    end
                    ent:AddFreeze(ref, freezeTime);
                    if (judasBook) then
                        ent:AddBurn(EntityRef(player), 150, player.Damage);
                    end
                    ent:TakeDamage(damage, 0, ref, 0)

                    score = score + GetEnemyScore(ent);
                    AddEnemy(ent);
                end
            end
        end

        
        ClearObjList();
        if (hasCarBattery) then
            score = score * 1.5;
        end

        if (judasBook and score > 0) then
            Mod:AddTemporaryDamage(player, score * 0.03, 150, false);
        end
        
        local data = TenguCamera:GetPlayerData(player, true);
        
        data.Score = score;
        data.ScoreTime = 120;
        if (data.Spotlight) then
            local spotlightData = spotlight:GetSpotlightData(data.Spotlight, true);
            spotlightData.ShotTime = maxShotTime;
        end
        SpawnBonus(player, score);

        local sfx = SFXManager();
        -- sfx:Play(SoundEffect.SOUND_FORTUNE_COOKIE);
        -- sfx:Play(SoundEffect.SOUND_FLASHBACK);
        sfx:Play(Mod.Sounds.SOUND_TOUHOU_SHUTTER);
        return {ShowAnim = true}
    end
end
TenguCamera:AddCallback(ModCallbacks.MC_USE_ITEM, TenguCamera.PostUseCamera, TenguCamera.Item);


function TenguCamera:PostPlayerUpdate(player)
    

    local data = TenguCamera:GetPlayerData(player, false);
    if (data) then
        
        if (data.ScoreTime > 0) then
            data.ScoreTime = data.ScoreTime - 1;
        end
    end
end
TenguCamera:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TenguCamera.PostPlayerUpdate);

function TenguCamera:PostPlayerEffect(player)
    local spotlight = Mod.Effects.TenguSpotlight;
    if (player:GetActiveItem() == TenguCamera.Item or 
        player:GetActiveItem(ActiveSlot.SLOT_POCKET) == TenguCamera.Item) then
        
        local data = TenguCamera:GetPlayerData(player, true);
        if (not data.Spotlight or not data.Spotlight:Exists()) then
            data.Spotlight = Isaac.Spawn(spotlight.Type, spotlight.Variant, 0, player.Position, Vector.Zero, player):ToEffect();
            data.Spotlight.Parent = player;
        end
        data.Spotlight.Rotation = player:GetSmoothBodyRotation() - 90;
        data.Spotlight.SpriteRotation = data.Spotlight.Rotation;
        data.Spotlight.Position = player.Position;
    else
        
        local data = TenguCamera:GetPlayerData(player, false);
        if (data and data.Spotlight and data.Spotlight:Exists()) then
            data.Spotlight:Remove();
            data.Spotlight = nil;
        end
    end
end
TenguCamera:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, TenguCamera.PostPlayerEffect);


function TenguCamera:PostRender()
    local game = Game();
    for p, player in Players.PlayerPairs() do
        local pos = Screen.GetEntityRenderPosition(player);
        
        local data = TenguCamera:GetPlayerData(player, false);
        if (data and data.ScoreTime > 0) then
            local alpha = data.ScoreTime / 30;
            local fontColor = KColor(1,1,1,alpha);
            local scoreStr = Mod.GetText(Mod.StringCategories.DEFAULT, "#SCORE");
            local enFont = Mod.GetFont("CAMERA_SCORE", "en");
            local font = Mod.GetFont("CAMERA_SCORE");
            local scoreWidth = font:GetStringWidthUTF8(scoreStr);
            local scoreValueStr = string.format("%.2f",data.Score);
            local valueWidth = enFont:GetStringWidthUTF8(scoreValueStr);
            font:DrawStringUTF8 (scoreStr, pos.X - scoreWidth / 2, pos.Y - 64, fontColor);
            enFont:DrawStringUTF8 (scoreValueStr, pos.X - valueWidth / 2, pos.Y - 52, fontColor);
        end
    end
end
TenguCamera:AddCallback(ModCallbacks.MC_POST_RENDER, TenguCamera.PostRender);

return TenguCamera;