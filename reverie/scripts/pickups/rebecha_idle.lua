local RebechaIdle = ModEntity("Rebecha Idle", "REBECHA_IDLE")


function RebechaIdle:SpawnMecha(pickup)
    local Mecha = THI.Monsters.Rebecha;
    local mecha = Isaac.Spawn(Mecha.Type, Mecha.Variant, Mecha.SubType, pickup.Position, Vector.Zero, pickup.SpawnerEntity);
    mecha.HitPoints = mecha.MaxHitPoints - pickup.SubType;
    mecha:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    mecha:GetSprite():Play("Appear");
    return mecha;
end

local function PostPickupInit(mod, pickup)
    pickup.Wait = 60;
    pickup.TargetPosition = pickup.Position;
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
end
RebechaIdle:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInit, RebechaIdle.Variant);


local function PostPickupUpdate(mod, pickup)
    if (pickup.FrameCount == 1) then
        if (pickup:HasEntityFlags(EntityFlag.FLAG_APPEAR)) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup);
        end
    end
    if (pickup.Wait >= 0) then
        pickup.Wait = pickup.Wait - 1;
    end
    pickup.Position = pickup.TargetPosition;

    if (pickup:GetSprite():IsEventTriggered("Land")) then
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
        Game():ShakeScreen(20);
        THI.SFXManager:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND);
        THI.SFXManager:Play(THI.Sounds.SOUND_ROBOT_SMASH);
        Game():BombDamage (pickup.Position, 100, 80, true, pickup.SpawnerEntity, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_CRUSH, false)
    end

    if (pickup:GetSprite():IsEventTriggered("Open")) then
        THI.SFXManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN);
    end
end
RebechaIdle:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostPickupUpdate, RebechaIdle.Variant);


local function PrePickupCollision(mod, pickup, other, low)
    if (pickup.Wait < 0 and other.Type == EntityType.ENTITY_PLAYER) then
        local Mecha = THI.Monsters.Rebecha;
        local player = other:ToPlayer();
        if (player:IsExtraAnimationFinished() and player:AreControlsEnabled() and Mecha:GetPlayerMechaState(player) == Mecha.MechaStates.NONE) then
            local mecha = RebechaIdle:SpawnMecha(pickup);
            Mecha:EnterMecha(player, mecha);
            pickup:Remove();
            return true;
        end
    end
end
RebechaIdle:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, PrePickupCollision, RebechaIdle.Variant);

return RebechaIdle;