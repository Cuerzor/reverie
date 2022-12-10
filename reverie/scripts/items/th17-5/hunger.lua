local Stats = CuerLib.Stats;
local Screen = CuerLib.Screen;
local Players = CuerLib.Players;

local Hunger = ModItem("Hunger", "Hunger");

local itemConfig = Isaac.GetItemConfig();

local CollectibleHungers = {
    [CollectibleType.COLLECTIBLE_IPECAC] = -3,

    [CollectibleType.COLLECTIBLE_WAFER] = 1,
    [CollectibleType.COLLECTIBLE_GHOST_PEPPER] = 1,
    [CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE] = 1,
    [CollectibleType.COLLECTIBLE_BIRDS_EYE] = 1,
    [CollectibleType.COLLECTIBLE_ROTTEN_TOMATO] = 1,
    [CollectibleType.COLLECTIBLE_DEAD_ONION] = 1,

    [CollectibleType.COLLECTIBLE_SAD_ONION] = 2,
    [CollectibleType.COLLECTIBLE_JESUS_JUICE] = 2,
    [CollectibleType.COLLECTIBLE_MILK] = 2,
    [CollectibleType.COLLECTIBLE_APPLE] = 2,
    [CollectibleType.COLLECTIBLE_EUCHARIST] = 2,
    [CollectibleType.COLLECTIBLE_BLACK_BEAN] = 2,
    [CollectibleType.COLLECTIBLE_LINGER_BEAN] = 2,
    [CollectibleType.COLLECTIBLE_JELLY_BELLY] = 2,

    [CollectibleType.COLLECTIBLE_FRUIT_CAKE] = 3,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 3,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = 3,
    [CollectibleType.COLLECTIBLE_CHOCOLATE_MILK] = 3,
    [CollectibleType.COLLECTIBLE_MARROW] = 3,
    [CollectibleType.COLLECTIBLE_CRACK_JACKS] = 3,
    [CollectibleType.COLLECTIBLE_CANDY_HEART] = 3,

    [CollectibleType.COLLECTIBLE_BUCKET_OF_LARD] = 4,
    [CollectibleType.COLLECTIBLE_RAW_LIVER] = 4,
    [CollectibleType.COLLECTIBLE_MEAT] = 4,
    [CollectibleType.COLLECTIBLE_SAUSAGE] = 4,
    [CollectibleType.COLLECTIBLE_THUNDER_THIGHS] = 4,

    [CollectibleType.COLLECTIBLE_RED_STEW] = 10
}
local TrinketHungers = {
    -- 1：冰块，蝗虫类饰品，蟋蟀腿，线虫类饰品，血虱，虱子，水疱，幼虫
    [TrinketType.TRINKET_ICE_CUBE] = 1,
    -- Locusts
    [TrinketType.TRINKET_LOCUST_OF_DEATH] = 1,
    [TrinketType.TRINKET_LOCUST_OF_CONQUEST] = 1,
    [TrinketType.TRINKET_LOCUST_OF_FAMINE] = 1,
    [TrinketType.TRINKET_LOCUST_OF_PESTILENCE] = 1,
    [TrinketType.TRINKET_LOCUST_OF_WRATH] = 1,
    [TrinketType.TRINKET_APOLLYONS_BEST_FRIEND] = 1,

    [TrinketType.TRINKET_CRICKET_LEG] = 1,
    -- Worms
    [TrinketType.TRINKET_WHIP_WORM] = 1,
    [TrinketType.TRINKET_FLAT_WORM] = 1,
    [TrinketType.TRINKET_HOOK_WORM] = 1,
    [TrinketType.TRINKET_LAZY_WORM] = 1,
    [TrinketType.TRINKET_RING_WORM] = 1,
    [TrinketType.TRINKET_TAPE_WORM] = 1,
    [TrinketType.TRINKET_BRAIN_WORM] = 1,
    [TrinketType.TRINKET_PULSE_WORM] = 1,
    [TrinketType.TRINKET_WIGGLE_WORM] = 1,
    [TrinketType.TRINKET_RAINBOW_WORM] = 1,
    [TrinketType.TRINKET_OUROBOROS_WORM] = 1,

    [TrinketType.TRINKET_TICK] = 1,
    [TrinketType.TRINKET_LOUSE] = 1,
    [TrinketType.TRINKET_BLISTER] = 1,
    [TrinketType.TRINKET_LIL_LARVA] = 1,

    -- 2：核桃，崩掉牙，神秘糖果，犹大的舌头，该隐的眼睛，左手，索多玛的苹果，脐带，老茧，恶魔尾巴，粉红眼睛，幸运脚趾，
    -- 鲍勃的气囊，扁桃体，蝙蝠翅膀，勿忘草，小血凝块
    [TrinketType.TRINKET_WALNUT] = 2,
    [TrinketType.TRINKET_JAW_BREAKER] = 2,
    [TrinketType.TRINKET_MYSTERIOUS_CANDY] = 2,
    [TrinketType.TRINKET_JUDAS_TONGUE] = 2,
    [TrinketType.TRINKET_CAINS_EYE] = 2,
    [TrinketType.TRINKET_LEFT_HAND] = 2,
    [TrinketType.TRINKET_APPLE_OF_SODOM] = 2,
    [TrinketType.TRINKET_UMBILICAL_CORD] = 2,
    [TrinketType.TRINKET_CALLUS] = 2,
    [TrinketType.TRINKET_DAEMONS_TAIL] = 2,
    [TrinketType.TRINKET_PINKY_EYE] = 2,
    [TrinketType.TRINKET_LUCKY_TOE] = 2,
    [TrinketType.TRINKET_BOBS_BLADDER] = 2,
    [TrinketType.TRINKET_TONSIL] = 2,
    [TrinketType.TRINKET_BAT_WING] = 2,
    [TrinketType.TRINKET_MYOSOTIS] = 2,
    [TrinketType.TRINKET_LIL_CLOT] = 2,

    -- 3：黄油，裸盖菇，鱼尾，夏娃的鸟爪，猴手，巨人豆，双胞胎，冻青蛙，招财猫爪
    [TrinketType.TRINKET_BUTTER] = 3,
    [TrinketType.TRINKET_LIBERTY_CAP] = 3,
    [TrinketType.TRINKET_FISH_TAIL] = 3,
    [TrinketType.TRINKET_EVES_BIRD_FOOT] = 3,
    [TrinketType.TRINKET_MONKEY_PAW] = 3,
    [TrinketType.TRINKET_GIGANTE_BEAN] = 3,
    [TrinketType.TRINKET_THE_TWINS] = 3,
    [Isaac.GetTrinketIdByName("Frozen Frog")] = 3,
    [Isaac.GetTrinketIdByName("Fortune Cat Paw")] = 3,

    -- 4：鱼头，小孩的心脏，乌鸦的心，羊蹄，以撒的头，便当
    [TrinketType.TRINKET_FISH_HEAD] = 4,
    [TrinketType.TRINKET_CHILDS_HEART] = 4,
    [TrinketType.TRINKET_CROW_HEART] = 4,
    [TrinketType.TRINKET_GOAT_HOOF] = 4,
    [TrinketType.TRINKET_ISAACS_HEAD] = 4,
    [TrinketType.TRINKET_BAG_LUNCH] = 4,
}

