local Lib = CuerLib;
local UnknownItems = Lib.UnknownItems;

local ModName = THI.Name;
local languages = {
    {Language = "en_us", Code = "en"},
    {Language = "zh_cn", Code = "zh"},
}

-- Cards.
local Cards = {
    [THI.Cards.SoulOfEika.ID] = {
        Frame = 0
    },
    [THI.Cards.SoulOfSatori.ID] = {
        Frame = 1
    },
    [THI.Cards.ASmallStone.ID] = {
        Frame = 2
    },
    [THI.Cards.SpiritMirror.ID] = {
        Frame = 3
    },
    [THI.Cards.SoulOfSeija.ID] = {
        Frame = 4
    },
    [THI.Cards.SoulOfSeija.ReversedID] = {
        Frame = 5
    },
    [THI.Cards.SituationTwist.ID] = {
        Frame = 6
    },
}

for id, card in pairs(Cards) do
    local spr = Sprite();
    spr:Load("gfx/eid/reverie_cardpill_icons.anm2", true)
    EID:addIcon("Card"..id, "Card", card.Frame, 16, 16, 0, 1, spr)
end

-- Transformations.
local Transformations = {
    ReverieMusician = {
        Icon = "gfx/eid/reverie_transformation_icons.anm2"
    }
}

local RuneSwordVariables = {
    [Card.RUNE_ANSUZ] = {
        DISTANCE = function(count, global) return global + 1; end
    },
    [Card.RUNE_HAGALAZ] =  {
        CHANCE = function(count, global) return math.min(100, math.floor(count / 3 * 100)); end
    },
    [Card.RUNE_PERTHRO] = {
        CHANCE = function(count, global) return math.min(100, 30+40*0.5^count); end
    },
    [Card.RUNE_BERKANO] = {
        COUNT = function(count, global) return 3 * count; end
    },
    [Card.RUNE_ALGIZ] = {
        CHANCE = function(count, global) return math.min(100, 20 * count); end
    },
    [Card.RUNE_JERA] = {
        CHANCE = function(count, global) return 50 * global; end
    },
    [Card.CARD_SOUL_ISAAC] = {
        CHANCE = function(count, global) return math.min(100, 50 * count); end
    },
    [Card.CARD_SOUL_CAIN] = {
        CHANCE = function(count, global) return math.min(20, 5 * global); end
    },
    [Card.CARD_SOUL_JUDAS] = {
        COUNT = function(count, global) return count; end
    },
    [Card.CARD_SOUL_EVE] = {
        COUNT = function(count, global) return 2 * count; end
    },
    [Card.CARD_SOUL_SAMSON] = {
        DAMAGE = function(count, global, stage) return (100 + 65*stage) * (0.5 + 0.5 /count); end
    },
    [Card.CARD_SOUL_LOST] = {
        CHANCE = function(count, global) return math.min(100, count * 10); end
    },
    [Card.CARD_SOUL_KEEPER] = {
        CHANCE = function(count, global) return global * 40; end
    },
    [Card.CARD_SOUL_APOLLYON] = {
        COUNT = function(count, global) return count * 3; end
    },
    [Card.CARD_SOUL_FORGOTTEN] = {
        CHANCE = function(count, global) return math.min(50, count * 10); end
    },
    [Card.CARD_SOUL_BETHANY] = {
        COUNT = function(count, global) return count; end
    },
    [THI.Cards.SoulOfEika.ID] = {
        CHANCE = function(count, global) return math.min(20, global * 2); end
    },
    [THI.Cards.SoulOfSatori.ID] = {
        CHANCE = function(count, global) return math.min(100, count * 20); end
    }
}

for id, trans in pairs(Transformations) do
    local musicianSprite = Sprite();
    musicianSprite:Load(trans.Icon, true)
    EID:addIcon(id, "Transformation", -1, 16, 16, nil, nil, musicianSprite)
end

