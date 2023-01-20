local hasCuerLib = not not CuerLib;
local Lib = CuerLib or include("cuerlib/main");
THI = RegisterMod("Reverie", 1);
Reverie = THI;

-- Load Fonts.
local teammeat10 = Font();
teammeat10:Load("font/teammeatfont10.fnt");
local teammeatExtended10 = Font();
teammeatExtended10:Load("font/teammeatfontextended10.fnt");
local lanapixel = Font();
lanapixel:Load("font/cjk/lanapixel.fnt");
local terminus8 = Font();
terminus8:Load("font/terminus8.fnt");
local pftempesta7 = Font();
pftempesta7:Load("font/pftempestasevencondensed.fnt");
local mplus_12b = Font();
mplus_12b:Load("font/mplus_12b.fnt");
THI.Fonts = {
    Teammeat10 = teammeat10,
    TeammeatExtended10 = teammeatExtended10,
    Lanapixel = lanapixel,
    Terminus8 = terminus8,
    PFTempesta7 = pftempesta7,
    MPlus12b = mplus_12b
}
-- CuerLib check.
if (not CuerLib) then
	local langFonts = {
		en = THI.Fonts.PFTempesta7,
		zh = THI.Fonts.Lanapixel
	}
	local langTexts = {
		en = {
			"This mod requires the mod \"CuerLib\" to work properly!",
			"Install and enable it before playing with this mod."
		},
		zh = {
			"该MOD需要前置MOD\"CuerLib\"来运行！",
			"请下载并开启该前置MOD。"
		}
	}
	local font = langFonts[Options.Language] or langFonts.en;
	local texts = langTexts[Options.Language] or langTexts.en;
	local color = KColor(1,0,0,1);

	local function PostRender(mod)
		local posX = Isaac.GetScreenWidth() / 2;
		for i, text in ipairs(texts) do
			font:DrawStringUTF8 (text, posX - 200, 0 + i * 20, color, 400, true )
		end
	end
	THI:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender);

    
	local function GetShaderParams(mod, name)
        if (name == "Reverie White Screen") then
            return {
                Alpha = 0;
            }
        elseif (name == "Reverie Black Screen") then
            return {
                Alpha = 0;
            }
        elseif (name == "Reverie Delusion Pipe") then
            return {
                Offset = 0,
                Alpha = 0,
            }
        end
	end
	THI:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);
	return;
end
Lib:InitMod(THI, "REVERIE");

THI.Version = {
    12,8,0
}
function THI:GetVersionString()
    local versionString = "";
    for i, version in pairs(self.Version) do
        if (i > 1) then
            versionString = versionString..".";
        end
        versionString = versionString..version;
    end
    return versionString;
end

if (StageAPI) then
    StageAPI.UnregisterCallbacks(THI.Name);
end

local function IsMainmenu()
    return Game():GetLevel():GetStage() <= 0;
end

THI.Game = Game();
THI.SFXManager = SFXManager();

function THI.GetData(entity)
    local entityData = entity:GetData();
    entityData._TOUHOU_DATA = entityData._TOUHOU_DATA or {};
    return entityData._TOUHOU_DATA;
end

------------------------
-- Stage
------------------------


THI.Lib = Lib;
local SaveAndLoad = THI.CuerLibAddon.SaveAndLoad;

local loaded = {};
function THI.Require(path) 
    if (not loaded[path]) then
        loaded[path] = include(path);
    end
    return loaded[path];
end;
local Require = THI.Require;

-- Room Generation.
do
    --THI.Shared.RoomGen = Require("scripts/shared/room_gen")

    function THI.GotoRoom(id)
        Isaac.ExecuteCommand("goto "..id);
    end

    function THI.GotoAdditionalRoom(index, dimension)
        Game():StartRoomTransition(index, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, nil, dimension);
    end
end

function THI.Random(min, max)
    if (not max) then
        max = min;
        min = 0;
    end
    return Random() % (max - min) + min;
end 

function THI.RandomFloat(min, max)
    if (not max) then
        max = min;
        min = 0;
    end
    return Random() % ((max - min) * 1000) / 1000 + min;
end 

