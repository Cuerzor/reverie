local Lib = CuerLib;

local HoldingActive = {
}

local function EndHolding(player)
    local playerData = HoldingActive:GetPlayerData(player, true);
    playerData.Item = nil;
    playerData.Slot = nil;
end

function HoldingActive:GetPlayerData(player, init)
    if (init == nil) then
        init = true;
    end
    local playerData = Lib:GetData(player, true);
    if (init) then
        playerData.HoldingActive = playerData.HoldingActive or {}
    end
    return playerData.HoldingActive;
end

function HoldingActive:GetHoldingItem(player)
    local playerData = self:GetPlayerData(player, false);
    return (playerData and playerData.Item) or -1;
end

function HoldingActive:SwitchHolding(id, player, slot)
    local holding = HoldingActive:GetHoldingItem(player);
    if (holding <= 0) then
        HoldingActive:Hold(id, player, slot);
    elseif (holding == id) then
        HoldingActive:Cancel(player)
    end
    return { Discharge = false }
end

function HoldingActive:Hold(id, player, slot)
    local playerData = self:GetPlayerData(player, true);
    playerData.Item = id;
    playerData.Slot = slot;
    player:AnimateCollectible(id, "LiftItem");
    playerData.Lifting = false;
end

function HoldingActive:Cancel(player)
    local playerData = self:GetPlayerData(player, true);
    EndHolding(player);
    player:PlayExtraAnimation("HideItem");
end

function HoldingActive:ReleaseActive(player, item, ...)
    -- Pre Release Active.
    local callbacks = Lib.Callbacks;
    for i, info in pairs(callbacks.Functions.PreReleaseHoldingActive) do
        if (not info.OptionalArg or info.OptionalArg == item) then
            local returned = info.Func(info.Mod, player, item, ...);

            if (returned == false) then
                return false;
            end
        end
    end

    -- Post Release Active Item.
    local discharge = true;
    local remove = false;
    for i, info in pairs(callbacks.Functions.PostReleaseHoldingActive) do
        if (not info.OptionalArg or info.OptionalArg == item) then
            local returned = info.Func(info.Mod, player, item, ...);

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
        if (shooting:Length() > 0.1) then
            HoldingActive:ReleaseActive(player, item, shooting)
        end
    end
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

-- Events.
local function PostPlayerEffect(mod, player)
    local playerData = HoldingActive:GetPlayerData(player, false);

    if (playerData) then
        local spr = player:GetSprite();
        local anim = spr:GetAnimation();
        local overlayAnim = spr:GetOverlayAnimation ( );
        if (HoldingActive:GetHoldingItem(player) > 0) then
            if (player:IsExtraAnimationFinished() or not IsHoldingAnimation(anim)) then
                EndHolding(player);
                return;
            end
            if (overlayAnim == "") then
                playerData.Lifting = true;
            end
            if (playerData.Lifting and overlayAnim ~= "") then
                EndHolding(player);
                playerData.Lifting = false;
                return;
            end
        else
            playerData.Lifting = false;
        end
    end
end

local function InputAction(mod, entity,hook, action)
    if (entity and entity.Type == EntityType.ENTITY_PLAYER) then
        if (HoldingActive:GetHoldingItem(entity) > 0) then
            if (action == ButtonAction.ACTION_DROP and hook == InputHook.IS_ACTION_TRIGGERED) then
                return false;
            end
        end
    end
end

-- local function PreUseItem(mod, item,rng,player,flags,slot,varData)
--     local holding = HoldingActive:GetHoldingItem(player);
--     if (flags & UseFlag.USE_NOANIM <= 0 and holding > 0 and holding ~= item) then
--         HoldingActive:Cancel(player);
--     end
-- end
-- -- local function PostUseItem(mod, item, rng, player, flags, slot, varData)
-- --     local holding = HoldingActive:GetHoldingItem(player);
-- --     if (flags & UseFlag.USE_NOANIM <= 0 and holding > 0 and holding ~= item) then
-- --         EndHolding(player);
-- --     end
-- -- end

-- local function PostUseCard(mod, card, player, flags)
--     if (flags & UseFlag.USE_NOANIM <= 0) then
--         local holding = HoldingActive:GetHoldingItem(player);
--         if (holding > 0) then
--             EndHolding(player);
--         end
--     end
-- end

-- local function PostUsePill(mod, effect, player, flags)
--     if (flags & UseFlag.USE_NOANIM <= 0) then
--         local holding = HoldingActive:GetHoldingItem(player);
--         if (holding > 0) then
--             EndHolding(player);
--         end
--     end
-- end


function HoldingActive:Register(mod)
    -- mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, PreUseItem)
    -- --mod:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseItem)
    -- mod:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard)
    -- mod:AddCallback(ModCallbacks.MC_USE_PILL, PostUsePill)
    mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)
end

function HoldingActive:Unregister(mod)
    -- mod:RemoveCallback(ModCallbacks.MC_PRE_USE_ITEM, PreUseItem)
    -- --mod:RemoveCallback(ModCallbacks.MC_USE_ITEM, PostUseItem)
    -- mod:RemoveCallback(ModCallbacks.MC_USE_CARD, PostUseCard)
    -- mod:RemoveCallback(ModCallbacks.MC_USE_PILL, PostUsePill)
    mod:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)
    mod:RemoveCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)
end


return HoldingActive;