local Players = THI.Players;
local playerSprite = Sprite();
playerSprite:Load("gfx/eid/reverie_player_icons.anm2", true)
EID:addIcon("Player"..Players.Eika.Type, "Players", 0, 12, 12, -1, 1, playerSprite);
EID:addIcon("Player"..Players.EikaB.Type, "Players", 1, 12, 12, -1, 1, playerSprite);
EID:addIcon("Player"..Players.Satori.Type, "Players", 2, 12, 12, -1, 1, playerSprite);
EID:addIcon("Player"..Players.SatoriB.Type, "Players", 3, 12, 12, -1, 1, playerSprite);
EID:addIcon("Player"..Players.Seija.Type, "Players", 4, 12, 12, -1, 1, playerSprite);
EID:addIcon("Player"..Players.SeijaB.Type, "Players", 5, 12, 12, -1, 1, playerSprite);

local TagIcons = {
    [0] = "Dead",					-- Dead things (for the Parasite unlock)
    [1] = "Syringe",				-- Syringes (for Little Baggy and the Spun! transformation)
    [2] = "Mom",					-- Mom's things (for Mom's Contact and the Yes Mother? transformation)
    [3] = "Tech",				-- Technology items (for the Technology Zero unlock)
    [4] = "Battery",				-- Battery items (for the Jumper Cables unlock)
    [5] = "Guppy",				-- Guppy items (Guppy transformation)
    [6] = "Fly",					-- Fly items (Beelzebub transformation)
    [7] = "Bob",					-- Bob items (Bob transformation)
    [8] = "Mushroom",			-- Mushroom items (Fun Guy transformation)
    [9] = "Baby",				-- Baby items (Conjoined transformation)
    [10] = "Angel",				-- Angel items (Seraphim transformation)
    [11] = "Devil",				-- Devil items (Leviathan transformation)
    [12] = "Poop",				-- Poop items (Oh Shit transformation)
    [13] = "Book",				-- Book items (Book Worm transformat)
    [14] = "Spider",				-- Spider items (Spider Baby transformation)
    [15] = "Quest",				-- Quest item (cannot be rerolled or randomly obtained)
    [16] = "MonsterManual",		-- Can be spawned by Monster Manual
    [17] = "NoGreed",			-- Cannot appear in Greed Mode
    [18] = "Food",				-- Food item (for Binge Eater)
    [19] = "TearsUp",			-- Tears up item (for Lachryphagy unlock detection)
    [20] = "Offensive",			-- Whitelisted item for Lost B
    [21] = "NoKeeper",			-- Blacklisted item for Keeper/Keeper B
    [22] = "NoLostBr",			-- Blacklisted item for Lost's Birthright
    [23] = "Stars",				-- Star themed items (for the Planetarium unlock)
    [24] = "Summonable",			-- Summonable items (for Bethany B)
    [25] = "NoCantrip",			-- Can't be obtained in Cantripped challenge
    [26] = "Wisp",				-- Active items that have wisps attached to them (automatically set)
    [27] = "UniqueFamiliar",	-- Unique familiars that cannot be duplicated
    [28] = "NoChallenge",		-- Items that shouldn't be obtainable in challenges
    [29] = "NoDaily",			-- Items that shouldn't be obtainable in daily runs
    [30] = "LazShared",			-- Items that should be shared between Tainted Lazarus' forms
    [31] = "LazSharedGlobal",	-- Items that should be shared between Tainted Lazarus' forms but only through global checks (such as PlayerManager::HasCollectible)
    [32] = "NoEden",			-- Items that can't be randomly rolled
}

local tagIconSprite = Sprite();
tagIconSprite:Load("gfx/reverie/ui/tag_icons.anm2", true)
for id, name in pairs(TagIcons) do
    EID:addIcon("Reverie_Tag"..name, "Tags", id, 16, 16, 7, 6, tagIconSprite)
end

for i = 0, 12 do
    EID:addIcon("Reverie_Charge"..i, "Charges", i, 12, 12, 5, 6, tagIconSprite)
