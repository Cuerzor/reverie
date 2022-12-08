local Consts = CuerLib.Consts;
local Entities = CuerLib.Entities;
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;
local Players = CuerLib.Players;
local Familiars = CuerLib.Familiars;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Tears = CuerLib.Tears;


local PsycheEye = ModEntity("Psyche Eye Familiar", "PsycheEye");

PsycheEye.FriendlyLimit = 5;
PsycheEye.TearColor = Color(1, 0, 1, 1, 0, 0, 0);
PsycheEye.VesselVariant = Isaac.GetEntityVariantByName("Psyche Eye Vessel");

function PsycheEye.GetVesselPosition(familiar, player, right)
    local player2Fam = familiar.Position - player.Position;
    local angle = -90;
    if (right) then
        angle = 90;
    end
    local offset = player2Fam:Rotated(angle):Normalized() * 8;
    return (familiar.Position + familiar.Velocity + player.Velocity + player.Position) / 2 + offset;
end

--function PsycheEye.GetNPCData(npc, init)
--    return PsycheEye:GetData(npc, init, function() return {
        --MindControlled = false
--    } end);
--end

function PsycheEye.GetPlayerData(player, init)
    return PsycheEye:GetData(player, init, function() return {
        EyeCount = 0, 
        ControlledCount = 0
    } end);
end

local function GetNPCData(npc, init)
    return PsycheEye:GetTempData(npc, init, function() return {
        RemainsFountainPlayer = nil,
        RemainsFountainFrame = -1,
    } end);
end

function PsycheEye:MarkFountain(target, player)
    local npcData = GetNPCData(target , true);
    npcData.RemainsFountainFrame = target.FrameCount;
    npcData.RemainsFountainPlayer = player;
end

Tears:RegisterModTearFlag("Mind Control");
function PsycheEye:AddMindControlTear(tear)
    local flags = Tears.GetModTearFlags(tear, true);
    flags:Add(Tears.TearFlags["Mind Control"]);
end

function PsycheEye:IsMindControlTear(tear)
    local flags = Tears.GetModTearFlags(tear, false);
    return flags and flags:Has(Tears.TearFlags["Mind Control"]);
end

function PsycheEye.GetFamiliarTempData(familiar, init)
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

function PsycheEye.FireTear(familiar, position, velocity)
    local player = familiar.Player;
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 1, 0, position, velocity, familiar):ToTear();
    
    tear.CollisionDamage = 2.5;

    Familiars.ApplyTearEffect(player, tear);
    return tear;
end

function PsycheEye.SpawnVessel(familiar, player, right)
    local pos = PsycheEye.GetVesselPosition(familiar, player, right);
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
    local data = PsycheEye.GetFamiliarTempData(familiar, true);
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
                        if (not ent:IsBoss()) then
                            PsycheEye:MarkFountain(ent);
                        end
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
        Familiars:PlayShootAnimation(familiar, headDirection);
    else
        -- Fire.
        local fireDir = Familiars:GetFireVector(familiar, dir)
        Familiars:DoFireCooldown(familiar);
        if (dir ~= Direction.NO_DIRECTION and Familiars:canFire(familiar) and (player == nil or player:IsExtraAnimationFinished())) then
            
            familiar.HeadFrameDelay = 15;
            familiar.FireCooldown = 30;
            local tear = PsycheEye.FireTear(familiar, familiar.Position, fireDir * 15);
            PsycheEye:AddMindControlTear(tear);
            tear:SetColor(PsycheEye.TearColor, -1, 0, false, false);
        end
        
        Familiars:AnimationUpdate(familiar, facingVector);
    end
    
    local player = familiar.Player;
    if (player) then
        local playerData = PsycheEye.GetPlayerData(player, false);
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

-- function PsycheEye:PostFamiliarRender(familiar, offset)
--     local data = PsycheEye.GetFamiliarTempData(familiar, false);
--     local player = familiar.Player;
--     if (data and player) then
--         local pos = Screen.GetEntityOffsetedRenderPosition(familiar, offset, Vector(0, -6));
--         local playerPos = player.Position;
--         local spr = data.VesselSprite;
--         spr.Rotation = (playerPos - familiar.Position):GetAngleDegrees() + 90;
--         spr:Render(pos)
--     end
-- end
-- PsycheEye:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, PsycheEye.PostFamiliarRender, PsycheEye.Variant)


