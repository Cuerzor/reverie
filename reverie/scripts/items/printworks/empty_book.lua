local Inputs = CuerLib.Inputs;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local Shields = CuerLib.Shields;
local Actives = CuerLib.Actives; 
local Screen = CuerLib.Screen;
local HoldingActive = CuerLib.HoldingActive;
local EmptyBook = ModItem("Empty Book", "EmptyBook")

local FinishedBooks = {
    Isaac.GetItemIdByName("My Manual"),
    Isaac.GetItemIdByName("My Guide"),
    Isaac.GetItemIdByName("My History")
}
EmptyBook.FinishedBooks = FinishedBooks;

local FamiliarPool = {
    {Familiar = 2, Collectible = CollectibleType.COLLECTIBLE_DEMON_BABY}, --Demon Baby
    {Familiar = 56, Collectible = CollectibleType.COLLECTIBLE_LEECH}, --Leech
    {Familiar = 61, Collectible = CollectibleType.COLLECTIBLE_LIL_BRIMSTONE}, -- lil Brimstone
    {Familiar = 64, Collectible = CollectibleType.COLLECTIBLE_DARK_BUM}, -- Dark Bum
    {Familiar = 80, Collectible = CollectibleType.COLLECTIBLE_INCUBUS}, --Incubus
    {Familiar = 96, Collectible = CollectibleType.COLLECTIBLE_SUCCUBUS}, --Succubs
    {Familiar = 230, Collectible = CollectibleType.COLLECTIBLE_LIL_ABADDON}, -- Lil Abaddon
    {Familiar = 235, Collectible = CollectibleType.COLLECTIBLE_TWISTED_PAIR}, -- Twisted Pair
}
local Sizes = {
    SMALL = 0,
    MEDIUM = 1,
    LARGE = 2,
}
local ActiveEffects = {
    INCANTATION = 0,
    PRAYING = 1,
    COLLECTION = 2,
    FORBIDDEN = 3,
    PROTECTION = 4,
    FAMILIARS = 5,
    EXPLORATION = 6
}
local PassiveEffects = {
    GOODWILLED = 0,
    WISE = 1,
    PRECISE = 2,
    MEAN = 3,
    CLEAR = 4,
    SELFLESS = 5,
    INNOVATIVE = 6
}
EmptyBook.Sizes = Sizes;
EmptyBook.ActiveEffects = ActiveEffects;
EmptyBook.PassiveEffects = PassiveEffects;

local BookStrings = {
    Template = { 
        Name = "#KOSUZU_BOOK_TEMPLATE_NAME",
        Desc = "#KOSUZU_BOOK_TEMPLATE_DESCRIPTION"
    },
    Default = {
        Size = "#KOSUZU_BOOK_SIZE_DEFAULT",
        Class = "#KOSUZU_BOOK_CLASS_DEFAULT", 
        Adjective = "#KOSUZU_BOOK_ADJECTIVE_DEFAULT",
    },
    Sizes = {
        "#KOSUZU_BOOK_SIZE_SMALL",
        "#KOSUZU_BOOK_SIZE_MEDIUM",
        "#KOSUZU_BOOK_SIZE_LARGE"
    },
    Classes = {
        "#KOSUZU_BOOK_CLASS_STAT",
        "#KOSUZU_BOOK_CLASS_HEART",
        "#KOSUZU_BOOK_CLASS_PICKUP",
        "#KOSUZU_BOOK_CLASS_DAMAGE",
        "#KOSUZU_BOOK_CLASS_SHIELD",
        "#KOSUZU_BOOK_CLASS_SUMMON",
        "#KOSUZU_BOOK_CLASS_DICE"
    },
    Adjectives = {
        "#KOSUZU_BOOK_ADJECTIVE_ANGEL",
        "#KOSUZU_BOOK_ADJECTIVE_NO_CURSE",
        "#KOSUZU_BOOK_ADJECTIVE_COMPASS",
        "#KOSUZU_BOOK_ADJECTIVE_DAMAGE",
        "#KOSUZU_BOOK_ADJECTIVE_SPEED",
        "#KOSUZU_BOOK_ADJECTIVE_HABIT",
        "#KOSUZU_BOOK_ADJECTIVE_WISP",
    },
}

local sizeCount = 3;
local activeEffectCount = 7;
local passiveEffectCount = 7;

local ChoiceSprite = Sprite();
ChoiceSprite:Load("gfx/reverie/ui/empty_book.anm2", true);

