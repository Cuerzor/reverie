local Spirit = ModEntity("Evil Spirit", "EVIL_SPIRIT");

do
    local sprites = {
        "Right",
        "RightDown",
        "Down",
        "LeftDown",
        "Left",
        "LeftUp",
        "Up",
        "RightUp",
    }
    local function PostSpiritInit(mod, spirit)
        if (spirit.Variant == Spirit.Variant) then
            spirit.SplatColor = Color(1,1,1,0,0,0,0);
        end
    end
    Spirit:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostSpiritInit, Spirit.Type)

    local function PostSpiritUpdate(mod, spirit)
        if (spirit.Variant == Spirit.Variant) then
            local maxSpeed = 7;
            if (spirit.FrameCount <= 150) then
                
                local target = spirit:GetPlayerTarget();

                local target2This = target.Position - spirit.Position;

                local angle = target2This:GetAngleDegrees();
                local spriteIndex = math.floor((angle + 22.5) % 360 / 45) + 1;
                spirit:GetSprite():Play("Move"..sprites[spriteIndex]);

                spirit.TargetPosition = target2This:Normalized();

                if (target.Type == EntityType.ENTITY_PLAYER) then
                    local player = target:ToPlayer();
                    maxSpeed = 2 ^ (player.MoveSpeed + 3) * 0.5 - 1;
                end
            else

                if (spirit:CollidesWithGrid()) then
                    spirit:Die();
                end
            end
            
            local acceleration = spirit.TargetPosition * 3;
            spirit:AddVelocity(acceleration)
            local vel = spirit.Velocity;
            local length = vel:Length();
            length = maxSpeed + (length - maxSpeed) * 0.1;
            spirit.Velocity = vel:Resized(length);
            spirit:MultiplyFriction(0.9);
        end
    end
    Spirit:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostSpiritUpdate, Spirit.Type)

    
    local function PostSpiritDeath(mod, spirit)
        if (spirit.Variant == Spirit.Variant) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, spirit.Position, Vector.Zero, spirit);
            local SpellCardWave = THI.Effects.SpellCardWave;
            local wave = Isaac.Spawn(SpellCardWave.Type, SpellCardWave.Variant, SpellCardWave.SubTypes.BURST, spirit.Position, Vector.Zero, spirit);
            wave.SpriteScale = Vector(0.5, 0.5);
            wave.PositionOffset = Vector(0, -16 * spirit.SpriteScale.Y) + spirit.PositionOffset; 
            THI.SFXManager:Play(THI.Sounds.SOUND_MAGIC_IMPACT);
        end
    end
    Spirit:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, PostSpiritDeath, Spirit.Type)

    local function PreSpiritCollision(mod, npc, other, low)
        if (npc.Variant == Spirit.Variant) then
            local canCollide = other.Type == EntityType.ENTITY_PLAYER;
            if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                canCollide = other.Type ~= EntityType.ENTITY_PLAYER and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY);
            end
            if (canCollide) then
                if (other:IsVulnerableEnemy()) then
                    other:TakeDamage(100, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(npc), 0);
                end
                npc:Die();
            else
                return true;
            end
        end
    end
    Spirit:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, PreSpiritCollision, Spirit.Type)

    
    local function InvalidateCollision(mod, this, other, low)
        if (other.Type == Spirit.Type and  other.Variant == Spirit.Variant) then
            return true;
        end
    end
    Spirit:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, InvalidateCollision)
    Spirit:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, InvalidateCollision)
    Spirit:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, InvalidateCollision)
    Spirit:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, InvalidateCollision)
    Spirit:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, InvalidateCollision)
    Spirit:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, InvalidateCollision)
end


return Spirit;