local maxHunger = 1000;
local hungerCostPerFrame = 0.0833333;
local RegenerationThresold = 900;
local RegenerationCost = 20;
local maxRegenDelay = 20;
local maxDamageDelay = 150;

local StatsUpThresold = 800;
local HungryThresold = 300;

local triggerDisplayerUnit = 100;
local displayUnit = 100;
local displayDifference = 15;
local maxDisplayTime = 100;

local HungerFont = THI.Fonts.PFTempesta7;


local HungerIcon = Sprite();
HungerIcon:Load("gfx/reverie/ui/hunger.anm2", true);

local HungryStats = {
    NORMAL = 0,
    FULL = 1,
    HUNGRY = 2
}

function Hunger:SetCollectibleHunger(item, hunger)
    CollectibleHungers[item] = hunger;
end
function Hunger:SetTrinketHunger(trinket, hunger)
    TrinketHungers[trinket] = hunger;
end

function Hunger.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        if (not data._THI_HUNGER) then
            local iconSprite = Sprite();
            iconSprite:Load("gfx/reverie/ui/hunger.anm2", true);
            data._THI_HUNGER = {
                Added = {
                    Value = 0,
                    Alpha = 0,
                    Time = 0,
                },
                Displayer = {
                    Alpha = 0,
                    Time = maxDisplayTime,
                    IconSprite = iconSprite
                }
            }
        end
    end
    return data._THI_HUNGER;
