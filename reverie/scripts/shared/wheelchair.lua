local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local CompareEntity = Entities.CompareEntity;
local WheelChair = {};

local Functions = {
    PostCrushNPC = {}
};
WheelChair.Callbacks = {
    WC_POST_CRUSH_NPC = "PostCrushNPC"
}

WheelChair.HitboxType = Isaac.GetEntityTypeByName("Wheelchair Hitbox");
WheelChair.HitboxVariant = Isaac.GetEntityVariantByName("Wheelchair Hitbox");
WheelChair.HitboxSubType = 555;

WheelChair.SpeedUpSpeed = 0.005;
WheelChair.SpeedDownSpeed = 0.08;
WheelChair.MeterVariant = Isaac.GetEntityVariantByName("Komeiji Meter");

local CrushedEnemies = {};

local function LimitVelocity(vel, maxSpeed)
    local dir = vel:Normalized();
    local spd = vel:Length();
    spd = math.min(maxSpeed, math.max(0, spd));
    vel = dir * spd;
    return vel;
end

local function MovingTowards(player, target)
    local playerVel = player.Velocity;
    local playerPos = player.Position;
    local targetPos = target.Position;
    
    local player2Target = targetPos - playerPos;
    local sizeSum = player.Size + target.Size;
    local allowedAngleDiff = math.atan(sizeSum / player2Target:Length())
    local angleDiff = math.acos(playerVel:Normalized():Dot(player2Target:Normalized()));
    if (angleDiff <= allowedAngleDiff) then
        return true;
    end
    return false;
end

function WheelChair.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        if (not data._SATORI_WHEELCHAIR) then
            data._SATORI_WHEELCHAIR =  {
                SpeedUp = 0,
                RenderSpeedUp = 0,
                AdditionSpeed = Vector(0, 0),
                LastPositions = {},
                Charging = false,
                Hitbox = nil,
                Meter = nil
            };
        end
    end
    return data._SATORI_WHEELCHAIR;
end

function WheelChair:GetMaxSpeed(player)
    
    local data = self.GetPlayerTempData(player, false);
    if (data) then
        return player.MoveSpeed * 4.5 * data.SpeedUp;
    end
    return 0;
end

function WheelChair:IsOverHalfSpeed(player)
    local data = self.GetPlayerTempData(player, false);
    if (data) then
        --local maxSpeed = self:GetMaxSpeed(player)
        return data.SpeedUp >= 0.5;
    end
    return false;
end

function WheelChair:PlayerUpdate(player)
    local data = self.GetPlayerTempData(player, true);
    -- Update Meter.
    if (not data.Meter or not data.Meter:Exists()) then
        data.Meter = Isaac.Spawn(EntityType.ENTITY_EFFECT, WheelChair.MeterVariant, 0, player.Position, player.Velocity, player);
        data.Meter:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
        data.Meter:GetSprite():SetFrame("Disappear", 10000);
    end
    data.Meter.Position = player.Position;
    data.Meter.Velocity = player.Velocity;
    data.Meter.DepthOffset = 60;
end

