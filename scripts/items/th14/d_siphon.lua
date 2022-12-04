local Collectibles = CuerLib.Collectibles;
local CompareEntity = CuerLib.Detection.CompareEntity;
local Actives = CuerLib.Actives;
local ItemPools = CuerLib.ItemPools;
local DSiphon = ModItem("D Siphon", "D_SIPHON");
DSiphon.GettingCollectible = false;
DSiphon.ReleaseThresold = 4;
DSiphon.FullColor = Color(1,0,0,1,0,0,0);
DSiphon.PoolCondition = nil;

local function GetPlayerData(player, init)
    return DSiphon:GetData(player, init, function()
        return {
            SiphonPoints = 0,
        }
    end);
end
local function GetPlayerTempData(player, init)
    local data = DSiphon:GetTempData(player, init, function()
        return {
            DrainTrails = {};
        }
    end);
    return data;
end


function DSiphon:WillRelease(player)
    local SeijaB = THI.Players.SeijaB;
    if (player:GetPlayerType() == SeijaB.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex);
    end

    local playerData = GetPlayerData(player, false);
    local points = (playerData and playerData.SiphonPoints) or 0;
    return points >= self.ReleaseThresold;

end

local function UseSiphon(mod, item, rng, player, flags, slot, vardata)
    local itemConfig = Isaac.GetItemConfig();
    local playerData = GetPlayerData(player, true);
    local willRelease = DSiphon:WillRelease(player);
    local reduced = false;
    local tempData = GetPlayerTempData(player, true)
    local itemPool = Game():GetItemPool();
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local type = ent.Type;
        local variant = ent.Variant;
        local subType = ent.SubType;
        local pickup = ent:ToPickup();
        if (pickup.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);

            local config = itemConfig:GetCollectible(pickup.SubType);
            local quality = (config and config.Quality) or 0;

            local item = -1;
            local targetQuality = quality;
            local default = CollectibleType.COLLECTIBLE_BREAKFAST
            if (not willRelease) then
                targetQuality = quality - 1;
                playerData.SiphonPoints = playerData.SiphonPoints + 1;
            else
                targetQuality = quality + 1;
                playerData.SiphonPoints = playerData.SiphonPoints - 1;
            end

            if (targetQuality >= 0 and targetQuality <= 4) then
                if (targetQuality == 0) then
                    default = CollectibleType.COLLECTIBLE_BOOM;
                elseif (targetQuality == 2) then
                    default = CollectibleType.COLLECTIBLE_HALO_OF_FLIES;
                elseif (targetQuality == 3) then
                    default = CollectibleType.COLLECTIBLE_SAD_ONION;
                elseif (targetQuality == 4) then
                    default = CollectibleType.COLLECTIBLE_BRIMSTONE;
                end
                local function condition(id, conf)
                    return conf.Quality == targetQuality
                end

                local poolType = ItemPools:GetRoomPool(rng:Next())
                DSiphon.GettingCollectible = true;
                DSiphon.PoolCondition = condition;
                ItemPools:EvaluateRoomBlacklist();
                item = itemPool:GetCollectible(poolType, true, rng:Next());
                if (item == CollectibleType.COLLECTIBLE_BREAKFAST) then
                    item = default;
                end
                DSiphon.GettingCollectible = false;
            end

            if (item <= 0) then
                pickup:Remove();
            else
                pickup:Morph(type, variant, item, true, false, false);
                pickup.Touched = false;
            end
            
            -- Trails.
            local parent = pickup;
            local target = player;
            local color;
            if (not willRelease) then
                color = Color(0, 0, 0, 1, 0.5,0,0);
                SFXManager():Play(SoundEffect.SOUND_MIRROR_ENTER);
            else
                color = Color(0, 0, 0, 1, 0,0.5,0.5);
                parent = player;
                target = pickup;
                SFXManager():Play(SoundEffect.SOUND_MIRROR_EXIT);
            end
            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SPRITE_TRAIL, 0, parent.Position, Vector.Zero, pickup):ToEffect()
            trail.MinRadius = 0.1;
            trail.MaxRadius = 0.15;
            trail.SpriteScale = Vector(3,3);
            trail.Parent = player;
            trail.LifeSpan = 60;
            trail.Timeout = 60;
            trail:SetColor(color, -1, 0);
            table.insert(tempData.DrainTrails, {Entity = trail, From = parent.Position, To = target, ToPosition = target.Position});
            pickup:SetColor(color, 30, 0, true);

            -- Wisp.
            if (Actives.CanSpawnWisp(player, flags)) then
                player:AddWisp(DSiphon.Item, pickup.Position);
            end
            if (not reduced) then
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, DSiphon.Item))  do
                    ent.HitPoints = ent.HitPoints - 8;
                    if (ent.HitPoints <= 0) then
                        ent:Kill();
                    end
                end


                reduced = true;
            end
        end
    end
    if (reduced) then
        DSiphon.PoolCondition = nil;
        ItemPools:EvaluateRoomBlacklist();
    end

    return {ShowAnim = true, Discharge = true}
end
DSiphon:AddCallback(ModCallbacks.MC_USE_ITEM, UseSiphon, DSiphon.Item);

local function EvaluateBlacklist(mod, id, config)
    if (DSiphon.PoolCondition) then
        return not DSiphon.PoolCondition(id, config);
    end
end
DSiphon:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateBlacklist);

local function PostPlayerUpdate(mod, player)
    local tempData = GetPlayerTempData(player, true)
    if (tempData and tempData.DrainTrails) then
        for i, info in ipairs(tempData.DrainTrails) do
            local effect = info.Entity;
            if (effect and effect:Exists()) then
                local fromPos = info.From;
                local to = info.To;
                local toPos = (to and to:Exists() and to.Position) or info.ToPosition;
                effect.Timeout = effect.Timeout - 1;
                local distance = toPos - fromPos;
                local lerp = math.max(0, math.min(1, (effect.LifeSpan - effect.Timeout) / (effect.LifeSpan - 30)));
                lerp = -(lerp - 1) ^ 2 + 1;
                local target = fromPos + distance * lerp;
                effect.Position = target;
                if (effect.Timeout < 0) then
                    effect:Remove();
                end
            else
                table.remove(tempData.DrainTrails, i);
            end
        end
    end
end
DSiphon:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

local function GetShaderParams(mod, name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        
        Actives.RenderActivesCount(DSiphon.Item, function(player) 
            local data = GetPlayerData(player, false);
            local color = Color.Default;
            if (DSiphon:WillRelease(player)) then
                color = DSiphon.FullColor;
            end
            return (data and data.SiphonPoints) or 0, color;
        end);
    end
end
DSiphon:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);

return DSiphon;