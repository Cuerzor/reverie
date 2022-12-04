local Lib = CuerLib;
local Detection = Lib.Detection;
local Pickups = Lib.Pickups;
local Players = Lib.Players;
local Stats = Lib.Stats;

local function IsPickupNotGoldenChest(pickup)
    local variant = pickup.Variant;
    local subType = pickup.SubType;
    return (variant == PickupVariant.PICKUP_CHEST or
    variant == PickupVariant.PICKUP_BOMBCHEST or
    variant == PickupVariant.PICKUP_SPIKEDCHEST or
    variant == PickupVariant.PICKUP_ETERNALCHEST or
    variant == PickupVariant.PICKUP_MINICCHEST or
    variant == PickupVariant.PICKUP_OLDCHEST or
    variant == PickupVariant.PICKUP_WOODENCHEST or
    variant == PickupVariant.PICKUP_HAUNTEDCHEST or
    variant == PickupVariant.PICKUP_REDCHEST) and subType == 1;
end

local function TurnPickupGold(pickup)
    local variant = pickup.Variant;
    local subType = pickup.SubType;
    if (variant == PickupVariant.PICKUP_COIN) then
        if (subType ~= CoinSubType.COIN_GOLDEN) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, true, true, true);
        end
    elseif (variant == PickupVariant.PICKUP_HEART) then
        if (subType ~= HeartSubType.HEART_GOLDEN) then
            local canMorph = true;
            local level = Game():GetLevel();
            local roomDesc = level:GetCurrentRoomDesc();
            if (roomDesc and roomDesc.Data) then
                local roomType =roomDesc.Data.Type;
                local roomId = roomDesc.Data.Variant; 
                if (roomType == RoomType.ROOM_SUPERSECRET) then
                    if (roomId == 0 or roomId == 1 or roomId == 6 or roomId == 12 or roomId == 13 or roomId == 16 or roomId == 23) then
                        canMorph = false;
                    end
                end
            end
            if (canMorph) then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN, true, true, true);
            end
        end
        
    elseif (variant == PickupVariant.PICKUP_BOMB) then
        if (subType ~= BombSubType.BOMB_GOLDEN) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN, true, true, true);
        end
    elseif (variant == PickupVariant.PICKUP_KEY) then
        if (subType ~= KeySubType.KEY_GOLDEN) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN, true, true, true);
        end
    elseif (IsPickupNotGoldenChest(pickup)) then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, subType, true, true, true);
    elseif (variant == PickupVariant.PICKUP_PILL) then
        if (subType ~= PillColor.PILL_GOLD) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, PillColor.PILL_GOLD, true, true, true);
        end
    elseif (variant == PickupVariant.PICKUP_LIL_BATTERY) then
        if (subType ~= BatterySubType.BATTERY_GOLDEN) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN, true, true, true);
        end
    elseif (variant == PickupVariant.PICKUP_TRINKET) then
        if (subType < 32768) then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, subType + 32768, true, true, true);
        end
    end
end

local function TurnGold()
    local room = THI.Game:GetRoom();
    room:TurnGold();

    local seed = room:GetSpawnSeed ( );
    for i = 0, room:GetGridSize() do 
        local gridEntity = room:GetGridEntity(i);
        if (gridEntity and gridEntity:GetType() == GridEntityType.GRID_POOP) then
            if (gridEntity:GetVariant() ~= 3) then
                -- local varData = gridEntity.VarData;
                -- room:RemoveGridEntity (i, 0, false);
                -- room:Update();
                -- room:SpawnGridEntity (i, GridEntityType.GRID_POOP, 3, seed, varData);
                gridEntity:SetVariant(3);
                gridEntity:Init(seed);
            end
        end
    end

    for _, ent in pairs(Isaac.GetRoomEntities()) do
        local type = ent.Type;
        local variant = ent.Variant;
        local subType = ent.SubType;
        if (ent.Type == EntityType.ENTITY_PICKUP) then
            local pickup = ent:ToPickup();
            TurnPickupGold(pickup);
        elseif(type == EntityType.ENTITY_BOMBDROP) then
            if (variant == BombVariant.BOMB_TROLL or variant == BombVariant.BOMB_SUPERTROLL) then
                ent:Remove();
                Isaac.Spawn(type, BombVariant.BOMB_GOLDENTROLL, subType, ent.Position, ent.Velocity, nil);
            end
        elseif (Detection.IsValidEnemy(ent) and not THI.IsLunatic()) then
            ent:AddMidasFreeze(EntityRef(nil), 150);
        end
    end
