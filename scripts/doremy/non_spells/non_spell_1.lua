local Dream = GensouDream;
local NonSpell1 = Dream.SpellCard();


local tearColor = Color(1,1,1,1,0.5,0,0);
local ProjParams = ProjectileParams();
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor;
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
ProjParams.Scale = 2;

function NonSpell1:GetDefaultData(doremy)
    return {
        Time = 0,
        Interval = 4,
        Clockwise = false,
        Position = Vector.Zero,
        Projectiles = {}
    };
end
    

function NonSpell1:CanMove(frame)
    return frame % 150 == 120;
end
function NonSpell1:CanCast(frame)
    return frame % 150 == 2;
end
function NonSpell1:GetDuration()
    return 450;
end
    
function NonSpell1:PostUpdate(doremy)
    local data = self:GetData(doremy);

    
    data.Interval = data.Interval - 1;
    if (data.Interval <= 0) then
        data.Interval = 4;
        -- Create Projectiles.
        if (data.Time > 0) then
            local tearAngle = data.Time * 30;
            if (not data.Clockwise) then
                tearAngle = 180 - data.Time * 30;
            end
            for i = 0, 5 do
                
                local angle = i * 60;
                local offset = Vector.FromAngle(angle) * 90;
                local sourcePos = data.Position + offset;
                local velocity = Vector.FromAngle(tearAngle) * 4;
                
                ProjParams.BulletFlags = self:GetProjectileFlags(doremy);
                doremy:FireProjectiles (sourcePos, velocity, 0, ProjParams);
                ProjParams.BulletFlags = 0;

                -- local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                -- tearEntity:SetColor(tearColor, -1, 0, false, true);

                -- local proj = tearEntity:ToProjectile();
                -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                -- proj.Scale = 2;
                -- table.insert(data.Projectiles, proj);
                --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
            end
            data.Time = data.Time - 1;
        end
    end

    -- -- Make projectiles float.
    -- for i, proj in pairs(data.Projectiles) do
    --     if (proj:Exists()) then
    --         proj.FallingSpeed = 0;
    --     else
    --         data.Projectiles[i] = nil;
    --     end
    -- end
end
function NonSpell1:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 20;
    data.Interval = 6;
    data.Position = doremy.Position;
    data.Clockwise = not data.Clockwise;
end

return NonSpell1;