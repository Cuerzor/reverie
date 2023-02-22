local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local Math = CuerLib.Math;
local Grids = CuerLib.Grids;
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;
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
local function MomsKnifeSynergy(player)
    local data = WheelChair:GetPlayerTempData(player, true);
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
        local rotation = player:GetSmoothBodyRotation ( );
        local rotVec = Vector.FromAngle(rotation)
        local pos = player.Position + rotVec:Resized(player.Size + 12);
        local pos1 = pos + rotVec:Rotated(90) * 8;
        local pos2 = pos + rotVec:Rotated(90) * -8;

        if (not EntityExists(data.MomsKnife1)) then
            data.MomsKnife1 = Isaac.Spawn(EntityType.ENTITY_KNIFE, 0, 55555, pos1, Vector.Zero, player):ToKnife();
            data.MomsKnife1.Parent = player;
        end
        if (not EntityExists(data.MomsKnife2)) then
            data.MomsKnife2 = Isaac.Spawn(EntityType.ENTITY_KNIFE, 0, 55555, pos1, Vector.Zero, player):ToKnife();
            data.MomsKnife2.Parent = player;
            data.MomsKnife2.FlipX = true;
        end
        data.MomsKnife1.Position = pos1;
        data.MomsKnife2.Position = pos2;

        data.MomsKnife1.Velocity = pos1 - data.MomsKnife1.Position;
        data.MomsKnife2.Velocity = pos2 - data.MomsKnife2.Position;

        data.MomsKnife1.Rotation = rotation;
        data.MomsKnife2.Rotation = rotation;
        
        data.MomsKnife1.SpriteRotation = rotation - 90;
        data.MomsKnife2.SpriteRotation = -(rotation - 90);
    else
        if (EntityExists(data.MomsKnife1)) then
            data.MomsKnife1:Remove();
        end
        if (EntityExists(data.MomsKnife2)) then
            data.MomsKnife2:Remove();
        end
    end
end

local function MontezumaSynergy(player)
    local data = WheelChair:GetPlayerTempData(player, false);
    if (data) then
        data.MontezumaLaser = false;
    end
    local monteLaser = nil;
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER, LaserVariant.THICK_BROWN)) do
        local laser = ent:ToLaser();
        if (CompareEntity(ent.Parent, player) and not laser.Shrink) then
            monteLaser = laser;
            break;
        end
    end
    if (monteLaser) then
        data = WheelChair:GetPlayerTempData(player, true);
        data.MontezumaLaser = monteLaser;
        data.SpeedUp = 1;

        player.Velocity = player.Velocity - Vector.FromAngle(monteLaser.AngleDegrees);
    end
end

