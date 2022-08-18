local Detection = CuerLib.Detection;
local Consts = CuerLib.Consts;
local Inputs = CuerLib.Inputs;
local Pickups = CuerLib.Pickups;
local Actives = CuerLib.Actives;
local MathTool = CuerLib.Math;
local Weapons = CuerLib.Weapons;
local Stages = CuerLib.Stages;

local Roukanken = ModItem("Roukanken", "Roukanken")
Roukanken.Sword = {
    Type = Isaac.GetEntityTypeByName("Roukanken"),
    Variant = Isaac.GetEntityVariantByName("Roukanken"),
    SubType = 580,
    SpriteOffset = Vector(0, -10)
};
Roukanken.Hitbox = {
    Type = Isaac.GetEntityTypeByName("Roukanken Hitbox"),
    Variant = Isaac.GetEntityVariantByName("Roukanken Hitbox"),
    SubType = 581,
    DashSubType = 582
};
Roukanken.Config = {
    DashCooldown = 60,
    SlashTime = 540,
    CutDamageMulti = 5,
    DashDamageMulti = 2
};
Roukanken.YoumuSpirit = Isaac.GetPlayerTypeByName("Youmu's Spirit");
local rootPath = "gfx/reverie/characters/";
Roukanken.YoumuCostume = Isaac.GetCostumeIdByPath(rootPath.."character_youmu_hair.anm2");
Roukanken.YoumuSpiritCostume = Isaac.GetCostumeIdByPath(rootPath.."costume_youmu_spirit.anm2");
Roukanken.SpiritSwordSpritePath = "gfx/reverie/effects/spirit_sword_roukanken.png";

local function GetSpiritSwordData(sword)
    return Roukanken:GetData(sword, true, function() return {
        IsRoukanken = false
    } end);
end

local function ReplaceSpiritSword(knife)
    local sprtData = GetSpiritSwordData(knife);
    if (not sprtData.IsRoukanken) then
        local sprite = knife:GetSprite();
        sprite:ReplaceSpritesheet(0, Roukanken.SpiritSwordSpritePath)
        sprite:LoadGraphics()
        sprtData.IsRoukanken = true;
    end
end

function Roukanken.GetPlayerData(player, init)
    return Roukanken:GetData(player, init, function() return {
        Slashing = false,
        SlashTime = 0,
        Sword = nil,
        SwingDelay = 0,
        IsYoumu = false,
        MetBoss = false,
        Dash = {
            Cooldown = 0
        }
    } end);
end

function Roukanken.ChangeToYoumu(player)
    local playerData = Roukanken.GetPlayerData(player, true);

    playerData.IsYoumu = true;

    player:AddNullCostume(Roukanken.YoumuSpiritCostume);
    player:SetColor(Color(1,1,1,1,1,1,1), 10, 0, true, false)
end

function Roukanken.ReturnFromYoumu(player)
    local playerData = Roukanken.GetPlayerData(player, true);

    playerData.IsYoumu = false;
    Weapons.UnbanWeapon(player);

    player:TryRemoveNullCostume(Roukanken.YoumuSpiritCostume)
    player:SetColor(Color(1,1,1,1,1,1,1), 10, 0, true, false)
end

function Roukanken.StartSlash(player)
    local playerData = Roukanken.GetPlayerData(player, true);
    playerData.Slashing = true;
    
    playerData.SlashTime = playerData.SlashTime + Roukanken.Config.SlashTime;
    if (not sword or not playerData.Sword:Exists()) then
        playerData.Sword = Roukanken.SpawnSword(player);
    end
    playerData.Sword:GetSprite():Play("Unsheathe");
end

function Roukanken.EndSlash(player)
    local playerData = Roukanken.GetPlayerData(player, true);
    playerData.Slashing = false;

    if (playerData.IsYoumu) then
        Roukanken.ReturnFromYoumu(player)
    end

    playerData.Sword:GetSprite():Play("Sheathe");
end

----------------------
-- Dash
----------------------

