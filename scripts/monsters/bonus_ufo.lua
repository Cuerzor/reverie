local BonusUFO = ModEntity("Red Bonus UFO", "BonusUFO");
local Detection = CuerLib.Detection;
local Pickups = CuerLib.Pickups;
local Screen = CuerLib.Screen;

BonusUFO.SubTypes = {
    RED = 0,
    BLUE = 1,
    GREEN = 2,
    RAINBOW = 3
}



function BonusUFO.GetFloorData(init)
    return BonusUFO:GetGlobalData(init, function() return {
        DestroyedCount = 0
    }end)
end

local timeLimit = 450;
-- BonusUFO.Collected = {};
-- local ufoCollected = BonusUFO.Collected;
function BonusUFO.GetUFOData(ufo, init)
    -- local data = ufoCollected;
    -- if (init) then
    --     data[ufo.Index] = data[ufo.Index] or {
    --         Collected = {
    --             Collectibles = {},
    --             Pickups = {}
    --         }
    --     }
    -- end
    -- return data[ufo.Index];
    return BonusUFO:GetData(ufo, init, function() return {
        BonusTimes = 2,
        Collected = {
            Collectibles = {},
            Pickups = {}
        },
        Direction = Vector.Zero
    } end);
end

function BonusUFO.GetUFOTime(npc)
    return math.max(0, npc.FrameCount - 70);
end

-- function BonusUFO.RemoveUFOData(ufo)
--     ufoCollected[ufo.Index] = nil;
-- end

function BonusUFO:PostUFOInit(npc)
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    npc:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_NO_PLAYER_CONTROL | EntityFlag.FLAG_NO_BLOOD_SPLASH);
    npc.PositionOffset = Vector(0, -16);
end
BonusUFO:AddCallback(ModCallbacks.MC_POST_NPC_INIT, BonusUFO.PostUFOInit, BonusUFO.Type);

local function GetBlueTarget(npc, maxSpeed)
    
    local game = THI.Game;
    local room = game:GetRoom();
    local gridIndex = room:GetGridIndex(npc.Position);
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    local x = gridIndex % width;
    local y = math.floor(gridIndex / width);

    local minX = 1;
    local maxX = width - 2;
    local minY = 1;
    local maxY = height - 2;
    local shape = room:GetRoomShape();
    if (shape == RoomShape.ROOMSHAPE_IV or shape ==  RoomShape.ROOMSHAPE_IIV) then
        minX = 5;
        maxX = width - 6;
    elseif (shape == RoomShape.ROOMSHAPE_IH or shape ==  RoomShape.ROOMSHAPE_IIH) then
        minY = 3;
        maxY = height - 4;
    end

    local clampedGridIndex = math.max(math.min(y, maxY), minY) * width + math.max(math.min(x, maxX), minX)
    local gridPos = room:GetGridPosition (clampedGridIndex);

    local wallFlags = 0;
    for i = 0, 7 do
        local targetX = x;
        local targetY = y;
        if (i == 0) then
            targetX = targetX + 1;
        elseif (i == 1) then
            targetY = targetY + 1;
        elseif (i == 2) then
            targetX = targetX - 1;
        elseif (i == 3) then
            targetY = targetY - 1;
        elseif (i == 4) then
            targetX = targetX + 1;
            targetY = targetY - 1;
        elseif (i == 5) then
            targetX = targetX + 1;
            targetY = targetY + 1;
        elseif (i == 6) then
            targetX = targetX - 1;
            targetY = targetY + 1;
        elseif (i == 7) then
            targetX = targetX - 1;
            targetY = targetY - 1;
        end
        if (targetX >= 0 and targetX < width and targetY >= 0 and targetY < height) then
            local targetIndex = targetY * width + targetX;
            local targetGrid = room:GetGridEntity(targetIndex);
            if (targetGrid and (targetGrid.CollisionClass == GridCollisionClass.COLLISION_WALL or targetGrid.CollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER)) then
                wallFlags = wallFlags | 1 << (i % 4);
            end
        end
    end

    if (room:IsPositionInRoom (npc.Position, 0)) then
        -- 1: Right
        -- 2: Bottom
        -- 4: Left
        -- 8: Top
        if (wallFlags == 4 or wallFlags == 12 or wallFlags == 13) then
            -- Left, Top Left or Left Top Right.
            return Vector(gridPos.X, npc.Position.Y + maxSpeed);
        elseif (wallFlags == 1 or wallFlags == 3 or wallFlags == 7) then
            -- Right, Bottom Right or Left Bottom Right.
            return Vector(gridPos.X, npc.Position.Y - maxSpeed);
        elseif (wallFlags == 8 or wallFlags == 9 or wallFlags == 11) then
            -- Top, Top Right or Bottom Top Right.
            return Vector(npc.Position.X - maxSpeed, gridPos.Y);
        elseif (wallFlags == 2 or wallFlags == 6 or wallFlags == 14 or wallFlags == 0) then
            -- Bottom, Bottom Left, Left Bottom Top or Open.
            return Vector(npc.Position.X + maxSpeed, gridPos.Y);
        else
            -- Left Right, Bottom Top or Closed.
            return gridPos;
        end
    end
    return room:GetCenterPos();
