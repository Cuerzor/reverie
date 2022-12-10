local Entities = CuerLib.Entities;
local Math = CuerLib.Math;
local Consts = CuerLib.Consts;
local Inputs = CuerLib.Inputs;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;
local CompareEntity = Entities.CompareEntity;
local Rebecha = ModEntity("Rebecha", "REBECHA");
Rebecha.MaxDestructCharge = 30;

Rebecha.MechaStates = {
    NONE = 0,
    ENTER = 1,
    DRIVE = 2,
    EXIT = 3
}
Rebecha.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_inside_rebecha.anm2");

Rebecha.DirectionAnimation = {
    [Direction.LEFT] = "Left",
    [Direction.LEFT] = "Left",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Right",
    [Direction.DOWN] = "Down"
}
Rebecha.HeartSprite = Sprite();
Rebecha.HeartSprite:Load("gfx/reverie/ui/ui_hearts.anm2", true);

local function GetPlayerData(player, create)
    return Rebecha:GetData(player, create, function() 
        return {
            HasCostume = false
        }
    end)
end

local function GetPlayerTempData(player, create)
    return Rebecha:GetTempData(player, create, function() 
        return {
            Mecha = nil,
            MechaState = Rebecha.MechaStates.NONE,
            HoldingDrop = false,
        }
    end)
end

local function GetMechaTempData(player, create)
    return Rebecha:GetData(player, create, function() 
        local chargeBar = Sprite();
        chargeBar:Load("gfx/chargebar.anm2", true)
        return {
            DamageCooldown = -1,
            Flying = false,
            SelfDestruction = false,
            SelfDestructionTimeout = -1,
            DestructCharge = 0,
            ChargeBarSprite = chargeBar
        }
    end)
end


local function GetBombTempData(bomb, create)
    return Rebecha:GetData(bomb, create, function() 
        return {
            Direction = Vector(1, 0)
        }
    end)
end

function Rebecha:GetPlayerMechaState(player)
    local playerData = GetPlayerTempData(player, false)
    return (playerData and playerData.MechaState) or Rebecha.MechaStates.NONE;
end

function Rebecha:GetMechaDamageCooldown(mecha)
    local data = GetMechaTempData(mecha, false)
    return (data and data.DamageCooldown) or -1;
end

function Rebecha:SetMechaDamageCooldown(mecha, value)
    local data = GetMechaTempData(mecha, true)
    data.DamageCooldown = value;
end


function Rebecha:GetMechaDestructCharge(mecha)
    local data = GetMechaTempData(mecha, false)
    return (data and data.DestructCharge) or 0;
end

function Rebecha:SetMechaDestructCharge(mecha, value)
    local data = GetMechaTempData(mecha, true)
    data.DestructCharge = value
end

function Rebecha:CanMechaDamaged(mecha, flags)
    flags = flags or 0;
    local player = self:GetMechaPlayer(mecha);
    if (player) then
        if (player:HasInvincibility(flags)) then
            return false;
        end
    end
    return Rebecha:GetMechaDamageCooldown(mecha) < 0 and mecha.FrameCount > 60 and not Rebecha:IsSelfDestruction(mecha);
end

function Rebecha:EnterMecha(player, mecha)
    local playerData = GetPlayerTempData(player, true)
    if (not playerData.Mecha and playerData.MechaState == Rebecha.MechaStates.NONE) then
        playerData.Mecha = mecha;
        mecha.Parent = player;
        playerData.MechaState = Rebecha.MechaStates.ENTER;
        player:PlayExtraAnimation("Trapdoor");
    end
end

function Rebecha:ExitMecha(player)
    local playerData = GetPlayerTempData(player, true)
    local mecha = playerData.Mecha;
    if (mecha and playerData.MechaState == Rebecha.MechaStates.DRIVE) then
        player.PositionOffset = Vector(0, -80);
        playerData.Mecha = nil;
        mecha.Parent = nil;
        playerData.MechaState = Rebecha.MechaStates.EXIT;
        player:AddCacheFlags(CacheFlag.CACHE_FLYING);
        player:EvaluateItems();
        Rebecha:SetPlayerMinDamageCooldown(player, 30);
    end
end

function Rebecha:GetPlayerMecha(player)
    local data = GetPlayerTempData(player, false)
    return (data and data.Mecha) or nil;