do -- Announcers.
    local Announcer = {}
    local Announcers = {};
    local PillAnnouncers = {};
    local QueuedAnnouncers = {};

    local AnnouncerEnabled = true;

    function Announcer.UpdateAnnouncer()
        local persistent = SaveAndLoad:ReadPersistentData();
        if (persistent.AnnouncerEnabled == false) then
            AnnouncerEnabled = false;
        end
    end
    Announcer.UpdateAnnouncer();

    function Announcer:PostGameStarted(isContinued)
        Announcer.UpdateAnnouncer()
    end
    THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Announcer.PostGameStarted)
    local function PostUpdate(mod)
        for i = #QueuedAnnouncers, 1, -1 do
            local announcer = QueuedAnnouncers[i];
            if (announcer.Timeout < 0) then
                THI.SFXManager:Play(announcer.ID);
                table.remove(QueuedAnnouncers ,i);
            else
                announcer.Timeout = announcer.Timeout - 1;
            end
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

    local function PostGameStarted(mod, isContinued)
        for i = 1, #QueuedAnnouncers do
            QueuedAnnouncers[i] = nil;
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);

    local function PostUseCard(mod, card, player, flags)
        if (flags & UseFlag.USE_NOANNOUNCER <= 0 and THI.AnnouncerEnabled()) then
            local announcer = THI:GetAnnouncer(card);
            if (announcer) then
                local willRandomPlay = Random() % 2 == 1;
                local announcerMode = Options.AnnouncerVoiceMode;
                if (announcerMode == 2 or (announcerMode == 0 and willRandomPlay)) then
                    table.insert(QueuedAnnouncers, 1, {ID = announcer.ID, Timeout = announcer.Delay});
                end 
            end
        end
    end
    THI:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard)

    local function PostUsePill(mod, effect, player, flags)
        if (flags & UseFlag.USE_NOANNOUNCER <= 0 and THI.AnnouncerEnabled()) then
            local announcer = THI:GetPillAnnouncer(effect);
            if (announcer) then
                local announcerMode = Options.AnnouncerVoiceMode;
                local willRandomPlay = Random() % 2 == 1;
                if (announcerMode == 2 or (announcerMode == 0 and willRandomPlay)) then


                    local mega = false;
                    local itemPool = Game():GetItemPool();
                    local pillColor = player:GetPill(0);
                    local pillEffect = itemPool:GetPillEffect(pillColor, player);
                    if (pillEffect == effect) then
                        if (pillColor & PillColor.PILL_GIANT_FLAG > 0) then
                            mega = true;
                        end
                    end

                    local sound = announcer.ID;
                    if (mega) then
                        sound = announcer.MegaID or sound;
                    end
                    table.insert(QueuedAnnouncers, 1, {ID = sound, Timeout = announcer.Delay});
                end 
            end
        end
    end
    THI:AddCallback(ModCallbacks.MC_USE_PILL, PostUsePill)

    function THI.AnnouncerEnabled()
        return AnnouncerEnabled;
    end

    function THI.DisableBoss(value)
        local persistent = SaveAndLoad:ReadPersistentData();
        persistent.AnnouncerEnabled = value;
        AnnouncerEnabled = value;
        SaveAndLoad:WritePersistentData(persistent);
    end


    function THI:AddAnnouncer(id, sound, delay)
        delay = delay or 0;
        Announcers[id] = {ID = sound, Delay = delay};
    end
    function THI:GetAnnouncer(id)
        return Announcers[id];
    end
    

    function THI:AddPillAnnouncer(id, sound, megaSound, delay)
        delay = delay or 0;
        PillAnnouncers[id] = {ID = sound, MegaID = megaSound, Delay = delay};
    end
    function THI:GetPillAnnouncer(card)
        return PillAnnouncers[card];
    end

end

THI.BossBlacklist = Require("scripts/boss_blacklist");

local Comps = THI.CuerLibAddon.ModComponents;
function ModEntity(name, dataName) 
    return Comps.ModEntity:New(name, dataName);
end

function ModItem(name, dataName) 
    return Comps.ModItem:New(name, dataName);
end

---- Trinkets
function ModTrinket(name, dataName) 
    return Comps.ModTrinket:New(name, dataName);
end

---- Player
function ModPlayer(name, tainted, dataName) 
    return Comps.ModPlayer:New(name, tainted, dataName);
end

function ModCard(name, dataName) 
    return Comps.ModCard:New(name, dataName);
end
function ModPill(name, dataName) 
    return Comps.ModPill:New(name, dataName);
end

function ModChallenge(name, dataName)
    return Comps.ModChallenge:New(name, dataName);
end

function ModPart(name, dataName)
    return Comps.ModPart:New(name, dataName);
end



local Shared = {};
THI.Instruments = Require("scripts/shared/instruments");
THI.GapFloor = Require("scripts/shared/gap_floor");
THI.TemporaryDamage = include("scripts/temporary_damage");
THI.GridDetection = include("scripts/grid_detection");
THI.Machines = include("scripts/machines");
include("scripts/question_items");

Shared.Wheelchair = include("scripts/shared/wheelchair");
Shared.Wheelchair:Register(THI);
Shared.LightFairies = include("scripts/shared/light_fairies");
Shared.TearEffects = include("scripts/shared/tear_effects");
Shared.EntityTags = include("scripts/shared/entity_tags");
Shared.PathFinding = include("scripts/shared/path_finding")
Shared.SoftlockFix = include("scripts/shared/softlock_fix")
Shared.Database = include("scripts/shared/database")
Shared.Options = include("scripts/shared/options");
THI.Halos = Require("scripts/shared/halos");


