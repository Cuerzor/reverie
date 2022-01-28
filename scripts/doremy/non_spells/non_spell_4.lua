local NonSpell = GensouDream.SpellCard();


local tearColor = Color(1,1,1,1,0.5,0,0);
local smallColor = Color(1,1,1,1,0.5,0.5,0.5);

function NonSpell:GetDefaultData(doremy)
    return {
        Time = 0,
        Interval = 4,
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
        data.Interval = 4;
        -- Create Projectiles.
        if (data.Time > 0) then
            local tearAngle = data.Time * 30;
            if (not data.Clockwise) then
                tearAngle = 180 - data.Time * 30;
            end
            for i = 0, 4 do
                
                local angle = i * 72;
                local offset = Vector.FromAngle(angle) * 90;
                local sourcePos = data.Position + offset;

                local velocity = Vector.FromAngle(tearAngle) * 4;
                local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                tearEntity:SetColor(tearColor, -1, 0, false, true);
                local proj = tearEntity:ToProjectile();
                proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                proj.Scale = 2;
                table.insert(data.Projectiles, proj);

                
                local smallVelocity = Vector.FromAngle(tearAngle) * -4;
                local smallEntity = Isaac.Spawn(9, 4, 0, sourcePos, smallVelocity, doremy);
                smallEntity:SetColor(smallColor, -1, 0, false, true);
                local small = smallEntity:ToProjectile();
                small.ProjectileFlags = small.ProjectileFlags | self:GetProjectileFlags(doremy);
                small.Scale = 0.5;
                table.insert(data.Projectiles, small);
            end

            --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);

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
    data.Time = 20;
    data.Interval = 6;
    data.Position = doremy.Position;
    data.Clockwise = not data.Clockwise;
end

return NonSpell;