local Lib = CuerLib;
local Synergies = Lib.Synergies;
local MultishotParams = Synergies.MultishotParams;
local Stats = Lib.Stats;
local Consts = Lib.Consts;
local Maths = Lib.Math;
local Tears = Lib.Tears;
local Inputs = Lib.Inputs;
local Detection = Lib.Detection;
local Screen = Lib.Screen;
local Eika = ModPlayer("Eika", false, "Eika");

local Costume = Isaac.GetCostumeIdByPath("gfx/characters/costume_eika.anm2");

local MaxFireCooldown = 2;
local rng = RNG();
local LudovicoFlag = Maths.GetTearFlag(127);


local FetusFlags = {
    TEAR_SWORD_FETUS = BitSet128(0, 1 << 43),
    TEAR_BONE_FETUS = BitSet128(0, 1 << 44),
    TEAR_KNIFE_FETUS = BitSet128(0, 1 << 45),
    TEAR_TECH_X_FETUS = BitSet128(0, 1 << 46),
    TEAR_TECH_FETUS = BitSet128(0, 1 << 47),
    TEAR_DR_FETUS = BitSet128(0, 1 << 49),
    TEAR_FETUS = BitSet128(0, 1 << 50),
}
local Effects = {
    PlaceHolder = Isaac.GetEntityVariantByName("Idle Rocket")
}

local PlaceHolderSubType = {
    IdleRocket = 1,
    KnifeParent = 2,
    SwordParent = 3
}

local Knifes = {
    BladeRock = Isaac.GetEntityVariantByName("Blade Rock"),
    RockSword = Isaac.GetEntityVariantByName("Rock Sword")
}

local RockVariants = {
    Probe = Isaac.GetEntityVariantByName("Probe Tear")
}

local RockColors = {
    Brimstone = Color(1, 0, 0, 1, 0, 0, 0)
}

--------------------
-- Helpers
--------------------

local function GetSpawnerPlayer(ent)
    local spawner = ent.SpawnerEntity;
    if (spawner) then
        local player = spawner:ToPlayer();
        return player;
    end
    return nil;
end

local RandomRange = Maths.RandomRange;

local CompareEntity = Detection.CompareEntity;
local EntityExists = Detection.EntityExists;

local function HasMomsKnife(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE);
end
local function HasLung(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG);
end
local function HasCursedEye(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE);
end
local function HasChocolateMilk(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK);
end
local function HasMarked(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED);
end
local function HasOccultEye(player) 
    return player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT);
end

local function GetMarkedTarget(player)
    local tempData = Eika:GetPlayerTempData(player, false);
    if (tempData and EntityExists(tempData.markedTarget)) then
        return tempData.markedTarget;
    end
end

----------------
-- Input
----------------


-- Is instantly throw the rock if stacked?
function Eika:IsThrowOnShoot(player)
    local shoot = player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or
                      player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK);
    return shoot;
end

-- Is player can shoot to any directions?
local function IsAllDirectionShoot(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or
               player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or
               player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE);
end


-- Get player's shooting vector.
local function GetShootingVector(player, center)
    local target = GetMarkedTarget(player);
    if (target) then
        return (target.Position - player.Position):Normalized();
    end

    local dir = Inputs.GetRawShootingVector(player, center);
    if (not IsAllDirectionShoot(player)) then
        local length = dir:Length();
        local angle = dir:GetAngleDegrees();
        angle = math.floor((angle + 45) / 90) * 90;
        return Vector.FromAngle(angle) * length;
    end
    return dir:Normalized();
end

-- Get players's throw direction.
function Eika:GetThrowDirection(player)
    if (Eika:IsThrowOnShoot(player)) then
        return GetShootingVector(player);
    end
    local tempData = Eika:GetPlayerTempData(player, false);
    if (tempData) then
        return tempData.RecentShootVector;
    end
    return Vector.Zero;
end



--------------------
-- Data
--------------------

-- Get player's persistent Data.
function Eika:GetPlayerData(player, init)
    return Eika:GetData(player, init, function() return {
        ThrowIndex = 0
    } end);
end

-- Get player's temporary Data for this run.
function Eika:GetPlayerTempData(player, init)
    local data = Lib:GetData(player);
    if (init) then
        data._EIKA = data._EIKA or {
            CursedEyeTeleport = false,
            FireDelay = 0,
            Stacking = false,
            StackedRocks = {},
            ThrowCooldown = 0,
            LastShootVector = Vector(0, 0),
            RecentShootVector = Vector(0, 0),
            Firing = false,
            LudoRock = nil,
            FiringKnifeCount = 0,
            FiringKnifeDirection = Vector(0, 0),
            MarkedTarget = nil,
            Anim = {
                Name = nil,
                Frame = 0
            }
        }
    end
    return data._EIKA;
end

-- Get player's current max stack count.
-- Birthright can increase this to 20.
function Eika:GetMaxStackCount(player)

    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return 20;
    end

    if (player.Velocity:Length() > 1) then
        return 3;
    end

    return 5;

end


--------------------
-- Rocks
--------------------

-- Get Rock's Data.
function Eika:GetRockData(tear, init)
    local data = tear:GetData();
    if (init) then
        data.EIKA_ROCK = data.EIKA_ROCK or {
            BaseDamage = 3.5,
            FireCooldown = 0,
            Brimstone = false,
            Technology = false,
            TechX = false,
            TechXRing = nil,
            EpicFetus = false,
            LaserCooldown = 0,
            IsStacking = false,
            IsDropping = false,
            FallingSpeed = 0,
            FallingAcceleration = 0,
            ScaleMultiplier = 1,
            Knife = {
                FlyAway = false,
                Fired = true,
                FireTime = 0,
                MaxFireTime = 60,
                StartPos = Vector(0, 0),
                TargetPos = Vector(0, 0),
                Timeout = 60,
                Direction = Vector(0, 0),
                SideVelocity = Vector(0, 0)
            },
            Ludo = {
                Enabled = false,
                Children = {},
                SubTearAngle = 0,
                Scale = 1
            },
            SpiritSword = {
                Has = false,
                Sword = nil
            },
            CollidedEnemies = {}
        }
    end
    return data.EIKA_ROCK;
end

function Eika:GetRockSwordData(sword, init)
    local data = sword:GetData();
    if (init) then
        data.EIKA_ROCK = data.EIKA_ROCK or {
            Hit = {},
            IsTech = false
        }
    end
    return data.EIKA_ROCK;
end



-- Conversion from bomb's SpriteOffset to PositionOffset.
local BombSpriteToPositionOffset = Vector(0, -32);

-- Conversion from Knife's Position to its parent's Position.
local KnifeParentOffset = Vector(0, -24);
-- Get knife parent's position based on knife's position.
local function GetKnifeParentPosition(knifePos)
    return knifePos + KnifeParentOffset;
end
local function GetKnifeChildPosition(knifePos)
    return knifePos - KnifeParentOffset;
end

-- Set Rock's Height.
local function SetRockHeight(rock, height)
    if (rock.Type == EntityType.ENTITY_TEAR) then
        if (rock.FallingAcceleration <= 0) then
            rock.Height = Maths.GetTearPositionOffsetHeight(height);
        else
            rock.Height = height;
        end
        rock.DepthOffset = -rock.PositionOffset.Y;
    elseif (rock.Type == EntityType.ENTITY_BOMBDROP) then
        rock.SpriteOffset = Vector(0, height) - BombSpriteToPositionOffset;
        rock.DepthOffset = -rock.SpriteOffset.Y;
    elseif (rock.Type == EntityType.ENTITY_KNIFE) then
        rock.PositionOffset = Vector(0, height) -- - rock.Position + rock.Parent.Position;
    else

        if (rock.Variant == Effects.PlaceHolder and rock.SubType == PlaceHolderSubType.KnifeParent) then
            SetRockHeight(rock.Child, height);
        else
            rock.PositionOffset = Vector(0, height);
            rock.DepthOffset = -rock.PositionOffset.Y;
        end

    end
end

-- Release knife rock. Called after the rock is dropped or thrown.
local function ReleaseKnife(knife)
    knife.PositionOffset = Vector.Zero;
end

-- Release bomb rock. Called after the rock is dropped or thrown.
local function ReleaseBomb(bomb, height)
    bomb.PositionOffset = bomb.SpriteOffset + BombSpriteToPositionOffset;
    bomb.SpriteOffset = Vector.Zero;
    bomb:SetExplosionCountdown(30);
end

