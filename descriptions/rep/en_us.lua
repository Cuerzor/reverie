------------------------------------------------------------------
-----  Basic English descriptions based on Platinumgod.co.uk -----
------------------------------------------------------------------
-- FORMAT: Item ID | Name| Description
-- '#' = starts new line of text
-- Special character markup:
-- ↑ = Up Arrow   |  ↓ = Down Arrow    | ! = Warning
local Collectibles = THI.Collectibles;
local Trinkets = THI.Trinkets;
local Players = THI.Players;

local EIDInfo = {};

EIDInfo.Entries = {
    ["Lunatic"] = "{{ColorPurple}}Lunatic Mode{{CR}}: ",
    ["TouhouCharacter"] = "{{ColorPink}}Character:{{CR}} "
}

EIDInfo.Transformations = {
    ReverieMusician = "Musician"
}
            
EIDInfo.Collectibles = {
    [Collectibles.YinYangOrb.Item] = {
        Description = "Throw a bouncing Yin-Yang Orb#Deal 20 collision damage",
        BookOfVirtues = "Yin-Yang Orb wisps",
        TouhouCharacter = "Reimu Hakurei"
    },
    [Collectibles.DarkRibbon.Item] = {
        Description = "Player has a damaging aura, dealing 10.71 damage every second#↑ +50% damage while standing in the aura",
        TouhouCharacter = "Rumia"
    },
    [Collectibles.DYSSpring.Item] = {
        Description = "+2 Soul Hearts#Full health#Full charges#Has 10% chance to transform any hearts into fairies#Fairies will fully heal Isaac and grant 1 Soul Heart",
        TouhouCharacter = "Daiyousei"
    },
    [Collectibles.DragonBadge.Item] = {
        Description = "Dash into enemies#Invincible while dashing#Release fists and gain more dash time upon hit",
        BookOfVirtues = "Fist tears",
        TouhouCharacter = "Hong Meiling"
    },
    [Collectibles.Grimoire.Item] = {
        Description = "Obtain random tear effects for current floor#Effects: Homing, Charm, Burn, Slow, Poison, Magnetize, Rock#If all 7 effects are obtained, teleport you to the I AM ERROR Room",
        BookOfVirtues = "Elemental / Error wisps",
        TouhouCharacter = "Patchouli Knowledge"
    },
    [Collectibles.MaidSuit.Item] = {
        Description = "Spawn {{Card21}}XXI - The World#Pause all enemies after enters a room#{{Card21}} XXI - The World has the time stop and knifes effect#Has a chance to spawn {{Card21}} XXI - The World after clearing a room",
        TouhouCharacter = "Sakuya Izayoi"
    },
    [Collectibles.VampireTooth.Item] = {
        Description = "↑ +1 Damage#↑ +2 Luck#Flight#!!! {{Card20}}XIX - The Sun will damage all Red Hearts#{{Card19}}XVIII - The Moon will teleport you to the Ultra Secret Room",
        TouhouCharacter = "Remilia Scarlet"
    },
    [Collectibles.Koakuma.Item] = {
        Description = "Large tear familiar#Deals 3 Damage per tear#Has synergies with {{Bookworm}} Bookworm and {{Collectible" ..
            Collectibles.Grimoire.Item .. "}} Grimoire of Patchouli",
        TouhouCharacter = "Koakuma"
    },
    [Collectibles.Destruction.Item] = {
        Description = "Spawn a meteor that explodes and cracks into fragments#Keep falling meteors at Isaac's position in current room",
        BookOfVirtues = "Burning tears, explodes upon put out",
        TouhouCharacter = "Flandre Scarlet"
    },
    [Collectibles.MarisasBroom.Item] = {
        Description = "Flight#↑ +1 Damage, -0.5 Fire Delay, +0.3 Speed for each kind of mushroom items you have",
        TouhouCharacter = "Marisa Kirisame"
    },
    [Collectibles.FrozenSakura.Item] = {
        Description = "Player has a damaging aura, dealing 4.3 damage every second#Slows enemies and projectiles in the aura#Freeze enemies killed by the aura",
        TouhouCharacter = "Letty Whiterock"
    },
    [Collectibles.ChenBaby.Item] = {
        Description = "Familiar that charges forward#Deals 3.5 contact damage and fly to the nearest enemy#One of Nine Tails will Double its damage",
        TouhouCharacter = "Chen"
    },
    [Collectibles.ShanghaiDoll.Item] = {
        Description = "Orbital#Charge into enemies close to player and deal 3.5 damage",
        TouhouCharacter = "Alice Margatroid"
    },
    [Collectibles.MelancholicViolin.Item] = {
        Description = "Spawn a violin for 10 seconds#↑ -4 Fire Delay in the range#Slow enemies in the range",
        BookOfVirtues = "Slow tears",
        TouhouCharacter = "Lunasa Prismriver"
    },
    [Collectibles.ManiacTrumpet.Item] = {
        Description = "Spawn a trumpet for 10 seconds#↑ +50% Damage in the range#Damage enemies in the range",
        BookOfVirtues = "Confuse tears",
        TouhouCharacter = "Merlin Prismriver"
    },
    [Collectibles.IllusionaryKeyboard.Item] = {
        Description = "Spawn a keyboard for 10 seconds#↑ +1 Speed in the range#Remove all projectiles in the range",
        BookOfVirtues = "Charming tears",
        TouhouCharacter = "Lyrica Prismriver"
    },
    [Collectibles.DeletedErhu.Item] = {
        Description = "Remove all enemies and obstacles in current room#Removed enemies or obstacles will no longer appear in current game#This disappears",
        BookOfVirtues = "Glitched wisp",
        TouhouCharacter = "Rin Satsuki"
    },
    [Collectibles.Roukanken.Item] = {
        Description = "Cut enemies by sword in 18 second, deals 5x Player Damage per hit and can destroy obstalces#Will dash into movement direciton if use again while using sword, deals 2x Player Damage per hit#Charges active items after kills using dash",
        BookOfVirtues = "Melee wisp that can destory obstacles",
        TouhouCharacter = "Youmu Konpaku"
    },
    [Collectibles.FanOfTheDead.Item] = {
        Description = "Flight#Spectral Tears#Transform all Heart Containers or Soul Hearts into extra lives#",
        TouhouCharacter = "Yuyuko Saigyouji"
    },
    [Collectibles.FriedTofu.Item] = {
        Description = "↑ +1 Health up",
        TouhouCharacter = "Ran Yakumo"
    },
    [Collectibles.OneOfNineTails.Item] = {
        Description = "Spawn an item from baby shop#Spawn items from baby shop after a new stage#↑ Damage up for each familiar you have#Max damage multiplier is 150% when familiars are 9#Chen Baby counts as 3 familiars.",
        TouhouCharacter = "Ran Yakumo"
    },
    [Collectibles.Gap.Item] = {
        Description = "Generate teleporter floors which are connected to all rooms#Use The Gap on the floors to teleport#Includes Ultra Secret Room",
        BookOfVirtues = "Teleporting tears",
        TouhouCharacter = "Yukari Yakumo"
    },
    [Collectibles.Starseeker.Item] = {
        Description = "After entering the room with items, generate three crystal balls#After picking up the crystal ball, the other two will disappear#the next item in this room type will be replaced by the chosen item#Choose for each items in the room",
        TouhouCharacter = "Renko Usami"
    },
    [Collectibles.Pathseeker.Item] = {
        Description = "Generate floors which displays all rooms in the starting room each stage#If player has The Gap, can use these to teleport",
        TouhouCharacter = "Maribel Hearn"
    },
    [Collectibles.GourdShroom.Item] = {
        Description = "Switch into sparse or dense form after Isaac takes damage#↑ x1.35 Damage, +5 Range, x1.5 Size and can crush rocks while in dense form#↑ x0.7 Fire Delay, +0.5 Speed, x0.75 Size and summon 5 minisaacs while in sparse form",
        TouhouCharacter = "Suika Ibuki"
    },
    [Collectibles.JarOfFireflies.Item] = {
        Description = "Spawn 12 friendly Onfire Flies#Onfire Flies will explode upon contact or death, deal damages equals to player's damage#Clear the Curse of Darkness",
        BookOfVirtues = "3 wisps that spawn Onfire Flies upon put out",
        TouhouCharacter = "Wriggle Nightbug"
    },
    [Collectibles.SongOfNightbird.Item] = {
        Description = "Has Curse of Darkness permanently#Monsters far away against Isaac get confused, and will take 1.5x damage",
        TouhouCharacter = "Mystia Lorelei"
    },
    [Collectibles.BookOfYears.Item] = {
        Description = "Remove a random passive collectible item with the lowest quality, spawn a random collectible.",
        BookOfVirtues = "Spawn {{Collectible"..CollectibleType.COLLECTIBLE_MISSING_PAGE_2.."}}Missing Page 2 upon put out",
        TouhouCharacter = "Keine Kamishirasawa"
    },
    [Collectibles.RabbitTrap.Item] = {
        Description = "↑ +1 Luck#Spawn traps after enters a room with enemies#Traps can instantly kill non-flying monsters, and deal 30 damage per 20 frames to bosses",
        TouhouCharacter = "Tewi Inaba"
    },
    [Collectibles.Illusion.Item] = {
        Description = "Spawn 4 illusions around Isaac#They deal contact damages equals to half of player's damage per 7 frames#Shoot blood tears which damage are 3.5",
        TouhouCharacter = "Reisen Udongein Inaba"
    },
    [Collectibles.PeerlessElixir.Item] = {
        Description = "↑ +0.6 Damage, +0.6 Fire Rate and +0.3 Speed in current floor#!!! After the fourth use in current floor, Isaac explodes and dies",
        
        BookOfVirtues = "Powerful green wisps but will explode upon put out",
        TouhouCharacter = "Eirin Yagokoro"
    },
    [Collectibles.DragonNeckJewel.Item] = {
        Description = "Spawn lightbolts at the nearest enemy per 3 seconds#Lightbolts spawns 5 tears, each deals 3.5 damage",
        TouhouCharacter = "Kaguya Houraisan"
    },
    [Collectibles.BuddhasBowl.Item] = {
        Description = "Whenever you take damage, prevent next damage",
        TouhouCharacter = "Kaguya Houraisan"
    },
    [Collectibles.RobeOfFirerat.Item] = {
        Description = "Spawn a fire orbital#Tears pass through fires transform into new fires#Immune to fires",
        TouhouCharacter = "Kaguya Houraisan"
    },
    [Collectibles.SwallowsShell.Item] = {
        Description = "Spawn an {{AngelRoom}}angle room item after enters a new floor#Spawn an extra soul heart for each {{Conjoined}} Conjoined item#Disappears upon taking damage",
        TouhouCharacter = "Kaguya Houraisan"
    },
    [Collectibles.JeweledBranch.Item] = {
        Description = "Isaac Fire tears to a ring around him#If tear count reaches it's limit as 5, one of them will fly to the nearest enemies",
        TouhouCharacter = "Kaguya Houraisan"
    },
    [Collectibles.AshOfPheonix.Item] = {
        Description = "Isaac transform into ashes and release fire waves after death.#If ash pile doesn't take any damage in 2 seconds, revive Isaac and release fire waves.#!!! Self-damaging will not trigger this effect.",
        TouhouCharacter = "Fujiwara no Mokou"
    },

    [Collectibles.TenguCamera.Item] = {
        Description = "Displays a fanshaped area when held#After use, Freeze and deal 5 damage to enemies, and destroy projectiles in the area#Generate bonuses depends on the score:#10: 1 penny 12: 1 key#16: 1 bomb  22: 1 pill#30: 1 card  40: 1 trinket#52: 1 soul heart#66: Negative#82: Torn Photo#100: Death Certificate",
        BookOfVirtues = "Turn projectiles into black wisps that cannot shoot",
        TouhouCharacter = "Aya Shameimaru"
    },
    [Collectibles.SunflowerPot.Item] = {
        Description = "Sunflower familiar on Isaac's head#After cleared a room, spawn a pickup or collectible#!!! After Isaac takes damage, sunflower dies. Then explode and deal 1 heart extra damage to Isaac#Revive next floor#{{Collectible" ..
            CollectibleType.COLLECTIBLE_BFFS .. "}}BFFs! will make it drop 2 items",
        TouhouCharacter = "Yuuka Kazami"
    },
    [Collectibles.ContinueArcade.Item] = {
        Description = "+3 Coins#After Isaac dies, pay 3 coins for resurrection with full red hearts in current room#Every resurrection triples the cost",
        TouhouCharacter = "Komachi Onozuka"
    },
    [Collectibles.RodOfRemorse.Item] = {
        Description = "Deal a heart of damage to Isaac (Red hearts first), and trigger sacrifice room's effect once#Sacrifice count is not related to any sacrifice rooms, and will be reset after floors",
        BookOfVirtues = "Has 25% chance to drop a red heart upon put out",
        TouhouCharacter = "Eiki Shiki, Yamaxanadu"
    },

    [Collectibles.IsaacsLastWills.Item] = {
        Description = "!!! One-time Use!#Send all collectibles and trinkets in the current room to the next run#!!! Doesn't work in seeded runs or challenges#!!! If mod is disabled then, have no effect until you enable this mod",
        BookOfVirtues = "Spawn powerful wisps in the next run",
        TouhouCharacter = "Hieda no Akyuu"
    },

    [Collectibles.LeafShield.Item] = {
        Description = "Spawn leaf shield per 3 seconds#Deals 4 damage per 7 seconds and block any projectiles#Press shoot buttons to fire this shield away",
        TouhouCharacter = "Shizuha Aki"
    },
    [Collectibles.BakedSweetPotato.Item] = {
        Description = "↑ +1 Health up#↑ +5 Damage, will scale down over 2 minutes",
        TouhouCharacter = "Minoriko Aki"
    },
    [Collectibles.BrokenAmulet.Item] = {
        Description = "↓ -3 Luck#Tears have black auras, enemies in the aura take damages per 2 frames#The lower luck Isaac has, the aura is larger, and the damage is higher#Damage is 20% player damage as the mininium when luck is 0#Damage is 80% player damage as the maxinium when luck is -5",
        TouhouCharacter = "Hina Kagiyama"
    },
    [Collectibles.ExtendingArm.Item] = {
        Description = "Shoot a hook to a direction#Hit enemies will be frozen, and pulled to Isaac#After hit an obstacle, pull Isaac to it#After hit a pickup, pull the pickup to Isaac#Isaac will be invincible until pulling is over",
        BookOfVirtues = "Spawn temporary green wisps when extending",
        TouhouCharacter = "Nitori Kawashiro"
    },
    [Collectibles.Benediction.Item] = {
        Description = "Can be used at any charges#Get an angel room collectible depends on the charges until next floor:".."#1: {{Collectible"..CollectibleType.COLLECTIBLE_HALLOWED_GROUND.."}}Hallowed Ground"..
        "#2: {{Collectible"..CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL.."}}Guardian Angel"..
        "#3: {{Collectible"..CollectibleType.COLLECTIBLE_ANGELIC_PRISM.."}}Angelic Prism".. 
        "#4: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_WATER.."}}Holy Water"..
        "#5: {{Collectible"..CollectibleType.COLLECTIBLE_TRISAGION.."}}Trisagion"..
        "#6: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_LIGHT.."}}Holy Light"..
        "#7: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}}Holy Mantle"..
        "#8: {{Collectible"..CollectibleType.COLLECTIBLE_SALVATION.."}}Salvation"..
        "#9: {{Collectible"..CollectibleType.COLLECTIBLE_GODHEAD.."}}Godhead"..
        "#10: {{Collectible"..CollectibleType.COLLECTIBLE_REVELATION.."}}Revelation"..
        "#11: {{Collectible"..CollectibleType.COLLECTIBLE_SACRED_HEART.."}}Sacred Heart"..
        "#12: {{Collectible"..CollectibleType.COLLECTIBLE_SACRED_ORB.."}}Sacred Orb",
        BookOfVirtues = "Wisp's HP depends on charges",
        TouhouCharacter = "Sanae Kochiya"
    },

    [Collectibles.RuneSword.Item] = {
        Description = "Spawn a rune upon pickup#Insert holding rune into this item, transform it into passive effect#Replace some random cards into runes",
        BookOfVirtues = "Rune wisps",
        TouhouCharacter = "Watatsuki no Yorihime"
    },

    [Collectibles.PlagueLord.Item] = {
        Name = "Plague Lord",
        Description = "Poison nearby enemies#Poisoned enemies leave poison clouds after death",
        TouhouCharacter = "Yamame Kurodani"
    },
    [Collectibles.GreenEyedEnvy.Item] = {
        Description = "After entering a room, reduce all non-final-boss enemies' health to 40%#After they die, spawn 2 copies with 20% health",
        TouhouCharacter = "Parsee Mizuhashi"
    },
    [Collectibles.PsycheEye.Item] = {
        Description = "Eye familiar#Shoots a mind-controlling tear per second, which turns hit monster friendly#Hit boss will be charmed for 5 seconds#Remove Curse of Lost, Blindness and Unknown",
        TouhouCharacter = "Satori Komeiji"
    },
    [Collectibles.OniHorn.Item] = {
        Name = "Oni Horn",
        Description = "↑ +1 Damage#Each time Isaac get damaged:#First time: Spawn a circle of shockwaves#Second time: Spawn 3 circles of shockwaves and explode#Third time: Fill the room with shockwaves, and cause a mega explosion#After the third time or leaving the room. reset the damage counter#!!! Only Blood Donation Machines, Confessionals and Beggars don't trigger this effect",
        TouhouCharacter = "Yuugi Hoshiguma"
    },
    [Collectibles.Technology666.Item] = {
        Description = "fired an additional yellow brimstone per second, deals 25% player damage#If the brimstone kills an enemy, the enemy explodes and bursts 6 new brimstone lasers at the enemy's position#The explosion cannot damage players, and bursted brimstone lasers has the same effect",
        TouhouCharacter = "Utsuho Reiuji"
    },
    [Collectibles.PsychoKnife.Item] = {
        Description = "Execute a nearby enemy#Will instantly kill monsters, and deal huge damage that ignores armor to bosses, then shakes enemies away#If enemy has low health or some debuffs, the range is doubled",
        BookOfVirtues = "Dark wisps",
        TouhouCharacter = "Koishi Komeiji"
    },

    
    [Collectibles.DowsingRods.Item] = {
        Description = "Hide pickups below normal rocks#Detect these rocks using radar waves#The closer the rock is, the more frequent radar waves are",
        TouhouCharacter = "Nazrin"
    },
    [Collectibles.ScaringUmbrella.Item] = {
        Description = "Block projectiles from above#Drop tear rains after shoot in current room#Randomly fear nearby enemies#Scare player while he does not have hazards",
        TouhouCharacter = "Kogasa Tatara"
    },
    [Collectibles.Pagota.Item] = {
        Description = "!!! One-time Use!#Needs coins as charges#Turn the whole floor gold, and transform all pickups and poops to golden version#Freeze all enemies and midas them for 5 seconds",
        BookOfVirtues = "12 golden wisps, fire midas tears",
        TouhouCharacter = "Shou Toramaru"
    },
    [Collectibles.SorcerersScroll.Item] = {
        Description = "!!! Remove all soul hearts (will not kill player)#For each half of removed soul hearts:#↑ +0.2 Damage#↑ +0.2 Firerate#↑ +0.03 Speed#↑ +0.4 Range",
        BookOfVirtues = "Spell wisps, increase player's all stats",
        TouhouCharacter = "Byakuren Hijiri"
    },
    [Collectibles.SaucerRemote.Item] = {
        Description = "Spawn a UFO which takes pickup and collectibles away#Spawn double bonus after destroyed UFO#UFO will run away after 15 seconds",
        BookOfVirtues = "Can cost 3 same color or 3 different colors of UFO wisps to freely use",
        TouhouCharacter = "Nue Houjuu"
    },

    [Collectibles.TenguCellphone.Item] = {
        Description = "Shopping online!#There are only three goods at a time, and is different between rooms#The goods are determined according to the current room type#The purchased goods will be delivered to the next floor#{{Collectible" ..
            CollectibleType.COLLECTIBLE_STEAM_SALE .. "}}Steam Sale will give these goods discounts",
        BookOfVirtues = "Midas tears",
        TouhouCharacter = "Hatate Himekaidou"
    },

    [Collectibles.MountainEar.Item] = {
        Name = "Mountain Ear",
        Description = "11% chance to shoot echo tears，which bounces in the room#disappears when hit player, and grant him temporary damage up#100% chance at 8 Luck",
        TouhouCharacter = "Kyouko Kasodani"
    },
    [Collectibles.ZombieInfestation.Item] = {
        Description = "Upon pickup, transform all red hearts into rotten hearts#When a monster is killed, spawn a new friendly copy of it#Copies cannot be brought out room",
        TouhouCharacter = "Yoshika Miyako"
    },
    [Collectibles.WarppingHairpin.Item] = {
        Description = "Teleports to the room at the other side of a wall",
        BookOfVirtues = "Weak gold tears",
        TouhouCharacter = "Seiga Kaku"
    },
    [Collectibles.D2147483647.Item] = {
        Description = "Can be used when has any charges#Transform this to any active item with inherited charges#After use transformed item, transform it back with remained charges#!!! Disappears after use one-time use items#!!! If transformed into D2147483647, will teleport player to I AM ERROR room after use again and disappears",
        BookOfVirtues = "None",
        TouhouCharacter = "Mamizou Futatsuiwa"
    },
    [Collectibles.TheInfamies.Item] = {
        Description = "Switch forms after clearing rooms:#↑ Pleasure: +0.3 Speed#↑ Anger: +2 Damage#↑ Sorrow: +1 Fire rate#↑ Fearness: +1 Luck#Has a chance to drop pokers after clearing rooms#Has synergies with {{Collectible" ..
            CollectibleType.COLLECTIBLE_INFAMY .. "}}Infamy, {{Collectible" .. CollectibleType.COLLECTIBLE_ISAACS_HEART ..
            "}}Isaac's Heart and Mask and Heart enemies",
        TouhouCharacter = "Hata no Kokoro"
    },
    [Collectibles.EmptyBook.Item] = {
        Description = "Select effects, and finish this item by yourself#!!! If you use Empty Book again, the new effects will override all old effects of books",
        BookOfVirtues = "None",
        TouhouCharacter = "Kosuzu Motoori"
    },

    [Collectibles.SekibankisHead.Item] = {
        Description = "Orbital#Deals 7 contact damage per 4 frames#Fire 2 lasers that deal 1.75 damage per 11 frames#Has interactions with {{Collectible"..CollectibleType.COLLECTIBLE_GUILLOTINE.."}}Guillotine, {{Collectible"..CollectibleType.COLLECTIBLE_PINKING_SHEARS.."}}The Pinking Shears, {{Collectible"..CollectibleType.COLLECTIBLE_SCISSORS.."}}Scissors and {{Collectible"..CollectibleType.COLLECTIBLE_DECAP_ATTACK.."}} Decap Attack",
        TouhouCharacter = "Sekibanki"
    },
    [Collectibles.DFlip.Item] = {
        Description = "Reroll pedestal collectibles into another one, Or reroll back#Transform Tarots in current room into reversed version#!!! Some collectible pairs are fixed",
        BookOfVirtues = "Destroy all this item's wisps, or spawn 3",
        TouhouCharacter = "Seija Kijin"
    },
    [Collectibles.MiracleMallet.Item] = {
        Description = "!!! ONE TIME USAGE !!!#Reroll all collectibles in the room into quality 4 collectibles#!!! Gain 3 broken hearts for each reroll",
        BookOfVirtues = "Midas tears",
        TouhouCharacter = "Shinmyoumaru Sukuna"
    },

    [Collectibles.ViciousCurse.Item] = {
        Description = "Gain {{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE ..
            "}}Damocles#Deal a heart of damage to Isaac#Double {{Collectible" ..
            CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE .. "}}Damocles' update rate",
        TouhouCharacter = "Sagume Kishin"
    },
    [Collectibles.PureFury.Item] = {
        Description = "↑ Damage x150%",
        TouhouCharacter = "Junko"
    },

    [Collectibles.DadsShares.Item] = {
        Description = "After clearing a room, spawn a penny#Upon takes damage, lose 5 pennies#Self-damaging will not trigger this effect",
        TouhouCharacter = "Joon Yorigami"
    },
    [Collectibles.MomsIOU.Item] = {
        Description = "↓-3 Luck#Only worth 1 penny in shop#Fill Isaac's coins to the limit#Pay 20% coins for debt after floors, with 20% interest#After paid off all debts, IOU disappears",
        TouhouCharacter = "Shion Yorigami"
    },

    [Collectibles.GolemOfIsaac.Item] = {
        Description = "A familiar that will automatically fight enemies, help you press buttons and open trap chests#Its damage and fire rate increases with the floor increases",
        TouhouCharacter = "Narumi Yatadera"
    },
    
    [Collectibles.KiketsuBlackmail.Item] = {
        Name = "Kiketsu Family's Blackmail",
        Description = "Fear nearby enemies#Charm enemies farther",
        TouhouCharacter = "Yachie Kitcho"
    },
    [Collectibles.Hunger.Item] = {
        Description = "Apply the Hunger system#Isaac loses Hunger while moving#Get healed if Hunger is larger than 9#Gain stats up if Hunger is larger than 8#Stats down and swallow trinkets if Hunger is less than 3#Take damages if Hunger is empty#Monsters drop food pickups#Food collectibles can restore Hunger",
        TouhouCharacter = "Yuuma Toutetsu"
    },

    [Collectibles.YamawarosCrate.Item] = {
        Description = "Provides slots for storing collectibles and trinkets#Can discard items#Can be expanded by {{Collectible"..CollectibleType.COLLECTIBLE_CAR_BATTERY.."}}Car Battery, {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES.."}}Book of Virtues and Judas' {{Collectible"..CollectibleType.COLLECTIBLE_BIRTHRIGHT.."}}Birthright",
        BookOfVirtues = "+2 Slots#can teleport to the start room using the blue scroll",
        BookOfBelial = "+2 Slots#Can use the red scroll to reroll collectibles in the room. Can only be used once each room",
        TouhouCharacter = "Takane Yamashiro"
    },

    [Collectibles.FoxInTube.Item] = {
        Description = "Provides helps in some situations#!!! If you accepts her helps, you will pay for this at sometime#Glass bottles spawn by her can be broken by tears",
        TouhouCharacter = "Tsukasa Kudamaki"
    },
    [Collectibles.DaitenguTelescope.Item] = {
        Description = "Has a chance to fall a meteor in a random room after a new floor, spawning a planetarium item#The chance increases if player doesn't enter treasure rooms, and restore to 1% after meteor falls#{{Trinket" ..
            TrinketType.TRINKET_TELESCOPE_LENS .. "}}Telescope Lens, {{Collectible" ..
            CollectibleType.COLLECTIBLE_MAGIC_8_BALL .. "}}Magic 8 Ball and {{Collectible" ..
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL .. "}}Crystal Ball increases the chance",
        TouhouCharacter = "Megumu Iizunamaru"
    },
    [Collectibles.ExchangeTicket.Item] = {
        Description = "Teleport player to the exchange to trade collectibles#!!! Everything will be refreshed after reentered",
        BookOfVirtues = "Spawned wisps can be used as emeralds",
        TouhouCharacter = "Chimata Tenkyuu"
    },
    [Collectibles.CurseOfCentipede.Item] = {
        Description = "Turns into {{Collectible" .. CollectibleType.COLLECTIBLE_MUTANT_SPIDER ..
            "}}Mutant Spider, {{Collectible" .. CollectibleType.COLLECTIBLE_BELLY_BUTTON ..
            "}}Belly Button, {{Collectible" .. CollectibleType.COLLECTIBLE_POLYDACTYLY .. "}}Polydactyly, {{Collectible" ..
            CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}}Schoolbag, {{Collectible" ..
            CollectibleType.COLLECTIBLE_LUCKY_FOOT ..
            "}}Lucky Foot#If player is Tainted Isaac, will drop items that cannot hold",
        TouhouCharacter = "Momoyo Himemushi"
    },

    [Collectibles.DreamSoul.Item] = {
        Description = "Can only spawn in the treasure room at Basement I while ascent#Remove the door of mom's room, then spawn a cushion to the dream world in Isaac's room.",
        TouhouCharacter = "Doremy Sweet"
    }

}
local EmptyBook= Collectibles.EmptyBook;
EIDInfo.KosuzuDescriptions = {
    Actives = {
        [EmptyBook.Sizes.SMALL] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "x1.25 damage for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "Heals half red heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "Has 50% chance to spawn a coin",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "Deal 20 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "Gain shield for 3 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "Spawn 1 familiar from {{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "Reroll all enemies",
        },
        
        [EmptyBook.Sizes.MEDIUM] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "x1.5 damage for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "Gain half soul heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "Randomly spawn a coin, heart, key or bomb",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "Deal 60 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "Gain shield for 10 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "Spawn 3 familiars from {{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "Reroll current room",
        },
        
        [EmptyBook.Sizes.LARGE] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "x2 damage for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "Gain an eternal heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "Spawn a coin, a heart, a key and a bomb",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "Deal 180 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "Gain shield for 30 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "Spawn 6 familiars from {{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "Reroll all pedestal items in current room",
        },
    },
    Passives = {
        [EmptyBook.PassiveEffects.GOODWILLED] = "When held, +10% chance to transform angel room from devil room",
        [EmptyBook.PassiveEffects.WISE] = "When held, dispel Curse of Unknown, Blind and Lost.",
        [EmptyBook.PassiveEffects.PRECISE] = "When held, get effect of {{Collectible"..CollectibleType.COLLECTIBLE_COMPASS.."}}Compass",
        [EmptyBook.PassiveEffects.MEAN] = "When held, +2 Flat damage",
        [EmptyBook.PassiveEffects.CLEAR] = "When held, +0.15 Speed",
        [EmptyBook.PassiveEffects.SELFLESS] = "When held, charges 1 for active items upon hit", 
        [EmptyBook.PassiveEffects.INNOVATIVE] = "Spawn wisps upon use",
    }
}

