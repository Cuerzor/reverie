local Actives = CuerLib.Actives;
local Inputs = CuerLib.Inputs;
local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local HoldingActive = CuerLib.HoldingActive;
local Dice = ModItem("D2147483647", "DLimit");
local config = Isaac.GetItemConfig();

local FrameSprite = Sprite();
FrameSprite:Load("gfx/reverie/ui/select_frame.anm2", true);
FrameSprite:SetFrame("Frame", 0);
FrameSprite.Scale = Vector(0.5, 0.5);

local FontColor =KColor(1,1,1,1);


local ActiveDifficulty = 0;
local ActiveList = Actives.GetActiveList();

local HUDWidth = 5;
local HUDHeight = 5;
local HUDSize = HUDWidth * HUDHeight;
local maxPage = math.ceil(#ActiveList / (HUDSize - 1));

function Dice.UpdateActiveList(player)
    local diff = 0;
    if (THI.IsLunatic()) then
        diff = 1;
    end
    local Seija = THI.Players.Seija;
    if (Seija:WillPlayerNerf(player)) then
        diff = 2;
    end

    if (diff ~= ActiveDifficulty) then
        ActiveList = Actives.GetActiveList();
        if (diff == 1) then
            for i = #ActiveList, 1, -1 do
                local active = ActiveList[i];
                if (active == CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE) then
                    table.remove(ActiveList, i);
                end
            end
        elseif (diff == 2) then
            local itemConfig = Isaac.GetItemConfig();
            for i = #ActiveList, 1, -1 do
                local active = ActiveList[i];
                local config = itemConfig:GetCollectible(active);
                if (config and config.Quality > 1) then
                    table.remove(ActiveList, i);
                end
            end
        end
        ActiveDifficulty = diff;
        maxPage = math.ceil(#ActiveList / (HUDSize - 1));
    end

end




function Dice.GetTransformCost()
    if (THI.IsLunatic()) then
        return 2;
    end
    return 1;
end

function Dice:GetPlayerData(player, init)
    return Dice:GetData(player, init, function() return {
        SelectedItem = nil,
        Choice = 1,
        Page = 1,
        ChargesAfterUse = 0,
        UsedItemSlot = -1,
        UsedItem = 0,
        UsedItemCharge = 0,
        Sprites = {},
        UsedThisFrame = false
    } end);
end


local function GetChoiceItemId(page, choice)
    if (choice == HUDSize) then
        return -1;
    end
    local index = (page - 1) * (HUDSize - 1) + choice;
    local item = ActiveList[index];
    if (item and item > 0) then
        return item;
    end
    return 0;
end

local function ChangeItemSprite(sprite, item)
    
    local gfx;
    if (item == 0) then
        gfx = "";
    elseif (item == -1) then
        gfx = "gfx/reverie/ui/cancel.png";
    else
        gfx = config:GetCollectible(item).GfxFileName;
    end
    sprite:ReplaceSpritesheet(1, gfx);
    sprite:LoadGraphics();
end
local function GetItemSprite(item)
    local spr = Sprite();
    spr:Load("gfx/005.100_collectible.anm2", false);
    spr:SetFrame("PlayerPickup", 0);
    spr.Scale = Vector(0.5, 0.5);
    return spr;
end

local function InitSprites(playerData)
    
    local sprites = playerData.Sprites;
    for i = 1, HUDSize do
        local item = GetChoiceItemId(playerData.Page, i);
        sprites[i] = sprites[i] or GetItemSprite();
        ChangeItemSprite(sprites[i], item);
    end
end

local function SetPage(playerData, page)
    local sprites = playerData.Sprites;
    playerData.Page = page;
    for i = 1, HUDSize do
        local item = GetChoiceItemId(page, i);
        sprites[i] = sprites[i] or GetItemSprite();
        ChangeItemSprite(sprites[i], item);
    end
end


local function SelectLeft(playerData)
    if (playerData.Choice % HUDWidth == 1) then
        local page = playerData.Page - 1;
        if (page < 1) then
            page = maxPage;
        end
        SetPage(playerData, page);
        playerData.Choice = playerData.Choice + HUDWidth -1;
    else
        playerData.Choice = playerData.Choice - 1;
    end
end
local function SelectRight(playerData)
    
    if (playerData.Choice % HUDWidth == 0) then
        local page = playerData.Page + 1;
        if (page > maxPage) then
            page = 1;
        end
        SetPage(playerData, page);
        playerData.Choice = playerData.Choice - HUDWidth +1;
    else
        playerData.Choice = playerData.Choice + 1;
    end
end
local function SelectDown(playerData)
    playerData.Choice = math.max(1, math.min(HUDSize, playerData.Choice + HUDWidth));
end

local function SelectUp(playerData)
    playerData.Choice = math.max(1, math.min(HUDSize, playerData.Choice - HUDWidth));
end

local function IsSelecting(player)
    return HoldingActive:GetHoldingItem(player) == Dice.Item;
end

function Dice:PostPlayerUpdate(player)
    -- Move the Cursor.
    local actionTrigger = Input.IsActionTriggered;
    -- Move.
    if (IsSelecting(player)) then

        local playerData = Dice:GetPlayerData(player, true);
        -- Move Left.
        if (actionTrigger(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)) then
            SelectLeft(playerData);
            
            local times = 0;
            while (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) do
                playerData.Choice = playerData.Choice - 1;

                times = times + 1;
                if (times > 50) then
                    print("Tries Out!");
                end
            end
        end
        -- Move Right.
        if (actionTrigger(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)) then
            SelectRight(playerData);
            
            if (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) then
                playerData.Choice = HUDSize;
            end
        end
        -- Move Down.
        if (actionTrigger(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)) then
            SelectDown(playerData);

            if (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) then
                playerData.Choice = HUDSize;
            end
        end
        -- Move Up.
        if (actionTrigger(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)) then
            SelectUp(playerData);
            
            
            local times = 0;
            while (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) do
                playerData.Choice = playerData.Choice - 1;
                
                times = times + 1;
                if (times > 25) then
                    print("Tries out!");
                    break;
                end
            end

        end

        -- Cancel.
        if (actionTrigger(ButtonAction.ACTION_DROP, player.ControllerIndex) or not player:HasCollectible(Dice.Item, true)) then
            HoldingActive:Cancel(player);
        end
    end

    
    -- Check if active item is used.
    local playerData = Dice:GetPlayerData(player, false);
    local used = false;
    if (playerData) then
        local slot = playerData.UsedItemSlot;
        if (slot >= 0) then
            -- If has tranformed item.
            local item = player:GetActiveItem(slot);
            local itemCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);
            local collectibleConfig = config:GetCollectible(item);
            local itemMaxCharges = 0;
            if (collectibleConfig) then
                itemMaxCharges = collectibleConfig.MaxCharges;
            end
            if (item == playerData.UsedItem) then
                if (itemCharge < playerData.UsedItemCharge or itemMaxCharges == 0) then
                    -- After active's charges is changed, or it has no charge.
                    player:RemoveCollectible(item, true, slot, true);
                    player:AddCollectible(Dice.Item, playerData.ChargesAfterUse, false, slot);
                    used = true;
                    playerData.UsedItemSlot = -1;
                end
            else
                -- If used item is not current active item (One-time use)
                playerData.SelectedItem = nil;
                playerData.UsedItem = -1;
                playerData.UsedItemSlot = -1;
                playerData.UsedItemCharge = 0;
                playerData.ChargesAfterUse = 0;
            end
        end

        playerData.UsedThisFrame = false;
    end
    if (used) then
        return false;
    end
end

Dice:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Dice.PostPlayerUpdate);