end

function BonusUFO.GetMaxHealth(npc)
    local data = BonusUFO.GetUFOData(npc, false);
    local globalData = BonusUFO.GetFloorData(false);
    local game = THI.Game;
    local level = game:GetLevel();
    local stage = level:GetStage();
    local maxHP = 5 + stage * 12;

    local destroyedCount = 1;
    if (globalData) then
        destroyedCount = globalData.DestroyedCount;
    end

    local c = 0;
    local p = 0;
    if (data) then
        c = #data.Collected.Collectibles;
        p = #data.Collected.Pickups;
    end
    maxHP = (maxHP + p * 3) * 2 ^ math.min(c + destroyedCount, 16);
    return maxHP;
end

function BonusUFO.EvaluateHealth(npc)
    local newHp = BonusUFO.GetMaxHealth(npc);
    local diff = newHp - npc.MaxHitPoints;
    npc.MaxHitPoints = newHp;
    if (diff > 0) then
        npc.HitPoints = npc.HitPoints + diff;
    end
end

local function Collect(npc, pickup)
    local data = BonusUFO.GetUFOData(npc, true);
    local variant = pickup.Variant;
    local subType = pickup.SubType;
    if (variant == PickupVariant.PICKUP_COLLECTIBLE) then
        local info = {
            Type = pickup.Type,
            Variant = variant,
            SubType = 0
        }
        
        table.insert(data.Collected.Collectibles, info)
    else
        if (variant == PickupVariant.PICKUP_TRINKET 
        -- or variant == PickupVariant.PICKUP_TAROTCARD 
        -- or variant == PickupVariant.PICKUP_PILL
        ) then
            subType = 0;
        end
        local info = {
            Type = pickup.Type,
            Variant = variant,
            SubType = subType;
        }
        table.insert(data.Collected.Pickups, info)
    end 

    BonusUFO.EvaluateHealth(npc);
end

local function CanCollect(pickup)
    local variant = pickup.Variant;
    local subType = pickup.SubType;

    if (pickup:IsShopItem()) then
        return false;
    end
    
    if (variant == PickupVariant.PICKUP_BED or 
        variant == PickupVariant.PICKUP_TROPHY or 
        variant == PickupVariant.PICKUP_BIGCHEST or 
        variant == THI.Pickups.StarseekerBall.Variant ) then
            return false;
    end

    if (variant == PickupVariant.PICKUP_COIN and subType == CoinSubType.COIN_STICKYNICKEL) then
        return false;
    end

    if (variant == PickupVariant.PICKUP_COLLECTIBLE and subType <= 0) then
        return false;
    end
    -- if (variant == PickupVariant.PICKUP_LIL_BATTERY) then
    --     return false;
    -- end

    if (Pickups.IsChest(pickup.Variant) and subType == ChestSubType.CHEST_OPENED) then
        return false;
    end
    return true;
end

local function CollectUpdate(npc)
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        local variant = ent.Variant;
        local subType = ent.SubType;
        local pickup = ent:ToPickup();
        if (pickup and CanCollect(pickup) and pickup:Exists()) then
            local dir = (npc.Position - pickup.Position):Normalized();
            local frameCount = npc.FrameCount;
            if (variant == PickupVariant.PICKUP_COLLECTIBLE) then
                pickup.TargetPosition = pickup.Position + dir * math.min(20, frameCount / 10 * 2);
            else
                pickup.Position = pickup.Position + dir * math.min(10, math.min(frameCount, pickup.FrameCount) / 10);
                pickup.Velocity = pickup.Velocity + dir * 1;
            end
            if (Detection.CheckCollision(npc, pickup)) then
                pickup:ToPickup():PlayPickupSound();
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
                Collect(npc, pickup:ToPickup());
                pickup:Remove();
            end
        end
    end
end