local function GetDashTarget(player, direction)
    

    local startPos = player.Position
    local distance = 360;
    local lastPos = startPos;
    local currentPos;
    local flying = player.CanFly;
    local room = THI.Game:GetRoom();
    local roomWidth = room:GetGridWidth();
    local roomHeight = room:GetGridHeight();
    local roomSize = room:GetGridSize();
    -- Functions
    
    local function GetOffsetedGridIndex(index, offset)
        
        local xoff = 0;
        local yoff = 0;
        if (offset == Direction.LEFT) then
            xoff = -1;
        elseif (offset == Direction.UP) then
            yoff = -1;
        elseif (offset == Direction.RIGHT) then
            xoff = 1;
        elseif (offset == Direction.DOWN) then
            yoff = 1;
        end
        local indexX = index % roomWidth;
        local indexY = math.floor(index / roomWidth);
        if (indexX + xoff >= 0 and indexX + xoff < roomWidth and indexY + yoff >= 0 and indexY + yoff < roomHeight) then
            return index + yoff * roomWidth + xoff;
        end
        return -1;
    end
    local function CanPassGrid(index) 
        local grid = room:GetGridEntity(index);
        if (grid == nil) then
            return true;
        end
        if (flying) then
            return grid.CollisionClass ~= GridCollisionClass.COLLISION_WALL;
        else
            return grid.CollisionClass ~= GridCollisionClass.COLLISION_PIT and 
            grid.CollisionClass ~= GridCollisionClass.COLLISION_WALL and 
            not (grid:GetType() == 3 and grid:GetVariant() == 10)
        end
    end
    -- Get Dashing Direction;
    local dashDir = MathTool.GetDirectionByAngle(direction:GetAngleDegrees() - 45);
    for i=0,distance,24 do
        currentPos = startPos + direction * i;
        local adjacentLeft = (dashDir + 3) % 4;
        local adjacentRight = dashDir;

        -- The destination grid must can be standed on, and one of the adjacent path can be walk through.
        local index = room:GetGridIndex(currentPos);
        local leftIndex = GetOffsetedGridIndex(index, adjacentLeft);
        local rightIndex = GetOffsetedGridIndex(index, adjacentRight);

        room:DestroyGrid(index);
        room:DestroyGrid(leftIndex);
        room:DestroyGrid(rightIndex);
        if (not (CanPassGrid(index) and (CanPassGrid(leftIndex) or CanPassGrid(rightIndex)))) then
            return lastPos;
        end


        -- Create Hitbox.
        local hitbox = Roukanken.FireHitBox(player, 25, currentPos, true);
        
        local hitboxSpr = hitbox:GetSprite();
        hitboxSpr:Play("Slash");
        hitboxSpr.Rotation = direction:GetAngleDegrees() - 90;
        hitbox.CollisionDamage = player.Damage * Roukanken.Config.DashDamageMulti;
        local hitboxData = Roukanken.GetHitboxData(hitbox, true);
        if (not THI.IsLunatic()) then
            hitboxData.ChargeActive = true;
        end
        lastPos = currentPos;
    end 
    return currentPos;
end

function Roukanken.SlashDash(player)
    if (player:GetMovementInput():Length() > 0.1 and (player.Velocity.X ~= 0 or player.Velocity.Y ~= 0)) then
        local playerData = Roukanken.GetPlayerData(player, true);
        local dashData = playerData.Dash;
        
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
        poof:SetColor(Color(1,1,1,1,0.5,0.5,0.5), -1, 0, false, false);

        local lastPosition = player.Position;
        local target = GetDashTarget(player, player.Velocity:Normalized());
        player.Position = target;
        THI.SFXManager:Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 0.75);
        THI.Game:ShakeScreen(10);
        poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
        poof:SetColor(Color(1,1,1,1,0.5,0.5,0.5), -1, 0, false, false);

        -- Urn of soul Synergy.
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_URN_OF_SOULS)) then
            local movedVector = target - lastPosition;
            local distance = movedVector:Length();
            local moveAngle = movedVector:GetAngleDegrees();
            for i = 0, 1 do
                for a = 0, 1080, 45 do
                    local angle = a;
                    if (i == 1) then
                        angle = angle + 180;
                    end
                    local rad = math.rad(angle);
                    local sin = math.sin(rad);
                    local yOffset = sin * distance / 20;
                    local x = a / 1080 * distance;
                    local offset = Vector(x, yOffset):Rotated(moveAngle);
                    local pos = lastPosition + offset;
                    local vel = Vector.FromAngle(a * math.pi) * 10;
                    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIRE, 0, pos, vel, player):ToTear();
                    tear.FallingAcceleration = -0.08;
                    tear:AddTearFlags(TearFlags.TEAR_HOMING | TearFlags.TEAR_ORBIT_ADVANCED)
                    tear.CollisionDamage = player.Damage * 6;
                end
            end
            SFXManager():Play(SoundEffect.SOUND_FLAMETHROWER_END, 2)
            SFXManager():Play(SoundEffect.SOUND_GHOST_ROAR)
        end


        dashData.Cooldown = Roukanken.Config.DashCooldown;
        player:SetMinDamageCooldown(30);
    end