end

function Hunger.GetPlayerData(player, init)
    return Hunger:GetData(player, init, function() return {
        LastHunger = maxHunger,
        Hunger = maxHunger,
        RegenDelay = 0,
        DamageDelay = maxDamageDelay,
        StatsState = 0
    } end)
end

function Hunger.GetFontColor(hunger)
    if (hunger >= RegenerationThresold) then
        return KColor(0,1,0,1);
    elseif (hunger >= StatsUpThresold) then
        return KColor(0.5,1,0.5,1);
    elseif (hunger <= 0) then
        return KColor(1,0,0,1);
    elseif (hunger < HungryThresold) then
        return KColor(1,1,0,1);
    end
    return KColor(1,1,1,1);
end

function Hunger:Feed(player, hunger)
    local data = Hunger.GetPlayerData(player, true);
    local tempData = Hunger.GetPlayerTempData(player, true);
    local beforeHunger = data.Hunger
    data.Hunger = math.max(0, math.min(maxHunger, data.Hunger + hunger * displayUnit));
    tempData.Added.Value = tempData.Added.Value + data.Hunger - beforeHunger;
    tempData.Added.Time = maxDisplayTime;
    tempData.Displayer.Time = maxDisplayTime;
    if (hunger > 0) then
        THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
    elseif (hunger < 0) then
        THI.SFXManager:Play(SoundEffect.SOUND_MEGA_PUKE);
    end
end

function Hunger.SwallowTrinket(player)
    local canEat = false;
    local feed = 0;
    local eatTrinket = 1;
    for index = 0, 1 do
        local trinket = player:GetTrinket(index);
        if (trinket > 0) then
            local hunger = TrinketHungers[trinket];
            if (hunger) then
                canEat = true;
                feed = hunger;
                eatTrinket = trinket;
                break;
            end
        end
    end
    if (canEat) then
        Hunger:Feed(player, feed);
        player:TryRemoveTrinket(eatTrinket);
        player:AnimateTrinket (eatTrinket, "UseItem", "PlayerPickup" );
    else
        local trinket = player:GetTrinket(0);
        if (trinket > 0) then
            local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME;
            player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);
            THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
            player:AnimateTrinket (trinket, "UseItem", "PlayerPickup" );
        end
    end
end