local function TryUseDice(mod, item, player, slot)
    local charges = player:GetActiveCharge (slot);
    return charges >= Dice.GetTransformCost();
end
Dice:AddCustomCallback(CuerLib.CLCallbacks.CLC_TRY_USE_ITEM, TryUseDice, Dice.Item);


function Dice:UseItem(item, rng, player, flags, slot, varData)
    local playerData = Dice:GetPlayerData(player, true);
    if (item == Dice.Item) then

        if (player:GetActiveItem(slot) == Dice.Item) then
            
            -- Use Dice when transforming into itself.
            if (playerData and playerData.SelectedItem and item == playerData.SelectedItem) then

                -- Teleport to I AM Error Room.
                THI.Game:StartRoomTransition(-2, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player);
                player:RemoveCollectible(Dice.Item, true, slot, true);
                playerData.SelectedItem = nil;
            else
                
                -- Normally Use.
                if (not IsSelecting(player)) then
                    HoldingActive:Hold(Dice.Item, player, slot, flags);
                    Dice.UpdateActiveList(player);
                    InitSprites(playerData);
                else

                    local item = GetChoiceItemId(playerData.Page, playerData.Choice);
                    if (item == -1) then
                        -- Cancel.
                        HoldingActive:Cancel(player);
                    elseif (item > 0) then

                        local currentCharge = Actives:GetUseTryCharges(player, slot);
                        if (not currentCharge or currentCharge < 0) then
                            currentCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);
                        end
                        
                        local transformCost = Dice.GetTransformCost();
                        
                        HoldingActive:Cancel(player);
                        THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                        -- Get Item.
                        player:RemoveCollectible(Dice.Item, true, slot, true);

                        local collectibleConfig = config:GetCollectible(item);
                        -- Make zero charge actives like Converter and Guppy's paw cost at least 1 charge.
                        local itemMaxCharges = collectibleConfig.MaxCharges;
                        local itemChargeType = collectibleConfig.ChargeType;

                        currentCharge = currentCharge - transformCost;
                        currentCharge = math.max(currentCharge, 0)

                        local newItemCharge = math.min(itemMaxCharges, currentCharge);
                        if (itemChargeType == 1 or itemChargeType == 2) then
                            newItemCharge = 0;
                        end

                        player:AddCollectible(item, newItemCharge, false, slot);
                        --player:AnimateCollectible(item, "Pickup");
                        player:AnimateCollectible(item, "HideItem");
                        THI.Game:GetHUD():ShowItemText(player, config:GetCollectible(item));
                        playerData.ChargesAfterUse = currentCharge - newItemCharge;
                        
                        playerData.SelectedItem = item;
                        playerData.UsedThisFrame = true; 

                        Actives:EndUseTry(player, slot);
                    end
                end

                return {Discharge = false}
            end
        end
    else
        if (playerData and playerData.SelectedItem and item == playerData.SelectedItem) then
            if (player:GetActiveItem(slot) == item and flags & UseFlag.USE_OWNED) then
                playerData.SelectedItem = nil;
                playerData.UsedItem = item;
                playerData.UsedItemSlot = slot;
                playerData.UsedItemCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);
            end
        end
    end