-- Release effect rock. Called after the rock is dropped or thrown.
local function ReleaseEffect(effect, height)
    height = height or 0;
    if (effect.Variant == Effects.PlaceHolder) then
        if (effect.SubType == PlaceHolderSubType.IdleRocket) then
            local player = GetSpawnerPlayer(effect);
            if (player) then
                player:FireBomb(effect.Position, effect.Velocity);
                effect:Remove();
            end
        elseif (effect.SubType == PlaceHolderSubType.KnifeParent) then
            effect.Child.PositionOffset = Vector(0, height - 14);
        end
    end
end

local function SetRockFired(player, rock, dir, rockParams)
    if (rock.Type == EntityType.ENTITY_TEAR) then
        rock.Height = player.TearHeight;
        rock.FallingSpeed = -player.TearFallingSpeed;
        rock.FallingAcceleration = player.TearFallingAcceleration;
    end
    if (rockParams.IsLung) then
        Synergies.ApplyClusterTearEffect(player, dir, rock);
    else
        local posOffset = Vector.Zero;
        posOffset = dir * 3;
        rock.Position = rock.Position + posOffset + rockParams.Offset;
        rock.Velocity = dir * player.ShotSpeed * 10;
    end

    local velocity = rock.Velocity;
    local inheritance = player:GetTearMovementInheritance(velocity);
    rock.Velocity = velocity + inheritance;

    if (rock.Type == EntityType.ENTITY_TEAR) then
        rock.DepthOffset = 0;
    elseif (rock.Type == EntityType.ENTITY_BOMBDROP) then
        ReleaseBomb(rock);
    elseif (rock.Type == EntityType.ENTITY_KNIFE) then
        ReleaseKnife(rock);
        rock.Rotation = dir:GetAngleDegrees();
        rock.Position = player.Position + dir * 20;
        --rock:Shoot(1, ((player.TearFallingSpeed - player.TearFallingAcceleration * 10) * 45 + 260));
        rock:Shoot(1, player.TearRange);
    elseif (rock.Type == EntityType.ENTITY_EFFECT) then
        ReleaseEffect(rock);

        if (rock.Variant == Effects.PlaceHolder) then
            if (rock.SubType == PlaceHolderSubType.KnifeParent) then
                rock.Position = GetKnifeParentPosition(rock.Position);
                if (not rockParams.FlyingKnife) then
                    local knifeData = Eika:GetRockData(rock, true).Knife;
                    knifeData.Fired = true;
                    knifeData.FireTime = 0;

                    local maxFireTime = 15;

                    knifeData.MaxFireTime = maxFireTime;
                    local startPos = GetKnifeParentPosition(player.Position);
                    knifeData.StartPos = startPos;
                    --knifeData.TargetPos = startPos + dir * ((player.TearFallingSpeed - player.TearFallingAcceleration * 10) * 45 + 260);
                    knifeData.TargetPos = startPos + dir * player.TearRange;
                else
                    Eika:MakeBladeRockFly(player, rock, dir);
                end
            end
        end
    end
end

local RockParams = {
    IsLung = false,
    FlyingKnife = false,
    AddIndex = true,
    CanWiz = true,
    Offset = Vector(0,0),
    IgnoreItems = false,
};
RockParams.__index = RockParams;
local defaultMETA = {
    __index = RockParams,
    __newindex = function() error("Trying to set value of a constant table.") end;
}
RockParams.Default = setmetatable({}, defaultMETA);

function RockParams:New()
    return setmetatable({}, RockParams);
end

-- Function that adds throw index and trigger Lead Pencil.
local function AddThrowIndex(player, fireDir)
    local data = Eika:GetPlayerData(player, true);
    data.ThrowIndex = data.ThrowIndex + 1;

    if (player:HasCollectible(CollectibleType.COLLECTIBLE_LEAD_PENCIL)) then
        if (data.ThrowIndex % 15 == 0) then
            local pencilParams = RockParams:New();
            pencilParams.IsLung = true;
            pencilParams.AddIndex = false;
            pencilParams.IgnoreItems = true;
            Eika:ShootRock(player, nil, fireDir, MultishotParams.Default, pencilParams);
        end
    end
end
-- Shoot the rock using specified params to a direction.
function Eika:ShootRock(player, rock, fireDir, params, rockParams)
    params = params or MultishotParams.Default;

    local data = Eika:GetPlayerData(player, true);

    local num = params.NumProjectiles;
    local isLung = rockParams.IsLung;
    local addIndex = rockParams.AddIndex;
    local canWiz = rockParams.CanWiz;


    if (isLung and (rockParams.IgnoreItems or not HasMomsKnife(player))) then
        local lessMode = false;
        if (not rockParams.IgnoreItems) then
            lessMode = Synergies.IsLungLessMode(player);
        end
        num = Synergies.GetNextLungShotCount(player, num, lessMode);
    end

    -- The Wiz.
    local wizNum = 0;
    if (canWiz) then
        wizNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ);
    end
    local wizIncludeAngle = 0;

    if (wizNum > 0) then
        wizIncludeAngle = 90 / wizNum;
    end

    for w = 0, wizNum do
        local RUAWizAngleOffset = 0;
        local wizAngle = RUAWizAngleOffset;
        if (wizNum > 0) then
            wizAngle = wizAngle + 45 - wizIncludeAngle * w;
        end

        for i = 1, num do
            local exists = EntityExists(rock);
            if (not exists) then
                rock = Eika:SpawnRock(player);
            end
            local rockData = Eika:GetRockData(rock, true);

            local dir = fireDir;
            local multishotAngle = 0;
            if (not isLung) then
                multishotAngle = -i * 4.34 + num * 4.34 / 2
            end
            dir = dir:Rotated(wizAngle + multishotAngle);

            SetRockFired(player, rock, dir, rockParams);

            if (exists) then
                rock.Position = rock.Position - rock.Velocity;
            end

            rockData.IsStacking = false;

            rock = nil;

            -- Monstro's Lung's tears will increase throw index.
            if (not exists and (isLung and rockParams.AddIndex)) then
                AddThrowIndex(player, fireDir);
            end
        end
    end

    -- Add throw index.
    if (rockParams.AddIndex) then
        AddThrowIndex(player, fireDir);
    end
end

-- Throw the rock. Will trigger fire events like mom's eye or mutant spider.
function Eika:ThrowRock(player, rock)
    local tempData = Eika:GetPlayerTempData(player, true);
    local dir = Eika:GetThrowDirection(player);
    local params = Synergies.GetNextMultishotParams(player);


    local isLung = HasLung(player);
    local isEyeSore = player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE);
    local isLokisHorns = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS);

    local rockParams = RockParams:New();
    rockParams.IsLung = isLung;

    Eika:ShootRock(player, rock, dir, params, rockParams);

    -- Mom's Knife.
    if (HasMomsKnife(player)) then
        -- Mom's Knife + Brimstone.
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) then
            tempData.FiringKnifeCount = tempData.FiringKnifeCount + 4;
            tempData.FiringKnifeDirection = dir;
        end

        -- Mom's Knife + Monstro's Lung.
        if (isLung) then
            local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG);

            rockParams.FlyingKnife = true;
            local count = fireRng:RandomInt(2) + 3;
            for i = 1, count do
                local angle = fireRng:RandomFloat() * 360;
                local vec = Vector.FromAngle(angle);
                Eika:ShootRock(player, Eika:SpawnRock(player), vec, MultishotParams.Default, rockParams)
            end
        end
    end

    -- Extra Tear Items.
    -- These will shoot clusters instead when has monstro's lung.

    local function TriggerMomsEye()
        rockParams.FlyingKnife = false;
        local angle = 180;
        local vec = dir:Rotated(angle);
        Eika:ShootRock(player, Eika:SpawnRock(player), vec, MultishotParams.Default, rockParams)
    end
    local function TriggerLokisHorn()
        rockParams.FlyingKnife = false;
        for i = 1, 3 do
            local angle = i * 90;
            local vec = dir:Rotated(angle);
            Eika:ShootRock(player, Eika:SpawnRock(player), vec, MultishotParams.Default, rockParams)
        end
    end
    -- Mom's Eye
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE)) then
        if (Synergies.CheckMomsEyeTrigger(player)) then
            if (not isLokisHorns) then
                -- Single Mom's Eye.
                TriggerMomsEye();
            else
                -- Mom's Eye + Loki's Horn.
                TriggerLokisHorn();
            end
        end
    else
        -- Single Loki's Horn.
        if (isLokisHorns) then
            if (Synergies.CheckLokisHornTrigger(player)) then
                TriggerLokisHorn();
            end
        end
    end
    -- Eye Sore.
    if (isEyeSore) then
        local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EYE_SORE);
        local fire = fireRng:RandomInt(2);
        if (fire == 1) then
            rockParams.FlyingKnife = true;
            local count = fireRng:RandomInt(3) + 1;
            for i = 1, count do
                local angle = fireRng:RandomFloat() * 360;
                local vec = Vector.FromAngle(angle);
                Eika:ShootRock(player, Eika:SpawnRock(player), vec, MultishotParams.Default, rockParams)
            end
        end
    end

    -- Conjoined.
    if (player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY)) then
        
        local rockParams = RockParams:New();
        rockParams.IsLung = isLung;
        rockParams.FlyingKnife = false;
        rockParams.CanWiz = false;
        rockParams.Offset = dir * -10;
        for i = 1, 2 do
            local angle = i * 90 - 135;
            local vec = dir:Rotated(angle);

            -- SetRockFired(player, rock, vec, rockParams);
            Eika:ShootRock(player, Eika:SpawnRock(player), vec, MultishotParams.Default, rockParams)
        end
    end


    -- Extra Weapons.

    -- Ghost Pepper
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)) then
        local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GHOST_PEPPER);
        local fire = fireRng:RandomFloat();
        local rate = 1 / math.max(1, 12 - player.Luck);
        if (fire <= rate) then
            local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, player.Position,
                dir * player.ShotSpeed * 10, player):ToEffect();
            flame.CollisionDamage = player.Damage * 6;
            flame:SetTimeout(60);
        end
    end

    -- Bird's Eye
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE)) then
        local fireRng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BIRDS_EYE);
        local fire = fireRng:RandomFloat();
        local rate = 1 / math.max(1, 12 - player.Luck);
        if (fire <= rate) then
            local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, player.Position,
                dir * player.ShotSpeed * 10, player):ToEffect();
            flame.CollisionDamage = player.Damage * 4;
            flame:SetTimeout(300);
        end
    end

    THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
    Eika:PlayAnimation(player, "HideItem");
