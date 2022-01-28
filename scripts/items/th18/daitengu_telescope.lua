local Detection = CuerLib.Detection;
local Telescope = ModItem("Daitengu Telescope", "MegumuTelescope");

function Telescope.GetTelescopeData(init)
    return Telescope:GetGlobalData(init, function() return {
        SkippedTreasureRooms = {},
        Meteor = {
            Triggered = false,
            RoomIndex = -1
        }
    }end)
end

function Telescope.FindNotVisitedTreasureRoomCount()
    local level = THI.Game:GetLevel();
    local rooms = level:GetRooms();
    local count = 0;
    -- Get valid rooms.
    for i = 1, rooms.Size do
        local room = rooms:Get(i);
        if (room and room.GridIndex >= 0) then
            local roomData = room.Data;
            local type = roomData.Type;
            local visitCount = room.VisitedCount;
            if (type == RoomType.ROOM_TREASURE) then
                if (visitCount <= 0) then
                    count = count + 1;
                end
            end
        end
    end

    return count;
end

function Telescope.ClearAllTreasureRooms()
    Telescope.GetTelescopeData(true).SkippedTreasureRooms = {};
end

function Telescope.ClearSkippedTreasureRoom(stage, stageType)
    local data = Telescope.GetTelescopeData(true).SkippedTreasureRooms;
    for i, info in pairs(data) do
        if (info.Stage == stage and info.StageType == stageType) then
            table.remove(data, i);
            return;
        end
    end
end

function Telescope.GetSkippedTreasureRoomCount()
    local data = Telescope.GetTelescopeData(false);
    local treasureCount = 0;
    if (data) then
        local treasureData = data.SkippedTreasureRooms;
        for i, info in pairs(treasureData) do
            treasureCount = treasureCount + info.Count;
        end
    end
    return treasureCount;
end

function Telescope.AddSkippedTreasureRoom(stage, stageType, count)
    if (count == nil) then
        count = 1;
    end

    if (count ~= 0) then
        local data = Telescope.GetTelescopeData(true).SkippedTreasureRooms;
        -- If this room's data exists.
        for i, info in pairs(data) do
            if (info.Stage == stage and info.StageType == stageType) then
                info.Count = info.Count + count;
                return;
            end
        end

        -- If this room's data does not exists.
        table.insert(data, {
            Stage = stage,
            StageType = stageType,
            Count = count
        });
    end
end

function Telescope.RemoveSkippedTreasureRoom(stage, stageType, count)
    if (count == nil) then
        count = 1;
    end
    local data = Telescope.GetTelescopeData(true).SkippedTreasureRooms;
    for i, info in pairs(data) do
        if (info.Stage == stage and info.StageType == stageType) then
            info.Count = info.Count - count;
            if (info.Count <= 0) then
                table.remove(data, i);
            end
            return;
        end
    end
end

function Telescope.GetMeteorRoomIndex(seed)
    local level = THI.Game:GetLevel();
    local rooms = level:GetRooms ( );
    local validRooms = {};
    -- Get valid rooms.
    for i = 1, rooms.Size do
        local room = rooms:Get(i);
        if (room and room.GridIndex >= 0) then
            local roomData = room.Data;
            local shape = roomData.Shape;
            local typeOk = roomData.Type == RoomType.ROOM_DEFAULT or roomData.Type == RoomType.ROOM_BOSS;
            local shapeOk = shape ~= RoomShape.ROOMSHAPE_IH and 
            shape ~= RoomShape.ROOMSHAPE_IV and 
            shape ~= RoomShape.ROOMSHAPE_IIH and 
            shape ~= RoomShape.ROOMSHAPE_IIV
            if (typeOk and shapeOk and room.GridIndex ~= level:GetStartingRoomIndex ( )) then
                table.insert(validRooms, room);
            end
        end
    end

    if (#validRooms <= 0) then
        return -1;
    end
    local tableIndex = seed % #validRooms + 1;
    return validRooms[tableIndex].SafeGridIndex;
end

function Telescope.GetPlayerMeteorChance(player)
    local chance = 0;
    if (player:HasTrinket(TrinketType.TRINKET_TELESCOPE_LENS)) then
        chance = chance + 10 * player:GetTrinketMultiplier(TrinketType.TRINKET_TELESCOPE_LENS);
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_8_BALL)) then
        chance = chance + 20 * player:GetCollectibleNum (CollectibleType.COLLECTIBLE_MAGIC_8_BALL);
    end
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_CRYSTAL_BALL)) then
        chance = chance + 30 * player:GetCollectibleNum (CollectibleType.COLLECTIBLE_CRYSTAL_BALL);;
    end
    return chance;
end

function Telescope.GetMeteorChance()
    local game = THI.Game;
    local chance = 1;
    local treasureCount = Telescope.GetSkippedTreasureRoomCount();
    chance = chance + treasureCount * 20;
    
    for p, player in Detection.PlayerPairs() do
        chance = chance + Telescope.GetPlayerMeteorChance(player);
    end

    return chance;
end

function Telescope.ClearMeteorData()
    local meteorData = Telescope.GetTelescopeData(true).Meteor;
    meteorData.Triggered = false;
    meteorData.RoomIndex = -1;
end

function Telescope.TriggerMeteor()
    local meteorData = Telescope.GetTelescopeData(true).Meteor;
    local seeds = THI.Game:GetSeeds();
    local level = THI.Game:GetLevel();
    local roomIndex = Telescope.GetMeteorRoomIndex(seeds:GetStageSeed (level:GetStage()));

    if (roomIndex >= 0) then
        meteorData.Triggered = true;
        
        Telescope.ClearAllTreasureRooms();

        meteorData.RoomIndex = roomIndex;
        THI.SFXManager:Play(SoundEffect.SOUND_EXPLOSION_STRONG);
        THI.Game:ShakeScreen(60);
    end
