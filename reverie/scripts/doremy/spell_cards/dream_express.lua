local Dream = GensouDream;
local DreamExpress = GensouDream.SpellCard();
DreamExpress.NameKey = "#SPELL_CARD_DREAM_EXPRESS"

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

local FeatherParams = ProjectileParams();
FeatherParams.BulletFlags = ProjectileFlags.ACCELERATE;
FeatherParams.Acceleration = 1.07;
FeatherParams.Variant = ProjectileVariant.PROJECTILE_WING;
FeatherParams.FallingAccelModifier = -0.2;
FeatherParams.FallingSpeedModifier = 3;

local ProjParams = ProjectileParams();
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
ProjParams.Scale = 2;

function DreamExpress:GetDefaultData(doremy)
    return {
        ScaleTime = 0,
        RingTime = 20,
        Target = Vector.Zero,
        MotherShadow = nil
    }
end
    
function DreamExpress:CanCast(frame)
    return frame % 90 == 0;
end

function DreamExpress:CanMove(frame)
    return frame % 60 == 0 and not self:CanCast(frame)
end

function DreamExpress:GetDuration()
    return 1200;
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
                local speed = 2;
                local velocity = fireDir * speed;

                
                FeatherParams.Color = color;
                FeatherParams.BulletFlags = self:GetProjectileFlags(doremy) | ProjectileFlags.ACCELERATE;
                doremy:FireProjectiles (sourcePos, velocity, 0, FeatherParams);
                FeatherParams.Color = Color.Default;
                FeatherParams.BulletFlags = ProjectileFlags.ACCELERATE;

                -- local tearEntity = Isaac.Spawn(9, 13, 0, sourcePos, velocity, doremy);
                
                -- tearEntity:SetColor(color, -1, 0,false, true);
                -- local proj = tearEntity:ToProjectile();
                -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
                -- table.insert(data.Projectiles, {
                --     Projectile = proj,
                --     Speed = speed
                -- }
                -- );
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

            ProjParams.BulletFlags = self:GetProjectileFlags(doremy);
            doremy:FireProjectiles (sourcePos, velocity, 0, ProjParams);
            ProjParams.BulletFlags = 0;

            --local tearEntity = Isaac.Spawn(9, 4, 0, sourcePos, velocity, doremy);
            -- local proj = tearEntity:ToProjectile();
            -- proj.ProjectileFlags = proj.ProjectileFlags | self:GetProjectileFlags(doremy);
            -- proj.Scale = 2;
            
            -- table.insert(data.Projectiles, {
            --     Projectile = proj,
            --     Speed = 0
            -- });
        end
        
        --THI.SFXManager:Play(SoundEffect.SOUND_BISHOP_HIT);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
    end

    local frame = self:GetFrame(doremy);
    if (frame >= 45) then
        if (not data.MotherShadow or not data.MotherShadow:Exists()) then
            local Shadow = Dream.Effects.NightmareMothersShadow;
            data.MotherShadow = Isaac.Spawn(Shadow.Type, Shadow.Variant, Shadow.SubType, Vector(-200, 0), Vector.Zero, doremy);
        end
    end
    -- -- Make projectiles float and increase speed.
    -- for i, info in pairs(data.Projectiles) do
    --     local proj = info.Projectile;
    --     if (proj:Exists()) then
    --         proj.Velocity = proj.Velocity + proj.Velocity:Normalized() * info.Speed;
    --         proj.FallingSpeed = 0;
    --     else
    --         data.Projectiles[i] = nil;
    --     end
    -- end
end
function DreamExpress:OnCast(doremy)
    local data = self:GetData(doremy);
    data.ScaleTime = 20;
    data.Target = self.GetRandomPlayer().Position;
    if (data.MotherShadow and data.MotherShadow:Exists()) then
        local Shadow = Dream.Effects.NightmareMothersShadow;
        Shadow:StartCharge(data.MotherShadow);
    end
end
function DreamExpress:End(doremy)
    local data = self:GetData(doremy);
    if (data.MotherShadow and data.MotherShadow:Exists()) then
        data.MotherShadow:Remove();
    end
end

return DreamExpress;