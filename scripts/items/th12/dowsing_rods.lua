local Collectbiles = CuerLib.Collectibles;
local ItemPools = CuerLib.ItemPools;
local Instruments = THI.Instruments;
local Rods = ModItem("Dowsing Rods", "DOWSING_RODS");

function Rods.GetRodsData(init)
    return Rods:GetGlobalData(init, function() return {
        Rooms = {}
    }end)
end
function Rods.GetPlayerData(player, init)
    return Rods:GetData(player, init, function() return {
        RadarTimer = 0
    } end)
end
function Rods.GetRoomKey(roomDesc)
    return roomDesc.ListIndex;
end

local HasRods = false;
function Rods:PostUpdate()
    HasRods = Collectbiles.IsAnyHasCollectible(Rods.Item);
    local globalData = Rods.GetRodsData(false);
    if (globalData) then
        
        local game = Game();
        local room = game:GetRoom();
        local level = game:GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        local key = Rods.GetRoomKey(roomDesc);
        local index = globalData.Rooms[key];
        if (index) then
            local gridEntity = room:GetGridEntity(index);
            if (gridEntity) then
                if (gridEntity.State ~= 1 or gridEntity:GetType() ~= GridEntityType.GRID_ROCK) then
                    -- Spawn Award.
                    if (HasRods) then
                        local gridDesc = gridEntity.Desc;
                        local seed = gridDesc.SpawnSeed;
                        local value = seed % 100;
                        local pos =  gridEntity.Position;
                        local award = nil;
                        if (value < 10) then
                            award = Isaac.Spawn(EntityType.ENTITY_HARDY, 0, 0, pos, Vector.Zero, nil);
                            award:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
                        elseif (value < 25) then
                            award = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, pos, RandomVector(), nil);
                        elseif (value < 26) then
                            for i=1, 64 do
                                award = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, pos, Vector.Zero, nil);
                            end
                        elseif (value < 65) then
                            award = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, pos, RandomVector(), nil);
                        elseif (value < 85) then
                            award = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, pos, RandomVector(), nil);
                        elseif (value < 95) then
                            for i=1, 2 do
                                local spider = Isaac.Spawn(EntityType.ENTITY_ROCK_SPIDER, 1, 0, pos, RandomVector(), nil);
                                spider:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
                            end
                        elseif (value < 100) then
                            
                            local pool = game:GetItemPool();
                            local roomType = room:GetType();
                            local poolType = ItemPools:GetPoolForRoom(roomType, seed);
                            local id = pool:GetCollectible(poolType, true, seed);
                            award = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, nil);
                        end
                    end
                    globalData.Rooms[key] = nil;
                end
            else
                globalData.Rooms[key] = nil;
            end
        end
    end
end
Rods:AddCallback(ModCallbacks.MC_POST_UPDATE, Rods.PostUpdate)

function Rods:PostPlayerEffect(player)
    if (player:HasCollectible(Rods.Item)) then
        local globalData = Rods.GetRodsData(false);
        if (globalData) then
            
            local room = THI.Game:GetRoom();
            local level = THI.Game:GetLevel();
            local roomDesc = level:GetCurrentRoomDesc();
            local key = Rods.GetRoomKey(roomDesc);
            local index = globalData.Rooms[key];
            if (index) then
                local playerData = Rods.GetPlayerData(player, true);
                local frameCount = room:GetFrameCount();
                local hiddenPos = room:GetGridPosition(index);
                local distance = player.Position:Distance(hiddenPos);
                local interval = math.min(90, math.max(5, math.ceil(5 + (distance - 40) / 200 * 85)))
                playerData.RadarTimer = (playerData.RadarTimer or 0) + 1;
                if (frameCount == 1 or playerData.RadarTimer >= interval) then
                    local wave = Isaac.Spawn(Instruments.MusicWave.Type, Instruments.MusicWave.Variant, 0, player.Position, Vector(0, 0), player):ToEffect();
                    wave.SpriteScale = Vector(0.5, 0.5);
                    wave:SetColor (Color(0,1,0,1,0,0,0), 0, 0, false, false);
                    THI.SFXManager:Play(THI.Sounds.SOUND_RADAR, 0.3);
                    playerData.RadarTimer = 0;
                end
            end
        end
    end
end
Rods:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Rods.PostPlayerEffect)

function Rods:PostNewRoom()
    local room = THI.Game:GetRoom();
    if (room:IsFirstVisit()) then
        local level = THI.Game:GetLevel();
        local roomDesc = level:GetCurrentRoomDesc();
        local key = Rods.GetRoomKey(roomDesc);
        local globalData = Rods.GetRodsData(true);
        globalData.Rooms[key] = nil;
        local seed = roomDesc.SpawnSeed;
        if (seed % 100 < 75) then

            local size = room:GetGridSize();
            local rocks = {};
            for i = 0, size do
                local gridEntity = room:GetGridEntity(i);
                if (gridEntity) then
                    if (gridEntity:GetType() == GridEntityType.GRID_ROCK) then
                        if (gridEntity.State == 1) then
                            table.insert(rocks, i);
                        end
                    end
                end
            end

            if (#rocks > 0) then
                local index = seed % #rocks + 1;
                globalData.Rooms[key] = rocks[index];
            end
        end
    end
end
Rods:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Rods.PostNewRoom)


function Rods:PostNewLevel()
    local globalData = Rods.GetRodsData(true);
    globalData.Rooms = {};
end
Rods:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Rods.PostNewLevel)

return Rods;