end

function Rebecha:GetMechaPlayer(mecha)
    return mecha.Parent and mecha.Parent:ToPlayer();
end
function Rebecha:GetMechaFlying(mecha)
    local data = GetPlayerTempData(mecha, false)
    return (data and data.Flying);
end

function Rebecha:SwitchMechaFlying(mecha)
    local data = GetPlayerTempData(mecha, true)
    data.Flying = not data.Flying;
end


function Rebecha:IsSelfDestruction(mecha)
    local data = GetPlayerTempData(mecha, false)
    return (data and data.SelfDestruction);
end
function Rebecha:GetSelfDestructionTimeout(mecha)
    local data = GetPlayerTempData(mecha, false)
    return (data and data.SelfDestructionTimeout) or -1;
end
function Rebecha:SetSelfDestructionTimeout(mecha, value)
    local data = GetPlayerTempData(mecha, true)
    data.SelfDestructionTimeout = value;
end
function Rebecha:StartSelfDestruction(mecha)
    local data = GetPlayerTempData(mecha, true)
    mecha:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT);
    local flying = Rebecha:GetMechaFlying(mecha);
    if (flying) then
        mecha.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS;
    else
        mecha.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND;
    end
    data.SelfDestruction = true;
    data.SelfDestructionTimeout = 60;
end

-- Player Type Compatibilities.

function Rebecha:GetMechaHeadDirection(mecha)
    local player = self:GetMechaPlayer(mecha);
    if (player) then
        local headDirection = player:GetHeadDirection()
        if (player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B) then
            local twin = player:GetOtherTwin();
            local fireDirection = twin:GetFireDirection();
            if (fireDirection ~= Direction.NO_DIRECTION) then
                return twin and twin:GetHeadDirection();
            end
        end
        return headDirection;
    end
    return Direction.NO_DIRECTION;
end

function Rebecha:SetPlayerMinDamageCooldown(player, value)
    if (player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B) then
        local twin = player:GetOtherTwin();
        twin:SetMinDamageCooldown(value);
    else
        player:SetMinDamageCooldown(value);
    end
end

function Rebecha:ResetPlayerDamageCooldown(player)
    if (player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B) then
        local twin = player:GetOtherTwin();
        twin:ResetDamageCooldown();
    else
        player:ResetDamageCooldown();
    end
end

function Rebecha:IsLeaveButtonTriggered(player)
    local playerType = player:GetPlayerType();
    if (playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU) then
        if (Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
            local data = GetPlayerTempData(player, true);
            data.HoldingDrop = true;
        else
            
            local data = GetPlayerTempData(player, false);
            if (data and data.HoldingDrop) then
                data.HoldingDrop = false;
                return true;
            end
        end
        return false;
    else
        return Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)
    end
end

function Rebecha:SpawnIdle(pos, mecha)
    local Idle = THI.Pickups.RebechaIdle;
    local idle = Isaac.Spawn(Idle.Type, Idle.Variant, Idle.SubType, pos, Vector.Zero, mecha.SpawnerEntity);
    idle.SubType = math.ceil(mecha.MaxHitPoints - mecha.HitPoints);
    idle:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    return idle;
end


-- Events.