local function AntiGravitySynergy(player)
    local data = WheelChair:GetPlayerTempData(player, false);
    if (data) then
        if (data.DelayCrushCooldown and data.DelayCrushCooldown >= 0) then
            data.DelayCrushCooldown = data.DelayCrushCooldown - 1;
        end

        if (player:GetMovementVector():Length() < 0.1 and player.Velocity:Length() < 1) then
            if (data.DelayedCrushes and #data.DelayedCrushes > 0) then
                data.CrushQueue = data.CrushQueue or {};
                for i = 1, #data.DelayedCrushes do
                    local crushData = data.DelayedCrushes[i];
                    table.insert(data.CrushQueue, crushData);
                    data.DelayedCrushes[i] = nil;
                end
            end
        end 

        local queue = data.CrushQueue;
        if (queue and #queue > 0) then
            local index = 1;
            while (#queue >= index) do
                local crushData = queue[index];
                if (crushData and EntityExists(crushData.Target)) then
                    if (crushData.Target:IsVulnerableEnemy()) then
                        WheelChair:Crush(crushData.Target, crushData.Damage, crushData.Source, crushData.Slice);
                        WheelChair:ApplyCrushEffects(crushData.Target, crushData.Target.Position, crushData.Damage, crushData.TearFlags or 0, player);    
                        table.remove(queue, index);
                        break;
                    else
                        index = index + 1;
                        goto continue;
                    end
                end
                table.remove(queue, index);
                ::continue::
            end
        end
    end
end

local function TechnologySynergy(player, hitbox)
    if (hitbox:IsFrame(20, 0)) then
        local targetEnemy = nil;
        local targetDis = 0;
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (Entities.IsValidEnemy(ent)) then
                local dis = ent.Position:DistanceSquared(player.Position);
                if (not targetEnemy or dis < targetDis) then
                    targetEnemy = ent;
                    targetDis = dis;
                end
            end
        end
        if (targetEnemy) then
            local pos = hitbox.Position + player.Velocity:Resized(40) * 2;
            local angle = (targetEnemy.Position - player.Position):GetAngleDegrees();

            local laser = EntityLaser.ShootAngle(2, hitbox.Position, angle, -1, Vector(0, -24), player);

            laser:SetColor(player.LaserColor, -1, 0);
            laser:AddTearFlags(hitbox:ToKnife().TearFlags);

            laser.CollisionDamage = player.Damage * 2;
            --laser.SubType = LaserSubType.LASER_SUBTYPE_NO_IMPACT;
            laser.Timeout = 10;
            laser.PositionOffset = Vector.Zero;
            laser.MaxDistance = 80;
            laser.DisableFollowParent = true;
            laser.Velocity = Vector.FromAngle(angle):Resized(40);
            laser:Update();
            SFXManager():Play(THI.Sounds.SOUND_SCIFI_LASER, 0.5, 0, false, 2);
        end
    end
end

local function PeppersSynergy(player, hitbox)
    local ghostPepper = player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER);
    local birdsEye = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE);
    local hitBoxData = WheelChair:GetHitboxData(hitbox, true);
    if (not hitBoxData.PepperCooldown or hitBoxData.PepperCooldown <= 0) then
        if (ghostPepper) then
            local pos = player.Position;
            local vel = player.Velocity:Rotated(THI.RandomFloat(-10, 10)):Resized(THI.RandomFloat(-10, -5));
            local tear = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, vel, player):ToEffect();
            tear.Timeout = 30;
            tear.LifeSpan = 30;
            tear.CollisionDamage = player.Damage * 3;
        end
        if (birdsEye) then
            local pos = player.Position;
            local vel = player.Velocity:Rotated(THI.RandomFloat(-10, 10)):Resized(THI.RandomFloat(-10, -5));
            local tear = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, pos, vel, player):ToEffect();
            tear.Timeout = 60;
            tear.LifeSpan = 60;
            tear.CollisionDamage = player.Damage * 4;
        end
        
        local cooldown = math.max(2, 12-player.Luck) / 2;
        if (birdsEye and ghostPepper) then
            cooldown = math.max(2, 8-player.Luck) / 2;
        end
        hitBoxData.PepperCooldown = (hitBoxData.PepperCooldown or 0) + cooldown;
    else
        hitBoxData.PepperCooldown = hitBoxData.PepperCooldown - 1;
    end
end

function WheelChair:GetPlayerTempData(player, init)
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
function WheelChair:GetNPCData(npc, init)
    local data = npc:GetData();
    if (init and not data._SATORI_WHEELCHAIR) then
        data._SATORI_WHEELCHAIR =  {};
    end
    return data._SATORI_WHEELCHAIR;
end

function WheelChair:GetHitboxData(hitbox, init)
    local data = hitbox:GetData();
    if (init) then
        if (not data._SATORI_WHEELCHAIR) then
            data._SATORI_WHEELCHAIR =  {
                Tech2Laser = nil
            };
        end
    end
    return data._SATORI_WHEELCHAIR;
end

function WheelChair:GetMaxSpeed(player)
    
    local data = self:GetPlayerTempData(player, false);
    if (data) then
        return player.MoveSpeed * 2 * data.SpeedUp;
    end
    return 0;
end

function WheelChair:IsOverHalfSpeed(player)
    local data = self:GetPlayerTempData(player, false);
    if (data) then
        --local maxSpeed = self:GetMaxSpeed(player)
        return data.SpeedUp >= 0.5;
    end
    return false;
end

function WheelChair:GetSpeedUpMultiplier(player)
    local tears = 30 / (math.max(player.MaxFireDelay, -0.75) + 1);
    return (0.0213 * tears ^ 2 + 0.851);
end

