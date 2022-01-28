local Detection = CuerLib.Detection;
local SaveAndLoad = CuerLib.SaveAndLoad
local Collectibles = CuerLib.Collectibles
local Stages = CuerLib.Stages;
local Callbacks = CuerLib.Callbacks;

local MaidSuit = ModItem("Maid Suit", "MaidSuit");
MaidSuit.MaidKnife = Isaac.GetEntityTypeByName("Maid Knife");
MaidSuit.MaidKnifeVariant = Isaac.GetEntityVariantByName("Maid Knife");
MaidSuit.KnifeSpawner = Isaac.GetEntityTypeByName("Knife Spawner");
MaidSuit.KnifeSpawnerVariant = Isaac.GetEntityVariantByName("Knife Spawner");
MaidSuit.Config = {
    ChanceIncreament = 20,
    KnifeSpawnerTime = 25
};
MaidSuit.rng = RNG();

local function GetDefaultTempData()
    return {
        Stopping = false,
        Time = 0,
        Countdown = 0
    };
end
MaidSuit.TimeStop = GetDefaultTempData();


local function GetGlobalData()
    return MaidSuit:GetGlobalData(true, function() return {
        Chance = 20,
        Has = Collectibles.IsAnyHasCollectible(MaidSuit.Item),
        WorldSpawned = false
    }end);
end

function MaidSuit.GetFreezeTime()
    if (THI.IsLunatic()) then
        return 60;
    else
        return 90;
    end
end

function MaidSuit:GetKnifeSpawnerData(effect)
    return MaidSuit:GetData(effect, true, function() return {
        Index = 0,
        Time = 0,
        Player = nil
    } end);
end

function MaidSuit:GetKnifeData(knife)
    return MaidSuit:GetData(knife, true, function() return {
        Direction = Vector(0, 0),
        StartSpeed = 0,
        Fired = false
    } end);
end

function MaidSuit:GetNPCData(npc)
    return MaidSuit:GetData(npc, true, function() return {
        Stopped = false
    } end);
end

function MaidSuit:postPickCollectible(player, item, count, touched)
    if (not touched) then
        local room = THI.Game:GetRoom();
        if (count > 0) then
            for i = 1, count do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_WORLD, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0,0), player);
            end
        end
    end
end
MaidSuit:AddCustomCallback(CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, MaidSuit.postPickCollectible, MaidSuit.Item);

-- function MaidSuit:postChangeCollectibles(player, item, diff)
--     GetGlobalData().Has = Collectibles.IsAnyHasCollectible(MaidSuit.Item);
-- end
-- MaidSuit:AddCustomCallback(CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, MaidSuit.postChangeCollectibles, MaidSuit.Item);

function MaidSuit:onUpdate()

    GetGlobalData().Has = Collectibles.IsAnyHasCollectible(MaidSuit.Item);
    local timeStopData = MaidSuit.TimeStop;
    if (timeStopData.Countdown > 0) then
        timeStopData.Countdown = timeStopData.Countdown - 1;
        if (timeStopData.Countdown <= 0) then
            MaidSuit:StartTimeStop();
        end
    end
    -- Time stop timeout.
    if (timeStopData.Stopping) then
        timeStopData.Time = timeStopData.Time + 1;
        -- Play Hand Sound.
        if (timeStopData.Time % 30 == 1) then
            THI.SFXManager:Play(SoundEffect.SOUND_COIN_INSERT, 1, 0, false, 5);
        end
        if (timeStopData.Time > MaidSuit.GetFreezeTime()) then
            MaidSuit:UnfreezeObjects();
            MaidSuit:EndTimeStop();
        else
            MaidSuit:FreezeObjects();
        end
    end
end

function MaidSuit:StartTimeStop()
    MaidSuit.TimeStop.Stopping = true;
    MaidSuit.TimeStop.Time = 0;
end

function MaidSuit:EndTimeStop()
    MaidSuit.TimeStop.Stopping = false;
    MaidSuit.TimeStop.Time = 0;
end

