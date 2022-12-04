local Onbashira = ModItem("Onbashira", "ONBASHIRA");

--- func desc
---@param mod ModReference
---@param item integer
---@param rng RNG
---@param player EntityPlayer
---@param flags integer
---@param slot integer
---@param varData integer
local function PostUseOnbashira(mod, item, rng, player, flags, slot, varData)
    local Entity = THI.Effects.Onbashira;
    local onbashira = Isaac.Spawn(Entity.Type, Entity.Variant, 0, player.Position, Vector.Zero, player);
    return {ShowAnim = true};
end
Onbashira:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseOnbashira, Onbashira.Item);

return Onbashira;