local HoldingActive = CuerLib.HoldingActive;
local Screen = CuerLib.Screen;
local CompareEntity = CuerLib.Entities.CompareEntity;
local Actives = CuerLib.Actives;
local ItemPools = CuerLib.ItemPools;
local GamblingD6 = ModItem("Gambling D6", "GAMBLING_D6");

local ChoiceSprite = Sprite();
ChoiceSprite:Load("gfx/reverie/ui/gambling_d6.anm2", true);

local FrameSprite = Sprite();
FrameSprite:Load("gfx/reverie/ui/select_frame.anm2", true);
FrameSprite:SetFrame("Frame", 0);

local function GetPlayerTempData(player,init)
    return GamblingD6:GetTempData(player, init, function()
        return {
            Choice = 0,
            Owned = false
        }
    end)
end

local function GetPickupTempData(pickup,init)
    return GamblingD6:GetTempData(pickup, init, function()
        return {
            Disappearing = false;
        }
    end)
end
    
    
function GamblingD6:GetChoice(player)
    local data = GetPlayerTempData(player,false);
    return (data and data.Choice) or 0;
end
function GamblingD6:ClearChoice(player)
    local data = GetPlayerTempData(player,true);
    data.Choice = 0;
end


function GamblingD6:SetPickupDisappearing(pickup, value)
    local data = GetPickupTempData(pickup,true);
    data.Disappearing = true;
end
function GamblingD6:IsPickupDisappearing(pickup)
    local data = GetPickupTempData(pickup,false);
    return (data and data.Disappearing);
end

function GamblingD6:Use(player, slot)
    local choice = GamblingD6:GetChoice(player);
    if (choice == 0) then
        HoldingActive:Cancel(player);
    else
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            if (ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and ent.SubType > 0) then
                local pickup = ent:ToPickup();
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);

                local oldId = ent.SubType;

                local game = Game();
                local room = game:GetRoom();
                local pool = game:GetItemPool();
                local poolType = ItemPools:GetRoomPool(ent.InitSeed);
                local newItem = pool:GetCollectible(poolType, true, ent.InitSeed);

                local wrong = false;
                if (choice == -1)then
                    wrong = newItem >= oldId;
                else
                    wrong = newItem <= oldId;
                end

                -- Book of Virtues.
                if (wrong) then
                    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, GamblingD6.Item)) do
                        if (CompareEntity(wisp:ToFamiliar().Player, player)) then
                            wrong = false;
                            wisp:Kill();
                            break;
                        end
                    end
                elseif (Actives:CanSpawnWisp(player, flags)) then
                    player:AddWisp(GamblingD6.Item, ent.Position);
                end

                if (wrong)then
                    pickup:Morph(pickup.Type, pickup.Variant, newItem, true, false, true);
                    pickup.Timeout = 30;
                    pickup.Wait = 60;
                    GamblingD6:SetPickupDisappearing(pickup, true);
                else
                    pickup:Morph(pickup.Type, pickup.Variant, newItem, true);
                    pickup.Touched = false;
                end
            end
        end
        HoldingActive:Cancel(player);
        return true;
    end
    return false;
end

local function UseGamblingD6(mod, item, rng, player, flags, slot, vardata)
    if (flags & UseFlag.USE_CARBATTERY > 0) then
        return {ShowAnim = false, Discharge = false;}
    end

    local holdingItem = HoldingActive:GetHoldingItem(player);
    if (holdingItem <= 0) then
        GamblingD6:ClearChoice(player);
        HoldingActive:Hold(GamblingD6.Item, player, slot, flags);
    elseif (holdingItem == GamblingD6.Item) then
        local shouldDischarge = HoldingActive:ShouldDischarge(player);
        local discharge = GamblingD6:Use(player, slot);
        return {ShowAnim = discharge, Discharge = shouldDischarge and discharge}
    end
    return {ShowAnim = false, Discharge = false;}
end
GamblingD6:AddCallback(ModCallbacks.MC_USE_ITEM, UseGamblingD6, GamblingD6.Item);


local function PostPickupRemove(mod, pickup)
    if (GamblingD6:IsPickupDisappearing(pickup)) then
        
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup);
        SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
    end
end
GamblingD6:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostPickupRemove, EntityType.ENTITY_PICKUP);


local renderOffset = Vector(0, -60);
local leftOffset = Vector(-40, 0);
local rightOffset = Vector(40, 0);

local function PostPlayerRender(mod, player, offset)
    local holdingItem = HoldingActive:GetHoldingItem(player);
    if (holdingItem == GamblingD6.Item) then
        local game = Game();
        local room = game:GetRoom()
        if (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
            local playerData = GetPlayerTempData(player, false)
            local playerPos = Screen.GetEntityRenderPosition(player);
            local centerPos = playerPos + renderOffset;
            local leftPos = centerPos + leftOffset;
            local rightPos = centerPos + rightOffset;

            -- Render Choices.

            ChoiceSprite:SetFrame("Choice", 0)
            ChoiceSprite:Render(leftPos, Vector.Zero, Vector.Zero);
            
            ChoiceSprite:SetFrame("Choice", 1)
            ChoiceSprite:Render(centerPos, Vector.Zero, Vector.Zero);
            
            ChoiceSprite:SetFrame("Choice", 2)
            ChoiceSprite:Render(rightPos, Vector.Zero, Vector.Zero);

            local framePos = centerPos;
            local choice = GamblingD6:GetChoice(player);
            if (choice == -1) then
                framePos = leftPos;
            elseif (choice == 1) then
                framePos = rightPos;
            end
            FrameSprite:Render(framePos, Vector.Zero, Vector.Zero);
        end
    end
end
GamblingD6:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, PostPlayerRender);


local function PostPlayerUpdate(mod, player)
    local holdingItem = HoldingActive:GetHoldingItem(player);
    if (holdingItem == GamblingD6.Item) then
        local playerData = GetPlayerTempData(player, true);
        if (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)) then
            playerData.Choice = playerData.Choice - 1;
            playerData.Choice = math.max(playerData.Choice, -1);
        end
        if (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)) then
            playerData.Choice = playerData.Choice + 1;
            playerData.Choice = math.min(playerData.Choice, 1);
        end
        if (Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) or not player:HasCollectible(GamblingD6.Item, true)) then
            HoldingActive:Cancel(player);
            player:AnimateCollectible(GamblingD6.Item, "HideItem");
        end

        local triggered, slot = Actives:IsActiveItemTriggered(player, GamblingD6.Item);
        if (triggered) then
            if (not Actives:IsChargeFull(player, slot)) then
                if (GamblingD6:Use(player, slot)) then
                    player:AnimateCollectible(GamblingD6.Item, "UseItem")
                end
            end
        end
    end
end
GamblingD6:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);


return GamblingD6;