local Mod = THI;
local Machines = {};

-- Code ideas from Fiend Folio.
function Mod:OnSlotTouch(func, variant)
    local function callback(_, player)
        local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, variant);
        for _, slot in ipairs(slots) do
            local slotPos = slot.Position;
            local playerPos = player.Position;
            local sizeMulti = slot.SizeMulti;
            if (sizeMulti.X ~= 1 or sizeMulti.Y ~= 1) then
                if ((math.abs(slotPos.X-playerPos.X) <= math.abs(slot.Size * sizeMulti.X + player.Size)) and 
                    (math.abs(slotPos.Y-playerPos.Y) <= math.abs(slot.Size * sizeMulti.Y + player.Size))) then
                    func(player, slot)
                end
            else
                if (slotPos:DistanceSquared(playerPos) <= (slot.Size + player.Size) ^ 2) then
                    func(player, slot)
                end
            end
        end
    end
	self:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, callback);
end
function Mod:RemoveRecentRewards(pos)
    for _, pickup in ipairs(Isaac.FindByType(5, -1, -1)) do
        if pickup.FrameCount <= 1 and pickup.SpawnerType == 0
        and pickup.Position:DistanceSquared(pos) <= 400 then
            pickup:Remove()
        end
    end

    for _, trollbomb in ipairs(Isaac.FindByType(4, -1, -1)) do
        if (trollbomb.Variant == 3 or trollbomb.Variant == 4)
        and trollbomb.FrameCount <= 1 and trollbomb.SpawnerType == 0
        and trollbomb.Position:DistanceSquared(pos) <= 400 then
            trollbomb:Remove()
        end
    end
end

return Machines;