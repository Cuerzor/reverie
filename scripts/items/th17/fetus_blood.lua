local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local FetusBlood = ModItem("Fetus Blood", "FetusBlood");

local function EvaluateBoneies()
    local game = THI.Game;
    local BloodBoney = THI.Monsters.BloodBoney;
    local players = 0;
    for p, player in Detection.PlayerPairs() do
        if (player:HasCollectible(FetusBlood.Item)) then
            players = players + 1;
        end
    end
    local limit = THI.Game:GetLevel():GetStage() * players;
    local boneies = Isaac.FindByType(BloodBoney.Type, BloodBoney.Variant);

    -- Remove Blood Boneies that out of limit.
    local count = 0;
    for i = #boneies, 1, -1 do
        local ent = boneies[i];
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
    local BloodBoney = THI.Monsters.BloodBoney;
    local bony = Isaac.Spawn(BloodBoney.Type, BloodBoney.Variant, 0, player.Position, Vector.Zero, player);
    bony.Parent = player;
    bony:AddCharmed(EntityRef(player), -1);
    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);

    -- Make Boney Immune to Spikes.
    bony:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_SPIKE_DAMAGE);
    -- Set Limit.
    EvaluateBoneies();

    
    return {ShowAnim = true};
end
FetusBlood:AddCallback(ModCallbacks.MC_USE_ITEM, FetusBlood.UseBlood, FetusBlood.Item);

return FetusBlood;