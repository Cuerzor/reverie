local Stats = CuerLib.Stats;
local Pickups = CuerLib.Pickups;
local Inputs = CuerLib.Inputs;
local Revive = CuerLib.Revive;
local Actives = CuerLib.Actives;
local Synergies = CuerLib.Synergies;
local Greed = CuerLib.Greed;
local Entities = CuerLib.Entities;
local EntityExists = CuerLib.Entities.EntityExists;
local Tears = CuerLib.Tears;
local Players = CuerLib.Players;
local ItemPools = CuerLib.ItemPools;
local RuneSword = ModItem("Rune Sword", "RUNE_SWORD");
RuneSword.MaxRuneSlot = 6;

local runeTexts = {
    [Card.RUNE_HAGALAZ] = "#RUNE_SWORD_HAGALAZ",
    [Card.RUNE_JERA] = "#RUNE_SWORD_JERA",
    [Card.RUNE_EHWAZ] = "#RUNE_SWORD_EHWAZ",
    [Card.RUNE_DAGAZ] = "#RUNE_SWORD_DAGAZ",
    [Card.RUNE_ANSUZ] = "#RUNE_SWORD_ANSUZ",
    [Card.RUNE_PERTHRO] = "#RUNE_SWORD_PERTHRO",
    [Card.RUNE_BERKANO] = "#RUNE_SWORD_BERKANO",
    [Card.RUNE_ALGIZ] = "#RUNE_SWORD_ALGIZ",
    [Card.RUNE_BLANK] = "#RUNE_SWORD_BLANK_RUNE",
    [Card.RUNE_BLACK] = "#RUNE_SWORD_BLACK_RUNE",
    [Card.RUNE_SHARD] = "#RUNE_SWORD_RUNE_SHARD",
    [Card.CARD_SOUL_ISAAC] = "#RUNE_SWORD_ISAAC",
    [Card.CARD_SOUL_MAGDALENE] = "#RUNE_SWORD_MAGDALENE",
    [Card.CARD_SOUL_CAIN] = "#RUNE_SWORD_CAIN",
    [Card.CARD_SOUL_JUDAS] = "#RUNE_SWORD_JUDAS", 
    [Card.CARD_SOUL_BLUEBABY] = "#RUNE_SWORD_BLUE_BABY" ,
    [Card.CARD_SOUL_EVE] = "#RUNE_SWORD_EVE" ,
    [Card.CARD_SOUL_SAMSON] = "#RUNE_SWORD_SAMSON" ,
    [Card.CARD_SOUL_AZAZEL] = "#RUNE_SWORD_AZAZEL" ,
    [Card.CARD_SOUL_LAZARUS] = "#RUNE_SWORD_LAZARUS" ,
    [Card.CARD_SOUL_EDEN] = "#RUNE_SWORD_EDEN",
    [Card.CARD_SOUL_LOST] = "#RUNE_SWORD_LOST" ,
    [Card.CARD_SOUL_LILITH] = "#RUNE_SWORD_LILITH" ,
    [Card.CARD_SOUL_KEEPER] = "#RUNE_SWORD_KEEPER" ,
    [Card.CARD_SOUL_APOLLYON] = "#RUNE_SWORD_APOLLYON" ,
    [Card.CARD_SOUL_FORGOTTEN] = "#RUNE_SWORD_FORGOTTEN" ,
    [Card.CARD_SOUL_BETHANY] = "#RUNE_SWORD_BETHANY" ,
    [Card.CARD_SOUL_JACOB] = "#RUNE_SWORD_JACOB" ,
}
RuneSword.Texts = runeTexts;

RuneSword.CustomRunes = {
    [THI.Cards.SoulOfEika.ID] = "#RUNE_SWORD_EIKA" ,
    [THI.Cards.SoulOfSatori.ID] = "#RUNE_SWORD_SATORI",
    [THI.Cards.SoulOfSeija.ID] = "#RUNE_SWORD_SEIJA",
    [THI.Cards.SoulOfSeija.ReversedID] = "#RUNE_SWORD_SEIJA_REVERSED"
}

local function GetChanceCounts(chance, value)
    local maxCount = math.ceil(chance / 100);
    local remainedChance = chance % 100;
    local count = maxCount - 1;
    if (value < remainedChance) then
        count = count + 1;
    end
    return count;
end

function RuneSword:GetGlobalRuneData(init)
    return self:GetGlobalData(init, function() return {
        CainChance = 0
    } end)
end