end
EID:addIcon("Reverie_ChargeTimed", "Charges", 14, 12, 12, 5, 6, tagIconSprite)
EID:addIcon("Reverie_ChargeUnknown", "Charges", 13, 12, 12, 5, 6, tagIconSprite)
EID:addIcon("Reverie_Familiar", "Familiar", 0, 12, 12, 5, 6, tagIconSprite)
EID:addIcon("Reverie_Mod", "Mod", 0, 16, 16, 7, 6, tagIconSprite)

-- Transformation Assignations.
local Collectibles = THI.Collectibles;
local CollectibleTransformations = {
    [Collectibles.GuppysCorpseCart.Item] = EID.TRANSFORMATION.GUPPY,

    [Collectibles.Grimoire.Item] = EID.TRANSFORMATION.BOOKWORM,
    [Collectibles.BookOfYears.Item] = EID.TRANSFORMATION.BOOKWORM,
    [Collectibles.EmptyBook.Item] = EID.TRANSFORMATION.BOOKWORM,

    [Collectibles.Koakuma.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.ChenBaby.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.SunnyFairy.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.LunarFairy.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.StarFairy.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.DancerServants.Item] = EID.TRANSFORMATION.CONJOINED,

    
    [Collectibles.AngelsRaiment.Item] = EID.TRANSFORMATION.ANGEL,

    [Collectibles.MomsIOU.Item] = EID.TRANSFORMATION.MOM,

    [CollectibleType.COLLECTIBLE_METRONOME] = "ReverieMusician",
    [CollectibleType.COLLECTIBLE_PLUM_FLUTE] = "ReverieMusician",
    [Collectibles.MelancholicViolin.Item] = "ReverieMusician",
    [Collectibles.ManiacTrumpet.Item] = "ReverieMusician",
    [Collectibles.IllusionaryKeyboard.Item] = "ReverieMusician",
    [Collectibles.DeletedErhu.Item] = "ReverieMusician",
    [Collectibles.SongOfNightbird.Item] = "ReverieMusician",
    [Collectibles.MountainEar.Item] = "ReverieMusician",
    [Collectibles.ThunderDrum.Item] = "ReverieMusician",
    [Collectibles.ReverieMusic.Item] = "ReverieMusician",

    [Collectibles.JarOfFireflies.Item] = EID.TRANSFORMATION.LORD_OF_THE_FLIES,

    [Collectibles.GourdShroom.Item] = EID.TRANSFORMATION.MUSHROOM
}


for id, trans in pairs(CollectibleTransformations) do
    EID:assignTransformation("collectible", id, trans);
end

