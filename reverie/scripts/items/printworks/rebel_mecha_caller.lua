local Caller = ModItem("Rebel Mecha Caller", "REBEL_MECHA_CALLER");

local function PostUseCaller(mod, item , rng,player , flags, slot, varData)
    local Idle = THI.Pickups.RebechaIdle;

    local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true);
    local pickup = Isaac.Spawn(Idle.Type, Idle.Variant, 0, pos, Vector.Zero, player);
    pickup:GetSprite():Play("Fall");
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
    return {ShowAnim = true}
end
Caller:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseCaller, Caller.Item);

return Caller;