local function PostPlayerUpdate(mod, player)
    local playerType = player:GetPlayerType();
    local tempData = GetPlayerTempData(player, false);
    local mechaExists = false;
    if (tempData) then
        local mecha = tempData.Mecha;
        mechaExists = mecha and mecha:Exists();
        if (mechaExists) then
            if (tempData.MechaState == Rebecha.MechaStates.ENTER) then
                player.Velocity = (mecha.Position - player.Position) / 4;
                player.PositionOffset = Vector(0, (-320 - player.PositionOffset.Y) / 4)
                Rebecha:SetPlayerMinDamageCooldown(player, 30);
                if (player:IsExtraAnimationFinished() or player:GetSprite():GetAnimation() ~= "Trapdoor") then
                    player.PositionOffset = mecha.PositionOffset;
                    tempData.MechaState = Rebecha.MechaStates.DRIVE;
                    mecha:GetSprite():Play("Launch");

                    local color = Consts.Colors.Clear;
                    player:SetColor(color, 2, -9999);
                    THI.SFXManager:Play(THI.Sounds.SOUND_SCIFI_MECH);
                end
            elseif (tempData.MechaState == Rebecha.MechaStates.DRIVE) then
                local mechaSpr = mecha:GetSprite();

                -- Fly.
                local flying = Rebecha:GetMechaFlying(mecha);
                player.CanFly = flying;
                if (flying) then
                    player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS;
                else
                    player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND;
                end

                -- Sprite.
                if (mechaSpr:IsPlaying("Launch") and not mechaSpr:IsFinished("Launch") or mecha:IsDead()) then
                    player.ControlsCooldown = math.max(player.ControlsCooldown, 1);
                    mechaSpr:RemoveOverlay();
                else
                    if (not Game():IsPaused() and not mecha:IsDead()) then
                        
                        local fireDirection = player:GetFireDirection();
                        local headDirection = Rebecha:GetMechaHeadDirection(mecha);
                        local moveDirection = player:GetMovementDirection();

                        if (flying) then
                            if (moveDirection == Direction.LEFT or moveDirection == Direction.RIGHT) then -- Hori.
                                mechaSpr:Play("FlyHori");
                            else -- Moving.
                                mechaSpr:Play("FlyVert");
                            end
                        else
                            if (moveDirection == Direction.NO_DIRECTION) then -- Not Moving
                                mechaSpr:Play("StandLegs");
                            else -- Moving.
                                mechaSpr:Play("Move"..Rebecha.DirectionAnimation[moveDirection]);
                            end
                        end

                        if (headDirection == Direction.NO_DIRECTION) then -- Not Shooting.
                            if (moveDirection == Direction.NO_DIRECTION) then
                                mechaSpr:PlayOverlay("StandDownHead");
                            else
                                if (flying) then
                                    mechaSpr:PlayOverlay("Stand"..Rebecha.DirectionAnimation[moveDirection].."Head");
                                else
                                    mechaSpr:PlayOverlay("Move"..Rebecha.DirectionAnimation[moveDirection].."Head");
                                end
                            end
                        else -- Shooting.
                            if (fireDirection == headDirection) then
                                mechaSpr:PlayOverlay("Shoot"..Rebecha.DirectionAnimation[headDirection].."Head")
                            else
                                mechaSpr:PlayOverlay("Stand"..Rebecha.DirectionAnimation[headDirection].."Head")
                            end
                        end
                    end 
                end
                mecha.Position = player.Position;
                mecha.Velocity = player.Velocity;

                
                -- local playerSpr = player:GetSprite();
                -- player:StopExtraAnimation();
                Rebecha:SetPlayerMinDamageCooldown(player, 3);

                if (player:HasEntityFlags(EntityFlag.FLAG_HELD)) then
                    mecha.DepthOffset = 6;
                else
                    mecha.DepthOffset = -6;
                end
                mecha.PositionOffset = player.PositionOffset + player:GetFlyingOffset();
                
                local color = Consts.Colors.Clear;
                player:SetColor(color, 2, -9999);

                if (mecha:IsDead()) then
                    player.Velocity = Vector.Zero;
                end
                -- Get out of Mecha
                if ((mecha:IsDead() and Rebecha:IsLeaveButtonTriggered(player)) or Players:IsDead(player)) then
                    Rebecha:ExitMecha(player);
                    player:PlayExtraAnimation("JumpOut");
                end
                
                if (player:AreControlsEnabled()) then
                    -- Fire gatlin.
                    local moveDir = player:GetMovementJoystick():Normalized();
                    local shooting = Inputs:GetShootingVector(player);
                    

                    if (shooting:Length() > 0.1) then
                        
                        if (player:IsFrame(2,0)) then
                            local pos = player.Position;
                            local fireDirection = Rebecha:GetMechaHeadDirection(mecha);
                            local offset = Consts.DirectionVectors[fireDirection]:Rotated(45) * Vector(48, 6)

                            pos = pos + offset;
                            local vel = shooting * 12;
                            vel = vel + player:GetTearMovementInheritance(vel);
                            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, pos, vel, player):ToTear();
                            THI.SFXManager:Play(SoundEffect.SOUND_BULLET_SHOT, 0.3);
                            tear.CollisionDamage = player.Damage * 0.5;
                            tear.Height = tear.Height - 10
                            if (flying) then
                                tear.Height = tear.Height - 23
                            end
                            tear.Scale = Math.GetTearScaleByDamage(tear.CollisionDamage);
    
                            local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, pos, Vector.Zero, player);
                            exp.SpriteScale = Vector(0.2,0.2);
                            exp.PositionOffset = tear.PositionOffset;
                        end
                    end
                    
                    -- Get out of Mecha
                    if (Rebecha:IsLeaveButtonTriggered(player)) then
                        Rebecha:ExitMecha(player);
                        player:PlayExtraAnimation("Jump");
                    end
                    
                    -- Bomb.
                    if (Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex)) then
                        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_BOMBDROP)) do
                            if (ent:Exists() and CompareEntity(ent.SpawnerEntity, player) and ent.Position:Distance(player.Position) < 80 and ent.FrameCount < 1) then
                                
                                local bomb = ent:ToBomb();
                                local flags = bomb.Flags;

                                local pos = player.Position;
                                local bombDir;
                                if (shooting:Length() > 0) then
                                    bombDir = shooting;
                                elseif (moveDir:Length() > 0) then
                                    bombDir = moveDir;
                                else
                                    bombDir = Vector(0, 1);
                                end
                                
                                local dir = Rebecha:GetMechaHeadDirection(mecha);
                                if (dir == Direction.NO_DIRECTION) then
                                    dir = player:GetMovementDirection();
                                end
                                if (dir == Direction.NO_DIRECTION) then
                                    dir = Direction.DOWN
                                end
                                local offset = Consts.DirectionVectors[dir]:Rotated(-45) * Vector(48, 6)
    
                                pos = pos + offset;

                                THI.SFXManager:Play(SoundEffect.SOUND_BULLET_SHOT);
                                --local bomb = player:FireBomb(pos, bombDir * 10, player);
                                -- ent.Position = pos;
                                local vel = bombDir;
                                vel = vel + player:GetTearMovementInheritance(vel) * 0.1;
                                -- ent.Velocity = vel;

                                local variant = BombVariant.BOMB_ROCKET;
                                if (bomb.Variant == BombVariant.BOMB_GIGA) then
                                    variant = BombVariant.BOMB_ROCKET_GIGA;
                                end
                                local newBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, variant, 0, pos, bombDir, player):ToBomb();
                                local bombData = GetBombTempData(newBomb, true);
                                bombData.Direction = vel;
                                newBomb:GetSprite().Rotation = vel:GetAngleDegrees();
                                newBomb:AddTearFlags(flags);
                                ent:Remove();
                                SFXManager():Play(SoundEffect.SOUND_ROCKET_LAUNCH);
                                break;
                            end
                        end
                    
                    end

                    -- Self Destruct.
                    local selfDestruct = false;
                    if (playerType == PlayerType.PLAYER_ESAU) then
                        selfDestruct = Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and 
                        Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)
                    elseif (playerType == PlayerType.PLAYER_JACOB) then
                        selfDestruct = Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and 
                        Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex)
                    else
                        selfDestruct = Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)
                    end
                    local charge = Rebecha:GetMechaDestructCharge(mecha);
                    if (selfDestruct) then
                        charge = charge + 1;
                        Rebecha:SetMechaDestructCharge(mecha, charge);
                        if (charge >= Rebecha.MaxDestructCharge) then
                            Rebecha:StartSelfDestruction(mecha);
                            Rebecha:ExitMecha(player);
                            player:PlayExtraAnimation("Jump");
                            Rebecha:SetMechaDestructCharge(mecha, 0);
                        end
                    else
                        if (charge > 0) then
                            Rebecha:SetMechaDestructCharge(mecha, 0);
                        end
                    end
                    
                    -- Fly.
                    local flyTriggered = false;
                    if (playerType == PlayerType.PLAYER_ESAU) then
                        flyTriggered = Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)
                    else
                        flyTriggered = Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex)
                    end
                    if (flyTriggered) then
                        Rebecha:SwitchMechaFlying(mecha);
                        if (flying) then
                            THI.SFXManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN);
                        else
                            THI.SFXManager:Play(SoundEffect.SOUND_FLAMETHROWER_END);
                        end
                    end
                end
            end
        else
            tempData.Mecha = nil;
            tempData.MechaState = Rebecha.MechaStates.NONE;
        end
        if (mecha and not mecha:Exists()) then
            player:AddCacheFlags(CacheFlag.CACHE_FLYING);
            player:EvaluateItems();
            Rebecha:SetPlayerMinDamageCooldown(player, 30);
        end

    end

    
    -- Add or Remove Costume.
    local data = GetPlayerData(player, false);
    local hasCostume = (data and data.HasCostume) or false;
    if (mechaExists ~= hasCostume) then
        if (mechaExists) then
            player:AddNullCostume(Rebecha.Costume);
        else
            player:TryRemoveNullCostume(Rebecha.Costume);
        end
        data = GetPlayerData(player, true);
        data.HasCostume = mechaExists;
    end
