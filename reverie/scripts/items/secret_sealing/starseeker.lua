local Collectibles = CuerLib.Collectibles
local Stages = CuerLib.Stages;
local ItemPools = CuerLib.ItemPools;

local Starseeker = ModItem("Starseeker", "Starseeker");
Starseeker.Ball = {
    Id = Isaac.GetEntityTypeByName("Starseeker Ball"),
    Variant = Isaac.GetEntityVariantByName("Starseeker Ball")
};
Starseeker.BallSpawnCooldown = 0

local itemConfig = Isaac.GetItemConfig();
local itemPool = THI.Game:GetItemPool ( );
-- To avoid trigger preGetCollectible Event while getting items in crystal balls.
local isGetingBallItem = false;
local rng = RNG();
---------------------------------
-- Local Functions
---------------------------------


local function GetGlobalData(create)
    return Starseeker:GetGlobalData(create, function() return {
        Triggered = false,
        Seed = Game():GetSeeds():GetStartSeed(),
        Futures = {},
        RoomItemCount = {}
    }end )
end

local function GetBallData(ball, init)
    local function getter()
        return {
            Inited = false
        }
    end
    return Starseeker:GetData(ball, init, getter);
end

local function GetSeekerNextSeed()
    local data = GetGlobalData(true);
    rng:SetSeed(data.Seed, 0);
    local value = rng:Next();
    data.Seed = rng:GetSeed();
    return value;
end

local function PickupBall(ball)
    Starseeker.RemoveBall(ball);
    
    Starseeker.EnqueueFuture(Game():GetRoom():GetType(), ball.SubType);

    if (ball.OptionsPickupIndex ~= 0) then
        
        -- Remove all balls with same OptionsPickupIndex
        for _, ent in pairs(Isaac.FindByType(Starseeker.Ball.Id, Starseeker.Ball.Variant)) do
            local pickup = ent:ToPickup();
            if (pickup.OptionsPickupIndex == ball.OptionsPickupIndex) then
                Starseeker.RemoveBall(pickup);
            end
        end
    end
end
---------------------------------
-- Public Functions
---------------------------------
function Starseeker.InitBallItem(ball)
    local room = THI.Game:GetRoom();
    local roomType = room:GetType();
    local itemId = ball.SubType;
    local config = itemConfig:GetCollectible(itemId);

    if (config == nil) then
        local seed = GetSeekerNextSeed();
        local tries = 0;
        while (config == nil and tries < 4) do
            isGetingBallItem = true;
            itemId = room:GetSeededCollectible(seed)
            isGetingBallItem = false;
            config = itemConfig:GetCollectible(itemId);

            tries = tries + 1;
        end
        if (tries >= 4) then
            print("Tries Out!");
        end
        
        ball.SubType = itemId;
        
    end

    local gfxName = config.GfxFileName;
    local ballSprite = ball:GetSprite();
    ballSprite:ReplaceSpritesheet(1, gfxName);
    ballSprite:LoadGraphics();
    
    ball.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
    ball.TargetPosition = ball.Position;
    ball.Wait = 60;

    local data = GetBallData(ball, true);
    data.Inited = true;
    
end

function Starseeker.SpawnBall(pos)
    
    local room = THI.Game:GetRoom();
    local roomType = room:GetType();
    local ball = Isaac.Spawn(Starseeker.Ball.Id, Starseeker.Ball.Variant, 0, pos, Vector(0, 0), nil) : ToPickup();
    Starseeker.InitBallItem(ball);
    local itemId = ball.SubType;
    
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ball.Position, Vector.Zero, ball);
    return ball;
end

function Starseeker.RemoveBall(ball)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ball.Position, Vector.Zero, ball);
    ball:Remove();
end

function Starseeker.EnqueueFuture(roomType, item)
    local data = GetGlobalData(true);
    table.insert(data.Futures, {RoomType = roomType, Item = item});
end

function Starseeker.HasFuture(roomType)
    local data = GetGlobalData(false);
    if (data) then
        for i, info in pairs(data.Futures) do
            if (info.RoomType == roomType) then
                return true;
            end
        end
    end
    return false;
end

function Starseeker.GetFutureCount(roomType)
    local data = GetGlobalData(false);
    local count = 0;
    if (data) then
        for i, info in pairs(data.Futures) do
            if (info.RoomType == roomType) then
                count = count + 1;
            end
        end
    end
    return count;
end


function Starseeker.DequeueFuture(roomType)
    local data = GetGlobalData(false);
    if (data) then
        for i, info in pairs(data.Futures) do
            if (info.RoomType == roomType) then
                table.remove(data.Futures, i);
                return info.Item;
            end
        end
    end
    return 0;
end

function Starseeker.GetCurrentRoomKey()
    local level = THI.Game:GetLevel();
    local roomDesc = level:GetCurrentRoomDesc();
    local currentSeed = roomDesc.DecorationSeed;
    return tostring(currentSeed);