function RuneSword:GetPlayerData(player, init)
    return self:GetData(player, init, function() return {
        InsertedRunes = {},
        HasBlackRune = false,
        RuneCount = 0,
        JudasCount = 0,
        BluebabyTime = 0,
        SamsonDamage = 0,
        AzazelCount = 0,
    } end);
end

function RuneSword:GetPickupData(pickup, init)
    return self:GetData(pickup , init, function() return {
        Duplicated = false
    } end)
end

function RuneSword:GetSamsonDamageLimit(stage, count)
    if (count > 0) then
        return (100 + 65 * stage) * (0.5 + 0.5 / count);
    end
    return -1;
end

function RuneSword:GetFirstPlayerWithRune(rune)
    local game = THI.Game;
    local player = Isaac.GetPlayer(0);
    for i, ply in Players.PlayerPairs() do
        if (RuneSword:HasInsertedRune(ply, rune)) then
            return ply;
        end
    end
    return player;
end

function RuneSword:ShowRuneText(rune)
    local texts = self.Texts;
    local customTexts = self.CustomRunes;
    
    local title = "";
    local desc = "";
    local stringKey = texts[rune] or customTexts[rune];
    if (stringKey) then
        title = THI.GetText(stringKey.."_NAME");
        desc = THI.GetText(stringKey.."_DESCRIPTION");
    end
    THI.Game:GetHUD():ShowItemText(title, desc);

end
function RuneSword:EvaluateInsertedRunes(player)
    local data = self:GetPlayerData(player, true);
    local count = 0;
    for rune, num in pairs(data.InsertedRunes) do
        count = count + num;
    end
    data.RuneCount = count;
end

function RuneSword:HasSword(player)
    return player:HasCollectible(self.Item);
end

function RuneSword:InsertRune(player, rune)
    local data = self:GetPlayerData(player, true);
    local key = rune;
    data.InsertedRunes[key] = (data.InsertedRunes[key] or 0) + 1;

    self:EvaluateInsertedRunes(player);
    RuneSword:PostInsertRune(player, rune);
end
function RuneSword:GetInsertedRuneNum(player, rune, raw)
    if (not raw and not RuneSword:HasSword(player)) then
        return 0;
    end
    local data = self:GetPlayerData(player, false);
    if (data) then
        local key = rune;
        return data.InsertedRunes[key] or 0;
    end
    return 0;
end

function RuneSword:HasInsertedRune(player, rune, raw)
    if (not raw and not RuneSword:HasSword(player)) then
        return false;
    end
    local data = self:GetPlayerData(player, false);
    if (data) then
        local key = rune;
        return data.InsertedRunes[key] ~= nil;
    end
    return false;
end
function RuneSword:GetRuneCount(player, raw)
    if (not raw and not RuneSword:HasSword(player)) then
        return 0;
    end
    local data = self:GetPlayerData(player, false);
    if (data) then
        return data.RuneCount;
    end
    return 0;
end


function RuneSword:GetGlobalRuneCount(rune)
    local game = THI.Game;
    local count = 0;
    for p, player in Players.PlayerPairs() do
        count = count + RuneSword:GetInsertedRuneNum(player, rune);
    end
    return count;
end

function RuneSword:HasGlobalRune(rune)
    local game = THI.Game;
    for p, player in Players.PlayerPairs() do
        if (RuneSword:HasInsertedRune(player, rune)) then
            return true;
        end
    end
    return false;
end

function RuneSword:RemoveRune(player, rune)
    local data = self:GetPlayerData(player, true);
    local key = rune;
    local runes = data.InsertedRunes[key] or 0;
    if (runes > 1) then
        data.InsertedRunes[key] = runes - 1;
    else
        data.InsertedRunes[key] = nil;
    end
    self:EvaluateInsertedRunes(player);
end

function RuneSword.IsRune(rune)
    if ((rune >= Card.RUNE_HAGALAZ and rune <= Card.RUNE_BLACK) or rune == Card.RUNE_SHARD) then
        return true;
    end
    if (rune >= Card.CARD_SOUL_ISAAC and rune <= Card.CARD_SOUL_JACOB) then
        return true;
    end
    if (RuneSword.CustomRunes[rune]) then
        return true;
    end
    return false;
end