end
Rebecha:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);


local function InputAction(mod, entity, hook, action)
    local player = entity and entity:ToPlayer();
    if (player) then
        local mecha = Rebecha:GetPlayerMecha(player);
        if (mecha) then
            if (hook == InputHook.IS_ACTION_TRIGGERED) then
                if (action == ButtonAction.ACTION_PILLCARD) then
                    return false;
                elseif (action == ButtonAction.ACTION_ITEM) then
                    return false;
                elseif (action == ButtonAction.ACTION_DROP) then
                    return false;
                end
            end
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction);

local function PostRebechaInit(mod, rebecha)
    if (rebecha.Variant == Rebecha.Variant) then
        rebecha:AddEntityFlags( EntityFlag.FLAG_NO_STATUS_EFFECTS |EntityFlag.FLAG_CHARM|EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_DONT_OVERWRITE);
        rebecha.SplatColor = Color(0,0,0,1,0,0,0);
    end
end
Rebecha:AddCallback(ModCallbacks.MC_POST_NPC_INIT, PostRebechaInit, Rebecha.Type);

local function PostUpdate(mod)
    for i, ent in pairs(Isaac.FindByType(Rebecha.Type, Rebecha.Variant)) do
        local spr = ent:GetSprite();
        if (spr:IsEventTriggered("Beep")) then
            THI.SFXManager:Play(SoundEffect.SOUND_BEEP);
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);