end

-- Drop the rock down.
function Eika:DropRock(player, rock, height)
    rock.Position = player.Position;
    rock.Velocity = RandomVector() * rng:RandomFloat();
    if (rock.Type == EntityType.ENTITY_TEAR) then
        rock.FallingSpeed = 0;
        rock.FallingAcceleration = 2;
        rock.Height = height;
    elseif (rock.Type == EntityType.ENTITY_BOMBDROP) then
        ReleaseBomb(rock, height);
    elseif (rock.Type == EntityType.ENTITY_EFFECT) then
        ReleaseEffect(rock, height);
    end
    rock.DepthOffset = 0;

    local rockData = Eika:GetRockData(rock, true);
    rockData.IsStacking = false;
    rockData.IsDropping = true;
end

-- Drop All rocks.
function Eika:DropAllRocks(player)
    local tempData = Eika:GetPlayerTempData(player, true);
    local stackedRocks = tempData.StackedRocks;
    local heightOffset = -45 * player.SpriteScale.Y;

    for i, rock in pairs(stackedRocks) do
        if (EntityExists(rock)) then
            heightOffset = heightOffset - rock.Size;
            SetRockHeight(rock, heightOffset);
            Eika:DropRock(player, rock, heightOffset);
        end
        table.remove(stackedRocks, i);
    end
end

local RockEffects = {};

function RockEffects.FireBrimstone(ent, player)
    local tear = ent:ToTear();
    for i = 0, 3 do
        local angle = i * 90;
        local laser = player:FireBrimstone(Vector.FromAngle(angle));
        laser.Parent = nil;
        laser.Position = ent.Position;
        laser:AddTearFlags(tear.TearFlags);
    end
end

function RockEffects.FallRocket(position)
    local target = Isaac.Spawn(1000, EffectVariant.TARGET, 0, position, Vector.Zero, player):ToEffect();
    local rocket = Isaac.Spawn(1000, EffectVariant.ROCKET, 0, position, Vector.Zero, player):ToEffect();
    rocket:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 1, 0, false, true);
    target:SetTimeout(10);
    rocket.Parent = target;
    rocket:SetTimeout(10);
end

function RockEffects:SpawnBladeRock(player)
    local parent = Isaac.Spawn(EntityType.ENTITY_EFFECT, Effects.PlaceHolder, PlaceHolderSubType.KnifeParent,
    player.Position + Vector(0, -16), Vector.Zero, player):ToEffect();
    -- local knife = Isaac.Spawn(EntityType.ENTITY_KNIFE, Knifes.BladeRock, 0, player.Position, Vector.Zero, player):ToKnife();
    local knife = player:FireKnife(parent, 0, false, 0, Knifes.BladeRock);
    knife.Parent = parent;
    parent.Child = knife;
    knife.Rotation = 90;
    knife.PositionOffset = Vector(0, 0);
    knife.MaxDistance = -10;

    local data = Eika:GetRockData(parent, true);
    data.BaseDamage = player.Damage / 2;

    Eika:SetRockFlags(player, parent);
    return parent;
end

function RockEffects.IsProbeRock(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or 
    player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X);
end

function RockEffects:IsBladeRock(rock)
    return rock.Type == EntityType.ENTITY_EFFECT and rock.Variant == Effects.PlaceHolder and rock.SubType == PlaceHolderSubType.KnifeParent;
end

-- Apply rock's effect, like Tech X, or Technology.
function Eika:ApplyRockEffect(player, ent, data)
    data = data or Eika:GetRockData(ent, true);
    local isTear = ent.Type == EntityType.ENTITY_TEAR;
    local room = THI.Game:GetRoom();
    local isInRoom = room:IsPositionInRoom (ent.Position, -40);
    -- TechX.
    if (data.TechX and isInRoom) then
        if (not EntityExists(data.TechXRing)) then
            local laser = player:FireTechXLaser(ent.Position, ent.Velocity, 60);
            laser.CollisionDamage = ent.CollisionDamage;
            laser.Parent = ent;
            data.TechXRing = laser;
        end

        local ring = data.TechXRing;
        ring.Position = ent.Position;
        ring.Velocity = ent.Velocity;
        ring.PositionOffset = ent.PositionOffset;
    else
        if (EntityExists(data.TechXRing)) then
            data.TechXRing:Remove();
            data.TechXRing = nil;
        end
    end
    if (data.Technology) then
        data.LaserCooldown = data.LaserCooldown - 1;
        while (data.LaserCooldown <= 0) do
            if (isInRoom) then
                for i = 0, 3 do
                    local angle = i * 90;
                    local laser = player:FireTechLaser(ent.Position, LaserOffset.LASER_BRIMSTONE_OFFSET,
                        Vector.FromAngle(angle), false);
                    laser.Parent = ent;
                    laser.CollisionDamage = ent.CollisionDamage;
                    laser.Position = ent.Position;
                end
            end
            data.LaserCooldown = data.LaserCooldown + 10;
        end
    end
    
    if (data.SpiritSword.Has) then
        local sfx = THI.SFXManager;
        if (not data.SpiritSword.Sword and isInRoom) then
            local parent = Isaac.Spawn(EntityType.ENTITY_EFFECT, Effects.PlaceHolder, PlaceHolderSubType.SwordParent, ent.Position, Vector.Zero, ent);

            local sword = Isaac.Spawn(EntityType.ENTITY_KNIFE, Knifes.RockSword, 0, ent.Position, Vector.Zero, ent):ToKnife();
            
            local sprite = sword:GetSprite();
            if (RockEffects.IsProbeRock(player)) then
                sprite:Load("gfx/008.011_tech sword.anm2", true);
                local swordData = Eika:GetRockSwordData(sword, true);
                swordData.IsTech = true;
            end
            
            sword.Parent = parent;
            parent.Child = sword;
            sword.CollisionDamage = (8 * ent.CollisionDamage + 10) / 2;
            sword.Scale = ent.Scale;

            sprite:Play("SpinRight");
            sfx:Play(SoundEffect.SOUND_SWORD_SPIN);
            data.SpiritSword.Sword = parent;
        end

        local swordParent = data.SpiritSword.Sword;
        if (swordParent and EntityExists(swordParent.Child)) then
            local sword = swordParent.Child:ToKnife();

            local offset = Vector(-30, 0);
            if (isTear) then
                offset.Y = ent:ToTear().Height;
            end
            swordParent.Position = ent.Position + offset
            sword.Size = 80 * ent.Scale;
            sword.SpriteScale = Vector(ent.Scale, ent.Scale);

            local sprite = sword:GetSprite();
            if (sprite:IsEventTriggered("SwingEnd")) then
                if (isInRoom) then
                    sprite:SetFrame(2);
                    sfx:Play(SoundEffect.SOUND_SWORD_SPIN);
                else
                    swordParent:Remove();
                    data.SpiritSword.Sword = nil;
                end
            end
        end
    end


    if (ent:IsDead()) then
        if (data.Brimstone) then
            RockEffects.FireBrimstone(ent, player);
        end

        if (data.EpicFetus) then
            if (not data.IsDropping) then
                RockEffects.FallRocket(ent.Position);
            end
        end
    end

    
    data.FireCooldown = math.min(data.FireCooldown - 1, player.MaxFireDelay + 1);
    while (data.FireCooldown <= 0) do
        if (isTear) then
            local tear = ent:ToTear();
            if (tear:HasTearFlags(LudovicoFlag)) then
                -- Ludovico.

                AddThrowIndex(player, (tear.Position - player.Position):Normalized());

                local lokisHorns = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS);

                local function TriggerLokisHorns()
                    for i = 1, 4 do
                        local angle = i * 90;
                        local vec = Vector.FromAngle(angle);
                        local rock = Eika:SpawnRock(player);
                        rock.Velocity = vec * player.ShotSpeed * 10;
                        rock.Position = tear.Position;
                    end
                end

                if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE)) then
                    if (Synergies.CheckMomsEyeTrigger(player)) then
                        if (lokisHorns) then
                            -- Ludovico + Mom's Eye + Loki's Horns
                            TriggerLokisHorns();
                        else
                            -- Ludovico + Mom's Eye
                            local vec = RandomVector();
                            local rock = Eika:SpawnRock(player);
                            rock.Velocity = vec * player.ShotSpeed * 10;
                            rock.Position = tear.Position;
                        end
                    end
                elseif (lokisHorns) then
                    -- Ludovico + Loki's Horns
                    if (Synergies.CheckLokisHornTrigger(player)) then
                        TriggerLokisHorns();
                    end
                end
            end
        end
        data.FireCooldown = data.FireCooldown + math.max(1, player.MaxFireDelay + 1);
    end
