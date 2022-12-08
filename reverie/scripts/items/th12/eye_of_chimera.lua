local Callbacks = CuerLib.Callbacks;
local Detection = CuerLib.Detection;
local Screen = CuerLib.Screen;
local EntityExists = Detection.EntityExists;
local CompareEntity = Detection.CompareEntity;
local Players = CuerLib.Players;
local EyeOfChimera = ModItem("Eye of Chimera", "EYE_OF_CHIMERA");
EyeOfChimera.HasEye = nil;

function EyeOfChimera:GetTempPlayerData(player, create)
    return self:GetTempData(player, create, function()
        return {
            DisplayerEntity = nil
        }
    end)
end


function EyeOfChimera:GetNearestCollectible(player)
    if (not self.HasEye) then
        return nil;
    end

    local nearest = nil;
    local nearestDis = 0;
    for _, ent in ipairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.PICKUP)) do
        if (ent.Variant == PickupVariant.PICKUP_COLLECTIBLE and ent.SubType ~= 0 and THI:IsUnknownItem(ent)) then
            local dis = player.Position:DistanceSquared(ent.Position);
            if (not nearest or dis < nearestDis) then
                nearest = ent;
                nearestDis = dis;
            end
        end 
    end
    return nearest;
end

function EyeOfChimera:UseItem(item, rng, player, flags, slot, varData)
    flags = flags & (~UseFlag.USE_OWNED) | UseFlag.USE_NOANIM;
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, flags);
    return {ShowAnim = true}
end
EyeOfChimera:AddCallback(ModCallbacks.MC_USE_ITEM, EyeOfChimera.UseItem, EyeOfChimera.Item);

function EyeOfChimera:PostUpdate()
    EyeOfChimera.HasEye = nil;
    for p, player in Players.PlayerPairs() do
        if (player:GetCollectibleNum(EyeOfChimera.Item) > 0) then
            EyeOfChimera.HasEye = true;
            break;
        end
    end
end
EyeOfChimera:AddCallback(ModCallbacks.MC_POST_UPDATE, EyeOfChimera.PostUpdate);

function EyeOfChimera:PostGameStarted(isContinued)
    EyeOfChimera.HasEye = nil;
end
EyeOfChimera:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, EyeOfChimera.PostGameStarted);

function EyeOfChimera:PostPlayerEffect(player)
    local nearest = EyeOfChimera:GetNearestCollectible(player);
    
    if (nearest) then
        local data = self:GetTempPlayerData(player, true);
        local displayerExists = EntityExists(data.DisplayerEntity);
        if (not displayerExists) then
            local Displayer = THI.Effects.EyeOfChimeraDisplayer;
            local displayer = Isaac.Spawn(Displayer.Type, Displayer.Variant, nearest.SubType, nearest.Position, Vector.Zero, player);
            displayer.Parent = nearest;
            displayer.SpriteOffset = Vector(0, -32);
            displayer.DepthOffset = 10;
            data.DisplayerEntity = displayer;
        end
        if (not CompareEntity(data.DisplayerEntity.Parent, nearest)) then
            data.DisplayerEntity.Parent = nearest;
            data.DisplayerEntity.SubType = nearest.SubType;
        end
    else
        local data = self:GetTempPlayerData(player, false);
        if (data and EntityExists(data.DisplayerEntity)) then
            data.DisplayerEntity:ToEffect().Timeout = 5;
            data.DisplayerEntity.Parent = nil;
            data.DisplayerEntity = nil;
        end
    end
end
EyeOfChimera:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EyeOfChimera.PostPlayerEffect);

function EyeOfChimera:EvaluateCurse(curses)
    
    local game = THI.Game;
    local hasEye = false;
    local hasBlackCandle = false;
    for p, player in Players.PlayerPairs() do
        if (player:HasCollectible(EyeOfChimera.Item)) then
            hasEye = true;
        end
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then
            hasBlackCandle = true;
            break;
        end
    end

    if (hasEye and not hasBlackCandle) then
        return curses | LevelCurse.CURSE_OF_BLIND;
    end
end
EyeOfChimera:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, EyeOfChimera.EvaluateCurse, 0, 0);

function EyeOfChimera:postChange(player, item, diff)
    THI:EvaluateCurses();
end
EyeOfChimera:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, EyeOfChimera.postChange);



return EyeOfChimera;