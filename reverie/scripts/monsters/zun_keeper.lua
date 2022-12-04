local Mod = THI;
local Keeper = {
    Type = EntityType.ENTITY_SHOPKEEPER,
    Variant = 3,
}
Keeper.SubType = 58;
local function PostKeeperUpdate(mod, npc)
    if (npc.FrameCount <= 1 and npc.Variant == Keeper.Variant and npc.SubType == Keeper.SubType) then
        local spr = npc:GetSprite();
        spr:Load("gfx/reverie/017.004_special shopkeeper.anm2", true);
        spr:Play("Shopkeeper 1");
    end
end
Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostKeeperUpdate, Keeper.Type);
return Keeper;