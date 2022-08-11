local Dream = GensouDream;
local ScarletNightmare = Dream.SpellCard();


local tearColor = Color(1,1,1,1,0.5,0,0);
local ProjParams = ProjectileParams();
ProjParams.FallingAccelModifier = -0.2;
ProjParams.FallingSpeedModifier = 3;
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor;

ScarletNightmare.NameKey = "#SPELL_CARD_SCARLET_NIGHTMARE";

function ScarletNightmare:GetDefaultData(doremy)
    return {
        Time = 0,
        Clockwise = false,
        Position = Vector.Zero,
        LeftHand = nil,
        RightHand = nil,
    };
end
    
function ScarletNightmare:CanCast(frame)
    return frame % 90 == 0;
end

function ScarletNightmare:CanMove(frame)
    return frame % 60 == 0 and not self:CanCast(frame);
end

function ScarletNightmare:GetDuration()
    return 1200;
end

    
function ScarletNightmare:PostUpdate(doremy)
    local data = self:GetData(doremy);
    -- Create Projectiles.
    if (data.Time > 0) then
        local angle = data.Time * 30;
        if (not data.Clockwise) then
            angle = 180 - data.Time * 30;
        end
        local offset = Vector.FromAngle(angle) * 180;
        local sourcePos = data.Position + offset;
        for i = 0, 3 do
            local tearAngle = i * 120;
            local velocity = Vector.FromAngle(tearAngle) * 4;

            
            ProjParams.BulletFlags = self:GetProjectileFlags(doremy);
            doremy:FireProjectiles(sourcePos, velocity, 0, ProjParams);
            ProjParams.BulletFlags = 0;
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, sourcePos, Vector.Zero, doremy);
            poof:SetColor(ProjParams.Color, -1, 0);
            THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
        end
        data.Time = data.Time - 1;

    end

    local frame = self:GetFrame(doremy);
    if (frame >= 45) then
        if (frame == 45) then
            SFXManager():Play(SoundEffect.SOUND_SATAN_GROW);
        end
        local SatanHand = Dream.Effects.NightmareMegasatanHand;
        if (not data.LeftHand or not data.LeftHand:Exists()) then
            local pos = Game():GetRoom():GetCenterPos();
            data.LeftHand = Isaac.Spawn(SatanHand.Type, SatanHand.Variant, SatanHand.SubType, pos, Vector.Zero, doremy);
            data.LeftHand.FlipX = true;
        end
        if (not data.RightHand or not data.RightHand:Exists()) then
            local pos = Game():GetRoom():GetCenterPos();
            data.RightHand = Isaac.Spawn(SatanHand.Type, SatanHand.Variant, SatanHand.SubType, pos, Vector.Zero, doremy);
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
function ScarletNightmare:OnCast(doremy)
    local data = self:GetData(doremy);
    data.Time = 12;
    data.Position = self.GetRandomPlayer().Position;
    data.Clockwise = not data.Clockwise;

    local SatanHand = Dream.Effects.NightmareMegasatanHand;
    local hand = data.RightHand;
    if (data.Clockwise) then
        hand = data.LeftHand;
    end
    if (hand and hand:Exists()) then
        SatanHand:StartSmash(hand, data.Position);
    end
end

function ScarletNightmare:End(doremy)
    local data = self:GetData(doremy);
    if (data.LeftHand and data.LeftHand:Exists()) then
        data.LeftHand:Remove();
    end
    if (data.RightHand and data.RightHand:Exists()) then
        data.RightHand:Remove();
    end
end


return ScarletNightmare;