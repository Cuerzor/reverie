local Entities = CuerLib.Entities;
local CompareEntity = Entities.CompareEntity;
local EntityExists = Entities.EntityExists;
local HoldingActive = CuerLib.HoldingActive;
local Inputs = CuerLib.Inputs;
local Players = CuerLib.Players;

local ExtendingArm = ModItem("Extending Arm", "ExtendingArm");

function ExtendingArm.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        data._EXTENDING_ARM = data._EXTENDING_ARM or {
            Arm = nil,
            TargetDir = Vector.Zero,
            FireCooldown = 0
        }
    end
    return data._EXTENDING_ARM;
end

function ExtendingArm:UseArm(item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_CARBATTERY <= 0) then
        local tempData = ExtendingArm.GetPlayerTempData(player, true);
        if (not EntityExists(tempData.Arm)) then
            return HoldingActive:SwitchHolding(item, player, slot, flags);
        else
            tempData.Arm:Remove();
        end
    end
    return {Discharge = false}
end
ExtendingArm:AddCallback(ModCallbacks.MC_USE_ITEM, ExtendingArm.UseArm, ExtendingArm.Item);
function ExtendingArm:PostPlayerEffect(player)

    HoldingActive:ReleaseOnShoot(player, ExtendingArm.Item);

    local tempData = ExtendingArm.GetPlayerTempData(player, false);
    if (tempData) then
        tempData.FireCooldown = tempData.FireCooldown or 0;
        if (tempData.FireCooldown > 0) then
            tempData.FireCooldown = tempData.FireCooldown - 1;
            if (tempData.FireCooldown <= 0) then
                local dir = Inputs.GetRawShootingVector(player);
                if (dir:Length()<0.1) then
                    dir = tempData.TargetDir;
                end
                local vel = dir:Normalized() * 20;
                vel = vel + player:GetTearMovementInheritance(dir) * 2;
                THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
                
                local Arm = THI.Effects.ExtendingArm;
                local subtype = Arm.SubTypes.NORMAL;
                if (Players.HasJudasBook(player)) then
                    subtype = Arm.SubTypes.BELIAL;
                end
                local arm = Isaac.Spawn(Arm.Type, Arm.Variant, subtype, player.Position, vel, player);
                local armData = Arm.GetArmData(arm, true);
                arm.Parent = player;
                armData.Velocity = vel;
                armData.SpawnWisps = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES);
                arm.SpriteRotation = vel:GetAngleDegrees();
                arm.PositionOffset = Vector(0, -10);
                arm:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
                arm.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_BULLET;
                tempData.Arm = arm;
            end
        end
    end
end
ExtendingArm:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ExtendingArm.PostPlayerEffect);

function ExtendingArm:FireArm(player, item, direction)
    local tempData = ExtendingArm.GetPlayerTempData(player, true);
    tempData.FireCooldown = 2;
    tempData.TargetDir = direction;
end
ExtendingArm:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_RELEASE_HOLDING_ACTIVE, ExtendingArm.FireArm, ExtendingArm.Item)

function ExtendingArm:PostWispUpdate(familiar)
    if (familiar.SubType == ExtendingArm.Item) then
        if (familiar.FrameCount > 90) then
            familiar:Kill();
        end
    end
end
ExtendingArm:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ExtendingArm.PostWispUpdate, FamiliarVariant.WISP);

function ExtendingArm:PostNewRoom()
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, ExtendingArm.Item)) do
        ent:Remove();
    end
end
ExtendingArm:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ExtendingArm.PostNewRoom);

return ExtendingArm;