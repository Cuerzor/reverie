local OchreConfusion = GensouDream.SpellCard();

local centerColor = Color(1,1,1,1,0.5,0.5,0);
local boundColor = Color(1,1,1,1,1,1,0);
    
function OchreConfusion:GetDefaultData(doremy)
    return {
        Time = 0,
        Clockwise = false,
        Index = 0,
        Position = Vector.Zero,
        Projectiles = {}
    }
end
    
function OchreConfusion:CanCast(frame)
    return (frame + 30) % 180 == 0;
end

function OchreConfusion:CanMove(frame)
    return frame % 90 == 0 and not OchreConfusion:CanCast(frame)
end

function OchreConfusion:GetDuration()
    return 850;
end


    
function OchreConfusion:PostUpdate(doremy)
    local data = OchreConfusion:GetData(doremy);

    -- Create Projectiles
    if (data.Index > 0) then
        data.Time = data.Time - 1;
        if (data.Time <= 0) then
            data.Time = 2;
            local angle = (40 - data.Index) * 15;
            if (not data.Clockwise) then
                angle = 180 - angle;
            end
            local offset = Vector.FromAngle(angle) * 180;
            local sourcePos = data.Position + offset;
            local angleOffset = -angle;
            for i = 0, 5 do
                local tearAngle;
                if (i <= 2) then
                    tearAngle = i * 30 + angleOffset - 30;
                else
                    tearAngle = (i - 3) * 30 + angleOffset + 150;
                end
                local color;
                local speed = 0.06;
                if (i == 1 or i == 4) then
                    color = centerColor;
                else
                    color = boundColor;
                end
                local velocity = Vector.FromAngle(tearAngle) * speed;
                local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
                
                tearEntity:SetColor(color, -1, 0,false, true);
                local proj = tearEntity:ToProjectile();
                proj.ProjectileFlags = proj.ProjectileFlags | OchreConfusion:GetProjectileFlags(doremy);
                table.insert(data.Projectiles, {
                    Projectile = proj,
                    Speed = speed
                }
                );
            end
            
            --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
            THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
            data.Index = data.Index - 1;
        end
    end


    -- Make projectiles float and increase speed.
    for i, info in pairs(data.Projectiles) do
        local proj = info.Projectile;
        if (proj:Exists()) then
            proj.Velocity = proj.Velocity + proj.Velocity:Normalized() * info.Speed;
            proj.FallingSpeed = 0;
        else
            data.Projectiles[i] = nil;
        end
    end
end
function OchreConfusion:OnCast(doremy)
    local data = OchreConfusion:GetData(doremy);
    data.Time = 2;
    data.Index = 40;
    data.Clockwise = not data.Clockwise;
    data.Position = OchreConfusion.GetRandomPlayer().Position;
end

return OchreConfusion;