THI.Shared = Shared;



THI.Music = {
    UFO = Isaac.GetMusicIdByName("UFO"),
    REVERIE = Isaac.GetMusicIdByName("Reverie"),
}

THI.Sounds = {
    SOUND_FAIRY_HEAL = Isaac.GetSoundIdByName("Fairy Heal"),
    SOUND_TOUHOU_CHARGE = Isaac.GetSoundIdByName("Touhou Charge"),
    SOUND_TOUHOU_CHARGE_RELEASE = Isaac.GetSoundIdByName("Touhou Charge Release"),
    SOUND_TOUHOU_DESTROY = Isaac.GetSoundIdByName("Touhou Destroy"),
    SOUND_TOUHOU_DANMAKU = Isaac.GetSoundIdByName("Touhou Danmaku"),
    SOUND_TOUHOU_LASER = Isaac.GetSoundIdByName("Touhou Laser"),
    SOUND_TOUHOU_SPELL_CARD = Isaac.GetSoundIdByName("Touhou Spell Card"),
    SOUND_TOUHOU_BOON = Isaac.GetSoundIdByName("Touhou Boon"),
    SOUND_TOUHOU_KAGEROU_ROAR = Isaac.GetSoundIdByName("Touhou Kagerou Roar"),
    SOUND_TOUHOU_SHUTTER = Isaac.GetSoundIdByName("Touhou Shutter"),
    SOUND_TOUHOU_TIMEOUT = Isaac.GetSoundIdByName("Touhou Timeout"),
    SOUND_NIMBLE_FABRIC = Isaac.GetSoundIdByName("Nimble Fabric"),
    SOUND_MIND_CONTROL = Isaac.GetSoundIdByName("Mind Control"),
    SOUND_MIND_WAVE = Isaac.GetSoundIdByName("Mind Wave"),
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
    SOUND_CORPSE_EXPLODE = Isaac.GetSoundIdByName("Corpse Explode"),
    SOUND_BONE_CAST = Isaac.GetSoundIdByName("Bone Cast"),
    SOUND_DIABLO_IDENTIFY = Isaac.GetSoundIdByName("Diablo Identify"),
    SOUND_DIABLO_SCROLL = Isaac.GetSoundIdByName("Diablo Scroll"),
    SOUND_ROOSTER_CROW = Isaac.GetSoundIdByName("Rooster Crow"),
    SOUND_SOUL_OF_EIKA = Isaac.GetSoundIdByName("Soul of Eika"),
    SOUND_SOUL_OF_SATORI = Isaac.GetSoundIdByName("Soul of Satori"),
    SOUND_SOUL_OF_SEIJA = Isaac.GetSoundIdByName("Soul of Seija"),
    SOUND_SPIRIT_MIRROR = Isaac.GetSoundIdByName("Spirit Mirror"),
    SOUND_SITUATION_TWIST = Isaac.GetSoundIdByName("Situation Twist"),
    SOUND_PILL_OF_ULTRAMARINE_ORB = Isaac.GetSoundIdByName("Pill of Ultramarine Orb"),
    SOUND_MEGA_PILL_OF_ULTRAMARINE_ORB = Isaac.GetSoundIdByName("Mega Pill of Ultramarine Orb"),
    SOUND_HAMMER_80 = Isaac.GetSoundIdByName("Hammer 80"),
    SOUND_ROBOT_SMASH = Isaac.GetSoundIdByName("Robot Smash"),
    SOUND_EARTHQUAKE = Isaac.GetSoundIdByName("Earthquake"),
    SOUND_WILD_ROAR = Isaac.GetSoundIdByName("Wild Roar"),
    SOUND_WILD_BITE = Isaac.GetSoundIdByName("Wild Bite"),
    SOUND_RAGING_DEMON = Isaac.GetSoundIdByName("Raging Demon"),
    SOUND_PIANO_C4 = Isaac.GetSoundIdByName("Piano C4"),
    SOUND_MUSIC_BOX_C4 = Isaac.GetSoundIdByName("Music Box C4"),
    SOUND_ACID_RAIN = Isaac.GetSoundIdByName("Acid Rain"),
}


THI.Players = {
    Eika = Require("scripts/players/eika"),
    EikaB = Require("scripts/players/eika_b"),
    Satori = Require("scripts/players/satori"),
    SatoriB = Require("scripts/players/satori_b"),
    Seija = Require("scripts/players/seija"),
    SeijaB = Require("scripts/players/seija_b"),
}
THI.Bosses = {
    TheAbandoned = Require("scripts/bosses/the_abandoned"),
    Necrospyder = Require("scripts/bosses/necrospyder"),
    TheCentipede = Require("scripts/bosses/the_centipede"),
    Pyroplume = Require("scripts/bosses/pyroplume"),
    TheSummoner = Require("scripts/bosses/the_summoner"),
    Devilcrow = Require("scripts/bosses/devilcrow"),
    Guppet = Require("scripts/bosses/guppet"),
    ReverieNote = Require("scripts/bosses/reverie_note")
}

