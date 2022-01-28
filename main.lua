

local tempData;
local tempConfig;
if (THI) then
    tempData = THI.Data;
    tempConfig = THI.Config;
end
THI = RegisterMod("Reverie", 1);
THI.Version = {
    7,10,0
}

function THI:GetVersionString()
    local versionString = "";
    for i, version in pairs(self.Version) do
        if ( i > 1) then
            versionString = versionString..".";
        end
        versionString = versionString..version;
    end
    return versionString;
end

THI.Data = tempData or {};
THI.Config = tempConfig or {};

-- Avoid Shader Crash.
THI:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

if (StageAPI) then
    StageAPI.UnregisterCallbacks(THI.Name);
end


local function IsMainmenu()
    return Game():GetLevel():GetStage() <= 0;
end


THI.Game = Game();
THI.SFXManager = SFXManager();
--THI.HUD = THI.Game:GetHUD();
--THI.Room = THI.Game:GetRoom();
--THI.Level = THI.Game:GetLevel();
--THI.ItemPool = THI.Game:GetItemPool();
--THI.Seeds = THI.Game:GetSeeds();

function THI.GetData(entity)
    local entityData = entity:GetData();
    entityData._TOUHOU_DATA = entityData._TOUHOU_DATA or {};
    return entityData._TOUHOU_DATA;
end



function THI.GetSaveGlobalData(data)
    local touhouData = data._TOUHOU_DATA or {
        Players = {},
        Global = {}
    };
    touhouData.Global = touhouData.Global or {};
    return touhouData.Global;
end


---- Save and Load -------------
function THI:GetGlobalData() return self.Data; end
function THI:SetGlobalData(data) self.Data = data; end

------------------------
-- Stage
------------------------

local Lib = include("cuerlib/main");
CuerLib = Lib;

THI.Lib = Lib;
THI.Require = Lib.Require;
local Require = THI.Require;

Lib:Register(THI, "_TOUHOU_DATA", THI.Data, THI.Data);

THI.Instruments = Require("scripts/shared/instruments");
THI.GapFloor = Require("scripts/shared/gap_floor");
THI.Shared = {};
THI.Shared.Wheelchair = include("scripts/shared/wheelchair");
THI.Shared.Wheelchair:Register(THI);

THI.Halos = Require("scripts/shared/halos");

function ModEntity(name, dataName) 
    return Lib.ModComponents.ModEntity:New(name, dataName);
end


function ModItem(name, dataName) 
    return Lib.ModComponents.ModItem:New(name, dataName);
end

---- Trinkets
function ModTrinket(name, dataName) 
    return Lib.ModComponents.ModTrinket:New(name, dataName);
end

---- Player
function ModPlayer(name, tainted, dataName) 
    return Lib.ModComponents.ModPlayer:New(name, tainted, dataName);
end

function ModChallenge(name, dataName)
    return Lib.ModComponents.ModChallenge:New(name, dataName);
end



local teammeat10 = Font();
teammeat10:Load("font/teammeatfont10.fnt");
local lanapixel = Font();
lanapixel:Load("font/cjk/lanapixel.fnt");
local terminus8 = Font();
terminus8:Load("font/terminus8.fnt");
local pftempesta7 = Font();
pftempesta7:Load("font/pftempestasevencondensed.fnt");
THI.Fonts = {
    Teammeat10 = teammeat10,
    Lanapixel = lanapixel,
    Terminus8 = terminus8,
    PFTempesta7 = pftempesta7,
}
THI.Music = {
    UFO = Isaac.GetMusicIdByName("UFO")
}

