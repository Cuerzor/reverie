local Actives = CuerLib.Actives;
local Detection = CuerLib.Detection;
local RodOfRemorse = ModItem("Rod of Remorse", "RodOfRemorse");

local function GetGlobalData(create)
    return RodOfRemorse:GetGlobalData(create, function() return {
        RedemptionAppeared = false
    } end)
end


function RodOfRemorse.GetPlayerData(player, init)
    return RodOfRemorse:GetData(player, init, function() return {
        SacrificeCount = 0,
    } end)
end

local BlessedTexts = {
    en = "You feel blessed!",
    jp = "恵まれてるね！",
    kr = "축복 받은 느낌!",
    zh = "你受到了祝福！",
    ru = "Ты чувствуешь благословение!",
    de = "Du fühlst dich gesegnet!",
    es = "¡Te sientes bendecido!",
}

function RodOfRemorse.ShowBlessedText()

    local hud = THI.Game:GetHUD();
    local str= BlessedTexts[Options.Language] or BlessedTexts.en;
    hud:ShowFortuneText(str, nil);
end

function RodOfRemorse.SpawnRandomChest(rng, pos, spawner)
    
    -- 普通箱子：86%
    -- 石箱子：2%
    -- 刺箱子：2%
    -- 伪装箱子：2%
    -- 鬼箱子：2%
    -- 红箱子：5%
    -- 木箱子：1%
    local variant = PickupVariant.PICKUP_CHEST;
    -- local value = rng:RandomInt(100);
    -- if (value < 2) then
    --     variant = PickupVariant.PICKUP_BOMBCHEST
    -- elseif (value < 4) then
    --     variant = PickupVariant.PICKUP_SPIKEDCHEST
    -- elseif (value < 6) then
    --     variant = PickupVariant.PICKUP_MIMICCHEST
    -- elseif (value < 8) then
    --     variant = PickupVariant.PICKUP_HAUNTEDCHEST
    -- elseif (value < 13) then
    --     variant = PickupVariant.PICKUP_REDCHEST
    -- elseif (value < 14) then
    --     variant = PickupVariant.PICKUP_WOODENCHEST
    -- end

    Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, 0, pos, Vector.Zero, spawner);
end
local teleported = false;

function RodOfRemorse:IsRedemptionAppeared()
    local data = GetGlobalData(false);
    return data and data.RedemptionAppeared;
end

function RodOfRemorse:SetRedemptionAppeared(value)
    local data = GetGlobalData(true)
    data.RedemptionAppeared = true;
end

function RodOfRemorse.TriggerSacrificeEffect(count, player)
    local game = THI.Game;
    local seeds = game:GetSeeds();
    local level = game:GetLevel();
    local room = game:GetRoom();
    local itemPools = game:GetItemPool();
    local rng = RNG();
    local seed = seeds:GetStageSeed(level:GetStage());
    rng:SetSeed(seed, count);
    if (count == 1 or count == 2) then
        local pos = room:FindFreePickupSpawnPosition(player.Position);
        if (level:GetStateFlag(LevelStateFlag.STATE_SHOVEL_QUEST_TRIGGERED) and player:GetNumBombs() <= 0) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pos, Vector.Zero, player);
        else
            if (rng:RandomInt(2) == 1) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
            end
        end
    elseif (count == 3) then
        if (rng:RandomInt(3) > 0) then
            RodOfRemorse.ShowBlessedText();
            level:AddAngelRoomChance (0.1);
        end
    elseif (count == 4) then
        local pos = room:FindFreePickupSpawnPosition(player.Position);
        if (rng:RandomInt(2) > 0) then
            RodOfRemorse.SpawnRandomChest(rng, pos, player);
        end
    elseif (count == 5) then
        if (rng:RandomInt(3) > 0) then
            RodOfRemorse.ShowBlessedText();
            level:AddAngelRoomChance (0.5);
        else
            for i = 1, 3 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
            end
        end
    elseif (count == 6) then
        if (rng:RandomInt(3) > 0) then
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            RodOfRemorse.SpawnRandomChest(rng, pos, player);
        else
            level:InitializeDevilAngelRoom (true, false)
            player:UseCard (Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER);
        end
    elseif (count == 7) then
        if (rng:RandomInt(3) > 0) then
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, player);
        else
            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
            local id = CollectibleType.COLLECTIBLE_REDEMPTION;
            if (game:GetDevilRoomDeals() <= 0 or RodOfRemorse:IsRedemptionAppeared()) then
                id = itemPools:GetCollectible(ItemPoolType.POOL_ANGEL, true, seed);
            end
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, player);
        end
    elseif (count == 8) then
        player:UseCard (Card.CARD_TOWER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER);
    elseif (count == 9) then
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true);
        Isaac.Spawn(EntityType.ENTITY_URIEL, 0, 0, pos, Vector.Zero, nil);
    elseif (count == 10) then
        if (rng:RandomInt(2) > 0) then
            for i = 1, 7 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);                
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, player);
            end
        else
            for i = 1, 30 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
            end
        end
    elseif (count == 11) then
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true);
        Isaac.Spawn(EntityType.ENTITY_GABRIEL, 0, 0, pos, Vector.Zero, nil);
    elseif (count >= 12) then
        if (rng:RandomInt(2) > 0) then
            level:SetStage (LevelStage.STAGE6, StageType.STAGETYPE_ORIGINAL);
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER);
            teleported = true;
            --game:StartStageTransition(true, 1);
        end
    end
