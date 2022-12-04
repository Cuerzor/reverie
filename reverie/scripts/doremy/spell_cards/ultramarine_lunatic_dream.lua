local SpellCard = GensouDream.SpellCard();
SpellCard.Name = "Ultramarine Lunatic Dream"
SpellCard.NameKey = "#SPELL_CARD_ULTRAMARINE_LUNATIC_DREAM"

local tearColor = Color(0,0,1,1,0,0,0);
local BlueParams = ProjectileParams();
BlueParams.FallingAccelModifier = -0.19;
BlueParams.FallingSpeedModifier = 3;
BlueParams.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE;
BlueParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
BlueParams.Color = tearColor;
BlueParams.Acceleration = 1.02;

local PurpleParams = ProjectileParams();
PurpleParams.FallingAccelModifier = -0.19;
PurpleParams.FallingSpeedModifier = 3;
PurpleParams.BulletFlags = ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE;
PurpleParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
PurpleParams.Color = Color(1,0,1,1,0,0,0);
PurpleParams.Acceleration = 1.02;

function SpellCard:GetDefaultData(doremy)
    return {
        Time = 0,
        Angle = 0,
        Distance = 60,
        PurpleAngle = 90,
        PurpleDistance = 60,
        Gaper = nil,
    };
end
    
function SpellCard:CanCast(frame)
    if (frame < 80) then
        return false;
    end
    if (self:GetDuration() - frame < 270) then
        return false;
    end
    return frame % 270 == 80;
end

function SpellCard:CanWarning(frame)
    return self:CanCast(frame + 30);
end

function SpellCard:GetDuration()
    return 1200;
end

function SpellCard:CanMove(frame)
    if (frame < 80) then
        return false;
    end
    local time = frame % 270;
    if (time > 40 and time < 100) then
        return false;
    end
    return frame % 60 == 0;
end

function SpellCard:SpawnProjectile(doremy, angle, dir, distance, params, pitch)
    pitch = pitch or 1;
    local offset = Vector.FromAngle(angle) * distance;
    local sourcePos = doremy.Position + offset;

    local room = Game():GetRoom();
    if (#Isaac.FindInRadius(sourcePos, 60, EntityPartition.PLAYER) <= 0 and room:IsPositionInRoom(sourcePos, -120)) then

        local velocity = Vector.FromAngle(dir) * 1;

        local flags = params.BulletFlags;
        params.BulletFlags = flags | self:GetProjectileFlags(doremy);
        doremy:FireProjectiles(sourcePos, velocity, 0, params);
        params.BulletFlags = flags;
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, sourcePos, Vector.Zero, doremy);
        poof:SetColor(params.Color, -1, 0);
    end
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25, 0, false, pitch);
end
    
function SpellCard:PostUpdate(doremy)
    local data = self:GetData(doremy);
    local frame = SpellCard:GetFrame(doremy);
    if (frame == 90) then
        Game():ShowHallucination(10, BackdropType.PLANETARIUM)
    end
    if (frame > 90) then
        -- Create Projectiles.
        data.Time = data.Time + 1;
        if (data.Time % 2 == 0) then
            data.Angle = data.Angle - 14;
            data.Distance = data.Distance + 4;
            self:SpawnProjectile(doremy, data.Angle, -3 * data.Angle, data.Distance, BlueParams)
            if (data.Time > 120) then
                data.PurpleAngle = data.PurpleAngle + 14;
                data.PurpleDistance = data.PurpleDistance + 4;
                self:SpawnProjectile(doremy, data.PurpleAngle, -9 * data.PurpleAngle, data.PurpleDistance, PurpleParams, 1.2)
            end
        end

        if (not data.Gaper or not data.Gaper:Exists()) then
            local Gaper = THI.Monsters.DeliriousGaper;
            data.Gaper = Isaac.Spawn(Gaper.Type, Gaper.Variant, Gaper.SubType, doremy.Position, Vector.Zero, doremy);
            SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND);
        end
    end
end
function SpellCard:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 0;
    data.Angle = 0;
    data.Distance = 60;
    data.PurpleAngle = 90;
    data.PurpleDistance = 60;
end

function SpellCard:End(doremy)
    local Gaper = THI.Monsters.DeliriousGaper;
    for _, ent in ipairs(Isaac.FindByType(Gaper.Type, Gaper.Variant, Gaper.SubType)) do
        ent:Remove();
    end
end


return SpellCard;