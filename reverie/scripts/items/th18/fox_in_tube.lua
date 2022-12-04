local Detection = CuerLib.Detection;
local Collectibles = CuerLib.Collectibles;
local ItemPools = CuerLib.ItemPools;
local Fox = ModItem("Fox in Tube", "FOX_IN_TUBE");
local EscapeTextKey = "#FOX_IN_TUBE_ESCAPE"
local Fortunes = {
    TreasureRoom = "#FOX_IN_TUBE_TREASURE",
    SacrificeRoom = "#FOX_IN_TUBE_SACRIFICE",
    Shop = "#FOX_IN_TUBE_SHOP",
    ChallengeRoom = "#FOX_IN_TUBE_CHALLENGE",
    DevilRoom = "#FOX_IN_TUBE_DEVIL",
    AngelRoom = "#FOX_IN_TUBE_ANGEL",
    SecretRoom = "#FOX_IN_TUBE_SECRET",
}

function Fox.GetPayData(init)
    return Fox:GetGlobalData(init, function() return {
        Pays = {},
        CanShowTreasureRoomFortune = false,
        Paying = {}
    }end)
end

function Fox.GetBossData(boss, init)
    return Fox:GetData(boss, init, function() return {
        TargetHP = -1
    } end)
end

function Fox.GetCollectibleData(pickup, init)
    return Fox:GetData(pickup, init, function() return {
        WillDisappear = false
    } end)
end

function Fox.ShowFortune(pay, key)
    local game = THI.Game;
    local strKey = Fortunes[key];
    local textList = {};
    if (key) then
        local subfix = "_HELP";
        if (pay) then
            subfix = "_PAY";
        end
        local category = THI.StringCategories.DEFAULT;
        for i = 1, 5 do
            local key = strKey..subfix.."_"..i
            if (THI.ContainsText(category, key)) then
                textList[i] = THI.GetText(category, key);
            end
        end
    end
    game:GetHUD():ShowFortuneText(textList[1], textList[2], textList[3], textList[4], textList[5]);
end

function Fox.SpawnBottle(subType, position)
    local bottle = THI.Pickups.FoxsAdviceBottle;
    return Isaac.Spawn(bottle.Type, bottle.Variant, subType, position, Vector.Zero, nil);
end

function Fox.AddPay(key, count)
    if (count == nil) then
        count = 1;
    end
    local global = Fox.GetPayData(true);
    global.Pays[key] = (global.Pays[key] or 0) + count;
end

function Fox.RemovePay(key, count)
    if (count == nil) then
        count = 1;
    end
    local global = Fox.GetPayData(true);
    global.Pays[key] = (global.Pays[key] or 0) - count;
    if (global.Pays[key] <= 0) then
        global.Pays[key] = nil;
    end
end

function Fox.AddPaying(key, count)
    if (count == nil) then
        count = 1;
    end
    local global = Fox.GetPayData(true);
    global.Paying[key] = (global.Paying[key] or 0) + count;
end

function Fox.RemovePaying(key, count)
    if (count == nil) then
        count = 1;
    end
    local global = Fox.GetPayData(true);
    global.Paying[key] = (global.Paying[key] or 0) - count;
    if (global.Paying[key] <= 0) then
        global.Paying[key] = nil;
    end
end

function Fox.HasPay(key)
    local global = Fox.GetPayData(true);
    return global.Pays[key] and global.Pays[key] > 0;
end

function Fox.GetPayCount(key)
    local global = Fox.GetPayData(true);
    return global.Pays[key] or 0;
end

local function SealRoom()
    local game = THI.Game;
    local room = game:GetRoom();
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(i);
        if (door and not door:IsLocked()) then
            door:Close();
            door:Bar();
        end
    end
    room:SetClear(false);

end

local function PlayMusic(music)
    local musicManager = MusicManager();
    musicManager:Play(music, 0);
    musicManager:UpdateVolume();
end