THI.Cards = {
    SoulOfEika = Require("scripts/pockets/soul_of_eika"),
    SoulOfSatori = Require("scripts/pockets/soul_of_satori"),
    ASmallStone = Require("scripts/pockets/a_small_stone"),
    SpiritMirror = Require("scripts/pockets/spirit_mirror"),
    SoulOfSeija = Require("scripts/pockets/soul_of_seija"),
    SituationTwist = Require("scripts/pockets/situation_twist"),
}
THI.Pills = {
    PillOfUltramarineOrb = Require("scripts/pockets/pill_of_ultramarine_orb")
}
THI.Pickups = {
    SpringFairy = Require("scripts/pickups/spring_fairy"),
    StarseekerBall = ModEntity("Starseeker Ball", "StarseekerBall"),
    FoxsAdviceBottle = Require("scripts/pickups/foxs_advice_bottle"),
    SakeBottle = Require("scripts/pickups/sake_bottle"),
    ReverieMusicBox = Require("scripts/pickups/reverie_music_box"),
    RebechaIdle = Require("scripts/pickups/rebecha_idle"),
    FoodPickup = Require("scripts/pickups/food_pickup"),
}
THI.Knives = {
    HaniwaKnife = Require("scripts/knives/haniwa_knife"),
}
THI.Effects = {
    FairyEffect = Require("scripts/effects/fairy_effect"),
    FairyParticle = Require("scripts/effects/fairy_particle"),
    PlayerTrail = Require("scripts/effects/player_trail"),
    RabbitTrap = Require("scripts/effects/rabbit_trap"),
    TenguSpotlight = Require("scripts/effects/tengu_spotlight"),
    SpellCardLeaf = Require("scripts/effects/spell_card_leaf"),
    SpellCardWave = Require("scripts/effects/spell_card_wave"),
    PickupEffect = Require("scripts/effects/pickup_effect"),
    ExtendingArm = Require("scripts/effects/extending_arm"),
    Onbashira = Require("scripts/effects/onbashira"),
    HolyThunder = Require("scripts/effects/holy_thunder"),
    MagicCluster = Require("scripts/effects/magic_cluster"),
    MagicCircle = Require("scripts/effects/magic_circle"),
    MagicCircleFire = Require("scripts/effects/magic_circle_fire"),
    SummonerGhost = Require("scripts/effects/summoner_ghost"),
    MiracleMalletReplica = Require("scripts/effects/miracle_mallet_replica"),
    WildFangs = Require("scripts/effects/wild_fangs"),
    UnzanFace = Require("scripts/effects/unzan_face"),
    ReverieMusicPaper = Require("scripts/effects/reverie_music_paper"),
    ReverieNoteWave = Require("scripts/effects/reverie_note_wave"),
    ReverieProp = Require("scripts/effects/reverie_prop"),
    TinyMeteor = Require("scripts/effects/tiny_meteor"),
    SeijasShade = Require("scripts/effects/seijas_shade"),
    ItemSoul = Require("scripts/effects/item_soul"),
    RemainsFountain = Require("scripts/effects/remains_fountain"),
    RagingDemonBackground = Require("scripts/effects/raging_demon_background"),
    SpiderbabyWeb = Require("scripts/effects/spiderbaby_web"),
    AcidRaindrop = Require("scripts/effects/acid_raindrop"),
    DaggerWarning = Require("scripts/effects/dagger_warning"),
    EyeOfChimeraDisplayer = Require("scripts/effects/eye_of_chimera_displayer"),
    DejavuCorpse = Require("scripts/effects/dejavu_corpse")
}
THI.Familiars = {
    Illusion = Require("scripts/familiars/illusion"),
    RobeFire = Require("scripts/familiars/robe_fire"),
    LeafShieldRing = Require("scripts/familiars/leaf_shield_ring"),
    IsaacGolem = Require("scripts/familiars/isaac_golem"),
    PsycheEye = Require("scripts/familiars/psyche_eye"),
    ScaringUmbrella = Require("scripts/familiars/scaring_umbrella"),
    SekibankiHead = Require("scripts/familiars/sekibanki_head"),
    ThunderDrum = Require("scripts/familiars/thunder_drum"),
    HellPlanets = Require("scripts/familiars/hell_planets"),
    SunnyFairy = Require("scripts/familiars/sunny_fairy"),
    LunarFairy = Require("scripts/familiars/lunar_fairy"),
    StarFairy = Require("scripts/familiars/star_fairy"),
    YoungNativeGod = Require("scripts/familiars/young_native_god"),
    DancerServant = Require("scripts/familiars/dancer_servant"),
    BackDoor = Require("scripts/familiars/back_door"),
    Unzan = Require("scripts/familiars/unzan"),
    Haniwa = Require("scripts/familiars/haniwa")
}
THI.Slots = {
    Trader = Require("scripts/slots/trader"),
    DoorKeeper = Require("scripts/slots/doorkeeper")
}

