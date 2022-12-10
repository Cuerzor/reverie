local Stats = CuerLib.Stats;
local SaveAndLoad = CuerLib.SaveAndLoad;
local Stats = CuerLib.Stats;
local Players = CuerLib.Players;

local TheInfamies = ModItem("The Infamies", "TheInfamies");
local rootPath = "gfx/reverie/characters/";
TheInfamies.Costumes = {
    Isaac.GetCostumeIdByPath(rootPath.."costume_the_infamies_pleasure.anm2"),
    Isaac.GetCostumeIdByPath(rootPath.."costume_the_infamies_anger.anm2"),
    Isaac.GetCostumeIdByPath(rootPath.."costume_the_infamies_sorrow.anm2"),
    Isaac.GetCostumeIdByPath(rootPath.."costume_the_infamies_fearness.anm2")
};
TheInfamies.NormalHeartGFX = "gfx/familiar/familiar_276_isaacsheart.png";
TheInfamies.MaskedHeartGFX = "gfx/reverie/familiar/isaacsheart_masked.png";

function TheInfamies.GetPlayerData(player, init)
    return TheInfamies:GetData(player, init, function() return {
        Form = 1,
        HasItem = false
    } end);
end

function TheInfamies.GetIsaacHeartData(heart, init)
    return TheInfamies:GetData(heart, init, function() return {
        Masked = false
    } end);
end

local function IsMaskOrHeart(npc)
    local isMask = npc.Type == EntityType.ENTITY_MASK or 
    npc.Type == EntityType.ENTITY_HEART;
    
    if (not THI.IsLunatic()) then
        isMask = isMask or npc.Type == EntityType.ENTITY_MASK_OF_INFAMY or
        npc.Type == EntityType.ENTITY_HEART_OF_INFAMY or
        npc.Type == EntityType.ENTITY_VISAGE;
    end
    return isMask;
end

local function HasItem()
    local game = THI.Game;
    for p, player in Players.PlayerPairs(true, true) do
        if (player:HasCollectible(TheInfamies.Item)) then
            return true, player;
        end
    end
    return false;
end

function TheInfamies:PostUpdate()
    local has, player = HasItem();
    if (has) then
        for i, ent in pairs(Isaac.GetRoomEntities()) do 
            if (IsMaskOrHeart(ent)) then
                if (not ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
                    ent:AddCharmed(EntityRef(player), -1)
                    ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_FRIENDLY_BALL);
                end
            end
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_POST_UPDATE, TheInfamies.PostUpdate); 

function TheInfamies:PostHeartUpdate(familiar)
    local player = familiar.Player;
    if (player) then
        local heartData = TheInfamies.GetIsaacHeartData(familiar);
        if (not heartData or not heartData.Masked) then
            if (player:HasCollectible(TheInfamies.Item)) then
                local spr = familiar:GetSprite();
                spr:ReplaceSpritesheet(0, TheInfamies.MaskedHeartGFX);
                spr:LoadGraphics();
                heartData = TheInfamies.GetIsaacHeartData(familiar, true);
                heartData.Masked = true;
            end
        else
            if (not player:HasCollectible(TheInfamies.Item)) then
                local spr = familiar:GetSprite();
                spr:ReplaceSpritesheet(0, TheInfamies.NormalHeartGFX);
                spr:LoadGraphics();
                heartData.Masked = false;
            end
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, TheInfamies.PostHeartUpdate, FamiliarVariant.ISAACS_HEART); 

-- Ignore Projectile Damage.
function TheInfamies:PrePlayerTakeDamage(tookDamage, amount ,flags, source, countdown)
    local player = tookDamage:ToPlayer();
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_HEART) and
        player:HasCollectible(TheInfamies.Item)) then
        if (source.Type == EntityType.ENTITY_PROJECTILE) then
            return false;
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TheInfamies.PrePlayerTakeDamage, EntityType.ENTITY_PLAYER); 

function TheInfamies:PreProjectileCollision(projectile, other, low)
    -- Ignore Projectile Collision and destroy the projectile.
    -- if other is Isaac's Heart
    if (other.Type == 3 and other.Variant == 62) then
        local heart = other:ToFamiliar();
        local player = heart.Player;
        -- If player has The Infamies.
        if (player and player:HasCollectible(TheInfamies.Item)) then
            -- Kill the projectile.
            projectile:Die();
            -- Ignore the collision.
            return false;
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, TheInfamies.PreProjectileCollision); 