THI.Players = {
    Eika = Require("scripts/players/eika"),
    EikaB = Require("scripts/players/eika_b"),
    Satori = Require("scripts/players/satori"),
    SatoriB = Require("scripts/players/satori_b"),
}
THI.Bosses = {
    TheAbandoned = Require("scripts/bosses/the_abandoned"),
    Necrospyder = Require("scripts/bosses/necrospyder"),
    TheCentipede = Require("scripts/bosses/the_centipede"),
    Pyroplume = Require("scripts/bosses/pyroplume"),
    TheSummoner = Require("scripts/bosses/the_summoner"),
    Devilcrow = Require("scripts/bosses/devilcrow"),
    Guppet = Require("scripts/bosses/guppet")
}
THI.Pickups = {
    StarseekerBall = ModEntity("Starseeker Ball", "StarseekerBall"),
    FoxsAdviceBottle = Require("scripts/pickups/foxs_advice_bottle")
}
THI.Effects = {
    RabbitTrap = Require("scripts/effects/rabbit_trap"),
    TenguSpotlight = Require("scripts/effects/tengu_spotlight"),
    SpellCardLeaf = ModEntity("Spell Card Leaf", "SpellCardLeaf"),
    SpellCardWave = ModEntity("Spell Card Wave", "SpellCardWave"),
    PickupEffect = ModEntity("Pickup Effect", "PickupEffect"),
    ExtendingArm = Require("scripts/effects/extending_arm"),
    HolyThunder = Require("scripts/effects/holy_thunder"),
    MagicCluster = Require("scripts/effects/magic_cluster"),
    MagicCircle = Require("scripts/effects/magic_circle"),
    MagicCircleFire = Require("scripts/effects/magic_circle_fire"),
    SummonerGhost = Require("scripts/effects/summoner_ghost"),
}
THI.Familiars = {
    Illusion = Require("scripts/familiars/illusion"),
    RobeFire = Require("scripts/familiars/robe_fire"),
    LeafShieldRing = Require("scripts/familiars/leaf_shield_ring"),
    IsaacGolem = Require("scripts/familiars/isaac_golem"),
    PsycheEye = Require("scripts/familiars/psyche_eye"),
    ScaringUmbrella = Require("scripts/familiars/scaring_umbrella"),
    SekibankiHead = Require("scripts/familiars/sekibanki_head")
}
THI.Slots = {
    Trader = Require("scripts/slots/trader"),
}

THI.Monsters = {
    BloodBoney = Require("scripts/monsters/blood_bony"),
    BonusUFO = Require("scripts/monsters/bonus_ufo"),
    EvilSpirit = Require("scripts/monsters/evil_spirit"),
    Immortal = Require("scripts/monsters/immortal"),
}


local Collectibles = {};

