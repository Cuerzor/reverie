local Coin = ModEntity("Nightmare Coin", "NIGHTMARE_COIN");
Coin.SubType = 5810;


local function PostCoinInit(mod, npc)
    if (npc.Variant == Coin.Variant and npc.SubType == Coin.SubType) then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET);
    end
end
Coin:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostCoinInit, Coin.Type);

local function PostCoinUpdate(mod, npc)
    if (npc.Variant == Coin.Variant and npc.SubType == Coin.SubType) then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
        -- if (npc.FrameCount % 3 == 0) then
        --     local Dream = THI.GensouDream;
        --     local trail = Dream.Effects.NightmareTrail;
        --     trail:SpawnTrail(npc);
        -- end
    end
end
Coin:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostCoinUpdate, Coin.Type);


return Coin;