local function PostBombUpdate(mod, bomb)
    local tempData = GetBombTempData(bomb, false);
    if (tempData) then
        bomb.Velocity = (tempData.Direction  + Vector(-0.15, 0)) * (1 + bomb.FrameCount);
        bomb:GetSprite().Rotation = tempData.Direction:GetAngleDegrees()
    end
end
Rebecha:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, PostBombUpdate, BombVariant.BOMB_ROCKET)

local function PostRebechaUpdate(mod, rebecha)
    if (rebecha.Variant == Rebecha.Variant) then
        local spr = rebecha:GetSprite();
        if (rebecha.FrameCount == 1) then
            spr:Play("Idle");
        end
        
        if (spr:IsEventTriggered("Step")) then
            THI.SFXManager:Play(SoundEffect.SOUND_POT_BREAK, 0.2)
        end

        local flying = Rebecha:GetMechaFlying(rebecha);
        if (flying) then
        else
            if (not Game():IsPaused()) then
                
                local room = Game():GetRoom();
                for i = 1, 12 do
                    local angle = i * 30;
                    local offset = Vector.FromAngle(angle) * rebecha.Size;
                    local pos = rebecha.Position + offset;
                    local index = room:GetGridIndex(pos);
                    local gridEntity = room:GetGridEntity(index);
                    if (gridEntity) then
                        room:DestroyGrid(index, false);
                    end
                end
            end
        end

        local selfDestruction = Rebecha:IsSelfDestruction(rebecha);
        if (not selfDestruction) then
            local driver = Rebecha:GetMechaPlayer(rebecha);
            if (not driver or not driver:Exists() or not CompareEntity(Rebecha:GetPlayerMecha(driver), rebecha)) then
                local idle = Rebecha:SpawnIdle(rebecha.Position, rebecha);
                THI.SFXManager:Play(SoundEffect.SOUND_METAL_DOOR_OPEN);
                idle:GetSprite():Play("Out");
                rebecha:Remove();
            end
        else
            local timeout = Rebecha:GetSelfDestructionTimeout(rebecha);
            local interval = 1;
            if (timeout > 60) then
                interval = 10;
            elseif (timeout > 30) then
                interval = 5;
            else
                interval = 2;
            end
            if (rebecha:IsFrame(interval, 0)) then
                rebecha:SetColor(Color(1,1,1,1,1,0.5,0), interval, 0, true);
                THI.SFXManager:Play(SoundEffect.SOUND_BEEP);
            end
            
            Rebecha:SetSelfDestructionTimeout(rebecha, timeout - 1);
            if (timeout < 0) then
                Game():BombExplosionEffects (rebecha.Position, 500, TearFlags.TEAR_NORMAL, Color.Default, nil, 1.5, true, true, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR )
                rebecha:BloodExplode();
                rebecha:Remove();
            end
        end

        -- Charge Bar Sprite.
        local charge = Rebecha:GetMechaDestructCharge(rebecha);
        local barSpr = GetMechaTempData(rebecha, true).ChargeBarSprite;
        if (charge > 0) then
            if(charge < Rebecha.MaxDestructCharge) then
                barSpr:SetFrame("Charging", math.floor(charge / Rebecha.MaxDestructCharge * 100));
            end
        else
            if (barSpr:GetAnimation() == "Charging") then
                barSpr:Play("Disappear");
            end
        end
        barSpr:Update();

        local cooldown = Rebecha:GetMechaDamageCooldown(rebecha);
        if (rebecha:IsDead() or selfDestruction) then
            cooldown = 0;
        end
        if (cooldown >= 0) then
            Rebecha:SetMechaDamageCooldown(rebecha, cooldown - 1);
            rebecha.Visible = rebecha:IsFrame(2,0) or cooldown < 1;
        end

        if (rebecha:IsDead()) then
            rebecha:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT);
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostRebechaUpdate, Rebecha.Type);