function RuneSword.UpdateVisibleRooms()
    local level = THI.Game:GetLevel();
    local visibleDistance = RuneSword:GetGlobalRuneCount(Card.RUNE_ANSUZ);
    local currentRoom = level:GetRoomByIdx(level:GetCurrentRoomIndex());
    local currentIndex = currentRoom.GridIndex;
    local shape = currentRoom.Data.Shape;
    local roomWidth = 1;
    local roomHeight = 2;
    if (shape == RoomShape.ROOMSHAPE_2x1 or shape == RoomShape.ROOMSHAPE_IIH) then
        roomWidth = 2;
    elseif (shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_IIV) then
        roomHeight = 2;
    elseif (shape == RoomShape.ROOMSHAPE_2x2 or
    shape == RoomShape.ROOMSHAPE_LBL or
    shape == RoomShape.ROOMSHAPE_LBR or
    shape == RoomShape.ROOMSHAPE_LTL or
    shape == RoomShape.ROOMSHAPE_LTR) then
        roomWidth = 2
        roomHeight = 2;
    end

    for rx = 0, roomWidth - 1 do
        for ry = 0, roomHeight - 1 do
            local roomX = currentIndex % 13 + rx;
            local roomY = math.floor(currentIndex / 13) + ry;
            
            for x = -visibleDistance, visibleDistance do
                for y = -visibleDistance, visibleDistance do
                    local curX = roomX + x;
                    local curY = roomY + y;
                    if (curX >= 0 and curX < 13 and curY >= 0 and curY < 13) then
                        if (math.abs(x) + math.abs(y) <= visibleDistance) then
                            local curIndex = curY * 13 + curX;
                            local curRoom = level:GetRoomByIdx(curIndex);
                            curRoom.DisplayFlags = curRoom.DisplayFlags | 7;
                        end
                    end
                end
            end
        end
    end
    level:UpdateVisibility ( );
end

function RuneSword:AddCustomRune(id, stringKey)
    local key = id;
    RuneSword.CustomRunes[key] = stringKey;
end

function RuneSword:RemoveCustomRune(id, texts)
    local key = id;
    RuneSword.CustomRunes[key] = nil
end

------------------------------------------------------------------
-- Events
------------------------------------------------------------------

function RuneSword:PostGainRuneSword(player, item, count, touched)
    if (not touched and player.Variant == 0) then
        local itemPool = THI.Game:GetItemPool();
        local seed = player:GetCollectibleRNG(item):Next();
        local rune = itemPool:GetCard(seed, false, true, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, player.Position, Vector.Zero, player);
    end
end
RuneSword:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, RuneSword.PostGainRuneSword, RuneSword.Item);

function RuneSword:UseSword(item, rng, player, flags, slot, varData)
    local slot = 0;
    local rune = player:GetCard(slot);
    local showAnim = true;
    if (RuneSword.IsRune(rune) and flags & UseFlag.USE_CARBATTERY <= 0 and 
    not (THI.IsLunatic() and RuneSword:GetRuneCount(player) >= RuneSword.MaxRuneSlot)) then
        rune = RuneSword:PreInsertRune(player, rune);
        RuneSword:InsertRune(player, rune)
        RuneSword:ShowRuneText(rune);
        THI.SFXManager:Play(SoundEffect.SOUND_TOOTH_AND_NAIL);
        THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
        player:AnimateCollectible(RuneSword.Item, "Pickup");
        --if (player:GetCard(slot) == rune) then
            Players.RemoveCardPill(player, slot)
        --end
        showAnim = false;
    else
        local itemPool = THI.Game:GetItemPool();
        local rune = itemPool:GetCard(rng:Next(), false, true, true);
        player:AddCard (rune);
    end
    if (Actives:CanSpawnWisp(player, flags)) then
        player:AddWisp(RuneSword.Item, player.Position);
    end
    return {ShowAnim = showAnim};
end
RuneSword:AddCallback(ModCallbacks.MC_USE_ITEM, RuneSword.UseSword, RuneSword.Item);

function RuneSword:PostFireTear(tear)
    local player = (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer());
    if (player) then
        local hagalazCount = RuneSword:GetInsertedRuneNum(player, Card.RUNE_HAGALAZ);
        if (hagalazCount > 0) then
            local totalChance = Random() % 3;
            if (hagalazCount > totalChance) then
                tear:AddTearFlags(TearFlags.TEAR_ROCK);
                if (Tears:CanOverrideVariant(TearVariant.Rock, tear.Variant)) then
                    
                    tear:ChangeVariant(TearVariant.ROCK);
                end
            end
        end

        -- Soul of Satori.
        local satoriCount = RuneSword:GetInsertedRuneNum(player, THI.Cards.SoulOfSatori.ID);
        if (satoriCount > 0) then
            local value = Random() % 100;
            if (value < satoriCount * 20) then
                local PsycheEye = THI.Familiars.PsycheEye;
                PsycheEye:AddMindControlTear(tear);
                tear:SetColor(PsycheEye.TearColor, 0, 0);
            end
        end
    end
end
RuneSword:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, RuneSword.PostFireTear);