function WheelChair:PlayerEffect(player)
    local movement = player:GetMovementVector();
    local data = self.GetPlayerTempData(player, true);

    local vel = player.Velocity;
    local currentSpeed = vel:Length();
    -- Check if player stands too long.
    -- used to check if player is in the corner.
    local movedDistance = 0;
    for i, pos in pairs(data.LastPositions) do
        local newerPos;
        if (i == 1) then
            newerPos = player.Position;
        else
            newerPos = data.LastPositions[i];
        end
        local distance = pos:Distance(newerPos);
        if (pos:Distance(newerPos) > movedDistance) then
            movedDistance = distance;
        end
    end

    
    local maxAdditionSpeed = math.min(4.5 * player.MoveSpeed, movedDistance, currentSpeed, (player.MoveSpeed * 9 - vel:Length()) * data.SpeedUp);
    maxAdditionSpeed = math.max(0, maxAdditionSpeed);
    data.AdditionSpeed = LimitVelocity(data.AdditionSpeed, maxAdditionSpeed);
    data.AdditionSpeed = data.AdditionSpeed * (movement:Length() * 0.2 + 0.8)

    player.Velocity = vel + data.AdditionSpeed;
    
    
    if (movement:Length() > 0 and movedDistance > 0.05) then
        if (data.SpeedUp < 1) then
            data.SpeedUp = data.SpeedUp + self.SpeedUpSpeed;
            data.SpeedUp = math.min(1, math.max(0, data.SpeedUp));
        end
        

        local addVel = data.AdditionSpeed;
        local moveSpeed = player.MoveSpeed;
        data.AdditionSpeed = addVel + movement * moveSpeed;

    else
        if (data.SpeedUp > 0) then
            data.SpeedUp = data.SpeedUp - self.SpeedDownSpeed;
            data.SpeedUp = math.min(1, math.max(0, data.SpeedUp));
        end
    end

    if (self:IsOverHalfSpeed(player)) then
        data.Charging = true;
        if (not data.Hitbox or not data.Hitbox:Exists()) then
            data.Hitbox = Isaac.Spawn(self.HitboxType, self.HitboxVariant, self.HitboxSubType, player.Position + player.Velocity, Vector.Zero, player);
        end

        local hitBox = data.Hitbox
        hitBox.Position = player.Position + player.Velocity;
        hitBox.Velocity = player.Velocity;
        hitBox.Parent = player;
        hitBox:ClearEntityFlags(EntityFlag.FLAG_APPEAR);

        -- Invincible.
        local movingTowardsEnemy = false;
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (ent:IsEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and MovingTowards(player, ent) and player.Position:Distance(ent.Position) < ent.Size + player.Size + 120) then
                movingTowardsEnemy = true;
            end
        end
        if (movingTowardsEnemy) then
            if (player.FrameCount % 6 <= 2) then
                player:SetColor(Color(1,1,1,1,0.5, 0, 0.5), 3, 99, true, true);
            end
            player:SetMinDamageCooldown(1);
        end
    else
        data.Charging = false;
    end

    -- Record LastPositions.
    local maxPositionRecords = 5;
    table.insert(data.LastPositions, 1, player.Position);
    if (#data.LastPositions > maxPositionRecords) then
        
        table.remove(data.LastPositions, maxPositionRecords);
    end

    data.RenderSpeedUp = data.RenderSpeedUp + (data.SpeedUp - data.RenderSpeedUp) * 0.5;

end

function WheelChair:PostHitboxUpdate(hitbox)
    if (hitbox.Variant == WheelChair.HitboxVariant and hitbox.SubType == WheelChair.HitboxSubType) then
        local spawner = hitbox.SpawnerEntity;
        if (spawner and spawner:Exists()) then
            local vel = spawner.Velocity;
            local speed = vel:Length();
            hitbox.Size = 20
            local player = spawner:ToPlayer();
            if (player) then
                hitbox.TearFlags = player.TearFlags;
                local data = WheelChair.GetPlayerTempData(player, false);
                if (not WheelChair:IsOverHalfSpeed(player) or not CompareEntity(hitbox, data.Hitbox)) then
                    hitbox:Remove();
                end
            else
                hitbox:Remove();
            end
        end
    end
end

-- function WheelChair:PreProjectileCollision(projectile, other, low)
--     if (not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
--         local otherPlayer = other:ToPlayer();
--         if (otherPlayer) then
--             if (WheelChair:IsOverHalfSpeed(otherPlayer)) then
                
--                 local data = WheelChair.GetPlayerTempData(otherPlayer, false);
--                 if (data) then
--                     data.SpeedUp = data.SpeedUp - 0.1;
--                 end
--                 projectile:Die();
--                 return false;
--             end
--         end
--     end
-- end

function WheelChair:AddCallback(mod, callback, func)
    local info = {
        Mod = mod,
        Func = func
    }
    table.insert(Functions[callback], info);
end

function WheelChair:PostCrushNPC(player, npc, damage)
    for i, info in pairs(Functions.PostCrushNPC) do
        info.Func(info.Mod, player, npc, damage);
    end
end


local function PreTakeDamage(mod, tookDamage, amount , flags, source, countdown)
    local srcEnt = source.Entity;
    if (srcEnt and srcEnt.Type == WheelChair.HitboxType and srcEnt.Variant == WheelChair.HitboxVariant and srcEnt.SubType == WheelChair.HitboxSubType) then
        return false;
    end
end

function WheelChair:Crush(npc, damage, source)
    local player = source:ToPlayer();
    npc:TakeDamage(damage, 0, EntityRef(source), 0);
    npc:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE);
    if (npc:HasMortalDamage()) then
        SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
        SFXManager():Play(SoundEffect.SOUND_BONE_SNAP);
        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE);

        local otherSpr = npc:GetSprite();
        table.insert(CrushedEnemies, { 
            Entity = npc, 
            Time = 5, 
            Sprite = otherSpr:GetFilename(), 
            Animation = otherSpr:GetAnimation(),
            Frame = otherSpr:GetFrame(),
            OverlayAnimation = otherSpr:GetOverlayAnimation(),
            OverlayFrame = otherSpr:GetOverlayFrame(),
            Scale = npc.SpriteScale,
            Rotation = npc.SpriteRotation,
            Color = npc:GetColor()
        })

        Game():ShakeScreen(10);
    else
        SFXManager():Play(SoundEffect.SOUND_PUNCH);
        SFXManager():Play(SoundEffect.SOUND_ROCKET_EXPLOSION);
        Game():ShakeScreen(10);
    end
    WheelChair:PostCrushNPC(source, npc, damage);
