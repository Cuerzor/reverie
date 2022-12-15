local Consts = CuerLib.Consts;
local Entities = CuerLib.Entities;
local Familiars = CuerLib.Familiars;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Tears = CuerLib.Tears;
local PsycheEye = ModEntity("Psyche Eye Familiar", "PsycheEye");
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;

PsycheEye.MaxScanProgress = 100;
PsycheEye.FriendlyLimit = 5;
PsycheEye.TearColor = Color(1, 0, 1, 1, 0, 0, 0);
PsycheEye.VesselVariant = Isaac.GetEntityVariantByName("Psyche Eye Vessel");
local connectionSprite = Sprite();
connectionSprite:Load("gfx/reverie/mind_connection.anm2", true)
PsycheEye.ConnectionSprite = connectionSprite;

local function GetPlayerData(player, init)
    return PsycheEye:GetData(player, init, function() return {
        EyeCount = 0
    } end);
end

local function GetNPCData(npc, init)
    return PsycheEye:GetTempData(npc, init, function() return {
        -- RemainsFountainPlayer = nil,
        -- RemainsFountainFrame = -1,
        Scanner = nil
    } end);
end

local function GetFamiliarTempData(familiar, init)
    local data = familiar:GetData();
    if (init) then
        if (not data._PSYCHE_EYE) then
            local sprite = Sprite();
            sprite:Load(familiar:GetSprite():GetFilename(), true);
            sprite:Play("Vessel");
            data._PSYCHE_EYE = {
                Index = 0,
                VesselLeft = nil,
                VesselRight = nil,
                MindBlowCharge = 0,
                MindBlowCooldown = 0,
                MindBlowClearTimeout = 0,
            }
        end
    end
    return data._PSYCHE_EYE;
end


function PsycheEye:GetVesselPosition(familiar, player, right)
    local player2Fam = familiar.Position - player.Position;
    local angle = -90;
    if (right) then
        angle = 90;
    end
    local offset = player2Fam:Rotated(angle):Normalized() * 8;
    return (familiar.Position + familiar.Velocity + player.Velocity + player.Position) / 2 + offset;
end

PsycheEye.GetPlayerData = GetPlayerData;
PsycheEye.GetFamiliarTempData = GetFamiliarTempData;

-- Mind Control Tear.
Tears:RegisterModTearFlag("Mind Control");
function PsycheEye:AddMindControlTear(tear)
    local flags = Tears:GetModTearFlags(tear, true);
    flags:Add(Tears.TearFlags["Mind Control"]);
end

function PsycheEye:IsMindControlTear(tear)
    local flags = Tears:GetModTearFlags(tear, false);
    return flags and flags:Has(Tears.TearFlags["Mind Control"]);
end