function RuneSword:RenderOverlay()
    Actives:RenderActivesCount(RuneSword.Item, function(player) 
        local count = RuneSword:GetRuneCount(player);
        local color = nil;
        if (THI.IsLunatic()) then
            local comp = (RuneSword.MaxRuneSlot - count) / RuneSword.MaxRuneSlot;
            color = Color(1,comp,comp,1,0,0,0);
        end
        return count, color
    end)
end
RuneSword:AddCallback(CuerLib.Callbacks.CLC_RENDER_OVERLAY, RuneSword.RenderOverlay);

local function ClearLevel()
    
    local game = THI.Game;
    local room = game:GetRoom();
    -- Ehwaz
    if (RuneSword:HasGlobalRune(Card.RUNE_EHWAZ)) then
        local spawn = true;
        for i = 0, room:GetGridSize() - 1 do
            local gridEnt = room:GetGridEntity(i);
            if (gridEnt and gridEnt:GetType() == GridEntityType.GRID_STAIRS) then
                spawn = false;
                break;
            end
        end
    
        if (spawn) then
            local chance = 100;
            -- if (THI.IsLunatic()) then
            --     chance = RuneSword:GetGlobalRuneCount(Card.RUNE_EHWAZ) * 50;
            -- end
            local value = room:GetDecorationSeed() % 100;
            if (value < chance) then
                local initPos = room:GetCenterPos() + Vector(0, 40);
                local centerIndex = room:GetGridIndex(initPos);
                room:DestroyGrid (centerIndex, true);
                local pos = room:FindFreeTilePosition (initPos, 6);
                room:SpawnGridEntity(room:GetGridIndex(pos), GridEntityType.GRID_STAIRS, 0, Random(), 0);
            end
        end
    end
    -- Soul of Lilith
    for p, player in Players.PlayerPairs() do
        if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_LILITH)) then
            local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
            player:UseCard(Card.CARD_SOUL_LILITH, flags);
        end
    end

    
end
local function PostNewWave()
    local game = THI.Game;
    local room = game:GetRoom();
    -- Soul of Cain
    local cainCount = RuneSword:GetGlobalRuneCount(Card.CARD_SOUL_CAIN); 
    if (cainCount > 0) then
        local globalData = RuneSword:GetGlobalRuneData(true);
        local chance = globalData.CainChance;
        local value = room:GetAwardSeed() % 100;
        if (value < chance) then
            local canUse = false;
            for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                if (room:IsDoorSlotAllowed (slot) and not room:GetDoor (slot)) then
                    canUse = true;
                    break;
                end
            end
            if (canUse) then
                local player = RuneSword:GetFirstPlayerWithRune(Card.CARD_SOUL_CAIN);
                local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
                player:UseCard(Card.CARD_SOUL_CAIN, flags);
                globalData.CainChance = 0;
            end
        else
            globalData.CainChance = globalData.CainChance + math.min(20, cainCount * 5);
        end
    end

    -- Berkano
    for p, player in Players.PlayerPairs() do
        local berkanoCount = RuneSword:GetInsertedRuneNum(player, Card.RUNE_BERKANO);
        if (berkanoCount > 0) then
            player:AddBlueFlies (berkanoCount * 3, player.Position, nil);
            for i = 1, berkanoCount * 3 do
                player:AddBlueSpider  (player.Position);
            end
        end

        -- Azazel.
        if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_AZAZEL)) then
            local data = RuneSword:GetData(player, true);
            data.AzazelCount = data.AzazelCount + 1;
        end

        -- Soul of Apollyon
        local apollyonCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_APOLLYON);
        if (apollyonCount > 0) then
            local seed = Random();
            local rng = RNG();
            rng:SetSeed(seed , 0);
            for i = 1, apollyonCount * 3 do
                local subType = rng:RandomInt(5) + 1;
                local ent = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subType, player.Position, Vector.Zero, player);

            end
        end

        -- Bethany
        local bethanyCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_BETHANY);
        if (bethanyCount > 0) then
            for i = 1, bethanyCount do
                player:AddWisp(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, player.Position);
            end
        end
    end
    local levelCleared = not game:IsGreedMode() and room:GetType() == RoomType.ROOM_BOSS;
    if (levelCleared) then
        ClearLevel();
    end
