local HoldingActive = CuerLib.HoldingActive;
local Detection = CuerLib.Detection;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;
local Inputs = CuerLib.Inputs;
local Pickups = CuerLib.Pickups;
local Crate = ModItem("Yamawaro's Crate", "YAMAWARO_CRATE");


local config = Isaac.GetItemConfig();
function Crate.IsOpening(player)
    return HoldingActive:GetHoldingItem(player) == Crate.Item;
end


local GoldenColor = Color(1,1,1,1,0,0,0);
GoldenColor:SetColorize(1,1,0,1);
GoldenColor:SetOffset(0.6,0.3,0);
Crate.UIFrames = {
    BACKGROUND = 0,
    SLOTS = 1,
    BLACK_SLOTS = 2,
    BLUE_SLOTS = 3,
    RED_SLOTS = 4,
    BLUE_SCROLL = 5,
    RED_SCROLL = 6,
    LEFT_ARROW = 7,
    RIGHT_ARROW = 8,
    SELECTED_SLOT = 9,
    CLOSED = 10,
}
Crate.SelectTypes = {
    CLOSE = 0,
    CRATE = 1,
    ITEMS = 2,
    DROP = 3,
    SCROLLS = 4
}
Crate.ItemType = {
    COLLECTIBLE = 0,
    TRINKET = 1,
    POCKET = 2,
}
Crate.Pivots = {
    LEFT_TOP = 0,
    RIGHT_TOP = 1,
    LEFT_BOTTOM = 2,
    RIGHT_BOTTOM = 3
}
Crate.Scrolls = {
    TELEPORT = 0,
    IDENTIFY = 1
}



local function GetPlayerCrateData(player, init)
    local function getter()
        -- local storage = {
        --     {
        --         ID = CollectibleType.COLLECTIBLE_LATCH_KEY,
        --         Type = Crate.ItemType.COLLECTIBLE,
        --         Sprite = nil,
        --         Touched = false,
        --         Charge = 0,
        --         Golden = false,
        --         VarData = 0,
        --     }
        -- };
        return {
            --Storage = storage,
            Storage = {},
            IdentifiedRooms = {}
        }
    end
    return Crate:GetData(player, init, getter);
end
local function GetPlayerTempData(player, init)
    local function getter()
        return {
            Selected = {
                Type = Crate.SelectTypes.CLOSE,
                Index = 1
            },
            Holding = {
                Index = 0,
                From = -1
            },
            ItemList = nil,
            ExtraSlots = {},
            TotalSlotsWidth = 0,
            ValidSlots = {},
            Page = 1,
            TotalPages = 1,
            HoldFrames ={}
        }
    end
    return Crate:GetTempData(player, init, getter);
end
local function ClearTempData(player)
    Crate:SetTempData(player, nil);
end



-- Slots.
local function HasBlueSlots(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES);
end

local function HasRedSlots(player) return Players.HasJudasBook(player) end

local ExtraSlots = {
    {
        Name = "Base",
        Condition = function(player)
            return true;
        end,
        SlotCount = 8,
        Frame = Crate.UIFrames.SLOTS,
        Width = 4,
        Height = 2,
        Pivot = Crate.Pivots.LEFT_TOP;
    },
    {
        Name = "CarBattery",
        Condition = function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY);
        end,
        SlotCount = 4,
        Frame = Crate.UIFrames.BLACK_SLOTS,
        Width = 2,
        Height = 2,
        Pivot = Crate.Pivots.RIGHT_TOP;
    },
    {
        Name = "BookOfVirtues",
        Condition = HasBlueSlots,
        SlotCount = 2,
        Frame = Crate.UIFrames.BLUE_SLOTS,
        Width = 1,
        Height = 2,
        Pivot = Crate.Pivots.RIGHT_TOP;
    },
    {
        Name = "JudasBook",
        Condition = HasRedSlots,
        SlotCount = 2,
        Frame = Crate.UIFrames.RED_SLOTS,
        Width = 1,
        Height = 2,
        Pivot = Crate.Pivots.RIGHT_TOP;
    }
}

local itemsWidth = 6;
local itemsHeight = 3;
local itemsSize = itemsWidth * itemsHeight;

local BookOfVirtuesBottomSlot = 13;
local JudasBookBottomSlot = 15;
do
    local slotIndex = 0;
    for _, slots in pairs(ExtraSlots) do
        if (slots.Name == "BookOfVirtues") then
            BookOfVirtuesBottomSlot = slotIndex + slots.SlotCount - 1;
        elseif (slots.Name == "JudasBook") then
            JudasBookBottomSlot = slotIndex + slots.SlotCount - 1;
        end
        slotIndex = slotIndex + slots.SlotCount;
    end
    
end

function Crate.IsScrollUnlocked(player, index)
    if (index == Crate.Scrolls.TELEPORT) then
        return HasBlueSlots(player);
    elseif (index == Crate.Scrolls.IDENTIFY) then
        return HasRedSlots(player);
    end
    return false;
end

function Crate.CanUseIdentifyScroll(player)
    local data = GetPlayerCrateData(player ,false);
    if (data) then
        local currentIndex = Game():GetLevel():GetCurrentRoomDesc().GridIndex;
        for _, roomIndex in pairs(data.IdentifiedRooms) do
            if (roomIndex == currentIndex) then
                return false;
            end
        end
    end
    return true;
end

function Crate.AddIdentifiedRoom(player)
    local data = GetPlayerCrateData(player ,true);
    local currentIndex = Game():GetLevel():GetCurrentRoomDesc().GridIndex;
    table.insert(data.IdentifiedRooms, currentIndex);
