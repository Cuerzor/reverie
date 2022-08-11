local NonSpell = GensouDream.SpellCard();


local tearColor1 = Color(1,1,1,1,0,0,0.5);
local tearColor2 = Color(1,1,1,1,0.5,0,0.5);
local ProjParams = ProjectileParams();
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor1;
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
local ProjParams2 = ProjectileParams();
ProjParams2.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams2.Color = tearColor2;
ProjParams2.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;

function NonSpell:GetDefaultData(doremy)
    return {
        Time = 0,
        Interval = 3,
        Clockwise = false,
        Position = Vector.Zero,
        Projectiles = {}
    };
end
    

function NonSpell:CanMove(frame)
    return frame % 150 == 120;
end
function NonSpell:CanCast(frame)
    return frame % 150 == 2;
end
function NonSpell:GetDuration()
    return 300;
end
    
function NonSpell:PostUpdate(doremy)
    local data = self:GetData(doremy);

    
    data.Interval = data.Interval - 1;
    if (data.Interval <= 0) then
        data.Interval = 3;
        -- Create Projectiles.
        if (data.Time > 0) then
            local tearAngle = data.Time * 23;
            if (not data.Clockwise) then
                tearAngle = 180 - data.Time * 23;
            end
            for i = 0, 3 do
                
                local angle = i * 120 + data.Time * 23;
                local offset = Vector.FromAngle(angle) * 90;
                local sourcePos = data.Position + offset;

                local params = ProjParams2;
                local speed = 6;
                if (data.Time > 20) then
                    params = ProjParams;
                    speed = 4;
                end
                local velocity = Vector.FromAngle(tearAngle) * speed;

                params.BulletFlags = self:GetProjectileFlags(doremy);
                doremy:FireProjectiles (sourcePos, velocity, 0, params);
                params.BulletFlags = 0;

                -- local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                -- tearEntity:SetColor(color, -1, 0, false, true);
                -- local proj = tearEntity:ToProjectile();
                -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                -- table.insert(data.Projectiles, proj);

                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
            end
            data.Time = data.Time - 1;
        end
    end

end
function NonSpell:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 46;
    data.Interval = 3;
    data.Position = doremy.Position;
    data.Clockwise = not data.Clockwise;
end

return NonSpell;