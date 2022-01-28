local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local WheelChair = {};

local Functions = {
    PostCrushNPC = {}
};
WheelChair.Callbacks = {
    WC_POST_CRUSH_NPC = "PostCrushNPC"
}

WheelChair.HitboxType = Isaac.GetEntityTypeByName("Wheelchair Hitbox");
WheelChair.HitboxVariant = Isaac.GetEntityVariantByName("Wheelchair Hitbox");
WheelChair.HitboxSubType = 5555;

WheelChair.SpeedUpSpeed = 0.005;
WheelChair.SpeedDownSpeed = 0.08;
WheelChair.MeterVariant = Isaac.GetEntityVariantByName("Komeiji Meter");

local function LimitVelocity(vel, maxSpeed)
    local dir = vel:Normalized();
    local spd = vel:Length();
    spd = math.min(maxSpeed, math.max(0, spd));
    vel = dir * spd;
    return vel;
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
        if (not data.Hitbox or not data.Hitbox:Exists()) then
            data.Hitbox = Isaac.Spawn(self.HitboxType, self.HitboxVariant, self.HitboxSubType, player.Position + player.Velocity, Vector.Zero, player);
        end

        data.Hitbox.Position = player.Position + player.Velocity;
        data.Hitbox.Velocity = player.Velocity;
        data.Hitbox:ClearEntityFlags(EntityFlag.FLAG_APPEAR);

        if (player.FrameCount % 6 <= 2) then
            player:SetColor(Color(1,1,1,1,0.5, 0, 0.5), 3, 99, true, true);
        end

        player:SetMinDamageCooldown(60);
        data.Charging = true;
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
    if (hitbox.SubType == WheelChair.HitboxSubType) then
        local spawner = hitbox.SpawnerEntity;
        if (spawner and spawner:Exists()) then
            local vel = spawner.Velocity;
            local speed = vel:Length();
            hitbox.Size = 20
            local player = spawner:ToPlayer();
            if (player) then
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

function WheelChair:PreHitboxCollision(hitbox, other, low)
    if (hitbox.SubType == WheelChair.HitboxSubType) then
        local spawner = hitbox.SpawnerEntity;
        if (spawner and spawner:Exists()) then
            local player = spawner:ToPlayer();
            local vel = spawner.Velocity;
            local speed = vel:Length();
            if (Detection.IsValidEnemy(other)) then
                local damage = speed;
                if (player and not player:IsDead()) then
                    local data = WheelChair.GetPlayerTempData(player, true);
                    -- if (data) then
                    --     multiplier = (data.SpeedUp - 0.5) * 2 * 3;
                    -- end
                    damage = 10 + 40 * (data.SpeedUp) * player.MoveSpeed * player.Damage;

                    other:TakeDamage(damage, 0, EntityRef(spawner), 0);
                    other:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE);
                    local player2Enemy = other.Position - spawner.Position;
                    if (other:HasMortalDamage()) then
                        data.SpeedUp = data.SpeedUp - other.HitPoints / damage;
                        SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
                        SFXManager():Play(SoundEffect.SOUND_BONE_SNAP);
                        other:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE);
                        Game():ShakeScreen(10);
                    else
                        data.SpeedUp = 0;
                        SFXManager():Play(SoundEffect.SOUND_PUNCH);
                        SFXManager():Play(SoundEffect.SOUND_ROCKET_EXPLOSION);
                        spawner:AddVelocity(-player2Enemy  * player.MoveSpeed / 3);
                        other:AddVelocity(player2Enemy * player.MoveSpeed);
                        Game():ShakeScreen(10);
                    end
                    WheelChair:PostCrushNPC(player, other:ToNPC(), damage);
                end
            elseif(other.Type == EntityType.ENTITY_PROJECTILE) then
                local proj = other:ToProjectile();
                if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                    if (player and not player:IsDead()) then
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

function WheelChair:Register(mod)
    --mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, self.PreNPCCollision);
    mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, self.PostHitboxUpdate, self.HitboxVariant);
    --mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, self.PreProjectileCollision);
    mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, self.PreHitboxCollision, self.HitboxVariant);
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, self.PostMeterUpdate, self.MeterVariant);
    mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, self.PostMeterRender, self.MeterVariant);
end

return WheelChair;