EIDInfo.Trinkets = {
    [Trinkets.FrozenFrog.Trinket] = {
        Description = "Freeze any non-Boss enemies Isaac touches",
        TouhouCharacter = "Cirno"
    },
    [Trinkets.AromaticFlower.Trinket] = {
        Description = "Isaac revives after death with hearts of half of heart containers. This disappears.",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {"hearts of half of heart containers", "full red hearts", "full hearts and 2 soul hearts"},
        TouhouCharacter = "Lily White"
    },
    [Trinkets.GlassesOfKnowledge.Trinket] = {
        Description = "For each kind of collectibles Isaac has:#↑ +0.03 Speed#↑ +0.03 Damage #↑ +0.02 Fire Rate#↑ +0.038 Range",
        GoldenInfo = {t={0.03, 0.03, 0.02, 0.038}},
        TouhouCharacter = "Rinnosuke Morichika"
    },
    [Trinkets.CorrodedDoll.Trinket] = {
        Description = "Isaac leaves green creep behind per 7 frames, dealing 20% of his damage per frame, existing for 1 second",
        GoldenInfo = 20,
        TouhouCharacter = "Medicine Melancholy"
    },
    [Trinkets.LionStatue.Trinket] = {
        Description = "Spawn 1 extra angel statue in rooms that contains angel statues",
        GoldenInfo = 1,
        TouhouCharacter = "Aunn Komano"
    },
    [Trinkets.FortuneCatPaw.Trinket] = {
        Description = "Has 25% chance to drop 1 temporary coin after a monster died#Bosses will always drop 3 random temporary coins",
        GoldenInfo = {t={1, 3}},
        TouhouCharacter = "Mike Goutokuji"
    },
    [Trinkets.MermanShell.Trinket] = {
        Name = "Merman Shell",
        Description = "Gain stats in flooded rooms:#↑ +2 Flat Damage#↑ +1 Tears#↑ +0.15 Speed#After a new floor, flood 20% rooms",
        GoldenInfo = {t={20}},
        TouhouCharacter= "Wakasagihime"
    }
}

