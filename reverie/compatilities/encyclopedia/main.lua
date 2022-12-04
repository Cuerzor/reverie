local Pedia = Encyclopedia;
local Wiki = {};
local ModName = THI.Name;


local ClassName = string.lower( ModName );

function Wiki:Register(eidInfo, itemPools)
    Wiki.Characters = include("compatilities/encyclopedia/characters");
    Wiki.HiddenItems = include("compatilities/encyclopedia/hidden");

    for id, col in pairs(eidInfo.Collectibles) do
        Pedia.AddItem{
            Class = ClassName,
            ID = id,
            WikiDesc = Pedia.EIDtoWiki(col.Description),
            Pools = itemPools[id],
        }
    end
    for id, col in pairs(eidInfo.Trinkets) do
        Pedia.AddTrinket{
            Class = ClassName,
            ID = id,
            WikiDesc = Encyclopedia.EIDtoWiki(col.Description),
        }
    end
    for id, card in pairs(eidInfo.Cards) do
        local info = {
            Class = ClassName,
            ID = id,
            WikiDesc = Encyclopedia.EIDtoWiki(card.Description),
        };
        if (card.Type== "SOUL") then
            Pedia.AddSoul(info);
        elseif (card.Type == "RUNE") then
            Pedia.AddRune(info);
        else
            Pedia.AddCard(info);
        end
    end
    for id, pill in pairs(eidInfo.Pills) do
        local info = {
            Class = ClassName,
            ID = id,
            WikiDesc = Encyclopedia.EIDtoWiki(pill.Description),
        };
        Pedia.AddPill(info);
    end

    for id, char in pairs(eidInfo.Characters) do
        local info = {
            ModName = ModName,
            Class = ClassName,
            Name = char.Name,
            Description = char.Nickname,
            ID = id,
            Sprite = Pedia.RegisterSprite(char.Sprite, char.Animation, char.Frame or 0),
            WikiDesc = char.Wiki or {},
        }
        if (char.Tainted) then
            Pedia.AddCharacterTainted(info);
        else
            Pedia.AddCharacter(info);
        end
    end

    
    for i, id in pairs(Wiki.HiddenItems) do
        Pedia.AddItem{
            Class = ClassName,
            ID = id,
            WikiDesc = {},
            Pools = {},
        }
        Encyclopedia.HideItem(id, string.lower(ClassName))
    end

end

return Wiki;