local NonSpell2 = GensouDream.SpellCard();


local tearColor = Color(1,1,1,1,0.5,0,0.5);

function NonSpell2:GetDefaultData(doremy)
    return {
        Time = 0,
        Interval = 4,
        Clockwise = false,
        Position = Vector.Zero,
        Projectiles = {}
    };
end
local MaxTime = 40;
    

function NonSpell2:CanMove(frame)
    return frame % 150 == 120;
end
function NonSpell2:CanCast(frame)
    return frame % 150 == 2;
end
function NonSpell2:GetDuration()
    return 450;
end
    
function NonSpell2:PostUpdate(doremy)
    local data = self:GetData(doremy);

    
    data.Interval = data.Interval - 1;
    if (data.Interval <= 0) then
        data.Interval = 120 / MaxTime;
        -- Create Projectiles.
        if (data.Time > 0) then
            local t = MaxTime - data.Time;
            local tearAngle = t * t;
            if (not data.Clockwise) then
                tearAngle = 180 - t * t;
            end
            for i = 0, 2 do
                local angle = i * 120 + t * t;
                local offset = Vector.FromAngle(angle) * 90;
                local sourcePos = data.Position + offset;
                local velocity = Vector.FromAngle(tearAngle) * (4 + t / MaxTime);
                local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                tearEntity:SetColor(tearColor, -1, 0, false, true);
                --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);

                local proj = tearEntity:ToProjectile();
                proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                proj.Scale = 2;
                table.insert(data.Projectiles, proj);
            end
            data.Time = data.Time - 1;
        end
    end


    -- Make projectiles float.
    for i, proj in pairs(data.Projectiles) do
        if (proj:Exists()) then
            proj.FallingSpeed = 0;
        else
            data.Projectiles[i] = nil;
        end
    end
end
function NonSpell2:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = MaxTime;
    data.Interval = 120 / MaxTime;
    data.Position = doremy.Position;
    data.Clockwise = not data.Clockwise;
end

return NonSpell2;