function WheelChair:PlayerUpdate(player)
    local data = self:GetPlayerTempData(player, true);
    -- Update Meter.
    if (not data.Meter or not data.Meter:Exists()) then
        data.Meter = Isaac.Spawn(EntityType.ENTITY_EFFECT, WheelChair.MeterVariant, 0, player.Position, player.Velocity, player);
        data.Meter:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
        data.Meter:GetSprite():SetFrame("Disappear", 10000);
    end
    data.Meter.Position = player.Position;
    data.Meter.Velocity = player.Velocity;
    data.Meter.DepthOffset = 60;

    -- Mom's Knife Synergy.
    MomsKnifeSynergy(player);

    -- Montezuma's Revenge Synergy.
    MontezumaSynergy(player);

    -- Anti-Gravity Synergy.
    AntiGravitySynergy(player);
end

function WheelChair:PlayerEffect(player)
    local movement = player:GetMovementVector();
    local data = self:GetPlayerTempData(player, true);

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
        if (distance > movedDistance) then
            movedDistance = distance;
        end
    end

    
    local normalMaxSpeed = (player.MoveSpeed + 3) * 0.9;
    local maxAdditionSpeed = 0.5 * normalMaxSpeed;
    maxAdditionSpeed = math.min(maxAdditionSpeed, movedDistance);
    maxAdditionSpeed = math.min(maxAdditionSpeed, currentSpeed);
    maxAdditionSpeed = math.min(maxAdditionSpeed, (normalMaxSpeed * 1.5 - vel:Length()) * data.SpeedUp);
    maxAdditionSpeed = math.max(0, maxAdditionSpeed);
    data.AdditionSpeed = LimitVelocity(data.AdditionSpeed, maxAdditionSpeed);
    data.AdditionSpeed = data.AdditionSpeed * (movement:Length() * 0.2 + 0.8)

    player.Velocity = vel + data.AdditionSpeed;
    
    
    if (movement:Length() > 0 and movedDistance > 0.05) then
        if (data.SpeedUp < 1) then
            local speedUpSpeed = self.SpeedUpSpeed;
            local speedUpMulti = WheelChair:GetSpeedUpMultiplier(player);
            data.SpeedUp = data.SpeedUp + speedUpSpeed * speedUpMulti;
            data.SpeedUp = math.min(1, math.max(0, data.SpeedUp));
        end
        

        local addVel = data.AdditionSpeed;
        local moveSpeed = player.MoveSpeed / 2 + 1;
        data.AdditionSpeed = addVel + movement * moveSpeed;

    else
        if (data.SpeedUp > 0) then
            data.SpeedUp = data.SpeedUp - self.SpeedDownSpeed;
            data.SpeedUp = math.min(1, math.max(0, data.SpeedUp));
        end
    end

    local playerEffects = player:GetEffects();
    -- Mars, A Pony, White Pony.
    if (playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) or
    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_PONY) or
    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY) or
    Reverie.Collectibles.BrutalHorseshoe:IsDashing(player)) then
        data.SpeedUp = 1;
    end

    local charging = self:IsOverHalfSpeed(player);
    if (charging) then
        data.Charging = true;
        if (not data.Hitbox or not data.Hitbox:Exists()) then
            data.Hitbox = Isaac.Spawn(self.HitboxType, self.HitboxVariant, self.HitboxSubType, player.Position + player.Velocity, Vector.Zero, player);
        end

        local hitBox = data.Hitbox
        hitBox.Position = player.Position + player.Velocity;
        hitBox.Velocity = player.Velocity;
        hitBox.Parent = player;
        hitBox:ClearEntityFlags(EntityFlag.FLAG_APPEAR);

        -- Technology Synergy.
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)) then
            TechnologySynergy(player, hitBox);
        end
        -- Tech X Synergy.
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
            if (hitBox:IsFrame(10, 0)) then
                local laser = player:FireTechXLaser (hitBox.Position, -player.Velocity:Resized(player.ShotSpeed * 10), 48, player, 0.5 )
            end
        end
        -- Ghost Pepper/Birds Eye Synergy.
        PeppersSynergy(player, hitBox);

        -- Invincible.
        local invincible = false;
        local SatoriB = Reverie.Players.SatoriB;
        if (player:GetPlayerType() == SatoriB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            invincible = true;
        else
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if (ent:IsEnemy() and 
                not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and 
                --MovingTowards(player, ent) and 
                player.Position:Distance(ent.Position) < ent.Size + player.Size + 40) then
                    invincible = true;
                end
            end
        end
        if (invincible) then
            player:SetMinDamageCooldown(5);
            if (player.FrameCount % 6 <= 2) then
                player:SetColor(Color(1,1,1,1,0.5, 0, 0.5), 3, 99, true, true);
            end
        end
    else
        data.Charging = false;
    end

    
    -- Technology 2 Synergy.
    if (charging and player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)) then
        local hitBox = data.Hitbox;
        if (hitBox) then
            
            local hitBoxData = WheelChair:GetHitboxData(hitBox, true);
            local angle = (player.Velocity):GetAngleDegrees();
            if (not EntityExists(hitBoxData.Tech2Laser)) then
                hitBoxData.Tech2Laser = EntityLaser.ShootAngle(2, hitBox.Position, angle, -1, Vector.Zero, player);
            end
            local tearParams = player:GetTearHitParams ( WeaponType.WEAPON_LASER, 0.13, 1, player);
            hitBoxData.Tech2Laser:SetColor(player.LaserColor, -1, 0);
            hitBoxData.Tech2Laser.TearFlags = tearParams.TearFlags;
            hitBoxData.Tech2Laser:SetActiveRotation (0, angle, Math.GetAngleDiff(hitBoxData.Tech2Laser.AngleDegrees, angle), false);
            hitBoxData.Tech2Laser.CollisionDamage = player.Damage * 0.13;
        end
    else
        local hitBox = data.Hitbox;
        if (hitBox) then
            local hitBoxData = WheelChair:GetHitboxData(hitBox, false);
            if (hitBoxData and hitBoxData.Tech2Laser) then
                hitBoxData.Tech2Laser:Remove();
                hitBoxData.Tech2Laser = nil
            end
        end
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
        local player;
        if (spawner and spawner:Exists()) then
            local vel = spawner.Velocity;
            local speed = vel:Length();
            hitbox.Size = 20
            player = spawner:ToPlayer();
            if (player) then
                hitbox.TearFlags = player.TearFlags;
                local data = WheelChair:GetPlayerTempData(player, false);
                if (not WheelChair:IsOverHalfSpeed(player) or not CompareEntity(hitbox, data.Hitbox)) then
                    hitbox:Remove();
                    return;
                end
            else
                hitbox:Remove();
                return;
            end
        end

        -- Terra Synergy.
        if (hitbox.TearFlags & TearFlags.TEAR_ROCK > 0) then
            local room = Game():GetRoom();
            for i = 1, 12 do
                local angle = i * 30;
                local pos = hitbox.Position + Vector.FromAngle(angle) * hitbox.Size;
                local index = room:GetGridIndex(pos);
                room:DestroyGrid(index, false);
                Grids:PushToBridge(hitbox.Position, index);
            end
        end
        -- Fire Mind Synergy.
        if (hitbox.TearFlags & TearFlags.TEAR_BURN > 0) then
            if (hitbox:IsFrame(2,0)) then
                local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, hitbox.Position - hitbox.Velocity, Vector.Zero, hitbox):ToEffect();
                flame.CollisionDamage =22;
                flame.Timeout = 30;
            end
        end
        -- Uranus Synergy.
        if (hitbox.TearFlags & TearFlags.TEAR_ICE > 0) then
            if (hitbox:IsFrame(2,0)) then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, hitbox.Position - hitbox.Velocity, Vector.Zero, hitbox):ToEffect();
                creep.CollisionDamage = (player and player.Damage or 3.5) * 0.66;
                creep.Timeout = 90;
            end
        end
    end
