local Entities = CuerLib.Entities;
local Screen = CuerLib.Screen;
local EntityExists = Entities.EntityExists;

local Arm = ModEntity("Extending Arm", "ExtendingArmEntity");
Arm.SubTypes = {
    NORMAL = 0,
    BELIAL = 1
}

local shrinkSpeed = 20;

local EntityInteractions = {
    Ignore = {
        { Type = EntityType.ENTITY_MOM, Variant = 0 },
        { Type = EntityType.ENTITY_HORNFEL_DOOR},
        { Type = EntityType.ENTITY_ULTRA_DOOR},
        { Type = EntityType.ENTITY_HORNFEL_DOOR}
    },
    Block = {
        { Type = EntityType.ENTITY_STONEHEAD },
        { Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER },
        { Type = EntityType.ENTITY_STONE_EYE },
        { Type = EntityType.ENTITY_BRIMSTONE_HEAD },
        { Type = EntityType.ENTITY_GAPING_MAW },
        { Type = EntityType.ENTITY_BROKEN_GAPING_MAW },
        { Type = EntityType.ENTITY_BOMB_GRIMACE },
        { Type = EntityType.ENTITY_QUAKE_GRIMACE },
        { Type = EntityType.ENTITY_GIDEON },
        { Type = EntityType.ENTITY_GENERIC_PROP },
    },
    SetTargetPosition = {
        { Type = EntityType.ENTITY_PICKUP },
        { Type = EntityType.ENTITY_SLOT },
        { Type = EntityType.ENTITY_SHOPKEEPER },
        { Type = EntityType.ENTITY_FIREPLACE },
        { Type = EntityType.ENTITY_GURDY },
        { Type = EntityType.ENTITY_BOIL },
        { Type = EntityType.ENTITY_HUSH_BOIL },
        { Type = EntityType.ENTITY_MOM, Variant = 10 },
        { Type = EntityType.ENTITY_LUMP },
        { Type = EntityType.ENTITY_FRED },
        { Type = EntityType.ENTITY_EYE },
        { Type = EntityType.ENTITY_PIN },
        { Type = EntityType.ENTITY_MOMS_HEART },
        { Type = EntityType.ENTITY_DADDYLONGLEGS },
        { Type = EntityType.ENTITY_ISAAC },
        { Type = EntityType.ENTITY_COD_WORM },
        { Type = EntityType.ENTITY_NERVE_ENDING },
        { Type = EntityType.ENTITY_ROUND_WORM },
        { Type = EntityType.ENTITY_NIGHT_CRAWLER },
        { Type = EntityType.ENTITY_MEGA_MAW },
        { Type = EntityType.ENTITY_GATE },
        { Type = EntityType.ENTITY_THE_LAMB, Variant = 10 },
        { Type = EntityType.ENTITY_ROUNDY },
        { Type = EntityType.ENTITY_ULCER },
        { Type = EntityType.ENTITY_HUSH },
        { Type = EntityType.ENTITY_MUSHROOM },
        { Type = EntityType.ENTITY_PORTAL },
        { Type = EntityType.ENTITY_TARBOY },
        { Type = EntityType.ENTITY_GUSH },
        { Type = EntityType.ENTITY_BIG_HORN },
        { Type = EntityType.ENTITY_BISHOP },
        { Type = EntityType.ENTITY_PUSTULE },
        { Type = EntityType.ENTITY_DUMP },
        { Type = EntityType.ENTITY_SIREN, Variant = 1 },
        { Type = EntityType.ENTITY_ROTGUT },
        { Type = EntityType.ENTITY_CLOG },
        { Type = EntityType.ENTITY_DOGMA, Variant = 1 },
        { Type = EntityType.ENTITY_MINECART},
    },
    NoDrag = {
        --{ Type = EntityType.ENTITY_BABY_PLUM },
        { Type = EntityType.ENTITY_MOTHER, Variant = 0 },
        { Type = EntityType.ENTITY_MOTHER, Variant = 10 },
        { Type = EntityType.ENTITY_DOPLE },
        { Type = EntityType.ENTITY_MAMA_GURDY },
        { Type = EntityType.ENTITY_MR_FRED },
        { Type = EntityType.ENTITY_MEGA_SATAN },
        { Type = EntityType.ENTITY_MEGA_SATAN_2 },
        { Type = EntityType.ENTITY_SCOURGE, Variant = 10  },
        { Type = EntityType.ENTITY_BEAST, Variant = 1 },
        
    }
}