local FrameSprite = Sprite();
FrameSprite:Load("gfx/reverie/ui/select_frame.anm2", true);
FrameSprite:SetFrame("Frame", 0);

local function IsWriting(player)
    return HoldingActive:GetHoldingItem(player) == EmptyBook.Item;
end

function EmptyBook:GetGlobalBookData(init)
    return EmptyBook:GetGlobalData(init, function () 
        local seed = Game():GetSeeds():GetStartSeed();
        local rng = RNG();
        rng:SetSeed(seed, 0);
        return {
            ChooseTime = 0,
            Effect = -1,
            MakingEffect = 0,
            Seed = seed,
            ActiveChoices = EmptyBook:GenerateChoices(rng, activeEffectCount),
            PassiveChoices = EmptyBook:GenerateChoices(rng, passiveEffectCount)
        };
    end);
end

function EmptyBook:GetPlayerData(player, init)
    return EmptyBook:GetData(player, init, function() return {
        Choice = 0,
        DamageBoost = 1,
        Familiars = {}
    } end);
end

function EmptyBook.GetBookEffect()
    local data = EmptyBook:GetGlobalBookData(false);
    if (data) then
        return data.Effect;
    end
    return -1;
end

local function GetBookSize(effect)
    if (effect < 0) then
        return -1;
    end
    return effect % sizeCount;
end
local function GetBookActive(effect)
    if (effect < 0) then
        return -1;
    end
    return math.floor(effect / sizeCount) % passiveEffectCount;
end
local function GetBookPassive(effect)
    if (effect < 0) then
        return -1;
    end
    return math.floor(effect / (sizeCount * activeEffectCount));
end
EmptyBook.GetBookSize = GetBookSize;
EmptyBook.GetBookActive = GetBookActive;
EmptyBook.GetBookPassive = GetBookPassive;





local function GetBookName(active, size, language)
    language = language or Options.Language;

    local strings = BookStrings;
    local sizeKey = strings.Default.Size;
    local classKey = strings.Default.Class;
    if (size >= 0) then
        sizeKey = strings.Sizes[size + 1];
    end

    if (active >= 0) then
        classKey = strings.Classes[active + 1];
    end

    local str = THI.GetText(THI.StringCategories.DEFAULT, strings.Template.Name, language);
    local sizeName = THI.GetText(THI.StringCategories.DEFAULT, sizeKey, language);
    local className = THI.GetText(THI.StringCategories.DEFAULT, classKey, language);
    str = string.gsub(str, "{SIZE}", sizeName);
    str = string.gsub(str, "{CLASS}", className)
    return str;
end
EmptyBook.GetBookName = GetBookName;

local function GetBookDescription(effect)
    local passive = GetBookPassive(effect);
    local strings = BookStrings;
    local adjectiveKey = strings.Default.Adjective;
    if (passive >= 0) then
        adjectiveKey = strings.Adjectives[passive + 1];
    end

    local str = THI.GetText(THI.StringCategories.DEFAULT, strings.Template.Desc);
    local adjectiveStr = THI.GetText(THI.StringCategories.DEFAULT, adjectiveKey);
    str = string.gsub(str, "{ADJECTIVE}", adjectiveStr);
    return str;
end

function EmptyBook.ShowBookItemText(effect, size)
    local active = GetBookActive(effect);
    THI.Game:GetHUD():ShowItemText(GetBookName(active, size), GetBookDescription(effect), false);
end

function EmptyBook:PostPlayerUpdate(player)
    if (IsWriting(player)) then
        local playerData = EmptyBook:GetPlayerData(player, true);
        if (playerData) then

            if (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)) then
                playerData.Choice = (playerData.Choice - 1) % 3;
            end
            
            if (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)) then
                playerData.Choice = (playerData.Choice + 1) % 3;
            end
            if (Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)  or not player:HasCollectible(EmptyBook.Item)) then
                HoldingActive:Cancel(player);
                player:AnimateCollectible(EmptyBook.Item, "HideItem");
            end
        end
    end


end

EmptyBook:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, EmptyBook.PostPlayerUpdate);

local function GetChoiceId(choice, time)
    local data = EmptyBook:GetGlobalBookData(false);
    if (data) then
        if (time == 1) then
            return data.ActiveChoices[choice + 1];
        elseif (time == 2) then
            return data.PassiveChoices[choice + 1];
        end
    end
    return choice;