Collectibles.YinYangOrb = Require("scripts/items/protagonists/yin-yang_orb");
Collectibles.MarisasBroom = Require("scripts/items/protagonists/marisas_broom");
--TH6
Collectibles.DarkRibbon = Require("scripts/items/th6/dark_ribbon");
Collectibles.DYSSpring = Require("scripts/items/th6/spring_of_daiyousei");
Collectibles.DragonBadge = Require("scripts/items/th6/rainbow_dragon_badge");
Collectibles.Koakuma = Require("scripts/items/th6/koakuma_baby");
Collectibles.Grimoire = Require("scripts/items/th6/grimoire_of_patchouli");
Collectibles.MaidSuit = Require("scripts/items/th6/maid_suit");
Collectibles.VampireTooth = Require("scripts/items/th6/tooth_of_vampire");
Collectibles.Destruction = Require("scripts/items/th6/destruction");
Collectibles.DeletedErhu = Require("scripts/items/th6/deleted_erhu");
--TH7
Collectibles.FrozenSakura = Require("scripts/items/th7/frozen_sakura");
Collectibles.ChenBaby = Require("scripts/items/th7/chen_baby");
Collectibles.ShanghaiDoll = Require("scripts/items/th7/shanghai_doll");
Collectibles.MelancholicViolin = Require("scripts/items/th7/melancholic_violin");
Collectibles.ManiacTrumpet = Require("scripts/items/th7/maniac_trumpet");
Collectibles.IllusionaryKeyboard = Require("scripts/items/th7/illusionary_keyboard");
Collectibles.Roukanken = Require("scripts/items/th7/roukanken");
Collectibles.FanOfTheDead = Require("scripts/items/th7/fan_of_the_dead");
Collectibles.FriedTofu = Require("scripts/items/th7/fried_tofu");
Collectibles.OneOfNineTails = Require("scripts/items/th7/one_of_nine_tails");
Collectibles.Gap = Require("scripts/items/th7/the_gap");
-- Secret Sealing
Collectibles.Starseeker = Require("scripts/items/secret_sealing/starseeker");
Collectibles.Pathseeker = Require("scripts/items/secret_sealing/pathseeker");
-- TH7.5
Collectibles.GourdShroom = Require("scripts/items/th7-5/gourd_shroom");
-- TH8
Collectibles.JarOfFireflies = Require("scripts/items/th8/jar_of_fireflies");
Collectibles.SongOfNightbird = Require("scripts/items/th8/song_of_nightbird");
Collectibles.BookOfYears = Require("scripts/items/th8/book_of_years");
Collectibles.RabbitTrap = Require("scripts/items/th8/rabbit_trap");
Collectibles.Illusion = Require("scripts/items/th8/illusion");
Collectibles.PeerlessElixir = Require("scripts/items/th8/peerless_elixir");
Collectibles.DragonNeckJewel = Require("scripts/items/th8/dragon_neck_jewel");
Collectibles.RobeOfFirerat = Require("scripts/items/th8/robe_of_firerat");
Collectibles.JeweledBranch = Require("scripts/items/th8/jeweled_branch");
Collectibles.AshOfPheonix = Require("scripts/items/th8/ash_of_pheonix");

-- TH9
Collectibles.TenguCamera = Require("scripts/items/th9/tengu_camera");
Collectibles.SunflowerPot = Require("scripts/items/th9/sunflower_pot");
Collectibles.ContinueArcade = Require("scripts/items/th9/continue_arcade");
Collectibles.RodOfRemorse = Require("scripts/items/th9/rod_of_remorse");

-- TH10
Collectibles.LeafShield = Require("scripts/items/th10/leaf_shield");
Collectibles.BakedSweetPotato = Require("scripts/items/th10/baked_sweet_potato");
Collectibles.BrokenAmulet = Require("scripts/items/th10/broken_amulet");
Collectibles.ExtendingArm = Require("scripts/items/th10/extending_arm");
Collectibles.Benediction = Require("scripts/items/th10/benediction");

-- TH11
Collectibles.PlagueLord = Require("scripts/items/th11/plague_lord");
Collectibles.GreenEyedEnvy = Require("scripts/items/th11/green_eyed_envy");
Collectibles.OniHorn = Require("scripts/items/th11/oni_horn");
Collectibles.PsycheEye = Require("scripts/items/th11/psyche_eye");
Collectibles.Technology666 = Require("scripts/items/th11/technology_666");
Collectibles.PsychoKnife = Require("scripts/items/th11/psycho_knife");
-- TH12
Collectibles.DowsingRods = Require("scripts/items/th12/dowsing_rods");
Collectibles.ScaringUmbrella = Require("scripts/items/th12/scaring_umbrella");
Collectibles.Pagota = Require("scripts/items/th12/bishamontens_pagota");
Collectibles.SorcerersScroll = Require("scripts/items/th12/sorcerers_scroll");
Collectibles.SaucerRemote = Require("scripts/items/th12/saucer_remote");

