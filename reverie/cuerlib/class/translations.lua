-- Translations
local Lib = LIB;
local Translations = Lib:NewClass();
Translations.ShowTranslationText = true;
Translations.IncludedLanguages = {
    "en", "jp", "kr", "zh", "ru", "de", "es", "fr"
}
Translations.Translations = {};
local language = Options.Language;

local BirthrightNames = {
    en = "Birthright",
    jp = "バースライト",
    kr = "생득권",
    zh = "长子名分",
    ru = "Право Первородства",
    de = "Geburtsrecht",
    es = "Primogenitura",
}
local function InitPath(tbl, ...)
    local current = tbl;
    for _, key in pairs({...}) do
        current[key] = current[key] or {};
        current = current[key];
    end
    return current;
end
local function TryFind(tbl, ...)
    local current = tbl;
    for _, key in pairs({...}) do
        if (current[key]) then
            current = current[key];
        else
            return nil;
        end
    end
    return current;
end

function Translations:SetCollectible(language, id, info)
    local tbl = InitPath(self.Translations, language, "Collectibles");
    tbl[id] = info;
end
function Translations:SetTrinket(language, id, info)
    local tbl = InitPath(self.Translations, language, "Trinkets");
    tbl[id] = info;
end
function Translations:SetCard(language, id, info)
    local tbl = InitPath(self.Translations, language, "Cards");
    tbl[id] = info;
end
function Translations:SetPillEffect(language, id, info)
    local tbl = InitPath(self.Translations, language, "Pills");
    tbl[id] = info;
end
function Translations:SetPlayer(language, id, info)
    local tbl = InitPath(self.Translations, language, "Players");
    tbl[id] = info;
end
function Translations:SetText(mod, language, key, text)
    local tbl = InitPath(self.Translations, language, "Texts", mod.Name);
    tbl[key] = text;
end

function Translations:GetCollectible(language, id)
    return TryFind(self.Translations, language, "Collectibles", id);
end
function Translations:GetTrinket(language, id)
    return TryFind(self.Translations, language, "Trinkets", id);
end
function Translations:GetCard(language, id)
    return TryFind(self.Translations, language, "Cards", id);
end
function Translations:GetPillEffect(language, id)
    return TryFind(self.Translations, language, "Pills", id);
end
function Translations:GetPlayer(language, id)
    return TryFind(self.Translations, language, "Players", id);
end
function Translations:GetText(mod, language, key)
    return TryFind(self.Translations, language, "Texts", mod.Name, key);
end


local function PostPickupItem(mod, player, item, touched)
    if (not Translations.ShowTranslationText) then
        return;
    end
    local language = Options.Language;
    if (item == CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        local playerType = player:GetPlayerType();
        local playerInfo = Translations:GetPlayer(language, playerType);
        if (playerInfo) then
            Game():GetHUD():ShowItemText(BirthrightNames[language] or BirthrightNames.en, playerInfo.Birthright or "");
        end
    else
        local info = Translations:GetCollectible(language, item);
        if (info) then
            Game():GetHUD():ShowItemText(info.Name or "", info.Description or "");
        end
    end
end
Translations:AddCallback(Lib.Callbacks.CLC_POST_PICK_UP_COLLECTIBLE, PostPickupItem);


local function PostPickupTrinket(mod, player, item, golden, touched)
    if (not Translations.ShowTranslationText) then
        return;
    end
    if (item & 0x8000 > 0) then
        item = item & 0x7FFF;
    end
    local language = Options.Language;
    local info = Translations:GetTrinket(language, item);
    if (info) then
        Game():GetHUD():ShowItemText(info.Name or "", info.Description or "");
    end
end
Translations:AddCallback(Lib.Callbacks.CLC_POST_PICK_UP_TRINKET, PostPickupTrinket);


local function PostPickUpCard(mod, player, card)
    if (not Translations.ShowTranslationText) then
        return;
    end

    local language = Options.Language;
    local info = Translations:GetCard(language, card);
    if (info) then
        Game():GetHUD():ShowItemText(info.Name or "", info.Description or "");
    end
end
Translations:AddCallback(Lib.Callbacks.CLC_POST_PICK_UP_CARD, PostPickUpCard);


local function PostUsePill(mod, pilleffect, player, flags)
    if (not Translations.ShowTranslationText) then
        return;
    end

    if (flags & UseFlag.USE_NOHUD < 0) then
        return;
    end

    local language = Options.Language;
    local info = Translations:GetPillEffect(language, pilleffect);
    if (info) then
        Game():GetHUD():ShowItemText(info.Name or "", info.Description or "");
    end
end
Translations:AddCallback(ModCallbacks.MC_USE_PILL, PostUsePill);

return Translations;