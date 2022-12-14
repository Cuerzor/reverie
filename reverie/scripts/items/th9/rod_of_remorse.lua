local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local RodOfRemorse = ModItem("Rod of Remorse", "RodOfRemorse");

-- local function GetGlobalData(create)
--     return RodOfRemorse:GetGlobalData(create, function() return {
--         RedemptionAppeared = false
--     } end)
-- end


function RodOfRemorse:GetRemorseData(init)
    return self:GetTempGlobalData(init, function() return {
        FallenSpawned = false,
    } end)
end

function RodOfRemorse.GetPlayerData(player, init)
    return RodOfRemorse:GetData(player, init, function() return {
        SacrificeCount = 0,
    } end)
end

local BlessedTexts = {
    en = { "You feel blessed!" },
    jp = { "恵まれてるね！" },
    kr = { "축복 받은 느낌!" },
    zh = { "你受到了祝福！" },
    ru = { "Ты чувствуешь благословение!" },
    de = { "Du fühlst dich gesegnet!" },
    es = { "¡Te sientes bendecido!" },
}
local DevilTexts = {
    en = { "you are dark inside" },
    jp = { "君の中は暗闇だ" },
    kr = { "네 안은 어둡다" },
    zh = { "你的内心太黑暗" },
    ru = { "тьма внутри тебя" },
    de = { "du bist dunkel", "im Inneren" },
    es = { "eres negro por dentro" },
}

function RodOfRemorse.ShowBlessedText(devil)

    local hud = Game():GetHUD();
    local texts = BlessedTexts;
    if (devil) then
        texts = DevilTexts;
    end
    local str = texts[Options.Language] or texts.en;
    hud:ShowFortuneText(table.unpack(str));
end

local teleported = false;

-- function RodOfRemorse:IsRedemptionAppeared()
--     local data = GetGlobalData(false);
--     return data and data.RedemptionAppeared;
-- end

-- function RodOfRemorse:SetRedemptionAppeared(value)
--     local data = GetGlobalData(true)
--     data.RedemptionAppeared = true;
-- end