end

-- function WheelChair:PreProjectileCollision(projectile, other, low)
--     if (not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
--         local otherPlayer = other:ToPlayer();
--         if (otherPlayer) then
--             if (WheelChair:IsOverHalfSpeed(otherPlayer)) then
                
--                 local data = WheelChair:GetPlayerTempData(otherPlayer, false);
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

function WheelChair:Crush(npc, damage, source, slice)
    local player = source:ToPlayer();
    npc:TakeDamage(damage, 0, EntityRef(source), 0);
    npc:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE);
    if (npc:HasMortalDamage()) then
        SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
        if (not slice) then
            SFXManager():Play(SoundEffect.SOUND_BONE_SNAP);
        else
            SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS);
        end
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
        if (not slice) then
            SFXManager():Play(SoundEffect.SOUND_PUNCH);
            SFXManager():Play(SoundEffect.SOUND_ROCKET_EXPLOSION);
        else
            SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS);
            SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
            npc:BloodExplode ( );
        end
        Game():ShakeScreen(10);
    end
    WheelChair:PostCrushNPC(source, npc, damage);
end

function WheelChair:ApplyCrushEffects(npc, position, damage, tearFlags, player)
    if (tearFlags & TearFlags.TEAR_EXPLOSIVE > 0) then
        Game():BombExplosionEffects (position, damage, TearFlags.TEAR_POISON, player.TearColor, player);
    end
    -- Brimstone Synergy.
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) then
        local ball = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL, 0, position, Vector.Zero, player):ToEffect();
        ball.Parent = player;
        ball.CollisionDamage = player.Damage;
        ball:SetTimeout(20);
        ball:SetColor(player.LaserColor, -1, 0)
        SFXManager():Play(SoundEffect.SOUND_BLOOD_LASER)
    end
    -- Mom's Knife Synergy.
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
        npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT);
    end
    -- Monstro's Lung Synergy.
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)) then
        for i = 1, 28 do
            local vel = RandomVector() * (THI.RandomFloat(0.5, 2) * player.ShotSpeed * 10)
            local tear = player:FireTear (position, vel, true, true, false, player, 1);
            tear.Scale = tear.Scale * THI.RandomFloat(0.75, 1.5);
            tear.FallingAcceleration = THI.RandomFloat(1, 2);
            tear.FallingSpeed = THI.RandomFloat(-23.5, -15);
        end
    end
    if (tearFlags & TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP > 0) then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, position, Vector.Zero, player):ToEffect();
        
        local creepScale = 1;
		creep:GetSprite():SetFrame("BiggestBlood0"..creep.InitSeed % 6, 0)

		creep:SetTimeout(150)
        creep.Scale = creepScale
        creep.Size = creepScale
		creep.SpriteScale = Vector(4, 4);
		creep.CollisionDamage = 1;
        creep:Update();
    end
    if (tearFlags & TearFlags.TEAR_BONE > 0) then
        local npcData = WheelChair:GetNPCData(npc, false);
        if (not npcData or not npcData.BoneBroken) then
            npcData = WheelChair:GetNPCData(npc, true);
            npcData.BoneBroken = true;
            npc:AddFreeze (EntityRef(player), 90)
            local Effect = Reverie.Effects.BoneBreakEffect;
            Isaac.Spawn(Effect.Type, Effect.Variant, 0, npc.Position, Vector.Zero, npc);
            SFXManager():Play(Reverie.Sounds.SOUND_BONE_BREAK);
        end
    end
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
                if (player and not Players.IsDead(player)) then
                    local data = WheelChair:GetPlayerTempData(player, true);
                    -- if (data) then
                    --     multiplier = (data.SpeedUp - 0.5) * 2 * 3;
                    -- end

                    local damageScale = data.SpeedUp * 40 * player.MoveSpeed ^ 2 / 3.5;
                    local tearParams = player:GetTearHitParams ( WeaponType.WEAPON_KNIFE, damageScale, 1, hitbox);
                    hitbox:SetColor(tearParams.TearColor, -1, 0);
                    hitbox.TearFlags = tearParams.TearFlags;
                    damage = tearParams.TearDamage;
                    local playerEffects = player:GetEffects();
                    local willCrush = true;
                    local applyKnockback = true;
                    local slice = false;
                    
                    -- Mars, A Pony, White Pony.
                    if (playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) or 
                    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_PONY) or
                    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHITE_PONY) or
                    Reverie.Collectibles.BrutalHorseshoe:IsDashing(player)) then
                        applyKnockback = false;
                        damage = damage * 0.33;
                    end

                    -- Aries Synergy.
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_ARIES)) then
                        damage = damage + 25;
                    end
                    -- This is already applied in GetTearHitParams.
                    -- -- Proptosis Synergy.
                    -- if (hitbox.TearFlags & TearFlags.TEAR_SHRINK > 0) then
                    --     damage = damage * 3;
                    -- end
                    -- Mom's Knife Synergy.
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
                        damage = damage * 2;
                        slice = true;
                    end
                    -- Rainbow charges Synergy.
                    if ((playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN) or
                    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_UNICORN_STUMP) or
                    playerEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_GAMEKID)) and 
                    not other:IsBoss()) then
                        willCrush = false;
                        player:AddHearts(1);
                        SFXManager():Play(SoundEffect.SOUND_1UP);
                        other:Remove();
                    elseif (hitbox.TearFlags & TearFlags.TEAR_WAIT > 0) then
                        -- Anti Gravity Syngery.
                        willCrush = false;
                        local calcedHP = other.HitPoints
                        data.DelayedCrushes = data.DelayedCrushes or {};
                        for _, crushedData in ipairs(data.DelayedCrushes) do
                            if (CompareEntity(crushedData.Target, other)) then
                                calcedHP = calcedHP - crushedData.Damage;
                            end
                        end

                        -- while (not data.DelayCrushCooldown or data.DelayCrushCooldown <= 0) do
                            local crushData = {
                                Target = other,
                                Damage = damage,
                                Source = spawner,
                                TearFlags = hitbox.TearFlags,
                                Slice = slice
                            }
                            table.insert(data.DelayedCrushes, crushData);

                            data.SpeedUp = data.SpeedUp - math.max(0, math.min(data.SpeedUp, calcedHP / damage));
                            player:SetMinDamageCooldown(60);
                            if (applyKnockback and calcedHP > 0) then
                                local player2Enemy = (other.Position - spawner.Position):Normalized();
                                spawner:AddVelocity(player2Enemy * (-spawner.Velocity:Length() * 2));
                            end
                        --end
                    end

                    if (willCrush) then
                        WheelChair:Crush(other, damage, spawner, slice)

                        WheelChair:ApplyCrushEffects(other, hitbox.Position, damage, hitbox.TearFlags, player);
    
                        if (other:HasMortalDamage()) then
                            data.SpeedUp = data.SpeedUp - other.HitPoints / damage;
                        else
                            data.SpeedUp = 0;
                            if (applyKnockback) then
                                local player2Enemy = (other.Position - spawner.Position):Normalized();
                                local enemyKnockbackMulti = spawner.Velocity:Length();
                                if (player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS)) then
                                    enemyKnockbackMulti = enemyKnockbackMulti * 2;
                                end
                                other:AddVelocity(player2Enemy * enemyKnockbackMulti);
                                spawner.Velocity = -spawner.Velocity
                            end
                        end
                    end
                    
                end
            -- elseif(other.Type == EntityType.ENTITY_PROJECTILE) then
            --     local proj = other:ToProjectile();
            --     if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
            --         if (player and not Players.IsDead(player)) then
            --             local data = WheelChair:GetPlayerTempData(player, true);
            --             data.SpeedUp = data.SpeedUp / 2;
            --             proj:Die();
            --         end
            --     end
            elseif(other.Type == EntityType.ENTITY_BOMB) then
                -- Dr. Fetus Synergy.
                local bomb = other:ToBomb();
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) and bomb.FrameCount > 5) then
                    bomb.ExplosionDamage = bomb.ExplosionDamage+40;
                    bomb.CollisionDamage = bomb.ExplosionDamage
                    bomb:SetExplosionCountdown(60);

                    WheelChair:ApplyCrushEffects(other, hitbox.Position, player.Damage, hitbox.TearFlags, player)

                    SFXManager():Play(SoundEffect.SOUND_PUNCH);
                    SFXManager():Play(SoundEffect.SOUND_ROCKET_EXPLOSION);
                    local player2Enemy = (other.Position - spawner.Position):Normalized();
                    local enemyKnockbackMulti = spawner.Velocity:Length() * 2;
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS)) then
                        enemyKnockbackMulti = enemyKnockbackMulti * 2;
                    end
                    other:AddVelocity(player2Enemy * enemyKnockbackMulti);
                    spawner.Velocity = -spawner.Velocity;
                    
                end
            end
        end
    end
end

function WheelChair:PostMeterUpdate(effect)
    local player = effect.SpawnerEntity;
    if (player) then
        local data = WheelChair:GetPlayerTempData(player, false);
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

function WheelChair:PostNPCUpdate(npc)
    local npcData = WheelChair:GetNPCData(npc, false);
    if (npcData and npcData.BoneBroken) then
        npc.Velocity = npc.Velocity * 0.8;
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
    mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, self.PostNPCUpdate);
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);
end

return WheelChair;