local function FitType(ent, info)
    if (ent.Type == info.Type) then
        if (not info.Variant or ent.Variant == info.Variant) then
            if (not info.SubType or ent.SubType == info.SubType) then
                return true;
            end
        end
    end
    return false;
end

local function WillIgnoreEntity(ent)
    for _, info in pairs(EntityInteractions.Ignore) do
        if (FitType(ent, info)) then
            return true;
        end
    end
    return false;
end

local function WillBlockHook(ent)
    for _, info in pairs(EntityInteractions.Block) do
        if (FitType(ent, info)) then
            return true;
        end
    end
    return false;
end

local function WillSetEntityTarget(ent)
    for _, info in pairs(EntityInteractions.SetTargetPosition) do
        if (FitType(ent, info)) then
            return true;
        end
    end
    return false;
end

local function WillNoDragEntity(ent)
    for _, info in pairs(EntityInteractions.NoDrag) do
        if (FitType(ent, info)) then
            return true;
        end
    end
    return false;
end

local maxArmLength = 320;
function Arm.GetArmData(arm, init)
    local data = arm:GetData();
    if (init) then
        if (not data._EXTENDING_ARM) then
            local sprite = Sprite();
            sprite:Load(arm:GetSprite():GetFilename ( ), true);
            sprite:Play("Arm");
            data._EXTENDING_ARM = {
                Shrink = false,
                DragMode = 0,
                LockedPosition = Vector.Zero,
                PulledDistance = 0,
                LockedEntity = nil,
                SpawnWisps = false,
                ArmSprite = sprite
            }
        end
    end
    return data._EXTENDING_ARM;
end

function Arm.GetArmParentPosition(arm)
    local room = THI.Game:GetRoom();
    local parentPos = room:GetCenterPos();

    if (arm.Parent) then
        parentPos = arm.Parent.Position;
    end
    return parentPos;
end

function Arm.ShrinkArm(arm)
    
    local data = Arm.GetArmData(arm, true);
    data.Shrink = true;
end

function Arm.CollisionCheck(arm)
    local room = THI.Game:GetRoom();
    local data = Arm.GetArmData(arm, false);
    if (data and not data.Shrink and data.DragMode <= 0) then
        
        local parentPos = Arm.GetArmParentPosition(arm);
        local caught = false;
        for i, ent in pairs(Isaac.GetRoomEntities()) do
            if ((ent.Type == EntityType.ENTITY_PICKUP or ent.Type == EntityType.ENTITY_SHOPKEEPER or
            ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_PLAYEROBJECTS or 
            ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ALL) and
                Entities.CheckCollision(arm, ent) and not WillIgnoreEntity(ent)) then
                if (WillBlockHook(ent)) then
                    data.DragMode = 1;
                    data.LockedPosition = arm.Position;
                    data.PulledDistance = parentPos:Distance(arm.Position);
                    THI.SFXManager:Play(THI.Sounds.SOUND_HOOK_CATCH);
                    caught = true;
                    break;
                elseif (ent:IsEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:IsDead()) then
                    data.DragMode = 2;
                    data.LockedEntity = ent;
                    ent:AddFreeze(EntityRef(arm.SpawnerEntity), 90);
                    THI.SFXManager:Play(THI.Sounds.SOUND_HOOK_CATCH);
                    caught = true;
                    break;
                elseif (ent.Type == EntityType.ENTITY_PICKUP or ent.Type == EntityType.ENTITY_SLOT or ent.Type == EntityType.ENTITY_BOMBDROP) then
                    data.DragMode = 3;
                    data.LockedEntity = ent;
                    THI.SFXManager:Play(THI.Sounds.SOUND_HOOK_CATCH);
                    caught = true;
                    break;
                end
            end
        end
        if (not caught) then
            local notBlocked, newPos = room:CheckLine(arm.Position, arm.Position + arm.Velocity, 3);
            if (not notBlocked) then
                data.DragMode = 1;
                arm.Position = newPos;
                data.LockedPosition = arm.Position;
                data.PulledDistance = parentPos:Distance(arm.Position);
                THI.SFXManager:Play(THI.Sounds.SOUND_HOOK_CATCH);
            end
        end
    end