end
function Crate.ClearIdentifiedRooms(player)
    local data = GetPlayerCrateData(player ,false);
    if (data) then
        for i, roomIndex in pairs(data.IdentifiedRooms) do
            data.IdentifiedRooms[i] = nil;
        end
    end
end

function Crate.CanTakeOut(player, source)
    if (source.Type == Crate.ItemType.COLLECTIBLE) then
        local playerType = player:GetPlayerType();
        -- Tainted Isaac limit.
        if (playerType == PlayerType.PLAYER_ISAAC_B) then
            if (Players.GetTIsaacRemainSpaces(player) <= 0 and not Players.IsTIsaacExcluded(source.ID)) then
                return false;
            end
        end

        -- Active item Limit.
        local col = config:GetCollectible(source.ID);
        if (col) then
            if (col.Type == ItemType.ITEM_ACTIVE) then

                local maxActives = 1;
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)) then
                    maxActives = 2;
                end


                local activeNum = 0;
                for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY do
                    if (player:GetActiveItem(slot) > 0) then
                        activeNum = activeNum + 1;
                    end
                end

                if (activeNum >= maxActives) then
                    return false;
                end
            end
        end
    elseif (source.Type == Crate.ItemType.TRINKET) then
        -- Trinket limit.
        local maxTrinkets = player:GetMaxTrinkets() 
        
        local trinketNum = 0;
        for slot = 0, 1 do
            if (player:GetTrinket(slot) > 0) then
                trinketNum = trinketNum + 1;
            end
        end
        
        if (trinketNum >= maxTrinkets) then
            return false;
        end
    end
    return true;
end


function Crate.IsCrateSlotExists(player, index)
    local tempData = GetPlayerTempData(player, false);
    if (tempData) then
        for _, slotData in pairs(tempData.ValidSlots) do
            if (slotData.Index == index) then
                return true;
            end
        end
        return false;
    end
    return index < 8 and index >= 0;
end

function Crate.GetCrateSlotHeight(player) 
    return 2;
end

function Crate.GetCrateSlotMaxIndex(player)
    local tempData = GetPlayerTempData(player, false);
    if (tempData) then
        return tempData.MaxIndex;
    end
    return 8;
end

function Crate.GetCrateSlotWidth(player)
    local tempData = GetPlayerTempData(player, false);
    if (tempData) then
        return tempData.TotalSlotsWidth;
    end
    return 4;
end

function Crate.GetItemsIndexOffset(player)
    local tempData = GetPlayerTempData(player, false);
    local page = (tempData and tempData.Page) or 1;
    return (page - 1) * itemsSize;
end

function Crate.GetCrateIndexPosition(player, index)
    local tempData = GetPlayerTempData(player, false);
    if (tempData) then
        for _, slot in pairs(tempData.ValidSlots) do
            if (slot.Index == index) then
                return slot.PosX, slot.PosY;
            end
        end
    end
    return -1, -1;
end

function Crate:GetItemReduceList(roomType, seed, countMulti)
    roomType = roomType or RoomType.ROOM_DEFAULT;
    seed = seed or math.max(Random(), 1);
    countMulti = countMulti or 1;

    local rng = RNG();
    rng:SetSeed(seed, 1);
    local count = rng:RandomInt(4 * countMulti + 1) + 4 * countMulti;
    local list = {};

    local function GetSpecialHeartSubType(roomType)
        if (roomType == RoomType.ROOM_SECRET) then
            return HeartSubType.HEART_BONE
        elseif (roomType == RoomType.ROOM_CURSE) then
            return HeartSubType.HEART_ROTTEN
        elseif (roomType == RoomType.ROOM_DEVIL) then
            return HeartSubType.HEART_BLACK
        elseif (roomType == RoomType.ROOM_ANGEL) then
            return HeartSubType.HEART_ETERNAL
        end
        return 0;
    end
    for i = 1, count do 
        local variant = 0;
        local subtype = 0;
        local skipRandom = false;
        if (i == 1) then
            local heartSubType = GetSpecialHeartSubType(roomType);
            if (heartSubType > 0) then
                variant = PickupVariant.PICKUP_HEART
                subtype = heartSubType;
                skipRandom = true;
            end
        end
        
        if (not skipRandom) then
            local value = rng:RandomInt(100);
            if (value < 10) then
                variant = PickupVariant.PICKUP_KEY;
            elseif (value < 25) then
                variant = PickupVariant.PICKUP_HEART;
            elseif (value < 50) then
                variant = PickupVariant.PICKUP_BOMB;
            else
                variant = PickupVariant.PICKUP_COIN;
            end
        end
        table.insert(list, {Variant = variant, SubType = subtype});
    end
    return list;
end