THI.Monsters = {
    BloodBony = Require("scripts/monsters/blood_bony"),
    BonusUFO = Require("scripts/monsters/bonus_ufo"),
    EvilSpirit = Require("scripts/monsters/evil_spirit"),
    Immortal = Require("scripts/monsters/immortal"),
    Rebecha = Require("scripts/monsters/rebecha"),
    NightmareSpider = Require("scripts/monsters/nightmare_spider"),
    NightmarePooter = Require("scripts/monsters/nightmare_pooter"),
    NightmareCoin = Require("scripts/monsters/nightmare_coin"),
    NightmareSoul = Require("scripts/monsters/nightmare_Soul"),
    DeliriousGaper = Require("scripts/monsters/delirious_gaper"),
    ZunKeeper = Require("scripts/monsters/zun_keeper")
}

THI.Rooms = {
    MovedShop = Require("scripts/rooms/moved_shop"),
    HiddenRoukanken = Require("scripts/rooms/hidden_roukanken"),
    FortuneTeller = Require("scripts/rooms/fortune_teller"),
    DrunkardsBase = Require("scripts/rooms/drunkards_base"),
    UndergroundBar = Require("scripts/rooms/underground_bar"),
    RinsGraveyard = Require("scripts/rooms/rins_graveyard"),
    ReimuInWater = Require("scripts/rooms/reimu_in_water"),
    Bankis = Require("scripts/rooms/bankis"),
    MarisaStake = Require("scripts/rooms/marisa_stake"),
    ReverseAll = Require("scripts/rooms/reverse_all"),
    Tentacles = Require("scripts/rooms/tentacles"),
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
Collectibles.AshOfPhoenix = Require("scripts/items/th8/ash_of_phoenix");

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
Collectibles.WolfEye = Require("scripts/items/th10/wolf_eye");
Collectibles.Benediction = Require("scripts/items/th10/benediction");
Collectibles.Onbashira = Require("scripts/items/th10/onbashira");
Collectibles.YoungNativeGod = Require("scripts/items/th10/young_native_god");

-- TH10.5
Collectibles.Keystone = Require("scripts/items/th10-5/keystone");
Collectibles.AngelsRaiment = Require("scripts/items/th10-5/angels_raiment");

-- TH11
Collectibles.BucketOfWisps = Require("scripts/items/th11/bucket_of_wisps");
Collectibles.PlagueLord = Require("scripts/items/th11/plague_lord");
Collectibles.GreenEyedEnvy = Require("scripts/items/th11/green_eyed_envy");
Collectibles.OniHorn = Require("scripts/items/th11/oni_horn");
Collectibles.PsycheEye = Require("scripts/items/th11/psyche_eye");
Collectibles.GuppysCorpseCart = Require("scripts/items/th11/guppys_corpse_cart");
Collectibles.Technology666 = Require("scripts/items/th11/technology_666");
Collectibles.PsychoKnife = Require("scripts/items/th11/psycho_knife");
-- TH12
Collectibles.DowsingRods = Require("scripts/items/th12/dowsing_rods");
Collectibles.ScaringUmbrella = Require("scripts/items/th12/scaring_umbrella");
Collectibles.Unzan = Require("scripts/items/th12/unzan");
Collectibles.Pagota = Require("scripts/items/th12/bishamontens_pagota");
Collectibles.SorcerersScroll = Require("scripts/items/th12/sorcerers_scroll");
Collectibles.SaucerRemote = Require("scripts/items/th12/saucer_remote");

-- TH12.5
Collectibles.TenguCellphone = Require("scripts/items/th12-5/tengu_cellphone");
-- TH13
Collectibles.MountainEar = Require("scripts/items/th13/mountain_ear");
Collectibles.ZombieInfestation = Require("scripts/items/th13/zombie_infestation");
Collectibles.WarpingHairpin = Require("scripts/items/th13/warpping_hairpin");
Collectibles.HolyThunder = Require("scripts/items/th13/holy_thunder");
Collectibles.GeomanticDetector = Require("scripts/items/th13/geomantic_detector");
Collectibles.Lightbombs = Require("scripts/items/th13/lightbombs");
Collectibles.D2147483647 = Require("scripts/items/th13/d2147483647");
-- TH13.5
Collectibles.TheInfamies = Require("scripts/items/th13-5/the_infamies");
-- TH14
Collectibles.SekibankisHead = Require("scripts/items/th14/sekibankis_head");
Collectibles.WildFury = Require("scripts/items/th14/wild_fury");
Collectibles.ReverieMusic = Require("scripts/items/th14/reverie_music");
Collectibles.DFlip = Require("scripts/items/th14/d_flip");
Collectibles.MiracleMallet = Require("scripts/items/th14/miracle_mallet");
Collectibles.ThunderDrum = Require("scripts/items/th14/thunder_drum");
-- Collectibles.DualDivision = Require("scripts/items/th14/dual_division");
Collectibles.DSiphon = Require("scripts/items/th14/d_siphon");
Collectibles.THTRAINER = Require("scripts/items/th14/thtrainer");
-- TH14.3
Collectibles.NimbleFabric = Require("scripts/items/th14-3/nimble_fabric");
Collectibles.MiracleMalletReplica = Require("scripts/items/th14-3/miracle_mallet_replica");
-- TH14.5
Collectibles.RuneCape = Require("scripts/items/th14-5/rune_cape");
-- TH15
Collectibles.LunaticGun = Require("scripts/items/th15/lunatic_gun");
Collectibles.ViciousCurse = Require("scripts/items/th15/vicious_curse");
Collectibles.CarnivalHat = Require("scripts/items/th15/carnival_hat");
Collectibles.PureFury = Require("scripts/items/th15/pure_fury");
Collectibles.Hekate = Require("scripts/items/th15/hekate");
-- TH15.5
Collectibles.DadsShares = Require("scripts/items/th15-5/dads_shares");
Collectibles.MomsIOU = Require("scripts/items/th15-5/moms_iou");
-- TH16
Collectibles.YamanbasChopper = Require("scripts/items/th16/yamanbas_chopper");
Collectibles.GolemOfIsaac = Require("scripts/items/th16/golem_of_isaac");
Collectibles.DancerServants = Require("scripts/items/th16/dancer_servants")
Collectibles.BackDoor = Require("scripts/items/th16/back_door")
-- TH17
Collectibles.FetusBlood = Require("scripts/items/th17/fetus_blood");
Collectibles.CockcrowWings = Require("scripts/items/th17/cockcrow_wings");
Collectibles.KiketsuBlackmail = Require("scripts/items/th17/kiketsu_familys_blackmail");
Collectibles.CarvingTools = Require("scripts/items/th17/carving_tools");
Collectibles.BrutalHorseshoe = Require("scripts/items/th17/brutal_horseshoe");

-- TH17.5
Collectibles.Hunger = Require("scripts/items/th17-5/hunger");

Collectibles.DreamSoul = {Item = Isaac.GetItemIdByName("Dream Soul")};

-- TH18
Collectibles.GamblingD6 = Require("scripts/items/th18/gambling_d6");
Collectibles.YamawarosCrate = Require("scripts/items/th18/yamawaros_crate");
Collectibles.DelusionPipe = Require("scripts/items/th18/delusion_pipe");
Collectibles.SoulMagatama = Require("scripts/items/th18/soul_magatama");
Collectibles.FoxInTube = Require("scripts/items/th18/fox_in_tube");
Collectibles.DaitenguTelescope = Require("scripts/items/th18/daitengu_telescope");
Collectibles.ExchangeTicket = Require("scripts/items/th18/exchange_ticket");
Collectibles.CurseOfCentipede = Require("scripts/items/th18/curse_of_centipede");


Collectibles.ParasiticMushroom = Require("scripts/items/protagonists/parasitic_mushroom");
-- TH6 ALT
Collectibles.FairyDust = Require("scripts/items/th6/fairy_dust");
Collectibles.SpiritCannon = Require("scripts/items/th6/spirit_cannon");
Collectibles.Asthma = Require("scripts/items/th6/asthma");
Collectibles.DaggerOfServants = Require("scripts/items/th6/dagger_of_servants");
Collectibles.ByteString = Require("scripts/items/th6/byte_string");

-- TH11 ALT
Collectibles.Jealousy = Require("scripts/items/th11/jealousy");

-- TH12 ALT
Collectibles.EyeOfChimera = Require("scripts/items/th12/eye_of_chimera");

-- Make resistance of player at the last.
Collectibles.BuddhasBowl = Require("scripts/items/th8/buddhas_bowl");
Collectibles.SwallowsShell = Require("scripts/items/th8/swallows_shell");


-- Printworks
Collectibles.IsaacsLastWills = Require("scripts/items/printworks/isaacs_last_wills");
Collectibles.SunnyFairy = Require("scripts/items/printworks/sunny_fairy");
Collectibles.LunarFairy = Require("scripts/items/printworks/lunar_fairy");
Collectibles.StarFairy = Require("scripts/items/printworks/star_fairy");
Collectibles.EmptyBook = Require("scripts/items/printworks/empty_book");
Collectibles.GeographicChain = Require("scripts/items/printworks/geographic_chain");
Collectibles.RuneSword = Require("scripts/items/printworks/rune_sword");
Collectibles.Escape = Require("scripts/items/printworks/escape");
Collectibles.EtherealArm = Require("scripts/items/printworks/ethereal_arm");
Collectibles.SakeOfForgotten = Require("scripts/items/printworks/sake_of_forgotten");
Collectibles.RebelMechaCaller = Require("scripts/items/printworks/rebel_mecha_caller");

-- Printworks ALT.
Collectibles.Dejavu = Require("scripts/items/printworks/dejavu");




THI.Collectibles = Collectibles;

THI.MinCollectibleID = Collectibles.YinYangOrb.Item;
THI.MaxCollectibleID = THI.MinCollectibleID;
for k,v in pairs(Collectibles) do
    if (v and v.Item > THI.MaxCollectibleID) then
        THI.MaxCollectibleID = v.Item;
    end
end

function THI:ContainsCollectible(id)
    return id >= self.MinCollectibleID and id <= self.MaxCollectibleID;
end



THI.Transformations = {
    Musician = Require("scripts/transformations/musician");
}

THI.Challenges = {
    HeavyDebt = Require("scripts/challenges/heavy_debt"),
    ShadowDieTwice = Require("scripts/challenges/shadow_die_twice"),
    SteamAge = Require("scripts/challenges/steam_age"),
    PurePurist = Require("scripts/challenges/pure_purist"),
    PhotoExam = Require("scripts/challenges/photo_exam"),
}


THI.GensouDream = Require("scripts/doremy/main");
function THI:IsDreamWorld()
    return self.GensouDream:IsDreamWorld();
end

THI.Trinkets = {
    FrozenFrog = Require("scripts/trinkets/frozen_frog"),
    AromaticFlower = Require("scripts/trinkets/aromatic_flower"),
    GlassesOfKnowledge = Require("scripts/trinkets/glasses_of_knowledge"),
    HowToReadABook = Require("scripts/trinkets/how_to_read_a_book"),
    CorrodedDoll = Require("scripts/trinkets/corroded_doll"),
    LionStatue = Require("scripts/trinkets/lion_statue"),
    FortuneCatPaw = Require("scripts/trinkets/fortune_cat_paw"),
    GhostAnchor = Require("scripts/trinkets/ghost_anchor"),
    MermanShell = Require("scripts/trinkets/merman_shell"),
    Dangos = Require("scripts/trinkets/dangos"),
    BundledStatue = Require("scripts/trinkets/bundled_statue"),
    ShieldOfLoyalty = Require("scripts/trinkets/shield_of_loyalty"),
    SwordOfLoyalty = Require("scripts/trinkets/sword_of_loyalty"),
    ButterflyWings = Require("scripts/trinkets/butterfly_wings"),

    -- TH6 ALT
    Snowflake = Require("scripts/trinkets/snowflake"),
    HeartSticker = Require("scripts/trinkets/heart_sticker"),

    SymmetryOCD = Require("scripts/trinkets/symmetry_ocd")
}


-- Synergies

--- Hunger
Collectibles.Hunger:SetCollectibleHunger(Collectibles.BakedSweetPotato.Item, 3);
Collectibles.Hunger:SetTrinketHunger(THI.Trinkets.Dangos.Trinket, 2);
Collectibles.Hunger:SetTrinketHunger(THI.Trinkets.ButterflyWings.Trinket, 1);

--- DFlip
--Dr. Fetus - Fetus Blood
Collectibles.DFlip:AddFixedPair(5,100,CollectibleType.COLLECTIBLE_DR_FETUS, 5,100, Collectibles.FetusBlood.Item);
--Godhead - Broken Amulet
Collectibles.DFlip:AddFixedPair(5,100,CollectibleType.COLLECTIBLE_GODHEAD, 5,100, Collectibles.BrokenAmulet.Item);
--Genesis - Destruction
Collectibles.DFlip:AddFixedPair(5,100,CollectibleType.COLLECTIBLE_GENESIS, 5,100, Collectibles.Destruction.Item);
--Brimstone Bombs - Lightbombs
Collectibles.DFlip:AddFixedPair(5,100,CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS, 5,100, Collectibles.Lightbombs.Item);
--Starseeker - Pathseeker
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.Starseeker.Item, 5,100, Collectibles.Pathseeker.Item);
--Wolf Eye - Wild Fury
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.WolfEye.Item, 5,100, Collectibles.WildFury.Item);
--Onbashira - Young Native God
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.Onbashira.Item, 5,100, Collectibles.YoungNativeGod.Item);
--D Flip - D DSiphon
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.DFlip.Item, 5,100, Collectibles.DSiphon.Item);
--Miracle Mallet - Miracle Mallet Replica
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.MiracleMallet.Item, 5,100, Collectibles.MiracleMalletReplica.Item);
--Mom's IOU - Dad's Shares
Collectibles.DFlip:AddFixedPair(5,100,Collectibles.MomsIOU.Item, 5,100, Collectibles.DadsShares.Item);
--Soul of Seija - Another Soul of Seija
Collectibles.DFlip:AddFixedPair(5,300,THI.Cards.SoulOfSeija.ID, 5,300, THI.Cards.SoulOfSeija.ReversedID);

