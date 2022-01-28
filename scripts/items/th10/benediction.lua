local Actives = CuerLib.Actives;
local Detection = CuerLib.Detection;
local Consts = CuerLib.Consts;
local Benediction = ModItem("Benediction", "BENEDICTION");

local config = Isaac.GetItemConfig();
local MaxCharges = config:GetCollectible(Benediction.Item).MaxCharges;
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
for i, item in pairs(Benediction.ItemList ) do
    local spr = Sprite();
    spr:Load("gfx/reverie/ui/benediction_displayer.anm2", false);
    local gfx = config:GetCollectible(item.Item).GfxFileName;
    spr:ReplaceSpritesheet(0, gfx);
    spr:ReplaceSpritesheet(1, gfx);
    spr:LoadGraphics();
    spr:Play("UI");
    item.Sprite = spr;
end

local function GetPlayerData(player, create)
    local function getter()
        return {
            GotItems = {},
            Charges = nil,
            Pressed = false,
            Charged = false,
            UsingSlot = -1,
       }
    end
    return Benediction:GetData(player, create, getter);
end

function Benediction:GainItem(player, item)
    
    player:QueueItem (config:GetCollectible(item), 0, true);

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
    local function InputAction(mod, entity, hook, action)
        local player = entity and entity:ToPlayer();
        if (player and player:AreControlsEnabled ()) then
            if (hook == InputHook.IS_ACTION_TRIGGERED and not Game():IsPaused()) then
                local pressed, slot = Actives.IsActiveItemPressed(player, Benediction.Item);
                if (pressed) then 
                    
                    local data = GetPlayerData(player, true);
                    if (not data.Pressed) then
                        data.Pressed = true;
                        local charges = player:GetActiveCharge (slot);
                        local soulCharges = player:GetEffectiveSoulCharge();
                        local bloodCharges = player:GetEffectiveBloodCharge();
                        local totalCharges = charges + soulCharges + bloodCharges;
                        if (totalCharges > 0 and totalCharges < MaxCharges) then
                            player:SetActiveCharge(math.max(0, MaxCharges - bloodCharges - soulCharges), slot);
                            data.Charges = totalCharges;
                            data.UsingSlot = slot;
                        end
                    end
                else
                    local data = GetPlayerData(player, false);
                    if (data) then
                        data.Pressed = false;
                    end
                end
            end
        end

    end
    Benediction:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction);

    local function PostUseBenediction(mod, item, rng, player, flags, slot, varData)
        local data = GetPlayerData(player, true);
        if (flags & UseFlag.USE_CARBATTERY > 0) then
            local item = Benediction.ItemList[1].Item;
            Benediction:GainItem(player, item);
        else

            local void = flags & UseFlag.USE_VOID > 0;
            
            local maxCharges = MaxCharges;
            if (void) then
                maxCharges = 6;
            end

            local totalCharges = data.Charges;

            if (totalCharges == nil) then
                totalCharges = math.max(1, math.min(Actives.GetTotalCharges(player, slot), maxCharges));
            end

            if (totalCharges > 0) then
                
                local item = Benediction.ItemList[totalCharges].Item;
                Benediction:GainItem(player, item);
                THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                THI.SFXManager:Play(SoundEffect.SOUND_CHOIR_UNLOCK);
                Game():GetHUD():ShowItemText(player, config:GetCollectible(item));
                player:AnimateCollectible(item);

                if (Actives.CanSpawnWisp(player, flags)) then
                    local wisp = player:AddWisp(Benediction.Item, player.Position);
                    if (wisp) then
                        wisp.HitPoints = totalCharges * 2;
                    end
                end

                if (flags & UseFlag.USE_OWNED > 0) then
                    data.Charges = player:GetBatteryCharge(slot);
                else
                    data.Charges = nil;
                end

                return {ShowAnim = false, Discharge = false}
            else
                return {Discharge = false;}
            end
        end
    end
    Benediction:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseBenediction, Benediction.Item);

    local function PostPlayerUpdate(mod, player)
        local data = GetPlayerData(player, false);
        if (data and data.Charges) then
            
            player:SetActiveCharge(data.Charges, data.UsingSlot);
            data.Charges = nil;
            data.UsingSlot = -1;
        end
    end
    Benediction:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

    local function PostNewLevel(mod)
        for p, player in Detection.PlayerPairs() do
            Benediction:ClearGainedItems(player);
        end
    end
    Benediction:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

    local WhiteColor = Color(1,1,1,1,1,1,1);
    local function GetShaderParams(mod, shaderName)
        local function func(player, playerIndex, slot, pos, scale)
            local charges = Actives.GetTotalCharges(player, slot);
            charges = math.min(charges, MaxCharges);
            if (charges > 0) then
                local sprite = Benediction.ItemList[charges].Sprite;
                sprite.Scale = scale;
                for i = 4, 0, -1 do
                    local offset = Consts.DirectionVectors[i] * 0.5 * scale;
                    if (i > 0) then
                        sprite.Color = WhiteColor;
                    else
                        sprite.Color = Color.Default;
                    end
                    sprite:Render(pos + Vector(-9, -12) + offset, Vector.Zero, Vector.Zero);
                end
            end
        end
        Actives.RenderOnActive(Benediction.Item, func)
    end
    Benediction:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);
end

return Benediction;