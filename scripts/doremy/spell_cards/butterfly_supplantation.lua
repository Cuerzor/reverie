local SpellCard = GensouDream.SpellCard();
SpellCard.Name = "Butterfly Supplantation"
SpellCard.NameKey = "#SPELL_CARD_BUTTERFLY_SUPPLANTATION"

local tearColor = Color(1,1,1,1,0.5,0,0);
local ProjParams = ProjectileParams();
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
ProjParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE;
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor;

function SpellCard:GetDefaultData(doremy)
    return {
        Time = 0,
        StateTime = 0,
        Clockwise = false,
        Position = Vector.Zero,
        Projectiles = {}
    };
end
    
function SpellCard:CanCast(frame)
    return false;
end

function SpellCard:CanMove(frame)
    return frame % 60 == 0;
end

function SpellCard:GetDuration()
    return 1200;
end

    
function SpellCard:PostUpdate(doremy)
    local data = self:GetData(doremy);
    -- Create Projectiles.
    data.Time = data.Time + 1;
    if (data.Time == 60) then
        SFXManager():Play(SoundEffect.SOUND_SCARED_WHIMPER);
    end
    if (data.Time > 60) then
        if (data.StateTime == 0) then
            data.Position = self.GetRandomPlayer().Position;
        end
        data.StateTime = data.StateTime + 1;
        if (data.StateTime <= 12) then
            local angle = data.StateTime * 37 + 180;
            if (not data.Clockwise) then
                angle = -data.StateTime * 37;
            end
            local target2This = (data.Position - doremy.Position):Normalized();
            local offset = Vector.FromAngle(angle) * 180;
            offset.Y = offset.Y * 0.5;
            offset = offset:Rotated(target2This:GetAngleDegrees() - 90)
            local sourcePos = doremy.Position + offset;
            local velocity = target2This * 4;

            ProjParams.BulletFlags = ProjParams.BulletFlags | SpellCard:GetProjectileFlags(doremy);
            doremy:FireProjectiles(sourcePos, velocity, 0, ProjParams);
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, sourcePos, Vector.Zero, doremy);
            ProjParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE;
            THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
        end
        if (data.StateTime > 30) then
            data.StateTime = 0;
            data.Clockwise = not data.Clockwise;
        end

        local frame = self:GetFrame(doremy);
        if (frame % 45 == 0) then
            local Pooter = THI.Monsters.NightmarePooter;
            local margin = 80;
            local width = Game():GetRoom():GetGridWidth() * 40 - 40- margin;
            local vel = Vector(0, 5)
            for i = 0, 1 do
                local pos = Vector(margin + i * width, 160);
                local pooter = Isaac.Spawn(Pooter.Type, Pooter.Variant, Pooter.SubType, pos, vel, doremy);
                pooter:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
                local pooterData = Pooter:GetPooterData(pooter, true);
                pooterData.Velocity = vel;
            end
        end
    end

end
function SpellCard:End(doremy)
    local Pooter = THI.Monsters.NightmarePooter;
    for _, ent in ipairs(Isaac.FindByType(Pooter.Type, Pooter.Variant, Pooter.SubType)) do
        ent:Die();
    end
end

return SpellCard;