end

local function HasFinishedBook(player)
    return player:HasCollectible(FinishedBooks[1]) or 
    player:HasCollectible(FinishedBooks[2]) or
    player:HasCollectible(FinishedBooks[3]);
end

function EmptyBook:GenerateChoices(rng, maxCount)
    -- Active.
    local pool = {};
    local results = {};
    for i = 1, maxCount do
        pool[i] = i - 1;
    end

    for i=1,3 do
        local index = rng:RandomInt(#pool) + 1;
        results[i] = pool[index];
        table.remove(pool, index);
    end
    return results;
end

local function SetBookSeed(seed)
    local data = EmptyBook:GetGlobalBookData(true);
    data.Seed = seed;

    local rng = RNG();
    rng:SetSeed(seed, 0);
    data.ActiveChoices = EmptyBook:GenerateChoices(rng, activeEffectCount);
    data.PassiveChoices = EmptyBook:GenerateChoices(rng, passiveEffectCount);
end

local function NextBookSeed()
    local data = EmptyBook:GetGlobalBookData(true);
    local rng = RNG();
    rng:SetSeed(data.Seed, 0);
    local newSeed = rng:Next();
    SetBookSeed(newSeed);
end

function EmptyBook:UseEmptyBook(item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_CARBATTERY <= 0) then
        local playerData = EmptyBook:GetPlayerData(player, true);
        local holding = HoldingActive:GetHoldingItem(player);
        if (holding <= 0) then
            HoldingActive:Hold(item, player, slot, flags);
        elseif (holding == EmptyBook.Item) then
            local globalData = EmptyBook:GetGlobalBookData(true);
            if (globalData.ChooseTime == 0) then
                globalData.MakingEffect = GetChoiceId(playerData.Choice, globalData.ChooseTime);
                THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                HoldingActive:Hold(item, player, slot, flags);
            elseif (globalData.ChooseTime == 1) then
                globalData.MakingEffect = globalData.MakingEffect + GetChoiceId(playerData.Choice, globalData.ChooseTime) * 3;
                THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                HoldingActive:Hold(item, player, slot, flags);
            else
                globalData.MakingEffect = globalData.MakingEffect + GetChoiceId(playerData.Choice, globalData.ChooseTime) * 3 * 7;
                THI.SFXManager:Play(SoundEffect.SOUND_POWERUP_SPEWER);
                globalData.Effect = globalData.MakingEffect;
                HoldingActive:Cancel(player);
                globalData.MakingEffect = 0;
                NextBookSeed();
                -- Get New Book.
                player:RemoveCollectible(item, true, slot, true);
                local size = GetBookSize(globalData.Effect);
                local newBook = FinishedBooks[size + 1];
                player:AddCollectible(newBook, -1, true, slot);
                player:AnimateCollectible(newBook, "Pickup");
                EmptyBook.ShowBookItemText(globalData.Effect, size);
            end
            

            globalData.ChooseTime = (globalData.ChooseTime + 1) % 3;
        end
    end
    return {Discharge = false}
end
EmptyBook:AddCallback(ModCallbacks.MC_USE_ITEM, EmptyBook.UseEmptyBook, EmptyBook.Item);


function EmptyBook:PostNewRoom()
    local game = THI.Game;
    for i, player in Players.PlayerPairs(true, true) do
        local playerData = EmptyBook:GetPlayerData(player, false);
        if (playerData) then
            if (math.abs(playerData.DamageBoost - 1) < 1e08) then
                playerData.DamageBoost = 1;
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems();
            end

            -- local hasFamiliar = 0;
            -- for k, v in pairs(playerData.Familiars) do
            --     hasFamiliar = true;
            --     break;
            -- end
            -- if (hasFamiliar) then
            --     playerData.Familiars = {};
            --     player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
            --     player:EvaluateItems();
            -- end
        end
    end
end 
EmptyBook:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EmptyBook.PostNewRoom);

function EmptyBook:PostNewLevel()
    local game = THI.Game;
    local globalData = EmptyBook:GetGlobalBookData(false);
    if (globalData) then
        local passive = GetBookPassive(globalData.Effect);
        if (passive == 0) then
            -- Goodwilled
            local num = 0;
            for i, player in Players.PlayerPairs() do
                num = num + player:GetCollectibleNum(FinishedBooks[1]) + 
                    player:GetCollectibleNum(FinishedBooks[2]) + 
                    player:GetCollectibleNum(FinishedBooks[3]); 
            end
            game:GetLevel():AddAngelRoomChance(num * 0.1);
        elseif (passive == 2) then
            -- Precise
            local compass = false;
            for i, player in Players.PlayerPairs() do
                if (HasFinishedBook(player)) then
                    compass = true;
                    break;
                end
            end
            if (compass) then
                game:GetLevel():ApplyCompassEffect(false);
            end
        end
    end