end

function Telescope.SpawnMeteorReward(position)
    local game = THI.Game;
    local itemPool = game:GetItemPool();
    local room = game:GetRoom();
    local pos = room:FindFreePickupSpawnPosition(position);
    local id = itemPool:GetCollectible (ItemPoolType.POOL_PLANETARIUM, true, room:GetAwardSeed(), CollectibleType.COLLECTIBLE_TINY_PLANET );
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, pos, Vector.Zero, nil);

    -- Spawn Crater.
    local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, pos, Vector.Zero, nil);
    crater.SpriteScale = Vector(3, 3);

    
    

    -- Destory nearby obstacles.
    local explosionRadius = 120;
    local gridRadius = math.ceil(explosionRadius / 40);
    local centerIndex = room:GetGridIndex(pos);
    local roomWidth = room:GetGridWidth();
    local roomHeight = room:GetGridHeight();
    local centerX = centerIndex % roomWidth;
    local centerY = math.floor(centerIndex / roomWidth);
    for x = -gridRadius, gridRadius do
        for y = -gridRadius, gridRadius do
            if ((x ^ 2 + y ^ 2) ^ 0.5 <= gridRadius) then
                local targetX = centerX + x;
                local targetY = centerY + y;
                if (targetX >= 0 and targetX < roomWidth and targetY >= 0 and targetY < roomHeight) then
                    local index = targetY * roomWidth + targetX;
                    room:DestroyGrid(index, true);
                end
            end
        end
    end
    
    -- Remove nearby enemies
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent.Position:Distance(pos) <= explosionRadius) then
            local npc = ent:ToNPC();
            if (npc) then
                if (npc:IsBoss()) then
                    npc.HitPoints = npc.HitPoints - npc.MaxHitPoints / 2;
                else
                    ent:Remove();
                end
            end
        end
    end

    -- Spawn Rocks and flames.
    local minRadius = 30;
    local decoRng = RNG();
    decoRng:SetSeed(room:GetDecorationSeed(), 0);
    for i = 1, 30 do
        local angle = decoRng:RandomFloat() * 360;
        local distance = decoRng:RandomFloat() * (explosionRadius - minRadius) + minRadius;
        local dir = Vector.FromAngle(angle) * distance;

        local rock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, pos + dir, Vector.Zero, nil):ToEffect();
        rock.m_Height = 0;
        rock.FallingSpeed = 0;
    end

    for i = 1, 60 do
        local angle = decoRng:RandomFloat() * 360;
        local distance = decoRng:RandomFloat() * (explosionRadius - minRadius) + minRadius;
        local scale = decoRng:RandomFloat() * 0.5 + 0.5;
        local dir = Vector.FromAngle(angle) * distance * 2;

        local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, pos + dir, Vector.Zero, nil):ToEffect();
        flame.Scale = scale;
    end

end

function Telescope:PostNewRoom()
    local globalData = Telescope.GetTelescopeData(false);
    if (globalData) then

        local game = THI.Game;
        local level = game:GetLevel();
        local room = game:GetRoom();
        local roomDesc = level:GetCurrentRoomDesc();
        local firstVisit = room:IsFirstVisit();

        if (not room:IsMirrorWorld() and room:GetType() == RoomType.ROOM_TREASURE and firstVisit) then
            Telescope.RemoveSkippedTreasureRoom(level:GetStage(), level:GetStageType(), 1);
        end

        local meteorData = globalData.Meteor;
        if (meteorData.Triggered) then
            if (roomDesc.SafeGridIndex == meteorData.RoomIndex and firstVisit) then
                local position = room:GetRandomPosition(80);
                Telescope.SpawnMeteorReward(position);
            end
        end
    end
end
Telescope:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Telescope.PostNewRoom)

function Telescope:PostNewStage()
    local game = THI.Game;
    if (game:GetFrameCount() <= 1) then
        return;
    end

    local level = THI.Game:GetLevel();
    local stage = level:GetStage();
    local stageType = level:GetStageType();
    local hasTelescope = false;
    for p, player in Detection.PlayerPairs() do
        if (player:HasCollectible(Telescope.Item)) then
            hasTelescope = true;
            break;
        end
    end

    Telescope.ClearMeteorData();

    -- Check the meteor.
    if (hasTelescope) then
        local chance = Telescope.GetMeteorChance();
        local seeds = THI.Game:GetSeeds();
        local seed = seeds:GetStageSeed (level:GetStage());
        local value = seed % 100;
        --print ("Chance: "..chance..", Value: ".. value);
        --print ("Skipped Treasure Rooms: "..Telescope.GetSkippedTreasureRoomCount());
        if (value < chance) then
            Telescope.TriggerMeteor();
        end
    end

    
    -- Find all treasure rooms.
    local treasureRoomCount = Telescope.FindNotVisitedTreasureRoomCount();
    -- Clear current floor's treasure rooms, for Forget Me Now and Ascent.
    Telescope.ClearSkippedTreasureRoom(stage, stageType);
    --print(treasureRoomCount.." treasure rooms found.");
    Telescope.AddSkippedTreasureRoom(stage, stageType, treasureRoomCount);
    --print ("Skipped Treasure Rooms Now: "..Telescope.GetSkippedTreasureRoomCount());
end
Telescope:AddCustomCallback(CLCallbacks.CLC_NEW_STAGE, Telescope.PostNewStage)

-- function Telescope:PostRender()
--     Isaac.RenderText(Telescope.GetMeteorChance(), 160, 80, 1,1,1,1);
-- end
-- Telescope:AddCallback(ModCallbacks.MC_POST_RENDER, Telescope.PostRender)

return Telescope;