end

----------------------
-- Events
----------------------

function Roukanken:onUseItem(item, rng, player, flags, slot, data)
    local playerData = Roukanken.GetPlayerData(player, true);
    if (not playerData.Slashing) then
        Roukanken.StartSlash(player);
        playerData.Dash.Cooldown = 5;
    else
        return {Discharge = false};
    end

end
Roukanken:AddCallback(ModCallbacks.MC_USE_ITEM, Roukanken.onUseItem, Roukanken.Item);


-- function Roukanken:onGameStarted(isContinued)
--     for p, player in Detection.PlayerPairs() do
--         local playerData = Roukanken.GetPlayerData(player, false);
--         if (playerData and playerData.IsYoumu) then
            
--             Weapons.BanishWeapon(player, true);
--         end
--     end
-- end
-- Roukanken:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Roukanken.onGameStarted);

function Roukanken:onPlayerUpdate(player)
    local playerData = Roukanken.GetPlayerData(player, false);
    if (playerData) then
        -- Set Sword Position;
        local sword = playerData.Sword;
        local swordSprite = nil;
        local swordPosOffset = Vector(0, 1);
        if (sword ~= nil) then
            swordSprite = sword:GetSprite();
            
            if (swordSprite:IsEventTriggered("Spin")) then
                THI.SFXManager:Play(SoundEffect.SOUND_SWORD_SPIN);
            end
            
            sword.Position = player.Position + swordPosOffset;
            if (swordSprite:WasEventTriggered("Disappear")) then
                sword:Remove();
                playerData.Sword = nil;
            end
        end
        -- Youmu form
        if (playerData.Slashing) then
            if (not sword or not sword:Exists()) then
                sword = Roukanken.SpawnSword(player);
                swordSprite = sword:GetSprite();
                playerData.Sword = sword;
            end
            local swordData = Roukanken.GetSwordData(sword, true);
            -- if is playing unsheathe animation
            if (swordSprite:IsPlaying("Unsheathe")) then
                if (swordSprite:IsEventTriggered("Transform")) then
                    -- Change player type to Youmu Spirit.
                    if (not playerData.IsYoumu) then
                        Roukanken.ChangeToYoumu(player)
                    end
                    
                    THI.SFXManager:Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 0.75);
                    THI.Game:ShakeScreen(10);
                end
            else
                -- Change player type to Youmu Spirit.
                if (not playerData.IsYoumu) then
                    Roukanken.ChangeToYoumu(player)
                end

                
                -- if not playing unsheathe Animation.
                if (playerData.IsYoumu) then

                    local headDirection = player:GetHeadDirection();

                    swordPosOffset = Consts.DirectionVectors[headDirection + 1];
                    
                    local swinging1 = swordSprite:IsPlaying("Swing") and not swordSprite:IsFinished("Swing");
                    local swinging2 = swordSprite:IsPlaying("Swing2") and not swordSprite:IsFinished("Swing2");
                    -- If Sword is swinging, change the rotation.
                    if (swinging1 or swinging2) then
                        swordPosOffset = swordData.SwingDirection;
                    end
                    swordSprite.Offset = Roukanken.Sword.SpriteOffset;
                    local targetRotation = swordPosOffset:GetAngleDegrees() - 90;
                    
                    swordSprite.Rotation = (swordSprite.Rotation + (targetRotation - swordSprite.Rotation) * 0.3);
                    sword.Position = player.Position + swordPosOffset * 10;

                    if (player.ControlsEnabled and player.ControlsCooldown <= 0 and playerData.Dash.Cooldown <= 0 and Actives.IsActiveItemTriggered(player, Roukanken.Item)) then
                        Roukanken.SlashDash(player);
                    end
                end
            end

            -- Spirit Sword
            local weaponEntity = player:GetActiveWeaponEntity();
            local swingingSword = weaponEntity ~= nil and weaponEntity.Type == 8 and (weaponEntity.Variant == 10 or weaponEntity.Variant == 11);
            if (swordData.Hidden ~= swingingSword and playerData.IsYoumu) then
                swordData.Hidden = swingingSword and playerData.IsYoumu;
                -- if Player has Spirit Sword, hide roukanken.
                if (swordData.Hidden) then
                    sword.Visible = false;
                else
                    -- else, show Roukanken.
                    sword.Visible = true;
                end
            end

            if (swingingSword) then
                ReplaceSpiritSword(weaponEntity);
            end
            
            -- Check Boss is defeated.
            local room = THI.Game:GetRoom();
            local roomType = room:GetType();
            local count = room:GetAliveEnemiesCount();

            if (playerData.MetBoss and count <= 0) then
                -- Sheathe if boss is defeated.
                Roukanken.EndSlash(player);
                playerData.MetBoss = false;
            end

            if (roomType == RoomType.ROOM_BOSS) then
                if (room:GetAliveBossesCount() > 0) then
                    playerData.MetBoss = true;
                end
            else 
                playerData.MetBoss = false;
            end
        else
            playerData.MetBoss = false;
        end
    end
