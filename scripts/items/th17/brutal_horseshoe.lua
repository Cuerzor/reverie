local Inputs = CuerLib.Inputs;
local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local Horseshoe = ModItem("Brutal Horseshoe", "BRUTAL_HORSESHOE");

Horseshoe.MaxChargeUp = 120;
Horseshoe.DashThresold = 30;

local function GetPlayerTempData(player, create)
    local function default()
        local sprite = Sprite();
        sprite:Load("gfx/reverie/horseshoe_chargebar.anm2", true);
        sprite:SetFrame("Disappear", 100);
        return {
            ChargeUp = 0,
            IsCharging = false,
            DashCountdown = -1,
            DashTimeout = -1,
            DashStrength = 0,
            DashVelocity = Vector.Zero,
            HitEnemies = {},
            ChargeBarSprite = sprite
        }
    end
    return Horseshoe:GetTempData(player, create, default);
end


local function GetNPCTempData(npc, create)
    local function default()
        return {
            PinnedTime = 0,
            PinnedVelocity = Vector.Zero;
        }
    end
    return Horseshoe:GetTempData(npc, create, default);
end


function Horseshoe:IsCharging(player)
    if (not self:IsDashing(player) and player:AreControlsEnabled() and player:HasCollectible(Horseshoe.Item)) then
        local controller = player.ControllerIndex;
        local joystick = player:GetMovementJoystick ( )
        local length = joystick:Length();
        local left = Input.IsActionPressed(ButtonAction.ACTION_LEFT, controller)
        local right = Input.IsActionPressed(ButtonAction.ACTION_RIGHT,controller)
        local up = Input.IsActionPressed(ButtonAction.ACTION_UP, controller)
        local down = Input.IsActionPressed(ButtonAction.ACTION_DOWN,controller)
        if ((left and right and not up and not down) or (up and down and not left and not right)) then
            return true;
        end

        local leftStickPressed = Input.IsButtonPressed(10,controller) -- 10 is left stick.
        if (leftStickPressed and length < 0.2) then
            return true;
        end
        if (length <= 0.7 and length > 0.01) then
            return true;
        end

    end
    return false;
end

function Horseshoe:GetChargeUp(player)
    local data = GetPlayerTempData(player, false);
    return (data and data.ChargeUp) or 0;
end

function Horseshoe:CanChargedToDash(charge)
    return charge >= Horseshoe.DashThresold
end


function Horseshoe:IsDashing(player)
    
    local data = GetPlayerTempData(player, false);
    return (data and data.DashTimeout > 0) or false;
end

function Horseshoe:StartDash(player, direction)
    local data = GetPlayerTempData(player, true);
    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_YELL_A);
    local chargeUp = self:GetChargeUp(player)
    data.DashStrength = (chargeUp - self.DashThresold) / (self.MaxChargeUp - self.DashThresold)
    data.DashTimeout = 20;
    -- Clear Hit Enemies.
    data.HitEnemies = nil;
    player:AddVelocity(15 * direction);
    
end

