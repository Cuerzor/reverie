local Pooter = ModEntity("Nightmare Pooter", "NIGHTMARE_POOTER");
Pooter.SubType = 5810;

function Pooter:GetPooterData(pooter, create)
    return Pooter:GetData(pooter, create, function()
        return {
            Velocity = Vector.Zero;
        }
    end)
end

local function PostPooterUpdate(mod, npc)
    if (npc.Variant == Pooter.Variant and npc.SubType == Pooter.SubType) then

        local data = Pooter:GetPooterData(npc, false);
        if (data) then
            npc.Velocity = data.Velocity;
        end

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
Pooter:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostPooterUpdate, Pooter.Type);
return Pooter;