end

-- Flash.
local MidasFlash = ModEntity("Midas Flash");

function MidasFlash:FlashInit(flash)
    flash.DepthOffset = 3000;
end
MidasFlash:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MidasFlash.FlashInit, MidasFlash.Variant);

function MidasFlash:FlashUpdate(flash)
    local spr = flash:GetSprite();
    if (spr:IsEventTriggered("Midas")) then
        TurnGold();
    end

    
    if (spr:WasEventTriggered("Disappear")) then
        flash:Remove();
    end
end
MidasFlash:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MidasFlash.FlashUpdate, MidasFlash.Variant);



local Pagota = ModItem("Bishamonten's Pagota", "Pagota");

local maxCharges = Isaac.GetItemConfig():GetCollectible(Pagota.Item).MaxCharges;
-- Pagota.
function Pagota:GetPagotaData(init)
    return Pagota:GetGlobalData(init, function() return {
        Golden = false,
        GoldenBelial = false
    }end);
end

function Pagota:GetPlayerTempData(player, init)
    local data = Lib:GetLibData(player);
    if (init) then
        data._PAGOTA_TEMP = data._PAGOTA_TEMP or {
            LastCoins = 0,
            AddedCoins = 0,
            LastCoinHearts = 0,
        }
    end
    return data._PAGOTA_TEMP;
end

function Pagota:UsePagota(item, rng, player, flags, slot, varData)
    THI.SFXManager:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY);
    local data = Pagota:GetPagotaData(true);
    data.Golden = true;
    if (Players.HasJudasBook(player)) then
        data.GoldenBelial = true;
        for p, player in Detection.PlayerPairs() do
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
            player:EvaluateItems();
        end
    end
    
    Isaac.Spawn(MidasFlash.Type, MidasFlash.Variant, 0, player.Position, Vector.Zero, player);

    -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
    --     for i=1,12 do
    --         player:AddWisp (Pagota.Item, player.Position);
    --     end
    -- end
    return {ShowAnim = true, Remove = true};
end
Pagota:AddCallback(ModCallbacks.MC_USE_ITEM, Pagota.UsePagota, Pagota.Item);


function Pagota:PostPickupUpdate(pickup)
    local data = Pagota:GetPagotaData(false);
    if (data and data.Golden) then
        TurnPickupGold(pickup);
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Pagota.PostPickupUpdate);

function Pagota:PostBombUpdate(bomb)
    local data = Pagota:GetPagotaData(false);
    if (data and data.Golden) then
        local variant = bomb.Variant;
        if (variant == BombVariant.BOMB_TROLL or variant == BombVariant.BOMB_SUPERTROLL) then
            bomb:Remove();
            Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_GOLDENTROLL, 0, bomb.Position, bomb.Velocity, nil);
        end
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Pagota.PostBombUpdate);