end


    
-- Set flags to the rock, like Brimstone or Tech X.
function Eika:SetRockFlags(player, rock)
    local data = Eika:GetRockData(rock, true);
    local isCSection = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION);
    local isTech = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY);
    local isTechX = player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X);
    local isSpiritSword = player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD);
    if (isCSection) then
        local tear = rock:ToTear();
        -- TODO TearVariant.Fetus;
        tear:ChangeVariant(50);
        -- TODO TearFlags.TEAR_FETUS;
        tear:AddTearFlags(FetusFlags.TEAR_FETUS | TearFlags.TEAR_SPECTRAL);
        local spr = tear:GetSprite();
        spr:ReplaceSpritesheet(0, "gfx/characters/costumes_eika/fetus_tears.png");
        spr:LoadGraphics();
        if (isSpiritSword) then
            tear:AddTearFlags(FetusFlags.TEAR_SWORD_FETUS);
        end
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
            -- TODO TearFlags.TEAR_KNIFE_FETUS;
            tear:AddTearFlags(FetusFlags.TEAR_KNIFE_FETUS);
        end
        if (isTechX) then
            tear:AddTearFlags(FetusFlags.TEAR_TECH_X_FETUS);
        end
        if (isTech) then
            tear:AddTearFlags(FetusFlags.TEAR_TECH_FETUS);
        end
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)) then
            -- TODO TearFlags.TEAR_DR_FETUS;
            tear:AddTearFlags(FetusFlags.TEAR_DR_FETUS);
        end
    else
        -- Technology
        data.Technology = isTech;
        -- TechX
        data.TechX = isTechX;
        -- Spirit Sword
        data.SpiritSword.Has = isSpiritSword

        
        if (rock.Type == EntityType.ENTITY_TEAR) then
            local tear = rock:ToTear();
            if (RockEffects.IsProbeRock(player)) then
                tear:ChangeVariant(RockVariants.Probe);
            end
        end
    end
    -- Brimstone.
    local isBrimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE);
    data.Brimstone = isBrimstone;
    -- Epic Fetus
    data.EpicFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS);

    if (isBrimstone) then
        rock.Color = RockColors.Brimstone;
    end
end

-- Spawn a rock.
function Eika:SpawnRock(player)
    -- local rock = player:FireTear(player.Position, Vector.Zero);

    local isTechX = player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X);
    local isTech = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY);
    local isMomsKnife = HasMomsKnife(player);
    local isBrimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE);
    local isDrFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS);
    local isCSection = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION);

    if (not isCSection) then
        
        if (isMomsKnife) then
            return RockEffects:SpawnBladeRock(player);
        end

        -- Dr. Fetus.
        if (isDrFetus) then
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR)) then
                -- Idle Rocket Effect.
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, Effects.PlaceHolder, PlaceHolderSubType.IdleRocket,
                    player.Position, Vector.Zero, player):ToEffect();
                effect.SpriteRotation = -90;
                effect:GetSprite():Play("Idle");
                return effect;
            else
                -- Normal Bomb.
                local bomb = player:FireBomb(player.Position, Vector(0, -1));
                local data = Eika:GetRockData(bomb, true);

                data.BaseDamage = bomb.ExplosionDamage;
                return bomb;
            end
        end

    end
    -- local rock = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, player.Position, Vector.Zero, player):ToTear();

    -- local params = player:GetTearHitParams (WeaponType.WEAPON_TEARS);
    -- local variant = params.TearVariant;
    -- local color = params.TearColor;
    local rock = player:FireTear(player.Position, Vector.Zero);

    local data = Eika:GetRockData(rock, true);

    Eika:SetRockFlags(player, rock);

    if (Tears:CanOverrideVariant(TearVariant.ROCK, rock.Variant)) then
        rock:ChangeVariant(TearVariant.ROCK);
    end
    -- rock.CollisionDamage = params.TearDamage;
    -- rock.Scale = params.TearScale;
    -- rock.TearFlags = params.TearFlags;
    -- rock.Height = params.TearHeight;

    local damage = rock.CollisionDamage;
    data.BaseDamage = damage;
    data.ScaleMultiplier = rock.Scale / Maths.GetTearScaleByDamage(damage);
    return rock;
end

function Eika:MakeBladeRockFly(player, rock, dir)
    local data = Eika:GetRockData(rock, true);
    local knifeData = data.Knife;
    rock.Position = GetKnifeParentPosition(player.Position);
    knifeData.FlyAway = true;
    knifeData.Direction = dir;
    knifeData.SideVelocity = dir:Rotated(-90):Normalized() * (rng:RandomFloat() * 2 - 1) * 10;
end

local function FindBladeKnifeHomingTarget(effect)
    local nearest = nil
    local pos = effect.Child.Position;
    for i, ent in pairs(Isaac.FindInRadius(pos, 80, EntityPartition.ENEMY)) do
        if (Detection.IsValidEnemy(ent)) then
            if (not nearest or ent.Position:Distance(pos) < nearest.Position:Distance(pos)) then
                nearest = ent;
            end
        end
    end
    return nearest;
end

--------------------
-- Animations
--------------------

-- Make player play an animation.
function Eika:PlayAnimation(player, anim)
    local tempData = Eika:GetPlayerTempData(player, true);
    tempData.Anim.Name = anim;
    tempData.Anim.Frame = 0;
end

-- Is player playing the animation?
function Eika:IsPlayingAnimation(player, anim)
    local tempData = Eika:GetPlayerTempData(player, false);
    if (not tempData) then
        return false;
    end
    return tempData.Anim.Name == anim;
end

-- Is player playing Pickup animation?
function Eika:IsPlayingPickupAnimation(player)
    local tempData = Eika:GetPlayerTempData(player, false);
    if (not tempData) then
        return false;
    end
    return tempData.Anim.Name == "PickupWalkDown" or tempData.Anim.Name == "PickupWalkUp" or tempData.Anim.Name ==
               "PickupWalkLeft" or tempData.Anim.Name == "PickupWalkRight";
end

-- End player's animation.
function Eika:EndAnimation(player)
    local tempData = Eika:GetPlayerTempData(player, true);
    tempData.Anim.Name = nil;
    local spr = player:GetSprite();
    local color = player:GetColor();
    color = Color(color.R, color.G, color.B, 1);
    spr.Color = color;
end

--------------------
-- Updates
--------------------

function Eika:CanUseLudovico(player)
    return not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS);
end