local function LoadEID(language)
    local lang = language.Language or "en_us";
    local descriptions = EID.descriptions[lang];
    local languageCode = language.Code;
    local EIDInfo = include("descriptions/rep/"..lang);

    do -- Encyclopedia
        local Pedia = Encyclopedia;
        if (Pedia and lang == "en_us") then
            local ItemPools = include("descriptions/rep/itempools");
            local wiki = include("compatilities/encyclopedia/main");
            wiki:Register(EIDInfo, ItemPools);
        end
    end

    do --Collectibles
        descriptions.reverieBelialReplace = {}
        for id, col in pairs(EIDInfo.Collectibles) do
            EID:addCollectible(id, col.Description, col.Name, lang);
            if (col.BookOfVirtues and descriptions.bookOfVirtuesWisps) then
                descriptions.bookOfVirtuesWisps[id] = col.BookOfVirtues;
            end
            
            if (col.BookOfBelial and descriptions.bookOfBelialBuffs) then
                descriptions.bookOfBelialBuffs[id] = col.BookOfBelial;
            end

            if (col.BookOfBelialReplace and descriptions.reverieBelialReplace) then
                descriptions.reverieBelialReplace["5.100."..id] = col.BookOfBelialReplace;
            end

            if (col.BingeEater and descriptions.bingeEaterBuffs) then
                descriptions.bingeEaterBuffs[id] = col.BingeEater;
            end

        end
    end

    for id, trinket in pairs(EIDInfo.Trinkets) do
        EID:addTrinket(id, trinket.Description, trinket.Name, lang);
        if (trinket.GoldenInfo) then
            EID.GoldenTrinketData[id] = trinket.GoldenInfo;
        end
        if (trinket.GoldenEffect) then
            EID.descriptions[lang].goldenTrinketEffects[id] = trinket.GoldenEffect;
        end
    end

    for id, card in pairs(EIDInfo.Cards) do
        EID:addCard(id, card.Description, card.Name, lang);
    end
    for id, pill in pairs(EIDInfo.Pills) do
        EID:addPill(id, pill.Description, pill.Name, lang);
    end

    -- Transformations.
    do
        for id, trans in pairs(EIDInfo.Transformations) do
            EID:createTransformation(id, trans, lang);
        end
    end

    -- Birthrights.
    for id, br in pairs(EIDInfo.Birthrights) do
        EID:addBirthright(id, br.Description, br.PlayerName, lang);
    end

    -- Rune Sword.
    descriptions.reverieRuneSword = {};
    for id, desc in pairs(EIDInfo.RuneSword) do
        descriptions.reverieRuneSword[id] = desc;
    end

    
    do -- Entries
        descriptions.reverieEntries = {};
        for id, entry in pairs(EIDInfo.Entries) do
            descriptions.reverieEntries[id] = entry;
        end
    end

    do -- Kosuzu Books
        local EmptyBook = THI.Collectibles.EmptyBook;

        descriptions.reverieKosuzuActive = {};
        descriptions.reverieKosuzuPassive = {};
        local kosuzuDescriptions = EIDInfo.KosuzuDescriptions;
        for i, id in pairs(EmptyBook.FinishedBooks) do
            local size = i - 1
            do
                local name = EmptyBook.GetBookName(-1, size, languageCode);
                local description = kosuzuDescriptions.Default;
                descriptions.reverieKosuzuActive[size..".nil"] = {name, description};
            end
            for _, active in pairs(EmptyBook.ActiveEffects) do
                local name = EmptyBook.GetBookName(active, size, languageCode);
                local description = kosuzuDescriptions.Actives[size][active];
                descriptions.reverieKosuzuActive[size.."."..active] = {name, description};
            end
        end
        
        for _, passive in pairs(EmptyBook.PassiveEffects) do
            local description = kosuzuDescriptions.Passives[passive];
            descriptions.reverieKosuzuPassive[passive + 1] = description;
        end
    end

    do -- Lunatic Descriptions
        descriptions.reverieLunatic = {}
        for id, desc in pairs(EIDInfo.LunaticDescs.Collectibles) do
            descriptions.reverieLunatic["100."..id] = desc;
        end
        for id, desc in pairs(EIDInfo.LunaticDescs.Trinkets) do
            descriptions.reverieLunatic["350."..id] = desc;
        end
    end

    do -- Seija Descriptions
        descriptions.reverieSeijaBuffs = {}
        for id, desc in pairs(EIDInfo.SeijaBuffs.Collectibles) do
            descriptions.reverieSeijaBuffs["100."..id] = desc;
        end
        descriptions.reverieSeijaBuffs["Modded"] = EIDInfo.SeijaBuffs.Modded;
        descriptions.reverieSeijaNerfs = {}
        for id, desc in pairs(EIDInfo.SeijaNerfs.Collectibles) do
            descriptions.reverieSeijaNerfs["100."..id] = desc;
        end
        descriptions.reverieSeijaNerfs["Modded"] = EIDInfo.SeijaNerfs.Modded;
    end

    do -- Tag Descriptions
        descriptions.reverieTagDescs = {}
        for id, desc in pairs(EIDInfo.Tags) do
            descriptions.reverieTagDescs[id] = desc;
        end
    end
end


for i, language in pairs(languages) do
    LoadEID(language);
end

