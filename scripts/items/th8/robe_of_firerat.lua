local Math = CuerLib.Math;
local RobeOfFirerat = ModItem("Robe of Firerat", "RobeOfFirerat");
RobeOfFirerat.rng = RNG();

local function IsFire(entity)
    return entity.Type == EntityType.ENTITY_FIREPLACE or
    (entity.Type == EntityType.ENTITY_EFFECT and (
        entity.Variant == EffectVariant.HOT_BOMB_FIRE or
        entity.Variant == EffectVariant.BLUE_FLAME or
        entity.Variant == EffectVariant.RED_CANDLE_FLAME
    ));
end

function RobeOfFirerat.MakeFire(tear)
    local spawner = tear.SpawnerEntity;

    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, tear.Position, tear.Velocity, spawner):ToEffect();
                        
    fire.CollisionDamage = tear.CollisionDamage * 4;
    fire.Timeout = 100;
    -- tear Scale.
    fire.Scale = tear.Scale;
    fire:SetColor(Color(0,0,0,0,0,0,0), 1, 0, false, false);
    tear:Remove();
end

-- function RobeOfFirerat:PostTearUpdate(tear)
--     local spawner = tear.SpawnerEntity;
--     local player;
--     if (spawner) then
--         player = spawner:ToPlayer();
--     end

--     if (player and player:HasCollectible(RobeOfFirerat.Item)) then
--         for _, ent in pairs(Isaac.FindByType(1000)) do
--             if (IsFire(ent)) then
--                 if (tear.Position:Distance(ent.Position) <= ent.Size + tear.Size) then
--                     RobeOfFirerat.MakeFire(tear);
--                     return;
--                 end
--             end
--         end
--     end
-- end
-- RobeOfFirerat:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, RobeOfFirerat.PostTearUpdate);

function RobeOfFirerat:PostUpdate()
    if (THI.Game:GetFrameCount() % 2 == 0) then
        local flames = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME);
        RobeOfFirerat.CanMakeFire = #flames < 64;
    end
end
RobeOfFirerat:AddCallback(ModCallbacks.MC_POST_UPDATE, RobeOfFirerat.PostUpdate);


function RobeOfFirerat:PostEffectUpdate(effect)
    if (THI.Game:GetFrameCount() % 2 == 0 and RobeOfFirerat.CanMakeFire) then
        if (IsFire(effect)) then
            for _, ent in pairs(Isaac.FindInRadius(effect.Position, effect.Scale * 24, EntityPartition.TEAR)) do
                if (ent:Exists()) then
                    local spawner = ent.SpawnerEntity;
                    local player;
                    if (spawner) then
                        player = spawner:ToPlayer();
                    end
                    if (player and player:HasCollectible(RobeOfFirerat.Item)) then
                        local tear = ent:ToTear();
                        if (tear) then
                            RobeOfFirerat.MakeFire(tear);
                        end
                        return;
                    end
                end
            end
        end
    end
end
RobeOfFirerat:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RobeOfFirerat.PostEffectUpdate);

function RobeOfFirerat:PreTearCollision(tear, other, low)
    if (THI.Game:GetFrameCount() % 2 == 0 and RobeOfFirerat.CanMakeFire) then
        local spawner = tear.SpawnerEntity;
        local player;
        if (spawner) then
            player = spawner:ToPlayer();
        end
        if (player and player:HasCollectible(RobeOfFirerat.Item)) then
            if (IsFire(other)) then
                RobeOfFirerat.MakeFire(tear);
                return false;
            end
        end
    end
end
RobeOfFirerat:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, RobeOfFirerat.PreTearCollision);

function RobeOfFirerat:PrePlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:HasCollectible(RobeOfFirerat.Item)) then
        if (flags & DamageFlag.DAMAGE_FIRE > 0) then
            return false;
        end
    end
end
RobeOfFirerat:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, RobeOfFirerat.PrePlayerTakeDamage, EntityType.ENTITY_PLAYER, 255);

function RobeOfFirerat:PreFireplaceCollision(fireplace, other, low)
    if (fireplace.Variant ~= 4) then
        -- If is not white fire.
        local player = other:ToPlayer();
        if (player) then
            if (player:HasCollectible(RobeOfFirerat.Item)) then
                return false;
            end
        end
    end
end
RobeOfFirerat:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, RobeOfFirerat.PreFireplaceCollision, EntityType.ENTITY_FIREPLACE);


function RobeOfFirerat:onEvaluateCache(player, flag)

    if (flag == CacheFlag.CACHE_FAMILIARS) then 
        local Familiar = THI.Familiars.RobeFire;
        local item = Isaac.GetItemConfig():GetCollectible(RobeOfFirerat.Item);
        
        local count = player:GetCollectibleNum(RobeOfFirerat.Item) + player:GetEffects():GetCollectibleEffectNum(RobeOfFirerat.Item);
        player:CheckFamiliar(Familiar.Variant, count, RobeOfFirerat.rng, item);
    end
end
RobeOfFirerat:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RobeOfFirerat.onEvaluateCache);

return RobeOfFirerat;