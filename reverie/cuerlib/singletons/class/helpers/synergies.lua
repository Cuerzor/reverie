local Mod = SINGLETON;
local Math = Mod.Math;
local RandomRange = Math.RandomRange;

local Synergies = Mod:NewClass();
local shotRNG = RNG();
local function ErrorSetConstValue(tbl, key, value)
    error("Trying to set value of a constant table.")
end
local function HasMomsKnife(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE);
end
local function HasLung(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG);
end


function Synergies.GetMarkedTarget(player)
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)) then
        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.OCCULT_TARGET)) do
            if (Mod.Entities.CompareEntity(ent.SpawnerEntity, player)) then
                return ent:ToEffect();
            end
        end
    elseif (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)) then
        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
            if (Mod.Entities.CompareEntity(ent.SpawnerEntity, player)) then
                return ent:ToEffect();
            end
        end
    end
    return nil;
end

function Synergies.CanLungShot(player)
    return HasLung(player) and not HasMomsKnife(player);
end

--========================================================
-- Multishot
--------------------
-- These will affect the tear count of Monstro's Lung. 
--========================================================

do
    
    -- Stores multishot infos like The Inner Eye, Mutant Spider, 20/20 and Bookworm.
    local MultishotParams = {
        -- The tear count.
        NumProjectiles = 1,
        -- The scale of tears' diffusion. changes tears' velocity direction.
        -- The larger this number is, the tears will be more scattered.
        DiffusionScale = 1,
        -- Start position offset of tears.
        Offset = 0
    };
    MultishotParams.__index = MultishotParams;

    local mt = {
        __index = MultishotParams,
        __newindex = ErrorSetConstValue
    }
    MultishotParams.Default = setmetatable({}, mt);

    -- Create a new MultishotParams.
    function MultishotParams:New()
        local new = {};
        setmetatable(new, self);
        return new;
    end

    
    Synergies.MultishotParams = MultishotParams;
end

local MultishotParams = Synergies.MultishotParams;

-- Get that will player trigger bookworm in next shoot?
-- **Note this is a function for custom characters, cannot be used on vanilla character's shots.**
-- The result will be changed every time you call this function.
function Synergies.GetNextBookwormTriggered(player)
    if (player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM)) then
        return shotRNG:RandomInt(2) == 1;
    end
    return false;
end
-- Get player's current multishot params.
function Synergies.GetNextMultishotParams(player)
    local params = MultishotParams:New();

    local bookwormTriggered = Synergies.GetNextBookwormTriggered(player);

    -- Shot Count.
    local shotCount = Synergies.GetNextMultishotCount(player, bookwormTriggered);

    -- Diffusion.
    local diffusionScale = Synergies.GetNextShotDiffusion(player, bookwormTriggered);

    -- Offset.
    local offset = 0;
    -- if there are only 2 shots, and has double tears, set the offset to 5.
    if (shotCount == 2) then
        if (bookwormTriggered or player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
            offset = offset + 5;
        end
    end

    -- Set Params.
    params.NumProjectiles = shotCount;
    params.DiffusionScale = diffusionScale;
    params.Offset = offset;

    return params;
end

-- Get next tear multishot count of a player.
function Synergies.GetNextMultishotCount(player, bookwormTriggered)
    local count = 1;
    local glassesNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20);
    local wizNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ);
    local innerEyeNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE);
    local mutantSpiderNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER);


    local multiTier = 0;

    if (innerEyeNum > 0) then
        multiTier = multiTier + innerEyeNum;
    end
    if (mutantSpiderNum > 0) then
        multiTier = multiTier + mutantSpiderNum * 2;
    end

    if (glassesNum > 0) then
        count = count + glassesNum;
        if (multiTier > 0) then
            count = count - 1;
        end
    end


    
    if (multiTier > 0) then
        count = count + math.floor(multiTier /(wizNum + 1) ) + 1;
    end

    if (bookwormTriggered) then
        count = count + 1;
    end

    count = math.min(count, 16); 

    
    return count;
end
-- Get next tear diffusion of a player.
function Synergies.GetNextShotDiffusion(player, bookwormTriggered)
    local scale = 1;

    if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
        scale = scale * 0.2;
    end

    if (bookwormTriggered) then
        scale = scale * 0.5;
    end
    return scale;
end


--====
-- Trigger Check
--====



function Synergies.CheckMomsEyeTrigger(player)
    local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_EYE);
    local fire = fireRng:RandomInt(100);
    local rate = 25 + player.Luck * 10;
    return fire < rate;
end

function Synergies.CheckLokisHornTrigger(player)
    local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOKIS_HORNS);
    local fire = fireRng:RandomInt(100);
    local rate = 25 + player.Luck * 5;
    return fire < rate;
end

function Synergies.CheckTechDot5Trigger(player)
    local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TECH_5);
    local fire = fireRng:RandomInt(6);
    return fire <= 0;
end

--================================================================
-- Tear Cluster
--================================================================

function Synergies.IsLungLessMode(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or 
    player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE);
end

function Synergies.GetNextLungShotCount(player, count, isLessMode)
    if (isLessMode == nil) then
        isLessMode = Synergies:IsLungLessMode(player);
    end
    count = count or Synergies.GetNextShotCount(player);
    local lungNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG);
    if (lungNum > 1) then    
        count = count + (lungNum - 1) * 5;
    end

    if (isLessMode) then
        return 5 + count;
    end
    
    return math.min(50, math.floor((count + 5) * 2.4));
end
-- Get player's current shot params with Montro's Lung.
function Synergies.ApplyClusterTearEffect(player, dir, tearEntity)
    local tear = tearEntity:ToTear();
    local speedMultiplier = RandomRange(shotRNG, 0.25, 1.25);
    local angleOffset = RandomRange(shotRNG, -10, 10);

    tearEntity.Velocity = (dir * player.ShotSpeed * 10 * speedMultiplier):Rotated(angleOffset);
    
    if (tear) then
        tear.Height = player.TearHeight;
        tear.FallingAcceleration = 0.5;
        tear.FallingSpeed = RandomRange(shotRNG, -player.TearFallingSpeed - 15, -player.TearFallingSpeed);
    end
end

return Synergies;