function TheInfamies:PostPlayerEffect(player)
    if (Game():GetFrameCount() > 0) then
        local has = player:HasCollectible(TheInfamies.Item);
        if (has) then
            local playerData = TheInfamies.GetPlayerData(player, true);
            if (not playerData.HasItem) then
                player:AddNullCostume(TheInfamies.Costumes[playerData.Form]);
                playerData.HasItem = true;
                player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK);
                player:EvaluateItems();
            end
        else
            local playerData = TheInfamies.GetPlayerData(player, false);
            if (playerData and playerData.HasItem) then
                player:TryRemoveNullCostume(TheInfamies.Costumes[playerData.Form]);
                playerData.HasItem = false;
                player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK);
                player:EvaluateItems();
            end
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, TheInfamies.PostPlayerEffect); 

function TheInfamies:PostNewRoom()
    local hasVisageHeart = false;
    for i, ent in pairs(Isaac.GetRoomEntities()) do 
        if (IsMaskOrHeart(ent)) then
            if (ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
                ent.Position = THI.Game:GetPlayer(0).Position;
            end
        end
        if (ent.Type == EntityType.ENTITY_VISAGE and ent.Variant == 0) then
            hasVisageHeart = true;
        end
    end

    
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_VISAGE, 1)) do 
        if (ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)) then
            if (ent.Type == EntityType.ENTITY_VISAGE and ent.Variant == 1) then
                if (not hasVisageHeart) then
                    ent:Remove();
                end
            end
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TheInfamies.PostNewRoom); 

local function SwapForm(player)
    local playerData = TheInfamies.GetPlayerData(player, true);
    local beforeForm = playerData.Form;
    player:PlayExtraAnimation("Sad");
    THI.SFXManager:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD);
    
    player:TryRemoveNullCostume(TheInfamies.Costumes[beforeForm]);

    playerData.Form = beforeForm % 4 + 1;
    player:AddNullCostume(TheInfamies.Costumes[playerData.Form]);
    player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK);
    player:EvaluateItems();
end

function TheInfamies:PreSpawnCleanAward(rng, position)
    local game = THI.Game;
    local spawnPoker = false;
    local spawner = nil;
    local maxLuck = 0;
    local form = 1;
    for p, player in Players.PlayerPairs(true, true) do
        if (player:HasCollectible(TheInfamies.Item)) then
            if (not spawnPoker) then
                local playerData = TheInfamies.GetPlayerData(player, true);
                form = playerData.Form;
                spawnPoker = true;
                spawner = player;
            end
            maxLuck = math.max(maxLuck, player.Luck)
            SwapForm(player);
        end
    end

    if (spawnPoker) then
        local value = rng:RandomInt(100);
        local aceThresold = math.max(5, math.min(25, 1.174 ^ maxLuck));
        local jokerThresold = math.ceil(aceThresold + aceThresold / 5);
        local room = THI.Game:GetRoom();
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true, false);
        if (value < aceThresold) then
            local subType = 29;
            if (form == 1) then
                subType = 29;
            elseif (form == 2) then
                subType = 30;
            elseif (form == 3) then
                subType = 27;
            elseif (form == 4) then
                subType = 28;
            end
            Isaac.Spawn(5, 300, subType, pos, Vector.Zero, spawner);
        elseif(value < jokerThresold) then
            Isaac.Spawn(5, 300, 31, pos, Vector.Zero, spawner);
        end
    end 
end
TheInfamies:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, TheInfamies.PreSpawnCleanAward); 


function TheInfamies:PostEvaluateItems(player, cache)
    if (player:HasCollectible(TheInfamies.Item)) then
        if (cache == CacheFlag.CACHE_SPEED and player:HasCollectible(CollectibleType.COLLECTIBLE_INFAMY)) then
            player.MoveSpeed = player.MoveSpeed + 0.15;
        end
        local playerData = TheInfamies.GetPlayerData(player);
        if (playerData) then
            local form = playerData.Form;
            if (cache == CacheFlag.CACHE_SPEED and form == 1) then
                player.MoveSpeed = player.MoveSpeed + 0.15;
            elseif (cache == CacheFlag.CACHE_DAMAGE and form == 2) then
                --player.Damage = player.Damage + 2;
                Stats:AddFlatDamage(player, 2);
            elseif (cache == CacheFlag.CACHE_FIREDELAY and form == 3) then
                Stats:AddTearsModifier(player, function(tears) return tears + 1 end);
            elseif (cache == CacheFlag.CACHE_LUCK and form == 4) then
                player.Luck = player.Luck + 1;
            end
        end
    end
end
TheInfamies:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TheInfamies.PostEvaluateItems); 

function TheInfamies:PostChangeCollectibles(player, item, diff)
    player:AddCacheFlags(CacheFlag.CACHE_SPEED);
    player:EvaluateItems();
end
TheInfamies:AddCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, TheInfamies.PostChangeCollectibles, CollectibleType.COLLECTIBLE_INFAMY); 


return TheInfamies;