end
Roukanken:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Roukanken.onPlayerUpdate);

function Roukanken:onPlayerEffect(player)
    local playerData = Roukanken.GetPlayerData(player, false);

    if (playerData) then
        local hasSpiritSword = player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD);
        if (playerData.Slashing) then
            local shouldBan = playerData.Slashing and not hasSpiritSword;
            local weaponBanned = Weapons:IsWeaponsBanned(player);
            if (shouldBan ~= weaponBanned) then
                if (shouldBan) then
                    Weapons.BanishWeapon(player, true, false);
                else
                    Weapons.UnbanWeapon(player);
                end
            end
        end

        if (playerData.Slashing) then
            if (Stages.IsInMinesEscape()) then
                Roukanken.EndSlash(player);
            end

            if (not hasSpiritSword) then
                -- Swing Sword
                if (playerData.IsYoumu) then
                    if (player:GetAimDirection():Length() > 0.1) then
                        if (player.FireDelay <= 0) then
                            player.FireDelay = player.MaxFireDelay;
                            Roukanken.SwingSword(player);
                        end
                    end
                end
            end
            -- Count Down
            if (playerData.SlashTime > 0) then
                playerData.SlashTime = playerData.SlashTime - 1;
                if (playerData.SlashTime <= 90 and playerData.SlashTime % 15 == 0) then
                    THI.SFXManager:Play(SoundEffect.SOUND_BEEP);
                    player:SetColor(Color(1,1,1,1,0.5,0.5,0.5), 10, 0, true, false)
                end
            end
            if (playerData.SlashTime <= 0) then
                Roukanken.EndSlash(player);
            end
        end
        
        if (playerData.Dash.Cooldown > 0) then
            playerData.Dash.Cooldown = playerData.Dash.Cooldown - 1;
            if (playerData.Dash.Cooldown <= 0) then
                THI.SFXManager:Play(SoundEffect.SOUND_BEEP, 1, 0, false, 0.5);
                local sword = playerData.Sword;
                if (sword) then
                    sword:SetColor(Color(1,1,1,1,1,1,1), 20, 0, true, false);
                end
            end
        end
        -- Swing
        if (playerData.SwingDelay > 0) then
            playerData.SwingDelay = playerData.SwingDelay - 1;
        end
    end
end

Roukanken:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Roukanken.onPlayerEffect);

------------------
-- Sword
------------------

function Roukanken.GetSwordData(sword, init)
    return Roukanken:GetData(sword, init, function() return {
        TargetRotation = 0,
        SwingDirection = Vector(0, 1)
    } end);
end