local function MovementUpdate(npc)
    local game = THI.Game;
    local room = game:GetRoom();

    local subType = npc.SubType;
    npc.Target = npc.SpawnerEntity or Isaac.GetPlayer(0);
    local target = npc.Target;
    local data = BonusUFO.GetUFOData(npc, true);
    local maxSpeed = 10;

    local time = BonusUFO.GetUFOTime(npc);
    if (time > timeLimit) then
        -- out of time.
        maxSpeed = 10;
        npc.TargetPosition = Vector(-300, -300);
    else

        -- Red.
        if (subType == BonusUFO.SubTypes.RED) then
            maxSpeed = 5;
            local maxRadius = 120;
            local maxRotateSpeed = 10;
    
            local dir = npc.Position - target.Position;
            local nextRadius = math.min(maxRadius, dir:Length() + 1);
            local rotatedAngle = math.atan(maxRotateSpeed / 2 / nextRadius) / math.pi * 180 * 2;
            local offset = dir:Rotated(rotatedAngle):Normalized() * nextRadius;
            npc.TargetPosition = target.Position + offset;

        -- Blue.
        elseif (subType == BonusUFO.SubTypes.BLUE) then
            -- Guts like movement.
            maxSpeed = 7;
            npc.TargetPosition = GetBlueTarget(npc, maxSpeed);
            
        -- Green.
        elseif (subType == BonusUFO.SubTypes.GREEN) then
            -- Warping Movement.
            maxSpeed = 12;
            local centerPos = room:GetCenterPos();
            local minY = 160;
            local maxY = 400;
            local shape = room:GetRoomShape();
            if (shape == RoomShape.ROOMSHAPE_IH or shape == RoomShape.ROOMSHAPE_IIH) then
                minY = 240;
                maxY = 320;
            end
            local limitPos = centerPos * 2;
            if (npc.Position.X < 0) then
                local rng = RNG();
                rng:SetSeed(Random(), 0);
                npc.Position = Vector(limitPos.X, minY + rng:RandomFloat() * (maxY - minY) );
            elseif (npc.Position.X > limitPos.X) then
                local rng = RNG();
                rng:SetSeed(Random(), 0);
                npc.Position = Vector(0, minY + rng:RandomFloat() * (maxY - minY) );
            end
    
            npc.TargetPosition = npc.Position + Vector(maxSpeed, 0);
            
        -- Rainbow.
        elseif (subType == BonusUFO.SubTypes.RAINBOW) then
            -- Vertical Warping Movement.
            maxSpeed = 12;
            local centerPos = room:GetCenterPos();
            local minX = 80;
            local maxX = 560;
            local shape = room:GetRoomShape();
            if (shape == RoomShape.ROOMSHAPE_IV or shape == RoomShape.ROOMSHAPE_IIV) then
                minX = 240;
                maxX = 400;
            end
            local limitPos = centerPos * 2;
            if (npc.Position.Y < 0) then
                local rng = RNG();
                rng:SetSeed(Random(), 0);
                npc.Position = Vector(minX + rng:RandomFloat() * (maxX - minX), limitPos.Y );
            elseif (npc.Position.Y > limitPos.Y) then
                local rng = RNG();
                rng:SetSeed(Random(), 0);
                local random = rng:RandomFloat();
                local x = minX + random * (maxX - minX);
                npc.Position = Vector(x, 0 );
            end
    
            npc.TargetPosition = npc.Position + Vector(0, maxSpeed);
        end
    end
    
    local vel = npc.Velocity + (npc.TargetPosition - npc.Position):Normalized() * math.min(2, (time / 30) * 2);
    vel = vel:Normalized() * math.min(maxSpeed , vel:Length());
    npc.Velocity = vel;
end

function BonusUFO:PostNPCUpdate(npc)
    if (npc.Variant == BonusUFO.Variant) then
        local game = THI.Game;
        local room = game:GetRoom();
        local sprite = npc:GetSprite();
        if (npc.FrameCount == 1) then
            BonusUFO.EvaluateHealth(npc);
            THI.SFXManager:Play(THI.Sounds.SOUND_UFO);
            sprite:Play("Appear", true);
        end
        if (sprite:IsFinished("Appear"))then
            sprite:Play("Idle");
        end
    
        npc.SpriteRotation = math.sin(npc.FrameCount / math.pi /4) * 5;
        if (npc.FrameCount % 15 == 0) then
            THI.SFXManager:Play(THI.Sounds.SOUND_UFO_ALERT, 0.5);
        end
    
        local time = BonusUFO.GetUFOTime(npc);
        CollectUpdate(npc);
        if (time > 0) then
            npc.Friction = 1;
            MovementUpdate(npc);
        else
            
            npc.Friction = 0;
        end
        
        if (time > timeLimit and not room:IsPositionInRoom(npc.Position, -200)) then
            npc:Remove();
            return;
        end
        if (npc:IsDead()) then
            local globalData = BonusUFO.GetFloorData(true);
            globalData.DestroyedCount = globalData.DestroyedCount + 1;
    
            local data = BonusUFO.GetUFOData(npc, false);
            if (data) then
                local game = THI.Game;
                local room = game:GetRoom();
                local rng = RNG();
                rng:SetSeed(Random(), 0);
                local times = data.BonusTimes;
                for i, info in pairs(data.Collected.Collectibles) do
                    for t = 1, times do
                        local pos = room:FindFreePickupSpawnPosition(npc.Position, 0, true);
                        Isaac.Spawn(info.Type, info.Variant, info.SubType, pos, Vector.Zero, npc);
                    end
                end
                for i, info in pairs(data.Collected.Pickups) do
                    for t = 1, times do
                        local pos = npc.Position;
                        Isaac.Spawn(info.Type, info.Variant, info.SubType, pos, RandomVector() * rng:RandomFloat() * 3, npc);
                    end
                end
            end
        end
    end
 
