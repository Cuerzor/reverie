local Lib = _TEMP_CUERLIB;
local Screen = Lib.Screen;
local Inputs = Lib.Inputs;
local Callbacks = Lib.Callbacks;

local Actives = _TEMP_CUERLIB:NewClass();
Actives.FontSprite = Sprite();

local itemConfig = Isaac.GetItemConfig();

local function GetPlayerData(player, create)
    local entData = Actives.Lib:GetLibData(player, true);
    if (create) then
        entData._ACTIVES = entData._ACTIVES or {
            UsedCharges = {}
        };
    end
    return entData._ACTIVES;
end

function Actives.GetActiveList()
    local results = {};
    local size = itemConfig:GetCollectibles().Size
    for i = 1, size do
        local collectible = itemConfig:GetCollectible(i);
        if (collectible and collectible.Type == ItemType.ITEM_ACTIVE and not collectible.Hidden) then
            table.insert(results, collectible.ID);
        end
    end
    return results;
end

function Actives:GetTotalCharges(player, slot)
    if (slot < 0) then
        return 0;
    end
    local charges = player:GetActiveCharge (slot);
    local batteryCharges = player:GetBatteryCharge (slot);
    local soulCharges = player:GetEffectiveSoulCharge();
    local bloodCharges = player:GetEffectiveBloodCharge();
    return charges + batteryCharges + soulCharges + bloodCharges;
end


Actives.FontSprite:Load("gfx/reverie/ui/active_count.anm2", true);

-- function Actives.GetPlayerData(player)
--     local data = Lib:GetLibData(player);
--     data._ACTIVE_DATA = data._ACTIVE_DATA or {
--         Pressing = {},
--         Pressed = {}
--     }
--     return data._ACTIVE_DATA;
-- end

local function IsActiveInput(player, slot, check)
    local playerType = player:GetPlayerType();

    if (playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU) then
        -- Jacob and Esau.
        local action = ButtonAction.ACTION_ITEM;
        if (playerType == PlayerType.PLAYER_ESAU) then
            action = ButtonAction.ACTION_PILLCARD;
        end

        local ctrlHold = Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex);
        
        if (slot == ActiveSlot.SLOT_POCKET or slot == ActiveSlot.SLOT_POCKET2) then
            return check(ButtonAction.ACTION_PILLCARD, player.ControllerIndex);
        elseif (slot == ActiveSlot.SLOT_PRIMARY) then
            return not ctrlHold and check(action, player.ControllerIndex);
        end
    else
        -- Normal.
        if (slot == ActiveSlot.SLOT_PRIMARY) then
            return check(ButtonAction.ACTION_ITEM, player.ControllerIndex);
        elseif (slot == ActiveSlot.SLOT_POCKET or slot == ActiveSlot.SLOT_POCKET2) then
            return check(ButtonAction.ACTION_PILLCARD, player.ControllerIndex);
        end
    end
    return false;
end

function Actives.IsActiveButtonTriggered(player, slot)
    return IsActiveInput(player, slot, Input.IsActionTriggered);
end

function Actives.IsActiveItemTriggered(player, item)
    for i=0,3 do
        if (player:GetActiveItem(i) == item) then
            if (Actives.IsActiveButtonTriggered(player, i)) then
                return true, i;
            end 
        end
    end
    return false, -1;
end


function Actives.IsActivePressed(player, slot)
    return IsActiveInput(player, slot, Input.IsActionPressed);
end
function Actives.IsActiveItemPressed(player, item)
    for i=0,3 do
        if (player:GetActiveItem(i) == item) then
            if (Actives.IsActivePressed(player, i)) then
                return true, i;
            end
        end
    end
    return false, -1;
    
end


function Actives.ChargeByOrder(player, amount)
    local hud = THI.Game:GetHUD();
    for i=1,amount do
        for slot = 0,2 do
            if (player:NeedsCharge(slot)) then
                local item = player:GetActiveItem(slot);
                local chargeType = itemConfig:GetCollectible(item).ChargeType;
                
                if (chargeType == 0) then
                    player:SetActiveCharge(player:GetActiveCharge(slot) + player:GetBatteryCharge(slot) + 1, slot);
                elseif (chargeType == 1) then
                    player:FullCharge(slot);
                end
                hud:FlashChargeBar(player, slot);
            end
        end
    end
end

----------------
-- Render Counts
----------------

local countNums = {};
function Actives:DrawMultiplier(pos, color)
    color = color or Color.Default;
    self.FontSprite.Color = color;
    self.FontSprite:SetFrame("Characters", 12);
    self.FontSprite:Render(pos, Vector.Zero, Vector.Zero);
end
function Actives:DrawMinus(pos, color)
    color = color or Color.Default;
    self.FontSprite.Color = color;
    self.FontSprite:SetFrame("Characters", 11);
    self.FontSprite:Render(pos, Vector.Zero, Vector.Zero);
end
function Actives:DrawSingleNumber(num, pos, color)
    color = color or Color.Default;
    self.FontSprite.Color = color;
    self.FontSprite:SetFrame("Characters", num);
    self.FontSprite:Render(pos, Vector.Zero, Vector.Zero);
