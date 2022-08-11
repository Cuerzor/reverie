local SpellCard = GensouDream.SpellCard();
SpellCard.Name = "Creeping Bullet"
SpellCard.NameKey = "#SPELL_CARD_CREEPING_BULLET"

local tearColor = Color(1,1,1,1,0.5,0,0);
local ProjParams = ProjectileParams();
ProjParams.FallingAccelModifier = -0.175;
ProjParams.FallingSpeedModifier = 0;
ProjParams.BulletFlags = 0;
ProjParams.Variant = ProjectileVariant.PROJECTILE_TEAR;
ProjParams.Color = tearColor;

function SpellCard:GetDefaultData(doremy)
    return {
        Time = 0,
        Angle = 180
    };
end
    
function SpellCard:CanCast(frame)
    return false;
end

function SpellCard:CanMove(frame)
    return frame % 60 == 0;
end



function SpellCard:GetDuration()
    return 1200;
end
    
function SpellCard:PostUpdate(doremy)
    local data = self:GetData(doremy);
    -- Create Projectiles.
    data.Time = data.Time + 1;

    if (data.Time == 60) then
        SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_B);
    end

    if (data.Time > 60) then
        local offset = Vector.FromAngle(data.Angle) * 220;
        local sourcePos = Game():GetRoom():GetCenterPos() + offset;
        local hasPlayer = #Isaac.FindInRadius(sourcePos, 60, EntityPartition.PLAYER) > 0;
        if (data.Time % 3 == 0) then
            data.Angle = data.Angle + 17;
            for i = 1, 1 do
                if (not hasPlayer) then

                    local angle = Random() % 360;
                    local velocity = Vector.FromAngle(angle) * 2;

                    ProjParams.BulletFlags = SpellCard:GetProjectileFlags(doremy);
                    doremy:FireProjectiles(sourcePos, velocity, 0, ProjParams);
                    ProjParams.BulletFlags = 0;
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, sourcePos, Vector.Zero, doremy);
                    poof:SetColor(ProjParams.Color, -1, 0);
                end
                THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.25);
            end
        end
        if (data.Time % 30 == 0 and not hasPlayer) then
            local Spider = THI.Monsters.NightmareSpider;
            if (#Isaac.FindByType(Spider.Type, Spider.Variant, Spider.SubType) < 3) then
                local vel = RandomVector() * 2;
                local spider = Isaac.Spawn(Spider.Type, Spider.Variant, Spider.SubType, sourcePos, vel, doremy):ToNPC();
                spider.State = 6;
                spider.V1 = vel;
                spider.V2 = Vector(0, -10);
                spider:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
                SFXManager():Play(SoundEffect.SOUND_BOIL_HATCH);
            end
        end
    end
end


function SpellCard:End(doremy)
    local Spider = THI.Monsters.NightmareSpider;
    for _, ent in ipairs(Isaac.FindByType(Spider.Type, Spider.Variant, Spider.SubType)) do
        ent:Die();
    end
end

return SpellCard;