do
    local function PostPlayerEffect(mod, player)
        local charging = Horseshoe:IsCharging(player);

        if (player:HasCollectible(Horseshoe.Item)) then

            local data = GetPlayerTempData(player, true);
            if (Horseshoe:IsDashing(player)) then
                -- Dashing.
                data.DashTimeout = data.DashTimeout - 1;
                local strength = data.DashStrength;

                -- Invincible.
                player:SetMinDamageCooldown(30);


                -- Grid Check.
                local collidesGrid = false;
                local room = Game():GetRoom();
                for i = 1, 4 do
                    local angle = i * 90;
                    local offset = Vector.FromAngle(angle) * player.Size + player.Velocity;
                    
                    --local offset = player.Velocity:Resized(player.Size);

                    local index = room:GetGridIndex(player.Position + offset)
                    local gridEntity = room:GetGridEntity(index);
                    if (gridEntity) then
                        -- Blocked.
                        local gridCollision = gridEntity.CollisionClass;
                        local collide = false;
                        if (player.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS) then
                            -- Flying.
                            collide = gridCollision == GridCollisionClass.COLLISION_WALL;
                        elseif (player.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE) then
                            collide = gridCollision == GridCollisionClass.COLLISION_WALL or 
                            gridCollision == GridCollisionClass.COLLISION_PIT or 
                            gridCollision == GridCollisionClass.COLLISION_SOLID or 
                            gridCollision == GridCollisionClass.COLLISION_OBJECT;
                        end
                        if (collide) then
                            collidesGrid = true;
                            break;
                        end
                    end
                end
                if (collidesGrid) then
                    data.DashTimeout = math.min(data.DashTimeout, 1);
                    Game():ShakeScreen(15);
                    THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                    local damage = 120 + strength * 240
                    Game():BombExplosionEffects (player.Position, damage, TearFlags.TEAR_NORMAL, Color.Default, player, 1 + strength * 1.5, true, false, DamageFlag.DAMAGE_EXPLOSION );
                    for i = 1, 4 do
                        local crack = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 0, player.Position, Vector.Zero, player):ToEffect();
                        crack.Parent = player;
                        crack.Rotation = i * 90 + 45
                    end

                else
                    local vel = player.Velocity;
                    if (vel:Length() == 0) then
                        vel = data.DashVelocity;
                    end
                    player.Velocity = vel:Resized(math.max(vel:Length(), 15));
                    if (player.Velocity:Length() > 0) then
                        data.DashVelocity = player.Velocity;
                    end
                end

            else
                -- Not Dashing.
                if (charging) then
                    data.IsCharging = true;
                    data.ChargeUp = math.min(Horseshoe.MaxChargeUp, data.ChargeUp + 1);
                else
                    if (data) then
                        local chargeUp = Horseshoe:GetChargeUp(player);
                        if (Horseshoe:CanChargedToDash(chargeUp)) then
                            if (data.IsCharging) then
                                data.DashCountdown = 0;
                                data.IsCharging = false;
                            end
                            
                            if (data.DashCountdown < 0) then
                                local joystick = player:GetMovementJoystick();
                                if (joystick:Length() > 0.5) then
                                    Horseshoe:StartDash(player, player:GetMovementJoystick():Normalized());
                                end
                                data.ChargeUp = 0;
                            else
                                data.DashCountdown = data.DashCountdown - 1;
                            end
                        else
                            if (chargeUp > 0) then
                                data.ChargeUp = chargeUp - 1;
                            end
                        end
                    end
                end

            end
            
            -- Update Sprite.
            
            local data = GetPlayerTempData(player, false);
            if (data) then
                local chargeUp = Horseshoe:GetChargeUp(player);
                local sprite = data.ChargeBarSprite;
                if (charging) then
                    local anim = sprite:GetAnimation();
                    if (chargeUp >= Horseshoe.MaxChargeUp) then
                        if (anim ~= "StartCharged"  and anim ~= "Charged") then
                            sprite:Play("StartCharged")
                        end
                        if (sprite:IsFinished("StartCharged")) then
                            sprite:Play("Charged")
                        end
                    else
                        sprite:SetFrame("Charging", math.floor(chargeUp * 100 / Horseshoe.MaxChargeUp));
                    end
                else
                    sprite:Play("Disappear")
                end
                sprite:Update();
            end
            
        else
            local data = GetPlayerTempData(player, false);
            if (data) then
                data.IsCharging = false;
                data.ChargeUp = 0;
                data.DashCountdown = -1;
                data.DashTimeout = 0;
                data.DashVelocity = Vector.Zero;
            end
        end

    end
    Horseshoe:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

    local function PostPlayerUpdate(mod, player)
        if (player:HasCollectible(Horseshoe.Item)) then
            
            local dashing = Horseshoe:IsDashing(player);
            if (dashing) then
                -- Spawn Trails.
                local trailInfo = THI.Effects.PlayerTrail;
                local trail = Isaac.Spawn(trailInfo.Type, trailInfo.Variant, trailInfo.SubTypes.HORSESHOE, player.Position, Vector(0, 0), player);
                trail.SpriteScale = player.SpriteScale;
            end

            local chargeUp = Horseshoe:GetChargeUp(player);
            local canDash = Horseshoe:CanChargedToDash(chargeUp);
            if (player:IsFrame(4,0) and (dashing or canDash)) then
                player:SetColor(Color(1,0.5,0.5,1,1,0.5,0.5), 2, 0);
            end
        end
    end
    Horseshoe:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

    local function PostPlayerRender(mod, player, offset)
        if (not Options.ChargeBars) then
            return;
        end
        local room = Game():GetRoom();
        if (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
            if (player:HasCollectible(Horseshoe.Item)) then
                local data = GetPlayerTempData(player, false);
                if (data) then
                    local pos = Screen.GetEntityOffsetedRenderPosition(player, offset, Vector(-24, 0));
                    data.ChargeBarSprite:Render(pos, Vector.Zero, Vector.Zero);
                end
            end
        end
    end
    Horseshoe:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, PostPlayerRender)

    local function PrePlayerCollision(mod, player, other, low)
        if (Horseshoe:IsDashing(player)) then
            local npc = other:ToNPC();
            if (npc and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                local data = GetPlayerTempData(player, true);
                THI.SFXManager:Play(SoundEffect.SOUND_PUNCH, 1);
                data.HitEnemies = data.HitEnemies or {};
                if (not data.HitEnemies[other.InitSeed]) then
                    data.HitEnemies[other.InitSeed] = true;
                    local damage = player.Damage * (1 +data.DashStrength) * 50 + 50
                    other:TakeDamage(damage, 0, EntityRef(player), 0);
                    
                    local dot = player.Velocity:Dot(npc.Position - player.Position);
                    local speed = 25;
                    local vel
                    if (dot <= 0) then -- At player's left.
                        vel = player.Velocity:Rotated(-90):Resized(speed);
                    else
                        vel = player.Velocity:Rotated(90):Resized(speed);
                    end
                    npc.Velocity = npc.Velocity + vel;
                    local npcData = GetNPCTempData(npc, true);
                    npcData.PinnedTime = 20;
                    npcData.PinnedVelocity = vel;
                end
            end
            return true;
        end
    end
    Horseshoe:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_PLAYER_COLLISION, PrePlayerCollision)

    local function PreNPCCollision(mod, npc, other, low)
        if (not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            
            local player = other:ToPlayer();
            if (player and Horseshoe:IsDashing(player)) then
                return false;
            end
        end
    end
    Horseshoe:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNPCCollision)

    local function PostNPCUpdate(mod, npc)
        local npcData = GetNPCTempData(npc, false);
        if (npcData and npcData.PinnedTime > 0) then
            npcData.PinnedTime = npcData.PinnedTime - 1;

            npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_APPLY_IMPACT_DAMAGE);
            local pinnedVelocity = npcData.PinnedVelocity;
            local vel = npc.Velocity;
            local speed = vel:Length();

            if (speed == 0) then
                npc.Velocity = pinnedVelocity:Normalized();
            end
            npc.Velocity = vel:Resized(math.max(speed, pinnedVelocity:Length()));
            npcData.PinnedVelocity = pinnedVelocity:Resized(math.max(0, pinnedVelocity:Length() - 0.2));
            
            if (npc:CollidesWithGrid()) then
                local stage = Game():GetLevel():GetStage();
                local damage = 10 + 2 * (stage - 1);
                npc:TakeDamage(damage, 0, EntityRef(nil), 0);
                npcData.PinnedTime = 0;
            elseif (npc.Velocity:Length() <= 5) then
                npcData.PinnedTime= 0;
            end
        end
    end
    Horseshoe:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)

    -- TODO Post Collision.
    local function PostNPCCollision(mod, npc, other, low)
        local npcData = GetNPCTempData(npc, false);
        if (npcData and npcData.Pinned) then
            if (other:IsActiveEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                local stage = Game():GetLevel():GetStage();
                local damage = 10 + 2 * (stage - 1);
                other:TakeDamage(damage, 0, EntityRef(npc), 0);
                other:AddVelocity(20 * (other.Position - npc.Position))
            end
        end
    end
    Horseshoe:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PostNPCCollision)
end

return Horseshoe;