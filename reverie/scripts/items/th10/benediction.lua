local Actives = CuerLib.Actives;
local Entities = CuerLib.Entities;
local Consts = CuerLib.Consts;
local Players = CuerLib.Players;
local Benediction = ModItem("Benediction", "BENEDICTION");

local itemConfig = Isaac.GetItemConfig();
local MaxCharges = itemConfig:GetCollectible(Benediction.Item).MaxCharges;
Benediction.DefaultItem = {
    Item = CollectibleType.COLLECTIBLE_DUALITY
}
Benediction.ItemList = {
    [1] = {
        Item = CollectibleType.COLLECTIBLE_HALLOWED_GROUND,
    },
    [2] = {
        Item = CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
    },
    [3] = {
        Item = CollectibleType.COLLECTIBLE_ANGELIC_PRISM,
    },
    [4] = {
        Item = CollectibleType.COLLECTIBLE_HOLY_WATER,
    },
    [5] = {
        Item = CollectibleType.COLLECTIBLE_TRISAGION,
    },
    [6] = {
        Item = CollectibleType.COLLECTIBLE_HOLY_LIGHT,
    },
    [7] = {
        Item = CollectibleType.COLLECTIBLE_HOLY_MANTLE,
    },
    [8] = {
        Item = CollectibleType.COLLECTIBLE_SALVATION,
    },
    [9] = {
        Item = CollectibleType.COLLECTIBLE_GODHEAD,
    },
    [10] = {
        Item = CollectibleType.COLLECTIBLE_REVELATION,
    },
    [11] = {
        Item = CollectibleType.COLLECTIBLE_SACRED_HEART,
    },
    [12] = {
        Item = CollectibleType.COLLECTIBLE_SACRED_ORB
    }
}
Benediction.DevilItemList = {
    [1] = {
        Item = CollectibleType.COLLECTIBLE_SHADE,
    },
    [2] = {
        Item = CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL,
    },
    [3] = {
        Item = CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER,
    },
    [4] = {
        Item = CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW,
    },
    [5] = {
        Item = CollectibleType.COLLECTIBLE_SUCCUBUS,
    },
    [6] = {
        Item = CollectibleType.COLLECTIBLE_DARK_BUM,
    },
    [7] = {
        Item = CollectibleType.COLLECTIBLE_DEATHS_TOUCH,
    },
    [8] = {
        Item = CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID,
    },
    [9] = {
        Item = CollectibleType.COLLECTIBLE_INCUBUS,
    },
    [10] = {
        Item = CollectibleType.COLLECTIBLE_TWISTED_PAIR,
    },
    [11] = {
        Item = CollectibleType.COLLECTIBLE_BRIMSTONE,
    },
    [12] = {
        Item = CollectibleType.COLLECTIBLE_MOMS_KNIFE
    }
}

local function GetItemSprite(ID)
    local spr = Sprite();
    spr:Load("gfx/reverie/ui/benediction_displayer.anm2", false);
    local gfx = itemConfig:GetCollectible(ID).GfxFileName;
    spr:ReplaceSpritesheet(0, gfx);
    spr:ReplaceSpritesheet(1, gfx);
    spr:LoadGraphics();
    spr:Play("UI");
    return spr;
end

Benediction.DefaultItem.Sprite = GetItemSprite(Benediction.DefaultItem.Item)
for i, item in pairs(Benediction.ItemList) do
    item.Sprite = GetItemSprite(item.Item);
end
for i, item in pairs(Benediction.DevilItemList) do
    item.Sprite = GetItemSprite(item.Item);
end

local function GetPlayerData(player, create)
    local function getter()
        return {
            GotItems = {},
            --Charges = nil,
            --Pressed = false,
            --UsingSlot = -1,
       }
    end
    return Benediction:GetData(player, create, getter);
