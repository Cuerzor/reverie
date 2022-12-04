local Bomb = ModItem("Lightbombs", "LIGHTBOMBS")

Bomb.ExcludedFlags = {
    TearFlags.TEAR_BRIMSTONE_BOMB
}

function Bomb:HasLightFlag(bomb)
    return bomb:HasTearFlags (TearFlags.TEAR_LIGHT_FROM_HEAVEN);
end

function Bomb:AddLightFlag(bomb)
    bomb:AddTearFlags (TearFlags.TEAR_LIGHT_FROM_HEAVEN);
end

function Bomb:ApplyLightCostume(bomb)

    for i, flag in pairs(self.ExcludedFlags) do
        if (bomb:HasTearFlags(flag)) then
            return;
        end
    end

    local spr = bomb:GetSprite();
    local filename = spr:GetFilename();
    local size = 2;
    for i = 0, 3 do
        if (string.sub( filename, -6) == i..".anm2") then
            size = i;
            break;
        end
    end

    local suffix = "";
    if (bomb:HasTearFlags(TearFlags.TEAR_BURN)) then
        suffix = "_hot";
    end

    spr:Load("gfx/reverie/items/pick ups/bombs/light"..suffix..size..".anm2", true);
    spr:Play("Pulse", true)
end

function Bomb:SpawnLightBeams(position, player, scale)
    scale = scale or 1;
    for i = 1, 10 do
        local angle = i * 36;
        local pos = position + Vector.FromAngle(angle) * 80 * scale;
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, pos, Vector.Zero, player);
        
            effect.SpriteScale = Vector(scale,1);

        if (player) then
            effect.Parent = player; 
            effect.CollisionDamage = 20 * scale + player.Damage
        end
    end
end

do
    -- local function PostBombInit(mod, bomb)
    --     local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer();
    --     if (player) then
    --         if (player:HasCollectible(Bomb.Item)) then
    --             Bomb:AddLightFlag(bomb);
    --         end
    --     end
    -- end
    --Bomb:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, PostBombInit)

    local function PostBombUpdate(mod, bomb)
        if (bomb.FrameCount < 2 and bomb.Variant ~= BombVariant.BOMB_THROWABLE) then
            local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer();
            if (player and player:HasCollectible(Bomb.Item)) then
                local canLight = true;
                if (bomb.IsFetus) then
                    local chance = 11 + player.Luck * 3;
                    canLight = bomb.InitSeed % 10000 < chance * 100;
                end
                if (canLight) then
                    Bomb:AddLightFlag(bomb);
                end
            end
        end

        if (Bomb:HasLightFlag(bomb)) then
            local spr = bomb:GetSprite();
            if (bomb:IsDead()) then
                local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer();
                Bomb:SpawnLightBeams(bomb.Position, player, bomb.RadiusMultiplier);
            end
        end
    end
    Bomb:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, PostBombUpdate)
end

-- Interactions.
do 
    local function PostExplosionInit(mod, effect)
        -- BBF, Bob's Brain, War locust.
        local spawner = effect.SpawnerEntity;
        if (spawner and spawner.Type == EntityType.ENTITY_FAMILIAR) then
            
            local familiar = spawner:ToFamiliar();
            local isBrain = spawner.Variant == FamiliarVariant.BOBS_BRAIN
            local isBBF = spawner.Variant == FamiliarVariant.BBF;
            local isWarLocust = spawner.Variant == FamiliarVariant.BLUE_FLY and spawner.SubType == LocustSubtypes.LOCUST_OF_WRATH;
            if (isBrain or isBBF or isWarLocust) then
                local player = familiar.Player;
                if (player and player:HasCollectible(Bomb.Item)) then
                    local scale = 1;
                    if (isWarLocust) then
                        scale = 0.5
                    end
                    Bomb:SpawnLightBeams(familiar.Position, player, scale);
                end
            end
        end
    end
    Bomb:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostExplosionInit, EffectVariant.BOMB_EXPLOSION);

    -- Epic fetus.
    local function PostEffectUpdate(mod, effect)
        
        if (effect.Timeout == 1) then
            
            local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer();
            if (player and player:HasCollectible(Bomb.Item)) then
                
                local chance = 11 + player.Luck * 3;
                local canLight = effect.InitSeed % 10000 < chance * 100;
                if (canLight) then
                    Bomb:SpawnLightBeams(effect.Position, player);
                end
            end
        end
    end
    Bomb:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, EffectVariant.ROCKET);

    
    -- Kamikaze.
    local function PostUseKamikaze(mod, item, rng, player, flags, slot, varData)
        if (player:HasCollectible(Bomb.Item)) then
            
            Bomb:SpawnLightBeams(player.Position, player);
        end
    end
    Bomb:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE);
end

return Bomb;