function RodOfRemorse.TriggerSacrificeEffect(count, player)
    local game = Game();
    local seeds = game:GetSeeds();
    local level = game:GetLevel();
    local room = game:GetRoom();
    local itemPools = game:GetItemPool();
    local rng = RNG();
    local judasBook = Players.HasJudasBook(player);
    local seed = seeds:GetStageSeed(level:GetStage());
    rng:SetSeed(seed, count);

    local angleChanceMulti = 1;
    local chestVariant = PickupVariant.PICKUP_CHEST;
    local heartSubType = HeartSubType.HEART_SOUL;
    local stageType = StageType.STAGETYPE_ORIGINAL
    if (judasBook) then
        angleChanceMulti = -1;
        chestVariant = PickupVariant.PICKUP_REDCHEST;
        heartSubType = HeartSubType.HEART_BLACK;
        stageType = StageType.STAGETYPE_WOTL;
    end

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
            RodOfRemorse.ShowBlessedText(judasBook);
            level:AddAngelRoomChance (0.1 * angleChanceMulti);
        end
    elseif (count == 4) then
        local pos = room:FindFreePickupSpawnPosition(player.Position);
        if (rng:RandomInt(2) > 0) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, chestVariant, 0, pos, Vector.Zero, player);
        end
    elseif (count == 5) then
        if (rng:RandomInt(3) > 0) then
            RodOfRemorse.ShowBlessedText(judasBook);
            level:AddAngelRoomChance (0.5 * angleChanceMulti);
        else
            for i = 1, 3 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
            end
        end
    elseif (count == 6) then
        if (rng:RandomInt(3) > 0) then
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, chestVariant, 0, pos, Vector.Zero, player);
        else
            if (not judasBook) then
                level:InitializeDevilAngelRoom (true, false)
            else
                level:InitializeDevilAngelRoom (false, true)
            end
            player:UseCard (Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER);
        end
    elseif (count == 7) then
        if (rng:RandomInt(3) > 0) then
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartSubType, pos, Vector.Zero, player);
        else
            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
            local id = 25;
            if (not judasBook) then -- have not judas book.
                -- Redemption if have dealt
                if (game:GetDevilRoomDeals() > 0 and itemPools:RemoveCollectible(CollectibleType.COLLECTIBLE_REDEMPTION)) then
                    id = CollectibleType.COLLECTIBLE_REDEMPTION
                else-- Angel room item.
                    id = itemPools:GetCollectible(ItemPoolType.POOL_ANGEL, true, seed);
                end
            else
                -- Goat head if haven't dealt
                if (game:GetDevilRoomDeals() <= 0 and itemPools:RemoveCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD)) then
                    id = CollectibleType.COLLECTIBLE_GOAT_HEAD
                else-- Devil room item.
                    id = itemPools:GetCollectible(ItemPoolType.POOL_DEVIL, true, seed);
                end
            end
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, player);
        end
    elseif (count == 8) then
        player:UseCard (Card.CARD_TOWER, UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANNOUNCER);
    elseif (count == 9) then
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true);
        if (not judasBook) then -- have not judas book.
            Isaac.Spawn(EntityType.ENTITY_URIEL, 0, 0, pos, Vector.Zero, nil);
        else
            Isaac.Spawn(EntityType.ENTITY_FALLEN, 0, 0, pos, Vector.Zero, nil);
            local data = RodOfRemorse:GetRemorseData(true);
            data.FallenSpawned = true;
        end
    elseif (count == 10) then
        if (rng:RandomInt(2) > 0) then
            for i = 1, 7 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);                
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartSubType, pos, Vector.Zero, player);
            end
        else
            for i = 1, 30 do
                local pos = room:FindFreePickupSpawnPosition(player.Position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
            end
        end
    elseif (count == 11) then
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true);
        if (not judasBook) then
            Isaac.Spawn(EntityType.ENTITY_GABRIEL, 0, 0, pos, Vector.Zero, nil);
        else -- Krampus.
            Isaac.Spawn(EntityType.ENTITY_FALLEN, 1, 0, pos, Vector.Zero, nil);
        end
    elseif (count >= 12) then
        if (rng:RandomInt(2) > 0) then
            level:SetStage (LevelStage.STAGE6, stageType);
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

-- local function PostCollectibleUpdate(mod, pickup)
    
--     if (pickup.FrameCount == 1 and pickup.SubType == CollectibleType.COLLECTIBLE_REDEMPTION) then
--         RodOfRemorse:SetRedemptionAppeared(true);
--     end
-- end
-- RodOfRemorse:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE);

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
RodOfRemorse:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, RodOfRemorse.PostTakeDamage);

function RodOfRemorse:GetShaderParams(name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        Actives:RenderActivesCount(RodOfRemorse.Item, function(player) 
            local data = RodOfRemorse.GetPlayerData(player, false);
            return (data and data.SacrificeCount) or 0;
        end);
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, RodOfRemorse.GetShaderParams);

function RodOfRemorse:onNewLevel()
    local game = THI.Game;
    for p, player in Players.PlayerPairs() do
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



function RodOfRemorse:ClearFallenSpawned()
    local data = RodOfRemorse:GetRemorseData(false);
    if (data and data.FallenSpawned) then
        data.FallenSpawned = false;
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RodOfRemorse.ClearFallenSpawned);

function RodOfRemorse:PostFallenDeath(npc)
    if (npc.Variant == 0) then
        local data = RodOfRemorse:GetRemorseData(false);
        if (data and data.FallenSpawned) then
            local fallenExists = false;
            for i, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FALLEN, 0)) do
                if (not ent:IsDead() and ent:Exists()) then
                    fallenExists = true;
                end
            end
            if (not fallenExists) then
                local room = Game():GetRoom();
                local pos = room:FindFreePickupSpawnPosition(npc.Position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_PENTAGRAM, pos, Vector.Zero, npc);
                data.FallenSpawned = false;
            end
        end
    end
end
RodOfRemorse:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, RodOfRemorse.PostFallenDeath, EntityType.ENTITY_FALLENS);


return RodOfRemorse;