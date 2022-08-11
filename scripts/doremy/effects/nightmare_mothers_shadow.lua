local Dream = GensouDream;
local Detection = CuerLib.Detection;
local MothersShadow = {
    Type = Isaac.GetEntityTypeByName("Nightmare Mother's Shadow"),
    Variant = Isaac.GetEntityVariantByName("Nightmare Mother's Shadow"),
    SubType = 0
}

function MothersShadow:StartCharge(entity)
    local effect= entity:ToEffect();
    effect.State = effect.State | 1;
    local right = effect.State & 2 > 0;
    local spr = effect:GetSprite();
    spr:Play("Attack")
    local vel = Vector(-2, 0);
    if (right) then
        vel.X = - vel.X;
    end
    entity.Velocity = vel;
end

function MothersShadow:FindTarget(entity)
    local target = nil;
    if (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        local nearest = nil;
        local nearestDis = 0;
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (not ent:IsVulnerableEnemy()) then
                local dis = ent.Position:Distance(entity.Position);
                if (not nearest or dis < nearestDis) then
                    nearest = ent;
                    nearestDis = dis;
                end
            end
        end
        if (nearest) then
            target = nearest;
        end
    else
        local nearest = nil;
        local nearestDis = 0;
        for p, player in Detection.PlayerPairs(true) do
            if (not player:IsInvincible()) then
                local dis = player.Position:Distance(entity.Position);
                if (not nearest or dis < nearestDis) then
                    nearest = player;
                    nearestDis = dis;
                end
            end
        end
        if (nearest) then
            target = nearest;
        end
    end
    return target;
end

function MothersShadow:DamageEntities(entity)
    if (entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        for _, entity in ipairs(Isaac.FindInRadius(entity.Position, entity.Size, EntityPartition.ENEMY)) do
            if (entity:IsActiveEnemy()) then
                entity:TakeDamage(100, 0, EntityRef(entity), 0);
            end
        end
    else
        for _, player in ipairs(Isaac.FindInRadius(entity.Position, entity.Size, EntityPartition.PLAYER)) do
            player:TakeDamage(2, 0, EntityRef(entity), 60);
        end
    end
end

local function PostEffectInit(mod, effect)
    local spr = effect:GetSprite();
    spr:Play("Idle");
    SFXManager():Play(SoundEffect.SOUND_MOTHERSHADOW_APPEAR);
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, MothersShadow.Variant);

local function PostEffectUpdate(mod, effect)
    local spr = effect:GetSprite();
    local game = Game();
    local room = game:GetRoom();
    local center = room:GetCenterPos();

    local state = effect.State;
    local right = state & 2 > 0;
    if (state & 1 > 0) then -- Charge.
        if (spr:IsEventTriggered("Sound")) then
            SFXManager():Play(SoundEffect.SOUND_MOTHERSHADOW_CHARGE_UP)
        end
        if (spr:IsEventTriggered("Shoot")) then
            SFXManager():Play(SoundEffect.SOUND_MOTHERSHADOW_DASH)
            local vel = Vector(25, 0);
            if (right) then
                vel.X = -vel.X;
            end
            effect.Velocity = vel;
        end
        if (spr:WasEventTriggered("Shoot")) then
            if (effect.FrameCount % 3 == 0) then
                local Trail = Dream.Effects.NightmareTrail;
                local trail = Trail:SpawnTrail(effect);
                trail.DepthOffset = -10;
            end
        end
        if (spr:IsFinished("Attack")) then
            spr:Play("Idle");
            effect.State = ~effect.State;
        end
    else
        if (effect.FrameCount % 10 == 0) then
            effect.Target = MothersShadow:FindTarget(effect);
        end
        local target = Vector.Zero;
        if (effect.Target) then
            local x = 0;
            if (right) then
                x = room:GetGridWidth() * 40 + 40;
            end
            target = Vector(x, effect.Target.Position.Y)
        end
        effect.Velocity = (target - effect.Position) * 0.1
    end
    MothersShadow:DamageEntities(effect);
    -- if (effect.FrameCount % 3 == 0) then
    --     local trail = Dream.Effects.NightmareTrail;
    --     trail:SpawnTrail(effect);
    -- end
end
Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, MothersShadow.Variant);


return MothersShadow;