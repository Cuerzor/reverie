local EntityTags = THI.Shared.EntityTags;
local Tears = CuerLib.Tears;
local Stats = CuerLib.Stats;
local Entities = CuerLib.Entities;
local Inputs = CuerLib.Inputs;
local CompareEntity = Entities.CompareEntity;
local Players = CuerLib.Players;
local ItemPools = CuerLib.ItemPools;
local Collectibles = CuerLib.Collectibles;
local Math = CuerLib.Math;
local Stages = CuerLib.Stages;
local Seija = ModPlayer("Seija", false, "SEIJA");
Seija.CacheItems = {
    --[CollectibleType.COLLECTIBLE_OUIJA_BOARD] = CacheFlag.CACHE_FIREDELAY,

    [CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = CacheFlag.CACHE_FIREDELAY,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = CacheFlag.CACHE_SPEED,
    [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG,
    [CollectibleType.COLLECTIBLE_IPECAC] = CacheFlag.CACHE_TEARFLAG,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = CacheFlag.CACHE_FIREDELAY,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK,
    [CollectibleType.COLLECTIBLE_STOP_WATCH] = CacheFlag.CACHE_SPEED,
    [CollectibleType.COLLECTIBLE_PROPTOSIS] = CacheFlag.CACHE_SHOTSPEED,
    [CollectibleType.COLLECTIBLE_INCUBUS] = CacheFlag.CACHE_DAMAGE,
    [CollectibleType.COLLECTIBLE_TECH_X] = CacheFlag.CACHE_SHOTSPEED,
    [CollectibleType.COLLECTIBLE_TWISTED_PAIR] = CacheFlag.CACHE_DAMAGE,
    [CollectibleType.COLLECTIBLE_GHOST_PEPPER] = CacheFlag.CACHE_LUCK,

    
    [CollectibleType.COLLECTIBLE_BIRTHRIGHT] = CacheFlag.CACHE_ALL
}
Seija.DipSubTypes = {
    0, --normal
    1,--red
    2,--corny
    3,--golden
    4,--rainbow
    5,--black
    6,--holy
    12,--stone
    13,--flaming
    14,--poison
    20--brownie
}
Seija.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_seija.anm2");
Seija.Sprite = "gfx/reverie/seija.anm2"
Seija.SpriteFlying = "gfx/reverie/seija_flying.anm2"

Seija.ShurikenVariant = Isaac.GetEntityVariantByName("Shuriken Tear");
Tears:RegisterModTearFlag("SHURIKEN");
Tears:RegisterModTearFlag("SHOCKS_ENEMY");
Tears:RegisterModTearFlag("ReverieSpiderWeb");

local ufoParams = ProjectileParams();
ufoParams.Variant = ProjectileVariant.PROJECTILE_HUSH;
ufoParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE;

local FoodItems = Collectibles.FindCollectibles(function(id, config) 
    return config:HasTags(ItemConfig.TAG_FOOD) 
end)

local function GetGlobalTempData(create)
    return Seija:GetTempGlobalData(create, function()
        return {
            AcidRainTimeout = 0
        }
    end)
end

local function GetPlayerData(player, create)
    return Seija:GetData(player, create, function()
        return {
            DataMinerTimes = 0,
            VoidTimes = 0,
            AbyssTimes = 0,
            ScooperDamage = 0,
            RockBottomRecord = nil
        }
    end)
end
local function GetPlayerTempData(player, create)
    return Seija:GetTempData(player, create, function()
        return {
            CostumeState = 0,
            SpriteState = 0,
            LingerBeanTime = 0,
            WasSeija = false,
            SeijaClicker = false,
            ModZeroCount = 0,
            ModFourCount = 0,
            UpdateModItems = false,
            VoidAbyssLifting = false,
        }
    end)
end
local function GetNPCTempData(npc, create)
    return Seija:GetTempData(npc, create, function()
        return {
            BloodRightsBleed = false,
            MawVoidExplosion = false,
        }
    end)
end
local function GetFamiliarTempData(familiar, create)
    return Seija:GetTempData(familiar, create, function()
        return {
            AbelLaser = nil,
            BestBudHitEnemies = nil,
            BestBudTargetPos = nil,
            BestBudTimeout = -1
        }
    end)
end
local function GetEffectTempData(effect, create)
    return Seija:GetTempData(effect, create, function()
        return {
            BrownCloudTargetPos = nil,
        }
    end)
end
local function GetTearTempData(tear, create)
    return Seija:GetTempData(tear, create, function()
        return {
            GlaucomaHitEnemies = {},
            SpiderWebHitEnemies = {},
        }
    end)
end
local function UpdatePlayerSprite(player)
    local data = GetPlayerTempData(player, true);
    local sprState = 1;
    local costumeState = 1;
    local path = Seija.Sprite;
    if (player.CanFly) then
        path = Seija.SpriteFlying;
        sprState = 2;
    end
    if (data.SpriteState ~= sprState) then
        data.SpriteState = sprState;
        local spr = player:GetSprite();
        local animation = spr:GetAnimation();
        local frame = spr:GetFrame();
        local overlayAnimation = spr:GetOverlayAnimation();
        local overlayFrame = spr:GetOverlayFrame();
        spr:Load(path, true);
        spr:SetFrame(animation, frame);
        spr:SetOverlayFrame(overlayAnimation, overlayFrame);

    end

    if (data.CostumeState ~= costumeState) then
        data.CostumeState = costumeState;
        
        player:TryRemoveNullCostume(Seija.Costume);
        if (costumeState == 1) then
            player:AddNullCostume(Seija.Costume);
        end
    end
end

local function UpdatePlayerModItems(player)
    local itemConfig = Isaac.GetItemConfig();
    local collectibleCount = itemConfig:GetCollectibles().Size;

    local tempData = GetPlayerTempData(player, true);
    tempData.ModZeroCount = 0;
    tempData.ModFourCount = 0;
    local function Check(id)
        local config = itemConfig:GetCollectible(id);
        if (config) then
            local num = player:GetCollectibleNum(id);
            if (num > 0) then
                if (config.Quality == 0) then
                    tempData.ModZeroCount = tempData.ModZeroCount + num
                elseif (config.Quality >= 4) then
                    tempData.ModFourCount = tempData.ModFourCount + num
                end
            end
        end
    end

    for i = CollectibleType.NUM_COLLECTIBLES, THI.MinCollectibleID - 1 do
        Check(i)
    end
    for i = THI.MaxCollectibleID + 1, collectibleCount do
        Check(i)
    end
    player:AddCacheFlags(CacheFlag.CACHE_ALL);
    player:EvaluateItems();
end

local function GetSpawnerPlayer(ent)
    local player;
    if (ent.SpawnerEntity) then
        player = ent.SpawnerEntity:ToPlayer();
    end
    return player;
end

local function UseTeleport(player, rng, flags)
    local game = Game();
    local level = game:GetLevel();
    for i = 1, 4 do
        local roomType = RoomType.ROOM_TREASURE;
        if (i == 2)then
            roomType = RoomType.ROOM_ULTRASECRET;
        elseif (i == 3)then
            roomType = RoomType.ROOM_DEVIL;
        elseif (i == 4)then
            roomType = RoomType.ROOM_ERROR;
        end


        local index = level:QueryRoomTypeIndex(roomType, false, rng, true);
        local room = level:GetRoomByIdx(index);
        if (room and room.Data and (room.VisitedCount <= 0 or roomType == RoomType.ROOM_ERROR)) then
            if (room.Data.Type == roomType or index < 0) then
                game:StartRoomTransition (index, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player);
                break;
            end
        end
    end
end
local function BlackBeanEffect(player, center)
    for _, ent in ipairs(Isaac.FindInRadius(center, 120, EntityPartition.ENEMY)) do
        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            Game():Fart (ent.Position, 85, player);
            ent:AddPoison(EntityRef(player), 9000, player.Damage);
        end
    end
end

local function FallMeteor(player)
    local room = Game():GetRoom();
    local pos = room:GetRandomPosition(40);
    local TinyMeteor = THI.Effects.TinyMeteor;
    local meteor = Isaac.Spawn(TinyMeteor.Type, TinyMeteor.Variant, TinyMeteor.SubType, pos, Vector.Zero, player):ToEffect();
    meteor.LifeSpan = 15;
    meteor.Timeout = 15;
    meteor.CollisionDamage = player.Damage * 10;
    meteor.SpriteRotation = -15;
end

local function FallRaindrop()
    local room = Game():GetRoom();
    local pos = room:GetRandomPosition(0);
    local raindrop = THI.Effects.AcidRaindrop;
    local drop = Isaac.Spawn(raindrop.Type, raindrop.Variant, raindrop.SubType, pos, Vector.Zero, nil):ToEffect();
    drop.LifeSpan = 15;
    drop.Timeout = 15;
    drop.SpriteRotation = 15;
end

function Seija:WillPlayerBuff(player)
    local playerType = player:GetPlayerType();
    local SeijaB = THI.Players.SeijaB;
    if (playerType == Seija.Type or playerType == SeijaB.Type) then
        return true;
    end

    local RuneSword = THI.Collectibles.RuneSword;
    local SoulOfSeija = THI.Cards.SoulOfSeija;
    if (RuneSword:HasInsertedRune(player, SoulOfSeija.ID) or RuneSword:HasInsertedRune(player, SoulOfSeija.ReversedID)) then
        return true;
    end
    return false;
end

function Seija:WillPlayerNerf(player)
    local RuneSword = THI.Collectibles.RuneSword;
    local SoulOfSeija = THI.Cards.SoulOfSeija;
    local nerf = false;


    local hasRune1 = RuneSword:HasInsertedRune(player, SoulOfSeija.ID);
    local hasRune2 = RuneSword:HasInsertedRune(player, SoulOfSeija.ReversedID);
    local playerType = player:GetPlayerType();
    local SeijaB = THI.Players.SeijaB;
    if (playerType == Seija.Type or playerType == SeijaB.Type or (hasRune1 or hasRune2)) then
        nerf = true;
    end

    if (playerType == Seija.Type and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        return false;
    end
    
    if (hasRune1 and hasRune2) then
        return false;
    end
    


    return nerf;
end
function Seija:IsModQuality0(item)
    if (item < CollectibleType.NUM_COLLECTIBLES or THI:ContainsCollectible(item)) then
        return false;
    end 
    local itemConfig = Isaac.GetItemConfig();
    local config = itemConfig:GetCollectible(item);
    if (config and config.Quality == 0) then
        return true;
    end
    return false;
end

function Seija:IsModQuality4(item)
    if (item < CollectibleType.NUM_COLLECTIBLES or THI:ContainsCollectible(item)) then
        return false;
    end 
    local itemConfig = Isaac.GetItemConfig();
    local config = itemConfig:GetCollectible(item);
    if (config and config.Quality >= 4) then
        return true;
    end
    return false;
end

function Seija:IsBloodRightsBleed(ent)
    local data = GetNPCTempData(ent, false);
    return data and data.BloodRightsBleed;
end
function Seija:SetBloodRightsBleed(ent, value)
    local data = GetNPCTempData(ent, true);
    data.BloodRightsBleed = value;
end

do -- Events
    local function PostPlayerInit(mod, player)
        if (player:GetPlayerType() == Seija.Type) then
            player:AddNullCostume(Seija.Costume);
            local game = Game();
            if (not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0)) then
                player:SetPocketActiveItem(THI.Collectibles.DFlip.Item, ActiveSlot.SLOT_POCKET, false);
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, PostPlayerInit, 0)


    local function PostPlayerUpdate(mod, player)
        if (player:GetPlayerType() == Seija.Type) then
            UpdatePlayerSprite(player);
            local tempData = GetPlayerTempData(player, true);
            tempData.WasSeija = true;
        else
            local tempData = GetPlayerTempData(player, false);
            if (tempData and tempData.WasSeija) then
                tempData.WasSeija = false;
                player:TryRemoveNullCostume(Seija.Costume);
            end
        end
        
        local room = Game():GetRoom();
        local effects = player:GetEffects();
        if (Seija:WillPlayerBuff(player)) then
            -- Skatole.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_SKATOLE)) then
                if (room:GetFrameCount() % 30 == 1) then
                    for _, ent in ipairs(Isaac.GetRoomEntities()) do
                        if (ent:IsVulnerableEnemy() and not ent:IsBoss() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and EntityTags:EntityFits(ent, "FlyEnemies")) then
                            if (EntityTags:EntityFits(ent, "ConvertToBlueFlies")) then
                                ent:Remove();
                                player:AddBlueFlies(1, ent.Position, nil);
                            else
                                ent:AddCharmed(EntityRef(player), -1);
                            end
                        end
                    end
                end
            end
            -- Best Bud.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_BEST_BUD)) then
                if (not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BEST_BUD)) then
                    effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BEST_BUD);
                end
            end
            --Linger Bean.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_LINGER_BEAN)) then
                local data = GetPlayerTempData(player, true);
                if (player:GetFireDirection() >= 0) then
                    data.LingerBeanTime = data.LingerBeanTime + 1;
                else
                    data.LingerBeanTime = 112;
                end
                if (data.LingerBeanTime > 225) then
                    data.LingerBeanTime = data.LingerBeanTime - 225;
                    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BROWN_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect();
                    cloud.Timeout = 450;
                end
            end
            -- Taurus.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS)) then
                player.MoveSpeed = 1.95;
            end
            -- TMTrainer.
            local tmtrainerCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TMTRAINER, true);
            if (tmtrainerCount > 0) then
                for i = 1, tmtrainerCount do
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER, true);
                    player:AddCollectible(THI.Collectibles.THTRAINER.Item, 0, false);
                end
                player:PlayExtraAnimation("Glitch");
                SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH);
            end
            -- My Shadow. (Obsoleted)
            -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_MY_SHADOW)) then
            --     if (room:GetFrameCount() % 90 == 89) then
            --         local maggotCount = #Isaac.FindByType(EntityType.ENTITY_CHARGER, 0, 1);
            --         for _, ent in ipairs(Isaac.GetRoomEntities()) do
            --             if (maggotCount < 6 and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            --                 local maggot = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, ent.Position, Vector.Zero, player);
            --                 maggot:AddCharmed(EntityRef(player), -1);
            --                 maggotCount = maggotCount + 1;
            --             end
            --         end
            --     end
            -- end
            local itemConfig = Isaac.GetItemConfig();
            for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
                local item = player:GetActiveItem(slot);
                local charge = player:GetActiveCharge(slot);
                local batteryCharge = player:GetBatteryCharge(slot);
                if (item == CollectibleType.COLLECTIBLE_ISAACS_TEARS) then
                    -- Isaac's Tears.
                    local configCharges = itemConfig:GetCollectible(item).MaxCharges;
                    player:SetActiveCharge(math.max(configCharges - 1, charge), slot);
                elseif (item == CollectibleType.COLLECTIBLE_BROWN_NUGGET) then
                    -- Brown Nugget.
                    local configCharges = itemConfig:GetCollectible(item).MaxCharges;
                    local speed = math.floor(configCharges / 30 - 1);
                    local maxCharge = configCharges;
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)) then
                        maxCharge = maxCharge * 2;
                    end
                    local result = charge + batteryCharge;
                    if (result < maxCharge) then
                        result = math.min(result + speed, maxCharge);
                    end
                    player:SetActiveCharge(result, slot);
                -- elseif (item == CollectibleType.COLLECTIBLE_BREATH_OF_LIFE) then
                --     -- Breath of Life (Obsoleted)
                --     local configCharges = itemConfig:GetCollectible(item).MaxCharges;
                --     if (charge < configCharges and charge > 0) then
                --         player:SetMinDamageCooldown(3);
                --     end
                end
            end

            -- IBS
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_IBS)) then
                if (player.IBSCharge >= 0.98) then
                    player.IBSCharge = 0;
                    Game():ButterBeanFart (player.Position, 80, player, true, false);
                    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IBS);
                    for i = 1, 3 do
                        local index = rng:RandomInt(#Seija.DipSubTypes) + 1;
                        local subtype = Seija.DipSubTypes[index];
                        local offset = Vector.FromAngle(rng:RandomFloat() * 360) * rng:RandomFloat() * 40;
                        player:ThrowFriendlyDip(subtype, player.Position, player.Position + offset);
                    end
                    player:UsePoopSpell(PoopSpellType.SPELL_LIQUID);
                end
            end

            -- A Quarter
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_QUARTER)) then
                if (player:GetNumCoins() < 25) then
                    local rng = RNG();
                    local v = RandomVector()*(rng:RandomFloat()*2+2); 
                    local poof = Isaac.Spawn(1000,15,100,player.Position,v,player);
                    local spr = poof:GetSprite();
                    spr:Load("gfx/005.350_Trinket.anm2", true);
                    local quarterConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_QUARTER);
                    spr:ReplaceSpritesheet(0, quarterConfig.GfxFileName);
                    spr:LoadGraphics()
                    spr:Play("Appear");


                    SFXManager():Play(SoundEffect.SOUND_DIMEPICKUP);
                    SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER);
                    player:AddCoins(25);
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_QUARTER);
                end
            end

            
            local tempData = GetPlayerTempData(player, true);
            tempData.SeijaClicker = true;
            if (player.QueuedItem and player.QueuedItem.Item and player.QueuedItem.Item.Type ~= ItemType.ITEM_TRINKET) then
                tempData.VoidAbyssLifting = true;
            else
                tempData.VoidAbyssLifting = false;
            end
            
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_BAGGY)) then
                local itemPool = Game():GetItemPool();
                for slot = 0, 1 do
                    local pillColor = player:GetPill(slot);
                    if (pillColor & PillColor.PILL_COLOR_MASK > 0) then
                        if (pillColor & PillColor.PILL_GIANT_FLAG <= 0) then
                            pillColor = pillColor | PillColor.PILL_GIANT_FLAG;
                            player:SetPill(slot, pillColor);
                        end

                        if (not itemPool:IsPillIdentified(pillColor)) then
                            itemPool:IdentifyPill(pillColor);
                        end
                    end
                end
            end
        else
            

            -- TMTrainer.
            local thtrainerCount = player:GetCollectibleNum(THI.Collectibles.THTRAINER.Item, true);
            if (thtrainerCount > 0) then
                for i = 1, thtrainerCount do
                    player:RemoveCollectible(THI.Collectibles.THTRAINER.Item, true);
                    player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER, 0, false);
                end
                player:PlayExtraAnimation("Glitch");
                SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH);
            end

            local tempData = GetPlayerTempData(player, false);
            if (tempData and tempData.SeijaClicker) then
                tempData.SeijaClicker = false;
            end
        end

        local willNerf = Seija:WillPlayerNerf(player);
        if (willNerf) then
            -- Holy Mantle.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
                if (not effects:HasNullEffect(NullItemID.ID_LOST_CURSE)) then
                    effects:AddNullEffect(NullItemID.ID_LOST_CURSE);
                end
            end

            local function LoseHearts()
                local hearts = player:GetHearts() ;
                local rottenHearts = player:GetRottenHearts() ;
                
                local leastRedHeart = 1;
                local leastSoulHeart = 1;
                local leastBoneHeart = 1;
                local loseRedHearts = false;
                local loseSoulHearts = false;
                local loseBoneHearts = false;
                
                local soulHearts = player:GetSoulHearts();
                local boneHearts = player:GetBoneHearts();
                if (soulHearts + boneHearts > 0) then
                    leastRedHeart = 0;
                end
                if (boneHearts > 0) then
                    leastSoulHeart = 0;
                end

                if (player:HasCollectible(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT)) then
                    loseRedHearts = true;
                end
                if (player:HasCollectible(THI.Collectibles.VampireTooth.Item)) then
                    loseRedHearts = true;
                    loseSoulHearts = true;
                    loseBoneHearts = true;
                end
                

                -- Operate.
                if (loseRedHearts and hearts > leastRedHeart) then
                    if (rottenHearts * 2 >= hearts and rottenHearts > leastRedHeart) then
                        player:AddRottenHearts(-2);
                        return;
                    end
                    player:AddHearts(-1);
                    return;
                end

                if (loseSoulHearts and soulHearts > leastSoulHeart) then
                    player:AddSoulHearts(-1)
                    return;
                end
                if (loseBoneHearts and boneHearts > leastBoneHeart) then
                    player:AddBoneHearts(-1)
                    return;
                end
            end
            -- Crown of the Light
            if (Game().TimeCounter % 300 == 299 and not player:HasEntityFlags(EntityFlag.FLAG_INTERPOLATION_UPDATE)) then
                LoseHearts()
            end

        end

        -- Scooper Decay.
        local data = GetPlayerData(player, false);
        if (data) then
            if (data.ScooperDamage > 0) then
                if (player:IsFrame(14, 0)) then
                    data.ScooperDamage = math.max(0, data.ScooperDamage - 0.5);
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                    player:EvaluateItems();
                end
            end
        end
        
        
        -- Rock Bottom.
        -- 如果拥有谷底石并且正邪削弱：
        --  如果Record为nil，则Evaluate所有属性，在Evaluate中将所有属性翻倍，然后将Record写为该属性值。
        --  如果Record不为nil，则锁定玩家的属性为Record。
        -- 否则：
        --  删除Record。
        local data = GetPlayerData(player, false);
        if (Seija:WillPlayerNerf(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM)) then
            if (not data or not data.RockBottomRecord) then
                data = GetPlayerData(player, true);
                player:AddCacheFlags(CacheFlag.CACHE_ALL);
                player:EvaluateItems();
                data.RockBottomRecord = {
                    MoveSpeed = player.MoveSpeed,
                    MaxFireDelay = player.MaxFireDelay,
                    Damage = player.Damage,
                    TearRange = player.TearRange,
                    TearHeight = player.TearHeight,
                    TearFallingSpeed = player.TearFallingSpeed,
                    TearFallingAcceleration = player.TearFallingAcceleration,
                    ShotSpeed = player.ShotSpeed,
                    Luck = player.Luck
                }
            else
                local record = data.RockBottomRecord;
                
                player.MoveSpeed = record.MoveSpeed;
                player.MaxFireDelay = record.MaxFireDelay;
                player.Damage = record.Damage;
                player.TearRange = record.TearRange;
                player.TearHeight = record.TearHeight;
                player.TearFallingSpeed = record.TearFallingSpeed;
                player.TearFallingAcceleration = record.TearFallingAcceleration;
                player.ShotSpeed = record.ShotSpeed;
                player.Luck = record.Luck;
            end
        else
            if (data and data.RockBottomRecord) then
                data.RockBottomRecord = nil;
            end
        end

        -- Mod Items.
        local tempData = GetPlayerTempData(player, false);
        if (tempData and tempData.UpdateModItems) then
            tempData.UpdateModItems = false;
            UpdatePlayerModItems(player);
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate, 0)

    

    local function PostPlayerEffect(mod, player)
    end
    Seija:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

    local function PrePlayerCollision(mod, player, other, low)
        if (other:IsVulnerableEnemy() and Seija:WillPlayerNerf(player)) then
            local effects =player:GetEffects();
            if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH)) then
                return false;
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PrePlayerCollision)


    local function PostNewRoom(mod)
        local betrayalPlayer;
        local shadePlayer;
        for p, player in Players.PlayerPairs() do
            if (Seija:WillPlayerBuff(player)) then
                local effects = player:GetEffects();
                -- Best Bud.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BEST_BUD)) then
                    if (not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BEST_BUD)) then
                        effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BEST_BUD);
                    end
                end
                if (not betrayalPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_BETRAYAL)) then
                    betrayalPlayer = player;
                end
                if (not shadePlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_SHADE)) then
                    shadePlayer = player;
                end
            end
        end
        -- Betrayal. (Obsoleted)
        -- if (betrayalPlayer) then
        --     local validEnemies = {};
        --     for _, ent in ipairs(Isaac.GetRoomEntities()) do
        --         if (ent:IsActiveEnemy() and ent:CanShutDoors() and ent.MaxHitPoints > 0 and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:HasEntityFlags(EntityFlag.FLAG_CHARM)) then
        --             table.insert(validEnemies, ent);
        --         end
        --     end
            
        --     local times = math.ceil(#validEnemies / 2);
        --     for i = 1, times do
        --         local rng = betrayalPlayer:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BETRAYAL);
        --         local index = rng:RandomInt(#validEnemies) + 1;
        --         validEnemies[index]:AddCharmed(EntityRef(betrayalPlayer), 300);
        --         table.remove(validEnemies, index);
        --     end
        -- end
        -- Shade. 
        if (shadePlayer) then
            local SeijasShade = THI.Effects.SeijasShade;
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if (ent:IsActiveEnemy() and ent:CanShutDoors() and ent.MaxHitPoints > 0 and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    local shade = Isaac.Spawn(SeijasShade.Type, SeijasShade.Variant, SeijasShade.SubType, ent.Position, Vector.Zero, shadePlayer);
                    shade.Parent = ent;
                end
            end
        end

        local globalData = GetGlobalTempData(false);
        if (globalData) then
            globalData.AcidRainTimeout = 0;
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

    local function PostNewLevel(mod)
        local cainsOtherEyePlayer;
        for p, player in Players.PlayerPairs() do
            if (Seija:WillPlayerBuff(player)) then
                -- Missing No.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)) then
                    --Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER);
                    player:AddSoulHearts(player:GetHeartLimit());
                end


                if (not cainsOtherEyePlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE)) then
                    cainsOtherEyePlayer = player;
                end
            end
        end
        -- Cain's other eye (Obsoleted)
        -- if (cainsOtherEyePlayer) then
        --     local level = Game():GetLevel()
        --     level:ApplyMapEffect ( );
        --     level:UpdateVisibility();
        -- end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel)

    local function EvaluateCache(mod, player, flag)
        if (Seija:WillPlayerBuff(player)) then
            


            local effects = player:GetEffects();
            -- Cursed Eye.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears * 2 end);
                end
            end
            -- My Reflection Tear Flags. (Obsoleted)
            -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)) then
            --     if (flag == CacheFlag.CACHE_TEARFLAG) then
            --         player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL;
            --     elseif (flag == CacheFlag.CACHE_RANGE) then
            --         player.TearRange = player.TearRange * 0.75;
            --     end
            -- end
            
            -- Missing Page 2.
            local missingPage2Num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MISSING_PAGE_2);
            if (missingPage2Num > 0) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:AddDamageUp(player, missingPage2Num);
                end
            end
            -- The Wiz Tear Flags.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ)) then
                if (flag == CacheFlag.CACHE_TEARFLAG) then
                    player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_PIERCING;
                end
            end
            -- Taurus
            -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_TAURUS)) then
            --     if (flag == CacheFlag.CACHE_SPEED) then
            --         player.MoveSpeed = 1.95;
            --     end
            -- end
            -- Ouija Board (Obsoleted)
            -- local ouijaCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_OUIJA_BOARD);
            -- if (ouijaCount > 0) then
            --     if (flag == CacheFlag.CACHE_TEARFLAG) then
            --         player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING;
            --     elseif (flag == CacheFlag.CACHE_FIREDELAY) then
            --         Stats:AddTearsModifier(player, function(tears) return tears + 1 * ouijaCount end);
            --     end
            -- end
            -- Bucket of Lard.
            local lardCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BUCKET_OF_LARD);
            if (lardCount) then
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed + 0.4 * lardCount;
                end
            end
            -- Razor Blade.
            if (flag == CacheFlag.CACHE_DAMAGE) then
                local razorCount = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_RAZOR_BLADE);
                if (razorCount > 0) then
                    Stats:MultiplyDamage(player, (razorCount + 1) ^ 0.5);
                end
            end

            local data = GetPlayerData(player, false);
            if (data) then
                -- Dataminer.
                local times = data.DataMinerTimes;
                -- Scooper.
                local scooperDamage = data.ScooperDamage;
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed + times * 0.1;
                elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears + 0.25 * times end);
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:AddFlatDamage(player, 0.5 * times + scooperDamage);
                elseif (flag == CacheFlag.CACHE_RANGE) then
                    player.TearRange = player.TearRange + 30 * times;
                elseif (flag == CacheFlag.CACHE_LUCK) then
                    player.Luck = player.Luck + times * 0.5;
                end
                

            end

        end

        -- Nerfs.
        if (Seija:WillPlayerNerf(player)) then
            
            local effects = player:GetEffects();
            -- Cricket's Head.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears * 0.667 end);
                end
            end
            -- Magic Mushroom.
            local magicMushCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM); 
            if (magicMushCount > 0) then
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed - 0.8 * magicMushCount;
                end
            end
            -- Mom's Knife.
            local momsKnifeCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_KNIFE); 
            if (momsKnifeCount > 0) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears * 0.75 * momsKnifeCount end);
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 0.75 ^ momsKnifeCount);
                elseif (flag == CacheFlag.CACHE_TEARFLAG) then
                    player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING;
                end
            end
            -- Ipecac.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC)) then
                if (flag == CacheFlag.CACHE_TEARFLAG) then
                    player.TearFlags = player.TearFlags | TearFlags.TEAR_BOOMERANG;
                end
            end
            -- Polyphemus.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears * 0.75 end);
                end
            end
            -- Sacred Heart.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART)) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears * 0.50 end);
                elseif (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed -0.5;
                elseif (flag == CacheFlag.CACHE_RANGE) then
                    player.TearRange = player.TearRange -100;
                elseif (flag == CacheFlag.CACHE_SHOTSPEED) then
                    player.ShotSpeed = player.ShotSpeed + 1;
                elseif (flag == CacheFlag.CACHE_LUCK) then
                    player.Luck = player.Luck - 3;
                end
            end
            -- Stopwatch.
            local stopwatchCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STOP_WATCH);
            if (stopwatchCount > 0) then
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed - 0.6 * stopwatchCount;
                end
            end
            -- Proptosis.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS)) then
                if (flag == CacheFlag.CACHE_SHOTSPEED) then
                    player.ShotSpeed = player.ShotSpeed - 1;
                end
            end
            -- Godhead.
            local godheadCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GODHEAD)
            if (godheadCount > 0) then
                if (flag == CacheFlag.CACHE_SHOTSPEED) then
                    player.ShotSpeed = player.ShotSpeed + 2.3 * godheadCount;
                end
            end
            -- Incubus.
            local incubusCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INCUBUS);
            if (incubusCount > 0) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 0.75 ^ incubusCount);
                end
            end
            -- Tech X.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
                if (flag == CacheFlag.CACHE_SHOTSPEED) then
                    player.ShotSpeed = player.ShotSpeed + 2;
                end
            end
            -- Twisted Pair.
            local twistedPairCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TWISTED_PAIR);
            if (twistedPairCount > 0) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 0.6 ^ twistedPairCount);
                end
            end
            -- Void/Abyss.
            local data = GetPlayerData(player, false);
            if (data) then
                local multiplier = 1;
                local voidTimes = data.VoidTimes;
                if (voidTimes > 0) then
                    multiplier = 1 - voidTimes * 0.05
                end
                if (data.AbyssTimes > 0) then
                    multiplier = multiplier - data.AbyssTimes * 0.1
                end
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed - voidTimes  * 0.05;
                elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) 
                        return tears * multiplier;
                    end);
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, multiplier);
                elseif (flag == CacheFlag.CACHE_RANGE) then
                    player.TearRange = player.TearRange - 20 * voidTimes;
                elseif (flag == CacheFlag.CACHE_LUCK) then
                    player.Luck = player.Luck -0.5 * voidTimes;
                end
            end
            -- Binge Eater.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then
                if (flag == CacheFlag.CACHE_SPEED) then
                    
                    local num = 0;
                    for _, item in ipairs(FoodItems) do
                        num = num + player:GetCollectibleNum(item, true);
                    end
                    player.MoveSpeed = player.MoveSpeed - 0.12 * num;
                end
            end
            -- Rock Bottom.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM)) then
                
                if (flag == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed * 2;
                elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) 
                        return tears * 2;
                    end);
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 2);
                elseif (flag == CacheFlag.CACHE_RANGE) then
                    player.TearRange = player.TearRange * 2;
                elseif (flag == CacheFlag.CACHE_SHOTSPEED) then
                    player.ShotSpeed = player.ShotSpeed * 2;
                elseif (flag == CacheFlag.CACHE_LUCK) then
                    if (player.Luck > 0) then
                        player.Luck = player.Luck * 2;
                    else
                        player.Luck = player.Luck / 2;
                    end
                end
            end
            -- Ghost Pepper
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)) then
                if (flag == CacheFlag.CACHE_LUCK) then
                    player.Luck = player.Luck - 8;
                end
            end
            -- 20/20
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 0.9325);
                end
            end
            
            -- Haemolacria.
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) then
                if (flag == CacheFlag.CACHE_TEARFLAG) then
                    player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING;
                end
            end
        end

        
        -- Mod Items.
        local tempData = GetPlayerTempData(player, false);
        if (tempData) then
            local count = 0;
            if (Seija:WillPlayerBuff(player)) then
                count = count + tempData.ModZeroCount;
            end
            if (Seija:WillPlayerNerf(player)) then
                count = count - tempData.ModFourCount;
            end
            local multiplier = 1;
            
            if (count > 0) then
                multiplier = 0.7 * count ^ 0.5 + 1;
            elseif (count < 0) then
                multiplier = 0.7 ^ (-count);
            end
            
            if (flag == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed + count * 0.3;
            elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                Stats:AddTearsModifier(player, function(tears) 
                    return tears * multiplier;
                end);
            elseif (flag == CacheFlag.CACHE_DAMAGE) then
                Stats:MultiplyDamage(player, multiplier);
            elseif (flag == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange + 40 * count;
            elseif (flag == CacheFlag.CACHE_LUCK) then
                player.Luck = player.Luck + 2 * count;
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

    local function PostChangeCollectible(mod, player, item, diff)
        if (player.Variant == 0 and not player:IsCoopGhost()) then
            if (Seija:WillPlayerBuff(player) or Seija:WillPlayerNerf(player)) then
                local caches = Seija.CacheItems[item];
                if (caches) then
                    player:AddCacheFlags(caches);
                    player:EvaluateItems();
                end
                local tempData = GetPlayerTempData(player, true);
                tempData.UpdateModItems = true;
            end
        end
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, PostChangeCollectible)

    local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
        local glitchedCrownPlayer;
        for p, player in Players.PlayerPairs() do
            if (Seija:WillPlayerNerf(player)) then
                if (not glitchedCrownPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_GLITCHED_CROWN)) then
                    glitchedCrownPlayer = player;
                end
            end
        end
        if (glitchedCrownPlayer) then
            if (loopCount == 1 and Game():GetFrameCount() > 2 and seed % 5 < 4) then
                return CollectibleType.COLLECTIBLE_GLITCHED_CROWN;
            end
        end
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, PreGetCollectible, nil, 100)

    local function PostGetCollectible(mod, item, pool, decrease, seed)
        if (item == CollectibleType.COLLECTIBLE_TMTRAINER) then
            local seijaPlayer;
            for p, player in Players.PlayerPairs() do
                if (Seija:WillPlayerBuff(player)) then
                    if (not seijaPlayer) then
                        seijaPlayer = player;
                    end
                end
            end
            if (seijaPlayer) then
                return THI.Collectibles.THTRAINER.Item;
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, PostGetCollectible)

    local ClickerGetting = false;
    local function EvaluatePoolBlacklist(mod, id, config)
        if (ClickerGetting) then
            return config.Quality < 4;
        end
        local missingNoPlayer;
        for p, player in Players.PlayerPairs() do
            if (Seija:WillPlayerBuff(player)) then
                if (not missingNoPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)) then
                    missingNoPlayer = player;
                end
            end
        end
        if (missingNoPlayer) then
            local game = Game();
            local level = game:GetLevel();
            local room = game:GetRoom();
            if (room:IsFirstVisit() and level:GetCurrentRoomIndex() == level:GetStartingRoomIndex ( ) and room:GetFrameCount() <= 0) then
                if (config.Type == ItemType.ITEM_ACTIVE) then
                    return true;
                end
            end
            if (config.Quality >= 4 and Seija:WillPlayerNerf(missingNoPlayer)) then
                return true;
            end
            --return id == CollectibleType.COLLECTIBLE_TMTRAINER;
            return false;
        end
       
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluatePoolBlacklist)

    local function PostGainCollectible(mod, player, item, count, touched, queued)
        if (player.Variant == 0 and not player:IsCoopGhost()) then
            if (Seija:WillPlayerBuff(player)) then
                local game = Game();
                local room = game:GetRoom();
                -- BOOM.
                if (item == CollectibleType.COLLECTIBLE_BOOM) then
                    if (not touched) then
                        player:AddBombs(89);
                    end
                elseif (item == CollectibleType.COLLECTIBLE_PAGEANT_BOY) then -- Pageant Boy.
                    if (not touched) then
                        for i = 1, 4 do
                            local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
                            local subtype = CoinSubType.COIN_NICKEL;
                            if (i == 2) then
                                subtype = CoinSubType.COIN_DIME;
                            elseif (i == 3) then
                                subtype = CoinSubType.COIN_GOLDEN;
                            elseif (i == 4) then
                                subtype = CoinSubType.COIN_LUCKYPENNY;
                            end
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, subtype, pos, Vector.Zero, player);
                        
                        end
                    end
                elseif (item == CollectibleType.COLLECTIBLE_BUCKET_OF_LARD) then
                    if (not touched) then
                        player:AddHearts(player:GetEffectiveMaxHearts());
                    end
                elseif (item == CollectibleType.COLLECTIBLE_MISSING_NO) then
                    --Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER);
                elseif (item == CollectibleType.COLLECTIBLE_BOX) then
                    if (queued and not touched) then
                        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOX);
                        local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true);
                        local subtype = CollectibleType.COLLECTIBLE_BOX;
                        if (rng:RandomInt(100) < 75) then
                            local seed = rng:Next();
                            local itemPool = Game():GetItemPool();
                            local poolType = itemPool:GetPoolForRoom (RoomType.ROOM_ERROR, seed);
                            subtype = itemPool:GetCollectible(poolType, true, seed)
                        end
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, subtype, pos, Vector.Zero, player);
                        SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
                    end
                end
            end
        end
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainCollectible)


    local function PreEntitySpawn(mod, type, variant, subtype, position, velocity, spawner, seed)
    --     -- Bum Friend. (Obsoleted)
    --     if (type == 5 and variant ~= PickupVariant.PICKUP_TRINKET and spawner) then
    --         if (spawner.Type == EntityType.ENTITY_FAMILIAR and spawner.Variant == FamiliarVariant.BUM_FRIEND) then
    --             local familiar = spawner:ToFamiliar();
    --             if (familiar.Player and Seija:WillPlayerBuff(familiar.Player)) then
    --                 if (seed % 100 < 50) then
    --                     local itemPool = Game():GetItemPool();
    --                     local poolType = ItemPoolType.POOL_BEGGAR;
    --                     local id = itemPool:GetCollectible(poolType, true, seed);
    --                     return {type, PickupVariant.PICKUP_COLLECTIBLE, id, seed};
    --                 end
    --             end
    --         end
    --     end
        -- Battery Pack.
        if (type == 5 and variant == PickupVariant.PICKUP_LIL_BATTERY and subtype == BatterySubType.BATTERY_MICRO) then
            for p, player in Players.PlayerPairs() do
                if (Seija:WillPlayerBuff(player)) then
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY_PACK)) then
                        return {type, variant, BatterySubType.BATTERY_NORMAL, seed};
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, PreEntitySpawn);

    local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
            local player = tookDamage:ToPlayer();
            if (Seija:WillPlayerBuff(player)) then
                -- Curse of the Tower.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER)) then
                    if (flags & DamageFlag.DAMAGE_EXPLOSION > 0) then
                        return false;
                    end
                end
            end
        else -- NPC.
            --Pyromaniac.
            if (flags & DamageFlag.DAMAGE_EXPLOSION > 0) then
                local canHeal = true;
                -- Avoid Tuff twin and The Shell
                if (tookDamage.Type == EntityType.ENTITY_LARRYJR) then
                    if (tookDamage.Variant == 2 or tookDamage.Variant == 3) then
                        local npc = tookDamage:ToNPC();
                        if (npc.I2 == 0) then
                            canHeal = false;
                        end
                    end
                end

                -- Dr. Fetus and Epic Fetus.
                local sourceEnt = source.Entity;
                if (sourceEnt) then
                    if (sourceEnt.Type == EntityType.ENTITY_EFFECT and sourceEnt.Variant == EffectVariant.ROCKET) then
                        canHeal = false;
                    else
                        local bomb = sourceEnt:ToBomb();
                        if (bomb and bomb.IsFetus) then
                            canHeal = false;
                        end
                    end
                end
                if (canHeal) then
                    local pyromaniacPlayer;
                    for p, player in Players.PlayerPairs() do
                        if (Seija:WillPlayerNerf(player)) then
                            if (not pyromaniacPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC)) then
                                pyromaniacPlayer = player;
                            end
                        end
                    end
                    if (pyromaniacPlayer) then
                        if (tookDamage.HitPoints < tookDamage.MaxHitPoints) then
                            tookDamage.HitPoints = math.min(tookDamage.HitPoints + amount, tookDamage.MaxHitPoints);
                            local heart = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, tookDamage.Position, Vector.Zero, tookDamage);
                            heart.DepthOffset = 10;
                            heart.PositionOffset = Vector(0, -10);
                        end
                        return false;
                    end
                end
            end
        end
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage);

    local function PostTakeDamage(mod, tookDamage, amount, flags, source, countdown)
        if (tookDamage.Type == EntityType.ENTITY_PLAYER) then
            local player = tookDamage:ToPlayer();
            if (Seija:WillPlayerBuff(player)) then
                -- Black Bean.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN)) then
                    BlackBeanEffect(player, player.Position);
                end
                -- Missing Page 2.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_PAGE_2)) then
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM);
                end
                -- Betrayal. (Obsoleted)
                -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_BETRAYAL)) then
                --     player:UseCard(THI.Cards.SoulOfSatori.ID, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER);
                -- end
            end
            if (Seija:WillPlayerNerf(player)) then
                -- Wafer.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER)) then
                    if (flags & DamageFlag.DAMAGE_CLONES <= 0) then
                        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_WAFER);
                        if (rng:RandomInt(100) < 50) then
                            player:TakeDamage(1, flags | DamageFlag.DAMAGE_CLONES, source, countdown);
                            local game = Game();
                            game:ShakeScreen(10);
                            THI.SFXManager:Play(SoundEffect.SOUND_DEATH_BURST_LARGE);
                            game:SpawnParticles (player.Position, EffectVariant.BLOOD_PARTICLE, 10, 5);
                        end
                    end
                end
            end
        else -- NPCs.

            local data = GetNPCTempData(tookDamage, false)
            if (data and data.MawVoidExplosion) then
                data.MawVoidExplosion = false;
            end
            local player;
            local sourceEnt = source.Entity;
            if (sourceEnt) then
                if (sourceEnt.Type == EntityType.ENTITY_TEAR) then
                    if (sourceEnt.SpawnerEntity) then
                        player = sourceEnt.SpawnerEntity:ToPlayer();
                    end
                else
                    player = sourceEnt:ToPlayer();
                end
            end
            if (player) then
                if (Seija:WillPlayerBuff(player)) then
                    -- Infestation.
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_INFESTATION)) then
                        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_INFESTATION);
                        if (rng:RandomInt(100) < 50) then
                            tookDamage:AddPoison(EntityRef(player), 90, amount);
                            player:AddBlueFlies(1, player.Position, tookDamage);
                        end
                    end

                    -- Tiny Planet.
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET)) then
                            
                        if (tookDamage:IsActiveEnemy(true) and sourceEnt.Type == EntityType.ENTITY_TEAR) then
                            local tear = sourceEnt:ToTear();
                            if (tear:HasTearFlags(TearFlags.TEAR_ORBIT)) then
                                FallMeteor(player);
                            end
                        end
                    end
                end
                -- if (Seija:WillPlayerNerf(player)) then
                    -- Maw of the Void. (Obsoleted)
                    -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID)) then
                    --     if (flags & DamageFlag.DAMAGE_LASER > 0) then
                    --         local data = GetNPCTempData(tookDamage, true)
                    --         data.MawVoidExplosion = true;
                    --         --Game():BombExplosionEffects(tookDamage.Position, 1, TearFlags.TEAR_NORMAL, Color.Black, tookDamage, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
                    --     end
                    -- end
                -- end
            end

        end
    end
    Seija:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostTakeDamage);

    local function PostEntityKill(mod, ent)
        if (ent:IsActiveEnemy(true)) then

            local skatolePlayer;
            local deadBirdPlayer;
            local blackBeanPlayer;
            local myShadowPlayer;
            local infestationIIPlayer;
            for p, player in Players.PlayerPairs() do
                if (Seija:WillPlayerBuff(player)) then
                    if (not skatolePlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_SKATOLE)) then
                        skatolePlayer = player;
                    end
                    if (not deadBirdPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_BIRD)) then
                        deadBirdPlayer = player;
                    end
                    if (not blackBeanPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN)) then
                        blackBeanPlayer = player;
                    end
                    if (not myShadowPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_MY_SHADOW)) then
                        myShadowPlayer = player;
                    end
                end
                
                if (Seija:WillPlayerNerf(player)) then
                    if (not infestationIIPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_INFESTATION_2)) then
                        infestationIIPlayer = player;
                    end
                end
            end
            -- Skatole.
            if (skatolePlayer) then
                skatolePlayer:AddBlueFlies(1, ent.Position, nil);
            end
            
            -- Dead Bird.
            if (deadBirdPlayer) then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, ent.Position, Vector.Zero, deadBirdPlayer);
            end
            
            -- Black Bean.
            if (blackBeanPlayer) then
                BlackBeanEffect(blackBeanPlayer, ent.Position);
            end
            
            -- My Shadow. (Obsoleted)
            -- if (ent.Type == EntityType.ENTITY_CHARGER and ent.Variant == 0 and ent.SubType == 1) then
            --     if (ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and myShadowPlayer) then
            --         Game():BombExplosionEffects(ent.Position, 185, TearFlags.TEAR_NORMAL, Color.Default, myShadowPlayer, 1, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR);
            --     end
            -- end
            
            --Infestation II. (Obsoleted)
            -- if (infestationIIPlayer) then
            --     if (ent.Type ~= EntityType.ENTITY_SPIDER and ent.Type ~= EntityType.ENTITY_STRIDER) then
            --         local spider = EntityNPC.ThrowSpider (ent.Position, ent, ent.Position + RandomVector() * 10, false, -10 );
            --         spider.MaxHitPoints = infestationIIPlayer.Damage * 10;
            --         spider.HitPoints = spider.MaxHitPoints;
            --     end
            -- end

            -- Dark Ribbon.
            if (not (ent.Type == EntityType.ENTITY_CHARGER and ent.Variant == 0 and ent.SubType == 1)) then
                local DarkRibbon = THI.Collectibles.DarkRibbon;
                for _, halo in ipairs(Isaac.FindByType(DarkRibbon.DarkHaloEntity, DarkRibbon.DarkHaloEntityVariant)) do
                    if (ent.Position:Distance(halo.Position) < 128) then
                        if (halo.SpawnerEntity) then
                            local spawnerPlayer = halo.SpawnerEntity:ToPlayer();
                            if (spawnerPlayer and Seija:WillPlayerNerf(spawnerPlayer)) then
                                local maggot = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, ent.Position, Vector.Zero, ent);
                                maggot.MaxHitPoints = 10 * spawnerPlayer.Damage;
                                maggot.HitPoints = maggot.MaxHitPoints;
                                break;
                            end
                        end
                    end
                end
            end
            
            if (Seija:IsBloodRightsBleed(ent)) then
                local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, ent.Position, RandomVector(), ent):ToPickup();
                heart.Timeout = 60;
            end
            
            local data = GetNPCTempData(ent, false)
            if (data and data.MawVoidExplosion) then
                data.MawVoidExplosion = false;
                Game():BombExplosionEffects(ent.Position, 10, TearFlags.TEAR_NORMAL, Color.Black, ent, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
                
            end
        end

    end
    Seija:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostEntityKill);

    -- Bombs.
    local function PostBombUpdate(mod, bomb)
        local player = GetSpawnerPlayer(bomb);

        if (player) then
            -- Dr. Fetus.
            if (bomb.IsFetus and bomb.FrameCount == 1) then
                if (Seija:WillPlayerNerf(player)) then
                    bomb:SetExplosionCountdown(90);
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, PostBombUpdate)

    -- NPC.
    local function PostNPCUpdate(mod, npc)
        if (Seija:IsBloodRightsBleed(npc)) then
            npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT);
        end
        local BonusUFO = THI.Monsters.BonusUFO;
        if (npc.Type == BonusUFO.Type and npc.Variant == BonusUFO.Variant) then
            if (npc:IsFrame(30, 0)) then
                local player = GetSpawnerPlayer(npc);
                if (player and Seija:WillPlayerNerf(player)) then
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DANMAKU)
                    for layer = 1, 3 do
                        local speed = 6 + layer
                        local angleInternal = layer * 20;

                        local color = Color.Default;
                        local colorID = npc.SubType;
                        if (colorID == BonusUFO.SubTypes.RAINBOW) then
                            colorID = layer - 1;
                        end
                        if (colorID == 0) then
                            color = Color(1,1,1,1,0.5,0,0);
                        elseif (colorID == 1) then
                            color = Color(1,1,1,1,0,0,0.5);
                        elseif (colorID == 2) then
                            color = Color(1,1,1,1,0,0.5,0);
                        end
                        ufoParams.Color = color;

                        for i = angleInternal, 360, angleInternal do
                            local vel = Vector.FromAngle(i) * speed;
                            npc:FireProjectiles (npc.Position, vel, 0, ufoParams )
                        end
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)

    local function PostUpdate(mod)
        local data = GetGlobalTempData(false);
        if (data) then
            if (data.AcidRainTimeout > 0) then
                data.AcidRainTimeout = data.AcidRainTimeout - 1;
                for i = 1, 6 do
                    FallRaindrop();
                end
                local room = Game():GetRoom();
                if (room:GetFrameCount() % 2 == 1) then
                    for _, ent in ipairs(Isaac.GetRoomEntities()) do
                        if (ent:IsEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            ent:TakeDamage(ent.MaxHitPoints * 0.3 / 450, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(nil), 0);
                            ent:TakeDamage(100 / 450, DamageFlag.DAMAGE_CRUSH, EntityRef(nil), 0);
                        end
                    end
                end
                
                local sfx = SFXManager();
                if (not sfx:IsPlaying(THI.Sounds.SOUND_ACID_RAIN)) then
                    sfx:Play(THI.Sounds.SOUND_ACID_RAIN, 1, 2, true);
                end
            else
                local sfx = SFXManager();
                if (sfx:IsPlaying(THI.Sounds.SOUND_ACID_RAIN)) then
                    sfx:Stop(THI.Sounds.SOUND_ACID_RAIN);
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)
    
    -- Familiar.
    local function PostFamiliarInit(mod, familiar)
        local player = familiar.Player;
        if (player) then
            if (Seija:WillPlayerBuff(player)) then
                -- Punching Bag.
                if (familiar.Variant == FamiliarVariant.PUNCHING_BAG) then
                    --familiar.CollisionDamage = math.max(familiar.CollisionDamage, 15);
                    familiar.Mass = 100;
                end
            end
        end

    end
    Seija:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostFamiliarInit)

    local function PostFamiliarUpdate(mod, familiar)
        local player = familiar.Player;
        if (player) then
            if (Seija:WillPlayerBuff(player)) then
                local hasBFF = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS);
                local hasLullaby = player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY);
                local damageMulti = 1;
                local delayMulti = 1;
                if (hasBFF) then
                    damageMulti = 2;
                end
                if (hasLullaby) then
                    delayMulti = 0.5;
                end
                -- Abel.
                if (familiar.Variant == FamiliarVariant.ABEL) then
                    if (familiar:IsFrame(7, 0)) then
                        local vel = Vector(0, -Random() % 1000 / 1000 * 5 - 10);
                        local pos = familiar.Position + RandomVector() * (Random() % 1000 / 1000 * 10);
                        local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, pos, vel, familiar):ToEffect();
                        smoke.LifeSpan = 16;
                        smoke.Timeout = 16;
                        smoke.SpriteScale = Vector(0.5, 0.5);
                        smoke.DepthOffset = -2000;
                        smoke:SetColor(Color(1, 1, 0.5, 0.8, 1, 0.2, 0), -1, 0);
                        for _, ent in ipairs(Isaac.FindInRadius(familiar.Position, 40, EntityPartition.ENEMY)) do
                            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                ent:TakeDamage(30 * damageMulti, 0, EntityRef(familiar), 0);
                                ent:AddBurn(EntityRef(familiar), 60, player.Damage * damageMulti);
                            end
                        end
                    end
                    local data = GetFamiliarTempData(familiar, true);
                    local fam2Player = (player.Position - familiar.Position);
                    local laserAngle = fam2Player:GetAngleDegrees();
                    local laserDistance = fam2Player:Length();
                    if (not data.AbelLaser or not data.AbelLaser:Exists()) then
                        data.AbelLaser = EntityLaser.ShootAngle(2, familiar.Position, laserAngle, 0, familiar.PositionOffset, familiar);
                        
                    else
                        data.AbelLaser.Angle = laserAngle;
                        data.AbelLaser.CollisionDamage = player.Damage * damageMulti;
                    end
                    data.AbelLaser.MaxDistance = laserDistance;
                end

                -- Best Bud.
                if (familiar.Variant == FamiliarVariant.BEST_BUD) then
                    local data = GetFamiliarTempData(familiar, true);

                    if (data.BestBudTargetPos) then
                        data.BestBudTimeout = data.BestBudTimeout - 1;
                        local vel = data.BestBudTargetPos - familiar.Position;

                        local percent
                        if (data.BestBudTimeout >= 7) then
                            percent = (10 - data.BestBudTimeout) / 3
                        else
                            percent = (data.BestBudTimeout / 6) ^ 2;
                        end
                        familiar.Velocity = vel * percent + familiar.Velocity * (1 - percent);
                        if (data.BestBudTimeout < 0) then
                            data.BestBudHitEnemies = nil;
                            data.BestBudTargetPos = nil;
                        end
                    else
                        if (familiar:IsFrame(5, 0)) then
                            local nearest, nearestDis;
                            for i, ent in ipairs(Isaac.FindInRadius(familiar.Position, 80, EntityPartition.ENEMY)) do
                                if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                    local dis = ent.Position:Distance(familiar.Position);
                                    if (not nearest or nearestDis > dis) then
                                        nearest = ent;
                                        nearestDis = dis;
                                    end
                                end
                            end
                            if (nearest) then
                                data.BestBudHitEnemies = {};
                                data.BestBudTargetPos = nearest.Position;
                                data.BestBudTimeout = 10;
                            end
                        end
                    end
                end

                -- Isaac's Heart
                if (familiar.Variant == FamiliarVariant.ISAACS_HEART) then
                    for i, ent in ipairs(Isaac.FindInRadius(familiar.Position, 80, EntityPartition.ENEMY)) do
                        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            local dis = ent.Position:Distance(familiar.Position);
                            ent:AddVelocity((ent.Position - familiar.Position):Resized(math.max(0, 60 - dis)))
                        end
                    end
                end
                
                -- Punching Bag.
                if (familiar.Variant == FamiliarVariant.PUNCHING_BAG) then
                    for i, ent in ipairs(Isaac.FindInRadius(familiar.Position, 100, EntityPartition.ENEMY)) do
                        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            local dis = ent.Position:Distance(familiar.Position);
                            ent.Velocity = ent.Velocity + (familiar.Position- ent.Position):Resized(3);
                        end
                    end
                end
                -- Key Bum.
                if (familiar.Variant == FamiliarVariant.KEY_BUM) then
                    local spr = familiar:GetSprite()
                    if (spr:GetAnimation() == "Spawn" and spr:GetFrame() == 0) then
                        local pos = Game():GetRoom():FindFreePickupSpawnPosition(familiar.Position);
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_LATCH_KEY, pos, Vector.Zero, familiar);
                    end
                end
                -- Obsessed Fan.
                if (familiar.Variant == FamiliarVariant.OBSESSED_FAN) then
                    if (familiar:IsFrame(math.floor(15 / damageMulti), 0)) then
                        local enemy;
                        for i, ent in ipairs(Isaac.GetRoomEntities()) do
                            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                enemy = ent;
                                break;
                            end
                        end
                        if (enemy) then
                            player:AddBlueFlies(1, familiar.Position, enemy)
                        end
                    end
                end
                -- Hushy
                if (familiar.Variant == FamiliarVariant.HUSHY) then
                    local interval = math.ceil(6 * delayMulti);
                    if (familiar:IsFrame(interval, 0)) then
                        if (player:GetFireDirection() >= 0) then
                            local oriVel = Inputs:GetShootingVector(player) * 20;
                            for i = 1, 3 do
                                local vel = oriVel:Rotated((i - 2) * 10)
                                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.MULTIDIMENSIONAL, 0, familiar.Position, vel, familiar):ToTear();
                                tear.CollisionDamage = player.Damage * 1 * damageMulti;
                                tear.Scale = Math.GetTearScaleByDamage(tear.CollisionDamage);
                                tear:AddTearFlags(TearFlags.TEAR_CONTINUUM |TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_WIGGLE);
                                tear.FallingAcceleration = -0.07;
                                tear.FallingSpeed = 1
                            end
                        end
                    end
                end
            end
            
            if (Seija:WillPlayerNerf(player)) then
                -- Psy Fly.
                if (familiar.Variant == FamiliarVariant.PSY_FLY) then
                    familiar.Velocity = familiar.Velocity * 0.3;
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFamiliarUpdate)

    local function PostFamiliarCollision(mod, familiar, other, low)
        local player = familiar.Player;
        if (player) then
            if (Seija:WillPlayerBuff(player)) then
                local hasBFF = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS);
                local damageMulti = 1;
                if (hasBFF) then
                    damageMulti = 2;
                end
                -- Best Bud.
                if (familiar.Variant == FamiliarVariant.BEST_BUD) then
                    if (other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        
                        local data = GetFamiliarTempData(familiar, false);

                        if (data and data.BestBudHitEnemies) then
                            local hash = GetPtrHash(other);
                            if (not data.BestBudHitEnemies[hash]) then
                                data.BestBudHitEnemies[hash] = true;
                                local damage = 10 + Game():GetLevel():GetAbsoluteStage() * 5;
                                damage = damage * damageMulti;
                                other:TakeDamage(damage, 0, EntityRef(familiar), 0);
                                other:AddConfusion(EntityRef(familiar), 30);
                                other:AddVelocity((other.Position - player.Position):Resized(20));
                                Game():ShakeScreen(5);
                                SFXManager():Play(SoundEffect.SOUND_PUNCH);
                            end
                        end
                    end
                end
                -- Punching Bag.
                if (familiar.Variant == FamiliarVariant.PUNCHING_BAG) then
                    if (other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        
                        other:TakeDamage(20 * damageMulti, 0, EntityRef(familiar), 0);
                        other:AddVelocity((other.Position - familiar.Position):Resized(20));
                        Game():ShakeScreen(5);
                        SFXManager():Play(SoundEffect.SOUND_PUNCH);
                    end
                end
            end
        end
    end
    Seija:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PostFamiliarCollision)
    -- Pickups.

    local function PreSpawnCleanAward(mod, rng, position)
        local jarPlayer;
        local batteryPackPlayer;
        local luck = 0;
        for p, player in Players.PlayerPairs() do
            if (player.Variant == 0) then
                luck = luck + player.Luck;
            end

            if (Seija:WillPlayerBuff(player)) then
                if (not jarPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_THE_JAR)) then
                    jarPlayer = player;
                end
                if (not batteryPackPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY_PACK)) then
                    batteryPackPlayer = player;
                end
            end

            if (Seija:WillPlayerNerf(player)) then
                for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
                    -- D Infinity.
                    if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_D_INFINITY) then
                        if (Random() % 100 < 33) then
                            local charge = player:GetActiveCharge(slot);
                            local batteryCharge = player:GetBatteryCharge(slot);
                            local result = math.max(0, charge + batteryCharge - 1);
                            player:SetActiveCharge(result, slot)
                            SFXManager():Play(SoundEffect.SOUND_BATTERYDISCHARGE)
                        end
                    end
                end
            end
        end
        -- The Jar.
        if (jarPlayer) then
            local pos = Game():GetRoom():FindFreePickupSpawnPosition(position);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, pos, Vector.Zero, nil);
        end
        -- Battery Pack.
        if (batteryPackPlayer) then
            local chance = 100 / math.max(1, 16 - luck);
            if (rng:RandomInt(100) < chance) then
                local pos = Game():GetRoom():FindFreePickupSpawnPosition(position);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0, pos, Vector.Zero, nil);
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, PreSpawnCleanAward);

    local function PostPickupSelection(mod, pickup, variant, subtype)
        local batteryPackPlayer;
        for p, player in Players.PlayerPairs() do
            if (Seija:WillPlayerBuff(player)) then
                if (not batteryPackPlayer and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY_PACK)) then
                    batteryPackPlayer = player;
                end
            end
        end
        -- Battery Pack.
        if (variant == PickupVariant.PICKUP_LIL_BATTERY) then
            if (batteryPackPlayer) then
                local rng = batteryPackPlayer:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BATTERY_PACK);
                if (subtype == BatterySubType.BATTERY_MICRO) then
                    subtype = BatterySubType.BATTERY_NORMAL
                end
                if (subtype == BatterySubType.BATTERY_NORMAL) then
                    if (rng:RandomInt(100) < 5) then
                        subtype = BatterySubType.BATTERY_MEGA;
                    end
                end
                return { variant, subtype };
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, PostPickupSelection);

    local function PostPickupInit(mod, pickup)
        if (Game():GetRoom():GetFrameCount() >= 1) then
            if (pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == 1) then
                local pageantPlayer;
                for p, player in Players.PlayerPairs() do
                    if (Seija:WillPlayerBuff(player)) then
                        if (player:HasCollectible(CollectibleType.COLLECTIBLE_PAGEANT_BOY)) then
                            pageantPlayer = pageantPlayer or player;
                        end
                    end
                end

                -- Pageant Boy.
                if (pageantPlayer) then
                    local rdm = pickup.InitSeed % 100;
                    local variant;
                    if (rdm < 2) then -- Lucky Penny.
                        variant = CoinSubType.COIN_LUCKYPENNY;
                    elseif (rdm < 5) then -- Golden Penny.
                        variant = CoinSubType.COIN_GOLDEN;
                    elseif (rdm < 10) then -- Dime.
                        variant = CoinSubType.COIN_DIME;
                    elseif (rdm < 20) then -- Nickel.
                        variant = CoinSubType.COIN_NICKEL;
                    end
                    if (variant) then
                        pickup:Morph(pickup.Type, pickup.Variant, variant, true, true, false);
                    end
                end
            end
        end


        -- Little Baggy.
        if (pickup.Type == 5 and pickup.Variant == PickupVariant.PICKUP_PILL and pickup.SubType & PillColor.PILL_COLOR_MASK > 0 and pickup.SubType & PillColor.PILL_GIANT_FLAG <= 0) then
            for p, player in Players.PlayerPairs() do
                if (Seija:WillPlayerBuff(player)) then
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_BAGGY)) then
                        pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType | PillColor.PILL_GIANT_FLAG, true, true, true)
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInit)

    -- Lasers.
    local function PostLaserInit(mod, laser)
        local player = GetSpawnerPlayer(laser);
        if (not player) then
            local spawner = laser.SpawnerEntity;
            if (spawner and spawner.Type == EntityType.ENTITY_FAMILIAR) then
                if (spawner.Variant == FamiliarVariant.INCUBUS or spawner.Variant == FamiliarVariant.TWISTED_BABY) then
                    player = spawner:ToFamiliar().Player;
                end
            end
        end

        if (player) then
            -- Brimstone.
            if (laser.Variant == 1 or laser.Variant == 9 or laser.Variant == 11 or laser.Variant == 14) then
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) and Seija:WillPlayerNerf(player)) then
                    local distance = player.TearRange / 3;
                    if (laser.MaxDistance > 0 and laser.MaxDistance < distance) then
                        distance = laser.MaxDistance;
                    end
                    laser:SetMaxDistance(distance);
                end
            end
            -- Revalation.
            if (laser.Variant == 5) then
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_REVELATION) and Seija:WillPlayerNerf(player)) then
                    local distance = player.TearRange / 3;
                    if (laser.MaxDistance > 0 and laser.MaxDistance < distance) then
                        distance = laser.MaxDistance;
                    end
                    laser:SetMaxDistance(distance);
                end
            end
            -- Athame (Obsoleted)
            -- if (laser.Variant == 1 and laser.SubType == 3) then
            --     if (player:HasCollectible(CollectibleType.COLLECTIBLE_ATHAME) and Seija:WillPlayerBuff(player)) then
            --         laser.BlackHpDropChance = laser.BlackHpDropChance + 0.2;
            --     end
                
            --     -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID) and Seija:WillPlayerNerf(player)) then
            --     --     print(laser.TearFlags);
            --     --     -- laser.TearFlags = laser.TearFlags | TearFlags.TEAR_EXPLOSIVE;
            --     --     -- print(laser.TearFlags);
            --     -- end
            -- end
            -- Mega Blast.
            if (laser.Variant == 6 and CompareEntity(laser.SpawnerEntity, player)) then
                if (Seija:WillPlayerNerf(player)) then
                    local distance = player.TearRange / 3;
                    if (laser.MaxDistance > 0 and laser.MaxDistance < distance) then
                        distance = laser.MaxDistance;
                    end
                    laser:SetMaxDistance(distance);
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_LASER_INIT, PostLaserInit)

    -- Tears.
    local function PostFireTear(mod, tear)
        local player = GetSpawnerPlayer(tear);
        if (player) then
            if (Seija:WillPlayerBuff(player)) then
                -- My Reflection Tear Variant.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)) then
                    if (Tears:CanOverrideVariant(Seija.ShurikenVariant,tear.Variant)) then
                        tear:ChangeVariant(Seija.ShurikenVariant);
                    end
                    -- Add shuriken tear flag. (Obsoleted)
                    -- Tears.GetModTearFlags(tear, true):Add(Tears.TearFlags.SHURIKEN)
                end

                -- Strange Attractor.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR)) then
                    Tears.GetModTearFlags(tear, true):Add(Tears.TearFlags.SHOCKS_ENEMY)
                end

                -- Glaucoma.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA)) then
                    if (not tear:HasTearFlags(TearFlags.TEAR_PERMANENT_CONFUSION)) then
                        local value = Random() % 10000 / 10000;
                        local thresold = 1 / math.max(2, 11 - player.Luck);
                        if (value < thresold) then
                            tear:AddTearFlags(TearFlags.TEAR_PERMANENT_CONFUSION);
                            if (tear.Variant == TearVariant.BLUE) then
                                tear:ChangeVariant(TearVariant.GLAUCOMA);
                            elseif (tear.Variant == TearVariant.BLOOD) then
                                tear:ChangeVariant(TearVariant.GLAUCOMA_BLOOD);
                            end
                        end
                    end
                end

                -- Spider Baby.
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDERBABY)) then
                    
                    local value = Random() % 10000 / 10000;
                    local thresold = 1 / math.max(2, 10 - player.Luck);
                    if (value < thresold) then
                        --tear:AddTearFlags(TearFlags.TEAR_EGG);
                        Tears.GetModTearFlags(tear, true):Add(Tears.TearFlags.ReverieSpiderWeb);
                        if (Tears:CanOverrideVariant(TearVariant.EGG, tear.Variant)) then
                            tear:ChangeVariant(TearVariant.EGG);
                        end
                    end
                end
            end
            if (Seija:WillPlayerNerf(player)) then
                if (tear.Variant == 50 and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION)) then
                    if (tear.InitSeed % 100 < 5) then
                        tear:Remove();
                        local unborn = Isaac.Spawn(EntityType.ENTITY_UNBORN, 0, 0, tear.Position, tear.Velocity, player):ToNPC();
                        unborn:AddEntityFlags(EntityFlag.FLAG_AMBUSH);
                        unborn:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
                        unborn.CanShutDoors = false;
                    end
                end
            end
        end

    end
    Seija:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PostFireTear)

    -- Cain's Other Eye. (Obsoleted)
    -- local function PostTearInit(mod, tear)
    --     if (tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and tear.SpawnerEntity.Variant == FamiliarVariant.CAINS_OTHER_EYE) then
    --         local familiar = tear.SpawnerEntity:ToFamiliar();
    --         local player = familiar.Player;
    --         if (player and Seija:WillPlayerBuff(player)) then
    --             local target, targetDis;
    --             for _, ent in ipairs(Isaac.GetRoomEntities()) do
    --                 if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
    --                     local dis = ent.Position:Distance(familiar.Position);
    --                     if (not target or targetDis > dis) then
    --                         target = ent;
    --                         targetDis = dis;
    --                     end
    --                 end
    --             end
    --             local angle = Inputs.GetRawShootingVector(player, familiar.Position):GetAngleDegrees();
    --             if (target) then
    --                 angle = (target.Position - familiar.Position):GetAngleDegrees();
    --             end
    --             local laser = EntityLaser.ShootAngle(1, familiar.Position, angle, 2, familiar.PositionOffset + Vector(0, -10), familiar);
    --             laser.CollisionDamage = player.Damage;
    --             tear:Remove();
    --         end
    --     end
    -- end
    -- Seija:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, PostTearInit)

    local function PostTearUpdate(mod, tear)
        -- Shuriken Update.
        if (tear.Variant == Seija.ShurikenVariant) then
            local sprite = tear:GetSprite();
            sprite:Play("Rotate" .. Tears.GetTearAnimationIndexByScale(tear.Scale, Tears.Animation.ROTATE));
        end


        
        -- Strange Attractor.
        local flags = Tears.GetModTearFlags(tear, false)
        if (flags) then
            if (flags:Has(Tears.TearFlags.SHOCKS_ENEMY)) then
                if (tear:IsFrame(5, 0)) then
                    local pos = tear.Position;
                    local radius = 80;
                    if (Game():GetRoom():HasWater()) then
                        radius = radius * 3;
                    end
                    for _, ent in ipairs(Isaac.FindInRadius(pos, tear.Size + radius, EntityPartition.ENEMY)) do
                        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, LaserSubType.LASER_SUBTYPE_LINEAR, pos, Vector.Zero, tear):ToLaser();
                            laser.Timeout = 3;
                            laser.OneHit = true;
                            laser.CollisionDamage = tear.CollisionDamage;
                            laser.PositionOffset = Vector(0, -10);
                            laser.Parent = tear;
                            laser.DisableFollowParent = true;

                            local ent2Source = ent.Position - pos;
                            if (ent2Source:Length() < 0.1) then
                                ent2Source = Vector(0, 1);
                            end
                            ent2Source = ent2Source:Resized(math.max(8, ent2Source:Length()))
                            laser.AngleDegrees = ent2Source:GetAngleDegrees();
                            laser.MaxDistance = ent2Source:Length() + ent.Size;
                            laser.Position = laser.Position - ent2Source:Normalized() * ent.Size / 2;
                            laser.TearFlags = laser.TearFlags | TearFlags.TEAR_PIERCING;
                        end
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate)

    local function PreTearCollision(mod, tear, other, low)
        local flags = Tears.GetModTearFlags(tear, false)
        local enemyActive = other:IsActiveEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY);
        if (flags) then
            if (flags:Has(Tears.TearFlags.SHURIKEN)) then
                if (other:IsVulnerableEnemy()) then
                    local damageFlags = 0;
                    other:TakeDamage(tear.CollisionDamage, damageFlags, EntityRef(tear), 0);
                    --return true;
                end
            end
            if (flags:Has(Tears.TearFlags.ReverieSpiderWeb) and enemyActive) then
                local hash = GetPtrHash(other);
                local data = GetTearTempData(tear, true);
                if (not data.SpiderWebHitEnemies[hash]) then
                    data.SpiderWebHitEnemies[hash] = true;

                    local Web = THI.Effects.SpiderbabyWeb;
                    local web = Isaac.Spawn(Web.Type, Web.Variant, Web.SubType, tear.Position, Vector.Zero, tear.SpawnerEntity):ToEffect();
                    web.CollisionDamage = tear.CollisionDamage;
                    local webFlags = 0;
                    if (tear:HasTearFlags(TearFlags.TEAR_POISON) or tear:HasTearFlags(TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)) then
                        webFlags = webFlags | Web.Flags.POISON;
                    end
                    if (tear:HasTearFlags(TearFlags.TEAR_BURN)) then
                        webFlags = webFlags | Web.Flags.FIRE;
                    end
                    if (tear:HasTearFlags(TearFlags.TEAR_ICE)) then
                        webFlags = webFlags | Web.Flags.ICE;
                    end
                    if (tear:HasTearFlags(TearFlags.TEAR_JACOBS) or tear:HasTearFlags(TearFlags.TEAR_LASER)) then
                        webFlags = webFlags | Web.Flags.ELEC;
                    end
                    web.DamageSource = webFlags;

                    local player = nil;
                    local spawner = tear.SpawnerEntity;
                    if (spawner) then
                        local spawnerPlayer = spawner:ToPlayer();
                        if (spawnerPlayer) then
                            player = spawnerPlayer;
                        else
                            local spawnerSpawner = spawner and spawner.SpawnerEntity;
                            local p = spawnerSpawner:ToPlayer()
                            if (p) then
                                player = p;
                            end
                        end
                    end
                    local seed = tear.InitSeed;
                    for i = 1, seed % 3 + 1 do
                        if (player) then
                            player:ThrowBlueSpider(tear.Position, tear.Position + RandomVector() * 20);
                        else
                            local spider = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, tear.Position, RandomVector() * 5, tear.SpawnerEntity):ToFamiliar();
                            spider.OrbitSpeed = -6;
                            spider.OrbitDistance = Vector(0, 4);
                        end
                    end
                    
                    SFXManager():Play(SoundEffect.SOUND_BOIL_HATCH);
                end
            end
        end

        if (tear:HasTearFlags(TearFlags.TEAR_PERMANENT_CONFUSION) and enemyActive) then
            local player = GetSpawnerPlayer(tear);

            if (player and Seija:WillPlayerBuff(player)) then

                local tearData = GetTearTempData(tear, true);
                local hash = GetPtrHash(other);
                if (not tearData.GlaucomaHitEnemies[hash]) then
                    tearData.GlaucomaHitEnemies[hash] = true;

                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, tear.Position, Vector.Zero, tear);
                    local poofSpr = poof:GetSprite();
                    poofSpr:Load("gfx/reverie/flashbang.anm2", true);
                    poofSpr:Play("Flash");
                    SFXManager():Play(SoundEffect.SOUND_BULB_FLASH);
                    
                    for _, ent in ipairs(Isaac.FindInRadius(tear.Position, 160, EntityPartition.ENEMY | EntityPartition.BULLET)) do
                        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                            ent:TakeDamage(player.Damage * 2, 0, EntityRef(tear), 0);
                            ent:AddConfusion(EntityRef(tear), 90);
                        elseif (ent.Type == EntityType.ENTITY_PROJECTILE) then
                            local proj = ent:ToProjectile();
                            if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                                proj:Remove();
                            end
                        end
                    end
                end
            end
        end
        
    end
    Seija:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.LATE, PreTearCollision)

    local function PostTearRemove(mod, ent)
        local tear = ent:ToTear();
        if (tear.Variant == Seija.ShurikenVariant) then
    
            THI.SFXManager:Play(SoundEffect.SOUND_SCYTHE_BREAK, 1, 0, false, 1.5);
            local color = Color(1.5, 1.5, 1.5, 1, 0, 0, 0);
            color = color * tear:GetColor();
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_POOF, 0, tear.Position, Vector.Zero, tear);
            poof:SetColor(color, -1, 0, false, false);
            poof.SpriteScale = poof.SpriteScale * tear.Scale;
            for i = 1, tear.Scale ^ 2 do
                local tooth = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, tear.Position,
                    RandomVector() * (Random() % 100 / 100) * 3, tear);
                tooth:SetColor(color, -1, 0, false, false);
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostTearRemove, EntityType.ENTITY_TEAR);
    
    -- Effects.
    local function PostEffectUpdate(mod, effect)
        if (effect.Variant == EffectVariant.TARGET and effect.FrameCount == 1 and effect.LifeSpan > 0) then
            local player = GetSpawnerPlayer(effect);
            if (player) then
                -- Epic Fetus.
                if (Seija:WillPlayerNerf(player)) then
                    effect.LifeSpan = 100;
                    effect.Timeout = 100;
                end
            end
        end
        if (effect.Variant == EffectVariant.CRACK_THE_SKY and effect.FrameCount == 1) then
            if (effect.SubType == 1) then
                local player;
                local spawner = effect.SpawnerEntity;
                if (spawner and spawner.Type == EntityType.ENTITY_TEAR) then
                    local tearSpawner = spawner.SpawnerEntity;
                    if (tearSpawner) then
                        player = tearSpawner:ToPlayer();
                    end
                end
                if (player) then
                    -- Holy Light.
                    if (Seija:WillPlayerNerf(player)) then
                        effect.CollisionDamage = player.Damage / 3;
                    end
                end
            end
        end
        -- Linger Bean Cloud.
        if (effect.Variant == EffectVariant.BROWN_CLOUD) then
            local player = GetSpawnerPlayer(effect);
            if (player) then
                if (Seija:WillPlayerBuff(player)) then
                    local data = GetEffectTempData(effect, true);
                    if (effect:IsFrame(5, 0)) then
                        local nearest, nearestDis;
                        for i, ent in ipairs(Isaac.GetRoomEntities()) do
                            if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                local dis = ent.Position:Distance(player.Position);
                                if (not nearest or nearestDis > dis) then
                                    nearest = ent;
                                    nearestDis = dis;
                                end
                            end
                        end
                        data.BrownCloudTargetPos = nil;
                        if (nearest) then
                            data.BrownCloudTargetPos = nearest.Position;
                        end
                    end
                    if (data.BrownCloudTargetPos) then
                        effect:AddVelocity((data.BrownCloudTargetPos - effect.Position):Resized(3))
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate)

    local function PostUseItem(mod, item, rng, player, flags, varData)
        if (Seija:WillPlayerBuff(player) and flags & UseFlag.USE_OWNED > 0) then
            local game = Game();
            local room = game:GetRoom();
            -- Poop.
            if (item == CollectibleType.COLLECTIBLE_POOP) then
                local pos = player.Position;
                local gridEntity = room:GetGridEntityFromPos(pos);
                if (gridEntity and gridEntity:GetType() == GridEntityType.GRID_POOP and gridEntity:GetVariant() == 0) then
                    
                    gridEntity:SetVariant(3);
                    gridEntity:Init(gridEntity.Desc.SpawnSeed);
                end
            elseif (item == CollectibleType.COLLECTIBLE_KAMIKAZE) then-- Kamikaze.
                local pos = player.Position;
                room:MamaMegaExplosion(pos);
            elseif (item == CollectibleType.COLLECTIBLE_MOMS_PAD) then-- Mom's Pad.
                for _, ent in ipairs(Isaac.GetRoomEntities()) do
                    if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        ent:TakeDamage(40, DamageFlag.DAMAGE_IGNORE_ARMOR | DamageFlag.DAMAGE_SPAWN_RED_HEART, EntityRef(player), 0);
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_TELEPORT) then-- Teleport!
                if (flags & UseFlag.USE_OWNED > 0) then
                    UseTeleport(player, rng, flags);
                end
            elseif (item == CollectibleType.COLLECTIBLE_PORTABLE_SLOT) then-- Portable Slot
                
                if (rng:RandomInt(100) < 50 and player:GetSprite():IsPlaying("Sad")) then
                    player:AddCoins(1);
                end
            elseif (item == CollectibleType.COLLECTIBLE_BEAN) then-- The Bean
                for _, ent in ipairs(Isaac.GetRoomEntities()) do
                    if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        game:Fart (ent.Position, 85, player);
                        ent:AddPoison(EntityRef(player), 150, player.Damage);
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_RAZOR_BLADE) then-- Razor Blade
                player:UseCard(Card.CARD_SOUL_MAGDALENE, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER);
            elseif (item == CollectibleType.COLLECTIBLE_BLOOD_RIGHTS) then-- Blood Rights
                for _, ent in ipairs(Isaac.GetRoomEntities()) do
                    if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                        ent:TakeDamage(40, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0);
                        Seija:SetBloodRightsBleed(ent, true);
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_PLAN_C) then-- Plan C
                player:AddCollectible(CollectibleType.COLLECTIBLE_1UP, 0, false)
            -- elseif (item == CollectibleType.COLLECTIBLE_D10) then-- D10 (Obsoleted)
            --     for _, ent in ipairs(Isaac.GetRoomEntities()) do
            --         if (not ent:IsBoss() and ent:IsActiveEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            --             if (rng:RandomInt(100) < 80) then
            --                 local npc = ent:ToNPC();
            --                 npc:Remove();
            --                 Isaac.Spawn( EntityType.ENTITY_FLY, 0, 0, npc.Position, Vector.Zero, player);
            --             end
            --         end
            --     end
            elseif (item == CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS) then-- Book of Secrets
                if (flags & UseFlag.USE_OWNED > 0) then
                    for i = 1, 3 do
                        player:UseActiveItem(item, 0);
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_DATAMINER) then-- Dataminer
                local data = GetPlayerData(player, true);
                data.DataMinerTimes = data.DataMinerTimes + 1;
                player:AddCacheFlags(CacheFlag.CACHE_ALL);
                player:EvaluateItems();
            elseif (item == CollectibleType.COLLECTIBLE_SCOOPER) then-- Scooper
                for i = 1, 5 do
                    player:UseActiveItem(item, 0);
                end

                local data = GetPlayerData(player, true);
                data.ScooperDamage = data.ScooperDamage + 5 * 5;
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();

            elseif (item == CollectibleType.COLLECTIBLE_LEMON_MISHAP) then -- Lemon Mishap.
                local data = GetGlobalTempData(true);
                data.AcidRainTimeout = (data.AcidRainTimeout or 0) + 900;
                
            end
        end
        if (item == CollectibleType.COLLECTIBLE_CLICKER) then-- Clicker
            local tempData = GetPlayerTempData(player, false);
            if (tempData and tempData.SeijaClicker) then
                local seed = math.max(1, rng:Next())
                local itemPool = Game():GetItemPool();
                local pool = itemPool:GetPoolForRoom(RoomType.ROOM_ERROR, seed);
                ClickerGetting = true;
                local item = itemPool:GetCollectible(pool, true, seed, CollectibleType.COLLECTIBLE_BRIMSTONE);
                ClickerGetting = false;
                local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true);
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, pos, Vector.Zero,player);
            end
        end
        
        if (Seija:WillPlayerNerf(player) and flags & UseFlag.USE_OWNED > 0) then
            if (item == CollectibleType.COLLECTIBLE_SATANIC_BIBLE) then-- Satanic Bible
                player:AddBrokenHearts(1);
            elseif (item == CollectibleType.COLLECTIBLE_D6) then-- D6
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    if (ent.SubType > 0 and ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
                        local value = rng:RandomInt(100);
                        if (value < 30) then
                            ent:Remove();
                        end
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_FLIP) then-- Flip
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    local value = rng:RandomInt(100);
                    if (value < 50) then
                        ent:Remove();
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position,Vector.Zero, nil);
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_VOID) then-- Void
                local data = GetPlayerData(player, true);
                local tempData = GetPlayerTempData(player, false);
                local collectibleCount = 0;
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    local pickup = ent:ToPickup();
                    if (ent.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and not pickup:IsShopItem()) then
                        collectibleCount = collectibleCount + 1;
                    end
                end
                if (tempData and tempData.VoidAbyssLifting) then
                    collectibleCount = collectibleCount + 1;
                end
                data.VoidTimes = data.VoidTimes + collectibleCount;
                player:AddCacheFlags(CacheFlag.CACHE_ALL);
                player:EvaluateItems();
            elseif (item == CollectibleType.COLLECTIBLE_ABYSS) then-- Abyss
                local data = GetPlayerData(player, true);
                local collectibleCount = 0;
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    local pickup = ent:ToPickup();
                    if (ent.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and not pickup:IsShopItem()) then
                        collectibleCount = collectibleCount + 1;
                    end
                end
                local tempData = GetPlayerTempData(player, false);
                if (tempData and tempData.VoidAbyssLifting) then
                    collectibleCount = collectibleCount + 1;
                end
                data.AbyssTimes = data.AbyssTimes + collectibleCount;
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
                player:EvaluateItems();
                
            elseif (item == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING) then-- Bag of Crafting
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    local pickup = ent:ToPickup();
                    if (ent.SubType > 0 and ent.FrameCount == 0) then
                        local value = rng:RandomInt(100);
                        if (value < 75) then
                            ent:Remove();
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player);
                            SFXManager():Stop(SoundEffect.SOUND_THUMBSUP);
                            SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
                        end
                        break;
                    end
                end
            elseif (item == CollectibleType.COLLECTIBLE_SPINDOWN_DICE) then-- Spindown Dice
                for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                    local value = rng:RandomInt(3);
                    if (value > 0) then
                        local subtype = ent.SubType - value
                        if (subtype > 0) then
                            local pickup = ent:ToPickup();
                            pickup:Morph(pickup.Type, pickup.Variant, subtype, true, false, false);
                            pickup.Touched = false;
                        else
                            ent:Remove();
                        end
                    end
                end
            end
        end
    end
    Seija:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseItem)
end


return Seija;