EIDInfo.Birthrights = {
    [Players.Eika.Type] = {
        Description = "Can stack 20 rocks",
        PlayerName = "Eika"
    },
    [Players.EikaB.Type] = {
        Description = "Blood Boneies regenerate their healths",
        PlayerName = "Tainted Eika"
    },
    [Players.Satori.Type] = {
        Description = "After entered a room, charm 3 random monsters for 5 minutes",
        PlayerName = "Satori"
    },
    [Players.SatoriB.Type] = {
        Description = "↑ Speed + Max speed up#Crush will cause explosion while speed is larger than or equal to 1",
        PlayerName = "Tainted Satori"
    }
}

EIDInfo.LunaticDescs = {
    Collectibles = {
        [Collectibles.DarkRibbon.Item] = "+20% damage instead",
        [Collectibles.DYSSpring.Item] = "Fairies can only heal 1 red heart and 1 soul heart",
        [Collectibles.MaidSuit.Item] = "Can only stop time for 2 seconds",
        [Collectibles.VampireTooth.Item] = "Heart drop rate reduced to 2.5%",
        [Collectibles.Roukanken.Item] = "No longer gain charges when kills enemies",
        [Collectibles.FanOfTheDead.Item] = "Life limit is 20",
        [Collectibles.OneOfNineTails.Item] = "Will no longer spawn more babies if player has reached the limit of 9",
        [Collectibles.Starseeker.Item] = "Choices become 2",
        [Collectibles.BookOfYears.Item] = "Has 30% chance to not spawn item",
        [Collectibles.TenguCamera.Item] = "Freeze 4 seconds instead",
        [Collectibles.RuneSword.Item] = "Ehwaz's effect become chance-based, the chance is (RuneCount * 50%)",
        [Collectibles.Pagota.Item] = "No longer midas enemies",
        [Collectibles.ZombieInfestation.Item] = "Monsters has only 50% chance to spawn friendly clones",
        [Collectibles.D2147483647.Item] = "Needs 2 charges to transform, and excluded {{Collectible" ..
            CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE .. "}} Death Certificate",
        [Collectibles.TheInfamies.Item] = "No longer charms bosses",
        [Collectibles.Hunger.Item] = "Monsters will not drop foods"
    },
    Trinkets = {
        [Trinkets.FortuneCatPaw.Trinket] = "The chance of dropping coins from Boss reduced to 60%",
    }
}
return EIDInfo;