function Roukanken.SwingSword(player)
    local playerData = Roukanken.GetPlayerData(player);
    local sword = playerData.Sword;
    
    if (sword ~= nil) then
        local swordData = Roukanken.GetSwordData(sword, true);
        local input = Inputs.GetRawShootingVector(player);
        if (input:Length() > 0.1 and player:IsExtraAnimationFinished()) then
            swordData.SwingDirection = input:Normalized();
        end

        -- Spawn Hitbox.
        local hitbox = Roukanken.FireHitBox(player, 50);
        
        -- Play Animation.
        local sprite = sword:GetSprite();
        local currentAnimation = sprite:GetAnimation();
        local swingAngle = -90;
        if (currentAnimation ~= "Swing") then
            sprite:Play("Swing");
            hitbox:GetSprite():Play("WhooshSwing");
        else
            sprite:Play("Swing2");
            hitbox:GetSprite():Play("WhooshSwing2");
            swingAngle = 90;
        end

        local hitboxData = Roukanken.GetHitboxData(hitbox, true);
        hitboxData.SwingVelocity = player:GetAimDirection():Rotated(swingAngle);

        -- Urn of Soul Synergy.
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_URN_OF_SOULS)) then
            local rotation = player:GetAimDirection():GetAngleDegrees() - 45;
            local position = player.Position + player:GetAimDirection() * 50;
            for i = 1, 5 do 
                local angle = i * 18 + rotation;
                local vel = Vector.FromAngle(angle) * 10 + player.Velocity;
                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIRE, 0, position, vel, player):ToTear();
                tear.CollisionDamage = player.Damage;
            end
            THI.SFXManager:Play(SoundEffect.SOUND_FLAMETHROWER_END, 2)
        end

        -- Play Sound.
        THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME)
    end
end

function Roukanken.SpawnSword(player)
    
    local playerData = Roukanken.GetPlayerData(player);
    local sword = Isaac.Spawn(Roukanken.Sword.Type, Roukanken.Sword.Variant, Roukanken.Sword.SubType, player.Position, Vector.Zero, player):ToKnife();
    sword.Parent = player;
    sword.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
    sword.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE;
    sword:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    --sword:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
    sword.CollisionDamage = 0;
    local swordData = Roukanken.GetSwordData(sword, true);
    swordData.Player = player;
    playerData.Sword = sword;

    return sword;
end

------------------
-- Hitbox
------------------