include("scripts/post_load.lua");

ModEntity = nil;
ModItem = nil;
ModChallenge = nil;
ModCard = nil;
ModTrinket = nil;
ModPart = nil;

do
    local Translations = CuerLib.Translations;
    THI.Translations = {};
    local language = Options.Language;
    
    THI.Translations.en = Require("translations/en");
    for _, language in pairs(Translations.IncludedLanguages) do
        THI.Translations[language] = Require("translations/"..language);
    end

    for lang, translation in pairs(THI.Translations) do
        if (translation and type(translation) == "table") then
            if (translation.Collectibles) then
                for id, info in pairs(translation.Collectibles) do
                    Translations:SetCollectible(lang, id, info)
                end
            end
            if (translation.Trinkets) then
                for id, info in pairs(translation.Trinkets) do
                    Translations:SetTrinket(lang, id, info)
                end
            end
            if (translation.Players) then
                for id, info in pairs(translation.Players) do
                    Translations:SetPlayer(lang, id, info)
                end
            end
            if (translation.Cards) then
                for id, info in pairs(translation.Cards) do
                    Translations:SetCard(lang, id, info)
                end
            end
            if (translation.Pills) then
                for id, info in pairs(translation.Pills) do
                    Translations:SetPillEffect(lang, id, info)
                end
            end
            if (translation.Texts) then
                for key, text in pairs(translation.Texts) do
                    Translations:SetText(THI, lang, key, text)
                end
            end
        end
    end

    function THI.ContainsText(key, lang)
        return not not THI.GetText(key, lang);
    end
    function THI.GetText(key, lang)
        local lang = lang or language;
        return Translations:GetText(THI, lang, key);
    end
    function THI.GetFont(key, lang)
        local lang = lang or language;
        local Translations = THI.Translations;
        local translation = Translations[lang];
        if (translation) then
            return translation.Fonts[key];
        end
    
        local en = Translations.en;
        if (en) then
            return en.Fonts[key];
        end        
        return THI.Fonts.Lanapixel;
    end