end
Dice:AddCallback(ModCallbacks.MC_USE_ITEM, Dice.UseItem);

local function PreUseItem(mod, item, rng, player, flags, slot, varData)
    local playerData = Dice:GetPlayerData(player, false);
    if (playerData and playerData.UsedThisFrame) then
        return true;
    end

end
Dice:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, PreUseItem);





local renderOffset = Vector(-32, -96);
local renderInterval = 16;
local pageOffset = Vector(0, -24);

local function RenderSelecting(player)
    local playerData = Dice:GetPlayerData(player, false)
    -- Render Choices.
    if (playerData) then
        local game = THI.Game;
        local playerPos = Screen.GetEntityRenderPosition(player);
        local renderPos = playerPos + renderOffset;
        local page = playerData.Page;
        local choice = playerData.Choice;

        local pagePos = renderPos + pageOffset;
        local pageString = THI.GetText(THI.StringCategories.DEFAULT, "#PAGES");
        local font = THI.GetFont("D2147483647_PAGE");
        font:DrawStringUTF8(pageString.." "..page.."/"..maxPage, pagePos.X, pagePos.Y, FontColor, 64, true)

        local sprites = playerData.Sprites;
        for x = 1, HUDWidth do
            for y = 1, HUDHeight do
                local i = (y - 1) * HUDWidth + x;
                local sprPos = renderPos + Vector((x - 1) * renderInterval, (y - 1) * renderInterval + 4);
                sprites[i]:Render(sprPos, Vector.Zero, Vector.Zero);
            end
        end

        local choiceX = (choice - 1) % HUDWidth;
        local choiceY = math.floor((choice - 1) / HUDWidth);
        local framePos = renderPos + Vector(choiceX * renderInterval, choiceY * renderInterval);
        FrameSprite:Render(framePos, Vector.Zero, Vector.Zero);
    end
    

end

function Dice:PostRender()
    for p, player in Detection.PlayerPairs() do
        if (IsSelecting(player)) then
            RenderSelecting(player);
        end
    end
end
Dice:AddCallback(ModCallbacks.MC_POST_RENDER, Dice.PostRender);

return Dice;