end

function Arm:PostArmInit(arm)
    arm:GetSprite():Play("Hand");
end
Arm:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Arm.PostArmInit, Arm.Variant);


function Arm:PostArmUpdate(arm)
    local data = Arm.GetArmData(arm, false);
    if (data) then
        local room = THI.Game:GetRoom();
        local player;
        local parent = arm.Parent;
        if (parent) then
            player = parent:ToPlayer();
        end
        if (data.DragMode > 0) then
            if (player) then
                player:SetMinDamageCooldown(29);
            end
            
        end
        if (arm.FrameCount > 120) then
            arm:Remove();
        end
        local parentPos = Arm.GetArmParentPosition(arm);

        if (data.DragMode == 0) then
            if (not data.Shrink) then
                if (arm.Position:Distance(parentPos) >= maxArmLength) then
                    Arm.ShrinkArm(arm)
                end
                if (data.SpawnWisps and arm.FrameCount % 3 == 2 and player) then
                    local wisp = player:AddWisp(THI.Collectibles.ExtendingArm.Item, arm.Position, false, true);
                    wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
                end
            else
                arm.Velocity = (Arm.GetArmParentPosition(arm) - arm.Position):Normalized() * shrinkSpeed;
                if (arm.Position:Distance(parentPos) <= 16) then
                    arm:Remove();
                end

            end
        elseif (data.DragMode == 1) then -- Drag the player to the target.
            local dir = (arm.Position - parent.Position):Normalized();
            parent.Position = arm.Position - dir * data.PulledDistance;
            data.PulledDistance = math.max(16, data.PulledDistance - 20);
            parent.Velocity = dir * 10;

            arm.Position = data.LockedPosition;
            arm.Velocity = Vector.Zero;
            
            if (arm.Position:Distance(parentPos) <= 22) then
                arm:Remove();
                THI.SFXManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE);
                THI.Game:ShakeScreen(10);
                if (player and not player.CanFly) then
                    local gridEntity = room:GetGridEntityFromPos(player.Position);
                    if (gridEntity and gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT) then
                        player.Velocity = Vector.Zero;
                        player.Position = gridEntity.Position;
                        THI.SFXManager:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT);
                        --player:ResetDamageCooldown();
                        player:AnimatePitfallIn();
                    end
                end
            end
        elseif (data.DragMode == 2 or data.DragMode == 3) then  -- Drag the enemy or pickup.
            local parentToArm = arm.Position - parentPos;
            local ent = data.LockedEntity;
            local nextArmPosition;

            local enemyMoveFirst = false;
            if (EntityExists(ent)) then
                local nextEnemyPos;
                local dir;
                if (enemyMoveFirst) then
                    local enemyToParent = ent.Position - parentPos;
                    dir = enemyToParent:Normalized();
                    local length = enemyToParent:Length();
                    nextEnemyPos = parentPos + dir * (length - 10);

                    -- Check Collision.
                    local notBlocked, newPos = room:CheckLine(ent.Position, nextEnemyPos, 3);
                    if (not notBlocked) then
                        nextEnemyPos = newPos;
                    end

                    nextArmPosition = nextEnemyPos - dir * 16;
                else
                    local armToParent = arm.Position - parentPos;
                    dir = armToParent:Normalized();
                    local length = armToParent:Length();
                    nextArmPosition = parentPos + dir * (length - 10);

                    -- Check Collision.
                    -- local notBlocked, newPos = room:CheckLine(arm.Position, nextArmPosition, 3);
                    -- if (not notBlocked) then
                    --     nextArmPosition = newPos;
                    -- end

                    nextEnemyPos = nextArmPosition + dir * 16;
                end

                if (not WillNoDragEntity(ent)) then
                    if (ent.TargetPosition:Distance(ent.Position) >= 0.5) then
                        ent.Position = nextEnemyPos;
                        ent.Velocity = Vector.Zero;
                        ent:AddVelocity(-dir *  10);
                    end
                    if (WillSetEntityTarget(ent)) then
                        ent.TargetPosition = nextEnemyPos;
                    end
                end
            else
                
                local dir = parentToArm:Normalized();
                local length = parentToArm:Length();

                local speed = 10;
                length = math.max(32, length - speed);

                nextArmPosition = parentPos + dir * length;
            end

            arm.Velocity = nextArmPosition - arm.Position;
            
            arm.SpriteRotation = (nextArmPosition - parentPos):GetAngleDegrees();
            
            if (nextArmPosition:Distance(parentPos) <= 32) then
                -- Chain the enemy..
                if (arm.SubType == Arm.SubTypes.BELIAL) then
                    if (ent and ent:IsActiveEnemy()) then
                        local entData = ent:GetData();
                        if (not entData.ReverieBelialArmCooldown) then
                            entData.ReverieBelialArmCooldown = 300;
                            local chain = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ANIMA_CHAIN, 0, ent.Position, Vector.Zero, arm):ToEffect();
                            chain.LifeSpan = 270;
                            chain.Timeout = chain.LifeSpan;
                            chain.Target = ent;
                        end
                    end
                end
                arm:Remove();
            end
        end

        Arm.CollisionCheck(arm);
    end