end
local function GetGainedEntry(player, charges)
    local itemList = Benediction.ItemList;
    local judasBook = Players.HasJudasBook(player);
    if (judasBook) then
        itemList = Benediction.DevilItemList;
    end

    local entry = itemList[charges];
    local id = entry.Item
    local config = itemConfig:GetCollectible(id);
    if (not config:IsAvailable()) then
        entry = Benediction.DefaultItem;
    end
    return entry;
end

function Benediction:GainItem(player, item)
    
    player:QueueItem (itemConfig:GetCollectible(item), 0, true);

    local data = GetPlayerData(player, true);
    table.insert(data.GotItems, item);
end

function Benediction:ClearGainedItems(player)
    local data = GetPlayerData(player, false);
    if (data) then
        for i, item in pairs(data.GotItems) do
            player:RemoveCollectible (item, true, ActiveSlot.SLOT_PRIMARY, false);
            data.GotItems[i] = nil;
        end
    end
end

do
    local function TryUseBenediction(mod, item, player, slot)
        return Actives:GetTotalCharges(player, slot) > 0
    end
    Benediction:AddCallback(CuerLib.Callbacks.CLC_TRY_USE_ITEM, TryUseBenediction, Benediction.Item);

    local function PostUseBenediction(mod, item, rng, player, flags, slot, varData)
        local data = GetPlayerData(player, true);


        
        if (flags & UseFlag.USE_CARBATTERY > 0) then
            local item = GetGainedEntry(player, 1).Item;
            Benediction:GainItem(player, item);
        else
            local maxCharges = MaxCharges;

            local extraCharges = player:GetBatteryCharge (slot) + player:GetEffectiveSoulCharge() + player:GetEffectiveBloodCharge();
            local charges = Actives:GetUseTryCharges(player, slot);

            if (not charges or charges < 0) then
                charges = Actives:GetTotalCharges(player, slot);
            end
            local totalCharges = math.max(1, math.min(maxCharges, charges + extraCharges));
            local item = GetGainedEntry(player, totalCharges).Item;

            Benediction:GainItem(player, item);
            local sfx = SFXManager();
            sfx:Play(SoundEffect.SOUND_POWERUP1);
            if (judasBook) then
                sfx:Play(SoundEffect.SOUND_SATAN_GROW);
            else
                sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK);
            end
            Game():GetHUD():ShowItemText(player, itemConfig:GetCollectible(item));
            player:AnimateCollectible(item);


            if (flags & UseFlag.USE_OWNED > 0) then
                if (Actives:CanSpawnWisp(player, flags)) then
                    local wisp = player:AddWisp(Benediction.Item, player.Position);
                    if (wisp) then
                        wisp.HitPoints = totalCharges * 2;
                    end
                end
                Actives:CostUseTryCharges(player, item, slot, totalCharges);
            else
                Actives:EndUseTry(player, slot)
            end

            return {ShowAnim = false, Discharge = false}
        end
    end
    Benediction:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseBenediction, Benediction.Item);


    local function PostNewLevel(mod)
        for p, player in Players.PlayerPairs() do
            Benediction:ClearGainedItems(player);
        end
    end
    Benediction:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

    local WhiteColor = Color(1,1,1,1,1,1,1);
    local function RenderOverlay(mod)
        local function func(player, playerIndex, slot, pos, scale)
            local charges = Actives:GetTotalCharges(player, slot);
            charges = math.min(charges, MaxCharges);
            if (charges > 0) then
                local sprite = GetGainedEntry(player, charges).Sprite;
                sprite.Scale = scale;
                for i = 3, -1, -1 do
                    local offset = Consts.DirectionVectors[i] * 0.5 * scale;
                    if (i > -1) then
                        sprite.Color = WhiteColor;
                    else
                        sprite.Color = Color.Default;
                    end
                    sprite:Render(pos + Vector(-9, -12) + offset, Vector.Zero, Vector.Zero);
                end
            end
        end
        Actives:RenderOnActive(Benediction.Item, func)
    end
    Benediction:AddCallback(CuerLib.Callbacks.CLC_RENDER_OVERLAY, RenderOverlay);
end

return Benediction;