function Crate:ReduceItem(position, spawner, seed)
    seed = seed or math.max(Random(), 1);

    local rng = RNG();
    rng:SetSeed(seed, 1);
    local room = Game():GetRoom();
    local player = spawner and spawner:ToPlayer();

    local multi = 1;
    if (player and player:GetPlayerType() == PlayerType.PLAYER_CAIN_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        multi = 3;
    end
    local list = Crate:GetItemReduceList(room:GetType(), rng:Next(), multi)
    for _, info in ipairs(list) do
        local type = info.Type or 5;
        local variant = info.Variant or 0;
        local subType = info.SubType or 0;

        local angle = rng:RandomFloat() * 360;

        local vel = Vector.FromAngle(angle) * 5;
        Isaac.Spawn(type, variant ,subType, position, vel, spawner);
    end
end

local function GetItem(self, index)
    local metatable = getmetatable(self);
    if (metatable and metatable._crateget) then
        return metatable._crateget(self, index);
    else
        return self[index + 1];
    end
end
local function SetItem(self, index, value)
    self[index + 1] = value;
end
local function AddItem(self, index, source)
    local metatable = getmetatable(self);
    if (metatable and metatable._crateadd) then
        metatable._crateadd(self, index, source);
    else
        self[index + 1] = source;
    end
end
local function RemoveItem(self, index)
    local metatable = getmetatable(self);
    if (metatable and metatable._crateremove) then
        metatable._crateremove(self, index);
    else
        self[index + 1] = false;
    end
end

local function GetItemSprite(id, type, golden)
    type = type or Crate.ItemType.COLLECTIBLE;
    local sprite = Sprite();
    sprite:Load("gfx/reverie/ui/yamawaro_crate.anm2", false);

    local col;
    if (type == Crate.ItemType.COLLECTIBLE) then
        col = config:GetCollectible(id);
    elseif (type == Crate.ItemType.TRINKET) then
        col = config:GetTrinket(id);
    end
    local gfx;
    if (col) then   
        gfx = col.GfxFileName;
    end
    if (gfx == "" or not gfx) then
        gfx = "gfx/items/collectibles/placeholder.png";
    end
    sprite:ReplaceSpritesheet(0, gfx);
    sprite:LoadGraphics();
    if (golden) then
        sprite.Color = GoldenColor;
    else
        sprite.Color = Color.Default;
    end
    sprite:Play("Item");
    return sprite;
end

local function UpdateItemList(player, tempData)

    local metatable = {
        _crateadd = function(self, index, value)
            table.insert(self, math.min(#self + 1, index + 1), value);

            local cfg;
            if (value.Type == Crate.ItemType.COLLECTIBLE) then
                cfg = config:GetCollectible(value.ID);
            elseif (value.Type == Crate.ItemType.TRINKET) then
                cfg = config:GetTrinket(value.ID);
            end
            player:QueueItem (cfg, value.Charge, value.Touched, value.Golden, value.VarData);
            tempData.FlushCountdown = 1;
            value.Touched = true;
        end,
        _crateremove = function(self, index)
            local source = self[index + 1];
            table.remove(self, index + 1);
            if (source.Type == Crate.ItemType.COLLECTIBLE) then
                player:RemoveCollectible (source.ID, true, source.ActiveSlot, false);
            elseif (source.Type == Crate.ItemType.TRINKET) then
                local trinketId = source.ID;
                if (source.Golden) then
                    trinketId = trinketId + 32768
                end
                player:TryRemoveTrinket (trinketId)
            end
        end,
        -- _crateget = function(self, index)
        --     local offset = Crate.GetItemsIndexOffset(player);
        --     return self[index + offset];
        -- end
    }
    local list = setmetatable({}, metatable);

    -- Trinkets.
    for slot = 0, 1 do
        local id = player:GetTrinket(slot);
        local golden = id > 32768;
        if (golden) then
            id = id - 32768;
        end
        local col = config:GetTrinket(id);
        if (col) then
            local sprite = GetItemSprite(id, Crate.ItemType.TRINKET, golden);
            local item = { 
                ID = id,
                Type = Crate.ItemType.TRINKET,
                Sprite = sprite,
                Touched = true,
                Charge = player:GetActiveCharge(slot),
                Golden = golden,
                ActiveSlot = slot,
                VarData = 0,
            }
            table.insert(list, item);
        end
    end

    -- Active Collectibles.
    for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY do
        local id = player:GetActiveItem(slot);
        if (id == Crate.Item) then
            goto continue;
        end
        local col = config:GetCollectible(id);
        if (col) then
            local sprite = GetItemSprite(id);
            local item = { 
                ID = id,
                Type = Crate.ItemType.COLLECTIBLE,
                Sprite = sprite,
                Touched = true,
                Charge = player:GetActiveCharge(slot),
                Golden = false,
                ActiveSlot = slot,
                VarData = 0,
            }
            table.insert(list, item);
        end
        ::continue::;
    end

    -- Passive Collectibles.
    local max = config:GetCollectibles().Size -1;
    for id = -max, max do
        local col = config:GetCollectible(id);
        if (col) then
            if (col.Type == ItemType.ITEM_PASSIVE or col.Type == ItemType.ITEM_FAMILIAR) then
                local num = 0;
                if (player:HasCollectible(id, true)) then
                    num = 1;
                end
                num = math.max(num, player:GetCollectibleNum(id, true));
                
                for i = 1, num do
                    local sprite = GetItemSprite(id);
                    local item = {
                        ID = id,
                        Type = Crate.ItemType.COLLECTIBLE,
                        Sprite = sprite,
                        Touched = true,
                        Charge = 0,
                        Golden = false,
                        VarData = 0,
                    }
                    table.insert(list, item);
                end
            end
        end
    end


    tempData.ItemList = list;
    tempData.TotalPages = math.max(1, math.ceil(#list / itemsSize));
end



-- Render.
local UISprite = Sprite();
UISprite:Load("gfx/reverie/ui/yamawaro_crate.anm2", true);
UISprite:SetAnimation("UI");
local backgroundPosOffset = Vector(-72, -160);
local slotsCenter = backgroundPosOffset + Vector(72, 40);
local slotsSize = Vector(64, 32);

local closePosOffset = backgroundPosOffset + Vector(120, 8);

local itemsOffset = backgroundPosOffset + Vector(24, 72);

local dropOffset = backgroundPosOffset + Vector(4, 104);

local function RenderItem(config, position)
    config.Sprite = config.Sprite or GetItemSprite(config.ID, config.Type, config.Golden);
    config.Sprite:Render(position, Vector.Zero, Vector.Zero);
end

local function RenderCrate(player)
    local playerPos = Screen.GetEntityRenderPosition(player);
    local pos;
    local backgroundPos = playerPos + backgroundPosOffset;
    -- Render Background.
    pos = backgroundPos;
    UISprite:SetFrame(Crate.UIFrames.BACKGROUND);
    UISprite:Render(pos, Vector.Zero, Vector.Zero);


    local slotsPos = playerPos + slotsCenter;
    local data = GetPlayerCrateData(player, false);
    local tempData = GetPlayerTempData(player, false);
    local holding = tempData.Holding;
    local holdingFrom = holding.From;
    local holdingIndex = holding.Index;
    
    local selected = tempData.Selected;
    local selectedType = selected.Type;
    local cursorPos = backgroundPos;
    local itemsPos = playerPos + itemsOffset;

    local totalCrateSlots = 8;
    local font = THI.GetFont("CRATE");
    if (tempData) then

        
        
        -- Render Slots.
        totalCrateSlots = #tempData.ValidSlots;
        local totalSlotsSize = Vector(Crate.GetCrateSlotWidth(player) * 16, Crate.GetCrateSlotHeight(player) * 16);

        slotsPos = playerPos + slotsCenter - totalSlotsSize / 2;
        for _, slot in pairs(tempData.ExtraSlots) do
            local slotData = ExtraSlots[slot.SlotsID];
            slotPos = slotsPos + Vector(slot.PosX, slot.PosY) * 16;
            UISprite:SetFrame(slotData.Frame);
            UISprite:Render(slotPos, Vector.Zero, Vector.Zero);

            if (slotData.Name == "BookOfVirtues") then
                UISprite:SetFrame(Crate.UIFrames.BLUE_SCROLL);
                local scrollPos = slotPos + Vector(0, 32);
                UISprite:Render(scrollPos, Vector.Zero, Vector.Zero);
            elseif (slotData.Name == "JudasBook") then
                local scrollPos = slotPos + Vector(0, 32);
                UISprite:SetFrame(Crate.UIFrames.RED_SCROLL);
                UISprite:Render(scrollPos, Vector.Zero, Vector.Zero);
                if (not Crate.CanUseIdentifyScroll(player)) then
                    UISprite:SetFrame(Crate.UIFrames.CLOSED);
                    UISprite:Render(scrollPos, Vector.Zero, Vector.Zero);
                end
            end
        end 
        local string = THI.GetText(THI.StringCategories.DEFAULT, "#YAMAWARO_CRATE_TITLE");
        font:DrawStringUTF8(string, slotsPos.X, slotsPos.Y - 14, KColor.White);
    end

    if (data) then
        
        
        -- Render Crate Content.
        pos = slotsPos;
        local startIndex = 0;
        local posIndex = 0;
        for key, slot in pairs(ExtraSlots) do
            for index = 1, slot.SlotCount do
                local i = startIndex + index;
                if (holdingFrom == Crate.SelectTypes.CRATE and holdingIndex == i - 1)  then
                    goto continue
                end
    
                local item = data.Storage[i];
                if (item) then
                    local posI = posIndex + index - 1;
                    local slotX = math.floor(posI / Crate.GetCrateSlotHeight(player));
                    local slotY = posI % Crate.GetCrateSlotHeight(player);
                    local slotOffset = Vector(slotX * 16, slotY * 16);
                    RenderItem(item, pos + slotOffset)
                end
                ::continue::
            end
            startIndex = startIndex + slot.SlotCount;
            if (slot.Condition(player)) then
                posIndex = posIndex + slot.SlotCount;
            end
        end
    end

    if (tempData) then
        -- Render Content.
        pos = itemsPos;
        local page = tempData.Page;
        local indexOffset = Crate.GetItemsIndexOffset(player);
        for i = 0, math.min(#tempData.ItemList - indexOffset, itemsSize - 1) do
            local index = i + indexOffset;
            if (holdingFrom == Crate.SelectTypes.ITEMS and holdingIndex == index)  then
                goto continue
            end
            local item = GetItem(tempData.ItemList, index);
            if (item) then
                local posIndex = i;
                local slotX = math.floor(posIndex / itemsHeight);
                local slotY = posIndex % itemsHeight;
                local slotOffset = Vector(slotX * 16, slotY * 16);
                RenderItem(item, pos + slotOffset)
            end
            ::continue::
        end
        local string = THI.GetText(THI.StringCategories.DEFAULT, "#YAMAWARO_CRATE_ITEMS");
        font:DrawStringUTF8(string, itemsPos.X, itemsPos.Y - 14, KColor.White);

        -- Render Arrow and page displayer.

        if (tempData.Page > 1) then
            local arrowPos = itemsPos + Vector(-20, -14 + itemsHeight * 8);
            UISprite:SetFrame(Crate.UIFrames.LEFT_ARROW);
            UISprite:Render(arrowPos, Vector.Zero, Vector.Zero);
        end

        
        if (tempData.Page < tempData.TotalPages) then
            local arrowPos = itemsPos + Vector(4 + itemsWidth * 16, -14 + itemsHeight * 8);
            UISprite:SetFrame(Crate.UIFrames.RIGHT_ARROW);
            UISprite:Render(arrowPos, Vector.Zero, Vector.Zero);
        end


        local pageString = THI.GetText(THI.StringCategories.DEFAULT, "#YAMAWARO_CRATE_PAGE");
        pageString = string.gsub(pageString,"{CURRENT}",tempData.Page ); 
        pageString = string.gsub(pageString,"{ALL}",tempData.TotalPages ); 
        font:DrawStringUTF8(pageString, itemsPos.X + 4 + itemsWidth * 16, itemsPos.Y - 14 + itemsHeight * 16, KColor.White);
        

        -- Render Cursor.
        -- Set Cursor Position;
        
        if (selectedType == Crate.SelectTypes.CLOSE) then -- Close Sign.
            cursorPos = playerPos + closePosOffset;
        elseif (selectedType == Crate.SelectTypes.CRATE) then -- Crate Slots.
            local index = selected.Index;

            local slotX, slotY = Crate.GetCrateIndexPosition(player, index);
            local slotOffset = Vector(slotX * 16, slotY * 16);
            cursorPos = slotsPos + slotOffset;
        elseif (selectedType == Crate.SelectTypes.ITEMS) then -- Item Slots.
            local index = selected.Index;

            local slotX = math.floor(index / itemsHeight);
            local slotY = index % itemsHeight;
            local slotOffset = Vector(slotX * 16, slotY * 16);
            cursorPos = itemsPos + slotOffset;
        elseif (selectedType == Crate.SelectTypes.DROP) then -- Drop Slot.
            local index = selected.Index;
            cursorPos = playerPos + dropOffset;
        elseif(selectedType == Crate.SelectTypes.SCROLLS) then
            local index = 0;

            if (selected.Index == 0) then
                index = BookOfVirtuesBottomSlot;
            elseif (selected.Index == 1) then
                index = JudasBookBottomSlot;
            end
            local slotX, slotY = Crate.GetCrateIndexPosition(player, index);
            slotY = slotY + 1;
            local slotOffset = Vector(slotX * 16, slotY * 16);
            cursorPos = slotsPos + slotOffset;
        end
        UISprite:SetFrame(Crate.UIFrames.SELECTED_SLOT);
        UISprite:Render(cursorPos, Vector.Zero, Vector.Zero);

        -- Render Holding.
        if (holdingFrom > 0) then
            local item;
            if (holdingFrom == Crate.SelectTypes.CRATE and data) then
                item = GetItem(data.Storage, holdingIndex);
            elseif (holdingFrom == Crate.SelectTypes.ITEMS) then
                item = GetItem(tempData.ItemList, holdingIndex);
            end
            if (item) then
                RenderItem(item, cursorPos + Vector(8, -8));
            end
        end
    end
end


-- Control.

local function DropItem(player, item)
    local source = item;
    local room = Game():GetRoom();
    local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
    local pickup;
    if (source.Type == Crate.ItemType.COLLECTIBLE) then
        pickup = Pickups.SpawnFixedCollectible(source.ID, pos, Vector.Zero, player):ToPickup();
        pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);
    elseif (source.Type == Crate.ItemType.TRINKET) then
        local trinketID = source.ID;
        if (source.Golden) then
            trinketID = trinketID + 32768;
        end
        pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinketID, pos, Vector.Zero, player):ToPickup();
    end
    if (pickup) then
        pickup.Charge = source.Charge;
        pickup.Touched = source.Touched;
    end
end

local function UpdateCrateSlots(player)
    
    local tempData = GetPlayerTempData(player, true);
    tempData.TotalSlotsWidth = 0;
    local slotUpdated = false;
    local indexOffset = 0;
    for id, slot in pairs(ExtraSlots) do
        local hasSlots = slot.Condition(player);
        if (hasSlots) then
            if (not tempData.ExtraSlots[id]) then
                tempData.ExtraSlots[id] = {
                    SlotsID = id,
                    StartIndex = indexOffset,
                };
                slotUpdated = true;
            end
            
            local posX = tempData.TotalSlotsWidth;
            local posY = 0;
            tempData.ExtraSlots[id].PosX = posX;
            tempData.ExtraSlots[id].PosY = posY;
            tempData.TotalSlotsWidth = tempData.TotalSlotsWidth + slot.Width;
        else
            if (tempData.ExtraSlots[id]) then
                tempData.ExtraSlots[id] = nil;
                slotUpdated = true;
            end
        end
        indexOffset = indexOffset + slot.SlotCount;
    end 

    -- Update Valid Slots.
    if (slotUpdated) then
        -- Clear Valid Slots.
        for k, _ in pairs(tempData.ValidSlots) do
            tempData.ValidSlots[k] = nil;
        end
        -- Fill valid Slots.
        local maxIndex = 0;
        for id, slots in pairs(tempData.ExtraSlots) do
            local slotsData = ExtraSlots[id];
            for i = 0, slotsData.SlotCount - 1 do
                local x = math.floor(i / slotsData.Height);
                local y = i % slotsData.Height;
                local index = slots.StartIndex + i;
                local posX = slots.PosX + x;
                local posY = slots.PosY + y;
                local slotData = {
                    Index = index;
                    SlotsID = id,

                    PosX = posX,
                    PosY = posY,
                }
                table.insert(tempData.ValidSlots, slotData)

                if (index > maxIndex) then
                    maxIndex = index;
                end
            end
        end
        tempData.MaxIndex = maxIndex;
    end

    if (tempData.Selected.Type == Crate.SelectTypes.CRATE) then
        if (not Crate.IsCrateSlotExists(player, tempData.Selected.Index)) then
            tempData.Selected.Index = 0;
        end
    end
    
    local data = GetPlayerCrateData(player, false);
    if (data) then
        for i, item in pairs(data.Storage) do
        
            local item = data.Storage[i];
            if (item and not Crate.IsCrateSlotExists(player, i - 1)) then
                DropItem(player, item);
                data.Storage[i] = false;
                item = false;
            end

        end
        for i = 0, Crate.GetCrateSlotMaxIndex(player) do
            if (GetItem(data.Storage, i) == nil) then
                SetItem(data.Storage, i, false);
            end
        end
    end
end


local function OnUse(player, tempData)
    local holding = tempData.Holding;
    local holdingFrom = holding.From;
    local selected = tempData.Selected;
    local function HasItem(player, source)
        if (source.Type == Crate.ItemType.COLLECTIBLE) then
            return player:GetCollectibleNum(source.ID, true) > 0;
        elseif (source.Type == Crate.ItemType.TRINKET) then
            return player:HasTrinket(source.ID, true);
        end
        return false;
    end
    local indexOffset = Crate.GetItemsIndexOffset(player);
    if (holdingFrom <= 0) then
        if (selected.Type == Crate.SelectTypes.CLOSE) then
            HoldingActive:Cancel(player);
        elseif (selected.Type == Crate.SelectTypes.CRATE) then
            local data = GetPlayerCrateData(player, false);
            if (data) then
                if (GetItem(data.Storage, selected.Index)) then
                    holding.From = selected.Type;
                    holding.Index = selected.Index;
                end
            end
        elseif (selected.Type == Crate.SelectTypes.ITEMS) then
            local sourceTable = tempData.ItemList;
            local itemIndex = indexOffset + selected.Index
            local source = GetItem(sourceTable, itemIndex);
            if (source) then
                if (HasItem(player, source)) then
                    holding.From = selected.Type;
                    holding.Index = itemIndex;
                else
                    RemoveItem(sourceTable, itemIndex);
                    THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                end
            end
        elseif (selected.Type == Crate.SelectTypes.SCROLLS) then
            if (Crate.IsScrollUnlocked(player, selected.Index)) then
                if (selected.Index == 0) then
                    local flags = UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC;
                    player:UseCard(Card.CARD_FOOL, flags);
                    HoldingActive:Cancel(player);
                    THI.SFXManager:Play(THI.Sounds.SOUND_DIABLO_SCROLL);
                elseif (selected.Index == 1) then
                    if (Crate.CanUseIdentifyScroll(player)) then
                        local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC;
                        player:UseActiveItem ( CollectibleType.COLLECTIBLE_D6, flags, -1)
                        Crate.AddIdentifiedRoom(player);

                        THI.SFXManager:Play(THI.Sounds.SOUND_DIABLO_SCROLL);
                        THI.SFXManager:Play(THI.Sounds.SOUND_DIABLO_IDENTIFY);
                    else
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                    end
                end
            end
        end
    else

        --箱子→箱子（相同位置）：取消选择
        --箱子→箱子（不同位置）：移除源，移除目标，将目标放入源，将源放入目标。选中源位置。
        --箱子→身上：移除源，将源放入目标，取消选择。
        --身上→箱子：移除源，移除目标，将目标放入源，将源放入目标。取消选择。
        --身上→身上：取消选择。

        if (selected.Type == Crate.SelectTypes.DROP) then -- Drop Item.
            
            local data = GetPlayerCrateData(player, true);
            local sourceIndex = holding.Index;
            local sourceList;
            if (holdingFrom == Crate.SelectTypes.CRATE) then 
                sourceList = data.Storage;
            elseif (holdingFrom == Crate.SelectTypes.ITEMS) then
                sourceList = tempData.ItemList; 
            end
            local source = GetItem(sourceList, sourceIndex);
            RemoveItem(sourceList, sourceIndex);

            -- Spawn Item.
            -- 现在会删除道具，而不是丢弃道具。因此将这一行注释。
            -- DropItem(player, source);
            Crate:ReduceItem(player.Position, player);
            SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)

            -- Clear Holding.

            holding.From = -1;
            holding.Index = 0;
            
        else
            if (holdingFrom == Crate.SelectTypes.CRATE) then
                if (selected.Type == Crate.SelectTypes.CRATE) then -- Move inside Crate.

                    local sourceIndex = holding.Index;
                    local destIndex = selected.Index;
                    local selfMove = sourceIndex == destIndex;
                    if (not selfMove) then
                        -- Swap the source and the destination.
                        local data = GetPlayerCrateData(player, true);

                        local sourceTable = data.Storage;
                        local destTable = data.Storage;

                        local source = GetItem(sourceTable, sourceIndex);
                        local destination = GetItem(destTable, destIndex);
                        AddItem(sourceTable, destIndex, source);
                        AddItem(destTable, sourceIndex, destination);
                        if (not destination) then
                            -- Clear Holding.
                            holding.From = -1;
                            holding.Index = 0;
                        else
                            holding.From = selected.Type;
                            holding.Index = sourceIndex;
                        end
                    else
                        -- Clear Holding.
                        holding.From = -1;
                        holding.Index = 0;
                    end

                elseif (selected.Type == Crate.SelectTypes.ITEMS) then -- Take out.
        
                    local data = GetPlayerCrateData(player, true);
                    local sourceList = data.Storage;
                    local sourceIndex = holding.Index;
                    local source = GetItem(sourceList, sourceIndex);
                    if (Crate.CanTakeOut(player, source)) then
                        

                        local destIndex = selected.Index;
                        local destList = tempData.ItemList;
                        local dest = GetItem(destList, destIndex);

                        -- Remove Source.
                        RemoveItem(sourceList, sourceIndex);
                        -- Put Source to Destination.
                        AddItem(destList, destIndex, source);

                        -- Clear Holding.
                        holding.From = -1;
                        holding.Index = 0;
                    else
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                    end

                end
            elseif (holdingFrom == Crate.SelectTypes.ITEMS) then
                if (selected.Type == Crate.SelectTypes.CRATE) then -- Put in.


                    local data = GetPlayerCrateData(player, true);
                    local originDestIndex = selected.Index

                    local sourceIndex = holding.Index;
                    local sourceList = tempData.ItemList;
                    local source = GetItem(sourceList, sourceIndex);

                    if (HasItem(player, source)) then
                        local destIndex = originDestIndex;
                        local destList = data.Storage;
                        local dest = GetItem(destList, destIndex);

                        -- Cannot put in a slot that already has an item.
                        local validSlots = tempData.ValidSlots;
                        if (dest) then
                            -- Find an empty slot.
                            local tries = 0;
                            while (tries <= #validSlots - 1) do
                                for i = 0, 1 do
                                    local offset = tries + 1;
                                    if (i == 0) then
                                        offset = -offset; 
                                    end
                                    destIndex = originDestIndex + offset;
                                    dest = GetItem(destList,destIndex);
                                    if (not dest and Crate.IsCrateSlotExists(player, destIndex)) then
                                        goto endWhile;
                                    end
                                end

                                tries = tries + 1;
                            end
                            ::endWhile::
                        end
                        -- If Destination has enough space.
                        if (not dest and Crate.IsCrateSlotExists(player, destIndex)) then
                            --Remove Source.
                            RemoveItem(sourceList, sourceIndex);

                            -- Put Source to Destination.
                            AddItem(destList, destIndex, source);
                            -- Clear Holding.
                            holding.From = -1;
                            holding.Index = 0;

                        else
                            THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                        end
                    else
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                    end

                elseif (selected.Type == Crate.SelectTypes.ITEMS) then -- Put back.
                    -- Clear Holding.
                    holding.From = -1;
                    holding.Index = 0;
                end
            end
        end
    end
end

local function UIControl(player)
    local controllerIndex = player.ControllerIndex;
    local tempData = GetPlayerTempData(player, false);
    if (tempData) then
            
        local function IsTriggered(action)
            tempData.HoldFrames = tempData.HoldFrames or {};
            if (Input.IsActionPressed(action, controllerIndex)) then
                tempData.HoldFrames[action] = (tempData.HoldFrames[action] or 0) + 1;
                if (tempData.HoldFrames[action] > 30) then
                    return true;
                end
            else
                tempData.HoldFrames[action] = nil;
            end
            if (Input.IsActionTriggered(action, controllerIndex)) then
                return true;
            end
        end
        -- Move Vertical.
        local vertical = 0;
        if (not (Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerIndex) and
            (Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerIndex)))) then
            if (IsTriggered(ButtonAction.ACTION_SHOOTDOWN)) then
                vertical = vertical + 1;
            end
            if (IsTriggered(ButtonAction.ACTION_SHOOTUP)) then
                vertical = vertical - 1;
            end
        end
        -- Move Horizontal.
        local horizontal = 0;
        if (not (Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerIndex) and
            (Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerIndex)))) then
            if (IsTriggered(ButtonAction.ACTION_SHOOTLEFT)) then
                horizontal = horizontal - 1;
            end
            if (IsTriggered(ButtonAction.ACTION_SHOOTRIGHT)) then
                horizontal = horizontal + 1;
            end

        end


        -- Start Control.
        local selected = tempData.Selected;

        local function GetColumn(maxX, height)
            return math.max(0, math.min(maxX, math.floor(selected.Index / height)));
        end
        local function GetRow(maxX, height)
            return selected.Index % height;
        end
        if (selected.Type == Crate.SelectTypes.CLOSE) then
            if (vertical > 0) then
                selected.Type = Crate.SelectTypes.CRATE;
                selected.Index = 0;
            end
        elseif (selected.Type == Crate.SelectTypes.CRATE or selected.Type == Crate.SelectTypes.ITEMS) then
            local crate = selected.Type == Crate.SelectTypes.CRATE;

            local maxIndex;
            local maxX; 
            local height;
            if (crate) then
                maxIndex = Crate.GetCrateSlotMaxIndex(player);
                height = Crate.GetCrateSlotHeight(player);
                maxX = math.floor(maxIndex / height);
            else
                maxIndex = itemsSize;
                maxX = itemsWidth;
                height = itemsHeight
            end
            local row = GetRow(maxX, height);
            local column = GetColumn(maxX, height);
            -- Vertical Move.
            if (vertical > 0) then -- Move Down.
                -- At the bottom.
                if (selected.Index % height == height - 1) then
                    if (crate) then
                        local type = Crate.SelectTypes.ITEMS;
                        local index = 0;
                        if (tempData.Holding.From <= 0) then
                            if (selected.Index == BookOfVirtuesBottomSlot) then
                                type = Crate.SelectTypes.SCROLLS
                                index = 0;
                            elseif (selected.Index == JudasBookBottomSlot) then
                                type = Crate.SelectTypes.SCROLLS
                                index = 1;
                            end
                        end
                        selected.Type = type;
                        selected.Index = index;
                    else
                        selected.Index = column * height;
                    end
                else -- Not at the bottom.
                    selected.Index = selected.Index + 1;
                end
            elseif (vertical < 0) then  -- Move Up.
                -- At the top.
                if (selected.Index % height == 0) then
                    if (crate) then
                        selected.Type = Crate.SelectTypes.CLOSE
                        selected.Index = 0;
                    else
                        selected.Type = Crate.SelectTypes.CRATE
                        selected.Index = 1;
                    end
                else -- Not at the top.
                    selected.Index = selected.Index - 1;
                end
            end
            
            local row = GetRow(maxX, height);
            -- Horizontal Move.
            if (horizontal > 0) then -- Move Right.
                if (crate) then -- Crates.
                    repeat
                        if (selected.Index - height >= maxIndex) then
                            -- At the rightest.
                            selected.Index = row;
                        else
                            selected.Index = selected.Index + height;
                        end
                    until Crate.IsCrateSlotExists(player, selected.Index);
                else -- Items.
                    
                    -- At the rightest.
                    if (selected.Index + height >= maxIndex) then
                        if (tempData.Page < tempData.TotalPages) then
                            selected.Index = row;
                            tempData.Page = tempData.Page + 1;
                        end
                    else
                        selected.Index = selected.Index + height;
                    end
                end
            elseif (horizontal < 0) then  -- Move Left.
                -- Drop Slot.
                if (tempData.Holding.From > 0 and column == 0) then
                    selected.Type = Crate.SelectTypes.DROP;
                    selected.Index = 0;
                else
                    -- Move.
                    if (crate) then -- Crates.
                        repeat
                            -- At the leftest.
                            if (selected.Index - height < 0) then
                                selected.Index = maxX * height + row;
                            else
                                selected.Index = selected.Index - height;
                            end
                        until Crate.IsCrateSlotExists(player, selected.Index);
                    else -- Items.
                        
                        -- At the leftest.
                        if (selected.Index - height < 0) then
                            if (tempData.Page > 1) then
                                selected.Index = (maxX - 1) * height + row;
                                tempData.Page = tempData.Page - 1;
                            end
                        else
                            selected.Index = selected.Index - height;
                        end
                    end
                end
            end
        elseif (selected.Type == Crate.SelectTypes.DROP) then
            if (horizontal > 0 or vertical < 0 ) then
                selected.Type = Crate.SelectTypes.ITEMS
                selected.Index = itemsHeight - 1;
            end
        elseif (selected.Type == Crate.SelectTypes.SCROLLS) then
            if (horizontal ~= 0) then
                local times = 0;
                repeat 
                    selected.Index = (selected.Index + horizontal) % 2;
                    times = times + 1;
                until Crate.IsScrollUnlocked(player,selected.Index) or times > 3;
            end

            if (vertical > 0) then
                selected.Type = Crate.SelectTypes.ITEMS;
                selected.Index = 0;
            elseif (vertical < 0) then
                selected.Type = Crate.SelectTypes.CRATE;
                local index = 0;
                if (selected.Index == 0) then
                    if (Crate.IsCrateSlotExists(player, BookOfVirtuesBottomSlot)) then
                        index = BookOfVirtuesBottomSlot;
                    end
                elseif (selected.Index == 1) then
                    if (Crate.IsCrateSlotExists(player, JudasBookBottomSlot)) then
                        index = JudasBookBottomSlot;
                    end
                end
                selected.Index = index;
            end
        end
    end
