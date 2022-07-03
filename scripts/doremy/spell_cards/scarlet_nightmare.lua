local ScarletNightmare = GensouDream.SpellCard();


local tearColor = Color(1,1,1,1,0.5,0,0);
local ProjParams = ProjectileParams();
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor;

function ScarletNightmare:GetDefaultData(doremy)
    return {
        Time = 0,
        Clockwise = false,
        Position = Vector.Zero,
        Projectiles = {}
    };
end
    
function ScarletNightmare:CanCast(frame)
    return frame % 90 == 0;
end

function ScarletNightmare:CanMove(frame)
    return frame % 60 == 0 and not self:CanCast(frame);
end


    
function ScarletNightmare:PostUpdate(doremy)
    local data = self:GetData(doremy);
    -- Create Projectiles.
    if (data.Time > 0) then
        local angle = data.Time * 20;
        if (not data.Clockwise) then
            angle = 180 - data.Time * 20;
        end
        local offset = Vector.FromAngle(angle) * 180;
        local sourcePos = data.Position + offset;
        for i = 0, 3 do
            local tearAngle = i * 120;
            local velocity = Vector.FromAngle(tearAngle) * 4;

            
            ProjParams.BulletFlags = self:GetProjectileFlags(doremy);
            doremy:FireProjectiles(sourcePos, velocity, 0, ProjParams);
            ProjParams.BulletFlags = 0;
            -- local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
            -- tearEntity:SetColor(tearColor, -1, 0, false, true);
            -- local proj = tearEntity:ToProjectile();
            -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
            -- table.insert(data.Projectiles, proj);

            THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
        end
        data.Time = data.Time - 1;
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
function ScarletNightmare:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 18;
    data.Position = self.GetRandomPlayer().Position;
    data.Clockwise = not data.Clockwise;
end

return ScarletNightmare;