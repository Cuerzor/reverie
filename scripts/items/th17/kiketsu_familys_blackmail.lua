local Blackmail = ModItem("Kiketsu Family's Blackmail", "KIKETSU_BLACKMAIL");

do
    local function PostPlayerEffect(mod, player)
        if (player:HasCollectible(Blackmail.Item)) then
            if (player:IsFrame(7, 0)) then
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    if (ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        local time = 8;
                        if (ent:IsBoss()) then
                            time = 150
                        end
                        local distance = ent.Position:Distance(player.Position);
                        if (distance < 120) then
                            ent:AddFear(EntityRef(player), time)
                        elseif (distance < 240) then
                            ent:AddCharmed(EntityRef(player), time)
                        end
                    end
                end
            end
        end
    end
    Blackmail:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);

    
    -- local function PreNPCCollision(mod, npc, other, low)
    --     local player = other:ToPlayer();
    --     if (player) then
    --         if (player:HasCollectible(Blackmail.Item) and (npc:HasEntityFlags(EntityFlag.FLAG_FEAR) or npc:HasEntityFlags(EntityFlag.FLAG_CHARM))) then
    --             return false;
    --         end
    --     end
    -- end
    -- Blackmail:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNPCCollision);
end

return Blackmail;