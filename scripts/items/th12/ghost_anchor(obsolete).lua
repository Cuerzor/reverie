local Anchor = ModItem("Ghost Anchor", "GHOST_ANCHOR")

local function GetPlayerData(player, create)
    local function default()
        return {
            Moving = false
        }
    end
    return Anchor:GetPlayerData(player, create, default);
end

do
    local function PostPlayerUpdate(mod, player)
        local hasAnchor = player:HasCollectible(Anchor.Item);
        local twin = player:GetOtherTwin();
        if (twin)then
            hasAnchor = hasAnchor or twin:HasCollectible(Anchor.Item);
        end
        if (player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) then
            hasAnchor = false;
        end
        if (hasAnchor) then
            
            if (player:GetMovementInput():Length() <= 0.0001) then
                local data = GetPlayerData(player, false);
                if (data and data.Moving) then
                    data.Moving = false;
                    player.Velocity = Vector.Zero;
                end
            else
                --player.Velocity = player:GetMovementInput():Resized(((player.MoveSpeed + 3) * 2) ^ 2 / 15);
                local data = GetPlayerData(player, true);
                data.Moving = true;
                player.Velocity = player:GetMovementInput():Resized(player.Velocity:Length());
            end
            if (not player.CanFly) then
                player.Position = player.Position - Game():GetRoom():GetWaterCurrent ( ) * 0.2; 
            end
        end
    end
    Anchor:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

    local function EvaluateCache(mod, player, flag)
        if (flag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.1 * player:GetCollectibleNum(Anchor.Item);
        end
    end
    Anchor:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);
end

return Anchor;