-- TH12.5
Collectibles.TenguCellphone = Require("scripts/items/th12-5/tengu_cellphone");
-- TH13
Collectibles.MountainEar = Require("scripts/items/th13/mountain_ear");
Collectibles.ZombieInfestation = Require("scripts/items/th13/zombie_infestation");
Collectibles.WarppingHairpin = Require("scripts/items/th13/warpping_hairpin");
Collectibles.D2147483647 = Require("scripts/items/th13/d2147483647");
-- TH13.5
Collectibles.TheInfamies = Require("scripts/items/th13-5/the_infamies");
-- TH14
Collectibles.SekibankisHead = Require("scripts/items/th14/sekibankis_head");
Collectibles.DFlip = Require("scripts/items/th14/d_flip");
Collectibles.MiracleMallet = Require("scripts/items/th14/miracle_mallet");
-- TH15
Collectibles.ViciousCurse = Require("scripts/items/th15/vicious_curse");
Collectibles.PureFury = Require("scripts/items/th15/pure_fury");
-- TH15.5
Collectibles.DadsShares = Require("scripts/items/th15-5/dads_shares");
Collectibles.MomsIOU = Require("scripts/items/th15-5/moms_iou");
-- TH16
Collectibles.GolemOfIsaac = Require("scripts/items/th16/golem_of_isaac");
-- TH17
Collectibles.FetusBlood = Require("scripts/items/th17/fetus_blood");
Collectibles.KiketsuBlackmail = Require("scripts/items/th17/kiketsu_familys_blackmail");

-- TH17.5
Collectibles.Hunger = Require("scripts/items/th17-5/hunger");

Collectibles.DreamSoul = {Item = Isaac.GetItemIdByName("Dream Soul")};

-- TH18
Collectibles.YamawarosCrate = Require("scripts/items/th18/yamawaros_crate");
Collectibles.FoxInTube = Require("scripts/items/th18/fox_in_tube");
Collectibles.DaitenguTelescope = Require("scripts/items/th18/daitengu_telescope");
Collectibles.ExchangeTicket = Require("scripts/items/th18/exchange_ticket");
Collectibles.CurseOfCentipede = Require("scripts/items/th18/curse_of_centipede");

-- Make resistance of player at the last.
Collectibles.BuddhasBowl = Require("scripts/items/th8/buddhas_bowl");
Collectibles.SwallowsShell = Require("scripts/items/th8/swallows_shell");


-- Printworks
Collectibles.IsaacsLastWills = Require("scripts/items/printworks/isaacs_last_wills");
Collectibles.EmptyBook = Require("scripts/items/printworks/empty_book");
Collectibles.RuneSword = Require("scripts/items/printworks/rune_sword");




--Dr. Fetus - Fetus Blood
Collectibles.DFlip.AddFixedPair(5,100,CollectibleType.COLLECTIBLE_DR_FETUS, 5,100, Collectibles.FetusBlood.Item);
--Godhead - Broken Amulet
Collectibles.DFlip.AddFixedPair(5,100,CollectibleType.COLLECTIBLE_GODHEAD, 5,100, Collectibles.BrokenAmulet.Item);
--Genesis - Destruction
Collectibles.DFlip.AddFixedPair(5,100,CollectibleType.COLLECTIBLE_GENESIS, 5,100, Collectibles.Destruction.Item);
--Brimstone Bombs - Lightbomb
--Collectibles.DFlip.AddFixedPair(5,100,CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS, 5,100, Collectibles.LightBomb.Item);
--Starseeker - Pathseeker
Collectibles.DFlip.AddFixedPair(5,100,Collectibles.Starseeker.Item, 5,100, Collectibles.Pathseeker.Item);
--Onbashira - Young Native God
--Collectibles.DFlip.AddFixedPair(5,100,Collectibles.Onbashira.Item, 5,100, Collectibles.YoungNativeGod.Item);
--D Flip - D Flip
Collectibles.DFlip.AddFixedPair(5,100,Collectibles.DFlip.Item, 5,100, Collectibles.DFlip.Item);
--Mom's IOU - Dad's Shares
Collectibles.DFlip.AddFixedPair(5,100,Collectibles.MomsIOU.Item, 5,100, Collectibles.DadsShares.Item);

THI.Collectibles = Collectibles;


THI.Transformations = {
    Musician = Require("scripts/transformations/musician");
}

THI.Challenges = {
    HeavyDebt = Require("scripts/challenges/heavy_debt"),
    ShadowDieTwice = Require("scripts/challenges/shadow_die_twice"),
    SteamAge = Require("scripts/challenges/steam_age"),
}