end
Arm:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Arm.PostArmUpdate, Arm.Variant);


function Arm:BelialCountdown()
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        local entData = ent:GetData();
        if (entData and entData.ReverieBelialArmCooldown) then
            entData.ReverieBelialArmCooldown = entData.ReverieBelialArmCooldown - 1;
            if (entData.ReverieBelialArmCooldown <= 0) then
                entData.ReverieBelialArmCooldown = nil;
            end
        end
    end
end
Arm:AddCallback(ModCallbacks.MC_POST_UPDATE, Arm.BelialCountdown);

function Arm:PostArmRender(arm, offset)
    local data = Arm.GetArmData(arm, false);
    local game = THI.Game;
    local room = game:GetRoom();
    local reflection = Screen.IsReflection();
    if (data) then
        local sprite = data.ArmSprite;
        local room = THI.Game:GetRoom();
        local parentPos = room:GetCenterPos();
        if (arm.Parent) then
            parentPos = arm.Parent.Position;
        end

        if (sprite) then
            local dir = arm.Position - parentPos;
            local distance = dir:Length();
            sprite.Rotation = dir:GetAngleDegrees();
            local flipY = sprite.FlipY;
            if (reflection) then
                sprite.FlipY = not flipY;
            end
            local segs = math.min(32, math.ceil(distance / 16));
            for i = 1, segs do
                local dis = -i * 16 - 8;
                local positionOffset = dir:Normalized() * dis;
                local pos = Screen.GetEntityOffsetedRenderPosition(arm, offset, positionOffset)

                
                pos = Isaac.WorldToScreen(arm.Position + arm.PositionOffset + positionOffset) + offset - room:GetRenderScrollOffset() - game.ScreenShakeOffset;


                local left = math.max(0, -dis - distance);

                if (reflection) then
                    positionOffset = -positionOffset;
                end

                sprite:Render(pos, Vector(left, 0), Vector(0, 0));
            end
            sprite.FlipY = flipY;
        end
    end

    local armSpr = arm:GetSprite();
    local color = armSpr.Color;
    armSpr.Color = Color(color.R, color.G, color.B, 1, color.RO, color.GO, color.BO);

    local flipY = armSpr.FlipY;
    if (reflection) then
        armSpr.FlipY = not flipY;
    end

    local armPos = Isaac.WorldToScreen(arm.Position + arm.PositionOffset) + offset - room:GetRenderScrollOffset() - game.ScreenShakeOffset;
    armSpr:Render(armPos);
    armSpr.FlipY = flipY;
    armSpr.Color = Color(color.R, color.G, color.B, 0, color.RO, color.GO, color.BO);
end
Arm:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Arm.PostArmRender, Arm.Variant);

return Arm;