function Fox.GetBossHP(base)
    local game = THI.Game;
    local level = game:GetLevel();
    local stage = level:GetStage();

    local totalFps = 0;
    for p, player in Detection.PlayerPairs() do
        totalFps = totalFps + 30 / (player.MaxFireDelay + 1) * player.Damage; 
    end
    totalFps = math.max(1, totalFps);
    return math.min(999999, base * stage * totalFps);
end

function Fox:IsShopUltraGreed()
    local game = THI.Game;
    local level = game:GetLevel();
    local stage = level:GetStage();
    local roomDesc = level:GetCurrentRoomDesc();
    return stage == LevelStage.STAGE4_3 and roomDesc.GridIndex == 84;
end

function Fox.HelpFor(key) 
    
    local game = THI.Game;
    local level = game:GetLevel();
    local room = game:GetRoom();
    local roomType = room:GetType();
    local roomDesc = level:GetCurrentRoomDesc();
    local stage = level:GetStage();
    if (key == "ChallengeRoom") then
        -- Challenge Room.
        local canShowFortune = false;

        local hasSafetyScissors = false;

        for p, player in Detection.PlayerPairs() do
            if (player:HasTrinket(TrinketType.TRINKET_SAFETY_SCISSORS)) then
                hasSafetyScissors = true;
                break
            end
        end
        if (not hasSafetyScissors and not Fox.HasPay("ChallengeRoom")) then

            for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i);
                if (door and door.TargetRoomType == RoomType.ROOM_CHALLENGE and not door:IsOpen()) then
                    door:TryUnlock(game:GetPlayer(0), true);
                    door:Open();
                    canShowFortune = true;
                end
            end
            if (canShowFortune) then
                Fox.AddPay(key);
                Fox.ShowFortune(false, key);
            end
        end
    elseif (key == "TreasureRoom") then
        -- Treasure Room.
        local rerollMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, 10);
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);

        local hasCollectible = false;
        for _, ent in pairs(collectibles) do
            if (ent:Exists()) then
                hasCollectible = true
                break
            end
        end

        if (#rerollMachines <= 0 and hasCollectible) then
            Fox.ShowFortune(false, key);
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
            Fox.SpawnBottle(0, pos);
        end
    elseif (key == "SacrificeRoom") then
        -- Sacrifice Room.
        local valid = false;
        for p, player in Detection.PlayerPairs() do
            local playerType = player:GetPlayerType();
            if (playerType ~= PlayerType.PLAYER_THELOST and playerType ~= PlayerType.PLAYER_THELOST_B and playerType ~=
                PlayerType.PLAYER_KEEPER and playerType ~= PlayerType.PLAYER_KEEPER_B) then
                valid = true;
                break
            end
        end

        if (valid) then
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
            Fox.SpawnBottle(1, pos);
            Fox.ShowFortune(false, key);
        end
    elseif (key == "Shop") then
        -- Shop
        if (not Fox.HasPay("Shop")) then
            local player = game:GetPlayer(0);
            local coins = player:GetNumCoins();

                
            local hasSales = false;
            local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP);

            for _, ent in pairs(pickups) do
                if (ent:Exists()) then
                    local pickup = ent:ToPickup();
                    if (pickup.Price ~= 0) then
                        hasSales = true
                        break
                    end
                end
            end

            if (coins < 30 and hasSales) then
                local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
                Fox.SpawnBottle(2, pos);
                Fox.ShowFortune(false, key);
            end
        end
    elseif (key == "DevilRoom") then
        -- Devil Room.
        local hasCollectible = false;
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);

        for _, ent in pairs(collectibles) do
            if (ent:Exists()) then
                hasCollectible = true
                break
            end
        end

        if (hasCollectible) then
            Fox.ShowFortune(false, key);
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
            Fox.SpawnBottle(3, pos);
        end
    elseif (key == "AngelRoom") then
        local selectableCount = 0;
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);
        for _, ent in pairs(collectibles) do
            local pickup = ent:ToPickup();
            if (ent:Exists() and pickup.OptionsPickupIndex ~= 0) then
                selectableCount = selectableCount + 1;
            end
        end

        if (selectableCount > 1) then
            Fox.ShowFortune(false, key);
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
            Fox.SpawnBottle(4, pos);
        end
    elseif (key == "SecretRoom") then
        Fox.ShowFortune(false, key);
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos());
        Fox.SpawnBottle(5, pos);
    end 