local function LudovicoUpdate(player)

    local tempData = Eika:GetPlayerTempData(player, true);

    local isBrimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE);
    local isKnife = HasMomsKnife(player);

    

        
    if (not EntityExists(tempData.LudoRock)) then


        local rock = nil;
        if (isKnife) then
            rock = RockEffects:SpawnBladeRock(player);
        else
            rock = player:FireTear(player.Position, Vector.Zero);
            rock.TearFlags = rock.TearFlags | LudovicoFlag;
        end
        tempData.LudoRock = rock;
        --rock:GetSprite():Load("gfx/002.042_rock tear.anm2", true);
    end

    local rock = tempData.LudoRock;

    local rockData = Eika:GetRockData(rock, true);
    local ludoData = rockData.Ludo;
    ludoData.Enabled = true;
    --rock:ChangeVariant(TearVariant.ROCK);
    local vec = GetShootingVector(player, rock.Position);
    local length = player.ShotSpeed * 10;
    local sum = rock.Velocity + vec * length;
    local speed = math.min(length, sum:Length());
    rock.Velocity = sum:Normalized() * speed;

    local canMultiShot = true;
    if (isBrimstone) then
        canMultiShot = false;
    end

    if (canMultiShot) then
        --------------------
        -- Multishot Synergies.
        --------------------

        local shotCount = 1;
        local hasBookworm = player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM);
        local isLung = HasLung(player) and not isKnife;
        shotCount = Synergies.GetNextMultishotCount(player, hasBookworm);
        if (isLung) then
            shotCount = Synergies.GetNextLungShotCount(player, shotCount, true);
        end

        local children = ludoData.Children;
        local extraCount = shotCount - 1;
        local childCount = #children;

        local angleInterval = 360 / childCount;
        for i, child in pairs(children) do
            if (not EntityExists(child)) then
                -- Clear non-existing sub tears from table.
                table.remove(children, i);
            elseif (isKnife ~= RockEffects:IsBladeRock(child)) then
                -- if knife or tear is not match with current mode, remove it.
                child:Remove();
                table.remove(children, i);
            else
                -- Make sub tears rotate.
                local angle = i * angleInterval + ludoData.SubTearAngle;
                child.Velocity = rock.Velocity + (rock.Position + Vector.FromAngle(angle) * 20 * rock.Scale - child.Position) / 3;
            end
        end


        -- if knife or tear is not match with current mode, remove it.
        if (isKnife ~= RockEffects:IsBladeRock(rock)) then
            for i, child in pairs(children) do
                if (EntityExists(child)) then
                    -- if knife or tear is not match with current mode, remove it.
                    child:Remove();
                end
                table.remove(children, i);
            end
            rock:Remove();
            return;
        end

        ludoData.SubTearAngle = ludoData.SubTearAngle + 3;

        -- Create or Remove sub tears.
        if (extraCount < childCount) then
            -- Need to remove sub tears.
            for i = childCount, extraCount + 1, -1 do
                local child = children[i];
                table.remove(children, i);
                child:Remove();
            end
        elseif (extraCount > childCount) then
            -- Need to create sub tears.
            for i = childCount, extraCount do
                local child;
                if (not isKnife) then
                    child = player:FireTear(rock.Position, Vector.Zero);
                    child.TearFlags = child.TearFlags | LudovicoFlag;
                    child.Parent = rock;
                    local childData = Eika:GetRockData(child, true);
                    
                    if (isLung) then
                        childData.Ludo.Scale = RandomRange(rng, 0.5 * rock.Scale, rock.Scale * 1.5)
                    else
                        childData.Ludo.Scale = 0.5;
                    end
                else
                    child = RockEffects:SpawnBladeRock(player);
                    child.Parent = rock;
                    
                    local childData = Eika:GetRockData(child, true);
                    childData.Ludo.Enabled = true;
                end
                table.insert(children, child);
            end
        end
    end
end

-- Fire all rocks on update.
local function FireRocksUpdate(player)

    local tempData = Eika:GetPlayerTempData(player, false);
    if (tempData and tempData.Stacking) then
        tempData.Stacking = false;
    end

    tempData.Firing = false;
    -- Shoot Rocks.
    local stackedRocks = tempData.StackedRocks;
    if (#stackedRocks > 0) then
        tempData.ThrowCooldown = tempData.ThrowCooldown - 1;
        while (tempData.ThrowCooldown <= 0) do
            local rock = stackedRocks[1];
            if (EntityExists(rock)) then
                Eika:ThrowRock(player, rock);

                table.remove(stackedRocks, 1);
            end
            tempData.ThrowCooldown = tempData.ThrowCooldown + MaxFireCooldown;
        end
        tempData.Firing = true;
    end
end

-- Update if player is holding shooting keys.
local function ShootingUpdate(player)
    local tempData = Eika:GetPlayerTempData(player, true);

    -- Stack Rocks.
    local stackedRocks = tempData.StackedRocks;
    while (tempData.FireDelay <= 0) do
        local rock = Eika:SpawnRock(player);
        -- Normal, Stack Rocks.
        table.insert(stackedRocks, 1, rock);
        local rockData = Eika:GetRockData(rock, true);
        rockData.IsStacking = true;
        tempData.Stacking = true;
        tempData.FireDelay = tempData.FireDelay + math.max(1, player.MaxFireDelay + 1);
    end

    local hasTarget = GetMarkedTarget(player) ~= nil;
    
    -- Automatically throw rocks if has soy milk or marked target.
    if (Eika:IsThrowOnShoot(player) or hasTarget) then
        FireRocksUpdate(player);
    end

    -- Set ThrowCooldown to 0.
    tempData.ThrowCooldown = 0;
end

-- Update if player is not holding shooting keys.
local function NotShootingUpdate(player)
    FireRocksUpdate(player)
end

-- Update Stacked Rocks.
local function UpdateStackedRocks(player)
    local tempData = Eika:GetPlayerTempData(player, true);
    local stackedRocks = tempData.StackedRocks;
    local heightOffset = -45 * player.SpriteScale.Y;

    local limit = Eika:GetMaxStackCount(player);
    for i = #stackedRocks, 1, -1 do
        local rock = stackedRocks[i];
        if (EntityExists(rock)) then

            rock.Position = player.Position
            rock.Velocity = player.Velocity;
            SetRockHeight(rock, heightOffset);
            heightOffset = heightOffset - rock.Size;
            local DamageMultiplier = 1;
            if (HasChocolateMilk(player)) then
                local maxDamageTime = 30;
                DamageMultiplier = DamageMultiplier * math.min(1, rock.FrameCount / maxDamageTime) * 4;
            end
            local outOfLimit = i > limit;

            local rockData = Eika:GetRockData(rock, true);
            -- Make Rocks Suspend.
            if (rock.Type == EntityType.ENTITY_TEAR) then
                -- Tear Rock.

                -- rock.FallingSpeed = 0;
                if (not outOfLimit) then
                    -- Make Rocks Suspend.
                    rock.WaitFrames = 2;
                    rock.CollisionDamage = rockData.BaseDamage * DamageMultiplier;
                    rock.Scale = Maths.GetTearScaleByDamage(rock.CollisionDamage) * rockData.ScaleMultiplier;
                else
                    rock.Height = heightOffset;
                end
            elseif (rock.Type == EntityType.ENTITY_BOMBDROP) then
                -- Bomb Rock.
                if (not outOfLimit) then
                    rock.ExplosionDamage = rockData.BaseDamage * DamageMultiplier;
                    rock.SpriteScale = Consts.Vectors.One * Maths.GetTearScaleByDamage(DamageMultiplier * 3.5) * rockData.ScaleMultiplier;
                end
            elseif (rock.Type == EntityType.ENTITY_KNIFE) then
                -- Knife Rock.
                if (not outOfLimit) then
                    rock.CollisionDamage = rockData.BaseDamage * DamageMultiplier;
                    rock.Scale = Maths.GetTearScaleByDamage(rock.CollisionDamage) * rockData.ScaleMultiplier;
                end
            elseif (rock.Type == EntityType.ENTITY_EFFECT) then
                -- Effect Rock.
                if (not outOfLimit) then
                    if (rock.Variant == Effects.PlaceHolder and rock.SubType == PlaceHolderSubType.KnifeParent) then
                        rock.Position = GetKnifeParentPosition(rock.Position);
                        heightOffset = heightOffset - 24;
                    else
                        rock.CollisionDamage = rockData.BaseDamage * DamageMultiplier;
                        rock.SpriteScale = Vector(1, 1) * Maths.GetTearScaleByDamage(rock.CollisionDamage);
                    end
                end
            end
            if (outOfLimit) then
                Eika:DropRock(player, rock, heightOffset);
                table.remove(stackedRocks, i);
            end
        else
            table.remove(stackedRocks, i);
        end
    end
end

-- Update if player has no ludovico.
local function NormalWeaponUpdate(player)
    local tempData = Eika:GetPlayerTempData(player, true);
    local playingExtraAnimation = not player:IsExtraAnimationFinished();

    if (not playingExtraAnimation) then
        local dir = GetShootingVector(player);
        local shoot = Inputs.IsPressingShoot(player);

        -- Update Marked Target.
        if (HasMarked(player)) then
            if (not GetMarkedTarget(player)) then
                for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
                    if (CompareEntity(ent.SpawnerEntity, player)) then
                        tempData.markedTarget = ent:ToEffect();
                        break
                    end
                end
            end
        end

        if (HasOccultEye(player)) then
            if (not GetMarkedTarget(player)) then
                for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.OCCULT_TARGET)) do
                    if (CompareEntity(ent.SpawnerEntity, player)) then
                        tempData.markedTarget = ent:ToEffect();
                        break
                    end
                end
            end
        end

        if (GetMarkedTarget(player)) then
            shoot = true;
        end

        if (shoot) then
            ShootingUpdate(player);

            tempData.RecentShootVector = tempData.LastShootVector;
            tempData.LastShootVector = dir:Normalized();
        else
            NotShootingUpdate(player);
        end
    else
        Eika:DropAllRocks(player);
        tempData.Stacking = false;
    end

    UpdateStackedRocks(player);
    
    local stackedRocks = tempData.StackedRocks;
    -- Update Animation.
    if (#stackedRocks > 0) then
        if (not Eika:IsPlayingAnimation(player, "LiftItem") and not Eika:IsPlayingPickupAnimation(player)) then
            Eika:PlayAnimation(player, "LiftItem");
        end
    else
        if (Eika:IsPlayingAnimation(player, "LiftItem") or Eika:IsPlayingPickupAnimation(player)) then
            Eika:EndAnimation(player);
        end
    end

    -- Update Firing Knifes.
    if (tempData.FiringKnifeCount > 0) then
        local rock = Eika:SpawnRock(player);
        Eika:MakeBladeRockFly(player, rock, tempData.FiringKnifeDirection);
        tempData.FiringKnifeCount = tempData.FiringKnifeCount - 1;
    end

end

----------------
-- Events
----------------
function Eika:PostPlayerInit(player)
    if (player:GetPlayerType() == Eika.Type) then
        player:AddNullCostume(Costume);
        player:AddTrinket(62);
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Eika.PostPlayerInit, 0)

