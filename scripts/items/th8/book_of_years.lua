
local BookOfYears = ModItem("Book of Years", "BookOfYears")

local config = Isaac.GetItemConfig();
local maxItemId = config:GetCollectibles().Size;

function BookOfYears.GetBookGlobalData(init)
    return BookOfYears:GetGlobalData(init, function() return {
        SpawnSeed = THI.Game:GetSeeds():GetStartSeed(),
        CollectibleSeed = THI.Game:GetSeeds():GetStartSeed()
    }end);
end

function BookOfYears.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        data._BOOK_OF_YEARS = data._BOOK_OF_YEARS or {
            SpawningCountdown = 0
        }
    end
    return data._BOOK_OF_YEARS;
end

function BookOfYears:onPlayerUpdate(player)
    local playerData = BookOfYears.GetPlayerTempData(player, false);
    if (playerData) then

        if (playerData.SpawningCountdown > 0) then
            playerData.SpawningCountdown = playerData.SpawningCountdown - 1;
            if (playerData.SpawningCountdown <= 0) then
                
                local sprite = player:GetSprite();
                local frame = sprite:GetFrame();
                --player:PlayExtraAnimation("HideItem");

                -- Create new Collectible.
                local canSpawn = true;
                local room = Game():GetRoom();
                local spawnSeed = room:GetSpawnSeed();
                local globalData = BookOfYears.GetBookGlobalData(true);

                if (THI.IsLunatic()) then
                    
                    local spawnRng = RNG();
                    spawnRng:SetSeed(globalData.SpawnSeed, 0);
                    local value = spawnRng:RandomInt(100);
                    local seed = spawnRng:Next();
                    canSpawn = value > 30;
                    globalData.SpawnSeed = seed;
                end

                if (canSpawn) then
                    local itemPool = Game():GetItemPool();
                    local poolType = math.max(0, itemPool:GetPoolForRoom(room:GetType(), spawnSeed));
                    local newId = itemPool:GetCollectible (poolType, true, spawnSeed, CollectibleType.COLLECTIBLE_BREAKFAST)
                    
                    local pos = room:FindFreePickupSpawnPosition (player.Position, 0, true);
                    Isaac.Spawn(5, 100, newId, pos, Vector.Zero, player);
                else
                    THI.SFXManager:Play(SoundEffect.SOUND_THUMBS_DOWN);
                end

                THI.Game:ShakeScreen(10);
                THI.SFXManager:Play(SoundEffect.SOUND_BLACK_POOF);
                local itemPoof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position + Vector(0, -40), Vector.Zero, player);
                itemPoof.DepthOffset = 50;
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player);
            end
        end
    end
end
BookOfYears:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BookOfYears.onPlayerUpdate);

local function GetWorstItems(player)
    
    local worstList = {};
    local worstQuality = 1000;
    local totalCount = 0;
    for id=1, maxItemId do
        local num = player:GetCollectibleNum(id, true);
        if (num > 0) then
            local item = config:GetCollectible(id);
            if (item and (item.Type == ItemType.ITEM_PASSIVE or item.Type == ItemType.ITEM_FAMILIAR)) then
                if (not item:HasTags(ItemConfig.TAG_QUEST)) then
                    local quality = item.Quality;
                    if (quality < worstQuality) then
                        worstQuality = quality;
                        -- Clear worst list.
                        for k, _ in pairs(worstList) do
                            worstList[k] = nil;
                            totalCount = 0;
                        end
                    end

                    if (quality == worstQuality) then
                        worstList[id] = num;
                        totalCount = totalCount + num;
                    end
                end
            end
        end
    end
    return worstList, totalCount, worstQuality;
end

local function SelectItem(player)
    local worstList, totalCount, _ = GetWorstItems(player);

    local rng = player:GetCollectibleRNG(BookOfYears.Item);
    local rdm = rng:RandomInt(totalCount);
    local randomValue = rdm;

    for id, num in pairs(worstList) do
        randomValue = randomValue - num;
        if (randomValue <= 0) then
            return id;
        end
    end
    return nil;
end

function BookOfYears:onUseBook(item,rng,player,flags,slot,data)	
    local id = SelectItem(player);
    local playerData = BookOfYears.GetPlayerTempData(player, true);
    if (playerData.SpawningCountdown <= 0) then
        if (id) then
            player:RemoveCollectible(id, true);
            player:AnimateCollectible(id, "UseItem", "PlayerPickup");
            playerData.SpawningCountdown = 20;
        else
            return { ShowAnim = true }
        end
    end
end
BookOfYears:AddCallback(ModCallbacks.MC_USE_ITEM, BookOfYears.onUseBook, BookOfYears.Item);

function BookOfYears:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == BookOfYears.Item) then
        local room = THI.Game:GetRoom();
        local pos = room:FindFreePickupSpawnPosition (familiar.Position, 0, true);
        Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_MISSING_PAGE_2, pos, Vector.Zero, familiar);
    end
end
BookOfYears:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, BookOfYears.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);

return BookOfYears;