local Actives = CuerLib.Actives
local GapFloor = THI.GapFloor;

local Gap = ModItem("The Gap", "Gap");


----------- Events ----------------
function Gap:TryUseItem(item, player, slot)
    local map = GapFloor.IsStandingOnMap(player);
    if (map) then
        return true;
    end
end
Gap:AddCallback(CuerLib.Callbacks.CLC_TRY_USE_ITEM, Gap.TryUseItem, Gap.Item);

function Gap:onUseGap(item, rng, player, flags, slot, data)
    if (GapFloor.IsStandingOnMap(player) == nil) then
        local room = THI.Game:GetRoom();
        GapFloor.GenerateMaps(room:GetGridIndex(player.Position))
        return {ShowAnim = true};
    else 
        local map = GapFloor.IsStandingOnMap(player);
        if (map) then
            local game = Game();
            local level = game:GetLevel();
            local room = game:GetRoom();
            local playerGridIndex = room:GetGridIndex(player.Position);
            local pos = room:GetGridPosition(playerGridIndex);
            player.Position = pos;
            player:AnimateTrapdoor ( )
            local index = map.State;
            if (not level:GetRoomByIdx(index).Data) then
                index = -2;
            end
            game:StartRoomTransition (index, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, player);
            GapFloor.TeleportCooldown = 30;
        end
        return {Discharge = false};
    end
end

Gap:AddCallback(ModCallbacks.MC_USE_ITEM, Gap.onUseGap, Gap.Item);

function Gap:onPlayerUpdate(player)
    local effectData = GapFloor.GetPlayerGapEffectData(player);
    local standingGap = false;
    if (GapFloor.TeleportCooldown <= 0) then
        local map = GapFloor.IsStandingOnMap(player);
        if (map) then
            local room = Game():GetRoom();
            local playerGridIndex = room:GetGridIndex(player.Position);
            local pos = room:GetGridPosition(playerGridIndex);
            if (player:HasCollectible(Gap.Item)) then
                local gapEffect = effectData.Effect;
                if (gapEffect == nil or effectData.lastGridIndex ~= playerGridIndex) then
                    
                    if (gapEffect ~= nil) then
                        gapEffect:GetSprite():Play("Close Animation");
                        gapEffect = nil;
                    end
                    gapEffect = Isaac.Spawn(GapFloor.Effect.Type, GapFloor.Effect.Variant, 0, pos, Vector.Zero, player);
                    
                    gapEffect:GetSprite():Play("Open Animation");
                    gapEffect.DepthOffset = -100;
                    effectData.lastGridIndex = playerGridIndex;
                end
                effectData.Effect = gapEffect;
                standingGap = true;
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

Gap:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Gap.onPlayerUpdate);

return Gap;