end

function Fox.PayFor(key, num, tryEscape)
    num = num or Fox.GetPayCount(key);

    local game = THI.Game;
    local level = game:GetLevel();
    local room = game:GetRoom();
    local roomType = room:GetType();
    local roomDesc = level:GetCurrentRoomDesc();
    local stage = level:GetStage();
    if (key == "ChallengeRoom") then
        -- Challenge Room.
        local hasSafetyScissors = false;

        for p, player in Detection.PlayerPairs() do
            if (player:HasTrinket(TrinketType.TRINKET_SAFETY_SCISSORS)) then
                hasSafetyScissors = true;
                break;
            end
        end
        
        Fox.RemovePay(key, num);
        if (not hasSafetyScissors) then
            for i = 1, 5 + stage do
                Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_GOLDENTROLL, 0,
                    room:GetRandomPosition(40), Vector.Zero, nil);
            end

            Fox.ShowFortune(true, key);
            return true;
        end
    elseif (key == "SacrificeRoom") then
        -- Sacrifice Room.
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0, -80), 0, true);
        local isaac = Isaac.Spawn(EntityType.ENTITY_ISAAC, 0, 0, pos, Vector.Zero, nil);
        local bossData = Fox.GetBossData(isaac, true);
        bossData.TargetHP = Fox.GetBossHP(5);

        Fox.ShowFortune(true, "SacrificeRoom");
        SealRoom();
        
        if (not tryEscape) then
            Fox.RemovePay(key, 1);
            Fox.AddPaying(key, 1);
        end
        return true;
    elseif (key == "Shop") then
        if (Fox:IsShopUltraGreed()) then
            -- Ultra greed in Hush.
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0, -160), 0, true);
            for i = 1, math.max(1,num) do
                local greed = Isaac.Spawn(EntityType.ENTITY_ULTRA_GREED, 0, 0, pos, Vector.Zero, nil);
                local bossData = Fox.GetBossData(greed, true);
                bossData.TargetHP = Fox.GetBossHP(10);
            end
        else
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true);
            local count = math.max(1, math.ceil(stage * num / 2));
            for i = 1, count do
                local greed = Isaac.Spawn(EntityType.ENTITY_GREED, 1, 0, pos, Vector.Zero, nil);
                local bossData = Fox.GetBossData(greed, true);
                bossData.TargetHP = Fox.GetBossHP(10 / count);
            end
        end
    
        Fox.ShowFortune(true, key);
        SealRoom();
        if (not tryEscape) then
            Fox.RemovePay(key, num);
            Fox.AddPaying(key, num);
        end
        return true;
    elseif (key == "DevilRoom") then
        local pos = room:GetCenterPos() + Vector(0, -140);
        for i = 1, 2 do
            local satan = Isaac.Spawn(EntityType.ENTITY_SATAN, 10, 0, pos, Vector.Zero, nil);
            local bossData = Fox.GetBossData(satan, true);
            bossData.TargetHP = Fox.GetBossHP(10 * num);
        end
        THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);

        -- PlayMusic(Music.MUSIC_SATAN_BOSS);
        Fox.ShowFortune(true, key);
        SealRoom();
        if (not tryEscape) then
            Fox.RemovePay(key, num);
            Fox.AddPaying(key, num);
        end
        return true;
    elseif (key == "AngelRoom") then
        local pos = room:GetCenterPos() + Vector(0, -80);
        for i = 1, 2 do
            local isaac = Isaac.Spawn(EntityType.ENTITY_ISAAC, 0, 0, pos, Vector.Zero, nil);
            local bossData = Fox.GetBossData(isaac, true);
            bossData.TargetHP = Fox.GetBossHP(5 * num);
        end
        THI.SFXManager:Play(SoundEffect.SOUND_SUMMONSOUND);

        Fox.ShowFortune(true, key);
        SealRoom();
        if (not tryEscape) then
            Fox.RemovePay(key, num);
            Fox.AddPaying(key, num);
        end
        return true;
    elseif (key == "SecretRoom") then
        local centerPos = room:GetCenterPos();
        for i = 1, 5 do
            local offset = Vector(0, 0);
            if (i == 1) then
                offset.X = -40;
                offset.Y = -40;
            elseif (i == 2) then
                offset.X = 40;
                offset.Y = -40;
            elseif (i == 3) then
                offset.X = 80;
                offset.Y = 20;
            elseif (i == 4) then
                offset.X = -80;
                offset.Y = 20;
            elseif (i == 5) then
                offset.Y = 60;
            end
            local pos = room:FindFreePickupSpawnPosition(centerPos + offset);


            local seed = room:GetSpawnSeed();
            local pool = game:GetItemPool();
            local roomType = room:GetType();
            local poolType = ItemPools:GetRoomPool(seed);
            local id = pool:GetCollectible(poolType, true, seed);
            local col = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero,
                nil):ToPickup();
            col.Timeout = 30;
            col:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);

            local data = Fox.GetCollectibleData(col, true);
            data.WillDisappear = true;
            col.Wait = 99999;
        end

        Fox.RemovePay("SecretRoom");
        Fox.ShowFortune(true, "SecretRoom");
        return true;
    end
    return false;