local function PreNPCCollision(mod, npc, other, low)
    if (npc.Type == Rebecha.Type and npc.Variant == Rebecha.Variant) then
        if (CompareEntity(other, npc.Parent)) then
            return true;
        end

        if (other.Type == EntityType.ENTITY_PROJECTILE) then
            -- Avoids that some friendly projectile hit the mecha.
            local projectile = other:ToProjectile();
            if (projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                return true;
            end
        elseif (other.Type == EntityType.ENTITY_FIREPLACE) then
            return true;
        else
            if (other:IsEnemy()) then
                if (other:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
                    print("Ignored.");
                    return true;
                end
            end
        end
    end
    if (other.Type == Rebecha.Type and other.Variant == Rebecha.Variant) then
        if (npc.Type == EntityType.ENTITY_POOP) then
                return true;
        elseif (npc.Type == EntityType.ENTITY_FROZEN_ENEMY) then
                return true;
        elseif (npc:IsEnemy()) then
            if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                return true;
            end
        end
    end

    
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local mecha = Rebecha:GetPlayerMecha(other);
        if (mecha) then
            return true;
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNPCCollision);


local function PostRebechaDeath(mod, entity)
    if (entity.Variant == Rebecha.Variant) then
        local player = Rebecha:GetMechaPlayer(entity);
        if (player)then
            Rebecha:ResetPlayerDamageCooldown(player);
        end
        Game():BombExplosionEffects (entity.Position, 500, TearFlags.TEAR_NORMAL, Color.Default, nil, 1.5, true, true, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR )
        entity:BloodExplode();
    end
end
Rebecha:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, PostRebechaDeath, Rebecha.Type);


local function PreBombCollision(mod, bomb, other, low)
    if (other.Type == Rebecha.Type and other.Variant == Rebecha.Variant) then
        if (bomb.Type == EntityType.ENTITY_BOMB) then
            if (CompareEntity(bomb.SpawnerEntity, other.Parent)) then
                return true;
            end
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, PreBombCollision);

