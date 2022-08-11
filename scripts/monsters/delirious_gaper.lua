local Gaper = ModEntity("Doremy Delirious Gaper", "DELIRIOUS_GAPER");
Gaper.SubType = 5810;
local function PostGaperInit(mod, npc)
    if (npc.Variant == Gaper.Variant and npc.SubType == Gaper.SubType) then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET);
    end
end
Gaper:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostGaperInit, Gaper.Type);
return Gaper;