end
local function PostRoomStart()
    local game = THI.Game;
    local room = game:GetRoom();
            
    local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
    for p, player in Players.PlayerPairs() do
        if (room:GetAliveEnemiesCount() > 0) then
            -- Soul of Magdalene
            if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_MAGDALENE)) then
                player:UseCard(Card.CARD_SOUL_MAGDALENE, flags);
            end
            -- Soul of Azazel
            if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_AZAZEL)) then
                local data = RuneSword:GetData(player, false);
                if (data and data.AzazelCount > 4) then
                    player:UseCard(Card.CARD_SOUL_AZAZEL, flags);
                    data.AzazelCount = 0
                end
            end

        end
        
        if (room:IsFirstVisit()) then
            local lostCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_LOST);
            if (lostCount > 0) then
                local chance = lostCount * 10;
                local value = room:GetDecorationSeed() % 100;
                if (value < chance) then
                    player:UseCard(Card.CARD_HOLY, flags);
                end
            end
        end
    end
end
function RuneSword:PreSpawnCleanAward(rng, spawnPosition)
    PostNewWave();
end
RuneSword:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, RuneSword.PreSpawnCleanAward);


function RuneSword:PostNewGreedWave(wave)
    PostNewWave();
    PostRoomStart();
end
RuneSword:AddCallback(CuerLib.Callbacks.CLC_POST_NEW_GREED_WAVE, RuneSword.PostNewGreedWave);

function RuneSword:PostGreedWaveEnd(state)
    if (state == Greed.GreedState.GREED_BOSS_CLEARED) then
        ClearLevel();
    end
end
RuneSword:AddCallback(CuerLib.Callbacks.CLC_POST_GREED_WAVE_END, RuneSword.PostGreedWaveEnd);

local function CanDuplicate(pickup)
    if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or Pickups:IsSpecialPickup(pickup.Variant)) then
        return false;
    end

    if (Pickups:IsChest(pickup.Variant) and pickup.SubType == ChestSubType.CHEST_OPENED) then
        return false;
    end
    return true;
end
local function DuplicatePickup(pickup)
    local jeraCount = RuneSword:GetGlobalRuneCount(Card.RUNE_JERA);
    local pickupData = RuneSword:GetPickupData(pickup, false);
    local room = THI.Game:GetRoom();
    local chance = jeraCount * 50;
    local value = pickup.InitSeed % 100;
    local times = GetChanceCounts(chance, value);
    for i = 1, times do
        local pos = room:FindFreePickupSpawnPosition(pickup.Position);
        local new = Isaac.Spawn(pickup.Type, pickup.Variant, pickup.SubType, pos, Vector.Zero, nil);
    end
end

function RuneSword:PostUpdate()
    
    local game = THI.Game;
    local room = game:GetRoom();
    if (room:GetFrameCount() == 1) then

        if (room:IsFirstVisit()) then
            if (RuneSword:HasGlobalRune(Card.RUNE_JERA)) then
                for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
                    if (CanDuplicate(ent)) then
                        DuplicatePickup(ent:ToPickup());
                    end
                end
            end
            -- Soul of Isaac
            local isaacCount = RuneSword:GetGlobalRuneCount(Card.CARD_SOUL_ISAAC);
            if (isaacCount > 0) then
                local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);
                if (#collectibles > 0) then
                    local seed = room:GetAwardSeed();
                    local chance = isaacCount * 50;
                    local value = seed % 100;
                    local times = GetChanceCounts(chance, value);
                    local player = RuneSword:GetFirstPlayerWithRune(Card.CARD_SOUL_ISAAC)
    
                    local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
                    for i = 1, times do
                        player:UseCard(Card.CARD_SOUL_ISAAC, flags);
                    end
                end
            end
        end


        PostRoomStart();
    end
    
end
RuneSword:AddCallback(ModCallbacks.MC_POST_UPDATE, RuneSword.PostUpdate);


function RuneSword:PostNewRoom()
    local game = Game();
    local room = game:GetRoom();
    if (RuneSword:HasGlobalRune(Card.RUNE_ANSUZ)) then
        RuneSword.UpdateVisibleRooms();
    end

    for p, player in Players.PlayerPairs() do
        local judasCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_JUDAS);
        if (judasCount > 0 and room:GetAliveEnemiesCount() > 0) then
            local data = RuneSword:GetPlayerData(player, true);
            data.JudasCount = judasCount;
        end
    end

end
RuneSword:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RuneSword.PostNewRoom);

function RuneSword:PreProjectileCollision(proj, other, low)
    if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
        if (other.Type == EntityType.ENTITY_PLAYER) then
            local player = other:ToPlayer();
            if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_JUDAS)) then
                local data = RuneSword:GetPlayerData(other, false);
                if (data and data.JudasCount > 0) then
                    if (not player:HasInvincibility()) then
                        local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
                        player:UseCard(Card.CARD_SOUL_JUDAS, flags);
                        data.JudasCount = data.JudasCount - 1;
                    end
                end
            end
        end
    end