function Hunger:PostPlayerEffect(player)
    if (player:HasCollectible(Hunger.Item)) then
        local data = Hunger.GetPlayerData(player, true);
        local tempData = Hunger.GetPlayerTempData(player, true);
        local displayerData = tempData.Displayer;
        local addedData = tempData.Added;

        local hunger = data.Hunger;
        -- Restore Red hearts.
        if (data.RegenDelay > 0 )then
            data.RegenDelay = data.RegenDelay - 1;
        end
        if (hunger >= RegenerationThresold) then
            local maxHearts = player:GetEffectiveMaxHearts();
            local hearts = player:GetHearts();
            if (hearts < maxHearts) then
                if (data.RegenDelay <= 0) then
                    player:AddHearts(1);
                    data.RegenDelay = maxRegenDelay;
                    data.Hunger = data.Hunger - RegenerationCost;
                    displayerData.Time = maxDisplayTime;
                    THI.SFXManager:Play(SoundEffect.SOUND_VAMP_GULP);
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position + Vector(0, -64), Vector.Zero, player);
                    effect.DepthOffset = 74;
                end
            end
        end

        
        -- Stats Up.
        local statsState = HungryStats.NORMAL;
        if (data.Hunger >= StatsUpThresold) then
            statsState = HungryStats.FULL;
        -- Hungry
        elseif (data.Hunger < HungryThresold) then
            statsState = HungryStats.HUNGRY;
            if (player:IsExtraAnimationFinished()) then
                -- Swallow Trinkets.
                Hunger.SwallowTrinket(player);
            end
        end
        if (data.StatsState ~= statsState) then
            data.StatsState = statsState;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end
        
        -- Empty
        if (hunger <= 0) then
            data.DamageDelay = data.DamageDelay - 1;
            if (data.DamageDelay <= 0) then
                local flags = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES;
                player:TakeDamage(1, flags, EntityRef(player), 0);
                data.DamageDelay = maxDamageDelay;
            end
        else
            data.DamageDelay = maxDamageDelay;
        end

        
        -- Walk costs hunger.
        if (player:GetMovementVector():Length() > 0.1 and player.Velocity:Length() > 0.1) then
            data.Hunger = data.Hunger - hungerCostPerFrame;
        end




        data.LastHunger = data.Hunger;
        data.Hunger = math.max(0, math.min(maxHunger, data.Hunger));

        -- Set Displayer.
        if (hunger % triggerDisplayerUnit <= displayDifference or hunger <= 0 or Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
            displayerData.Time = maxDisplayTime;
        end

        local iconSprite = displayerData.IconSprite;
        local animName = "Feeded";
        if (hunger >= RegenerationThresold) then
            animName = "Full";
        elseif (hunger >= StatsUpThresold) then
            animName = "Feeded";
        elseif (hunger >= HungryThresold) then
            animName = "Normal";
        elseif (hunger > 0) then
            animName = "Hungry";
        else
            animName = "Starving";
        end
        if (iconSprite:GetAnimation() ~= animName) then
            iconSprite:Play(animName);
        end
        iconSprite:Update();
        if (displayerData.Time > 0) then
            displayerData.Time = displayerData.Time - 1;
            displayerData.Alpha = math.min(1, displayerData.Alpha + 0.1);
        else
            displayerData.Alpha = math.max(0, displayerData.Alpha - 0.1);
        end

        
        if (addedData.Time > 0) then
            addedData.Time = addedData.Time - 1;
            addedData.Alpha = math.min(1, addedData.Alpha + 0.1);
        else
            addedData.Alpha = math.max(0, addedData.Alpha - 0.1);
        end
        if (addedData.Alpha <= 0) then
            addedData.Value = 0;
        end


    end
end
Hunger:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Hunger.PostPlayerEffect);

function Hunger:OnEvaluateCahce(player, cache)
    if (player:HasCollectible(Hunger.Item)) then
        local data = Hunger.GetPlayerData(player, false);
        if (data) then
            local hunger = data.Hunger;
            if (data.StatsState == HungryStats.FULL) then
                if (cache == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed + 0.2;
                elseif (cache == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsUp(player, 1);
                elseif (cache == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 1.2);
                end
            elseif (data.StatsState == HungryStats.HUNGRY) then
                if (cache == CacheFlag.CACHE_SPEED) then
                    player.MoveSpeed = player.MoveSpeed - 0.5;
                elseif (cache == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears) return tears / 2 end);
                elseif (cache == CacheFlag.CACHE_DAMAGE) then
                    Stats:MultiplyDamage(player, 0.5);
                end
            end

        end
    end
end
Hunger:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Hunger.OnEvaluateCahce);

function Hunger:PostUsePill(effect, player, flags)
    if (flags & UseFlag.USE_MIMIC <= 0) then
        if (player:HasCollectible(Hunger.Item)) then
            Hunger:Feed(player, 0.5);
        end
    end
end
Hunger:AddCallback(ModCallbacks.MC_USE_PILL, Hunger.PostUsePill);