do

    function Roukanken.GetHitboxData(hitbox, init)
        return Roukanken:GetData(hitbox, init, function() return {
            Timeout = 11,
            Offset = Vector.Zero,
            SwingVelocity = Vector.Zero,
            HitEnemies = {},
            HitPickups = {}
        } end);
    end
    
    
    function Roukanken.DestroyObstacles(position, size)
        local room = THI.Game:GetRoom();
        local extents = size;
        local roomWidth = room:GetGridWidth();
        local leftest = position.X - extents;
        local topest = position.Y - extents;
        local rightest = position.X + extents;
        local bottomest = position.Y + extents;
        local width = math.ceil((rightest - leftest) / 24);
        local height = math.ceil((bottomest - topest) / 24);
        
        for y=0, height do
            for x=0, width do
                local pos = Vector(leftest + 24 * x, topest + 24 * y);
                if (pos:Distance(position) < size) then
                    local index = room:GetGridIndex(pos);
                    room:DestroyGrid(index);
                end
            end
        end
    
        for _,ent in pairs(Isaac.FindInRadius (position, size + 12, EntityPartition.ENEMY)) do
            -- If it's a fire place but not white fire place.
            if (ent.Type == EntityType.ENTITY_FIREPLACE and ent.Variant ~= 4) then
                ent:Die();
            end
        end
    end
    
    function Roukanken.CollectPickups(player, hitbox, swingVector)
        swingVector = swingVector or Vector.Zero;
        local position = hitbox.Position;
        local size = hitbox.Size;
        for _,ent in pairs(Isaac.FindInRadius (position, size + 12, EntityPartition.PICKUP)) do
            local pickup = ent:ToPickup();
            local hitPickups = Roukanken.GetHitboxData(hitbox, true).HitPickups;
            if (pickup ~= nil and hitPickups[pickup.InitSeed] == nil) then
                if (Pickups.CanCollect(player, pickup)) then
                    Pickups.Collect(player, pickup)
                end
                pickup:AddVelocity(((position - player.Position):Normalized() + swingVector:Normalized()) * 5 )
                hitPickups[pickup.InitSeed] = true;
            end
        end
    end
    
    function Roukanken.CutProjectiles(position, size)
        for _,ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
            local projectile = ent:ToProjectile();
            if (projectile ~= nil) then
                if (projectile.Position:Distance(position) < projectile.Size + size) then
                    projectile:Die();
                end
            end
        end
    end
    
    function Roukanken.SpawnHitbox(spawner, position, size, damage, rotation, spriteOffset, subType)
        damage = damage or 7;
        rotation = rotation or 0;
        spriteOffset = spriteOffset or Vector.Zero;
        subType = subType or Roukanken.Hitbox.SubType;

        local hitBoxInfo = Roukanken.Hitbox;
        local hitbox = Isaac.Spawn(hitBoxInfo.Type, hitBoxInfo.Variant, subType, position, Vector.Zero, spawner):ToKnife();
        
        hitbox:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
        hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE;
        --hitbox.Target = hitbox;
        hitbox.Size = size;
        hitbox.SpriteRotation = rotation;
        hitbox.SpriteOffset = spriteOffset;
        hitbox.CollisionDamage = damage;
    
        hitbox.Parent = spawner;
        return hitbox;
    end
    
    function Roukanken.FireHitBox(player, size, position, fixed)
        fixed = fixed or false;
        position = position or player.Position + player:GetAimDirection() * 50;
    
        local rotation = player:GetAimDirection():GetAngleDegrees() - 90;
        local spriteOffset = Vector.Zero;
        if (not fixed) then
            spriteOffset = Roukanken.Sword.SpriteOffset - (position - player.Position) / 2;
        end
        local damage = player.Damage * Roukanken.Config.CutDamageMulti;

        local subType = nil;
        if (fixed) then
            subType = Roukanken.Hitbox.DashSubType;
        end
        local hitbox = Roukanken.SpawnHitbox(player, position, size, damage, rotation, spriteOffset, subType);
        local hitboxData = Roukanken.GetHitboxData(hitbox, true);
        hitboxData.Offset = position - player.Position;


        
    
        return hitbox;
    end
    
    
    local function PostHitboxUpdate(mod, hitbox)
        local info = Roukanken.Hitbox;
        local isHitbox = hitbox.SubType == info.SubType;
        
        local isDash = hitbox.SubType == info.DashSubType;
        if (hitbox.Type == info.Type and hitbox.Variant == info.Variant and (isHitbox or isDash)) then
            hitbox.SpriteScale = Vector(hitbox.Size / 50, hitbox.Size /50 );
            local hitboxData = Roukanken.GetHitboxData(hitbox, true);
            local parent = hitbox.Parent;
            local player;
            if (parent) then
                player = parent:ToPlayer();
                if (not isDash) then
                    hitbox.Position = parent.Position + hitboxData.Offset;
                    hitbox.Velocity = parent.Velocity;
                end
            end
            if (hitboxData.Timeout == 0) then
                hitbox:Remove();
            else
                
                if (hitboxData.Timeout > 0) then
                    hitboxData.Timeout = hitboxData.Timeout - 1;
                end
    
                -- Destroy Obstacles.
                Roukanken.DestroyObstacles(hitbox.Position, hitbox.Size)
    
                -- Collect Pickups.
                if (player) then
                    Roukanken.CollectPickups(player, hitbox, hitboxData.SwingVelocity)
                end
    
                -- Cut Projectiles.
                Roukanken.CutProjectiles(hitbox.Position, hitbox.Size)
            end
        end
    end
    Roukanken:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, PostHitboxUpdate);
    

    -- Fixed the knife only damage player's double stats damage.
    local replacingDMG = false;
    local function PreEntityDamage(mod, tookDamage, damage, flags, source, countdown)
        if source == nil or source.Entity == nil or not Detection.IsValidEnemy(tookDamage) then
            return nil
        end
    
        local srcEnt = source.Entity;
        local hitBoxInfo = Roukanken.Hitbox;
        if (srcEnt.Type == hitBoxInfo.Type and srcEnt.Variant == hitBoxInfo.Variant) then

            if (not replacingDMG) then
                -- Replace the damage into collisionDamage.
                replacingDMG = true;
                tookDamage:TakeDamage(srcEnt.CollisionDamage, flags, source, countdown);
                replacingDMG = false;
                return false;
            else
                local hitboxData = Roukanken.GetHitboxData(srcEnt, true);
                local player = srcEnt.Parent:ToPlayer();
                local key = tookDamage.InitSeed;

                if (not hitboxData.HitEnemies[key]) then
                    -- Hit the enemy.
                    hitboxData.HitEnemies[key] = true;
                    local npc = tookDamage:ToNPC();
                    if (npc) then
                        npc:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 0.75, 0, false, 1.8)
                        if (hitboxData.ChargeActive) then
                            Roukanken.GetNPCData(npc, true).DeathCharge = {
                                Target = player,
                                Amount = 1,
                                Timeout = 10
                            };
                        end
                    end
                else 
                    -- Has hit this enemy.
                    return false;
                end
            end
        end
    end
    Roukanken:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreEntityDamage);