function MaidSuit:CanUnfreeze(e) 
    return e.Type ~= EntityType.ENTITY_PLAYER and 
    e.Type ~= EntityType.ENTITY_TEAR and 
    e.Type ~= EntityType.ENTITY_FAMILIAR and 
    e.Type ~= EntityType.ENTITY_BOMBDROP and 
    e.Type ~= EntityType.ENTITY_PICKUP and 
    e.Type ~= EntityType.ENTITY_SLOT and 
    e.Type ~= EntityType.ENTITY_PROJECTILE and 
    e.Type ~= EntityType.ENTITY_EFFECT and 
    e.Type ~= EntityType.ENTITY_TEXT and 
    e.Type ~= EntityType.ENTITY_KNIFE and 
    e.Type ~= EntityType.ENTITY_FIREPLACE and 
    e.Type ~= EntityType.ENTITY_MINECART and 
    e.Type ~= EntityType.ENTITY_LASER;
end
function MaidSuit:CanFreeze(e) 
    return not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and 
    e.Type ~= EntityType.ENTITY_PLAYER and 
    e.Type ~= EntityType.ENTITY_TEAR and 
    e.Type ~= EntityType.ENTITY_FAMILIAR and 
    e.Type ~= EntityType.ENTITY_BOMBDROP and 
    e.Type ~= EntityType.ENTITY_PICKUP and 
    e.Type ~= EntityType.ENTITY_SLOT and 
    e.Type ~= EntityType.ENTITY_PROJECTILE and 
    e.Type ~= EntityType.ENTITY_EFFECT and 
    e.Type ~= EntityType.ENTITY_TEXT and 
    e.Type ~= EntityType.ENTITY_KNIFE and 
    e.Type ~= EntityType.ENTITY_FIREPLACE and 
    e.Type ~= EntityType.ENTITY_MINECART and 
    e.Type ~= EntityType.ENTITY_LASER;
end

function MaidSuit:FreezeObjects()
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (MaidSuit:CanFreeze(ent) and not ent:IsDead()) then
            local data = MaidSuit:GetNPCData(ent);
            if (not ent:HasEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)) then
                ent:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)
            end
            if (not ent:HasEntityFlags(EntityFlag.FLAG_FREEZE)) then
                ent:AddEntityFlags(EntityFlag.FLAG_FREEZE)
            end
            data.Stopped = true;
        end
    end
end

function MaidSuit:UnfreezeNPC(npc)
    local data = MaidSuit:GetNPCData(npc);
    if (npc:HasEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE)) then
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE);
    end
    if (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE)) then
        npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE);
    end
    data.Stopped = false
end

function MaidSuit:UnfreezeObjects()
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (MaidSuit:CanUnfreeze(ent)) then
            local data = MaidSuit:GetNPCData(ent);
            if (data.Stopped) then
                MaidSuit:UnfreezeNPC(ent);
            end
        end
    end
end

function MaidSuit:SpawnKnife(position, i, player)
    local rad = i * 40 / 180 * math.pi;
    local dir = Vector(math.sin(rad), -math.cos(rad));
    local pos = position + dir * 120;
    local knife = Isaac.Spawn(MaidSuit.MaidKnife, MaidSuit.MaidKnifeVariant, 0, pos, Vector(0, 0), player):ToTear();
    local freezeTime = MaidSuit.GetFreezeTime();
    knife.WaitFrames = freezeTime;
    knife.TearFlags = knife.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING;
    local data = MaidSuit:GetKnifeData(knife);
    data.Direction = -dir;
    data.FreezeTime = freezeTime;
    data.StartSpeed = 20;
    return knife;
end

function MaidSuit:SpawnKnifes(player)
    local time = 0;
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (Detection.IsValidEnemy(ent)) then
            local spawner = Isaac.Spawn(MaidSuit.KnifeSpawner, MaidSuit.KnifeSpawnerVariant, 0, ent.Position, Vector(0, 0), player):ToEffect();
            local spawnerData = MaidSuit:GetKnifeSpawnerData(spawner);
            spawnerData.Player = player;
            
            time = time + 1;
            if (time >= 8) then
                return;
            end
        end
    end
end