function PsycheEye:CanControl(entity)
    if (entity and entity:Exists() and entity:IsActiveEnemy() and entity:CanShutDoors()and not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then 
        local EntityTags = THI.Shared.EntityTags;
        local isFly = EntityTags:EntityFits(entity, "ConvertToBlueFlies");
        local isSpider = EntityTags:EntityFits(entity, "ConvertToBlueSpiders");

        if (not isFly and not isSpider) then
            local friendlyCount = 0;
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if (ent:IsActiveEnemy() and ent:CanShutDoors() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    friendlyCount = friendlyCount + 1;
                    if (friendlyCount >= PsycheEye.FriendlyLimit) then
                        return false;
                    end
                end
            end
        end

        return true;
    end
    return false;
end


function PsycheEye:IsValidTarget(familiar, entity)
    local player = familiar.Player;
    local centerPos = (player and player.Position) or familiar.Position;

    local targetData = GetNPCData(entity, false);
    if (targetData) then
        if (targetData.Scanner and not CompareEntity(targetData.Scanner, familiar)) then
            return false;
        end
    end

    return PsycheEye:CanControl(entity) and entity.Position:Distance(centerPos) <= 280;
end

function PsycheEye:FindTarget(familiar)
    local minHPTarget;
    local minHP; 
    local player = familiar.Player;
    if (player) then
        for _, ent in ipairs(Isaac.FindInRadius(player.Position, 240, EntityPartition.ENEMY)) do
            if (PsycheEye:CanControl(ent)) then
                if (not minHPTarget or ent.HitPoints < minHP) then
                    minHPTarget = ent;
                    minHP = ent.HitPoints;
                end
            end
        end
    end
    return minHPTarget;
end

function PsycheEye:ControlEntity(target, source)
    if (target:IsBoss() or target.Type == EntityType.ENTITY_THE_HAUNT or target.Type == EntityType.ENTITY_EXORCIST) then
        target:AddCharmed( EntityRef(source), 150);
    else
        local EntityTags = THI.Shared.EntityTags;
        local isFly = EntityTags:EntityFits(target, "ConvertToBlueFlies");
        local isSpider = EntityTags:EntityFits(target, "ConvertToBlueSpiders");
        if (isFly) then
            target:Remove();
            source:AddBlueFlies (1, target.Position, nil)
        elseif (isSpider) then
            target:Remove();
            source:AddBlueSpider(target.Position)
        else
            target:AddCharmed( EntityRef(source), -1);
        end

        THI.SFXManager:Play(THI.Sounds.SOUND_MIND_CONTROL);
    end
end



function PsycheEye.SpawnVessel(familiar, player, right)
    local pos = PsycheEye:GetVesselPosition(familiar, player, right);
    local vessel = Isaac.Spawn(EntityType.ENTITY_EFFECT, PsycheEye.VesselVariant, 0, pos, Vector.Zero, familiar);
    vessel.Parent = player;
    vessel.Child = familiar;
    vessel:GetSprite():Play("Vessel");
    if (not right) then
        vessel.FlipX = true;
    end
    vessel:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
    return vessel;
end

function PsycheEye:PostFamiliarUpdate(familiar)
    local player = familiar.Player;
    local data = GetFamiliarTempData(familiar, true);
    local dir = player:GetFireDirection();
    
    familiar.PositionOffset = Vector(0, -3);
    
    local headDirection = player:GetHeadDirection();
    local facingVector = Consts.DirectionVectors[headDirection];
    local controllerIndex = player.ControllerIndex;
    local holdingDrop = Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex);
    local shooting = player:GetShootingInput():Length() > 0.1;

    if ((not holdingDrop or not shooting) and data.MindBlowClearTimeout < 0) then
        data.MindBlowCharge = 0;
        data.MindBlowClearTimeout = 3;
    end
    if (data.MindBlowCooldown >= 0) then
        data.MindBlowCooldown = data.MindBlowCooldown - 1;
    end
    if (data.MindBlowClearTimeout >= 0) then
        data.MindBlowClearTimeout = data.MindBlowClearTimeout - 1;
    end
    if (holdingDrop) then
        familiar.Target = nil;
        
        if (shooting and data.MindBlowCooldown < 0) then
            data.MindBlowClearTimeout = 3;
            data.MindBlowCharge = data.MindBlowCharge +1;
            if (data.MindBlowCharge == 15) then
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE)
                local Wave = THI.Effects.SpellCardWave;
                local wave = Isaac.Spawn(Wave.Type, Wave.Variant, 0, familiar.Position, Vector.Zero, familiar);
                wave.Parent = familiar;
                wave:SetColor(Color(1,0,1,1,0,0,0),-1,0);
            end
            if (data.MindBlowCharge == 45) then
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE)
                Game():ShakeScreen(30);
                for _, ent in ipairs(Isaac.GetRoomEntities()) do
                    if (not ent:IsDead() and ent:IsActiveEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:HasEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)) then
                        ent:Kill();
                        ent:BloodExplode();
                        -- if (not ent:IsBoss()) then
                        --     PsycheEye:MarkFountain(ent);
                        -- end
                    else
                        local distance = ent.Position:Distance(familiar.Position);
                        if (ent.Type ~= EntityType.ENTITY_PLAYER and  distance <= 240) then
                            ent:AddVelocity((ent.Position - familiar.Position):Resized((240 - distance) / 240 * 50));
                        end

                        -- if (ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        --     ent:AddConfusion(EntityRef(familiar), 90);
                        -- end
                    end
                end
                data.MindBlowCooldown = 90;

                local Wave = THI.Effects.SpellCardWave;
                for i = 1, 3 do
                
                    local wave = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, familiar.Position, Vector.Zero, familiar);
                    wave:SetColor(Color(1,0,1,1,0,0,0),-1,0);
                    wave.SpriteScale = Vector(i, i);
                end
            end
        end
        Familiars.PlayShootAnimation(familiar, headDirection);
    else
        
        local recheckTarget = false;
        if (not familiar.Target or not familiar.Target:Exists() or familiar.Target:IsDead()) then
            recheckTarget = true;
        else
            if (familiar:IsFrame(4, 0)) then
                if (not PsycheEye:IsValidTarget(familiar, familiar.Target)) then
                    recheckTarget = true;
                end
            end
        end
        if (recheckTarget) then
            -- local target = PsycheEye:FindTarget(familiar);
            -- familiar.Target = target;
            familiar.Target = nil;
            data.ScanProgress = 0;
        end

        if (familiar.Target) then
            -- Set target's Scanner.
            local targetData = GetNPCData(familiar.Target, true);
            targetData.Scanner = familiar;

            local hitPoints = familiar.Target.HitPoints;
            local damage = player.Damage;

            -- Scan.
            facingVector = (familiar.Target.Position - familiar.Position):Normalized();
            local scanSpeed = 30 / (player.MaxFireDelay + 1);
            if (familiar.Target:IsBoss()) then
                hitPoints = hitPoints / 20;
            end
            if (hitPoints <= 0) then
                scanSpeed = 120;
            else
                scanSpeed = scanSpeed * damage / hitPoints;
            end
            scanSpeed = math.min(120, scanSpeed);
            data.ScanProgress = data.ScanProgress + scanSpeed;
            while (data.ScanProgress > PsycheEye.MaxScanProgress) do
                data.ScanProgress = data.ScanProgress - PsycheEye.MaxScanProgress;
                -- local chance = 100;
                -- if (hitPoints > 0) then
                --     chance = 100 * (1 + 1 / hitPoints) ^ (damage - hitPoints) - 50
                -- end
                -- if (THI.RandomFloat(100) < chance and PsycheEye:CanControl(familiar.Target)) then
                if (PsycheEye:CanControl(familiar.Target)) then
                    PsycheEye:ControlEntity(familiar.Target, player);
                    familiar.Target = nil;
                    data.ScanProgress = 0;
                    break;
                end
            end
        else
            data.ScanProgress = 0;
        end
        Familiars.AnimationUpdate(familiar, facingVector);
    end
    

    -- Position Update.
    if (player) then
        local playerData = GetPlayerData(player, false);
        local angle = (data.Index - 1) * 15;
        if (playerData) then
            angle = angle - (playerData.EyeCount - 1) * 7.5;
        end
        local playerPos = player.Position;
        local offset = facingVector:Rotated(angle);
        local player2Familiar = familiar.Position - playerPos;
        local nextAngle = player2Familiar:GetAngleDegrees() + Math.GetIncludedAngle(player2Familiar, offset) / 2;

        local nextPos = playerPos + Vector.FromAngle(nextAngle) * 20;
        local targetVelocity = nextPos - familiar.Position;
        familiar.Velocity = familiar.Velocity + (targetVelocity - familiar.Velocity) / 2;

        
        -- Vessel
        if (not EntityExists(data.VesselLeft)) then
            data.VesselLeft = PsycheEye.SpawnVessel(familiar, player, false)
        end

        if (not EntityExists(data.VesselRight)) then
            data.VesselRight = PsycheEye.SpawnVessel(familiar, player, true)
        end
    end