end
RuneSword:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.LATE, RuneSword.PreProjectileCollision);

function RuneSword:PreNPCCollision(npc, other, low)
    if (not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and npc.CollisionDamage > 0) then
        if (npc:IsActiveEnemy() and
            other.Type == EntityType.ENTITY_PLAYER) then
            local player = other:ToPlayer();
            if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_JUDAS)) then
                local data = RuneSword:GetPlayerData(other, false);
                local judasCount = (data and data.JudasCount) or 0;
                if (judasCount > 0) then
                    if (not player:HasInvincibility()) then
                        local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
                        player:UseCard(Card.CARD_SOUL_JUDAS, flags);
                        data.JudasCount = data.JudasCount - 1;
                    end
                end
            end
        end
    end
end
RuneSword:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, RuneSword.PreNPCCollision);

function RuneSword:PostFamiliarKill(entity)
    if (entity.Variant == FamiliarVariant.WISP and entity.SubType == RuneSword.Item) then
        local itemPool = THI.Game:GetItemPool();
        local rune = itemPool:GetCard(entity.DropSeed, false, true, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, entity.Position, Vector.Zero, entity);
    end
end
RuneSword:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, RuneSword.PostFamiliarKill, EntityType.ENTITY_FAMILIAR);

local fartColor = Color(1,1,1,1,0,0,0);
fartColor:SetColorize(1, 0.8, 0.8, 1);
function RuneSword:PostPlayerEffect(player)
    local game = THI.Game;
    if (not player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_TWO) and RuneSword:HasInsertedRune(player, Card.CARD_SOUL_BLUEBABY)) then
        local pressing = Inputs.IsPressingShoot(player);
        local data = RuneSword:GetPlayerData(player, true);
        if (pressing) then
            data.BluebabyTime = data.BluebabyTime + 1;
        else
            data.BluebabyTime = 0;
        end

        if (data.BluebabyTime >= 90) then
            game:Fart (player.Position, 85, player, 1, 0, fartColor);
            local ent = Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_BUTT, 0, player.Position, Vector.Zero, player);
            local bomb = ent:ToBomb();
            bomb:AddTearFlags(player:GetBombFlags ( ) | TearFlags.TEAR_BUTT_BOMB);
            data.BluebabyTime = 0;
        end
    end

    local samsonCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_SAMSON);
    if (samsonCount > 0 and player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BERSERK) <= 0) then
        local data = RuneSword:GetPlayerData(player, false);
        if (data) then
            local level = game:GetLevel();
            local limit = RuneSword:GetSamsonDamageLimit(level:GetStage(), samsonCount);
            if (data.SamsonDamage > limit) then
                data.SamsonDamage = 0;
                player:AddCacheFlags(CacheFlag.CACHE_COLOR);
                player:EvaluateItems();

                local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
                player:UseCard(Card.CARD_SOUL_SAMSON, flags);
            end
        end
    else
        local data = RuneSword:GetPlayerData(player, false);
        if (data) then
            data.SamsonDamage = 0;
            player:AddCacheFlags(CacheFlag.CACHE_COLOR);
            player:EvaluateItems();
        end
    end

    local data = RuneSword:GetPlayerData(player, false);
    if (data) then
        local hasBlackRune = RuneSword:HasInsertedRune(player, Card.RUNE_BLACK);
        if (data.HasBlackRune ~= hasBlackRune) then
            player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            data.HasBlackRune = hasBlackRune;
        end
    end
end
RuneSword:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, RuneSword.PostPlayerEffect);

function RuneSword:EvaluateCurse(curses)
    if (RuneSword:HasGlobalRune(Card.RUNE_DAGAZ)) then
        return 0;
    end
end
RuneSword:AddPriorityCallback(CuerLib.Callbacks.CLC_EVALUATE_CURSE, CallbackPriority.LATE, RuneSword.EvaluateCurse);

