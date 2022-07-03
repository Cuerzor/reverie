local Tears = CuerLib.Tears;
local CompareEntity = CuerLib.Detection.CompareEntity;
local Thunder = ModItem("Holy Thunder", "HOLY_THUNDER");

Tears:RegisterModTearFlag("ReverieHolyThunder");
local HolyThunderFlag = Tears.TearFlags.ReverieHolyThunder;

local function GetTearTempData(tear, create)
    return Thunder:GetTempData(tear, create, function()
        return {
            HitEnemies = {},
            HitThisFrame = false
        }
    end)
end

function Thunder:TearHasThunder(tear)
    local flags = Tears.GetModTearFlags(tear, false)
    if (flags) then
        return flags:Has(HolyThunderFlag);
    end
    return false;
end

function Thunder:SetTearThunder(tear, value)
    local flags = Tears.GetModTearFlags(tear, true)
    return flags:Add(HolyThunderFlag);
end

function Thunder:FallThunder(position, spawner, damage)
    local Thunder = THI.Effects.HolyThunder;
    local thunder = Isaac.Spawn(Thunder.Type, Thunder.Variant, Thunder.SubTypes.NORMAL, position, Vector.Zero, spawner);
    thunder.CollisionDamage = damage * 2;
end

function Thunder:RandomThunder(seed, luck)
    local range = 1 / math.min(17, math.max(2, 17 - luck));
    return seed % 100 < range * 100
end

local function PostFireTear(mod, tear)
    local player = nil;
    if (tear.SpawnerEntity) then
        player = tear.SpawnerEntity:ToPlayer();
    end
    if (player) then
        if (player:HasCollectible(Thunder.Item)) then
            local rng = player:GetCollectibleRNG(Thunder.Item);
            local luck = player.Luck;
            
            if (Thunder:RandomThunder(rng:Next(), luck)) then
                if (not Thunder:TearHasThunder(tear)) then
                    Thunder:SetTearThunder(tear, true);
                    tear.Velocity = tear.Velocity:Resized(20);
                    tear:AddTearFlags(TearFlags.TEAR_JACOBS);
                end
            end
        end
    end
end
Thunder:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PostFireTear);


local function PostTearUpdate(mod, tear)
    if (Thunder:TearHasThunder(tear)) then
        local data = GetTearTempData(tear, false);
        
        if (tear:IsDead()) then
            if (not data or not data.HitThisFrame) then
                Thunder:FallThunder(tear.Position, tear.SpawnerEntity, tear.CollisionDamage * 2)
            end
        end
        if (data) then
            data.HitThisFrame = false;
        end
    end
end
Thunder:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate);

--TODO Post Collision
local function PostTearCollision(mod, tear, other, low)
    if (Thunder:TearHasThunder(tear) and other:IsActiveEnemy(true) and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        local hash = GetPtrHash(other);
        local data = GetTearTempData(tear, true);
        if (not data[hash]) then
            data[hash] = true;
            Thunder:FallThunder(tear.Position, tear.SpawnerEntity, tear.CollisionDamage * 2)
            data.HitThisFrame = true;
        end
    end
    
end
Thunder:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, PostTearCollision);


Thunder.BlacklistDamageFlags = DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_COUNTDOWN;

local function PostTakeDamage(mod, tookDamage, amount, flags, source, countdown)

    if (tookDamage:IsActiveEnemy(true)) then
        local sourceEnt = source.Entity;
        if (sourceEnt) then
            local sourceSpawner = sourceEnt.SpawnerEntity;
            local player = sourceEnt:ToPlayer();
            if (not player and sourceSpawner) then
                player = sourceSpawner:ToPlayer();
            end 
            if (player and player:HasCollectible(Thunder.Item)) then

                local canStrike = false;

                if (flags & DamageFlag.DAMAGE_EXPLOSION > 0) then
                    -- Dr. Fetus.
                    if (sourceEnt.Type == EntityType.ENTITY_BOMB) then
                        local bomb = sourceEnt:ToBomb();
                        if (bomb.IsFetus) then
                            canStrike = true;
                        end
                    -- Epic Fetus.
                    elseif (sourceEnt.Type == EntityType.ENTITY_EFFECT and sourceEnt.Variant == EffectVariant.ROCKET) then
                        canStrike = true;
                    end
                -- Lasers.
                elseif (flags & DamageFlag.DAMAGE_LASER > 0 and sourceEnt.Type == EntityType.ENTITY_PLAYER) then
                    canStrike = true;
                -- Boogers and creeps.
                elseif (flags & DamageFlag.DAMAGE_BOOGER > 0 or flags & DamageFlag.DAMAGE_ACID > 0) then
                    canStrike = true;
                -- Any normal damage.
                elseif (flags == 0) then
                    if (sourceEnt.Type ~= EntityType.ENTITY_TEAR 
                    and sourceEnt.Type ~= EntityType.ENTITY_PROJECTILE 
                    and sourceEnt.Type ~= EntityType.ENTITY_FAMILIAR 
                    and sourceEnt.Type ~= EntityType.ENTITY_EFFECT) then
                        canStrike = true;
                    end
                end

                -- Results thunder.
                if (canStrike) then
                    
                    local rng = player:GetCollectibleRNG(Thunder.Item);
                    local luck = player.Luck;
                    
                    if (Thunder:RandomThunder(rng:Next(), luck)) then
                        Thunder:FallThunder(tookDamage.Position, player, player.Damage * 2)
                    end
                end
            end
        end

    end
end
Thunder:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostTakeDamage);

return Thunder;