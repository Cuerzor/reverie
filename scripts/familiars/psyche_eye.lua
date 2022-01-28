local Consts = CuerLib.Consts;
local Detection = CuerLib.Detection;
local Familiars = CuerLib.Familiars;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local PsycheEye = ModEntity("Psyche Eye Familiar", "PsycheEye");
local mindControlColor = Color(1, 0, 1, 1, 0, 0, 0);
local maxControlCount = 3;


local CompareEntity = Detection.CompareEntity;
local EntityExists = Detection.EntityExists;

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

function PsycheEye.GetTearData(tear, init)
    return PsycheEye:GetData(tear, init, function() return {
        MindControl = false
    } end);
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
                VesselRight = nil
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
    local facingVector = Consts.DirectionVectors[headDirection + 1];
    local fireDir = Familiars:GetFireVector(familiar, dir)
    Familiars:DoFireCooldown(familiar);
    if (dir ~= Direction.NO_DIRECTION and Familiars:canFire(familiar) and (player == nil or player:IsExtraAnimationFinished())) then
        
        familiar.HeadFrameDelay = 15;
        familiar.FireCooldown = 30;
        local tear = PsycheEye.FireTear(familiar, familiar.Position, fireDir * 10);
        local tearData = PsycheEye.GetTearData(tear, true);
        tearData.MindControl = true;
        tear:SetColor(mindControlColor, -1, 0, false, false);
    end
    
    Familiars:AnimationUpdate(familiar, facingVector);
    
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
    if (other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        local tearData = PsycheEye.GetTearData(tear, false);
        if (tearData and tearData.MindControl) then
            local spawner = tear.SpawnerEntity;
            local familiar = nil;
            local player = nil;
            if (spawner) then
                familiar = spawner:ToFamiliar();
            end
            if (familiar) then
                player = familiar.Player;
            end
            if (player) then
                local playerData = PsycheEye.GetPlayerData(player, true);
                if (other:IsBoss() or other.Type == EntityType.ENTITY_THE_HAUNT or other.Type == EntityType.ENTITY_EXORCIST) then -- or playerData.ControlledCount >= maxControlCount) then
                    other:AddCharmed( EntityRef(player), 150);
                else
                    other:AddCharmed( EntityRef(player), -1);
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

function PsycheEye:PostNewRoom()

    local game = THI.Game;
    for i, player in Detection.PlayerPairs(true, true) do
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