end 
EmptyBook:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, EmptyBook.PostNewLevel);

function EmptyBook:EvaluateCurse(curses)
    local game = THI.Game;
    local globalData = EmptyBook:GetGlobalBookData(false);
    if (globalData) then
        local passive = GetBookPassive(globalData.Effect);
        if (passive == 1) then
            -- Wise
            local dispel = false;
            for i, player in Players.PlayerPairs() do
                if (HasFinishedBook(player)) then
                    dispel = true;
                    break;
                end
            end
            if (dispel) then
                return curses & ~(LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND);
            end
        end
    end
end
EmptyBook:AddPriorityCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, CallbackPriority.LATE, EmptyBook.EvaluateCurse);

function EmptyBook:OnEvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_SPEED) then
        
        local globalData = EmptyBook:GetGlobalBookData(false);
        if (globalData) then
            if (HasFinishedBook(player) and GetBookPassive(globalData.Effect) == PassiveEffects.CLEAR) then
                player.MoveSpeed = player.MoveSpeed + 0.15;
            end
        end

    elseif (cache == CacheFlag.CACHE_DAMAGE) then
        local playerData = EmptyBook:GetPlayerData(player, false);
        
        local globalData = EmptyBook:GetGlobalBookData(false);
        if (globalData) then
            if (HasFinishedBook(player) and GetBookPassive(globalData.Effect) == PassiveEffects.MEAN) then
                Stats:AddFlatDamage(player, 2);
            end
        end

        if (playerData) then
            Stats:MultiplyDamage(player, playerData.DamageBoost);
        end
    end
end
EmptyBook:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EmptyBook.OnEvaluateCache);

function EmptyBook:PostEntityTakeDamage(tookDamage, amount, flags, source, countdown)
    local player = tookDamage:ToPlayer();
    if (player) then
        local globalData = EmptyBook:GetGlobalBookData(false);
        if (globalData) then
            if (HasFinishedBook(player) and GetBookPassive(globalData.Effect) == PassiveEffects.SELFLESS) then
                Actives.ChargeByOrder(player, 1);
                THI.SFXManager:Play(SoundEffect.SOUND_BEEP);
            end
        end
    end
end
EmptyBook:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, EmptyBook.PostEntityTakeDamage);

-- Active Effects.
local function DamageBoost(player, size, rng)
    
    THI.SFXManager:Play(SoundEffect.SOUND_DEVIL_CARD);
    local playerData = EmptyBook:GetPlayerData(player, true);
    local boost = 1.25;
    if (size == 1) then
        boost = 1.5;
    elseif (size == 2) then
        boost = 2;
    end
    playerData.DamageBoost = playerData.DamageBoost * boost;
    
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems();
end

local function GainHeart(player, size, rng)
    if (size == 1) then
        player:AddSoulHearts(1);
        THI.SFXManager:Play(SoundEffect.SOUND_HOLY);
    elseif (size == 2) then
        player:AddEternalHearts(1);
        THI.SFXManager:Play(SoundEffect.SOUND_SUPERHOLY);
    else
        player:AddHearts(1);
        THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
    end
end

local function SpawnPickups(player, size, rng)
    local room = THI.Game:GetRoom();
    if (size == 1) then
        -- Heart, Key, Bomb
        local value = rng:RandomInt(3);
        local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
        if (value == 0) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, pos, Vector.Zero, player);
        elseif (value == 1) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, pos, Vector.Zero, player);
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, pos, Vector.Zero, player);
        end
    elseif (size == 2) then
        -- Justice
        local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, pos, Vector.Zero, player);
        pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, pos, Vector.Zero, player);
        pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, pos, Vector.Zero, player);
        pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, player);
    else
        local value = rng:RandomInt(2);
        if (value == 1) then
            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector.Zero, player);
        end
    end
end