THI.GensouDream = Require("scripts/doremy/main");

THI.Trinkets = {
    FrozenFrog = Require("scripts/trinkets/frozen_frog"),
    AromaticFlower = Require("scripts/trinkets/aromatic_flower"),
    GlassesOfKnowledge = Require("scripts/trinkets/glasses_of_knowledge"),
    CorrodedDoll = Require("scripts/trinkets/corroded_doll"),
    LionStatue = Require("scripts/trinkets/lion_statue"),
    FortuneCatPaw = Require("scripts/trinkets/fortune_cat_paw"),
    MermanShell = Require("scripts/trinkets/merman_shell")
}

ModEntity = nil;
ModItem = nil;
ModChallenge = nil;
ModTrinket = nil;

THI.Sounds = {
    SOUND_FAIRY_HEAL = Isaac.GetSoundIdByName("Fairy Heal"),
    SOUND_TOUHOU_CHARGE = Isaac.GetSoundIdByName("Touhou Charge"),
    SOUND_TOUHOU_CHARGE_RELEASE = Isaac.GetSoundIdByName("Touhou Charge Release"),
    SOUND_TOUHOU_DESTROY = Isaac.GetSoundIdByName("Touhou Destroy"),
    SOUND_TOUHOU_DANMAKU = Isaac.GetSoundIdByName("Touhou Danmaku"),
    SOUND_TOUHOU_LASER = Isaac.GetSoundIdByName("Touhou Laser"),
    SOUND_TOUHOU_SPELL_CARD = Isaac.GetSoundIdByName("Touhou Spell Card"),
    SOUND_MIND_CONTROL = Isaac.GetSoundIdByName("Mind Control"),
    SOUND_EXECUTE = Isaac.GetSoundIdByName("Execute"),
    SOUND_CENTIPEDE = Isaac.GetSoundIdByName("Centipede"),
    SOUND_HOOK_CATCH = Isaac.GetSoundIdByName("Hook Catch"),
    SOUND_UFO = Isaac.GetSoundIdByName("UFO"),
    SOUND_UFO_ALERT = Isaac.GetSoundIdByName("UFO Alert"),
    SOUND_FAULT = Isaac.GetSoundIdByName("Fault"),
    SOUND_RADAR = Isaac.GetSoundIdByName("Radar"),
    SOUND_SCIFI_MECH = Isaac.GetSoundIdByName("Scifi Mech"),
    SOUND_SCIFI_LASER = Isaac.GetSoundIdByName("Scifi Laser"),
    SOUND_NUCLEAR_ALERT = Isaac.GetSoundIdByName("Nuclear Alert"),
    SOUND_THUNDER_SHOCK = Isaac.GetSoundIdByName("Thunder Shock"),
    SOUND_SUMMONER_DEATH = Isaac.GetSoundIdByName("Summoner Death"),
    SOUND_MAGIC_IMPACT = Isaac.GetSoundIdByName("Magic Impact"),
    SOUND_CURSE_CAST = Isaac.GetSoundIdByName("Curse Cast"),
    SOUND_CURSE_FEARNESS = Isaac.GetSoundIdByName("Fearness Curse"),
    SOUND_REVIVE_SKELETON_CAST = Isaac.GetSoundIdByName("Revive Skeleton Cast"),
    SOUND_CORPSE_EXPLODE_CAST = Isaac.GetSoundIdByName("Corpse Explode Cast"),
    SOUND_BONE_CAST = Isaac.GetSoundIdByName("Bone Cast"),
    SOUND_DIABLO_IDENTIFY = Isaac.GetSoundIdByName("Diablo Identify"),
    SOUND_DIABLO_SCROLL = Isaac.GetSoundIdByName("Diablo Scroll"),
}