end

if (EID) then
    Require("descriptions/rep/main")
end

if (HPBars) then
    Require("compatilities/boss_bars")
end

-- Lunatic.
do
    local Lunatic = {}

    local IsLunatic = false;

    function Lunatic.UpdateLunatic()
        local persistent = SaveAndLoad:ReadPersistentData();
        if (persistent.Lunatic) then
            IsLunatic = true;
        end
    end
    Lunatic.UpdateLunatic();

    function THI.IsLunatic()
        return IsLunatic;
    end

    function THI.SetLunatic(value)
        local persistent = SaveAndLoad:ReadPersistentData();
        persistent.Lunatic = value;
        IsLunatic = value;
        SaveAndLoad:WritePersistentData(persistent);
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
    LunaticIcon:Load("gfx/reverie/ui/lunatic.anm2", true);
    LunaticIcon:Play("Icon");
    LunaticIcon.Color = Color(1,1,1,0.3)
    function Lunatic:PostRender()
        if (THI.Game:GetHUD():IsVisible ( ) and THI.IsLunatic()) then
            local size = Lib.Screen.GetScreenSize() 
            local pos = Vector(size.X / 2 + 60, 14 + Options.HUDOffset * 24);
            LunaticIcon:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_RENDER, Lunatic.PostRender)

