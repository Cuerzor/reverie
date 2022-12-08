local Collectibles = CuerLib.Collectibles;
local CompareEntity = CuerLib.Entities.CompareEntity;
local Actives = CuerLib.Actives;
local ItemPools = CuerLib.ItemPools;
local DualDivision = ModItem("Dual Division", "DUAL_DIVISION");
DualDivision.GettingCollectible = false;
DualDivision.PoolCondition = nil;

local function GetGlobalData(init)
    return DualDivision:GetGlobalData(init, function()
        return {
            ItemQueue = {}
        }
    end);
end

local function GetTempPlayerData(player, init)
    return DualDivision:GetTempData(player, init, function()
        return {
            SpawningCountdown = 0,
            SpawningQuality = 0,
        }
    end);
end

local function SpawnExplosionWave(position, positionOffset, spawner)
    local Leaf = THI.Effects.SpellCardLeaf;
    local Wave =THI.Effects.SpellCardWave;
    
    local rng = RNG();
    rng:SetSeed(math.max(1, Random()), 0);
    local count = 10;
    for i = 1, count do
        local angle = rng:RandomFloat()* 360;
        local length = rng:RandomFloat() * 320 + 480;
        local sizeX = rng:RandomFloat()  + 0.5;
        local sizeY = rng:RandomFloat()  + 0.5;
        local rotation = rng:RandomFloat()* 360;
        local speed = rng:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(Leaf.Type, Leaf.Variant, 0, position, offset / 21 * speed, spawner);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
        leafEntity.DepthOffset = 10;
        leafEntity.PositionOffset = positionOffset;
    end
    local waveEnt = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, position, Vector.Zero, spawner);
    waveEnt.DepthOffset = 10;
    waveEnt.PositionOffset = positionOffset;
end

local function PostPlayerUpdate(mod, player)
    if (player:IsFrame(10, 0) and not player:IsItemQueueEmpty ( )) then
        local queuedItem = player.QueuedItem.Item;
        if (queuedItem and queuedItem.Type ~= ItemType.ITEM_TRINKET) then
            
            for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
                local item = player:GetActiveItem(slot);
                if (item == DualDivision.Item and player:GetActiveCharge(slot) >= 6) then
                    Game():GetHUD():FlashChargeBar(player, slot);
                    SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
                end
            end
        end
    end

    
    local playerData = GetTempPlayerData(player, false);
    if (playerData) then

        if (playerData.SpawningCountdown > 0) then
            playerData.SpawningCountdown = playerData.SpawningCountdown - 1;
            if (playerData.SpawningCountdown == 30) then
                --Game():ShakeScreen(40);
            end
            if (playerData.SpawningCountdown <= 0) then
                
                local sprite = player:GetSprite();
                local frame = sprite:GetFrame();
                --player:PlayExtraAnimation("HideItem");

                -- Clear Pickup Sprite.
                player:AnimatePickup(Sprite(), false, "UseItem");

                -- Create new Collectible.
                local room = Game():GetRoom();
                local rng = player:GetCollectibleRNG(DualDivision.Item);
                local globalData = GetGlobalData(true);

                local itemPool = Game():GetItemPool();
                local poolType = math.max(0, ItemPools:GetRoomPool(rng:Next()));

                local function worseCondition(id, conf)
                    return conf.Quality == math.max(0, playerData.SpawningQuality - 1);
                end
                local function betterCondition(id, conf)
                    return conf.Quality == math.min(4, playerData.SpawningQuality + 1);
                end

                DualDivision.GettingCollectible = true;

                DualDivision.PoolCondition = worseCondition;
                ItemPools:EvaluateBlacklist();
                local worseID = itemPool:GetCollectible(poolType, true, rng:Next(), 0);

                DualDivision.PoolCondition = betterCondition;
                ItemPools:EvaluateBlacklist();
                itemPool:AddRoomBlacklist(worseID);
                local betterID = itemPool:GetCollectible(poolType, true, rng:Next(), 0);

                ItemPools:EvaluateBlacklist();

                DualDivision.GettingCollectible = false;
                
                local pos = room:FindFreePickupSpawnPosition (player.Position + Vector(0, 40), 0, true);
                local positionOffset = Vector(0, -32 * player.SpriteScale.Y);
                --Isaac.Spawn(5, 100, worseID, pos, Vector.Zero, player);
                local ItemSoul = THI.Effects.ItemSoul;
                local redSoul = Isaac.Spawn(ItemSoul.Type, ItemSoul.Variant, ItemSoul.SubTypes.RED, player.Position, Vector(-20, 0), player):ToEffect();
                ItemSoul:SetItem(redSoul, worseID);
                redSoul.TargetPosition = pos;
                redSoul.Timeout = 90;
                redSoul.LifeSpan = 90;
                redSoul.DepthOffset = 1000;
                redSoul.PositionOffset = positionOffset;
                local blackSoul = Isaac.Spawn(ItemSoul.Type, ItemSoul.Variant, ItemSoul.SubTypes.BLACK, player.Position, Vector(20, 0), player):ToEffect();
                ItemSoul:SetItem(blackSoul, betterID);
                blackSoul.Timeout = 90;
                blackSoul.LifeSpan = 90;
                blackSoul.DepthOffset = 1000;
                blackSoul.PositionOffset = positionOffset;

                table.insert(globalData.ItemQueue, betterID);


                THI.Game:ShakeScreen(10);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE);

                SpawnExplosionWave(player.Position, positionOffset, player);
            end
        end
    end
end
DualDivision:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

local function EvaluateBlacklist(mod, id, config)
    if (DualDivision.PoolCondition) then
        return not DualDivision.PoolCondition(id, config);
    end
end
DualDivision:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateBlacklist);


local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
    local room = Game():GetRoom();
    if (loopCount == 1 and room:GetFrameCount() <= 0 and room:IsFirstVisit()) then
        local globalData = GetGlobalData(false);
        if (globalData and #globalData.ItemQueue > 0) then
            local count = #globalData.ItemQueue;
            local item = globalData.ItemQueue[count];
            table.remove(globalData.ItemQueue, count)
            return item;
        end
    end
end
DualDivision:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, PreGetCollectible, nil, -1)

local function UseDivision(mod, item, rng, player, flags, slot, vardata)
    if (flags & UseFlag.USE_CARBATTERY > 0) then
        return {ShowAnim = false, Discharge = false;}
    end

    if (not player:IsItemQueueEmpty ( )) then
        local queuedItem = player.QueuedItem.Item;
        if (queuedItem and queuedItem.Type ~= ItemType.ITEM_TRINKET) then
            

            local playerData = GetTempPlayerData(player, true);
            local id = queuedItem.ID;
            if (playerData.SpawningCountdown <= 0) then
                if (id and id ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
                    playerData.SpawningQuality = queuedItem.Quality;
                    if (THI.QueuedItemNil) then
                        player.QueuedItem = THI.QueuedItemNil;
                    else
                        player:FlushQueueItem();
                        player:RemoveCollectible(id)
                    end


                    local gfx = Isaac.GetItemConfig():GetCollectible(id).GfxFileName;
                    player:AnimateCollectible(id, "Pickup", "PlayerPickupSparkle");
                    playerData.SpawningCountdown = 50;
                    return { ShowAnim = false, Discharge = true}
                end
            end


        end
    end
    return {ShowAnim = false, Discharge = false;}
end
DualDivision:AddCallback(ModCallbacks.MC_USE_ITEM, UseDivision, DualDivision.Item);

return DualDivision;