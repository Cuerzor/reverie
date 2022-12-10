local Purist = ModChallenge("Pure Purist", "PURE_PURIST");

local ModifyPoolCooldown = 0;
function Purist:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == Purist.Id) then
            
            ModifyPoolCooldown = 2;
        end
    end
end
Purist:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Purist.PostGameStarted);
function Purist:PostUpdate()
    if (ModifyPoolCooldown > 0) then
        ModifyPoolCooldown = ModifyPoolCooldown - 1;
    end
end
Purist:AddCallback(ModCallbacks.MC_POST_UPDATE, Purist.PostUpdate);

function Purist:PreGetCollectible(pool, decrease, seed, loopCount)
    if (loopCount == 1 and Isaac.GetChallenge() == Purist.Id and Game():GetFrameCount() > 2 and ModifyPoolCooldown <= 0) then
        return THI.Collectibles.PureFury.Item;
    end
end
Purist:AddPriorityCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, CallbackPriority.EARLY, Purist.PreGetCollectible);

function Purist:PreGameExit(ShouldSave)
    ModifyPoolCooldown = 2;
end
Purist:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Purist.PreGameExit);

local function PreEntitySpawn(mod, id, variant, subtype, position, velocity, spawner, seed)
    if (Isaac.GetChallenge() == Purist.Id) then
        if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COLLECTIBLE and subtype ~= THI.Collectibles.PureFury.Item) then
            return {id, variant, THI.Collectibles.PureFury.Item, seed};
        end
    end
end
Purist:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, PreEntitySpawn);

return Purist;