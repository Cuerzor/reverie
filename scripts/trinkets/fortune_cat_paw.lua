local Detection = CuerLib.Detection;
local EntityExists = Detection.EntityExists;
local FortuneCatPaw = ModTrinket("Fortune Cat Paw", "FortuneCatPaw");

local NormalChance = 25;
local dropRNG = RNG();

function FortuneCatPaw:PostEntityKill(entity)
    local npc = entity:ToNPC();
    if (npc) then
        
        local isBoss = npc:IsBoss() and not EntityExists(npc.ParentNPC) and not EntityExists(npc.ChildNPC);
        local chance = NormalChance;
        if (isBoss) then
            chance = 100;
            if (THI.IsLunatic()) then
                chance = 60;
            end
        end
        if (not npc:HasEntityFlags(EntityFlag.FLAG_NO_REWARD) and npc.DropSeed % 100 < chance) then
            local multiplier = 0;
            local game = THI.Game;
            for p, player in Detection.PlayerPairs() do
                multiplier = multiplier + player:GetTrinketMultiplier(FortuneCatPaw.Trinket);
            end

            if (multiplier > 0) then
                local times = multiplier;
                local timeout = 60;
                if (isBoss) then
                    times = times * 3;
                    timeout = 120;
                end
                for i = 1, times do
                    local pos = npc.Position;
                    local vel = RandomVector() * dropRNG:RandomFloat();
                    local new = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, vel, npc):ToPickup();
                    new.Timeout = timeout;
                end
            end
        end
    end
end
FortuneCatPaw:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, FortuneCatPaw.PostEntityKill);

return FortuneCatPaw;