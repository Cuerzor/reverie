local Players = CuerLib.Players;
local Players = CuerLib.Players;
local Pill = ModPill("Pill of Ultramarine Orb", "ULTRAMARINE_ORB_PILL");

local function GetPlayerTempData(player, create)
    return Pill:GetTempData(player, create, function ()
        return {
            Rewinded = false,
            ShouldRemovePill = false,
            ShouldDischargePlacebo = true,
            PlaceboCharges = 0,
            HasEffect = false,
        }
    end)
end

function Pill:Trigger(player)
    
    local useFlags = 0;
    player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, useFlags);

    local data = GetPlayerTempData(player, true);
    data.Rewinded = true;
end

local StopOutput = false;
local function PostUsePill(mod, pilleffect, player, flags)
    StopOutput = true;
    local itemPool = Game():GetItemPool();
    local data = GetPlayerTempData(player, true);
    data.HasEffect = true;

    local remove = true;
    if (flags & UseFlag.USE_MIMIC > 0) then
        remove = false;
    else
        local pillColor = player:GetPill(0);
        local pillEffect = itemPool:GetPillEffect(pillColor, player);
        if (pillEffect == Pill.ID) then
            if (pillColor & PillColor.PILL_GIANT_FLAG > 0) then
                remove = false;
            end
        end
    end
    data.ShouldRemovePill = remove;

    player:AnimateHappy();

    
end
Pill:AddCallback(ModCallbacks.MC_USE_PILL, PostUsePill, Pill.ID);


local function PostUsePlacebo(mod, item ,rng, player, flags, slot, varData)
    
    local itemPool = Game():GetItemPool();
    local pillColor = player:GetPill(0);
    local pillEffect = itemPool:GetPillEffect(pillColor, player);
    if (pillEffect == Pill.ID) then
        local data = GetPlayerTempData(player, true);
        data.ShouldDischargePlacebo = true;
        if (pillColor & PillColor.PILL_GIANT_FLAG > 0) then
            data.PlaceboCharges = math.max(0, player:GetActiveCharge(slot) + player:GetBatteryCharge(slot));
        else
            data.PlaceboCharges = math.max(0, player:GetBatteryCharge(slot));
        end
    end 
end
Pill:AddCallback(ModCallbacks.MC_USE_ITEM, PostUsePlacebo, CollectibleType.COLLECTIBLE_PLACEBO);

local function PostTakeDamage(mod, ent, amount, flags, source, countdown)
    local player = ent:ToPlayer();
    local data = GetPlayerTempData(player, false);
    if (data and data.HasEffect) then
        Pill:Trigger(player)
    end
end
Pill:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostTakeDamage, EntityType.ENTITY_PLAYER);

local function PostNewRoom(mod)
    for p, player in Players.PlayerPairs() do
        local data = GetPlayerTempData(player, false);
        if (data) then
            if (data.Rewinded) then
                local itemPool = Game():GetItemPool();
                if (data.ShouldRemovePill) then
                    for slot = 0, 1 do
                        local pillColor = player:GetPill(slot);
                        if (pillColor & PillColor.PILL_GIANT_FLAG <= 0) then
                            local pillEffect = itemPool:GetPillEffect(pillColor, player);
                            if (pillEffect == Pill.ID) then
                                Players.RemoveCardPill(player, slot)
                                break;
                            end
                        end
                    end
                    data.ShouldRemovePill = false;
                end

                if (data.ShouldDischargePlacebo) then
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_PLACEBO)) then
                        player:RemoveCollectible(CollectibleType.COLLECTIBLE_PLACEBO, false, ActiveSlot.SLOT_PRIMARY);
                        player:AddCollectible (CollectibleType.COLLECTIBLE_PLACEBO, data.PlaceboCharges, false, ActiveSlot.SLOT_PRIMARY, 3)
                    end
                    data.ShouldDischargePlacebo = false;
                end

                for color = 1, PillColor.NUM_STANDARD_PILLS - 1 do
                    local pillEffect = itemPool:GetPillEffect(color, player);
                    if (pillEffect == Pill.ID) then
                        itemPool:IdentifyPill (color);
                        break;
                    end
                end
                data.Rewinded = false;
            end
            -- Reset Effects.
            data.Rewinded = false;
            data.ShouldRemovePill = false;
            data.ShouldDischargePlacebo = true;
            data.PlaceboCharges = 0;
            data.HasEffect = false;
        end
    end
end
Pill:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

THI:AddPillAnnouncer(Pill.ID, THI.Sounds.SOUND_PILL_OF_ULTRAMARINE_ORB, THI.Sounds.SOUND_MEGA_PILL_OF_ULTRAMARINE_ORB, 15);

return Pill;