end

function WheelChair:PostHitboxCollision(hitbox, other, low)
    if (hitbox.Variant == WheelChair.HitboxVariant and hitbox.SubType == WheelChair.HitboxSubType) then
        local spawner = hitbox.SpawnerEntity;
        if (spawner and spawner:Exists()) then
            local player = spawner:ToPlayer();
            local vel = spawner.Velocity;
            local speed = vel:Length();
            if (Entities.IsValidEnemy(other)) then
                local damage = speed;
                if (player and not Players:IsDead(player)) then
                    local data = WheelChair.GetPlayerTempData(player, true);
                    -- if (data) then
                    --     multiplier = (data.SpeedUp - 0.5) * 2 * 3;
                    -- end
                    damage = 10 + 140 * (data.SpeedUp) * player.MoveSpeed * (player.Damage / 3.5) ^ 0.5;

                    WheelChair:Crush(other, damage, spawner)
                    if (other:HasMortalDamage()) then
                        data.SpeedUp = data.SpeedUp - other.HitPoints / damage;
                    else
                        local player2Enemy = other.Position - spawner.Position;
                        data.SpeedUp = 0;
                        spawner:AddVelocity(-player2Enemy  * player.MoveSpeed / 3);
                        other:AddVelocity(player2Enemy * player.MoveSpeed);
                    end
                end
            elseif(other.Type == EntityType.ENTITY_PROJECTILE) then
                local proj = other:ToProjectile();
                if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                    if (player and not Players:IsDead(player)) then
                        local data = WheelChair.GetPlayerTempData(player, true);
                        data.SpeedUp = data.SpeedUp - 0.2;
                        proj:Die();
                    end
                end
            end
        end
    end
end

function WheelChair:PostMeterUpdate(effect)
    local player = effect.SpawnerEntity;
    if (player) then
        local data = WheelChair.GetPlayerTempData(player, false);
        if (data) then
            local meterSprite = effect:GetSprite();
            
            if (data.RenderSpeedUp > 0.01) then
                if (data.RenderSpeedUp >= 0.999) then
                    local anim = meterSprite:GetAnimation();
                    if (anim ~= "StartCharged" and anim ~= "Charged") then
                        meterSprite:Play("StartCharged");
                    end
                    if (meterSprite:IsFinished("StartCharged")) then
                        meterSprite:Play("Charged");
                    end
                else
                    meterSprite:SetFrame("Charging", math.floor(data.RenderSpeedUp * 100));
                end
            else
                meterSprite:Play("Disappear");
            end
        end
    end
end

function WheelChair:PostMeterRender(effect, offset)
    local player = effect.SpawnerEntity;
    if (player) then
        effect.SpriteScale = Vector(1, 1);
        local room = Game():GetRoom();
        local pos = Isaac.WorldToScreen(player.Position + player.PositionOffset + Vector(-25, -50)) + offset - room:GetRenderScrollOffset() - Game().ScreenShakeOffset;
        effect:GetSprite():Render(pos);
        effect.SpriteScale = Vector(0, 0);
    end
end

local function PostUpdate(mod)
    for i = #CrushedEnemies, 1, -1 do
        local info = CrushedEnemies[i];
        if (info) then
            local ent = info.Entity;
            if (ent and ent:IsDead() and not ent:Exists()) then
                local image = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, 0, ent.Position, Vector.Zero, ent);
                local spr = image:GetSprite();
                spr:Load(info.Sprite, true);
                spr:SetFrame(info.Animation, info.Frame);
                spr:SetOverlayFrame(info.OverlayAnimation, info.OverlayFrame);
                image.SpriteScale = Vector(1 * info.Scale.X, 0.3 * info.Scale.Y);
                image.SpriteRotation = info.Rotation;
                spr.Color = info.Color;
                image:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR);
                table.remove(CrushedEnemies, i);
            else 
                if (info.Time < 0) then
                    table.remove(CrushedEnemies, i);
                else
                    info.Time = info.Time - 1;
                end
            end
        end
    end
end

function WheelChair:Register(mod)
    --mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, self.PreNPCCollision);
    mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, self.PostHitboxUpdate);
    --mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, self.PreProjectileCollision);
    mod:AddPriorityCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, CallbackPriority.LATE, self.PostHitboxCollision);
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDamage);
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, self.PostMeterUpdate, self.MeterVariant);
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, self.PostMeterRender, self.MeterVariant);
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);
end

return WheelChair;