end


---------------------------------
-- Events
---------------------------------
function Starseeker:preGetCollectible(pool, decrease, seed, loopCount)
    if (decrease and loopCount == 1) then
        local room = THI.Game:GetRoom();
        local roomType = room:GetType();
        if (Starseeker.HasFuture(roomType)) then
            if (not isGetingBallItem) then
                local item = Starseeker.DequeueFuture(roomType);
                if (item > 0) then
                    return item;
                end
            end
        end
    end
end
    
Starseeker:AddPriorityCallback(CuerLib.Callbacks.CLC_PRE_GET_COLLECTIBLE, 50, Starseeker.preGetCollectible);


--local ballsDataBuffer = {};
function Starseeker:onUpdate()
    local globalData = GetGlobalData(false);
    local level = THI.Game:GetLevel();
    local room = THI.Game:GetRoom();
    
    if (room:GetFrameCount() == 1) then
        local canTrigger = false;
        if (room:IsFirstVisit()) then
            if (Collectibles:IsAnyHasCollectible(Starseeker.Item)) then
                local roomDesc = level:GetCurrentRoomDesc();
                local dimension = Stages:GetDimension(roomDesc);
                if (dimension ~= 2) then -- No Death Certificate
                    if (roomDesc.Data.Type ~= RoomType.ROOM_DUNGEON) then
                        canTrigger = true;
                    end
                end
            end
        end

        if (canTrigger) then
            local key = Starseeker.GetCurrentRoomKey();
            local count = 0;
            for _, ent in pairs(Isaac.FindByType(5, 100)) do
                if (ent.SubType ~= 0) then
                    count = count + 1;
                end
            end
            if (count > 0) then
                globalData = GetGlobalData(true);
                globalData.Triggered = count > 0;
                globalData.RoomItemCount[key] = count;
            end
        end
    end

    if (Starseeker.BallSpawnCooldown > 0) then
        Starseeker.BallSpawnCooldown = Starseeker.BallSpawnCooldown - 1;
    end

    if (globalData and globalData.Triggered) then
        if (Starseeker.BallSpawnCooldown <= 0) then 
            local level = THI.Game:GetLevel();
            local roomKey = Starseeker.GetCurrentRoomKey();
            local itemCount = (globalData and globalData.RoomItemCount[roomKey]) or 0;
            if (itemCount > 0) then
                -- Will not create balls if there are balls in this room.
                if (#Isaac.FindByType(Starseeker.Ball.Id, Starseeker.Ball.Variant) > 0) then
                    return;
                end

                local room = THI.Game:GetRoom();
                local ballDistance = 80;
                local count = 3;
                if (THI.IsLunatic()) then
                    count = 2;
                end
                for i=1,count do
                    local originPos = room:GetCenterPos() + Vector(ballDistance * (i - 1 - (count - 1) / 2), 80);
                    local pos = room:FindFreePickupSpawnPosition(originPos, 0, true);
                    local ball = Starseeker.SpawnBall(pos);
                    ball.OptionsPickupIndex = 5810;
                end
                globalData.Triggered = itemCount > 1;
                globalData.RoomItemCount[roomKey] = itemCount - 1;
                if (globalData.RoomItemCount[roomKey] <= 0) then
                    globalData.RoomItemCount[roomKey] = nil;
                end
            end
        end
    end
end

Starseeker:AddCallback(ModCallbacks.MC_POST_UPDATE, Starseeker.onUpdate);

---- Ball -------------------
function Starseeker:PostBallInit(ball)
    Starseeker.InitBallItem(ball);
end
Starseeker:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Starseeker.PostBallInit, Starseeker.Ball.Variant);

function Starseeker:onBallUpdate(ball)
    if (Game():GetFrameCount() > 0) then

        local sprite = ball:GetSprite();
        if (sprite:IsEventTriggered("Appear")) then
            sprite:Play("Idle");
        end

        if (ball.Wait >= 0) then
            ball.Wait = ball.Wait - 1;
        end

        ball.Velocity = ball.TargetPosition - ball.Position;
    end
end
    
Starseeker:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Starseeker.onBallUpdate, Starseeker.Ball.Variant);

function Starseeker:onBallCollision(ball, collider, low)
    if (collider.Type == EntityType.ENTITY_PLAYER) then
        local player = collider:ToPlayer();
        if (player:IsExtraAnimationFinished()) then
            if (ball.Wait < 0) then
                PickupBall(ball);
            
                player:AnimateCollectible (Starseeker.Item, "UseItem")
                THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
                Starseeker.BallSpawnCooldown = 20;
            end
        end
    end
end
    
Starseeker:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, Starseeker.onBallCollision, Starseeker.Ball.Variant);

return Starseeker;