function MaidSuit:onNewRoom()
    MaidSuit:EndTimeStop();
    if (GetGlobalData().Has and (Isaac.CountEnemies() > 0 or Isaac.CountBosses() > 0)) then
        -- Set Timestop Countdown.
        MaidSuit.TimeStop.Countdown = 15;
    end
end

function MaidSuit:onNewLevel()
    if (SaveAndLoad.GameStarted) then
        local data = GetGlobalData();
        if (data.Has) then
            data.Chance = MaidSuit.Config.ChanceIncreament;
            data.Stage = stage;
            data.WorldSpawned = false;
        end
    end
end

function MaidSuit:onUseTheWorld(card, player, flags)
    if (player:HasCollectible(MaidSuit.Item)) then
        MaidSuit:StartTimeStop();
        MaidSuit:SpawnKnifes(player);
    end
end

function MaidSuit:onKnifeUpdate(knife)
    
    
    local data = MaidSuit:GetKnifeData(knife);
    
    local spr = knife:GetSprite()
    spr.Rotation = data.Direction:GetAngleDegrees() - 90;
    
    if (knife.WaitFrames <= 0 and not data.Fired) then
        knife:AddVelocity(data.Direction * data.StartSpeed);
        knife.CollisionDamage = 20;
        data.Fired = true;
    end
end

function MaidSuit:onKnifeSpawnerUpdate(effect)
    local data = MaidSuit:GetKnifeSpawnerData(effect);
    
    if (data.Time % 3 == 0) then
        local knife = MaidSuit:SpawnKnife(effect.Position, data.Index, data.Player);
        local knifeData = MaidSuit:GetKnifeData(knife);
        knife.WaitFrames = MaidSuit.GetFreezeTime() - data.Time;
        data.Index = data.Index + 1;
    end
    
    if (data.Time > MaidSuit.Config.KnifeSpawnerTime) then
        effect:Remove();
    end
    data.Time = data.Time + 1;
    
end

function MaidSuit:preSpawnCleanAward(rng, Position)
    local data = GetGlobalData();
    if (data.Has and not data.WorldSpawned) then
        if (not THI.IsLunatic()) then
            local value = MaidSuit.rng:RandomInt(99);
            if (value < data.Chance) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_WORLD, THI.Game:GetRoom():FindFreePickupSpawnPosition(Position, 0, false), Vector(0,0), nil);
                data.WorldSpawned = true;
                data.Chance = 0;
            else
                data.Chance = data.Chance + MaidSuit.Config.ChanceIncreament;
            end
        else
            if (THI.Game:GetRoom():GetType() == RoomType.ROOM_BOSS) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_WORLD, THI.Game:GetRoom():FindFreePickupSpawnPosition(Position, 0, false), Vector(0,0), nil);
                data.WorldSpawned = true;
            end
        end
    end
end

function MaidSuit:onNPCUpdate(npc)
    if (npc:IsDead()) then
        local data = MaidSuit:GetNPCData(npc);
        if (data.Stopped) then
            MaidSuit:UnfreezeNPC(npc);
        end
    end
end

function MaidSuit:postExit()
    MaidSuit.TimeStop = GetDefaultTempData();
end
SaveAndLoad:AddCallback(MaidSuit:GetMod(), SLCallbacks.SLC_POST_EXIT, MaidSuit.postExit);

MaidSuit:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MaidSuit.onNewLevel);
MaidSuit:AddCallback(ModCallbacks.MC_POST_UPDATE, MaidSuit.onUpdate);
MaidSuit:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MaidSuit.onKnifeSpawnerUpdate, MaidSuit.KnifeSpawnerVariant);
MaidSuit:AddCallback(ModCallbacks.MC_USE_CARD, MaidSuit.onUseTheWorld, Card.CARD_WORLD);
MaidSuit:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, MaidSuit.onKnifeUpdate, MaidSuit.MaidKnifeVariant);
MaidSuit:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MaidSuit.onNewRoom);
MaidSuit:AddCallback(ModCallbacks.MC_NPC_UPDATE, MaidSuit.onNPCUpdate)
MaidSuit:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, MaidSuit.preSpawnCleanAward)

return MaidSuit;