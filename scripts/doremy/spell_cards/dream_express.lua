local DreamExpress = GensouDream.SpellCard();

local featherGap = 30;    
local scaleColors = {
    Color(1,1,1,1,1,0,0),
    Color(1,1,1,1,1,0.5,0),
    Color(1,1,1,1,1,1,0),
    Color(1,1,1,1,0.5,1,0),
    Color(1,1,1,1,0,1,0),
    Color(1,1,1,1,0,1,0.5),
    Color(1,1,1,1,0,1,1),
    Color(1,1,1,1,0,0.5,1),
    Color(1,1,1,1,1,0,1)
}

function DreamExpress:GetDefaultData(doremy)
    return {
        ScaleTime = 0,
        RingTime = 20,
        Target = Vector.Zero,
        Projectiles = {},
    }
end
    
function DreamExpress:CanCast(frame)
    return frame % 90 == 0;
end

function DreamExpress:CanMove(frame)
    return frame % 60 == 0 and not self:CanCast(frame)
end

function DreamExpress:PostUpdate(doremy)
    local data = self:GetData(doremy);

    -- Fire feather projectiles
    if (data.ScaleTime > 0) then
        local startIndex = 1;
        local endIndex = 9;

        if (data.ScaleTime == 20) then
            startIndex = 5;
            endIndex = 5;
        elseif (data.ScaleTime == 19) then
            startIndex = 4;
            endIndex = 6;
        elseif (data.ScaleTime == 18) then
            startIndex = 3;
            endIndex = 7;
        end


        local dir = (data.Target - doremy.Position):Normalized();
        local angle = dir:GetAngleDegrees();
        local normalAngle = angle + 90;
        for i = startIndex, endIndex do
            local canFire = true;
            
            if (data.ScaleTime == 3) then
                canFire = i ~= 5;
            elseif (data.ScaleTime == 2) then
                canFire = i < 4 or i > 6;
            elseif (data.ScaleTime == 1) then
                canFire = i < 3 or i > 7;
            end

            if (canFire) then

                local normalOffset = (i - 5) * featherGap;
                local fireDir = Vector.FromAngle(angle);
                local offset = fireDir * 10 + Vector.FromAngle(normalAngle) * normalOffset;
                local sourcePos = doremy.Position + offset;
                local color = scaleColors[i];
                local speed = 0.3;
                local velocity = fireDir * speed;
                local tearEntity = Isaac.Spawn(9, 13, 0, sourcePos, velocity, doremy);
                
                tearEntity:SetColor(color, -1, 0,false, true);
                local proj = tearEntity:ToProjectile();
                proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                table.insert(data.Projectiles, {
                    Projectile = proj,
                    Speed = speed
                }
                );
            end
        end
        
        --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
        data.ScaleTime = data.ScaleTime - 1;
    end

    -- Fire ring projectiles
    data.RingTime = data.RingTime - 1;
    if (data.RingTime <= 0) then
        data.RingTime = 40;

        for i = 0, 24 do
            local angle = i * 15;
            local sourcePos = doremy.Position;
            local speed = 6;
            local velocity = Vector.FromAngle(angle) * speed;
            local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);

            local proj = tearEntity:ToProjectile();
            proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
            proj.Scale = 2;
            
            table.insert(data.Projectiles, {
                Projectile = proj,
                Speed = 0
            });
        end
        
        --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
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
function DreamExpress:OnCast(doremy)
    local data = self:GetData(doremy);
    data.ScaleTime = 20;
    data.Target = self.GetRandomPlayer().Position;
end

return DreamExpress;