-- Kosuzu books.
do

    local EmptyBook = THI.Collectibles.EmptyBook;


    for i, id in pairs(EmptyBook.FinishedBooks) do
        EID:addCollectible(id, "", "");
    end
    
    local function KosuzuBooksCondition(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5 and variant == 100) then
            for size, id in pairs(EmptyBook.FinishedBooks) do
                if (subType == id) then
                    return true;
                end
            end
        end
        return false;
    end
    
    
    local function KosuzuBooksCallback(descObj)
        local subType = descObj.ObjSubType;
        local effect = EmptyBook.GetBookEffect();
        local active = EmptyBook.GetBookActive(effect);
        local passive = EmptyBook.GetBookPassive(effect);
        for i, id in pairs(EmptyBook.FinishedBooks) do
            if (subType == id) then
                local size = i - 1;
                local description;
                local name;
                if (active >= 0) then
                    local activeEntry = EID:getDescriptionEntry("reverieKosuzuActive", size.."."..active);
                    local passiveEntry = EID:getDescriptionEntry("reverieKosuzuPassive", passive + 1);
                    name = activeEntry[1]
                    local activeDesc = activeEntry[2];
                    local passiveDesc = passiveEntry;
                    description= activeDesc.."#"..passiveDesc;
                else
                    local activeEntry = EID:getDescriptionEntry("reverieKosuzuActive", size..".nil");
                    name = activeEntry[1];
                    description = activeEntry[2];
                end
                
                descObj.Name = name;
                EID:appendToDescription(descObj, description);
                return descObj;
            end
        end
        return descObj;
    end
    
    EID:addDescriptionModifier("reverieKosuzuBooks", KosuzuBooksCondition, KosuzuBooksCallback);
    
end

-- Lunatic.
do

    local function LunaticCondition(descObj)
        return THI.IsLunatic();
    end
    local function LunaticCallback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5) then
            local desc = EID:getDescriptionEntry("reverieLunatic", variant.."."..subType);
            local title = EID:getDescriptionEntry("reverieEntries", "Lunatic");
            if (desc) then
                EID:appendToDescription(descObj, "#"..title..desc);
            end
        end
        return descObj;
    end
    EID:addDescriptionModifier("reverieLunatic", LunaticCondition, LunaticCallback);
    
end

-- Belial Replacement.
do
    local function BelialCondition(descObj)
        return EID.collectiblesOwned[59];
    end
    local function BelialCallback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5) then
            local key = id.."."..variant.."."..subType;
            local replace = EID:getDescriptionEntry("reverieBelialReplace", key);
            local descEntry = EID:getDescriptionEntry("custom", key);
            local desc = descEntry and descEntry[3];
            if (desc and replace) then
                replace = string.gsub("{{Collectible59}} "..replace, "%%", "%%%%");
                descObj.Description = string.gsub(descObj.Description, desc, replace);
            end
        end
        return descObj;
    end
    EID:addDescriptionModifier("reverieBelial", BelialCondition, BelialCallback);
    
end


-- Rune Sword.
do
    local playerIndex = 0;
    local function PostRender(mod)
        playerIndex = 0;
    end
    THI:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender)
    local function Condition(descObj)
        local RuneSword = THI.Collectibles.RuneSword;
        local game = Game();
        for i = 0, game:GetNumPlayers(0) - 1 do
            local player = game:GetPlayer(i);
            if (player:HasCollectible(RuneSword.Item)) then
                return true;
            end
        end
        return false;
    end
    local function Callback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5 and variant == PickupVariant.PICKUP_TAROTCARD) then
            local desc = EID:getDescriptionEntry("reverieRuneSword", subType);
            if (desc) then
                local RuneSword = THI.Collectibles.RuneSword;

                local variables = RuneSwordVariables[subType];
                if (variables) then
                    local game = Game();
                    local level = game:GetLevel();
                    local stage = level:GetStage();
                    local globalCount = RuneSword:GetGlobalRuneCount(subType) + 1;
                    local nextCount = 0;
                    if (descObj.Entity) then
                        local nearestPlayer;
                        local nearestDis;
                        for i = 0, game:GetNumPlayers() - 1 do
                            local player = game:GetPlayer(i);
                            local dis = descObj.Entity.Position:Distance(player.Position);
                            if (player:HasCollectible(RuneSword.Item) and not nearestPlayer or dis < nearestDis) then
                                nearestPlayer = player;
                                nearestDis = dis;
                            end
                        end
                        nextCount =  RuneSword:GetInsertedRuneNum(nearestPlayer, subType) + 1;
                    else
                        while (playerIndex < game:GetNumPlayers()) do
                            local player = game:GetPlayer(playerIndex);
                            playerIndex = playerIndex + 1;
                            if (player:HasCollectible(RuneSword.Item) and player:GetCard(0) == subType) then
                                nextCount = RuneSword:GetInsertedRuneNum(player, subType) + 1;
                                break;
                            end
                        end
                    end
                    
                    for name, func in pairs(variables) do
                        local str = string.format("%.0f", func(nextCount, globalCount, stage));
                        str = "{{ColorYellow}}"..str.."{{CR}}"
                        desc = string.gsub(desc, "{"..name.."}", str)
                    end
                end

                desc = "#"..desc;
                local repl = "#{{Collectible"..RuneSword.Item.."}} "
                desc = string.gsub(desc, "#", repl)
                EID:appendToDescription(descObj, desc);
            end
        end
        return descObj;
    end
    EID:addDescriptionModifier("reverieRuneSword", Condition, Callback);
    