-- Translations
do
    THI.ShowTranslationText = true;
    THI.Translations = {};
    THI.Translations.en = Require("translations/en");
    local language = Options.Language;
    THI.Translations[language] = Require("translations/"..language);

    THI.StringCategories = {
        DEFAULT = "Default",
        DIALOGS = "Dialogs",

    }

    local function GetLanguageText(category, key, lang)
        local Translations = THI.Translations;
        local translation = Translations[lang];
        if (translation) then
            local categoryStrings = translation[category];
            if (categoryStrings) then
                local string = categoryStrings[key];
                if (string) then
                    return string;
                end
            end
        end
        return nil;
    end
    function THI.ContainsText(category, key, lang)
        lang = lang or language;
        local languageString = GetLanguageText(category, key, language);
        if (languageString) then
            return true;
        end
        return false;
    end
    function THI.GetText(category, key, lang)
        local lang = lang or language;
        local languageString = GetLanguageText(category, key, lang);
        if (languageString) then
            return languageString;
        end
        -- English Fallback.
        return GetLanguageText(category, key, "en");
    end

    local function PostPickupItem(mod, player, item, touched)
        if (not THI.ShowTranslationText) then
            return;
        end
        local language = Options.Language;
        local Translations = THI.Translations;
        local translation = Translations[language];
        if (translation) then
            local info = translation.Collectibles and translation.Collectibles[item];
            if (info) then
                THI.Game:GetHUD():ShowItemText(info.Name or "", info.Description or "");
            end
        end
    end
    Lib.Callbacks:AddCallback(THI, CLCallbacks.CLC_POST_PICKUP_COLLECTIBLE, PostPickupItem);

    
    local function PostPickupTrinket(mod, player, item, golden, touched)
        if (not THI.ShowTranslationText) then
            return;
        end
        if (item > 32768) then
            item = item - 32768
        end
        local language = Options.Language;
        local Translations = THI.Translations;
        local translation = Translations[language];
        if (translation) then
            local info = translation.Trinkets and translation.Trinkets[item];
            if (info) then
                THI.Game:GetHUD():ShowItemText(info.Name or "", info.Description or "");
            end
        end
    end
    Lib.Callbacks:AddCallback(THI, CLCallbacks.CLC_POST_PICKUP_TRINKET, PostPickupTrinket);
end


function THI:postExit()
    for k, _ in pairs(THI.Data) do
        THI.Data[k] = nil
    end
end
CuerLib.SaveAndLoad:AddCallback(THI, SLCallbacks.SLC_POST_EXIT, THI.postExit);

if (EID) then
    Require("descriptions/rep/main")
end

if (HPBars) then
    Require("compatilities/boss_bars")
end

CuerLib:LateRegister();

-- Lunatic.
do
    local Lunatic = {}

    local IsLunatic = false;

    function Lunatic.UpdateLunatic()
        local persistent = Lib.SaveAndLoad.ReadPersistentData();
        if (persistent.Lunatic) then
            IsLunatic = true;
        end
    end
    Lunatic.UpdateLunatic();

    function THI.IsLunatic()
        return IsLunatic;
    end

    function THI.SetLunatic(value)
        local persistent = Lib.SaveAndLoad.ReadPersistentData();
        persistent.Lunatic = value;
        IsLunatic = value;
        Lib.SaveAndLoad.WritePersistentData(persistent);
    end

    function Lunatic:PostExecuteCommand(cmd, parameters)
        if (cmd == "thlunatic") then
            local lunatic = THI.IsLunatic();
            THI.SetLunatic(not lunatic);
            if (lunatic) then
                print("Lunatic Mode is now off.");
            else
                print("Lunatic Mode is now on.");
            end
        -- elseif (cmd == "thfortune") then
        --     local value = tonumber(parameters);
        --     THI.SetFortune(value);
        --     print("Reverie item fortune has been set to "..value..".");
        end
    end
    THI:AddCallback(ModCallbacks.MC_EXECUTE_CMD, Lunatic.PostExecuteCommand)

    function Lunatic:PostGameStarted(isContinued)
        Lunatic.UpdateLunatic()
    end
    THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Lunatic.PostGameStarted)

    local LunaticIcon = Sprite();
    LunaticIcon:Load("gfx/ui/lunatic.anm2", true);
    LunaticIcon:Play("Icon");
    function Lunatic:PostRender()
        if (THI.Game:GetHUD():IsVisible ( ) and THI.IsLunatic()) then
            local size = Lib.Screen.GetScreenSize() 
            local pos = Vector(size.X / 2 + 60, 14 + Options.HUDOffset * 24);
            LunaticIcon:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_RENDER, Lunatic.PostRender)

