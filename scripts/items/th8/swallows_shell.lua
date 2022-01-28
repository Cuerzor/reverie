local Callbacks = CuerLib.Callbacks;
local Damages = CuerLib.Damages;
local Detection = CuerLib.Detection;

local SwallowsShell = ModItem("Swallow's Shell", "SwallowsShell");
SwallowsShell.rng = RNG();
local RemoveMode = true;

local function GetBabyItems()
    local results = {};
    local config = Isaac.GetItemConfig();
    local size = config:GetCollectibles().Size;
    for i = 1, size do
        local collectible = config:GetCollectible(i);
        if (collectible) then
            if (collectible:HasTags(ItemConfig.TAG_BABY)) then
                table.insert(results, i);
            end
        end
    end
    return results;
end
local BabyItems = GetBabyItems();

function SwallowsShell.GetPlayerData(player, init)
    return Builder:GetItemData(player, init, "SwallowsShell", {
        GetHurt = false
    });
end

function SwallowsShell:PostPlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(SwallowsShell.Item)) then
        local noPenalties = Damages.IsSelfDamage(entity, flags, source);
        if (not noPenalties) then
            
            local dropImage = false;
            if (RemoveMode) then
                if (player:HasCollectible(SwallowsShell.Item)) then
                    dropImage = true;
                    player:RemoveCollectible(SwallowsShell.Item);
                end
            else
                local playerData = SwallowsShell.GetPlayerData(player, true);
                if (not playerData.GetHurt) then
                    dropImage = true;
                    playerData.GetHurt = true;
                end
            end

            
            if(dropImage)then 
                local config = Isaac.GetItemConfig();
                local collectible = config:GetCollectible(SwallowsShell.Item);
                local rng = SwallowsShell.rng;
                player:AnimateSad();
                local velocity = RandomVector()*(rng:RandomFloat()*2+2); 
                local poof = Isaac.Spawn(1000,15,100,player.Position,velocity,player);
                local spr = poof:GetSprite();
                spr:Load("gfx/005.350_Trinket.anm2", true);
                spr:Play("Appear");
                spr:ReplaceSpritesheet(0, collectible.GfxFileName);
                spr:LoadGraphics();
            end
        end
    end
end
SwallowsShell:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, SwallowsShell.PostPlayerTakeDamage, EntityType.ENTITY_PLAYER);

function SwallowsShell.SpawnBonus(player, position)
    local game = THI.Game;
    local room = THI.Game:GetRoom();
    local itemPool = THI.Game:GetItemPool();
    local pos = room:FindFreePickupSpawnPosition(position, 0, true);
    local seed = THI.Game:GetSeeds():GetStageSeed(THI.Game:GetLevel():GetStage());
    local item = itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, seed, CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR)
    local entity = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, pos, Vector.Zero, player);

    for _, baby in pairs(BabyItems) do
        for i = 1, player:GetCollectibleNum(baby, false) do
            pos = room:FindFreePickupSpawnPosition(position, 0, true);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, player);
        end
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, entity);
end


function SwallowsShell:PostNewStage()
    local game = THI.Game;
    if (game:GetFrameCount() > 1) then
        for p, player in Detection.PlayerPairs() do
            local spawnBonus = false;
            if (RemoveMode) then
                spawnBonus = player:HasCollectible(SwallowsShell.Item);
            else
                local playerData = SwallowsShell.GetPlayerData(player, false);
                spawnBonus = not playerData or not playerData.GetHurt;
            end

            if (spawnBonus) then
                local num = player:GetCollectibleNum(SwallowsShell.Item);
                for i=1,num do
                    SwallowsShell.SpawnBonus(player, player.Position);
                end
                THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
            end

            if (not RemoveMode) then
                local playerData = SwallowsShell.GetPlayerData(player, true);
                playerData.GetHurt = false;
            end
        end
    end
end
SwallowsShell:AddCustomCallback(CLCallbacks.CLC_NEW_STAGE, SwallowsShell.PostNewStage);

return SwallowsShell;