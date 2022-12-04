local Screen = CuerLib.Screen;
local SpiderBabyWeb = ModEntity("Spiderbaby Web", "SPIDERBABY_WEB");
SpiderBabyWeb.SubType = 5811;
SpiderBabyWeb.SlowColor = Color(1,1,1,1,0.5,0.5,0.5)
SpiderBabyWeb.Flags = {
    FIRE = 1,
    ICE = 1 << 1,
    ELEC = 1 << 2,
    POISON = 1 << 3
}

local function GetEffectTempData(effect, create)
    return SpiderBabyWeb:GetData(effect, create, function()
        return {
            LastDamageSource = 0
        }
    end)
end

local function FireRandomLaser(effect)

    local seed = Random();
    local distance = effect.Size * effect.Scale * (seed % 6 / 12 + 0.5);
    local direction = seed % 8 * 45;
    local startPos = effect.Position + Vector.FromAngle(direction) * distance;
    local targetPos = effect.Position + Vector.FromAngle(direction + 45) * distance;
    local laser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, LaserSubType.LASER_SUBTYPE_LINEAR, startPos, Vector.Zero, effect):ToLaser();
    laser.Timeout = 3;
    laser.OneHit = true;
    laser.CollisionDamage = effect.CollisionDamage / 2;
    laser.PositionOffset = Vector(0, -10);
    laser.Parent = effect.SpawnerEntity;
    laser.DisableFollowParent = true;

    local ent2Source = targetPos - startPos;
    if (ent2Source:Length() < 0.1) then
        ent2Source = Vector(0, 1);
    end
    laser.AngleDegrees = ent2Source:GetAngleDegrees();
    laser.MaxDistance = ent2Source:Length() + 10;
    laser.Position = laser.Position - ent2Source:Resized(10);
    laser.TearFlags = laser.TearFlags | TearFlags.TEAR_PIERCING;
end

local function UpdateSprite(effect)
    local spr = effect:GetSprite();
    local flags = effect.DamageSource;
    local fire = flags & SpiderBabyWeb.Flags.FIRE > 0;
    local ice = flags & SpiderBabyWeb.Flags.ICE > 0;
    local elec = flags & SpiderBabyWeb.Flags.ELEC > 0;
    local poison = flags & SpiderBabyWeb.Flags.POISON > 0;

    local originPath = "gfx/reverie/effects/spiderbaby_web.png";
    local paths = {originPath, "" ,"", "", "", ""};
    if (fire) then
        paths[5] = originPath;
        paths[6] = originPath;
    end
    if (ice) then
        paths[1] = "";
        paths[4] = originPath;
    end
    if (elec) then
        paths[3] = originPath;
    end
    if (poison) then
        paths[2] = originPath;
    end
    for i = 0, #paths - 1 do
        spr:ReplaceSpritesheet(i, paths[i + 1]);
    end
    spr:LoadGraphics();
    local data = GetEffectTempData(effect, true);
    data.LastDamageSource = effect.DamageSource;
end

local function PostEffectInit(mod, effect)
    if (effect.SubType == SpiderBabyWeb.SubType) then
        effect.Timeout = 300;
        effect.LifeSpan = 300;
        effect:SetColor(Color(1, 1, 1, 0, 0 ,0 ,0), 1, 0);
        effect.Scale = 1;
        effect.DamageSource = SpiderBabyWeb.Flags.FIRE;
        local spr = effect:GetSprite();
        spr:Play("Idle");
        UpdateSprite(effect);
    end
end
SpiderBabyWeb:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, SpiderBabyWeb.Variant);

local function PostEffectUpdate(mod, effect)
    if (effect.SubType == SpiderBabyWeb.SubType) then
        local spr = effect:GetSprite();
        local data = GetEffectTempData(effect, true);
        if (Game():GetRoom():HasWater()) then
            effect.DamageSource = effect.DamageSource & ~SpiderBabyWeb.Flags.FIRE;
        end
        if (data.LastDamageSource ~= effect.DamageSource) then
            UpdateSprite(effect);
        end

        if (effect.Timeout > 30) then
            
            if (effect:IsFrame(7,0)) then
                
                local flags = effect.DamageSource;
                local fire = flags & SpiderBabyWeb.Flags.FIRE > 0;
                local ice = flags & SpiderBabyWeb.Flags.ICE > 0;
                local elec = flags & SpiderBabyWeb.Flags.ELEC > 0;
                local poison = flags & SpiderBabyWeb.Flags.POISON > 0;
                for _, ent in ipairs(Isaac.FindInRadius(effect.Position, (effect.Size * effect.Scale), EntityPartition.ENEMY)) do
                    if (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        if (ent:IsActiveEnemy()) then
                            if (not ent:IsFlying()) then
                                local duration = 7;
                                if (ent:IsBoss()) then
                                    duration = 300;
                                end
                                ent:AddSlowing ( EntityRef(effect), duration, 0.8, SpiderBabyWeb.SlowColor )
                                
                                if (ent:IsVulnerableEnemy()) then
                                    if (ice) then
                                        ent:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0);
                                        ent:GetData().Reverie_FreezeTimeout = 1;
                                        ent:AddEntityFlags(EntityFlag.FLAG_ICE);
                                    end
                                    if (fire) then
                                        ent:TakeDamage(effect.CollisionDamage, DamageFlag.DAMAGE_FIRE, EntityRef(effect), 0);
                                        ent:AddBurn(EntityRef(effect), duration * 2, effect.CollisionDamage * 0.5)
                                    end
                                end
                                if (poison) then
                                    ent:AddPoison ( EntityRef(effect), duration * 2, effect.CollisionDamage * 0.5)
                                end
                            end
                        end
                    end
                end
                if (elec) then
                    for i = 1, 4 do
                        FireRandomLaser(effect);
                    end
                end
            end
            -- if (effect:IsFrame(30, 0)) then
            --     Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, effect.Position, Vector.Zero, effect);
            --     SFXManager():Play(SoundEffect.SOUND_BOIL_HATCH);
            -- end
        end
    end
end
SpiderBabyWeb:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, SpiderBabyWeb.Variant);




-- local function PostEffectRender(mod, effect, offset)
--     local spr = effect:GetSprite();
--     local pos = Screen.GetEntityOffsetedRenderPosition(effect, offset, SpiderBabyWeb.ReversedOffset);
--     print(pos);
--     spr:RenderLayer(0, pos + Vector(30, 0));
-- end
-- SpiderBabyWeb:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, PostEffectRender, SpiderBabyWeb.Variant);

return SpiderBabyWeb;