-- function Eika:PostPlayerUpdate(player)
--     if (player:GetPlayerType() == Eika.Type) then

--         local tempData = Eika:GetPlayerTempData(player, false);
--         if (Eika:CanUseLudovico(player) and
--             player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then
--             -- Ludovico
--             LudovicoUpdate(player)
--         else
--             -- Normal

--             -- Remove Ludo Tear.
--             if (tempData and EntityExists(tempData.LudoRock)) then

--                 local rock = tempData.LudoRock;
--                 -- Clear Children.
--                 local ludoData = Eika:GetRockData(rock).Ludo;
--                 local children = ludoData.Children;
--                 for i = #children, 1, -1 do
--                     local child = children[i];
--                     if (EntityExists(child)) then
--                         child:Remove();
--                     end
--                     table.remove(children, i);
--                 end
--                 rock:Remove();
--                 tempData.LudoRock = nil;
--             end

--             NormalWeaponUpdate(player);
--         end


--         if (tempData and tempData.CursedEyeTeleport) then

--             local game = THI.Game;
--             local level = THI.Game:GetLevel();
--             local seed = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CURSED_EYE):Next();
--             local index = level:GetRandomRoomIndex(false, seed);
--             game:StartRoomTransition(index, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1);
--             tempData.CursedEyeTeleport = false;
--         end
--     end
-- end
-- Eika:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Eika.PostPlayerUpdate)

function Eika:PostPlayerTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer();
    if (player:GetPlayerType() == Eika.Type) then

        if (HasCursedEye(player)) then
            local tempData = Eika:GetPlayerTempData(player, false);
            if (tempData and tempData.Stacking) then
                tempData.CursedEyeTeleport = true;
            end
        end
    end
end
Eika:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, Eika.PostPlayerTakeDamage, EntityType.ENTITY_PLAYER);

function Eika:PostPlayerEffect(player)
    if (player:GetPlayerType() == Eika.Type) then

        local tempData = Eika:GetPlayerTempData(player, true);

        -- Weapon Update
        if (Eika:CanUseLudovico(player) and
            player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then
            -- Ludovico
            LudovicoUpdate(player)
        else
            -- Normal

            -- Remove Ludo Tear.
            if (tempData and EntityExists(tempData.LudoRock)) then

                local rock = tempData.LudoRock;
                -- Clear Children.
                local ludoData = Eika:GetRockData(rock).Ludo;
                local children = ludoData.Children;
                for i = #children, 1, -1 do
                    local child = children[i];
                    if (EntityExists(child)) then
                        child:Remove();
                    end
                    table.remove(children, i);
                end
                rock:Remove();
                tempData.LudoRock = nil;
            end

            NormalWeaponUpdate(player);
        end
    

        if (tempData.FireDelay > 0) then
            tempData.FireDelay = math.min(tempData.FireDelay - 1, player.MaxFireDelay + 1);
        end


        local hasTech2 = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2);
        if (Inputs.IsPressingShoot(player)) then
            local dir = GetShootingVector(player, player.Position);
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5)) then
                if (player.FrameCount % 2 == 0) then
                    if (Synergies.CheckTechDot5Trigger(player)) then
                        local laser = player:FireTechLaser (player.Position, LaserOffset.LASER_TECH5_OFFSET, dir, false);
                        laser.CollisionDamage = player.Damage;
                    end
                end
            end

            if (hasTech2) then
                if (not EntityExists(tempData.Tech2Laser)) then
                    local laser = EntityLaser.ShootAngle(2, player.Position, dir:GetAngleDegrees(), 2, dir:Rotated(90) * 10 + Vector(0, -20 * player.SpriteScale.Y), player)
                    laser.Parent = player;
                    tempData.Tech2Laser = laser;
                end

                
                local params = player:GetTearHitParams ( WeaponType.WEAPON_LASER, 0.13);

                local laser = tempData.Tech2Laser;
                laser.Velocity = laser.Parent.Position + laser.Parent.Velocity - laser.Position;
                laser.Color = params.TearColor;
                laser.CollisionDamage = params.TearDamage;
                laser.TearFlags = params.TearFlags;
                laser.Angle = dir:GetAngleDegrees();
                laser.Timeout = 2;
            end

            if (player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_TOOTH)) then
                if (not EntityExists(tempData.DeadToothRing)) then
                    local ring = Isaac.Spawn(1000,106,0,player.Position,Vector.Zero,player);
                    ring.Parent = player;
                    tempData.DeadToothRing = ring;
                end
            end
        end

        -- Anim.
        if (player:IsExtraAnimationFinished()) then

            tempData.Anim.Frame = tempData.Anim.Frame + 1;

            if (Eika:IsPlayingAnimation(player, "HideItem")) then
                if (tempData.Anim.Frame >= 8) then
                    Eika:EndAnimation(player);
                end
            elseif (Eika:IsPlayingAnimation(player, "LiftItem")) then
                if (tempData.Anim.Frame >= 9) then
                    Eika:PlayAnimation(player, "PickupWalkDown");
                end
            end

            if (Eika:IsPlayingPickupAnimation(player)) then
                local direction = player:GetMovementDirection();
                -- if (dir:Length() < 0.1) then
                if (direction == Direction.NO_DIRECTION) then
                    tempData.Anim.Name = "PickupWalkDown"
                    tempData.Anim.Frame = 0;
                else
                    -- local angle = dir:GetAngleDegrees();
                    local suffix = nil;
                    -- local direction = Maths.GetDirectionByAngle(angle);
                    if (direction == Direction.UP) then
                        suffix = "Up";
                    elseif (direction == Direction.LEFT) then
                        suffix = "Left";
                    elseif (direction == Direction.RIGHT) then
                        suffix = "Right";
                    else
                        suffix = "Down";
                    end
                    local anim = "PickupWalk" .. suffix;
                    if (tempData.Anim.Name ~= anim) then
                        tempData.Anim.Name = anim;
                        tempData.Anim.Frame = 0;
                    end

                    if (tempData.Anim.Frame > 20) then
                        tempData.Anim.Frame = 0;
                    end
                end
            end
        else
            if (tempData.Anim.Name) then
                Eika:EndAnimation(player);
            end
        end

        -- Cursed Eye.
        if (tempData.CursedEyeTeleport) then
    
            local game = THI.Game;
            local level = THI.Game:GetLevel();
            local seed = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CURSED_EYE):Next();
            local index = level:GetRandomRoomIndex(false, seed);
            game:StartRoomTransition(index, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1);
            tempData.CursedEyeTeleport = false;
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Eika.PostPlayerEffect)

function Eika:PostFamiliarUpdate(familiar)
    local player = familiar.Player;
    if (player and player:GetPlayerType() == Eika.Type) then
    end
end
Eika:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Eika.PostFamiliarUpdate)

