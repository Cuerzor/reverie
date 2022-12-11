local Collectibles = CuerLib.Collectibles
local Stats = CuerLib.Stats;

local VampireTooth = ModItem("Tooth of Vampire", "VampireTooth");

function VampireTooth:onUseSun(card, player, flags)
    if (player:HasCollectible(VampireTooth.Item)) then
        local hearts = player:GetHearts();
        for i=1,hearts do
            player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | 
            DamageFlag.DAMAGE_NO_MODIFIERS | 
            DamageFlag.DAMAGE_NO_PENALTIES | 
            DamageFlag.DAMAGE_INVINCIBLE | 
            DamageFlag.DAMAGE_NOKILL, EntityRef(player), 0)
            player:ResetDamageCooldown()
        end
    end
end

function VampireTooth:onUseMoon(card, player, flags)
    if (player:HasCollectible(VampireTooth.Item)) then
        local level = THI.Game:GetLevel();
        local secretIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, RNG(), true);
        THI.Game:StartRoomTransition(secretIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
    end
end

function VampireTooth:onEntityDeath(npc)
    if (Collectibles.IsAnyHasCollectible(VampireTooth.Item)) then
        local rng = npc:GetDropRNG();
        local value = rng:RandomInt(1000);
        local chance = 50;
        if (THI.IsLunatic()) then
            chance = 25;
        end
        if (value < chance) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, npc.Position, Vector(0,0), npc);
        end
    end
end

function VampireTooth:onEvaluateCache(player, flag)
    if (player:HasCollectible(VampireTooth.Item)) then
        local count = player:GetCollectibleNum(VampireTooth.Item);
        if (flag == CacheFlag.CACHE_FLYING) then
            player.CanFly = true;
        end
        if (flag == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + count * 2;
        end
        if (flag == CacheFlag.CACHE_DAMAGE) then
            --player.Damage = player.Damage + count * 1;
            Stats:AddDamageUp(player, count * 1)
        end
    end
end

VampireTooth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, VampireTooth.onEvaluateCache);
VampireTooth:AddCallback(ModCallbacks.MC_USE_CARD, VampireTooth.onUseSun, Card.CARD_SUN);
VampireTooth:AddCallback(ModCallbacks.MC_USE_CARD, VampireTooth.onUseMoon, Card.CARD_MOON);
VampireTooth:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, VampireTooth.onEntityDeath);

return VampireTooth;
