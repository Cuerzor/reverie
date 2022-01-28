local NonSpell = GensouDream.SpellCard();


local tearColor1 = Color(1,1,1,1,0,0,0.5);
local tearColor2 = Color(1,1,1,1,0.5,0,0.5);

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
    return 450;
end
    
function NonSpell:PostUpdate(doremy)
    local data = self:GetData(doremy);

    
    data.Interval = data.Interval - 1;
    if (data.Interval <= 0) then
        data.Interval = 3;
        -- Create Projectiles.
        if (data.Time > 0) then
            local tearAngle = data.Time * 30;
            if (not data.Clockwise) then
                tearAngle = 180 - data.Time * 30;
            end
            for i = 0, 3 do
                
                local angle = i * 120 + data.Time * 30;
                local offset = Vector.FromAngle(angle) * 90;
                local sourcePos = data.Position + offset;
                if (data.Time > 20) then
                    color = tearColor1;
                    speed = 4;
                else
                    color = tearColor2;
                    speed = 6;
                end
                local velocity = Vector.FromAngle(tearAngle) * speed;
                local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                
                tearEntity:SetColor(color, -1, 0, false, true);
                --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);

                local proj = tearEntity:ToProjectile();
                proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
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
function NonSpell:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 40;
    data.Interval = 3;
    data.Position = doremy.Position;
    data.Clockwise = not data.Clockwise;
end

return NonSpell;