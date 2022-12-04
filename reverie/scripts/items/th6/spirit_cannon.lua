local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local EntityExists = Detection.EntityExists;
local Inputs = CuerLib.Inputs;
local Maths = CuerLib.Math;
local Consts = CuerLib.Consts;
local SpiritCannon = ModItem("Spirit Cannon", "SPIRIT_CANNON");

-- SpiritCannon.Costumes = {
--     [Direction.LEFT] = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_spirit_cannon_left.anm2"),
--     [Direction.UP] = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_spirit_cannon_up.anm2"),
--     [Direction.RIGHT] = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_spirit_cannon_right.anm2"),
--     [Direction.DOWN] = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_spirit_cannon_down.anm2"),
-- }

function SpiritCannon:GetPlayerTempData(player, create)
    return self:GetTempData(player, create, function()
        return {
            Timeout = 0,
            Laser = nil,
            -- Direction = Vector(0, 1),
            -- LastDirection = -1,
        }
    end)
end

function SpiritCannon:GetLaserTargetAngle(player)
    local dir = player:GetAimDirection();
    if (dir:Length() < 0.1) then
        -- local data = self:GetPlayerTempData(player, false);
        -- dir = (data and data.Direction) or Vector(0, 1);
        dir = Consts.GetDirectionVector(player:GetMovementDirection());
        if (dir:Length() < 0.1) then
            return Vector(0, 1);
        end
    end
    return dir;
end

function SpiritCannon:ShootLaser(player)
    local aimDir = player:GetAimDirection();
    local dir = 90;
    if (aimDir:Length() > 0.1) then
        dir = aimDir:GetAngleDegrees();
    else
        local moveDir = Consts.GetDirectionVector(player:GetMovementDirection());
        if (moveDir:Length() > 0.1) then
            dir = moveDir:GetAngleDegrees();
        end
    end
    local yOffset = -7.85 * player.SpriteScale.Y - 34.817;
    local laser = EntityLaser.ShootAngle(6, player.Position, dir, 150, Vector(0, yOffset), player);
    laser:AddTearFlags(TearFlags.TEAR_RAINBOW);
    laser.CollisionDamage = 20 *player.Damage;
    return laser;
end
function SpiritCannon:ShootWispLaser(familiar)
    local player = familiar.Player;
    local dir = (familiar.Position-player.Position):GetAngleDegrees();
    local yOffset = -10;
    local laser = EntityLaser.ShootAngle(1, familiar.Position, dir, 0, Vector(0, yOffset), familiar);
    laser:AddTearFlags(TearFlags.TEAR_RAINBOW);
    laser.CollisionDamage = 11;
    laser.MaxDistance = 40;
    return laser;
end

function SpiritCannon:SwitchCostume(player, direction)
    for i = 0, 3 do
        local costume = SpiritCannon.Costumes[i];
        if (direction ~= i) then
            player:TryRemoveNullCostume(costume);
        else
            player:AddNullCostume(costume);
        end
    end
end

function SpiritCannon:PostPlayerUpdate(player)
    local data = self:GetPlayerTempData(player, false);
    --local costumeDirection = -1;
    if (data and data.Timeout > 0) then
        data.Timeout = data.Timeout - 1;

        if (not EntityExists(data.Laser)) then
            data.Laser = self:ShootLaser(player);
        end
        if (data.Timeout > 15) then
            data.Laser.Timeout = data.Timeout - 10;
            if (data.Laser and data.Laser.Shrink) then
                data.Laser:Remove();
                data.Laser = nil
            end
        end
        local dir = self:GetLaserTargetAngle(player);
        local angle = dir:GetAngleDegrees();
        local includedAngle = Maths.GetAngleDiff(data.Laser.Angle, angle);
        local spd = 18;
        if (includedAngle < 0) then
            spd = -18;
        end
        data.Laser:SetActiveRotation(0, includedAngle, spd, false);
        data.Laser.CollisionDamage = 20 * player.Damage;
        -- Set Costume.
        local angle = data.Laser.Angle % 360;
        --costumeDirection = Maths.GetDirectionByAngle(angle);


        if (angle > 180 or angle < 0) then
            data.Laser.DepthOffset = -10;
        else
            data.Laser.DepthOffset = 3000;
        end

        -- Disable Shooting.
        if (player:CanShoot()) then
            local game = Game();
            game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM;
            player:UpdateCanShoot();
            game.Challenge = Challenge.CHALLENGE_NULL;
        end

        if (data.Timeout <= 0) then
            if (data.Laser) then
                data.Laser = nil;
                --costumeDirection = -1;
            end
            player:UpdateCanShoot();
            player:GetEffects():RemoveCollectibleEffect(self.Item);
        end
    end
    -- if (costumeDirection ~= (data and data.LastDirection)) then
    --     self:SwitchCostume(player, costumeDirection);
    --     data = data or self:GetPlayerTempData(player, true);
    --     data.LastDirection = costumeDirection;
    -- end
end
SpiritCannon:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SpiritCannon.PostPlayerUpdate);

function SpiritCannon:PostUseItem(item, rng, player, flags, vardata)
    local data = SpiritCannon:GetPlayerTempData(player, true);
    if (data.Timeout <= 0) then
        data.Laser = self:ShootLaser(player);
    end
    data.Timeout = (data.Timeout or 0) + 300;
    local isLost = playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B;
    if (not isLost) then
        player:AddBrokenHearts(1);
    end
    SFXManager():Play(SoundEffect.SOUND_MEGA_BLAST_START);
end
SpiritCannon:AddCallback(ModCallbacks.MC_USE_ITEM, SpiritCannon.PostUseItem, SpiritCannon.Item);

-- function SpiritCannon:InputAction(entity, hook, action)
--     if (entity and entity:ToPlayer()) then
--         if (action == ButtonAction.ACTION_SHOOTRIGHT) then
--             if (hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED) then
--                 return true;
--             else
--                 return 1
--             end
--         end
--     end
-- end
-- SpiritCannon:AddCallback(ModCallbacks.MC_INPUT_ACTION, SpiritCannon.InputAction);

function SpiritCannon:PostNewRoom()
    for p, player in Detection.PlayerPairs(true, true) do
        local data = self:GetPlayerTempData(player, false);
        if (data) then
            data.Timeout = 0;
            data.Laser = nil;
            player:UpdateCanShoot();
        end
    end
end
SpiritCannon:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SpiritCannon.PostNewRoom);


function SpiritCannon:PostFamiliarUpdate(familiar)
    if (familiar.SubType == self.Item) then
        local data = familiar:GetData();
        local player = familiar.Player;
        if (player and Inputs:GetShootingVector(player, familiar.Position):Length() > 0) then
            if (not EntityExists(data._REVERIE_SPIRIT_CANNON_WISP_LASER)) then
                data._REVERIE_SPIRIT_CANNON_WISP_LASER = self:ShootWispLaser(familiar);
            end
            data._REVERIE_SPIRIT_CANNON_WISP_LASER.Angle = (familiar.Position - player.Position):GetAngleDegrees();
            data._REVERIE_SPIRIT_CANNON_WISP_LASER.SpriteScale = Vector(0.5,1);
            data._REVERIE_SPIRIT_CANNON_WISP_LASER.Size = 8;
        else
            if (EntityExists(data._REVERIE_SPIRIT_CANNON_WISP_LASER)) then
                data._REVERIE_SPIRIT_CANNON_WISP_LASER.Shrink = true;
            end
        end
    end
end
SpiritCannon:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SpiritCannon.PostFamiliarUpdate, FamiliarVariant.WISP);

return SpiritCannon;