function RuneSword:EvaluateCache(player, cache)
    local blackRuneCount = RuneSword:GetInsertedRuneNum(player, Card.RUNE_BLACK);
    if (cache == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + blackRuneCount * 0.2;
    elseif (cache == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + blackRuneCount;
    elseif (cache == CacheFlag.CACHE_DAMAGE) then
        Stats:AddFlatDamage(player, blackRuneCount);
    elseif (cache == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + blackRuneCount * 0.2;
    elseif (cache == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + blackRuneCount *1.5;
    elseif (cache == CacheFlag.CACHE_FIREDELAY) then
        Stats:AddTearsModifier(player, function(tears)
            return tears + 0.5 * blackRuneCount
        end);
    elseif (cache == CacheFlag.CACHE_COLOR) then
        local data = RuneSword:GetPlayerData(player, false);
        if (data) then
            if (data.SamsonDamage > 0) then
                local samsonCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_SAMSON);
                local level = THI.Game:GetLevel();
                local limit = RuneSword:GetSamsonDamageLimit(level:GetStage(), samsonCount);
                local percent = data.SamsonDamage / limit;

                local otherComp = 1 - percent;
                local newColor = Color(1, otherComp,otherComp, 1);
                player:SetColor(newColor, -1, 50, false, true);
            end
        end
    end
end
RuneSword:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RuneSword.EvaluateCache);

function RuneSword:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        local player = tookDamage:ToPlayer();
        local algizCount = RuneSword:GetInsertedRuneNum(player, Card.RUNE_ALGIZ);
        if (algizCount > 0) then
            local chance = algizCount * 20;
            local maxCount = math.ceil(chance / 100);
            local remainedChance = chance % 100;
            local value = Random() % 100;
            local count = maxCount - 1;
            if (value < remainedChance) then
                count = count + 1;
            end

            if (count > 0) then
                local effects = player:GetEffects();
                effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, count);
            end
        end
        
        local eveCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_EVE);
        local birdCount = #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD);
        for i = 1, math.min(32 - birdCount, eveCount * 2) do
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, player.Position, Vector.Zero, player);
        end

        local forgottenCount = RuneSword:GetInsertedRuneNum(player, Card.CARD_SOUL_FORGOTTEN);
        local chance = math.min(50, forgottenCount * 10);
        local value = Random() % 100;
        if (value < chance) then
            local room = THI.Game:GetRoom();
            local pos = room:FindFreePickupSpawnPosition(player.Position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, pos, Vector.Zero, player);
        end
    elseif (tookDamage:IsEnemy()) then
        local player = nil;
        local spawner = source.Entity;
        while (spawner ~= nil) do
            local p = spawner:ToPlayer();
            if (p) then
                player = p;
                break;
            end
            spawner = spawner.SpawnerEntity;
        end
        if (player) then
            if (player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BERSERK) <= 0) then
                if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_SAMSON)) then
                    local playerData = RuneSword:GetPlayerData(player, true);
                    playerData.SamsonDamage = playerData.SamsonDamage + math.min(tookDamage.HitPoints, amount);
                    player:AddCacheFlags(CacheFlag.CACHE_COLOR);
                    player:EvaluateItems();
                end
            end
        end
    end
end
RuneSword:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, RuneSword.PostTakeDamage);

-- function RuneSword:PreEntitySpawn(Type, Variant, SubType, Position, Velocity, Spawner, Seed)
--     if (Type == EntityType.ENTITY_PICKUP) then
--         if (Variant == PickupVariant.PICKUP_TAROTCARD and SubType == 0) then
--             local game = THI.Game;
--             local hasSword = false;
--             for p, player in Players.PlayerPairs() do
--                 if (RuneSword:HasSword(player)) then
--                     hasSword = true;
--                     break;
--                 end
--             end
--             if (hasSword) then
--                 local itemPool = game:GetItemPool();
--                 local chance = 10;
--                 local value = Seed % 100;
--                 if (value < chance) then
--                     local rune = itemPool:GetCard(Seed, false, true, true);
--                     return { Type, PickupVariant.PICKUP_TAROTCARD, rune, Seed }
--                 end
--             end
--         end
--     end
-- end
-- RuneSword:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, RuneSword.PreEntitySpawn)

function RuneSword:PostBombRemoved(entity)
    if (entity.Variant ~= BombVariant.BOMB_THROWABLE) then
        
    local player = (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer());
    if (player) then
        local perthroCoount = RuneSword:GetInsertedRuneNum(player, Card.RUNE_PERTHRO);
        if (perthroCoount > 0) then
            
            local bomb = entity:ToBomb();
            local canReroll = false;
            for _, ent in pairs(Isaac.FindByType(1000, 1)) do
                if (ent.Position:Distance(entity.Position) <= 1) then
                    canReroll = true;
                    goto checkReroll;
                end
            end

            ::checkReroll::
            if (canReroll) then
                local radius = 80 * bomb.RadiusMultiplier;
                for _, pick in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    if (pick.SubType > 0 and pick.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and bomb.Position:Distance(pick.Position) <= radius) then
                        local pickup = pick:ToPickup();
                        if (pickup.Wait <= 0) then
                            local seed = pick.InitSeed;
                            local rdm = seed % 100;
                            local disappearChance = (30 + 40*0.5^perthroCoount)
                            if (rdm < disappearChance) then
                                pick:Remove();
                            else
                                local game = THI.Game;
                                local room = game:GetRoom();
                                local item = room:GetSeededCollectible(seed);
                                pickup:Morph(pick.Type, pick.Variant, item, true, false, false);
                                pickup.Touched = false;
                            end 
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pick.Position, Vector.Zero, nil);
                        end
                    end
                end
            end
        end
    end
    end
        