end

-- function THI:PostGameStartGetItemPools(isContinued)
--     if (not isContinued) then
--         THI.Config.CollectibleItemPools = Lib.ItemPools.GetItemPoolCollectibles()
--     end
--     --print("Collectible Item Pools Loaded.");
-- end
-- THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, THI.PostGameStartGetItemPools);

function THI.GotoRoom(id)
    Isaac.ExecuteCommand("goto "..id);
end

-- Reevaluate caches after gameStarted.
function THI:PostGameStartEvaluate(isContinued)
    if  (isContinued) then
        for index, player in Lib.Detection.PlayerPairs(true, true) do
            --local player = THI.Game:GetPlayer(p);
            --print(index);
            player:AddCacheFlags(CacheFlag.CACHE_ALL);
            player:EvaluateItems();
            --print(player.MaxFireDelay)
        end
    end
end
THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, THI.PostGameStartEvaluate);


-- Curses.
do
    local function EvaluateCurse(curses)
        curses = curses or Game():GetLevel():GetCurses();
        for i, info in pairs(Lib.Callbacks.Functions.EvaluateCurse) do
            local result = info.Func(info.Mod, curses);
            if (result ~= nil) then
                if (type(result) == "number") then
                    curses = result;
                else
                    error("Trying to return a value which is not a number or nil in EVALUATE_CURSE.");
                end
            end
        end
        return curses;
    end
    function THI:EvaluateCurses()
        local level = Game():GetLevel();
        local beforeCurses = level:GetCurses();
        local curses = EvaluateCurse();

        local removedCurses = ~curses & beforeCurses;
        local addedCurses = ~beforeCurses & curses;
        level:RemoveCurses(removedCurses);
        level:AddCurse(addedCurses);
    end

    local function OnCurseEvaluate(mod, curses)
        local newCurses = EvaluateCurse(curses);
        return newCurses;
    end
    THI:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, OnCurseEvaluate);
end

if (not StageAPI) then
    -- Custom Boss.
    do
        local CustomBosses = {};
        local noSkipBoss = false;
        function CustomBosses:PostExecuteCommand(cmd, parameters)
            if (cmd == "noskipboss") then
                noSkipBoss = not noSkipBoss;
                if (noSkipBoss) then
                    print("Disabled boss splash skip.");
                else
                    print("Enabled boss splash skip.");
                end
            -- elseif (cmd == "thfortune") then
            --     local value = tonumber(parameters);
            --     THI.SetFortune(value);
            --     print("Reverie item fortune has been set to "..value..".");
            end
        end
        THI:AddCallback(ModCallbacks.MC_EXECUTE_CMD, CustomBosses.PostExecuteCommand)

        
        local function InputAction(mod, entity, hook, action)
            if (noSkipBoss and Lib.Bosses:IsPlayingSplashSprite()) then
                if (action == ButtonAction.ACTION_MENUCONFIRM or action == ButtonAction.ACTION_CONSOLE) then
                    if ((hook == InputHook.IS_ACTION_TRIGGERED or hook == InputHook.IS_ACTION_PRESSED)) then
                        return false;
                    else
                        return 0;
                    end
                end
            end
        end
        THI:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction);
    end
end

if (ModConfigMenu) then
    require("compatilities/mod_config_menu");
end

CuerLib = nil;

print("[Reverie] Reverie "..THI:GetVersionString().." Loaded.")