end
BonusUFO:AddCallback(ModCallbacks.MC_NPC_UPDATE, BonusUFO.PostNPCUpdate, BonusUFO.Type);

function BonusUFO.BurstEffect(position, count)
    count = count or 20;
    position = position or Vector(320, 280);
    local rng = RNG();
    rng:SetSeed(Random(), 0);
    local wave = THI.Effects.SpellCardWave;
    local leaf = THI.Effects.SpellCardLeaf;
    for i = 1, count do
        local angle = rng:RandomFloat()* 360;
        local length = rng:RandomFloat() * 320 + 480;
        local sizeX = rng:RandomFloat()  + 0.5;
        local sizeY = rng:RandomFloat()  + 0.5;
        local rotation = rng:RandomFloat()* 360;
        local speed = rng:RandomFloat() * 0.3 + 0.7;

        local offset = Vector.FromAngle(angle) * length;
        local leafEntity = Isaac.Spawn(leaf.Type, leaf.Variant, 0, position, offset / 21 * speed, nil);
        leafEntity.SpriteRotation = rotation;
        leafEntity.SpriteScale = Vector(sizeX, sizeY);
        leafEntity:GetSprite().PlaybackSpeed = speed;
    end
    local waveEnt = Isaac.Spawn(wave.Type, wave.Variant, wave.SubTypes.BURST, position, Vector.Zero, nil);
end

function BonusUFO:PostUFODeath(npc)
    BonusUFO.BurstEffect(npc.Position)


    THI.Game:ShakeScreen(30);
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_CHARGE_RELEASE);
    THI.SFXManager:Play(SoundEffect.SOUND_DOGMA_TV_BREAK);
end
BonusUFO:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BonusUFO.PostUFODeath, BonusUFO.Type);

function BonusUFO:PreUFOTakeDamage(entity, amount, flags, source, countdown)
    if (source.Type == EntityType.ENTITY_FIREPLACE) then
        return false;
    end

    local time = BonusUFO.GetUFOTime(entity);
    if (time <= 0) then
        return false;
    end
end
BonusUFO:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, BonusUFO.PreUFOTakeDamage, BonusUFO.Type);

local greyColor = KColor(0.5, 0.5, 0.5, 1);
function BonusUFO:RenderUFO(ufo, offset)
    local font = THI.GetFont("UFO_TIMER");

    if (not Screen.IsReflection()) then
        local pos = Screen.GetEntityOffsetedRenderPosition(ufo, offset, Vector(0, -64));

        local time = BonusUFO.GetUFOTime(ufo);
        local seconds = math.max(0, (timeLimit - time) / 30);
        local str = string.format("%.2f", seconds);
        local length = font:GetStringWidth(str);
        local color = KColor.White;
        if (time <= 0) then
            color = greyColor;
        elseif (seconds <= 5) then
            color = KColor.Red;
        end

        
        font:DrawString(str, pos.X - length / 2, pos.Y, color, length, true);
    end
end
BonusUFO:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, BonusUFO.RenderUFO, BonusUFO.Type);

function BonusUFO:PostUFORemove(npc)
    local ufos = Isaac.FindByType(BonusUFO.Type);
    local ufoExists = false;
    for i, ent in pairs(ufos) do
        if (ent:Exists()) then
            ufoExists = true;
            break;
        end
    end
    if (not ufoExists) then
        local musicManager = MusicManager();
        local curMusic = musicManager:GetCurrentMusicID ( );
        local queued = musicManager:GetQueuedMusicID();
        if (curMusic == THI.Music.UFO and curMusic ~= queued) then
            musicManager:Crossfade (musicManager:GetQueuedMusicID());
        end
    end

end
BonusUFO:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, BonusUFO.PostUFORemove, BonusUFO.Type);

function BonusUFO.PostNewLevel()
    local globalData = BonusUFO.GetFloorData(true);
    globalData.DestroyedCount = 0;
end
BonusUFO:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BonusUFO.PostNewLevel, BonusUFO.Type);

return BonusUFO;