function Hunger:PostGainCollectible(player, item, count, touched)
    if (not touched) then
        if (player:HasCollectible(Hunger.Item)) then
            local hunger = CollectibleHungers[item];
            if (hunger) then
                Hunger:Feed(player, hunger * count);
            else
                local c = itemConfig:GetCollectible(item);
                if (c) then
                    if (c:HasTags(ItemConfig.TAG_MUSHROOM | ItemConfig.TAG_FOOD)) then
                        Hunger:Feed(player, 3 * count);
                    end
                end
            end
        end
    end
end
Hunger:AddCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, Hunger.PostGainCollectible);

function Hunger:PostNPCDeath(npc)
    
    -- if (THI.IsLunatic()) then
    --     return;
    -- end


    local game = THI.Game;
    local hasHunger = false;
    for p, player in Players.PlayerPairs() do
        if (player:HasCollectible(Hunger.Item)) then
            hasHunger = true;
            break;
        end
    end

    if (hasHunger) then
        local chance = npc.DropSeed % 30;
        if (chance < 1) then
            local room = THI.Game:GetRoom();
            local pos = room:FindFreePickupSpawnPosition (npc.Position, 0, true);
            local FoodPickup = THI.Pickups.FoodPickup;
            Isaac.Spawn(FoodPickup.Type, FoodPickup.Variant, 0, pos, Vector.Zero, npc);
        end
    end
end
Hunger:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Hunger.PostNPCDeath);

local renderOffset = Vector(-4, -52);
function Hunger:PostPlayerRender(player, offset)
    local game = THI.Game;
    -- Render Hunger.
    if (not Screen.IsReflection()) then
        if (player:HasCollectible(Hunger.Item)) then
            local data = Hunger.GetPlayerData(player, false);
            local tempData = Hunger.GetPlayerTempData(player, false);
            if (data and tempData) then
                local alpha = tempData.Displayer.Alpha;
                local addedAlpha = tempData.Added.Alpha;
                local addedValue = tempData.Added.Value;
                if (alpha > 0) then
                    local hunger = data.Hunger;

                    local renderPos = Screen.GetEntityOffsetedRenderPosition(player, offset) + renderOffset;
                    local str = string.format("%.2f", hunger / displayUnit);
                    local color = Hunger.GetFontColor(hunger);
                    color.Alpha = alpha;
                    HungerFont:DrawString (str, renderPos.X, renderPos.Y, color);

                    if (addedAlpha > 0 and addedValue ~= 0) then
                        local addedStr = string.format("%.2f", addedValue / displayUnit);
                        local addedColor = KColor(0,1,0,addedAlpha);
                        if (addedValue < 0) then
                            addedColor.Red = 1;
                            addedColor.Green = 0;
                        else
                            addedStr = "+"..addedStr;
                        end
                        HungerFont:DrawString (addedStr, renderPos.X + 24, renderPos.Y, addedColor);
                    end

                    local iconSprite = tempData.Displayer.IconSprite;
                    iconSprite.Color = Color(1,1,1,alpha, 0,0,0);
                    iconSprite:Render(renderPos + Vector(-10, 8));
                end
            end
        end
    end
    -- end
end
Hunger:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Hunger.PostPlayerRender);


function Hunger:ExecuteCommand(cmd, parameters)
    if (cmd == "hunger") then
        if (string.sub(parameters, 1, 4) == "set ") then
            local numStr = string.sub(parameters, 5);
            local value = tonumber(numStr);
            if (value) then
                local player = Isaac.GetPlayer(0);
                local data = Hunger.GetPlayerData(player, true);
                data.Hunger = value * displayUnit;
            else
                print(numStr.." is not a number.");
            end
        elseif (string.sub(parameters, 1, 4) == "add ") then
            local numStr = string.sub(parameters, 5);
            local value = tonumber(numStr);
            if (value) then
                local player = Isaac.GetPlayer(0);
                local data = Hunger.GetPlayerData(player, true);
                data.Hunger = data.Hunger + value * displayUnit;
            else
                print(numStr.." is not a number.");
            end
        end
    end
end
Hunger:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Hunger.ExecuteCommand);


return Hunger;