end

function Fox.PayForSacrifice()
    return Fox.PayFor("SacrificeRoom");
end


function Fox:PostUpdate()
    local game = THI.Game;
    local room = game:GetRoom();

    if (room:IsMirrorWorld()) then
        return;
    end

    if (Collectibles.IsAnyHasCollectible(Fox.Item)) then
        local level = game:GetLevel();
        local roomType = room:GetType();
        local firstVisit = room:IsFirstVisit();
        local isStart = room:GetFrameCount() == 1;
        local roomDesc = level:GetCurrentRoomDesc();
        local stage = level:GetStage();
        local cleared = room:IsClear();
        local isPaidThisFrame = false;

    
        -- Pays.
        if (isStart) then

            local continuedPaying = false;
            -- Continue Paying.
            local globalData = Fox.GetPayData(false);
            if (globalData) then
                local paying = globalData.Paying;
                for key, num in pairs(paying) do
                    if (Fox.PayFor(key, num, true)) then
                        isPaidThisFrame = true;
                        continuedPaying = true;
                    end
                end
            end

            -- Pay for Shop.
            if (Fox.HasPay("Shop")) then
                if ((roomType == RoomType.ROOM_SHOP and firstVisit) or Fox.IsShopUltraGreed()) then
                    if (Fox.PayFor("Shop")) then
                        isPaidThisFrame = true;
                    end
                end
            end
            
            -- Pay for Challenge Room.
            if (Fox.HasPay("ChallengeRoom")) then
                if (roomType == RoomType.ROOM_CHALLENGE) then
                    if (Fox.PayFor("ChallengeRoom")) then
                        isPaidThisFrame = true;
                    end
                else
                    local num = Fox.GetPayCount("ChallengeRoom");
                    Fox.RemovePay("ChallengeRoom", num);
                end
            end

            -- Pay for Secret Room.
            if (Fox.HasPay("SecretRoom") and firstVisit and roomType == RoomType.ROOM_SECRET) then
                if (Fox.PayFor("SecretRoom")) then
                    isPaidThisFrame = true;
                end
            end

            
            if (globalData and globalData.NewLevel) then
                -- Devil Room Pay.
                if (Fox.HasPay("DevilRoom")) then
                    if (Fox.PayFor("DevilRoom")) then
                        isPaidThisFrame = true;
                    end
                end

                -- Angel Room Pay.
                if (Fox.HasPay("AngelRoom")) then
                    if (Fox.PayFor("AngelRoom")) then
                        isPaidThisFrame = true;
                    end
                end
                globalData.NewLevel = false;
            end

            if (continuedPaying) then
                local escape = THI.GetText(THI.StringCategories.DEFAULT, EscapeTextKey);
                game:GetHUD():ShowFortuneText(escape);
            end
        end

        if (not isPaidThisFrame) then
            -- Flush Paying.
            if (cleared) then
                local globalData = Fox.GetPayData(false);
                if (globalData) then
                    local paying = globalData.Paying;
                    for key, num in pairs(paying) do
                        Fox.RemovePay(key, num);
                        Fox.RemovePaying(key, num);
                    end
                end
            end
            -- Helps
            if (firstVisit and isStart) then
                if (roomType == RoomType.ROOM_TREASURE) then
                    -- Treasure Room Help.
                    Fox.HelpFor("TreasureRoom");
                elseif (roomType == RoomType.ROOM_SACRIFICE) then
                    -- Sacrifice Room Help.
                    Fox.HelpFor("SacrificeRoom");
                elseif (roomType == RoomType.ROOM_SHOP) then
                    -- Shop Help.
                    Fox.HelpFor("Shop");
                elseif (roomType == RoomType.ROOM_DEVIL) then
                    -- Devil Room Help.
                    Fox.HelpFor("DevilRoom");
                elseif (roomType == RoomType.ROOM_ANGEL) then
                    -- Angel Room Help.
                    Fox.HelpFor("AngelRoom");
                elseif (roomType == RoomType.ROOM_SECRET) then
                    -- Secret Room Help.
                    Fox.HelpFor("SecretRoom");
                end
            end
            -- Challenge Help.
            if (firstVisit and cleared) then
                -- Challenge Room Help.
                if (roomType == RoomType.ROOM_DEFAULT) then
                    Fox.HelpFor("ChallengeRoom");
                end
            end
        end
    end
