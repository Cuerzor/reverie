local Detection = CuerLib.Detection;
local Collectibles = CuerLib.Collectibles;
local CompareEntity = Detection.CompareEntity;
local FetusBlood = ModItem("Fetus Blood", "FetusBlood");

local function EvaluateBoneies()
    local game = THI.Game;
    local BloodBony = THI.Monsters.BloodBony;
    local players = 0;
    for p, player in Detection.PlayerPairs() do
        if (player:HasCollectible(FetusBlood.Item)) then
            players = players + 1;
        end
    end
    local limit = THI.Game:GetLevel():GetStage() * players;
    local bonies = Isaac.FindByType(BloodBony.Type, BloodBony.Variant, BloodBony.SubTypes.TEMPORARY);

    -- Remove Blood Boneies that out of limit.
    local count = 0;
    for i = #bonies, 1, -1 do
        local ent = bonies[i];
        if (ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            if (count < limit) then
                count = count + 1;
            else
                ent:Kill();
            end
        end
    end
end

function FetusBlood:PostUpdate()
    local game = THI.Game;
    if (game:GetFrameCount() % 10 == 0) then
        EvaluateBoneies()
    end
end
FetusBlood:AddCallback(ModCallbacks.MC_POST_UPDATE, FetusBlood.PostUpdate);



function FetusBlood:UseBlood(item, rng, player, flags, slot, varData)
    local BloodBony = THI.Monsters.BloodBony;
    local bony = BloodBony:SpawnBony(BloodBony.Type, BloodBony.Variant, BloodBony.SubTypes.TEMPORARY, player.Position, player);
    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);

    -- Set Limit.
    EvaluateBoneies();

    
    return {ShowAnim = true};
end
FetusBlood:AddCallback(ModCallbacks.MC_USE_ITEM, FetusBlood.UseBlood, FetusBlood.Item);

return FetusBlood;