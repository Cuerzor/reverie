local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;
local Actives = CuerLib.Actives;
local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local LastWills = ModItem("Isaac's Last Wills", "IsaacsLastWills");

local function GetGlobalData(create)
    return LastWills:GetGlobalData(create, function () return {
        GreedLegacy = false,
        DamageUp = false
    }end)
end

function LastWills:HasLegacies()
    local persistentData = SaveAndLoad.ReadPersistentData();
    local willsData = persistentData.LastWills;
    if (willsData) then
        return true;
    end
    return false;
end


local function SpawnLegacies(wills)
    local game = THI.Game;
    local room = THI.Game:GetRoom();
    local index = room:GetGridSize() - room:GetGridWidth() * 2 + 1;
    local leftBottomCorner = room:GetGridPosition(index);
    for i, colInfo in pairs(wills.Pickups) do
        local pos = room:FindFreePickupSpawnPosition(leftBottomCorner, 0, true);
        Isaac.Spawn(colInfo.Type, colInfo.Variant, colInfo.SubType, pos, Vector.Zero, nil);
    end
end

function LastWills:CanSend(pickup)
    local EntityTags = THI.Shared.EntityTags;
    return not EntityTags:EntityFits(pickup, "LastWillsBlacklist");
end

function LastWills:UseLastWills(item, rng, player, flags, slow, varData)

    local game = THI.Game;
    local seeds = THI.Game:GetSeeds();
    if (not seeds:IsCustomRun()) then
        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP);
        local validCount = 0;

        for _, pickup in pairs(pickups) do
            if (LastWills:CanSend(pickup)) then
                validCount = validCount + 1;
            end
        end


        local canLegacy = validCount > 0;
        local canWisps = Actives:CanSpawnWisp(player, flags)
        if (canLegacy or canWisps) then
            local persistentData = SaveAndLoad.ReadPersistentData();
            -- Init Data.
            if (not persistentData.LastWills) then
                persistentData.LastWills = {
                    Pickups = {},
                    Wisps = false,
                    DamageUp = false
                };
            end

            -- Write Data.
            local willsData = persistentData.LastWills;
            if (canLegacy) then
                for i, ent in pairs(pickups) do
                    local pickup = ent:ToPickup();
                    if (not pickup:IsShopItem() and LastWills:CanSend(pickup)) then
                        local info = {
                            Type = pickup.Type,
                            Variant = pickup.Variant,
                            SubType = pickup.SubType
                        }
                        table.insert(willsData.Pickups, info);
                        pickup:Remove();
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                    end
                end
            end

            if (canWisps) then
                willsData.Wisps = true;
            end
            
            if (Players.HasJudasBook(player)) then
                willsData.DamageUp = true;
            end

            SaveAndLoad.WritePersistentData(persistentData);
        end
    end

    return {ShowAnim = true, Remove = true}
end
LastWills:AddCallback(ModCallbacks.MC_USE_ITEM, LastWills.UseLastWills, LastWills.Item)


function LastWills:PostGameStarted(isContinued)
    local game = THI.Game;
    local seeds = THI.Game:GetSeeds();
    if (not seeds:IsCustomRun()) then
        if (not isContinued) then
            if (LastWills:HasLegacies()) then
                local persistentData = SaveAndLoad.ReadPersistentData();
                if (not game:IsGreedMode() ) then
                    SpawnLegacies(SaveAndLoad.ReadPersistentData().LastWills)
                else
                    -- Greed Mode
                    local globalData = GetGlobalData(true);
                    globalData.GreedLegacy = persistentData.LastWills;
                end
                
                if (persistentData.LastWills.Wisps) then
                    local player = game:GetPlayer(0);
                    for i= 1, 10 do
                        player:AddWisp (LastWills.Item, player.Position);
                    end
                end
                if (persistentData.LastWills.DamageUp) then
                    local data = GetGlobalData(true);
                    data.DamageUp = true;
                    for p, player in Players.PlayerPairs() do
                        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                        player:EvaluateItems();
                    end
                end
                -- Remove Legacies.
                persistentData.LastWills = nil;
                SaveAndLoad.WritePersistentData(persistentData);
            end
        end
    end
end

LastWills:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LastWills.PostGameStarted)


function LastWills:EvaluateCache(player, flag)
    local globalData = GetGlobalData(false)
    if (globalData and globalData.DamageUp) then
        if (flag == CacheFlag.CACHE_DAMAGE) then
            Stats:AddDamageUp(player, 1);
        end
    end
end
LastWills:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LastWills.EvaluateCache)

function LastWills:PostNewRoom()
    local game = THI.Game;
    if (game:IsGreedMode()) then
        local globalData = GetGlobalData(false)
        if (globalData and globalData.GreedLegacy) then
            local level = THI.Game:GetLevel();
            local roomDesc = level:GetCurrentRoomDesc();
            local isStartRoom = roomDesc.SafeGridIndex == 98;
            
            if (isStartRoom) then
                SpawnLegacies(globalData.GreedLegacy);
                globalData.GreedLegacy = nil;
            end
        end
    end
end
LastWills:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LastWills.PostNewRoom)

return LastWills;