end


function RodOfRemorse:UseRod(item, rng, player, flags, slot, data)
    if (player.Variant == 0) then
        local data = RodOfRemorse.GetPlayerData(player, true);
        data.Sacrificing = true;
        player:ResetDamageCooldown();
        player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 60);
        player:AnimateCollectible(item, "UseItem");
        if (teleported) then
            player:AnimateTeleport(true);
        end
        teleported = false;
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_USE_ITEM, RodOfRemorse.UseRod, RodOfRemorse.Item);

function RodOfRemorse:PostPlayerEffect(player)
    local data = RodOfRemorse.GetPlayerData(player, false);
    if (data) then
        if (data.Sacrificing) then
            data.Sacrificing = false;
        end
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, RodOfRemorse.PostPlayerEffect);

local function PostCollectibleUpdate(mod, pickup)
    
    if (pickup.FrameCount == 1 and pickup.SubType == CollectibleType.COLLECTIBLE_REDEMPTION) then
        RodOfRemorse:SetRedemptionAppeared(true);
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE);

function RodOfRemorse:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        local player = tookDamage:ToPlayer();
        local data = RodOfRemorse.GetPlayerData(player, false);
        if (data) then
            if (data.Sacrificing) then
                data.Sacrificing = false;
                data.SacrificeCount = data.SacrificeCount + 1;
                RodOfRemorse.TriggerSacrificeEffect(data.SacrificeCount, player);
            end
        end
    end
end
RodOfRemorse:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, RodOfRemorse.PostTakeDamage);

function RodOfRemorse:GetShaderParams(name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        Actives.RenderActivesCount(RodOfRemorse.Item, function(player) 
            local data = RodOfRemorse.GetPlayerData(player, false);
            return (data and data.SacrificeCount) or 0;
        end);
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, RodOfRemorse.GetShaderParams);

function RodOfRemorse:onNewLevel()
    local game = THI.Game;
    for p, player in Detection.PlayerPairs() do
        local playerData = RodOfRemorse.GetPlayerData(player, false);
        if (playerData) then
            playerData.SacrificeCount = 0;
        end
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, RodOfRemorse.onNewLevel);

function RodOfRemorse:onFamiliarKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == RodOfRemorse.Item) then
        if (familiar.DropSeed % 4 == 0) then
            local game = THI.Game;
            local room = game:GetRoom();
            local pos = room:FindFreePickupSpawnPosition(familiar.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, pos, Vector.Zero, nil);
        end
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, RodOfRemorse.onFamiliarKilled, EntityType.ENTITY_FAMILIAR);


return RodOfRemorse;