end


-- D Flip.
do

    local function Condition(descObj)
        local DFlip = THI.Collectibles.DFlip;
        local SoulOfSeija = THI.Cards.SoulOfSeija;
        local game = Game();
        for i = 0, game:GetNumPlayers(0) - 1 do
            local player = game:GetPlayer(i);
            if (player:HasCollectible(DFlip.Item)) then
                return true;
            end
            for slot = 0, 1 do
                local card = player:GetCard(slot);
                if (card == SoulOfSeija.ID or card == SoulOfSeija.ReversedID) then
                    return true;
                end
            end
        end
        return false;
    end
    local function Callback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        local DFlip = THI.Collectibles.DFlip;
        local another = DFlip:GetFixedAnother(id, variant, subType)
        if (another) then
            local desc = "#{{Collectible"..DFlip.Item.."}} ";
            local function GetDesc(type, variant ,subtype)
                
                if (type == 5) then
                    if (variant == PickupVariant.PICKUP_COLLECTIBLE) then
                        return "{{Collectible"..subtype.."}}"
                    elseif (variant == PickupVariant.PICKUP_TRINKET) then
                        return "{{Trinket"..subtype.."}}"
                    elseif (variant == PickupVariant.PICKUP_TAROTCARD) then
                        return "{{Card"..subtype.."}}"
                    end
                end
                return "{{QuestionMark}}"
            end

            local thisDesc = GetDesc(id, variant, subType);
            local anotherDesc = GetDesc(another[1] or 5, another[2] or 0, another[3] or 0);

            desc = desc..thisDesc.."<=>"..anotherDesc;

            EID:appendToDescription(descObj, desc);
        end
        return descObj;
    end
    EID:addDescriptionModifier("reverieDFlip", Condition, Callback);
    
end

