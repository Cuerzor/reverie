local Lib = CuerLib;

local languages = {
    {Language = "en_us", Code = "en"},
    {Language = "zh_cn", Code = "zh"},
}
-- Transformations.
local Transformations = {
    ReverieMusician = {
        Icon = "gfx/eid/icons.anm2"
    }
}
for id, trans in pairs(Transformations) do
    local musicianSprite = Sprite();
    musicianSprite:Load(trans.Icon, true)
    EID:addIcon(id, "Transformation", -1, 16, 16, nil, nil, musicianSprite)
end

-- Transformation Assignations.
local Collectibles = THI.Collectibles;
local CollectibleTransformations = {
    [Collectibles.Grimoire.Item] = EID.TRANSFORMATION.BOOKWORM,
    [Collectibles.BookOfYears.Item] = EID.TRANSFORMATION.BOOKWORM,
    [Collectibles.EmptyBook.Item] = EID.TRANSFORMATION.BOOKWORM,

    [Collectibles.Koakuma.Item] = EID.TRANSFORMATION.CONJOINED,
    [Collectibles.ChenBaby.Item] = EID.TRANSFORMATION.CONJOINED,

    [Collectibles.MomsIOU.Item] = EID.TRANSFORMATION.MOM,

    [CollectibleType.COLLECTIBLE_METRONOME] = "ReverieMusician",
    [CollectibleType.COLLECTIBLE_PLUM_FLUTE] = "ReverieMusician",
    [Collectibles.MelancholicViolin.Item] = "ReverieMusician",
    [Collectibles.ManiacTrumpet.Item] = "ReverieMusician",
    [Collectibles.IllusionaryKeyboard.Item] = "ReverieMusician",
    [Collectibles.DeletedErhu.Item] = "ReverieMusician",
    [Collectibles.SongOfNightbird.Item] = "ReverieMusician",
    [Collectibles.MountainEar.Item] = "ReverieMusician",

    [Collectibles.JarOfFireflies.Item] = EID.TRANSFORMATION.LORD_OF_THE_FLIES,

    [Collectibles.GourdShroom.Item] = EID.TRANSFORMATION.MUSHROOM
}


for id, trans in pairs(CollectibleTransformations) do
    EID:assignTransformation("collectible", id, trans);
end

local function AddKosuzuBookActive(size, active, name, description, language)
	language = language or "en_us"
	EID.descriptions[language].reverieKosuzuActive[size.."."..active] = {name, description};
end
local function AddKosuzuBookPassive(passive, description, language)
	language = language or "en_us"
	EID.descriptions[language].reverieKosuzuPassive[passive + 1] = description;
end

local function LoadEID(language)
    local lang = language.Language or "en_us";
    local descriptions = EID.descriptions[lang];
    local languageCode = language.Code;
    local EIDInfo = include("descriptions/rep/"..lang);

    do --Collectibles
        for id, col in pairs(EIDInfo.Collectibles) do
            EID:addCollectible(id, col.Description, col.Name, lang);
            if (col.BookOfVirtues and descriptions.bookOfVirtuesWisps) then
                descriptions.bookOfVirtuesWisps[id] = col.BookOfVirtues;
            end
            
            if (col.BookOfBelial and descriptions.bookOfBelialBuffs) then
                descriptions.bookOfBelialBuffs[id] = col.BookOfBelial;
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

    -- Transformations.
    do
        for id, trans in pairs(EIDInfo.Transformations) do
            EID:createTransformation(id, trans, lang);
        end
    end

    -- Birthrights.
    for id, br in pairs(EIDInfo.Birthrights) do
        EID:addBirthright(id, br.Description, br.PlayerName);
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
                local activeEntry = EID:getDescriptionEntry("reverieKosuzuActive", size.."."..active);
                local passiveEntry = EID:getDescriptionEntry("reverieKosuzuPassive", passive + 1);
                local name = activeEntry[1];
                local activeDesc = activeEntry[2];
                local passiveDesc = passiveEntry;
                local description = activeDesc.."#"..passiveDesc;
                
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