function Eika:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == Eika.Type) then
        if (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.2;
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 1.25);
        elseif (cache == CacheFlag.CACHE_FIREDELAY) then
            
            Stats:AddTearsModifier(player, function(tears)
                tears = tears * 0.6;

                -- Mom's Knife.
                if (HasMomsKnife(player)) then
                    tears = tears * 0.5;
                    if (HasChocolateMilk(player)) then
                        tears = tears * 1.25
                    end
                end

                -- Cursed Eye.
                if (HasCursedEye(player)) then
                    tears = tears * 2;
                end
                return tears;
            end)

        elseif (cache == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + 1;
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Eika.OnEvaluateCache)

function Eika:InputAction(entity, hook, action)
    if (entity and entity.Type == EntityType.ENTITY_PLAYER) then
        local player = entity:ToPlayer();
        if (player:GetPlayerType() == Eika.Type) then
            local tempData = Eika:GetPlayerTempData(player, false);
            if (tempData and tempData.Stacking) then
                local item = 0;
                if (action == ButtonAction.ACTION_ITEM or action == ButtonAction.ACTION_PILLCARD) then
                    return Inputs.DisabledInput(hook);
                end
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_INPUT_ACTION, Eika.InputAction);

function Eika:PostPlayerRender(player, offset)
    if (player:GetPlayerType() == Eika.Type) then
        local spr = player:GetSprite();
        local color = player:GetColor();
        color = Color(color.R, color.G, color.B, 1);
        spr.Color = color;

        local hasMegaMush = player:GetEffects():HasCollectibleEffect(625);

        if (player:IsExtraAnimationFinished() and not hasMegaMush) then
            local tempData = Eika:GetPlayerTempData(player, false);

            if (tempData and tempData.Anim.Name) then

                if (spr:GetAnimation() ~= tempData.Anim.Name) then
                    spr:Play(tempData.Anim.Name);
                end
                spr:SetFrame(tempData.Anim.Frame);
                spr:RemoveOverlay();
                local game = THI.Game;
                local pos = Screen.GetEntityOffsetedRenderPosition(player, offset);
                spr:Render(pos, Vector.Zero, Vector.Zero);
                color.A = 0;
                spr.Color = color;
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Eika.PostPlayerRender)

-- Tears
function Eika:PostTearUpdate(tear)
    if (tear.Variant == RockVariants.Probe) then
        local sprite = tear:GetSprite();
        sprite:Play("Rotate" .. Tears.GetTearAnimationIndexByScale(tear.Scale, Tears.Animation.ROTATE));
    end

    local player = GetSpawnerPlayer(tear);
    if (player) then
        local data = Eika:GetRockData(tear, false);
        if (data) then
            if (not data.IsStacking) then
                -- TechX.
                Eika:ApplyRockEffect(player, tear);
            end
        end

        -- Change the variant of Ludovico tear
        if (tear:HasTearFlags(LudovicoFlag)) then
            if (player:GetPlayerType() == Eika.Type) then
                Eika:SetRockFlags(player, tear);
                if (Synergies.CanRockChangeVariant(TearVariant.ROCK, tear.Variant)) then
                    tear:ChangeVariant(TearVariant.ROCK);
                end

                local sprite = tear:GetSprite();
                if (tear.Variant == TearVariant.ROCK) then
                    sprite:SetFrame(tear.FrameCount % 16);
                elseif (tear.Variant == RockVariants.Probe) then
                    sprite:SetFrame("Rotate" .. Tears.GetTearAnimationIndexByScale(tear.Scale, Tears.Animation.Rotate), tear.FrameCount % 4);
                end
                local scale = 1;
                if (data) then
                    scale = data.Ludo.Scale;
                end
                tear.Scale = Maths.GetTearScaleByDamage(player.Damage) * 2 * scale;
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Eika.PostTearUpdate)

-- function Eika:PreTearCollision(tear, other, low)
--     if (low and tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
--         local player = GetSpawnerPlayer(tear);
--         if (player) then
--             local data = Eika:GetRockData(tear, false);
--             if (data) then
--                 if (not data.IsStacking) then
                    
--                     if (data.Brimstone) then
--                         RockEffects.FireBrimstone(tear, player);
--                     end

--                     if (data.EpicFetus) then
--                         if (not data.IsDropping) then
--                             RockEffects.FallRocket(tear.Position);
--                         end
--                     end
--                 end
--             end
--         end
--     end
-- end
-- Eika:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, Eika.PreTearCollision)


-- function Eika:PostEntityTakeDamage(tookDamage, amount, flags, source, countdown)
--     if (not source) then
--         return false;
--     end
--     local ent = source.Entity;
--     if (ent and ent.Type == EntityType.ENTITY_TEAR) then
--         local tear = ent:ToTear();
--         --if (tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
--             local data = Eika:GetRockData(tear, false);
--             if (data) then
--                 local player = GetSpawnerPlayer(tear);
--                 if (player) then
--                     if (not data.IsStacking) then
                        
--                         if (data.Brimstone) then
--                             RockEffects.FireBrimstone(tear, player);
--                         end

--                         if (data.EpicFetus) then
--                             if (not data.IsDropping) then
--                                 RockEffects.FallRocket(tear.Position);
--                             end
--                         end
--                     end
--                 end
--             end
--         --end
--     end
-- end
-- Eika:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, Eika.PostEntityTakeDamage);

function Eika:PreTearCollision(tear, other, low)
    --if (tear:HasTearFlags(TearFlags.TEAR_PIERCING)) then
    local data = Eika:GetRockData(tear, false);
    if (data and other:IsEnemy()) then
        local player = GetSpawnerPlayer(tear);
        if (player) then
            
            local notCollided = true;
            for i, enemy in pairs(data.CollidedEnemies) do
                if (CompareEntity(enemy, other)) then
                    notCollided = false;
                    break;
                end
            end

            if (notCollided and not data.IsStacking) then
                
                if (data.Brimstone) then
                    RockEffects.FireBrimstone(tear, player);
                end

                if (data.EpicFetus) then
                    if (not data.IsDropping) then
                        RockEffects.FallRocket(tear.Position);
                    end
                end

                table.insert(data.CollidedEnemies, other);
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, Eika.PreTearCollision);


function Eika:PostKnifeInit(knife)
    if (knife.Variant == Knifes.BladeRock) then
        local sprite = knife:GetSprite();
        sprite:Play("Idle");
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, Eika.PostKnifeInit)