end


-- Reevaluate caches after gameStarted.
function THI:PostGameStartEvaluate(isContinued)
    if  (isContinued) then
        for index, player in Lib.Players.PlayerPairs(true, true) do
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
    function THI:EvaluateCurses()
        Lib.Curses:EvaluateCurses();
    end
end

do -- Queued Item.

    THI.QueuedItemNil = nil;
    
    local function PostPlayerUpdate(mod, player)
        local queuedItem = player.QueuedItem.Item;
        if (not queuedItem) then
            THI.QueuedItemNil = player.QueuedItem
        end
    end
    THI:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);
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
print("[Reverie] Reverie "..THI:GetVersionString().." Loaded.")

function SpawnPlanets()
    local planets = THI.Familiars.HellPlanets;
    local planet1 = Isaac.Spawn(planets.Type, planets.Variant, planets.SubTypes.OTHERWORLD, Vector(320, 280), Vector.Zero, nil):ToFamiliar();
    planet1.Parent = Isaac.GetPlayer();
    
    local planet2 = Isaac.Spawn(planets.Type, planets.Variant, planets.SubTypes.EARTH, Vector(320, 280), Vector.Zero, nil):ToFamiliar();
    planet2.Parent = planet1;
    
    local planet3 = Isaac.Spawn(planets.Type, planets.Variant, planets.SubTypes.MOON, Vector(320, 280), Vector.Zero, nil):ToFamiliar();
    planet3.Parent = planet2;
end