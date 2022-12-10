local Drum = ModEntity("Thunder Drum", "THUNDER_DRUM");

Drum.MaxCrushCooldown = 150;
Drum.ForgottenCooldown = 50;

local function GetDrumData(drum, create)
    local function default()
        return {
            Crushing = false,
            CrushCooldown = -1
        }
    end
    return Drum:GetData(drum, create, default);
end

function Drum:GetCrushCooldown(drum)
    local data = GetDrumData(drum, false);
    if (data) then
        return data.CrushCooldown;
    end
    return -1;
end

function Drum:IsCrushing(drum)
    local data = GetDrumData(drum, false);
    return data and data.Crushing;
end
function Drum:Crush(drum)
    
    local data = GetDrumData(drum, true);
    data.Crushing = true;
    data.CrushCooldown = Drum.MaxCrushCooldown;
    drum:GetSprite():Play("Crush");
end
function Drum:EndCrush(drum)
    local data = GetDrumData(drum, true);
    data.Crushing = false;
    drum:GetSprite():Play("Float");
end

local LaserColor = Color(0,0,0,1,0.8,0.8,1);
function Drum:FireLasers(drum, damage)
    damage = damage or 2;
    for i = 1, 18 do
        local angle = i * 20 + Random() % 10 - 5;
        local laser = EntityLaser.ShootAngle(2, drum.Position, angle, 10, Vector.Zero, drum);
        laser.OneHit = true;
        laser:SetColor(LaserColor, 0 ,0);
        laser.Parent = drum;
        laser.CollisionDamage = damage;
    end
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_LASER, 0.3, 0, false);
end

do

    local function PostDrumInit(mod, familiar)
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
    Drum:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostDrumInit, Drum.Variant);

    local function PostDrumUpdate(mod, familiar)


        local spr = familiar:GetSprite();
        if (not Drum:IsCrushing(familiar)) then
            spr:Play("Float");
    
            -- local vel = familiar.Velocity
            -- local dir = vel:Normalized();
            -- if (dir:Length() < 0.1) then
            --     dir = Vector.FromAngle(Random() % 4 * 90 +45)
            -- else
            --     local angle = dir:GetAngleDegrees() % 360;
            --     angle = math.floor(angle / 90) * 90 + 45;
            --     dir = Vector.FromAngle(angle);
            -- end
            -- familiar.Velocity = dir * 3;
            familiar:MoveDiagonally(0.5);
        else
            if (spr:IsEventTriggered("Crush")) then
                THI.SFXManager:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND);
                Game():ShakeScreen(15);

                local laserDamage = 15;
                if (familiar.Player and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    laserDamage = laserDamage * 2;
                end
                Drum:FireLasers(familiar, laserDamage);

                local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, familiar.Position, Vector.Zero, familiar):ToEffect();
                shockwave.Timeout = 2;
                shockwave.MinRadius = 40;
                shockwave.MaxRadius = 40;
                shockwave.Parent = familiar.Player;
            end

            --familiar.Velocity = Vector.Zero;
            familiar:MoveDiagonally(0);
            if (spr:IsFinished("Crush")) then
                Drum:EndCrush(familiar);
            end
        end

        local data = GetDrumData(familiar, false);
        if (data) then
            if (data.CrushCooldown >= 0) then
                data.CrushCooldown = data.CrushCooldown - 1;
            end
        end

        -- Bone Club.
        if (Drum:GetCrushCooldown(familiar) < Drum.MaxCrushCooldown - Drum.ForgottenCooldown) then
            for i, ent in pairs(Isaac.FindByType(8,1,4)) do
                local knife = ent:ToKnife();
                if (knife) then
                    local size = knife.SpriteScale.X * 32;
                    local center = knife.Position + Vector.FromAngle(knife.Rotation) * size;
                    if (center:Distance(familiar.Position) < size + familiar.Size) then
                        familiar:TakeDamage(1, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(ent), 30);
                        THI.SFXManager:Play(SoundEffect.SOUND_BULLET_SHOT, 1, 0, false, 0.8)
                        break;
                    end
                end
            end
        end


        familiar.HitPoints = familiar.MaxHitPoints;
    end
    Drum:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostDrumUpdate, Drum.Variant);

    local function PostTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        if (tookDamage.Type == Drum.Type and tookDamage.Variant == Drum.Variant) then
            --if (Drum:GetCrushCooldown(tookDamage) < 0) then
                Drum:Crush(tookDamage);
            --end
        end
    end
    Drum:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, PostTakeDamage);

    local function PostFamiliarCollision(mod, familiar, other, low)
        if (familiar.Type == Drum.Type and familiar.Variant == Drum.Variant) then
            local canDamage = false;
            if (Drum:GetCrushCooldown(familiar) < 0) then
                if (other.CollisionDamage > 0) then
                local proj = other:ToProjectile();
                    local isProjectile = proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER);
                    if (other:IsEnemy() or isProjectile) then
                        canDamage = true;
                    end
                end
            end

            
            if (canDamage) then
                familiar:TakeDamage(1, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(other), 30);
            end
        end
    end
    Drum:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PostFamiliarCollision);
end

return Drum;