function PsycheEye:PostVesselUpdate(effect)
    local parent = effect.Parent;
    local child = effect.Child;
    if (parent and child) then
        local pos = PsycheEye.GetVesselPosition(child, parent, not effect.FlipX);
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
    local isFly = other.Type == EntityType.ENTITY_FLY or other.Type == EntityType.ENTITY_ATTACKFLY;
    local isSpider = other.Type == EntityType.ENTITY_SPIDER or other.Type == EntityType.ENTITY_STRIDER;

    if (not isFly and not isSpider) then
        
        local friendlyCount = 0;
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (ent:IsActiveEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                friendlyCount = friendlyCount + 1;
                if (friendlyCount >= PsycheEye.FriendlyLimit) then
                    return nil;
                end
            end
        end
    end

    if (other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if (PsycheEye:IsMindControlTear(tear)) then
            local spawner = tear.SpawnerEntity;
            local player = nil;
            while (spawner) do
                if (spawner.Type == EntityType.ENTITY_PLAYER) then
                    player = spawner:ToPlayer();
                    break;
                end
                spawner = spawner.SpawnerEntity;
            end
            if (player) then
                local playerData = PsycheEye.GetPlayerData(player, true);
                if (not other:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)) then -- Avoid some uncharmable enemies to be controlled.
                    if (other:IsBoss() or other.Type == EntityType.ENTITY_THE_HAUNT or other.Type == EntityType.ENTITY_EXORCIST) then -- or playerData.ControlledCount >= maxControlCount) then
                        other:AddCharmed( EntityRef(player), 150);
                    else
                        if (isFly) then
                            other:Remove();
                            player:AddBlueFlies (1, other.Position, nil)
                        elseif (isSpider) then
                            other:Remove();
                            player:AddBlueSpider(other.Position)
                        else
                            other:TakeDamage(tear.CollisionDamage, 0, EntityRef(tear), 0);
                            other:AddCharmed( EntityRef(player), -1);
                        end
                        --local npcData = PsycheEye.GetNPCData(other, true);
                        --npcData.MindControlled = true;
                        --playerData.ControlledCount = playerData.ControlledCount + 1;
                        THI.SFXManager:Play(THI.Sounds.SOUND_MIND_CONTROL);
                        if (not tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
                            tear:Die();
                        end
                    end
                end
            end
        end
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, PsycheEye.PreTearCollision)

-- function PsycheEye:PostPlayerEffect(player)

--     local playerData = PsycheEye.GetPlayerData(player, false);
--     if (playerData) then
--         local npcs = playerData.ControlledNPC;
--         for i = #npcs, 1, -1 do
--             local ent = npcs[i];
--             if (not ent or not ent:Exists()) then
--                 table.remove(playerData.ControlledNPC, i);
--             end
--         end
--     end
-- end
-- PsycheEye:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PsycheEye.PostPlayerEffect)


local function PostEntityRemove(mod, entity)
    local data = GetNPCData(entity, false);
    if (entity:IsDead() and data and (data.RemainsFountainFrame > 0 and entity.FrameCount - data.RemainsFountainFrame < 3)) then
                    
        local Fountain = THI.Effects.RemainsFountain;
        Fountain:SpawnRemain(entity, entity.Position, data.RemainsFountainPlayer);
        data.RemainsFountainFrame = -1;
        data.RemainsFountainPlayer = nil;
    end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEntityRemove)

function PsycheEye:PostNewRoom()

    local game = THI.Game;
    for i, player in Players.PlayerPairs(true, true) do
        local playerData = PsycheEye.GetPlayerData(player, false);
        if (playerData) then
            playerData.ControlledCount = 0;
        end
    end
    -- for i, ent in pairs(Isaac.GetRoomEntities()) do
    --     if (ent:IsEnemy()) then
    --         local npcData = PsycheEye.GetNPCData(ent, false);
    --         if (npcData and npcData.MindControlled) then
    --             ent:Remove();
    --         end
    --     end
    -- end
end
PsycheEye:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PsycheEye.PostNewRoom)

return PsycheEye;