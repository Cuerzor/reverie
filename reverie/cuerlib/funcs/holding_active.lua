local Lib = LIB;

local HoldingActive = Lib:NewClass();

local function EndHolding(player)
    local playerData = HoldingActive:GetPlayerData(player, true);
    playerData.Item = nil;
    playerData.Slot = nil;
    playerData.Mimic = false;
end


local function IsHoldingAnimation(anim)
    return anim == "PickupWalkDown" or 
            anim == "PickupWalkUp" or 
            anim == "PickupWalkRight"  or 
            anim == "PickupWalkLeft" or
            anim == "WalkDown" or 
            anim == "WalkUp" or 
            anim == "WalkRight"  or 
            anim == "WalkLeft" or
            anim == "HideItem"
end

function HoldingActive:GetPlayerData(player, init)
    if (init == nil) then
        init = true;
    end
    local playerData = Lib:GetEntityLibData(player, true);
    if (init) then
        playerData.HoldingActive = playerData.HoldingActive or {
            HoldFrame = 0,
            Mimic = false,
            PreMimicCheck = false,
        }
    end
    return playerData.HoldingActive;
end

function HoldingActive:GetHoldingItem(player)
    local playerData = self:GetPlayerData(player, false);
    return (playerData and playerData.Item) or -1;
end


function HoldingActive:ShouldDischarge(player)
    local playerData = self:GetPlayerData(player, false);
    if (playerData) then
        return not playerData.Mimic;
    end
    return true;
end

function HoldingActive:GetHoldingSlot(player)
    local playerData = self:GetPlayerData(player, false);
    return (playerData and playerData.Slot) or -1;
end

function HoldingActive:SwitchHolding(id, player, slot, flags)
    local playerData = self:GetPlayerData(player, false);
    local holding = HoldingActive:GetHoldingItem(player);
    if (holding <= 0) then
        HoldingActive:Hold(id, player, slot, flags);
    elseif (holding == id) then
        HoldingActive:Cancel(player)
    end
    return { Discharge = false }
end

function HoldingActive:Hold(id, player, slot, flags)
    local playerData = self:GetPlayerData(player, true);
    playerData.Item = id;
    playerData.Slot = slot;
    player:AnimateCollectible(id, "LiftItem");
    playerData.Lifting = false;
    playerData.HoldFrame = player.FrameCount;
    if (flags & UseFlag.USE_OWNED <= 0) then
        playerData.Mimic = true;
    else
        playerData.PreMimicCheck = true;
    end
end

function HoldingActive:Cancel(player)
    local playerData = self:GetPlayerData(player, true);
    EndHolding(player);
    player:PlayExtraAnimation("HideItem");
end

function HoldingActive:ReleaseActive(player, item, ...)
    -- Release Active Item.
    local discharge = true;
    local remove = false;

    local callbacks = Isaac.GetCallbacks(Lib.CLCallbacks.CLC_RELEASE_HOLDING_ACTIVE);
    for _, callback in pairs(callbacks) do
        if (callback.Param < 0 or callback.Param == item) then
            local returned = callback.Function(callback.Mod, player, item, ...);

            if (returned) then
                if (returned.Discharge == false) then
                    discharge = false;
                end
                if (returned.Remove) then
                    remove = true;
                end
            end
        end
    end

    -- Discharge Active.
    local playerData = HoldingActive:GetPlayerData(player, true);
    for i = 1, 2 do
        local slot = playerData.Slot;
        if (i == 2) then
            if (slot == ActiveSlot.SLOT_PRIMARY) then
                slot = ActiveSlot.SLOT_SECONDARY;
            end
        end
        if (player:GetActiveItem (slot) == item) then
            if (discharge) then
                player:DischargeActiveItem(slot);
            end
            if (remove) then
                player:RemoveCollectible (item, true, slot, false);
            end
            break;
        end
    end
    EndHolding(player);
    player:PlayExtraAnimation("HideItem");
    return true;
end

function HoldingActive:ReleaseOnShoot(player, item)
    if (HoldingActive:GetHoldingItem(player) == item) then
        local shooting = Lib.Inputs.GetRawShootingVector(player);
        local spr = player:GetSprite();
        if (shooting:Length() > 0.1 and IsHoldingAnimation(spr:GetAnimation())) then
            HoldingActive:ReleaseActive(player, item, shooting)
        end
    end
end

-- Events.
local function PostPlayerEffect(mod, player)
    local playerData = HoldingActive:GetPlayerData(player, false);

    if (playerData) then
        local spr = player:GetSprite();
        local anim = spr:GetAnimation();
        local overlayAnim = spr:GetOverlayAnimation ( );
        local holdingItem = HoldingActive:GetHoldingItem(player);
        if (holdingItem > 0) then
            if (player:IsExtraAnimationFinished()) then
                player:AnimateCollectible(holdingItem, "LiftItem");
            end
            
            if (playerData.Hit) then
                if (not IsHoldingAnimation(anim)) then
                    EndHolding(player);
                end
            end
        end
        playerData.Hit = false;
        playerData.PreMimicCheck = false;
    end
end
HoldingActive:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        local player = tookDamage:ToPlayer();
        if (HoldingActive:GetHoldingItem(player) > 0) then
            local playerData = HoldingActive:GetPlayerData(player, true);
            playerData.Hit = true;
        end
    end
end
HoldingActive:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDamage)


-- local function PostUseItem(mod, item, rng, player, flags, slot, data)
--     if (flags & UseFlag.USE_NOANIM <= 0) then
--         local holdingItem = HoldingActive:GetHoldingItem(player);
--         if (holdingItem > 0 and item ~= holdingItem) then
            -- local spr = player:GetSprite();
            -- local anim = spr:GetAnimation();
            -- local overlayanim = spr:GetOverlayAnimation();
            -- if (spr:GetOverlayFrame() == -1 and string.find(anim, "PickupWalk")) then
            --     EndHolding(player);
            -- elseif (spr:GetOverlayFrame() == 0 and string.find(anim, "Walk") and string.find(overlayanim, "Head")) then
            --     EndHolding(player);
            -- end
--         end
--     end
-- end
-- HoldingActive:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseItem)


local function PostUseCard(mod, card, player, flags)
    if (card == Card.CARD_QUESTIONMARK or card == Card.CARD_WILD) then
        local playerData = HoldingActive:GetPlayerData(player, false);
        if (playerData and playerData.PreMimicCheck) then
            playerData.Mimic = true;
            playerData.PreMimicCheck = false;
        end
    end
end
HoldingActive:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard)



local function PostNewRoom(mod)
    for p, player in Lib.Players.PlayerPairs(true) do
        if (HoldingActive:GetHoldingItem(player) > 0) then
            EndHolding(player);
        end
    end
end
HoldingActive:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

local function InputAction(mod, entity,hook, action)
    if (entity and entity.Type == EntityType.ENTITY_PLAYER) then
        if (HoldingActive:GetHoldingItem(entity) > 0) then
            if (action == ButtonAction.ACTION_DROP and hook == InputHook.IS_ACTION_TRIGGERED) then
                return false;
            end
        end
    end
end
HoldingActive:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)


return HoldingActive;