local SaveAndLoad = CuerLib.SaveAndLoad;
local Actives = CuerLib.Actives;
local LastWills = ModItem("Isaac's Last Wills", "IsaacsLastWills");

function LastWills.HasLegacies()
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
    for i, colInfo in pairs(wills.Collectibles) do
        local pos = room:FindFreePickupSpawnPosition(leftBottomCorner, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, colInfo.Id, pos, Vector.Zero, nil);
    end

    
    for i, trinkInfo in pairs(wills.Trinkets) do
        local pos = room:FindFreePickupSpawnPosition(leftBottomCorner, 0, true);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinkInfo.Id, pos, Vector.Zero, nil);
    end
end
function LastWills:UseLastWills(item, rng, player, flags, slow, varData)

    local game = THI.Game;
    local seeds = THI.Game:GetSeeds();
    if (not seeds:IsCustomRun()) then
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE);
        local trinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET);
        local collectibleCount = 0;

        for _, col in pairs(collectibles) do
            if (col.SubType > 0) then
                collectibleCount = collectibleCount + 1;
            end
        end


        local canLegacy = collectibleCount + #trinkets > 0;
        local canWisps = Actives.CanSpawnWisp(player, flags)
        if (canLegacy or canWisps) then
            local persistentData = SaveAndLoad.ReadPersistentData();
            if (not persistentData.LastWills) then
                persistentData.LastWills = {
                    Collectibles = {},
                    Trinkets = {},
                    Wisps = false
                };
            end

            local willsData = persistentData.LastWills;
            if (canLegacy) then
                for i, ent in pairs(collectibles) do
                    local col = ent:ToPickup();
                    if (not col:IsShopItem()) then
                        local info = {
                            Id = col.SubType
                        }
                        table.insert(willsData.Collectibles, info);
                        col:Remove();
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, col.Position, Vector.Zero, nil);
                    end
                end

                for i, ent in pairs(trinkets) do
                    local col = ent:ToPickup();
                    if (not col:IsShopItem()) then
                        local info = {
                            Id = col.SubType
                        }
                        table.insert(willsData.Trinkets, info);
                        col:Remove();
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, col.Position, Vector.Zero, nil);
                    end
                end
            end

            if (canWisps) then
                willsData.Wisps = true;
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
            if (LastWills.HasLegacies()) then
                local persistentData = SaveAndLoad.ReadPersistentData();
                if (game.Difficulty ~= Difficulty.DIFFICULTY_GREED and game.Difficulty ~= Difficulty.DIFFICULTY_GREEDIER) then
                    SpawnLegacies(SaveAndLoad.ReadPersistentData().LastWills)
                else
                    -- Greed Mode
                    local globalData = LastWills:GetGlobalData(true, function () return {
                        GreedLegacy = false;
                    }end)
                    globalData.GreedLegacy = persistentData.LastWills;
                end
                
                if (persistentData.LastWills.Wisps) then
                    local player = game:GetPlayer(0);
                    for i= 1, 10 do
                        player:AddWisp (LastWills.Item, player.Position);
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

function LastWills:PostNewRoom()
    local game = THI.Game;
    if (game.Difficulty == Difficulty.DIFFICULTY_GREED or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER) then
        local globalData = LastWills:GetGlobalData(false)
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