local function MassDamage(player, size, rng)
    THI.SFXManager:Play(SoundEffect.SOUND_DEATH_CARD);
    
    local damage = 20;
    if (size == 1) then
        damage = 60;
    elseif (size == 2) then
        damage = 180;
    end
    THI.Game:ShakeScreen(math.floor(damage ^ 0.5 * 2));
    damage = damage + (player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_PAGE) + 
        player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MISSING_PAGE_2)) * 40

    local color = Color(0.2,0.2,0.2,1,0,0,0);
    color:SetColorize(1, 1, 1, 1);
    local poof = Isaac.Spawn(1000, 16, 1, player.Position, Vector.Zero, player);
    poof:SetColor(color, -1, 0);
    poof = Isaac.Spawn(1000, 16, 2, player.Position,  Vector.Zero, player);
    poof:SetColor(color, -1, 0);

    local renderRNG = RNG();
    renderRNG:SetSeed(Random(), 0);

    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (Entities.IsValidEnemy(ent)) then
            ent:TakeDamage(damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0);
            for i = 1, damage / 10 do
                local blood = Isaac.Spawn(1000, 5, 0, ent.Position, RandomVector() * renderRNG:RandomFloat() * 3, player);
                blood:SetColor(color, -1, 0);
            end
            local poof = Isaac.Spawn(1000, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, player);
            poof:SetColor(color, -1, 0);
            local bloodExp = Isaac.Spawn(1000, EffectVariant.BLOOD_EXPLOSION, 0, ent.Position, Vector.Zero, player);
            bloodExp:SetColor(color, -1, 0);
        end
    end
end

local function Shield(player, size, rng)
    
    local time = 90;
    if (size == 1) then
        time = 300;
    elseif (size == 2) then
        time = 900;
    end

    Shields:AddShield(player, time);
end

local function SpawnFamiliar(player, size, rng)
    
    THI.SFXManager:Play(SoundEffect.SOUND_SATAN_GROW);
    local count = 1;
    if (size == 1) then
        count = 3;
    elseif (size == 2) then
        count = 6;
    end

    local playerData = EmptyBook:GetPlayerData(player, true);
    for i = 1, count do
        local index = rng:RandomInt(#FamiliarPool) + 1;
        local effects = player:GetEffects();
        effects:AddCollectibleEffect (FamiliarPool[index].Collectible);
    end
end

local function TriggerDies(player, size, rng)
    local count = 1;
    if (size == 1) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, true, true);
    elseif (size == 2) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false, true, true);
    else
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D10, false, true, true);
    end
end
-- Use Finished Book.
function EmptyBook:UseItem(item, rng, player, flags, slot, varData)
    -- Small
    if (item == FinishedBooks[1] or item == FinishedBooks[2] or item == FinishedBooks[3]) then
        local globalData = EmptyBook:GetGlobalBookData(false);
        local effect = globalData.Effect;
        local size = 0;
        if (item == FinishedBooks[2]) then
            size = 1;
        elseif (item == FinishedBooks[3]) then
            size = 2;
        end
        local active = GetBookActive(effect);
        local passive = GetBookPassive(effect);
        if (active == ActiveEffects.INCANTATION) then
            -- Damage Boost.
            DamageBoost(player, size, rng);
        elseif (active == ActiveEffects.PRAYING)then
            -- Gain Heart.
            GainHeart(player, size, rng);
        elseif (active == ActiveEffects.COLLECTION)then
            -- Pickups
            SpawnPickups(player, size, rng);
        elseif(active == ActiveEffects.FORBIDDEN)then
            MassDamage(player, size, rng);
        elseif(active == ActiveEffects.PROTECTION)then
            Shield(player, size, rng);
        elseif(active == ActiveEffects.FAMILIARS) then
            SpawnFamiliar(player, size, rng);
        elseif(active == ActiveEffects.EXPLORATION) then
            TriggerDies(player, size, rng)
        end

        if (passive == PassiveEffects.INNOVATIVE and not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
            player:AddWisp(item, player.Position);
        end
        return {ShowAnim = true}
    end
end
EmptyBook:AddCallback(ModCallbacks.MC_USE_ITEM, EmptyBook.UseItem);

function EmptyBook:PostChangeCollecitble(player, item, diff)
    if (item == FinishedBooks[1] or item == FinishedBooks[2] or item == FinishedBooks[3]) then
        
        local globalData = EmptyBook:GetGlobalBookData(false);
        if (globalData) then
            local passive = GetBookPassive(globalData.Effect);
            local game = THI.Game;
            if (passive == PassiveEffects.GOODWILLED) then
                -- Goodwilled
                THI.Game:GetLevel():AddAngelRoomChance(diff * 0.1);
            elseif (passive == PassiveEffects.WISE) then
                -- Wise
                if (HasFinishedBook(player)) then
                    THI:EvaluateCurses();
                end
            elseif (passive == PassiveEffects.PRECISE) then
                -- Precise
                if (HasFinishedBook(player)) then
                    THI.Game:GetLevel():ApplyCompassEffect(false);
                end
            elseif (passive == PassiveEffects.MEAN) then
                -- Mean
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();
            elseif (passive == PassiveEffects.CLEAR) then
                -- Clear
                player:AddCacheFlags(CacheFlag.CACHE_SPEED);
                player:EvaluateItems();
            end
        end
    end
end
EmptyBook:AddCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, EmptyBook.PostChangeCollecitble);

