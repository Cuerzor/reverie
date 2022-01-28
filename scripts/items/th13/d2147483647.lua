local Actives = CuerLib.Actives;
local Inputs = CuerLib.Inputs;
local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local HoldingActive = CuerLib.HoldingActive;
local Dice = ModItem("D2147483647", "DLimit");
local config = Isaac.GetItemConfig();

local FrameSprite = Sprite();
FrameSprite:Load("gfx/ui/select_frame.anm2", true);
FrameSprite:SetFrame("Frame", 0);
FrameSprite.Scale = Vector(0.5, 0.5);

local enFont = Font();
enFont:Load("font/terminus8.fnt");
local zhFont = Font();
zhFont:Load("font/cjk/lanapixel.fnt");
local PageFonts = {
    en = enFont,
    zh = zhFont,
}
local FontColor =KColor(1,1,1,1);


local ActiveDifficulty = 0;
local ActiveList = Actives.GetActiveList();

local HUDWidth = 5;
local HUDHeight = 5;
local HUDSize = HUDWidth * HUDHeight;
local maxPage = math.ceil(#ActiveList / (HUDSize - 1));

function Dice.UpdateActiveList()
    local diff = 0;
    if (THI.IsLunatic()) then
        diff = 1;
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
        SelectedItem = -1,
        Choice = 1,
        Page = 1,
        ChargesAfterUse = 0,
        UsedItemSlot = -1,
        UsedItem = 0,
        UsedItemCharge = 0,
        Sprites = {}
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
        gfx = "gfx/ui/cancel.png";
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

function Dice:PostPlayerEffect(player)
    -- Move the Cursor.
    if (IsSelecting(player)) then

        local playerData = Dice:GetPlayerData(player, true);
        if (Inputs.IsActionDown(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)) then
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
        if (Inputs.IsActionDown(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)) then
            SelectRight(playerData);
            
            if (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) then
                playerData.Choice = HUDSize;
            end
        end
        if (Inputs.IsActionDown(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)) then
            SelectDown(playerData);

            
            if (GetChoiceItemId(playerData.Page, playerData.Choice) == 0) then
                playerData.Choice = HUDSize;
            end
        end
        if (Inputs.IsActionDown(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)) then
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

        if (Inputs.IsActionDown(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
            HoldingActive:Cancel(player);
        end
    end

    local playerData = Dice:GetPlayerData(player, false);
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
                    playerData.UsedItemSlot = -1;
                end
            else
                -- If used item is not current active item (One-time use)
                playerData.SelectedItem = -1;
                playerData.UsedItem = -1;
                playerData.UsedItemSlot = -1;
                playerData.UsedItemCharge = 0;
                playerData.ChargesAfterUse = 0;
            end
        end
    end
        
    -- Use the dice.
    local pressed, slot = Actives.IsActiveItemDown(player, Dice.Item);
    
    local currentCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);

    local transformCost = Dice.GetTransformCost();
    if (pressed and (currentCharge >= transformCost or slot == ActiveSlot.SLOT_POCKET2)) then
        local playerData = Dice:GetPlayerData(player, true);
        -- I AM ERROR room
        if (Dice.Item == playerData.SelectedItem) then
            THI.Game:StartRoomTransition(-2, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player);
            player:RemoveCollectible(Dice.Item, true, slot, true);
            playerData.SelectedItem = -1;
        else
            -- Normal Use.
            if (not IsSelecting(player)) then
                HoldingActive:Hold(Dice.Item, player, slot);
                Dice.UpdateActiveList();
                InitSprites(playerData);
            else

                local item = GetChoiceItemId(playerData.Page, playerData.Choice);
                if (item == -1) then
                    -- Cancel.
                    HoldingActive:Cancel(player);
                elseif (item > 0) then
                    
                    HoldingActive:Cancel(player);
                    THI.SFXManager:Play(SoundEffect.SOUND_POWERUP1);
                    -- Get Item.
                    player:RemoveCollectible(Dice.Item, true, slot, true);

                    local collectibleConfig = config:GetCollectible(item);
                    -- Make zero charge actives like Converter and Guppy's paw cost at least 1 charge.
                    local itemMaxCharges = collectibleConfig.MaxCharges;
                    local itemChargeType = collectibleConfig.ChargeType;

                    currentCharge = currentCharge - transformCost;

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
                end
            end
        end
    end
end

Dice:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Dice.PostPlayerEffect);


function Dice:UseItem(item, rng, player, flags, slot, varData)
    local playerData = Dice:GetPlayerData(player, false);
    if (playerData and item == playerData.SelectedItem) then
        if (item ~= Dice.Item) then
            playerData.SelectedItem = -1;
            playerData.UsedItem = item;
            playerData.UsedItemSlot = slot;
            playerData.UsedItemCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot);
        end
    end
end
Dice:AddCallback(ModCallbacks.MC_USE_ITEM, Dice.UseItem);

function Dice:UseDice(item, rng, player, flags, slot, varData)
    return {Discharge = false, ShowAnim = false};
end
Dice:AddCallback(ModCallbacks.MC_USE_ITEM, Dice.UseDice, Dice.Item);





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
        local font = PageFonts[Options.Language] or PageFonts.en;
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