function Pagota:PostPlayerRender(player)
    if (player:HasCollectible(Pagota.Item, true)) then
        local data = Pagota:GetPlayerTempData(player, true);

        local playerType = player:GetPlayerType();
        local isKeeper = playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B;

        local added = data.AddedCoins;
        if (isKeeper) then
            local costHeartCoins = math.max( 0, math.ceil((player:GetHearts() - data.LastCoinHearts) / 2));
            added = added - costHeartCoins;
        end
        -- Charge.
        if (added > 0) then
            for slot = 0, 3 do
                if (player:GetActiveItem(slot) == Pagota.Item) then
                    local charges = player:GetActiveCharge(slot);
                    if (charges < maxCharges) then
                        local chargeValue = math.min(added, maxCharges - charges);
                        local newCharges = charges + chargeValue;
                        player:SetActiveCharge (newCharges, slot)
                        THI.Game:GetHUD():FlashChargeBar (player, slot);

                        local sfx = THI.SFXManager
                        sfx:Play(SoundEffect.SOUND_BEEP);
                        if (newCharges >= maxCharges) then
                            sfx:Play(SoundEffect.SOUND_ITEMRECHARGE);
                        end
                        added = added - chargeValue;
                    end
                end
            end

            local needAdd = data.LastCoins + added - player:GetNumCoins();
            player:AddCoins(needAdd);
        end

        data.AddedCoins = 0;
        data.LastCoins = player:GetNumCoins();

        if (isKeeper) then
            data.LastCoinHearts = player:GetHearts();
        end
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Pagota.PostPlayerRender);

function Pagota:PostPickupCollected(player, pickup)
    if (player:HasCollectible(Pagota.Item, true)) then
        local originValue = pickup:GetCoinValue ( );
        local data = Pagota:GetPlayerTempData(player, true);
        data.AddedCoins = data.AddedCoins + originValue;
    end
end
Pagota:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_PICKUP_COLLECTED, Pagota.PostPickupCollected, PickupVariant.PICKUP_COIN);

-- function Pagota:PrePickupCollision(pickup, other, low)
    
--     if (other.Type == EntityType.ENTITY_PLAYER) then
--         local player = other:ToPlayer();
--         if (Pickups.CanCollect(player, pickup)) then
--             local originValue = pickup:GetCoinValue ( );
--             local value = originValue;
--             for slot = 0, 3 do
--                 if (player:GetActiveItem(slot) == Pagota.Item) then
--                     local charges = player:GetActiveCharge(slot);
--                     if (charges < maxCharges) then
--                         local chargeValue = math.min(value, maxCharges - charges);
--                         local newCharges = charges + chargeValue;
--                         player:SetActiveCharge (newCharges, slot)
--                         THI.Game:GetHUD():FlashChargeBar (player, slot);
--                         local sfx = THI.SFXManager
--                         sfx:Play(SoundEffect.SOUND_BEEP);
--                         if (newCharges >= maxCharges) then
--                             sfx:Play(SoundEffect.SOUND_ITEMRECHARGE);
--                         end
--                         value = value - chargeValue;
--                     end
--                 end

--                 if (value <= 0) then
--                     break;
--                 end
--             end

--             if (value < originValue) then
--                 pickup:PlayPickupSound();
--                 Pickups.AddCoinsOrCoinHearts(player, value);
--                 Pickups.SetCollected(pickup, true);
--                 return true;
--             end
--         end
--     end
-- end
-- Pagota:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_PICKUP_COLLISION, Pagota.PrePickupCollision, PickupVariant.PICKUP_COIN);

local turnGoldInUpdate = false;
function Pagota:NewRoom()
    local data = Pagota:GetPagotaData(false);
    
    if (data) then
        if (data.Golden) then
            turnGoldInUpdate = true;
        end
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Pagota.NewRoom);

function Pagota:PostPlayerUpdate(player)
    if (turnGoldInUpdate) then
        TurnGold();
        turnGoldInUpdate = false;
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Pagota.PostPlayerUpdate);


function Pagota:EvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local data = Pagota:GetPagotaData(false);
        if (data and data.GoldenBelial) then
            Stats:AddDamageUp(player, 12);
        end
    end
end
Pagota:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Pagota.EvaluateCache);

function Pagota:NewLevel()
    local data = Pagota:GetPagotaData(false);
    
    if (data) then
        data.Golden = false;
        if (data.GoldenBelial) then
            data.GoldenBelial = false;
            for p, player in Detection.PlayerPairs() do
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();
            end
        end
        turnGoldInUpdate = false;
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Pagota.NewLevel);

function Pagota:PostGameStarted(isContinued)
    if (isContinued) then
        local data = Pagota:GetPagotaData(false);
        if (data and data.Golden) then
            TurnGold();
        end
    end
end
Pagota:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Pagota.PostGameStarted);


return Pagota;