-- Seija.
do

    local function SeijaBuffCondition(descObj)
        local Seija = THI.Players.Seija;
        local game = Game();
        for i = 0, game:GetNumPlayers(0) - 1 do
            local player = game:GetPlayer(i);
            if (Seija:WillPlayerBuff(player)) then
                return true;
            end
        end
        return false;
    end
    local function SeijaBuffCallback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5) then
            local Seija = THI.Players.Seija;
            local desc = EID:getDescriptionEntry("reverieSeijaBuffs", variant.."."..subType);
            if (not desc) then
                if (Seija:IsModQuality0(subType)) then
                    desc = EID:getDescriptionEntry("reverieSeijaBuffs", "Modded");
                end
            end
            if (desc) then
                desc = "#"..desc;
                local repl = "#{{Player"..Seija.Type.."}} "
                desc = string.gsub(desc, "#", repl)
                EID:appendToDescription(descObj, desc);
            end
        end
        return descObj;
    end
    local function SeijaNerfCondition(descObj)
        local Seija = THI.Players.Seija;
        local game = Game();
        for i = 0, game:GetNumPlayers(0) - 1 do
            local player = game:GetPlayer(i);
            if (Seija:WillPlayerNerf(player)) then
                return true;
            end
        end
        return false;
    end
    local function SeijaNerfCallback(descObj)
        local id = descObj.ObjType;
        local variant = descObj.ObjVariant;
        local subType = descObj.ObjSubType;
        if (id == 5) then
            local Seija = THI.Players.Seija;
            local desc = EID:getDescriptionEntry("reverieSeijaNerfs", variant.."."..subType);
            if (not desc) then
                if (Seija:IsModQuality4(subType)) then
                    desc = EID:getDescriptionEntry("reverieSeijaNerfs", "Modded");
                end
            end
            if (desc) then
                desc = "#"..desc;
                local repl = "#{{Player"..Seija.Type.."}} "
                desc = string.gsub(desc, "#", repl)
                EID:appendToDescription(descObj, desc);
            end
        end
        return descObj;
    end
    EID:addDescriptionModifier("reverieSeijaBuffs", SeijaBuffCondition, SeijaBuffCallback);
    EID:addDescriptionModifier("reverieSeijaNerfs", SeijaNerfCondition, SeijaNerfCallback);
    
end


-- Seija.
do
    local itemConfig = Isaac.GetItemConfig();
    local function GetItemTagDescription(config)
        local desc = "";
        if (config) then
            local tags = config.Tags;
            local i = 0;
            while (tags > 0) do
                if (tags & 1 > 0 and i ~= 26) then
                    desc = desc..EID:getDescriptionEntry("reverieTagDescs", i).."#";
                end
                i = i + 1;
                tags = tags >> 1
            end
        end
        return desc;
    end

    local function onRender()
        if (EID.isDisplaying) then
            local Chimera = THI.Collectibles.EyeOfChimera;
            if (Chimera.HasEye) then
                
                local descObj = EID.previousDescs[1];
                local ent = descObj and descObj.Entity;
                if (ent and ent.Type == EntityType.ENTITY_PICKUP and ent.Variant == PickupVariant.PICKUP_COLLECTIBLE) then
                    if (descObj.Description == "QuestionMark" and UnknownItems:IsUnknownItem(ent)) then
                        local config = itemConfig:GetCollectible(ent.SubType);

                        if (config) then
                            
                            local pos = EID:getTextPosition() + Vector(0, 0);
                            local scale = Vector(EID.Scale, EID.Scale);
                            local color = EID:getNameColor();

                            local typeStr = "";
                            if (config.Type == ItemType.ITEM_ACTIVE) then
                                if (config.ChargeType == ItemConfig.CHARGE_NORMAL) then
                                    typeStr = "{{Reverie_Charge"..config.MaxCharges.."}}"
                                elseif (config.ChargeType == ItemConfig.CHARGE_TIMED) then
                                    typeStr = "{{Reverie_ChargeTimed}}"
                                else
                                    typeStr = "{{Reverie_ChargeUnknown}}"
                                end
                            elseif (config.Type == ItemType.ITEM_FAMILIAR) then
                                typeStr = "{{Reverie_Familiar}}"
                            end

                            local unknownStr = EID:getDescriptionEntry("reverieEntries", "UnknownItem")
                            local modStr = "";
                            if (ent.SubType >= CollectibleType.NUM_COLLECTIBLES) then
                                modStr = "{{Reverie_Mod}}";
                            end

                            EID:renderString(typeStr..unknownStr.." {{Quality"..config.Quality.."}}"..modStr, pos + Vector(12,0), scale, color)


                            local color = EID:getTextColor();
                            pos = pos + Vector(0, 16);

                            local desc = GetItemTagDescription(config);

                            local lineHeight = EID.lineHeight;
                            EID.lineHeight = EID.Config["LineHeight"];
                            EID:printBulletPoints(desc, pos);
                            EID.lineHeight = lineHeight;
                        end
                    end
                end
            end
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_RENDER, onRender);
end