end

do 
    local function PostPlayerUpdate(mod, player)
        local tempData = GetPlayerTempData(player,false);
        if (tempData) then
            if (tempData.FlushCountdown) then
                if (tempData.FlushCountdown > 0) then
                    tempData.FlushCountdown = tempData.FlushCountdown - 1;
                else
                    player:FlushQueueItem();
                    tempData.FlushCountdown = nil;
                end
            end
        end

        local hasCrate = player:HasCollectible(Crate.Item);
        local opening = Crate.IsOpening(player);
        if (Game():GetFrameCount() > 1 and (hasCrate or opening)) then
            UpdateCrateSlots(player);
        end
        if (opening) then
            if (tempData) then
                if (tempData.OperateCooldown) then
                    if (tempData.OperateCooldown > 0) then
                        tempData.OperateCooldown = tempData.OperateCooldown - 1;
                    else
                        tempData.OperateCooldown = nil
                    end
                else
                    local playerType = player:GetPlayerType();
                    local action = ButtonAction.ACTION_ITEM;
                    if (playerType == PlayerType.ESAU) then
                        action = ButtonAction.ACTION_PILLCARD;
                    end
                    if (Input.IsActionTriggered(action, player.ControllerIndex)) then
                        OnUse(player, tempData);
                    end
                end
            end


            UIControl(player);

            if (Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
                HoldingActive:Cancel(player);
            end
        end
    end
    Crate:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

    local function PostUseCrate(mod, item, rng, player, flags, slot, varData)
        if (flags & UseFlag.USE_CARBATTERY <= 0) then
            local holding = HoldingActive:GetHoldingItem(player);
            if (holding <= 0) then
                player:FlushQueueItem();
                ClearTempData(player);
                local data = GetPlayerTempData(player, true);
                GetPlayerCrateData(player, true);
                UpdateItemList(player, data);
                HoldingActive:Hold(item,player,  slot);
                data.OperateCooldown = 2;
            end
        end 
    end
    Crate:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseCrate, Crate.Item);

    
    local function PostNewLevel(mod)
        for p ,player in Detection.PlayerPairs() do
            Crate.ClearIdentifiedRooms(player);
        end
    end
    Crate:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

    
    local function InputAction(mod, entity, hook, action)
        if (entity and entity.Type == EntityType.ENTITY_PLAYER) then
            if (action == ButtonAction.ACTION_ITEM and Crate.IsOpening(entity)) then
                if (hook == InputHook.IS_ACTION_TRIGGERED) then
                    return false;
                end
            end
        end
    end
    Crate:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction);

    local function PostRender(mod)
        for p, player in Detection.PlayerPairs() do
            if (Crate.IsOpening(player)) then
                RenderCrate(player);
            end
        end
    end
    Crate:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender);
end

return Crate;