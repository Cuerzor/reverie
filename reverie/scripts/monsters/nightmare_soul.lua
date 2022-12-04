local Soul = ModEntity("Nightmare Soul", "NIGHTMARE_SOUL");
Soul.SubType = 0;

local function PostSoulInit(mod, npc)
    if (npc.Variant == Soul.Variant) then
        npc:GetSprite():Play("WalkDown");
    end
end
Soul:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostSoulInit, Soul.Type);


local function PostSoulUpdate(mod, npc)
    if (npc.Variant == Soul.Variant) then
        npc.Velocity = npc.Velocity + Vector(0, -0.1);
        if (npc:CollidesWithGrid()) then
            npc:Kill();
        end
        if (npc.FrameCount % 3 == 0) then
            local Dream = THI.GensouDream;
            local trail = Dream.Effects.NightmareTrail;
            trail:SpawnTrail(npc);
        end
    end
end
Soul:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostSoulUpdate, Soul.Type);

return Soul;