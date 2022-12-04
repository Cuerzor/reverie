local NightmareSpider = ModEntity("Nightmare Spider", "NIGHTMARE_SPIDER");
NightmareSpider.SubType = 5810;


local function PostSpiderUpdate(mod, npc)
    if (npc.Variant == NightmareSpider.Variant and npc.SubType == NightmareSpider.SubType) then
        if (npc.FrameCount % 3 == 0) then
            local Dream = THI.GensouDream;
            local trail = Dream.Effects.NightmareTrail;
            trail:SpawnTrail(npc);
        end
    end
end
NightmareSpider:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostSpiderUpdate, NightmareSpider.Type);


return NightmareSpider;