end
RuneSword:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, RuneSword.PostBombRemoved, EntityType.ENTITY_BOMBDROP);

local function PostEntityKill(mod, entity)
    local npc = entity:ToNPC();
    if (npc and npc:IsActiveEnemy(true)) then
        local count = RuneSword:GetGlobalRuneCount(Card.CARD_SOUL_KEEPER)
        if (count > 0) then
            local chance = count * 40;
            local value = entity.DropSeed % 100;
            local times = GetChanceCounts(chance, value);
            for i = 1, times do
                local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, entity.Position, RandomVector(), entity):ToPickup();
                coin.Timeout = 60;
            end
        end
        
        local eikaCount = RuneSword:GetGlobalRuneCount(THI.Cards.SoulOfEika.ID);
        if (eikaCount > 0) then
            local firstPlayer = RuneSword:GetFirstPlayerWithRune(THI.Cards.SoulOfEika.ID);
            local chance = math.min(eikaCount * 2, 20);
            local value = npc.DropSeed % 100;
            local times = GetChanceCounts(chance, value);
            if (value < chance) then
                local BloodBony = THI.Monsters.BloodBony;
                local bony = Isaac.Spawn(BloodBony.Type, BloodBony.Variant, BloodBony.SubTypes.PERNAMENT, npc.Position, Vector.Zero, firstPlayer);
                bony:AddCharmed(EntityRef(firstPlayer), -1);
                THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);
            end
        end
    end
end
RuneSword:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);



function RuneSword:PreInsertRune(player, rune)
    if (rune == Card.RUNE_SHARD or rune == Card.RUNE_BLANK) then
        local rng = player:GetCollectibleRNG(RuneSword.Item);
        local value = rng:RandomInt(9);
        if (value == 8) then
            return Card.RUNE_BLACK;
        else
            return Card.RUNE_HAGALAZ + value;
        end
    end
    return rune;
end

function RuneSword:PostInsertRune(player, rune)
    if (rune == Card.RUNE_DAGAZ) then
        player:AddSoulHearts(4);
        THI:EvaluateCurses();
    elseif (rune == Card.RUNE_ANSUZ) then
        RuneSword.UpdateVisibleRooms()
    elseif (rune == Card.RUNE_BLACK) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
    elseif (rune == Card.CARD_SOUL_EDEN) then
        local itemPool = THI.Game:GetItemPool();
        local seed = player:GetCollectibleRNG(RuneSword.Item):Next();
        local pool = itemPool:GetPoolForRoom(RoomType.ROOM_ERROR, seed);
        local col = itemPool:GetCollectible (pool, true, seed);
        local room = THI.Game:GetRoom();
        local pos = room:FindFreePickupSpawnPosition(player.Position);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, col, pos, Vector.Zero, player);
        player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
    elseif (rune == Card.CARD_SOUL_LOST) then
        local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME;
        player:UseCard(Card.CARD_HOLY, flags);
    elseif (rune == Card.CARD_SOUL_JACOB) then
        local room = THI.Game:GetRoom();
        local pos = room:FindFreePickupSpawnPosition(player.Position);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_BIRTHRIGHT, pos, Vector.Zero, player);
    else
        local SoulOfSeija = THI.Cards.SoulOfSeija;
        if (rune == SoulOfSeija.ID or rune == SoulOfSeija.ReversedID) then
            player:AddCacheFlags(CacheFlag.CACHE_ALL);
            player:EvaluateItems();
        end
    end
end

do

    ---@type ReviveCallback
    local function ReviveCallback(player, reviver)
        player:AnimateCard(Card.CARD_SOUL_LAZARUS);
        RuneSword:RemoveRune(reviver, Card.CARD_SOUL_LAZARUS);
    end
    
    local function PreRevive(mod, player)
        if (RuneSword:HasInsertedRune(player, Card.CARD_SOUL_LAZARUS)) then
            ---@type ReviveInfo
            return {
                BeforeVanilla = true,
                Callback = ReviveCallback,
            }
        end
    end
    RuneSword:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_REVIVE, 10, PreRevive)
end

return RuneSword;