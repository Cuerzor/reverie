local Actives = CuerLib.Actives
local GapFloor = THI.GapFloor;

local Gap = ModItem("The Gap", "Gap");


----------- Events ----------------
function Gap:onUseGap(item, rng, player, flags, slot, data)
    if (GapFloor.IsStandingOnMap(player) == nil) then
        local room = THI.Game:GetRoom();
        GapFloor.GenerateMaps(room:GetGridIndex(player.Position))
        return {ShowAnim = true};
    else 
        return {Discharge = false};
    end
end

Gap:AddCallback(ModCallbacks.MC_USE_ITEM, Gap.onUseGap, Gap.Item);

function Gap:onPlayerEffect(player)
    local effectData = GapFloor.GetPlayerGapEffectData(player);
    local standingGap = false;
    if (GapFloor.TeleportCooldown <= 0) then
        local map = GapFloor.IsStandingOnMap(player);
        if (map ~= nil) then
            local room = THI.Game:GetRoom();
            local playerGridIndex = room:GetGridIndex(player.Position);
            local pos = room:GetGridPosition(playerGridIndex);
            if (player:HasCollectible(Gap.Item)) then
                if (effectData.Effect == nil or effectData.lastGridIndex ~= playerGridIndex) then
                    
                    if (effectData.Effect ~= nil) then
                        effectData.Effect:GetSprite():Play("Close Animation");
                        effectData.Effect = nil;
                    end
                    effectData.Effect = Isaac.Spawn(GapFloor.Effect.Type, GapFloor.Effect.Variant, 0, pos, Vector.Zero, player);
                    
                    effectData.Effect:GetSprite():Play("Open Animation");
                    effectData.Effect.DepthOffset = -100;
                    effectData.lastGridIndex = playerGridIndex;
                end
                standingGap = true;
            end
            if (Actives.IsActiveItemDown(player, Gap.Item)) then
                player.Position = pos;
                player:AnimateTrapdoor ( )
                THI.Game:StartRoomTransition (map.State, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, player);
                GapFloor.TeleportCooldown = 30;
            end
        end
    end

    if (effectData.Effect ~= nil) then
        if (not standingGap) then
            effectData.Effect:GetSprite():Play("Close Animation");
            effectData.Effect = nil;
        end
    end
end

Gap:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Gap.onPlayerEffect);

return Gap;