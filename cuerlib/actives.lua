local Lib = CuerLib;
local Screen = Lib.Screen;
local Inputs = Lib.Inputs;

local Actives = {
    FontSprite = Sprite();
}
local itemConfig = Isaac.GetItemConfig();

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

Actives.FontSprite:Load("gfx/ui/active_count.anm2", true);

-- function Actives.GetPlayerData(player)
--     local data = Lib:GetData(player);
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

function Actives.IsActiveButtonDown(player, slot)
    return IsActiveInput(player, slot, Inputs.IsActionDown);
end

function Actives.IsActiveItemDown(player, item)
    for i=0,3 do
        if (player:GetActiveItem(i) == item) then
            if (Actives.IsActiveButtonDown(player, i)) then
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
function Actives:DrawMultiplier(pos)
    self.FontSprite:SetFrame("Characters", 12);
    self.FontSprite:Render(pos, Vector.Zero, Vector.Zero);
end
function Actives:DrawSingleNumber(num, pos)
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

function Actives.DrawActiveCount(pos, count, pivot)
    pivot = pivot or Vector.Zero;
    local exp = 1;
    local index = 1;
    for i = #countNums, 1, -1 do
        table.remove(countNums, i);
    end

    if (count == 0) then
        countNums[1] = 0;
    else

        while (exp <= count) do
            local num = math.floor(count % (exp * 10) / exp)
            countNums[index] = num;
            exp = exp * 10;
            index = index + 1;
        end
    end

    local posOffset = Vector(4, 0);
    pos = pos + Vector(-pivot.X * (1 + #countNums) * 4, -8 * pivot.Y);
    Actives:DrawMultiplier(pos);
    pos = pos + posOffset;
    local charNum = #countNums;
    if (charNum > 1 ) then
        pos = pos + Vector(-1, 0);
    end
    for i = charNum, 1, -1 do
        local char = countNums[i];
        Actives:DrawSingleNumber(char, pos);
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
                y = screenSize.Y - 6 - 6 * hudOffset;
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
            for slot = ActiveSlot.SLOT_PRIMARY , ActiveSlot.SLOT_POCKET, 2 do
                if (player:GetActiveItem(slot) == item) then
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

function Actives.RenderActivesCount(item, countGetter)
    local function func(player, playerIndex, slot, pos, scale)
        local pivot = Vector(0.5, 0.5);
        local pos = GetPlayerActiveCountPos(player, slot, playerIndex);
        local count = 0;
        if (type(countGetter) == "function") then
            count = countGetter(player);
        else
            count = countGetter;
        end
        Actives.DrawActiveCount(pos, count, pivot);
    end
    Actives.RenderOnActive(item, func);
end

function Actives.GetTotalCharges(player,slot)
    local charges = player:GetActiveCharge (slot);
    local soulCharges = player:GetEffectiveSoulCharge();
    local bloodCharges = player:GetEffectiveBloodCharge();
    return charges + soulCharges + bloodCharges;
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


function Actives:Register(mod)
    --mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Actives.onPlayerUpdate)
end

function Actives:Unregister(mod)
    --mod:RemoveCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Actives.onPlayerUpdate)
end



return Actives;