function Eika:PostEffectUpdate(effect)
    local player = GetSpawnerPlayer(effect);
    if (player) then
        local data = Eika:GetRockData(effect, false);
        if (data) then
            if (data.Ludo.Enabled) then
                
                if (EntityExists(effect.Child)) then
                    local child = effect.Child:ToKnife();
                    Eika:ApplyRockEffect(player, child, data);
                end
                Eika:SetRockFlags(player, effect);
                local childPosition = GetKnifeChildPosition(effect.Position);
                childPosition = THI.Game:GetRoom():GetClampedPosition(childPosition, 0);
                effect.Position = GetKnifeParentPosition(childPosition);
                effect.Velocity = effect.Velocity * 0.4;
            elseif (not data.IsStacking) then
                if (effect.SubType == PlaceHolderSubType.KnifeParent) then

                    if (EntityExists(effect.Child)) then
                        local child = effect.Child:ToKnife();
                        local knifeData = data.Knife;
    
                        Eika:ApplyRockEffect(player, child, data);
    
                        if (data.TechXRing) then
                            data.TechXRing.Velocity = effect.Velocity;
                        end
    
                        local timeMultiplier = 1;
                        if (not data.IsDropping) then
                            if (knifeData.FlyAway) then
                                -- Fly Away.
                                effect.Velocity = knifeData.Direction * 20 + knifeData.SideVelocity;
                                knifeData.SideVelocity = knifeData.SideVelocity * 0.8;
                            elseif (knifeData.Fired) then
                                if (child:HasTearFlags(TearFlags.TEAR_HOMING)) then
                                    local homingTarget = FindBladeKnifeHomingTarget(effect);
                                    effect.Target = homingTarget;
                                end
    
                                knifeData.FireTime = knifeData.FireTime + 1;
                                local fireTime = knifeData.FireTime;
                                local maxFireTime = knifeData.MaxFireTime;
                                local startPos = knifeData.StartPos;
                                local targetPos = knifeData.TargetPos;
                                local velocity = effect.Velocity;
                                local pos = effect.Position;
    
                                if (child:HasTearFlags(TearFlags.TEAR_ORBIT)) then
                                    timeMultiplier = timeMultiplier * 4;
                                end
    
                                maxFireTime = maxFireTime * timeMultiplier;
    
                                if (fireTime <= maxFireTime) then
    
                                    -- v = ?
                                    -- t = maxFireTime;
                                    -- s = totalLength;
    
                                    -- s = vt - at^2/2
                                    -- v = s/t - at/2
                                    -- a = -v / t;
                                    -- v = 2s/t
    
                                    local percent = fireTime / maxFireTime;
                                    -- Tiny Planet
                                    if (child:HasTearFlags(TearFlags.TEAR_ORBIT)) then
                                        local dir = (targetPos - startPos):Normalized();
                                        local totalLength = (targetPos - startPos):Length() / 3;
                                        local initSpeed = 1.6 * totalLength / maxFireTime;
                                        local accel = -initSpeed / maxFireTime;
                                        local speed = initSpeed + accel * 0.8 * fireTime;
                                        local currentLength = Maths.EaseOut(percent) * totalLength;
    
                                        local angle = currentLength * 15;
    
                                        local playerPos = GetKnifeParentPosition(player.Position + player.Velocity);
                                        next = playerPos + (targetPos - startPos):Rotated(angle):Normalized() *
                                                   currentLength * speed;
    
                                        if (effect.Target) then
                                            local distance = effect.Target.Position - child.Position;
                                            next = Maths.LerpVector(next, effect.Target.Position,
                                                1 - distance:Length() / 120);
                                        end
    
                                        velocity = next - pos;
                                    else
                                        local dir = (targetPos - startPos):Normalized();
                                        -- local offsetLength = -4*(percent - 0.5) ^ 2 + 1
                                        local offsetLength = (2 * percent - 1) * 10;
                                        local offset = dir:Rotated(-90) * offsetLength;
                                        if (effect.Target) then
                                            local distance = effect.Target.Position - child.Position;
                                            offset = offset + distance * 50 / distance:Length();
                                        end
    
                                        local totalLength = (targetPos - startPos):Length();
                                        local initSpeed = 1.6 * totalLength / maxFireTime;
                                        local accel = -initSpeed / maxFireTime;
                                        local speed = initSpeed + accel * 0.8 * fireTime;
                                        local next = pos + dir * speed;
                                        next = next + offset;
    
                                        velocity = (next - pos):Normalized() * speed;
                                    end
                                    knifeData.Direction = velocity:Normalized();
                                else
                                    local target = GetKnifeParentPosition(player.Position);
                                    local target2Current = target - pos;
    
                                    local angleDiff = Maths.GetIncludedAngle(target2Current, velocity);
                                    local dir = knifeData.Direction;
                                    local angle = dir:GetAngleDegrees() - angleDiff * 0.5;
                                    dir = Vector.FromAngle(angle);
                                    local length = velocity:Length() + 3;
                                    velocity = dir:Normalized() * length;
    
                                    knifeData.Direction = dir;
    
                                    if (pos:Distance(target) <= velocity:Length()) then
                                        effect:Remove();
                                    end
                                end
    
                                effect.Velocity = velocity;
    
                                local distanceMultiplier = (pos - player.Position):Length() /
                                                               (targetPos - startPos):Length();
                                -- Strange Attractor
                                if (child:HasTearFlags(TearFlags.TEAR_ATTRACTOR)) then
                                    local radius = 120;
                                    for i, ent in pairs(Isaac.FindInRadius(child.Position, 120,
                                        EntityPartition.ENEMY | EntityPartition.PICKUP)) do
                                        local distance = child.Position - ent.Position;
                                        local length = radius - distance:Length();
                                        local speed = distanceMultiplier * length * 0.1;
                                        ent:AddVelocity(distance:Normalized() * speed)
                                    end
                                end
    
                                local damageMultiplier = 1 + distanceMultiplier * 2;
    
                                if (child:HasTearFlags(TearFlags.TEAR_ORBIT)) then
                                    damageMultiplier = 6;
                                end
                                if (child:HasTearFlags(TearFlags.TEAR_SHRINK)) then
                                    damageMultiplier = damageMultiplier * 3;
                                end
    
                                child.CollisionDamage = data.BaseDamage * damageMultiplier;
    
                            end
                        else
                            -- Dropping.
                            child.PositionOffset = child.PositionOffset + Vector(0, data.FallingSpeed);
                            data.FallingSpeed = data.FallingSpeed + 2;
                            if (child.PositionOffset.Y >= -14) then
                                effect:Remove();
                                -- break
                                THI.SFXManager:Play(SoundEffect.SOUND_STONE_IMPACT, 1, 0, false, 0.8);
                                color = child:GetColor();
                                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_POOF, 0,
                                    child.Position, Vector.Zero, child);
                                poof:SetColor(color, -1, 0, false, false);
                                poof.SpriteScale = poof.SpriteScale * child.Scale;
                                for i = 1, child.Scale ^ 2 do
                                    local tooth = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0,
                                        child.Position, RandomVector() * rng:RandomFloat() * 3, child);
                                    tooth:SetColor(color, -1, 0, false, false);
                                end
                            end
                        end
    
                        if (child:HasTearFlags(TearFlags.TEAR_SHIELDED)) then
                            for i, ent in pairs(Isaac.FindInRadius(child.Position, child.Size, EntityPartition.BULLET)) do
                                ent:Die();
                            end
                        end
    
                        knifeData.Timeout = knifeData.Timeout - 1 / timeMultiplier;
                        if (knifeData.Timeout <= 0) then
                            effect:Remove();
                        end
                    else
                        effect:Remove();
                    end
                end
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Eika.PostEffectUpdate);


function Eika:SwordUpdate(knife)
    if (knife.Variant == Knifes.RockSword) then
        local radius = knife.Size - 20;
        local swordData = Eika:GetRockSwordData(knife, true);
        if (swordData.IsTech) then
            for i, other in pairs(Isaac.FindByType(9)) do
                local distance = other.Position - knife.Position;
                if (distance:Length() <= radius) then
                    local hit = false;
                    for i, ent in pairs(swordData.Hit) do
                        if (CompareEntity(ent, other)) then
                            hit = true;
                            break;
                        end
                    end
                    if (not hit) then
                        other:AddVelocity(distance:Normalized() * 20);
                        table.insert(swordData.Hit, other);
                    end
                end
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, Eika.SwordUpdate)

function Eika:PreKnifeCollision(knife, collider, low)
    if (knife.Variant == Knifes.RockSword) then
        local swordData = Eika:GetRockSwordData(knife, true);
        for i, ent in pairs(swordData.Hit) do
            if (CompareEntity(ent, collider)) then
                return true;
            end
        end
        table.insert(swordData.Hit, collider);
        return nil;
    end
end
Eika:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, Eika.PreKnifeCollision)

function Eika:DamageFromKnife(tookDamage, amount, flags, source, countdown)
    if (not source) then
        return false;
    end
    local ent = source.Entity;
    if (ent and ent.Type == EntityType.ENTITY_KNIFE and ent.Variant == Knifes.RockSword) then
        THI.SFXManager:Play(SoundEffect.SOUND_MEATY_DEATHS);
        local dir = tookDamage.Position - ent.Position;
        local length = 20;
        tookDamage:AddVelocity(dir:Normalized() * length);
    end
end
Eika:AddCustomCallback(CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, Eika.DamageFromKnife);

function Eika:PostBombUpdate(bomb)
    local data = Eika:GetRockData(bomb, false);
    if (data) then
        if (data.IsStacking) then
            bomb:SetExplosionCountdown(61 - bomb.FrameCount % 8);
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Eika.PostBombUpdate)

function Eika:PostTearRemove(ent)
    local tear = ent:ToTear();

    local data = Eika:GetRockData(tear, false);
    if (data) then

        if (data.TechXRing) then
            data.TechXRing.Timeout = 1;
            data.TechXRing.Velocity = Vector.Zero;
        end

        local sword = data.SpiritSword.Sword;
        if (EntityExists(sword)) then
            sword:Remove();
        end
    end

    if (tear.Variant == RockVariants.Probe) then

        THI.SFXManager:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 0, false, 1.5);
        local color = Color(1.5, 1.5, 1.5, 1, 0, 0, 0);
        color = color * tear:GetColor();
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_POOF, 0, tear.Position, Vector.Zero, tear);
        poof:SetColor(color, -1, 0, false, false);
        poof.SpriteScale = poof.SpriteScale * tear.Scale;
        for i = 1, tear.Scale ^ 2 do
            local tooth = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, tear.Position,
                RandomVector() * rng:RandomFloat() * 3, tear);
            tooth:SetColor(color, -1, 0, false, false);
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Eika.PostTearRemove, EntityType.ENTITY_TEAR);

function Eika:PostEffectRemove(ent)

    if (ent.Variant == Effects.PlaceHolder) then
        local data = Eika:GetRockData(ent, false);
        if (data) then
            if (data.TechXRing) then
                data.TechXRing:Remove();
            end
            local sword = data.SpiritSword.Sword;
            if (EntityExists(sword)) then
                sword:Remove();
            end
        end
    end
end
Eika:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Eika.PostEffectRemove, EntityType.ENTITY_EFFECT);

return Eika;