end


---------------------------
-- NPCs
---------------------------

function Roukanken.GetNPCData(npc, init)
    return Roukanken:GetData(npc, init, function() return {} end);
end

function Roukanken:onNPCUpdate(npc) 
    if (not npc:IsDead()) then
        local npcData = Roukanken.GetNPCData(npc, false);
        local deathCharge = npcData and npcData.DeathCharge;
        if (deathCharge) then
            if (deathCharge.Timeout < 0) then
                deathCharge = nil;
            else
                deathCharge.Timeout = deathCharge.Timeout - 1;
            end
        end
    end
end
Roukanken:AddCallback(ModCallbacks.MC_NPC_UPDATE, Roukanken.onNPCUpdate);

function Roukanken:onEntityKill(entity)
    local npcData = Roukanken.GetNPCData(entity, false);
    if (npcData and npcData.DeathCharge) then
        Actives.ChargeByOrder(npcData.DeathCharge.Target, npcData.DeathCharge.Amount);
        THI.SFXManager:Play(SoundEffect.SOUND_BEEP);
    end
end
Roukanken:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Roukanken.onEntityKill, EntityType.ENTITY_NPC);

---------------------------
-- Spirit Sword
---------------------------
function Roukanken:onSpiritSwordUpdate(knife)
    -- if knife is Spirit Sword.
    if (knife.Variant == 10 or knife.Variant == 11) then
        local swordData = GetSpiritSwordData(knife);
        if (swordData.IsRoukanken) then
            -- Destroy Obstacles.
            Roukanken.DestroyObstacles(knife.Position, knife.Size * 4.5)

            -- Cut Projectiles.
            Roukanken.CutProjectiles(knife.Position, knife.Size * 4.5)
        end
    end
end

Roukanken:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, Roukanken.onSpiritSwordUpdate);


--------------------------
-- Wisp
--------------------------
function Roukanken:onWispUpdate(familiar)
    if (familiar.SubType == Roukanken.Item) then
        if (familiar.FireCooldown > 0) then
            familiar.FireCooldown = familiar.FireCooldown - 1;
        end
        local player = familiar.Player;
        if (player ~= nil and player:GetAimDirection():Length() > 0.1 and familiar.FireCooldown <= 0) then
            -- Spawn Hitbox.
            local size = 25;
            local position = familiar.Position + player:GetAimDirection() * size;
            local rotation = player:GetAimDirection():GetAngleDegrees() - 90;
            local spriteOffset = Vector(0, -10) - player:GetAimDirection() * size / 2;
            local damage = 6;
            local hitbox = Roukanken.SpawnHitbox(familiar, position, size, damage, rotation, spriteOffset);
            local hitboxData = Roukanken.GetHitboxData(hitbox, true);
            hitboxData.Offset = position - familiar.Position;
            
            -- Play Animation.
            local sprite = hitbox:GetSprite();
            local swingAngle = -90;
            hitbox:GetSprite():Play("WhooshSwing");

            hitboxData.SwingVelocity = player:GetAimDirection():Rotated(swingAngle);

            -- Play Sound.
            THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME)

            familiar.FireCooldown = 10;
        end
    end
end

Roukanken:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Roukanken.onWispUpdate, FamiliarVariant.WISP);


return Roukanken;