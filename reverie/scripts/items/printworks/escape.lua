local CompareEntity = CuerLib.Entities.CompareEntity;
local Escape = ModItem("Escape", "Escape");

local function GetPlayerData(player ,create)
    return Escape:GetData(player, create, function()
        return {
            MantleCount = 0
        }
    end)
end

function Escape:TriggerEffect(player)
    local effects = player:GetEffects();
    effects:AddCollectibleEffect(Escape.Item);
    -- player:AddCacheFlags(CacheFlag.CACHE_SPEED);
    -- player:EvaluateItems();

    local room = Game():GetRoom();
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor (slot);
        if (door) then
            local canOpen = not door:IsLocked ( ) and not door:IsOpen();
            if (door:IsRoomType (RoomType.ROOM_SECRET) or door:IsRoomType (RoomType.ROOM_SUPERSECRET) or door:IsRoomType (RoomType.ROOM_ULTRASECRET)) then
                canOpen = canOpen and door:IsBusted();
            end
            if (canOpen) then
                door:Open();
                THI.SFXManager:Play(SoundEffect.SOUND_UNLOCK00);
            end
        end
    end
end

local function PostPlayerDamage(mod, tookDamage, amount, flags, source, countdown)
    local player = tookDamage:ToPlayer();
    if (player:HasCollectible(Escape.Item)) then
        Escape:TriggerEffect(player);
    end
end
Escape:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostPlayerDamage, EntityType.ENTITY_PLAYER);

local function PostPlayerUpdate(mod, player)
    if (player:HasCollectible(Escape.Item)) then
        
        local effects = player:GetEffects()
        local mantleCount = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE);
        local data = GetPlayerData(player, false);
        local currentMantleCount = (data and data.MantleCount) or 0;
        if (currentMantleCount ~= mantleCount) then
            if (currentMantleCount > mantleCount) then
                for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 11)) do
                    if (CompareEntity(ent.SpawnerEntity, player)) then
                        Escape:TriggerEffect(player);
                        break;
                    end
                end
            end
            data = GetPlayerData(player, true);
            data.MantleCount = mantleCount;
        end
    end
end
Escape:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

local function EvaluateCache(mod, player, flag)
    if (flag == CacheFlag.CACHE_SPEED) then
        local count = player:GetCollectibleNum(Escape.Item) + player:GetEffects():GetCollectibleEffectNum(Escape.Item);
        player.MoveSpeed = player.MoveSpeed + count * 0.15;
    end
end
Escape:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

return Escape;