end

local CharWidths = {
    [0] = 4,
    [1] = 3,
    [2] = 4,
    [3] = 4,
    [4] = 4,
    [5] = 4,
    [6] = 4,
    [7] = 4,
    [8] = 4,
    [9] = 4,
}
local function GetCharWidth(char)
    return CharWidths[char];
end

function Actives.DrawActiveCount(pos, count, pivot, color)
    pivot = pivot or Vector.Zero;
    local exp = 1;
    for i = #countNums, 1, -1 do
        table.remove(countNums, i);
    end

    local negative = false;
    if (count == 0) then
        countNums[1] = 0;
    else
        if (count < 0) then
            count = -count;
            negative = true;
        end

        while (exp <= count) do
            local num = math.floor(count % (exp * 10) / exp)
            table.insert(countNums, num);
            exp = exp * 10;
        end
    end

    local posOffset = Vector(4, 0);
    pos = pos + Vector(-pivot.X * (1 + #countNums) * 4, -8 * pivot.Y);
    Actives:DrawMultiplier(pos, color);
    pos = pos + posOffset;
    local charNum = #countNums;
    if (charNum > 1 ) then
        pos = pos + Vector(-1, 0);
    end

    if (negative) then
        Actives:DrawMinus(pos + Vector(1,0), color);
        pos = pos + posOffset;
    end

    for i = charNum, 1, -1 do
        local char = countNums[i];
        Actives:DrawSingleNumber(char, pos, color);
        posOffset.X = GetCharWidth(char);
        pos = pos + posOffset;
    end
    return true;
end

function Actives.GetPlayerActiveUIPos(player, slot, playerIndex)
    local type = player:GetPlayerType();
    local hudOffset = Options.HUDOffset;
    local x, y;
    local screenSize = Screen.GetScreenSize();
    x = 19 + 20 * hudOffset;
    y = 20 + 12 * hudOffset;
    if (playerIndex == 1) then
        x = screenSize.X - 140 - 24 * hudOffset;
        y = 20 + 12 * hudOffset;
        
    elseif (playerIndex == 2) then
        x = 29 + 22 * hudOffset;
        y = screenSize.Y - 19 - 6 * hudOffset;
    elseif (playerIndex == 3) then
        x = screenSize.X - 148 - 16 * hudOffset;
        y = screenSize.Y - 19 - 6 * hudOffset;
    end
    if (type == PlayerType.PLAYER_ESAU) then
        if (playerIndex == 0) then
            x = screenSize.X - 21 - 16 * hudOffset;
            y = screenSize.Y - 19 - 6 * hudOffset;
        end
    end
    
    if (slot == ActiveSlot.SLOT_POCKET) then
        if (playerIndex > 0) then
            x = x - 19;
            y = y + 22;
        else
            if (type == PlayerType.PLAYER_ESAU) then
                x = screenSize.X - 16 - 16 * hudOffset;
                y = screenSize.Y - 42 - 6 * hudOffset;
            else
                x = screenSize.X - 21 - 16 * hudOffset;
                y = screenSize.Y - 10 - 6 * hudOffset;
            end
        end
    end
    return Vector(x, y);
end

local HalfVector = Vector(0.5, 0.5);
function Actives.GetPlayerActiveUIScale(player, slot, playerIndex)
    
    if (slot == ActiveSlot.SLOT_POCKET) then
        if (playerIndex > 0) then
            return HalfVector;
        end
    end
    return Vector.One;
end
local countOffset = Vector(-16, -16);
local function GetPlayerActiveCountPos(player, slot, playerIndex)
    return Actives.GetPlayerActiveUIPos(player ,slot, playerIndex) + countOffset;
end



function Actives.RenderOnActive(item, func)
    if (Game():GetHUD():IsVisible()) then
        local Detection = Lib.Detection;
        local controllers = {};


        local function RenderActive(player, playerIndex)
            for slot = ActiveSlot.SLOT_PRIMARY , ActiveSlot.SLOT_POCKET2, 2 do
                if (player:GetActiveItem(slot) == item and (slot < ActiveSlot.SLOT_POCKET or player:GetCard(0) + player:GetPill(0) <= 0)) then
                    local pos = Actives.GetPlayerActiveUIPos(player, slot, playerIndex)
                    local scale = Actives.GetPlayerActiveUIScale(player, slot, playerIndex);
                    func(player, playerIndex, slot, pos, scale);
                end
            end
        end

        local playerIndex = 0;
        for i, player in Detection.PlayerPairs() do
            -- If is not a coop baby.
            if (not controllers[player.ControllerIndex]) then
                local type = player:GetPlayerType();
                if (type ~= PlayerType.PLAYER_ESAU) then
                    RenderActive(player, playerIndex);
                    if (type == PlayerType.PLAYER_JACOB) then
                        local other = player:GetOtherTwin();
                        RenderActive(other, playerIndex);
                    end
                end
                controllers[player.ControllerIndex] = true;
                playerIndex = playerIndex + 1;
            end
        end
    end
end

function Actives.RenderActivesCount(item, infoGetter)
    local function func(player, playerIndex, slot, pos, scale)
        local pivot = Vector(0.5, 0.5);
        local pos = GetPlayerActiveCountPos(player, slot, playerIndex);
        local count = 0;
        local color = Color.Default;
        if (type(infoGetter) == "function") then
            count, color = infoGetter(player);
        else
            count = infoGetter;
        end
        Actives.DrawActiveCount(pos, count, pivot, color);
    end
    Actives.RenderOnActive(item, func);
end


function Actives.CanSpawnWisp(player, flags)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0);
end

------- Events ---------
-- function Actives:onPlayerUpdate(player)
--     local playerData = Actives.GetPlayerData(player);
--     for i=0,3 do
--         local pressing = Actives.IsActivePressed(player, i);
--         if (playerData.Pressing[i] ~= pressing) then
--             playerData.Pressing[i] = pressing;
--             if (pressing) then
--                 playerData.Pressed[i] = true;
--             end
--         else
--             playerData.Pressed[i] = false;
--         end
--     end
-- end


do -- Try Use Active.
    
    --- Get the charges of the active item which player trying to use.
    --- If the active item is not being tried to use, return -1.
    ---@param player EntityPlayer
    ---@param slot integer
    ---@return integer charges
    function Actives:GetUseTryCharges(player, slot)
        local data = GetPlayerData(player, false);
        return (data and data.UsedCharges[slot]) or -1;
    end

    --- Set the charges of the active item which player trying to use.
    --- This will set the charges of the active item into `charges` at next update.
    ---@param player EntityPlayer
    ---@param slot integer
    ---@param charges integer 
    function Actives:SetUseTryCharges(player, slot, charges)
        local data = GetPlayerData(player, true);
        data.UsedCharges[slot] = charges;
    end

    --- End current active use try of an active slot.
    --- Remember to call this when you want to discharge the item.
    ---@param player EntityPlayer
    ---@param slot integer
    function Actives:EndUseTry(player, slot)
        self:SetUseTryCharges(player, slot, nil);
    end
    function Actives:CostUseTryCharges(player, item, slot, cost)
        local maxCharges = Isaac.GetItemConfig():GetCollectible(item).MaxCharges;
        local charges = Actives:GetUseTryCharges(player, slot);
        if (not charges or charges < 0) then
            charges = player:GetActiveCharge (slot) + player:GetBatteryCharge (slot);
        end

        local needCost = cost;
        if (needCost > 0) then
            local cost = math.min(needCost, charges);
            Actives:SetUseTryCharges(player, slot, charges - cost);
            needCost = needCost - cost;
        end
        if (needCost > 0) then
            local soulCharges = player:GetEffectiveSoulCharge();
            local cost = math.min(needCost, soulCharges);
            player:AddSoulCharge(-cost);
            needCost = needCost - cost;
        end
        if (needCost > 0) then
            local bloodCharges = player:GetEffectiveBloodCharge();
            local cost = math.min(needCost, bloodCharges);
            player:AddBloodCharge(-cost);
            needCost = needCost - cost;
        end
    end

    local function InputAction(mod, entity, hook, action)
        local player = entity and entity:ToPlayer();
        if (player and player:AreControlsEnabled ()) then
            if (hook == InputHook.IS_ACTION_TRIGGERED and not Game():IsPaused()) then
                local itemConfig = Isaac.GetItemConfig();
                for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET, 2 do
                    local item = player:GetActiveItem(slot);
                    if (item > 0 and Actives.IsActiveButtonTriggered(player, slot)) then
                        local data = GetPlayerData(player, false);
                        if (not data or not data.UsedCharges[slot] ) then
                            local maxCharges = itemConfig:GetCollectible(item).MaxCharges;
                            local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);
                            local soulCharges = player:GetEffectiveSoulCharge();
                            local bloodCharges = player:GetEffectiveBloodCharge();
                            local totalCharges = charges + soulCharges + bloodCharges;
                            if (totalCharges < maxCharges) then

                                local canUse = false;
                                for i, info in ipairs(Callbacks.Functions.TryUseItem) do
                                    if (not info.OptionalArg or info.OptionalArg <=0 or info.OptionalArg == item) then
                                        local result = info.Func(info.Mod, item, player, slot);
                                        canUse = result;
                                    end
                                end
                                if (canUse) then
                                    player:SetActiveCharge(math.max(0, maxCharges - bloodCharges - soulCharges), slot);
                                    local data = GetPlayerData(player, true);
                                    data.UsedCharges[slot] = charges;
                                end
                            end
                        end
                    end 
                end
            end
        end

    end
    Actives:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)


    local function PostPlayerUpdate(mod, player)
        local data = GetPlayerData(player, false);
        if (data) then
            for slot, charge in pairs(data.UsedCharges) do
                player:SetActiveCharge(math.max(0, charge), slot);
                data.UsedCharges[slot] = nil;
            end
        end
    end
    Actives:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)
end


return Actives;