function EmptyBook:PostPickupCollectible(player, item, touched)
    for i ,id in pairs(FinishedBooks) do
        if (item == id) then
        
            -- local size = 0;
            -- if (item == FinishedBooks[2]) then
            --     size = 1;
            -- elseif (item == FinishedBooks[3]) then
            --     size = 2;
            -- end

            local globalData = EmptyBook:GetGlobalBookData(false);
            if (globalData) then
                EmptyBook.ShowBookItemText(globalData.Effect, i - 1);
            end
        end
    end
end
EmptyBook:AddCallback(CuerLib.CLCallbacks.CLC_POST_PICK_UP_COLLECTIBLE, EmptyBook.PostPickupCollectible);

local renderOffset = Vector(0, -60);
local leftOffset = Vector(-40, 0);
local rightOffset = Vector(40, 0);

local function RenderWriting(player)
    local game = THI.Game;
    local globalData = EmptyBook:GetGlobalBookData(false);
    local playerData = EmptyBook:GetPlayerData(player, false)
    local playerPos = Screen.GetEntityRenderPosition(player);
    local centerPos = playerPos + renderOffset;
    local leftPos = centerPos + leftOffset;
    local rightPos = centerPos + rightOffset;

    -- Render Choices.
    local stage = 0;
    local size = 0;

    if (globalData) then
        if (globalData.ChooseTime == 1) then
            stage = 1;
        elseif (globalData.ChooseTime == 2) then
            stage = 2;
        end

        size = GetBookSize(globalData.MakingEffect);
    end

    if (stage == 0) then
        ChoiceSprite:SetFrame("Charges", 0)
        ChoiceSprite:Render(leftPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame("Charges", 1)
        ChoiceSprite:Render(centerPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame("Charges", 2)
        ChoiceSprite:Render(rightPos, Vector.Zero, Vector.Zero);
    elseif (stage == 1) then
        local animationName = "Manual";
        if (size == 1) then
            animationName = "Guide";
        elseif (size == 2) then
            animationName = "History";
        end
        ChoiceSprite:SetFrame(animationName, GetChoiceId(0, 1))
        ChoiceSprite:Render(leftPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame(animationName, GetChoiceId(1, 1))
        ChoiceSprite:Render(centerPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame(animationName, GetChoiceId(2, 1))
        ChoiceSprite:Render(rightPos, Vector.Zero, Vector.Zero);
    elseif (stage == 2) then
        local animationName = "Passive";
        ChoiceSprite:SetFrame(animationName, GetChoiceId(0, 2))
        ChoiceSprite:Render(leftPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame(animationName, GetChoiceId(1, 2))
        ChoiceSprite:Render(centerPos, Vector.Zero, Vector.Zero);
        
        ChoiceSprite:SetFrame(animationName, GetChoiceId(2, 2))
        ChoiceSprite:Render(rightPos, Vector.Zero, Vector.Zero);
    end

    local framePos = leftPos;
    if (playerData) then
        if (playerData.Choice == 1) then
            framePos = centerPos;
        elseif (playerData.Choice == 2) then
            framePos = rightPos;
        end
    end
    FrameSprite:Render(framePos, Vector.Zero, Vector.Zero);
end

function EmptyBook:PostRender()
    local game = THI.Game;
    for i, player in Players.PlayerPairs() do
        if (IsWriting(player)) then
            RenderWriting(player);
        end
    end
end
EmptyBook:AddCallback(ModCallbacks.MC_POST_RENDER, EmptyBook.PostRender);


return EmptyBook;