end
Fox:AddCallback(ModCallbacks.MC_POST_UPDATE, Fox.PostUpdate);

function Fox:PreGetCollectible(pool, decrease, seed, loopCount)
    -- Treasure Room Pay.
    if (decrease and seed % 100 < Fox.GetPayCount("TreasureRoom") * 20 and loopCount == 1) then
        Fox.RemovePay("TreasureRoom", 1);
        local data = Fox.GetPayData(true);
        if (data.CanShowTreasureRoomFortune) then
            Fox.ShowFortune(true, "TreasureRoom");
            data.CanShowTreasureRoomFortune = false;
        end
        return CollectibleType.COLLECTIBLE_POOP;
    end
end
Fox:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, Fox.PreGetCollectible, nil, 200)

function Fox:PostPickupRemove(pickup)
    local data = Fox.GetCollectibleData(pickup, false);
    if (data) then
        if (data.WillDisappear) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
        end
    end
end
Fox:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Fox.PostPickupRemove, EntityType.ENTITY_PICKUP);

function Fox:PostNPCUpdate(npc)
    local data = Fox.GetBossData(npc, false);
    if (data and data.TargetHP > 0) then
        local hp = data.TargetHP;
        if (math.abs(hp - npc.MaxHitPoints) > 0.01) then
            if (hp > npc.MaxHitPoints) then
                npc.HitPoints = npc.HitPoints + hp - npc.MaxHitPoints;
            end
            npc.HitPoints = math.min(hp, npc.HitPoints);
            npc.MaxHitPoints = hp;
        end
    end
end
Fox:AddCallback(ModCallbacks.MC_NPC_UPDATE, Fox.PostNPCUpdate)

function Fox:PostNewLevel()
    if (Collectibles.IsAnyHasCollectible(Fox.Item)) then
        local data = Fox.GetPayData(true);
        data.NewLevel = true;
    end
end
Fox:AddCustomCallback(CuerLib.CLCallbacks.CLC_NEW_STAGE, Fox.PostNewLevel);

return Fox;