local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
        if (amount > 0) then
            local player = tookDamage:ToPlayer();
            local mecha = Rebecha:GetPlayerMecha(player);
            if (mecha and mecha:Exists()) then
                mecha:TakeDamage(1, flags, source, countdown);
                return false;
            end
        end
    elseif (tookDamage.Type == Rebecha.Type and tookDamage.Variant == Rebecha.Variant) then
        local sourceType = source.Type;
        local variant = source.Variant;

        if (sourceType == EntityType.ENTITY_EFFECT and (
        variant == EffectVariant.CREEP_RED or
        variant == EffectVariant.CREEP_GREEN or
        variant == EffectVariant.CREEP_YELLOW or
        variant == EffectVariant.CREEP_WHITE or
        variant == EffectVariant.CREEP_BLACK) or 
        (sourceType == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_SPIKEDCHEST) or 
        (sourceType == EntityType.ENTITY_EFFECT and variant == EffectVariant.BRIMSTONE_BALL)) then
            return false;
        end

        if (flags & DamageFlag.DAMAGE_FIRE > 0 or flags & DamageFlag.DAMAGE_SPIKES > 0 or flags & DamageFlag.DAMAGE_CURSED_DOOR > 0
        or flags & DamageFlag.DAMAGE_POISON_BURN > 0) then
            return false;
        end

        if (Rebecha:CanMechaDamaged(tookDamage, flags)) then
            Rebecha:SetMechaDamageCooldown(tookDamage, countdown * 2);
            local Caller = THI.Collectibles.RebelMechaCaller;
            local player = Rebecha:GetMechaPlayer(tookDamage);
            local shouldDamage = true;
            for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Caller.Item)) do
                if (CompareEntity(ent:ToFamiliar().Player, player)) then
                    ent:Kill();
                    shouldDamage = false;
                    break;
                end
            end
            if (shouldDamage) then
                tookDamage.HitPoints = tookDamage.HitPoints - 1;
            end
            THI.SFXManager:Play(THI.Sounds.SOUND_ROBOT_SMASH)
            if (tookDamage.HitPoints <= 0) then
                tookDamage:Kill();
            end
        end
        return false;
    end
end
Rebecha:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDamage);

local function PostRebechaKill(mod, entity)
    if (entity.Variant == Rebecha.Variant) then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
        entity:GetSprite():RemoveOverlay();
        THI.SFXManager:Play(SoundEffect.SOUND_DOGMA_TV_BREAK);
    end
    
end
Rebecha:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostRebechaKill, Rebecha.Type);


local function PostRebechaRender(mod, entity, offset)
    if (entity.Variant == Rebecha.Variant) then
        local maxHp = math.ceil(entity.MaxHitPoints);
        local hp = math.ceil(entity.HitPoints);
        local spr = Rebecha.HeartSprite;
        local width = 12;
        local renderPos = Screen.GetEntityOffsetedRenderPosition(entity, offset) + Vector(-width * maxHp / 2, -48);
        for i = 1, maxHp do
            local pos = renderPos + Vector((i - 0.5) * width, 0);
            if (hp >= i) then
                spr:SetFrame("IronHeartFull", 1);
            else
                spr:SetFrame("EmptyHeart", 1);
            end
            spr:Render(pos, Vector.Zero, Vector.Zero)
        end

        if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
            local tempData = GetMechaTempData(entity, false);
            if (tempData) then
                local barSpr = tempData.ChargeBarSprite;
                local pos = Screen.GetEntityOffsetedRenderPosition(entity, offset, Vector(-24, -24 *  entity.SpriteScale.Y));
                barSpr:Render(pos, Vector.Zero, Vector.Zero);
            end
        end
    end
    
end
Rebecha:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, PostRebechaRender, Rebecha.Type);

local function PrePickupCollision(mod, pickup, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local player = other:ToPlayer();
        local mecha = Rebecha:GetPlayerMecha(player);
        if (mecha) then
            if (pickup:IsShopItem()) then
                return true;
            else
                if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or 
                pickup.Variant == PickupVariant.PICKUP_TAROTCARD or 
                pickup.Variant == PickupVariant.PICKUP_PILL or 
                pickup.Variant == PickupVariant.PICKUP_TRINKET) then
                    return false;
                end
            end
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PrePickupCollision);

local function PreExit(mod, shouldSave)
    if (shouldSave) then
        for i, ent in pairs(Isaac.FindByType(Rebecha.Type, Rebecha.Variant)) do
            ent:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY);
            if (not ent:IsDead() and not Rebecha:IsSelfDestruction(ent)) then

                Rebecha:SpawnIdle(ent.Position, ent);
            end
        end
    end
end
Rebecha:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreExit);


return Rebecha