end
PsycheEye:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PsycheEye.PostFamiliarUpdate, PsycheEye.Variant)

local function PostUpdate(mod)
    -- Clear Scanner Data.
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        local targetData = GetNPCData(ent, false);
        if (targetData and targetData.Scanner) then
            local scanner = targetData.Scanner;
            if (not scanner or not scanner:Exists() or not CompareEntity(scanner.Target, ent)) then
                targetData.Scanner = nil;
            end
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostFamiliarRender(mod, familiar, offset)
    if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
        if (familiar.Target) then
            local data = GetFamiliarTempData(familiar, false);
            if (data) then
                local targetPos = Screen.GetEntityOffsetedRenderPosition(familiar.Target, offset, familiar.Target.PositionOffset);
                local pos = Screen.GetEntityOffsetedRenderPosition(familiar, offset, familiar.PositionOffset + Vector(0, -10));
                local spr = PsycheEye.ConnectionSprite;
                spr:SetFrame("Idle", math.floor(data.ScanProgress / PsycheEye.MaxScanProgress * 100));
                local this2Target = pos - targetPos;
                spr.Rotation = this2Target:GetAngleDegrees();
                spr.Scale = Vector(this2Target:Length() / 32, 0.2);
                spr:Render(targetPos)
            end
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, PostFamiliarRender, PsycheEye.Variant)


function PsycheEye:PostVesselUpdate(effect)
    local parent = effect.Parent;
    local child = effect.Child;
    if (parent and child) then
        local pos = PsycheEye:GetVesselPosition(child, parent, not effect.FlipX);
        effect.PositionOffset = Vector(0, -15);
        effect.DepthOffset = -3;
        effect.Friction = 1;
        effect.Position = pos;
        effect.Velocity = parent.Velocity;
        effect.SpriteRotation = (parent.Position - child.Position):GetAngleDegrees() + 90;
        if (effect.FlipX) then
            effect.SpriteRotation = - effect.SpriteRotation;
        end
    else
        effect:Remove();
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PsycheEye.PostVesselUpdate, PsycheEye.VesselVariant)

function PsycheEye:PreTearCollision(tear, other, low)

    local player;
    local spawner = tear.SpawnerEntity;
    if (spawner) then
        player = spawner:ToPlayer();
    end
    if (player) then
        for _, ent in ipairs(Isaac.FindByType(PsycheEye.Type, PsycheEye.Variant)) do
            local familiar = ent:ToFamiliar();
            if (not familiar.Target and CompareEntity(familiar.Player, player) and PsycheEye:IsValidTarget(familiar, other)) then
                familiar.Target = other;
                break;
            end
        end
    end
    
    if (other:IsVulnerableEnemy()) then
        if (PsycheEye:IsMindControlTear(tear) and PsycheEye:CanControl(other)) then
            local spawner = tear.SpawnerEntity;
            PsycheEye:ControllEntity(other, spawner);
        end
    end
end
PsycheEye:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.LATE, PsycheEye.PreTearCollision)


return PsycheEye;