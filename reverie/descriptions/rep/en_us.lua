------------------------------------------------------------------
-----  Basic English descriptions based on Platinumgod.co.uk -----
------------------------------------------------------------------
-- FORMAT: Item ID | Name| Description
-- '#' = starts new line of text
-- Special character markup:
-- ↑ = Up Arrow   |  ↓ = Down Arrow    | ! = Warning
local Collectibles = THI.Collectibles;
local Trinkets = THI.Trinkets;
local Cards = THI.Cards;
local Players = THI.Players;

local EIDInfo = {};

EIDInfo.Entries = {
    ["Lunatic"] = "{{ColorPurple}}Lunatic Mode{{CR}}: ",
    ["UnknownItem"] = "Unknown Item"
}

EIDInfo.Transformations = {
    ReverieMusician = "Musician"
}
            
EIDInfo.Collectibles = {


    -- TH6
    [Collectibles.YinYangOrb.Item] = {
        Description = "Throw a bouncing Yin-Yang Orb"..
        "#Deals 20 collision damage",
        BookOfVirtues = "Yin-Yang Orb wisps"
    },
    [Collectibles.MarisasBroom.Item] = {
        Description = "Flight"..
        "#For each mushroom item player has:"..
        "#↑  {{Speed}} +0.3 Speed up"..
        "#↑  {{Tears}} +0.5 Tears up"..
        "#↑  {{Damage}} +1 Damage up"
    },
    [Collectibles.DarkRibbon.Item] = {
        Description = "Player has a damaging aura, dealing 10.71 damage every second"..
        "#↑  {{Damage}} +50% Damage up while standing in the aura"
    },
    [Collectibles.DYSSpring.Item] = {
        Description = "{{SoulHeart}} +2 Soul Hearts"..
        "#{{Heart}} Full health"..
        "#{{Battery}} Full charges"..
        "#Has 10% chance to transform any hearts into fairies"..
        "#Fairies will {{Heart}}fully heal player and grant 1 {{SoulHeart}}soul heart"
    },
    [Collectibles.DragonBadge.Item] = {
        Description = "Dash into enemies and punch them"..
        "#Invincible while dashing"..
        "#Release fists and gain more dash time upon hit",
        BookOfVirtues = "Fist tears",
        BookOfBelialReplace = "Deal 3% player damage 1000 times to the enemy when hit"
    },
    [Collectibles.Koakuma.Item] = {
        Description = "Large tear familiar"..
        "#Deals 3 Damage per tear"..
        "#Has synergies with {{Bookworm}} Bookworm and {{Collectible" ..
            Collectibles.Grimoire.Item .. "}} Grimoire of Patchouli"
    },
    [Collectibles.Grimoire.Item] = {
        Description = "Obtain a random tear effect for current floor"..
        "#Effects: Homing, Charm, Burn, Slow, Poison, Magnetize, Rock"..
        "#If all 7 effects are obtained, teleport to the I AM ERROR Room",
        BookOfVirtues = "Elemental / Error wisps"
    },
    [Collectibles.MaidSuit.Item] = {
        Description = "{{Card21}} Spawn XXI-The World"..
        "#Pause all enemies after enters a room"..
        "#{{Card21}} XXI-The World will stop the time and spawn knives"..
        "#{{Card21}} Has chance to spawn XXI-The World after room cleared"
    },
    [Collectibles.VampireTooth.Item] = {
        Description = "↑  {{Damage}}+1 Damage up"..
        "#↑  {{Luck}}+2 Luck up"..
        "#Flight"..
        "#{{Card20}} !!! XIX-The Sun will damage all red hearts"..
        "#{{Card19}} XVIII-The Moon will teleport to {{UltraSecretRoom}} ultra secret"
    },
    [Collectibles.Destruction.Item] = {
        Description = "Spawn a meteor that explodes and cracks into fragments"..
        "#Keep falls meteors at player's position in current room",
        BookOfVirtues = "Burning tears, explodes upon put out"
    },
    [Collectibles.DeletedErhu.Item] = {
        Description = "!!! ONE-TIME USE !!!"..
        "#Remove all enemies and obstacles in current room"..
        "#Removed enemies or obstacles will no longer appear in current game",
        BookOfVirtues = "Glitched wisp",
        BookOfBelial = "↑{{Damage}}+0.2 damage up for each kind of deleted monster and obstacle"
    },


    -- TH7
    [Collectibles.FrozenSakura.Item] = {
        Description = "Player has a damaging aura, dealing 4.3 damage every second"..
        "#{{Slow}} Slows enemies and projectiles in the aura"..
        "#{{Freezing}} Freeze enemies killed by the aura"
    },
    [Collectibles.ChenBaby.Item] = {
        Description = "Familiar that charges forward"..
        "#Deals 3.5 contact damage and fly to the nearest enemy"..
        "#{{Collectible"..Collectibles.OneOfNineTails.Item.."}} One of Nine Tails will Double its damage"
    },
    [Collectibles.ShanghaiDoll.Item] = {
        Description = "Orbital"..
        "#Charge into enemies close to player and deal 3.5 damage"
    },
    [Collectibles.MelancholicViolin.Item] = {
        Description = "Spawn a violin for 10 seconds"..
        "#↑  {{Tears}}+5 Tears up in the range"..
        "#{{Slow}} Slow enemies in the range",
        BookOfVirtues = "Slowing tears",
        BookOfBelial = "Also inflicts weakness",
    },
    [Collectibles.ManiacTrumpet.Item] = {
        Description = "Spawn a trumpet for 10 seconds"..
        "#↑  {{Damage}}+50% Damage up in the range"..
        "#Damage enemies in the range",
        BookOfVirtues = "Confusing tears",
        BookOfBelial = "{{BleedingOut}}Also inflicts bleed out",
    },
    [Collectibles.IllusionaryKeyboard.Item] = {
        Description = "Spawn a keyboard for 10 seconds"..
        "#↑  {{Speed}}+1 Speed up in the range"..
        "#Remove all projectiles in the range",
        BookOfVirtues = "Charming tears",
        BookOfBelial = "Also inflicts petrified",
    },
    [Collectibles.Roukanken.Item] = {
        Description = "Cut enemies by sword in 18 second, deals 5x {{Damage}}player damage per hit and can destroy obstalces"..
        "#Will dash into movement direciton if use again, deals 2x {{Damage}}player damage per hit"..
        "#{{Battery}} Charges active items after kills using dash",
        BookOfVirtues = "Melee wisp that can destory obstacles",
        BookOfBelial = "Bloody edge, increases its range and damage"
    },
    [Collectibles.FanOfTheDead.Item] = {
        Description = "Flight"..
        "#Spectral Tears"..
        "#Transform all {{EmptyHeart}}heart containers or {{SoulHeart}}soul hearts into extra lives"
    },
    [Collectibles.FriedTofu.Item] = {
        Description = "↑  {{Heart}}+1 Health up"..
        "#{{Heart}} Heals 1 red heart",
        BingeEater = "↑  {{Range}}+1.5 Range up"..
        "#↑  {{Luck}}+1 Luck up"..
        "#↓  {{Speed}}-0.03 Speed down"
    },
    [Collectibles.OneOfNineTails.Item] = {
        Description = "Spawn an item from baby shop"..
        "#Spawn items from baby shop after new floor"..
        "#↑  {{Damage}}Damage up for each familiar you have"..
        "#Max damage multiplier is 150% when familiars are 9"..
        "#{{Collectible"..Collectibles.ChenBaby.Item.."}}Chen Baby counts as 3 familiars."
    },
    [Collectibles.Gap.Item] = {
        Description = "Generate teleporter floors which are connected to all rooms"..
        "#Use The Gap on the floors to teleport"..
        "#{{UltraSecretRoom}} Includes ultra secret",
        BookOfVirtues = "Teleporting tears"
    },


    -- Secret Sealing
    [Collectibles.Starseeker.Item] = {
        Description = "Spawn 3 crystal balls after enters a room with collectibles"..
        "#The other two crystal ball will disappear after one is chosen"..
        "#the next collectible in this room type will be replaced by the chosen collectible"..
        "#Choose once for each collectibles in the room"
    },
    [Collectibles.Pathseeker.Item] = {
        Description = "Spawn floors which displays all rooms after new floor"..
        "#{{Collectible"..Collectibles.Gap.Item.."}} Can use The Gap to teleport"
    },


    -- TH7
    [Collectibles.GourdShroom.Item] = {
        Description = "Switch between sparse or dense form when damaged"..
        "#{{ColorOrange}}Dense form:{{CR}}"..
        "#↑  {{Damage}}x1.35 Damage up"..
        "#↑  {{Range}}+5 Range up"..
        "#{{Blank}} x1.5 Size up and can crush rocks"..
        "#{{ColorOrange}}Sparse form{{CR}}"..
        "#↑  {{Tears}}x1.5 Tears up"..
        "#↑  {{Speed}}+0.5 Speed up"..
        "#{{Blank}} x0.75 Size down and spawn 5 minisaacs"
    },


    -- TH8
    [Collectibles.JarOfFireflies.Item] = {
        Description = "Spawn 12 friendly onfire flies"..
        "#Onfire flies will explode upon contact or death, deal damages equals to player's damage"..
        "#{{CurseDarkness}} Clear the Curse of Darkness",
        BookOfVirtues = "3 wisps that spawn Onfire Flies upon put out"
    },
    [Collectibles.SongOfNightbird.Item] = {
        Description = "{{CurseDarkness}} Has Curse of Darkness permanently"..
        "#{{Confusion}} Monsters far away against player get confused, and will take additional 0.5x damage"
    },
    [Collectibles.BookOfYears.Item] = {
        Description = "Remove a random passive collectible item with the lowest quality"..
        "#Spawn a random collectible",
        BookOfVirtues = "Spawn {{Collectible"..CollectibleType.COLLECTIBLE_MISSING_PAGE_2.."}}Missing Page 2 upon put out",
        BookOfBelial = "50% chance to spawn a {{DevilRoom}}devil room item"
    },
    [Collectibles.RabbitTrap.Item] = {
        Description = "↑  {{Luck}}+1 Luck up"..
        "#Spawn traps after enters a room with enemies"..
        "#Traps can instantly kill ground monsters, and deal 45 damage per second to bosses"
    },
    [Collectibles.Illusion.Item] = {
        Description = "Spawn 4 illusions around player"..
        "#Deals contact damage equals to 2.14x player damage per second"..
        "#Shoot blood tears with 3.5 damage"
    },
    [Collectibles.PeerlessElixir.Item] = {
        Description = "For current floor"..
        "#↑  {{Damage}}+0.6 Damage up"..
        "#↑  {{Tears}}+0.6 Tears up"..
        "#↑  {{Speed}}+0.3 Speed up "..
        "#!!! After the fourth use in current floor, player explodes and dies",
        BookOfVirtues = "Powerful green wisps but will explode upon put out"
    },
    [Collectibles.DragonNeckJewel.Item] = {
        Description = "Spawn lightbolts at the nearest enemy per 3 seconds"..
        "#Lightbolts spawn 5 tears with 3.5 damage"
    },
    [Collectibles.BuddhasBowl.Item] = {
        Description = "Prevent next damage when damaged"
    },
    [Collectibles.RobeOfFirerat.Item] = {
        Description = "Spawn a fire orbital"..
        "#Tears pass through fires transform into new fires"..
        "#Immune to fires"
    },
    [Collectibles.SwallowsShell.Item] = {
        Description = "Spawn an {{AngelRoom}}angle room item after new floor"..
        "#Spawn an extra {{SoulHeart}}soul heart for each {{Conjoined}}Conjoined item"..
        "#!!! Disappears when damaged"
    },
    [Collectibles.JeweledBranch.Item] = {
        Description = "Form a tear ring around player"..
        "#When tear count reaches the limit of 5, one of them will fly to the nearest enemies"
    },
    [Collectibles.AshOfPhoenix.Item] = {
        Description = "Player transform into ashes and release fire waves upon death"..
        "#If ash pile doesn't take any damage in 2 seconds, revive player and release fire waves"..
        "#!!! Self-damaging will not trigger this effect"
    },


    -- TH9
    [Collectibles.TenguCamera.Item] = {
        Description = "Display a fanshaped area when held"..
        "#Freeze and deal 5 damage to enemies, remove projectiles in the area after use"..
        "#Spawn bonuses based on the score:"..
        "#{{Blank}} 10: {{Coin}} 12: {{Key}} 16: {{Bomb}}"..
        "#{{Blank}} 22: {{Pill}} 30: {{Card}} 40: {{Trinket}}"..
        "#{{Blank}} 52: {{SoulHeart}} 66: {{Collectible"..CollectibleType.COLLECTIBLE_NEGATIVE.."}}"..
        "#{{Blank}} 82: {{Collectible"..CollectibleType.COLLECTIBLE_TORN_PHOTO.."}} 100: {{Collectible"..CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE.."}}",
        BookOfVirtues = "Turn projectiles into black wisps that cannot shoot",
        BookOfBelial = "{{Burning}}Burn flashed enemies, Gain {{Damage}}damage up decays in 5 seconds, amount based on the score"
    },
    [Collectibles.SunflowerPot.Item] = {
        Description = "Sunflower familiar on player's head"..
        "#After cleared a room, spawn a pickup or collectible"..
        "#!!! Sunflower dies when player is damaged, it explodes and deals 1 heart extra damage to player"..
        "#Revives next floor"..
        "#{{Collectible" ..
            CollectibleType.COLLECTIBLE_BFFS .. "}} BFFs! will make it drop 2 instead"
    },
    [Collectibles.ContinueArcade.Item] = {
        Description = "{{Coin}} +3 Coins"..
        "#After player dies, pay 3 {{Coin}}coins for resurrection with full red hearts in current room"..
        "#!!! Every resurrection triples the cost"
    },
    [Collectibles.RodOfRemorse.Item] = {
        Description = "{{SacrificeRoom}} Take a heart of damage ({{Heart}}Red hearts first), triggers sacrifice room's effect once"..
        "#Sacrifice count is not related to any sacrifice rooms, and will be reset after new floor",
        BookOfVirtues = "Has 25% chance to drop a red heart upon put out",
        BookOfBelial = "{{DevilRoom}} Do the reversed demonic sacrifice instead"
    },

    [Collectibles.IsaacsLastWills.Item] = {
        Description = "!!! ONE-TIME USE !!!"..
        "#Send all collectibles and pickups in the current room to the next run"..
        "#!!! Doesn't work in seeded runs or challenges"..
        "#!!! Has no effect if the mod is disabled, it works again until the mod get enabled",
        BookOfVirtues = "Spawn powerful wisps in the next run",
        BookOfBelial = "↑ Pernamently {{Damage}}+1 damage up next run"
    },
    [Collectibles.SunnyFairy.Item] = {
        Name = "Sunny Fairy",
        Description = "Familiar dormants every floor"..
        "#Awake after enters {{BossRoom}} boss room or use {{Card20}}XIX - The Sun, and spawn 3 {{Heart}}red hearts"..
        "#Shoots 3 burning tears with 4 damage per second after awake"..
        "#If player has all 3 {{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}light fairies, they awake together, and has 3x damage"
    },
    [Collectibles.LunarFairy.Item] = {
        Name = "Lunar Fairy",
        Description = "Familiar dormants every floor"..
        "#Awake after enters {{SecretRoom}}secret, {{SuperSecretRoom}}super secret or {{UltraSecretRoom}}ultra secret room, and spawn 2 {{Bomb}}bombs"..
        "#Shoots 3 bouncing tears with 3 damage per second after awake"..
        "#If player has all 3 {{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}light fairies, they awake together, and damages become 3x"
    },
    [Collectibles.StarFairy.Item] = {
        Name = "Star Fairy",
        Description = "Familiar dormants every floor"..
        "#Awake after enters {{TreasureRoom}}treasure room or {{Planetarium}}planetarium, and spawn 1 {{Key}}key"..
        "#Shoots 3 homing tears with 2 damage per second after awake"..
        "#If player has all 3 {{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}light fairies, they awake together, and damages become 3x"
    },


    --TH10
    [Collectibles.LeafShield.Item] = {
        Description = "Spawn leaf shield per 3 seconds"..
        "#Deals 4 damage per 7 seconds and block any projectiles"..
        "#Press shoot buttons to fire this shield away"
    },
    [Collectibles.BakedSweetPotato.Item] = {
        Description = "↑  {{Heart}}+1 Health up"..
        "#{{Heart}} Heals 1 red heart"..
        "#↑  {{Damage}}+5 Damage up, which scales down over 2 minutes"
    },
    [Collectibles.BrokenAmulet.Item] = {
        Description = "↓  {{Luck}}-3 Luck down"..
        "#Tears have black auras, enemies in the aura take damages 15 times per second"..
        "#The lower luck Isaac has, the aura is larger, and the damage is higher"..
        "#{{Luck}} 20% player damage at 0 luck"..
        "#{{Luck}} 80% player damage at -5 luck"
    },
    [Collectibles.ExtendingArm.Item] = {
        Description = "Shoot a hook to a direction"..
        "#Hit enemies will be frozen and pulled to player"..
        "#After hit an obstacle, pull player to it"..
        "#After hit a pickup, pull the pickup to player"..
        "#Player will be invincible until pulling is over",
        BookOfVirtues = "Spawn temporary green wisps when extending",
        BookOfBelial = "{{Collectible722}}Lock the enemy after pulling it to the player"
    },
    [Collectibles.WolfEye.Item] = {
        Name = "Wolf Eye",
        Description = "↑  {{Damage}}+0.5 Damage up"..
        "#Display all rooms at map's border"..
        "#Increase projectiles' visiblity"
    },
    [Collectibles.Benediction.Item] = {
        Description = "Can be used at any charges"..
        "#Get an {{AngelRoom}}angel room collectible based on the charges until next floor:"..
        "#1: {{Collectible"..CollectibleType.COLLECTIBLE_HALLOWED_GROUND.."}}Hallowed Ground"..
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
        BookOfBelialReplace = "Can be used at any charges"..
        "#Get a {{DevilRoom}}devil room collectible based on the charges until next floor:"..
        "#1: {{Collectible"..CollectibleType.COLLECTIBLE_SHADE.."}}Shade"..
        "#2: {{Collectible"..CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL.."}}Guppy's Hairball"..
        "#3: {{Collectible"..CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER.."}}Sacrificial Dagger".. 
        "#4: {{Collectible"..CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW.."}}Contract from Below"..
        "#5: {{Collectible"..CollectibleType.COLLECTIBLE_SUCCUBUS.."}}Succubus"..
        "#6: {{Collectible"..CollectibleType.COLLECTIBLE_DARK_BUM.."}}Dark Bum"..
        "#7: {{Collectible"..CollectibleType.COLLECTIBLE_DEATHS_TOUCH.."}}Death's Touch"..
        "#8: {{Collectible"..CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID.."}}Maw of the Void"..
        "#9: {{Collectible"..CollectibleType.COLLECTIBLE_INCUBUS.."}}Incubus"..
        "#10: {{Collectible"..CollectibleType.COLLECTIBLE_TWISTED_PAIR.."}}Twisted Pair"..
        "#11: {{Collectible"..CollectibleType.COLLECTIBLE_BRIMSTONE.."}}Brimstone"..
        "#12: {{Collectible"..CollectibleType.COLLECTIBLE_MOMS_KNIFE.."}}Mom's Knife",
    },
    [Collectibles.Onbashira.Item] = {
        Name = "Onbashira",
        Description = "Summon an onbashira from the sky, crush all obstacles and enemies nearby"..
        "#Onbashira will exist for 8 seconds, strike enemies in range by holy lights"..
        "#Each hit of holy light deals 2 damage"..
        "#{{Collectible"..Collectibles.YoungNativeGod.Item.."}} Young Native Gods' damage become tripled in onbashira's range",
        BookOfVirtues = "Wisps has 10% chance to shoot holy light tears"
    },
    [Collectibles.YoungNativeGod.Item] = {
        Name = "Young Native God",
        Description = "Snake familiar that moves underground"..
        "#{{Poison}} Will bite enemies, each bite deals 35 damage, and poison enemies"..
        "#Will crush any rocks on the way, and help player finding tinted rocks and {{LadderRoom}}crawlspaces"
    },


    [Collectibles.GeographicChain.Item] = {
        Name = "Geographic Chain",
        Description = "↑  {{Luck}}+2 Luck up when held"..
        "#Upon use, destroy all rocks, locks, blocks, cobwebs and pillars, fill all pits"..
        "#Kill all invulernable traps or enemies with invincible shell",
        BookOfVirtues = "Rock wisps, shoot rocks"
    },
    [Collectibles.RuneSword.Item] = {
        Description = "Spawn a {{Rune}}rune when picked up"..
        "#Insert holding {{Rune}}rune into this item, transform it into passive effect"..
        "#Give player a {{Rune}}rune instead if not holding",
        BookOfVirtues = "Rune wisps"
    },
    [Collectibles.Escape.Item] = {
        Name = "Escape",
        Description = "↑  {{Speed}}+0.15 Speed up"..
        "#After damaged or broke {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}}Holy Mantle, Gain ↑{{Speed}}+0.15 speed in current room, and opens all doors which are not locked"
    },
    [Collectibles.Keystone.Item] = {
        Name = "Keystone",
        Description = "{{Key}} +3 keys when picked up"..
        "#Upon use, release an earthquake which lasts for 4 seconds, destroying rocks and doors, and fall rocks from the ceiling"..
        "#Deal damage to all ground enemies during earthquake, the value is about 11.4% of their current HP per second",
        BookOfVirtues = "Rock wisps, shoot rocks"
    },
    [Collectibles.AngelsRaiment.Item] = {
        Name = "Angel's Raiment",
        Description = "Flight"..
        "#Trigger {{Collectible"..CollectibleType.COLLECTIBLE_CRACK_THE_SKY.."}}Crack the Sky's effect when damaged"
    },


    
    -- TH11
    [Collectibles.BucketOfWisps.Item] = {
        Name = "Bucket of Wisps",
        Description = "Gains souls each time an enemy dies"..
        "#Cost 8 souls to produce a wisp when used"..
        "#Wisps' hp and tear damage is based on the enemies' max hp",
        BookOfVirtues = "Double produced wisps",
        BookOfBelial = "Spawn Book of Belial's wisp instead, but inherits the wisp's HP"
    },
    [Collectibles.PlagueLord.Item] = {
        Name = "Plague Lord",
        Description = "{{Poison}} Poison nearby enemies"..
        "#{{Poison}} Poisoned enemies leave poison clouds after death"
    },
    [Collectibles.GreenEyedEnvy.Item] = {
        Description = "Reduce all non-final-boss enemies' health to 40% after new room"..
        "#After they die, spawn 2 copies with 20% health"
    },
    [Collectibles.OniHorn.Item] = {
        Name = "Oni Horn",
        Description = "↑  {{Damage}}+1 Damage up"..
        "#Each time player get damaged:"..
        "#First time: Spawn a circle of shockwaves"..
        "#Second time: Spawn 3 circles of shockwaves and explode"..
        "#Third time: Fill the room with shockwaves, and cause a mega explosion"..
        "#After the third time or leaving the room. reset the damage counter"..
        "#!!! Only {{BloodDonationMachine}}Blood Donation Machines, {{Confessional}}Confessionals and {{DemonBeggar}}Beggars don't trigger this effect"
    },
    [Collectibles.PsycheEye.Item] = {
        Name = "Psyche Eye",
        Description = "Eye familiar"..
        "#{{Charm}} Charge for 2.5 seconds to turn enemy monsters nearby friendly, and charms bosses"..
        "#!!! Can only control 5 monsters for each psyche eye"..
        "#Hold "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].." and shooting keys to release mind blast, kill all friendly monsters"
    },
    [Collectibles.GuppysCorpseCart.Item] = {
        Name = "Guppy's Corpse Cart",
        Description = "Flight"..
        "#↑  {{Speed}}+0.2 Speed up"..
        "#When moving at a speed faster than 0.85, crush enemies without taking any contact damage"
    },
    [Collectibles.Technology666.Item] = {
        Description = "Fire an additional yellow brimstone per second, deals 15% player damage"..
        "#If the brimstone kills an enemy, the enemy explodes and bursts 6 new brimstone lasers at the enemy's position"..
        "#The explosion cannot damage players, and bursted brimstone lasers has the same effect"
    },
    [Collectibles.PsychoKnife.Item] = {
        Description = "Execute a nearby enemy"..
        "#Will instantly kill monsters, and deal huge damage which ignores armor to bosses, then shakes enemies away"..
        "#If enemy has low health or some debuffs, the range is doubled",
        BookOfVirtues = "Dark wisps",
        BookOfBelial = "↑{{Damage}}+1 Damage up in 10 seconds after kills by the execution"
    },

    
    --TH12
    [Collectibles.DowsingRods.Item] = {
        Description = "Hide treasures below normal rocks"..
        "#Detect these rocks using radar waves"..
        "#The closer the rock is, the more frequent radar waves are"
    },
    [Collectibles.ScaringUmbrella.Item] = {
        Description = "Block projectiles from above"..
        "#Drop tear rains after shoot in current room"..
        "#{{Fear}} Randomly fear nearby enemies"..
        "#Scare player while he does not have hazards"
    },
    [Collectibles.Unzan.Item] = {
        Name = "Unzan",
        Description = "Summon Unzan for attack helps after entering a room with enemies"..
        "#Spawns giant fist tears at both side of player"..
        "#Fist tear deals (2 * currentFloor) damage"..
        "#Fists impacts at the center of room, deal huge damage to enemies at the center"..
        "#Unzan leaves when the game is cleared"
    },
    [Collectibles.Pagota.Item] = {
        Description = "!!! ONE-TIME USE !!!"..
        "#{{Coin}} Needs coins as charges"..
        "#Turn the whole floor gold, and transform all pickups and poops to golden version"..
        "#Freeze all enemies and midas them for 5 seconds",
        BookOfVirtues = "12 golden wisps, fire midas tears",
        BookOfBelial = "↑ {{Damage}}+12 damage up this floor"
    },
    [Collectibles.SorcerersScroll.Item] = {
        Description = "!!! Remove all {{SoulHeart}}soul hearts (will not kill player)"..
        "#For each half of removed soul hearts:"..
        "#↑  {{Damage}}+0.2 Damage up"..
        "#↑  {{Tears}}+0.2 Tears up"..
        "#↑  {{Speed}}+0.03 Speed up"..
        "#↑  {{Range}}+0.4 Range up",
        BookOfVirtues = "Spell wisps, increase player's all stats"
    },
    [Collectibles.SaucerRemote.Item] = {
        Description = "Spawn a UFO which takes pickup and collectibles away"..
        "#Spawn double bonus after destroyed UFO"..
        "#!!! UFO will run away after 15 seconds",
        BookOfVirtues = "Can cost 3 same color or 3 different colors of UFO wisps to freely use"
    },

    [Collectibles.TenguCellphone.Item] = {
        Description = "Shopping online!"..
        "#There are only three goods at a time, and is different between rooms"..
        "#The goods are determined according to the current room type"..
        "#The purchased goods will be delivered to the next floor"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_STEAM_SALE.."}} Steam Sale will give these goods discounts",
        BookOfVirtues = "Midas tears",
        BookOfBelial = "The first offer costs hearts"
    },
    [Collectibles.EtherealArm.Item] = {
        Name = "Ethereal Arm",
        Description = "!!! Player can no longer pick up pocket items"..
        "#Replace player's pocket item into Void Hand, which can transform a pocket item into random collectibles (from all item pools)"..
        "#Can only be used 3 times every floor"..
        "#Marked skulls always drop {{Collectible"..CollectibleType.COLLECTIBLE_TELEPORT.."}}Teleport!"
    },

    [Collectibles.MountainEar.Item] = {
        Name = "Mountain Ear",
        Description = "11% chance to shoot echo tears, which bounces in the room"..
        "#disappears when hit player, and grant him temporary damage up"..
        "#{{Luck}} 100% chance at 8 Luck"
    },
    [Collectibles.ZombieInfestation.Item] = {
        Description = "When picked up, transform all {{Heart}}red hearts into {{RottenHeart}}rotten hearts"..
        "#When a monster is killed, spawn a new friendly copy of it"..
        "#Copies cannot be brought out room"
    },
    [Collectibles.WarpingHairpin.Item] = {
        Description = "Teleports to the room at the other side of a wall",
        BookOfVirtues = "Weak gold tears",
        BookOfBelial = "↑ Gain {{Damage}}damage up in the room after warp"
    },
    [Collectibles.HolyThunder.Item] = {
        Name = "Holy Thunder",
        Description = "5.88% chance to shoot thunder tears, which fall thunders when hit or land"..
        "#Thunders will create chain lasers between surrounding enemies, dealing 2x tear damage"..
        "#{{Luck}} 50% at 15 Luck"
    },
    [Collectibles.GeomanticDetector.Item] = {
        Name = "Geomantic Detector",
        Description = "↓  {{Luck}}-3 Luck down"..
        "#↑  {{Luck}}+0.05 Luck up for each empty grid in the room"..
        "#↑  {{Luck}}+3 Luck up for each secret room near this room"
    },
    [Collectibles.Lightbombs.Item] = {
        Description = "{{Bomb}} +5 bombs"..
        "#Bombs release 10 light beams at circular directions"
    },
    [Collectibles.D2147483647.Item] = {
        Description = "Can be used at any charges"..
        "#Transform this to any active item with inherited charges"..
        "#After use transformed item, transform it back with remained charges"..
        "#!!! Disappears after use ONE-TIME USE items"..
        "#!!! If transformed into {{Collectible"..Collectibles.D2147483647.Item.."}}D2147483647, Use this will teleport player to I AM ERROR room, this disappears",
        BookOfVirtues = "None"
    },
    [Collectibles.EmptyBook.Item] = {
        Description = "Select effects, and finish this item by yourself"..
        "#!!! The new effects will override all old effects after use Empty Book again",
        BookOfVirtues = "None"
    },
    [Collectibles.TheInfamies.Item] = {
        Description = "Switch forms after room cleared:"..
        "#{{ColorOrange}}Pleasure:{{CR}} ↑{{Speed}}+0.15 Speed up"..
        "#{{ColorOrange}}Anger:{{CR}} ↑{{Damage}}+2 Damage up"..
        "#{{ColorOrange}}Sorrow:{{CR}} ↑{{Tears}}+1 Tears up"..
        "#{{ColorOrange}}Fearness:{{CR}} ↑{{Luck}}+1 Luck up"..
        "#Has a chance to drop pokers after clearing rooms"..
        "#Has synergies with {{Collectible" ..
            CollectibleType.COLLECTIBLE_INFAMY .. "}}Infamy, {{Collectible" .. CollectibleType.COLLECTIBLE_ISAACS_HEART ..
            "}}Isaac's Heart and Mask and Heart enemies"
    },



    --TH14
    [Collectibles.SekibankisHead.Item] = {
        Description = "Orbital"..
        "#Deals 52.5 contact damage per second"..
        "#Fire 2 lasers which deals 1.75 damage per 11 frames"..
        "#Has interactions with {{Collectible"..CollectibleType.COLLECTIBLE_GUILLOTINE.."}}Guillotine, {{Collectible"..CollectibleType.COLLECTIBLE_PINKING_SHEARS.."}}The Pinking Shears, {{Collectible"..CollectibleType.COLLECTIBLE_SCISSORS.."}}Scissors and {{Collectible"..CollectibleType.COLLECTIBLE_DECAP_ATTACK.."}} Decap Attack"
    },
    [Collectibles.WildFury.Item] = {
        Description = "Become furious in 10 seconds, ↑ 1.5x player's {{Speed}}speed, {{Tears}}tears, {{Damage}}damage and {{Range}}range"..
        "#↑ Each enemy killed during fury will give player all stats up"..
        "#!!! The stats up amount is based on the enemy's max HP",
        BookOfVirtues = "The wisp is extermely offensive but extermely fragile"
    },
    [Collectibles.ReverieMusic.Item] = {
        Name="Reverie Music",
        Description = "Appears in the first treasure room after the game playing 5 music"..
        "#Collects music when it plays"..
        "#Opens a secret entrance after defeated Mom's Heart with 15 collected music"
    },
    [Collectibles.DFlip.Item] = {
        Description = "Reroll pedestal collectibles into another one, or reroll back"..
        "#Transform Tarots in current room into reversed version"..
        "#!!! Some collectible pairs are fixed",
        BookOfVirtues = "Destroy all this item's wisps, or spawn 3"
    },
    [Collectibles.MiracleMallet.Item] = {
        Description = "!!! ONE-TIME USE !!!"..
        "#Reroll all collectibles in the room into quality {{Quality4}} collectibles"..
        "#!!! Gain 3 {{BrokenHeart}}broken hearts for each reroll"..
        "#Transform pickups into their BIG version",
        BookOfVirtues = "Midas tears",
        BookOfBelial = "If used in {{DevilRoom}}devil room, {{BlackHeart}}+3 black hearts instead of {{BrokenHeart}}broken hearts"
    },
    [Collectibles.ThunderDrum.Item] = {
        Name = "Thunder Drum",
        Description = "Drum familiar bounces around the room"..
        "#After the drum takes damage, spawn shockwaves and 18 lasers"..
        "#Each laser deals 15 damage"..
        "#{{Player"..PlayerType.PLAYER_THEFORGOTTEN.."}}Can be directly beaten by bone club"
    },
    [Collectibles.NimbleFabric.Item] = {
        Name = "Nimble Fabric",
        Description = "Cost 1 charge to temporarily become invincible"..
        "#Cannot move or shoot while invincible"..
        "#Hold active key to lengthen the duration",
        BookOfVirtues = "Purple wisps"
    },
    [Collectibles.MiracleMalletReplica.Item] = {
        Name = "Miracle Mallet Replica",
        Description = "Hammer to the a direction, deals 80 damage and spawn shockwaves",
        BookOfVirtues = "Hammer wisp, spawn shockwaves after put out"
    },
    [Collectibles.RuneCape.Item] = {
        Name = "Rune Cape",
        Description = "↑  {{Shotspeed}}+0.16 Shot Speed up"..
        "#Drop 3 random runes"
    },
    
    [Collectibles.THTRAINER.Item] = {
        Name = "THTRAINER",
        Description = "Replaces all {{SuperSecretRoom}}super secret rooms to I AM ERROR room"
    },

    --TH15
    [Collectibles.LunaticGun.Item] = {
        Name = "Lunatic Gun",
        Description = "When player holds shooting buttons for 2 seconds, shoot a cone-shaped cluster of tears"..
        "#Each tear is spectral and piercing, dealing 20% of player damage, and has no knockback"
    },
    [Collectibles.ViciousCurse.Item] = {
        Description = "Gain {{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE ..
            "}}Damocles"..
        "#Deal a heart of damage to player"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE .. "}} Double Damocles' update rate"
    },
    [Collectibles.CarnivalHat.Item] = {
        Name = "Carnival Hat",
        Description = "↑ All stats +0.01"..
        "#Spawn a {{Card"..Card.CARD_JOKER.."}}Joker"..
        "#Monsters spawn a troll bomb upon death"..
        "#↑ Gain {{Damage}}+0.1 damage up for each explosion damage taken"
    },
    [Collectibles.PureFury.Item] = {
        Description = "↑  {{Damage}}x1.5 Damage up"
    },
    [Collectibles.Hekate.Item] = {
        Name="Hekate",
        Description = "Three planet orbitals"..
        "#Otherworld orbits player, dealing 105 contact dps"..
        "#Earth orbits otherworld, dealing 75 contact dps"..
        "#Moon orbits Earth, dealing 45 contact dps"
    },


    [Collectibles.DadsShares.Item] = {
        Description = "Spawn a penny after room cleared"..
        "#Lose 5 pennies when damaged"..
        "#!!! Self-damages will not trigger this effect"
    },
    [Collectibles.MomsIOU.Item] = {
        Description = "↓  {{Luck}}-3 Luck"..
        "#Only cost 1 coin in shop"..
        "#Fill player's {{Coin}}coins to the limit"..
        "#Pay 20% coins for debt after floors, with 20% interest"..
        "#!!! Will remove player's {{Collectible}}collectibles, then {{Heart}}hearts if coins are not enough"..
        "#After paid off all debts, IOU disappears"
    },


    --TH16
    [Collectibles.YamanbasChopper.Item] = {
        Name = "Yamanba's Chopper",
        Description = "Has chance to restore {{HalfHeart}}half red heart when enemy killed"..
        "#Has chance to drop {{Coin}}coins when player is damaged"..
        "#These chances are based on player's {{Luck}}Luck"..
        "#{{CurseBlind}}This item can be shown in Curse of Blind"
    },
    [Collectibles.GolemOfIsaac.Item] = {
        Description = "A familiar that will automatically fight enemies"..
        "#Will help you press buttons and open {{SpikedChest}}{{TrapChest}}{{HauntedChest}}trap chests"..
        "#Its {{Damage}}damage and {{Tears}}tears increases with the floor increases"
    },
    [Collectibles.DancerServants.Item] = {
        Name = "Dancer Servants",
        Description = "2 fast orbital babies which shoot tears backwards player's shooting direction"..
        "#Enemies killed by {{ColorGreen}}green{{CR}} servant has 10% chance to drop a {{SoulHeart}}soul heart"..
        "#Enemies killed by {{ColorPink}}magenta{{CR}} servant has 20% chance to drop a {{Heart}}red heart"
    },
    [Collectibles.BackDoor.Item] = {
        Name = "Back Door",
        Description = "A door familiar behind player"..
        "#Can block projectiles"..
        "#Deals 52.5 contact damage per second"
    },


    --TH16
    [Collectibles.FetusBlood.Item] = {
        Name = "Fetus Blood",
        Description = "Spawn a friendly blood bony fighting for you"..
        "#Count limit equals to current floor",
        BookOfVirtues = "Flesh wisps",
        BookOfBelial = "Spawn Devil Bonies"
    },
    [Collectibles.CockcrowWings.Item] = {
        Name = "Cockcrow Wings",
        Description = "Flight"..
        "#Cycle dawn, day, dusk and night based on game timer:"..
        "#{{Collectible589}} {{ColorPurple}}Dawn (0:00-0:30): {{CR}}"..
        "#{{Blank}} ↑{{Tears}}+0.5 tears up"..
        "#{{Collectible588}} {{ColorOrange}}Day (0:30-2:00): {{CR}}"..
        "#{{Blank}} ↑{{Damage}}+1 damage up"..
        "#{{Blank}} ↓{{Tears}}-0.5 tears down"..
        "#{{Collectible588}} {{ColorOrange}}Dusk (2:00-2:30): {{CR}}"..
        "#{{Blank}} ↑{{Damage}}+0.5 damage up"..
        "#{{Collectible589}} {{ColorPurple}}Night (2:30-4:00): {{CR}}"..
        "#{{Blank}} ↑{{Tears}}+1 tears up"..
        "#{{Blank}} ↓{{Damage}}-0.5 damage down"..
        "#{{Blank}} "..
        "#{{Collectible588}} Dispel {{CurseDarkness}}, show {{BossRoom}}"..
        "#{{Collectible589}} Gain {{CurseDarkness}}, show {{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}",
    },
    [Collectibles.KiketsuBlackmail.Item] = {
        Name = "Kiketsu Family's Blackmail",
        Description = "{{Fear}} Fear nearby enemies"..
        "#{{Charm}} Charm enemies farther"
    },
    [Collectibles.CarvingTools.Item] = {
        Name = "Carving Tools",
        Description = "Spawn haniwa soldiers when destroys rocks"..
        "#Difference rocks will spawn different haniwas"
    },
    [Collectibles.BrutalHorseshoe.Item] = {
        Name = "Brutal Horseshoe",
        Description = "Hold opposite move keys or press {{ButtonLStick}}left stick on gamepad to charge up"..
        "#After charged for at least 1 seconds, dash to moving direction"..
        "#Invincible during dash"..
        "#Cause explosions after hit obstacles, and spawn 4 crackwaves"..
        "#Deal damages to hit enemies and kick them off"
    },


    --TH17.5
    [Collectibles.Hunger.Item] = {
        Description = "Apply the Hunger system"..
        "#Player loses Hunger while moving"..
        "#Get healed if Hunger is larger than 9"..
        "#Gain stats up if Hunger is larger than 8"..
        "#Stats down and swallow trinkets if Hunger is less than 3"..
        "#Take damages if Hunger is empty"..
        "#Monsters drop food pickups"
    },
    [Collectibles.SakeOfForgotten.Item] = {
        Name="Sake of Forgotten",
        Description = "Spawn a sake bottle after defeat the boss, restart current floor after touched it"..
        "#!!! New floor has {{CurseMaze}}Curse of Maze, {{CurseLabyrinth}}Labyrinth and {{CurseLost}}Lost, and player become {{Player"..PlayerType.PLAYER_THELOST.."}}The Lost for entire floor"..
        "#!!! Can only spawn sake bottle in odd floors or chapters that haven't second floor"..
        "#!!! Will not spawn another sake bottle in new floor"
    },

    [Collectibles.GamblingD6.Item] = {
        Name = "Gambling D6",
        Description = "Choose greater or less ID, then reroll all pedestal items in the room"..
        "#If you failed to guess that the rerolled item's ID is greater or less than the original, the rerolled item disappears",
        BookOfVirtues = "Consumes a wisp instead of the item disappears after guessing wrong"
    },
    [Collectibles.YamawarosCrate.Item] = {
        Description = "Provides slots for storing collectibles and trinkets"..
        "#Can reduce items into pickups"..
        "#Can be expanded by {{Collectible"..CollectibleType.COLLECTIBLE_CAR_BATTERY.."}}Car Battery, {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES.."}}Book of Virtues and Judas' {{Collectible"..CollectibleType.COLLECTIBLE_BIRTHRIGHT.."}}Birthright",
        BookOfVirtues = "+2 Slots"..
        "#can teleport to the start room using the blue scroll",
        BookOfBelial = "+2 Slots"..
        "#Can use the red scroll to reroll collectibles in the room. Can only be used once each room"
    },
    [Collectibles.DelusionPipe.Item] = {
        Name = "Delusion Pipe",
        Description = "↑  {{Luck}}+10 Luck up which decays in 30 seconds"..
        "#Seeing double on screen"..
        "#Effect can be stacked",
        BookOfVirtues = "Whirl wisps, their hp is based on player's luck up",
        BookOfBelial = "Gain an additional extra damage for the rest of the floor based on the current amount of uses"
    },
    [Collectibles.SoulMagatama.Item] = {
        Name = "Soul Magatama",
        Description = "Fire a magatama which swap {{Heart}}red hearts of player and hp of hit enemy"..
        "#Life swapping is based on their percentages"..
        "#!!! Cannot reduce bosses' hp below 25%"..
        "#if player has no heart containers, transform monsters into error keepers, or reduce bosses' hp into 25%",
        BookOfVirtues = "Lifestealing wisps",
        BookOfBelial = "Fires dark magatama, drain 50% extra health from the enemy after hit"
    },
    [Collectibles.FoxInTube.Item] = {
        Description = "Provides helps in some situations"..
        "#!!! If you accepts her helps, you will pay for this at sometime"..
        "#Glass bottles spawn by her can be broken by tears"
    },
    [Collectibles.DaitenguTelescope.Item] = {
        Description = "Has a chance to fall a meteor in a random room after new floor, spawning a {{Planetarium}}planetarium item"..
        "#The chance increases if player doesn't enter {{TreasureRoom}}treasure rooms, and restore to 1% after meteor falls"..
        "#{{Trinket" ..
            TrinketType.TRINKET_TELESCOPE_LENS .. "}}Telescope Lens, {{Collectible" ..
            CollectibleType.COLLECTIBLE_MAGIC_8_BALL .. "}}Magic 8 Ball and {{Collectible" ..
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL .. "}}Crystal Ball increases the chance"
    },
    [Collectibles.ExchangeTicket.Item] = {
        Description = "Teleport player to the exchange to trade collectibles"..
        "#!!! Everything will be refreshed after reentered",
        BookOfVirtues = "Spawned wisps can be used as emeralds",
        BookOfBelial = "Includes a {{DevilRoom}}devil deal"
    },
    [Collectibles.CurseOfCentipede.Item] = {
        Description = "Turns into {{Collectible" .. CollectibleType.COLLECTIBLE_MUTANT_SPIDER ..
            "}}Mutant Spider, {{Collectible" .. CollectibleType.COLLECTIBLE_BELLY_BUTTON ..
            "}}Belly Button, {{Collectible" .. CollectibleType.COLLECTIBLE_POLYDACTYLY .. "}}Polydactyly, {{Collectible" ..
            CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}}Schoolbag, {{Collectible" ..
            CollectibleType.COLLECTIBLE_LUCKY_FOOT ..
            "}}Lucky Foot"..
            "#{{Player"..PlayerType.PLAYER_ISAAC_B.."}} Will drop items that cannot hold as Tainted Isaac"
    },
    [Collectibles.RebelMechaCaller.Item] = {
        Description = "Summon a mecha from above, crush all enemies nearby"..
        "#Touch the mecha to drive it, providing 3 times of defense"..
        "#Press "..EID.ButtonToIconMap[ButtonAction.ACTION_ITEM].."to toggle jet mode"..
        "#Press "..EID.ButtonToIconMap[ButtonAction.ACTION_BOMB].."to fire bombs"..
        "#Press "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."to leave mecha"..
        "#Press "..EID.ButtonToIconMap[ButtonAction.ACTION_PILLCARD].."to self destruct",
        BookOfVirtues = "Brown Heart wisp, can consume this instead of HP loss after the mecha being hit"
    },
    [Collectibles.DSiphon.Item] = {
        Name="D Siphon",
        Description = "Reroll all pedestal items in the room to {{ColorRed}}-1{{CR}} quality items"..
        "#This dice gets {{ColorGreen}}+1{{CR}} counter for each rerolled item"..
        "#Reverse the operation when its counter reaches 4",
        BookOfVirtues = "Black Wisp with high HP, loses HP for each use"
    },

    [Collectibles.DreamSoul.Item] = {
        Description = "Can only spawn in the {{TreasureRoom}}treasure room at Basement I while ascent"..
        "#Remove the door of mom's room, then spawn a cushion to the dream world in Isaac's room."
    },

    
    [Collectibles.ParasiticMushroom.Item] = {
        Name = "Parasitic Mushroom",
        Description = "↓ -0.1 {{Speed}}speed down"..
        "#↑ +0.5 {{Tears}}tears up"..
        "#↑ +0.5 {{Damage}}damage up"..
        "#↑ +1.5 {{Range}}range up"..
        "#Heals {{Heart}}{{Heart}}2 hearts"..
        "#!!! Chance to replace collectibles from item pools into {{Collectible"..Collectibles.ParasiticMushroom.Item.."}}Parasitic Mushroom"..
        "#!!! Lose {{Heart}}1 heart container after remove this item"
    },
    --TH6 ALT
    [Collectibles.FairyDust.Item] = {
        Description = "↑ {{Luck}} +1 Luck up"..
        "#Flight while holding 3 Fairy Dusts"..
        "#Enemies have chance to drop fairy dusts"..
        "#10% at 10 {{Luck}}Luck"..
        "#!!! No longer drops when all players have 3 Fairy Dusts"
    },
    [Collectibles.SpiritCannon.Item] = {
        Name = "Spirit Cannon",
        Description = "When used:"..
        "#{{BrokenHeart}} +1 Broken Heart"..
        "#{{Collectible118}} Fire a rainbow giant brimstone laser in current room, which lasts for 5 seconds"..
        "#Deals 150x{{Damage}}player damage per second",
        BookOfVirtues = "Star wisp fires short rainbow laser while shooting"
    },
    [Collectibles.DaggerOfServants.Item] = {
        Name = "Dagger of Servants",
        Description = "After 4 entering new rooms, removes player's rightmost heart, ↑+0.6{{Damage}}damage up"..
        "#{{BrokenHeart}} Can remove broken hearts"..
        "#!!! Not lethal"
    },
    [Collectibles.Asthma.Item] = {
        Name = "Asthma",
        Description = "40% to change {{Heart}}heart pickup into random {{Card}}card/{{Rune}}rune"..
        "#20% to change it into lucky penny"..
        "#!!! Hearts spawned by cards/items will not be changed"
    },
    [Collectibles.ByteString.Item] = {
        Name = "Byte String",
        Description = "Upon picked up: "..
        "#{{Coin}} +999 Coins"..
        "#{{Bomb}} +999 Bombs"..
        "#{{Key}} +999 Keys"..
        "#{{Battery}} +999 Charges"..
        "#{{SoulHeart}} +999 Soul charges"..
        "#{{Heart}} +999 Blood charges"..
        "#{{Collectible"..Collectibles.FanOfTheDead.Item.."}} +999 Fan of the Dead lives"..
        "#{{Timer}} Time becomes 99:59:59"
    },
    [Collectibles.Dejavu.Item] = {
        Name = "Deja vu",
        Description = "Chance to spawn a corpse with 3 random items after entering room"..
        "#!!! You can only take 1 of the item group, and can only spawn up to 3 groups per run"..
        "#!!! Player's recorded dead runs will also appear"
    },
    [Collectibles.Jealousy.Item] = {
        Name = "Jealousy",
        Description = "↑  {{Damage}}+1 damage up"..
        "#↓  {{Damage}} Damage * 95%"..
        "#Whenever player takes penalty damage, gain a new {{Collectible"..Collectibles.Jealousy.Item.."}}Jealousy"
    },
    [Collectibles.EyeOfChimera.Item] = {
        Name = "Eye of Chimera",
        Description = "Reroll all pedestal items in the room upon use"..
        "#Has {{CurseBlind}}Curse of Blind while holding"..
        "#You can see unknown item's qualities, charges and tags",
        BookOfVirtues = "Fires poison tears"
    },
    [Collectibles.MimicTear.Item] = {
        Name = "Mimic Tear",
        Description = "Whenever you picks up an other passive collectible, gain an extra clone of it"
    },
    [Collectibles.CursedBlood.Item] = {
        Name = "Cursed Blood",
        Description = "Gains 3{{Coin}}coins after room cleared"..
        "#!!! Instantly dies after taking fire or explosion damage"..
        "#{{Collectible260}} Black Candle will remove the instantly death effect",
    },
    [Collectibles.RainbowCard.Item] = {
        Name = "Rainbow Card",
        Description = "!!! ONE-TIME USAGE!!!"..
        "#Upon use: "..
        "#!!! Lose all collectibles"..
        "#{{Shop}}Shop items, {{DevilRoom}}devil deals and {{Collectible"..Collectibles.ExchangeTicket.Item.."}}exchange trades next level are free",
        BookOfVirtues = "Spawn a wisp for each lost item",
        BookOfBelial = " ↑ +0.3 {{Damage}}damage up for each lost item"
    },
}
local EmptyBook= Collectibles.EmptyBook;
EIDInfo.KosuzuDescriptions = {
    Default = "No Effect",
    Actives = {
        [EmptyBook.Sizes.SMALL] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}x1.25 damage up for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "{{HalfHeart}} Heals half red heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "{{Coin}} Has 50% chance to spawn a coin",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} Deal 20 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} Gain shield for 3 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} Spawn 1 familiar from Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible285}} Reroll all enemies",
        },
        
        [EmptyBook.Sizes.MEDIUM] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}x1.5 damage up for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "{{HalfSoulHeart}} Gain half soul heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "Randomly spawn a {{Coin}}coin, {{Heart}}heart, {{Key}}key or {{Bomb}}bomb",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} Deal 60 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} Gain shield for 10 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} Spawn 3 familiars from Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible437}} Reroll current room",
        },
        
        [EmptyBook.Sizes.LARGE] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}x2 damage up for current room",
            [EmptyBook.ActiveEffects.PRAYING] = "{{EternalHeart}} Gain an eternal heart",
            [EmptyBook.ActiveEffects.COLLECTION] = "Spawn a {{Coin}}coin, a {{Heart}}heart, a {{Key}}key and a {{Bomb}}bomb",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} Deal 180 damage to all enemies",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} Gain shield for 30 seconds",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} Spawn 6 familiars from {{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}Cambion Conception for current room", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible105}} Reroll all pedestal items in current room",
        },
    },
    Passives = {
        [EmptyBook.PassiveEffects.GOODWILLED] = "When held, +10% {{AngelChance}}angel room chance",
        [EmptyBook.PassiveEffects.WISE] = "When held, dispel {{CurseUnknown}}Curse of Unknown, {{CurseBlind}}Blind and {{CurseLost}}Lost.",
        [EmptyBook.PassiveEffects.PRECISE] = "{{Collectible"..CollectibleType.COLLECTIBLE_COMPASS.."}} When held, get effect of Compass",
        [EmptyBook.PassiveEffects.MEAN] = "{{Trinket35}} ↑When held, {{Damage}}+2 Flat damage up",
        [EmptyBook.PassiveEffects.CLEAR] = "{{Trinket37}} ↑When held, {{Speed}}+0.15 Speed up",
        [EmptyBook.PassiveEffects.SELFLESS] = "{{Collectible156}} When held, charges 1 for active items upon hit", 
        [EmptyBook.PassiveEffects.INNOVATIVE] = "{{Collectible584}} Spawn wisps upon use",
    }
}

EIDInfo.Trinkets = {
    [Trinkets.FrozenFrog.Trinket] = {
        Description = "{{Freezing}} Freeze any non-Boss enemies player touches"
    },
    [Trinkets.AromaticFlower.Trinket] = {
        Description = "Player revives after death with {{Heart}}hearts of half of heart containers. This disappears.",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {"{{Heart}}hearts of half of heart containers", "{{Heart}}full red hearts", "{{Heart}}full hearts and 2 {{SoulHeart}}soul hearts"}
    },
    [Trinkets.GlassesOfKnowledge.Trinket] = {
        Description = "For each collectible player has:"..
        "#↑  {{Speed}}+0.03 Speed up"..
        "#↑  {{Damage}}+0.03 Damage up"..
        "#↑  {{Tears}}+0.02 Tears up"..
        "#↑  {{Range}}+0.038 Range up",
        GoldenInfo = {t={0.03, 0.03, 0.02, 0.038}}
    },
    [Trinkets.HowToReadABook.Trinket] = {
        Description = "Increase chance for book collectibles"
    },
    [Trinkets.CorrodedDoll.Trinket] = {
        Description = "Player leaves green creep behind per 7 frames, dealing 20% of player damage per frame, existing for 1 second",
        GoldenInfo = 20
    },
    [Trinkets.GhostAnchor.Trinket] = {
        Name = "Ghost Anchor",
        Description = "↑  {{Speed}}+0.3 Speed up"..
        "#Player's movement has no inertia, and will move strictly towards the input"..
        "#Player is no longer affected by water currents",
        GoldenInfo = nil
    },
    [Trinkets.MermanShell.Trinket] = {
        Name = "Merman Shell",
        Description = "Gain stats in flooded rooms:"..
        "#↑  {{Damage}}+2 Flat Damage up"..
        "#↑  {{Tears}}+1 Tears up"..
        "#↑  {{Speed}}+0.15 Speed up"..
        "#After a new floor, flood 20% rooms",
        GoldenInfo = {t={20}}
    },
    [Trinkets.Dangos.Trinket] = {
        Name = "Dangos",
        Description = "No effects when holding"..
        "#Gain these stats when gulped:"..
        "#↑ +0.5 tears"..
        "#↑ +1 damage"..
        "#↑ +1.5 range"..
        "#↑ +0.2 shot speed"..
        "#↑ +1 luck",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "{{ColorGold}}Gain these stats{{CR}} when holding:"..
            "#↑ +0.5 tears"..
            "#↑ +1 damage"..
            "#↑ +1.5 range"..
            "#↑ +0.2 shot speed"..
            "#↑ +1 luck"..
            "#Gain again when gulped",

            "{{ColorGold}}Gain these stats{{CR}} when holding:"..
            "#↑ +0.5 tears"..
            "#↑ +1 damage"..
            "#↑ +1.5 range"..
            "#↑ +0.2 shot speed"..
            "#↑ +1 luck"..
            "#Gain again when gulped",

            "{{ColorGold}}Gain these stats twice{{CR}} when holding:"..
            "#↑ +0.5 tears"..
            "#↑ +1 damage"..
            "#↑ +1.5 range"..
            "#↑ +0.2 shot speed"..
            "#↑ +1 luck"..
            "#Gain again when gulped",
        }
    },
    [Trinkets.ButterflyWings.Trinket] = {
        Name = "Butterfly Wings",
        Description = "After player clear a room, gain flight"..
        "#After player clear the second room, lose flight",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "{{ColorGold}}Flight", 
            "{{ColorGold}}Flight", 
            "{{ColorGold}}Flight"
        }
    },
    [Trinkets.LionStatue.Trinket] = {
        Description = "Spawn 1 extra angel statue in rooms that contains angel statues",
        GoldenInfo = 1
    },
    [Trinkets.BundledStatue.Trinket] = {
        Name = "Bundled Statue",
        Description = "↓  {{Speed}}-0.15 Speed down"..
        "#All enemy projectiles fall faster",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {
            "faster",
            "faster",
            "faster"
        }
    },
    [Trinkets.ShieldOfLoyalty.Trinket] = {
        Name = "Shield of Loyalty",
        Description = "All familiars can block enemy projectiles"..
        "#Blue flies and spiders will be killed after blocking"
    },
    [Trinkets.SwordOfLoyalty.Trinket] = {
        Name = "Sword of Loyalty",
        Description = "All familiars can deal 15 additional contact damage per second"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} 30 damage when has BFFs! .",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "All familiars can deal {{ColorGold}}30{{ColorText}} additional contact damage per second"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} {{ColorGold}}60{{ColorText}} damage when has BFFs! .",
            "All familiars can deal {{ColorGold}}30{{ColorText}} additional contact damage per 7 frames"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} {{ColorGold}}60{{ColorText}} damage when has BFFs! .",
            "All familiars can deal {{ColorGold}}45{{ColorText}} additional contact damage per 7 frames"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} {{ColorGold}}90{{ColorText}} damage when has BFFs! ."
        }
    },
    [Trinkets.FortuneCatPaw.Trinket] = {
        Description = "Has 25% chance to drop 1 temporary {{Coin}}coin after a monster died"..
        "#Bosses will always drop 3 random temporary {{Coin}}coins",
        GoldenInfo = {t={1, 3}}
    },
    [Trinkets.Snowflake.Trinket] = {
        Name = "Snowflake",
        Description = "When player trying to pick up an item that they already has, reroll it instead",
    },
    [Trinkets.HeartSticker.Trinket] = {
        Name = "Heart Sticker",
        Description = "Whenever player uses a card, spawn 1 {{Heart}}red heart",
        GoldenInfo = {t={1}}
    },
    [Trinkets.SymmetryOCD.Trinket] = {
        Name = "Symmetry OCD",
        Description = "Has priority to spawn collectibles which icon's outline is horizontal symmetrical or nearly symmetrical",
    },
}


EIDInfo.RuneSword = {
    [Card.RUNE_ANSUZ] = "Displays all rooms within the Manhattan distance of {DISTANCE}",
    [Card.RUNE_DAGAZ] = "No curses#Gain 2 soul hearts",
    [Card.RUNE_HAGALAZ] = "Tears have {CHANCE}% chance to turn into Rocks",
    [Card.RUNE_PERTHRO] = "Reroll pedestal items by hitting with bombs#{CHANCE}% chance to disappear",
    [Card.RUNE_EHWAZ] = "Spawn a trapdoor to the crawlspace after defeating the boss",
    [Card.RUNE_BERKANO] = "Spawn {COUNT} blue flies and blue spiders after room cleared",
    [Card.RUNE_ALGIZ] = "{CHANCE}% chance to trigger {{Collectible58}}Book of shadows upon hit",
    [Card.RUNE_JERA] = "{CHANCE}% chance to duplicate pickups after new room#Chance over 100% will be converted to new pickups",
    [Card.RUNE_BLACK] = "↑ All Stats up",
    [Card.RUNE_BLANK] = "Insert a random basic rune instead",
    [Card.RUNE_SHARD] = "Insert a random basic rune instead",
    [Card.CARD_SOUL_ISAAC] = "{CHANCE}% chance to trigger this rune's effect after new room#Chance over 100% will be converted to new times",
    [Card.CARD_SOUL_MAGDALENE] = "Trigger this rune's effect after entering room with enemies",
    [Card.CARD_SOUL_CAIN] = "{CHANCE}% chance to trigger this rune's effect after room cleared#The chance will stack if not triggered",
    [Card.CARD_SOUL_JUDAS] = "Trigger this rune's effect before hit by enemies or bullets#Can trigger {COUNT} times for each room",
    [Card.CARD_SOUL_BLUEBABY] = "Spawn a butt bomb after hold the shooting keys for 3 seconds",
    [Card.CARD_SOUL_EVE] = "Spawn {COUNT} dead birds upon hit",
    [Card.CARD_SOUL_SAMSON] = "Trigger this rune's effect after dealing or taking {DAMAGE} damage",
    [Card.CARD_SOUL_AZAZEL] = "Trigger this rune's effect after clearing 4 rooms and entering a new room",
    [Card.CARD_SOUL_LAZARUS] = "Cost this rune to revive after death",
    [Card.CARD_SOUL_EDEN] = "Spawn a random item when inserted",
    [Card.CARD_SOUL_LOST] = "Use {{Card"..Card.CARD_HOLY.."}}Holy Card when inserted#{CHANCE}% chance to use{{Card"..Card.CARD_HOLY.."}}Holy Card after new room",
    [Card.CARD_SOUL_LILITH] = "Trigger this rune's effect after defeating the boss",
    [Card.CARD_SOUL_KEEPER] = "{CHANCE}% to drop random temporary coins after enemy dies#Chance over 100% will be converted to new coins",
    [Card.CARD_SOUL_APOLLYON] = "Spawn {COUNT} random locusts after room cleared",
    [Card.CARD_SOUL_FORGOTTEN] = "{CHANCE}% chance to spawn a bone heart when hit",
    [Card.CARD_SOUL_BETHANY] = "Spawn {COUNT} wisp(s) after room cleared",
    [Card.CARD_SOUL_JACOB] = "Spawn {{Collectible619}}Birthright when inserted",
    [Cards.SoulOfEika.ID] = "{CHANCE}% chance to spawn a friendly blood bony after enemy dies",
    [Cards.SoulOfSatori.ID] = "{CHANCE}% chance to turn tears into mind control tears",
    [Cards.SoulOfSeija.ID] = "Get {{Player"..Players.Seija.Type.."}}Seija's passive effect"..
    "#Inserting {{Card"..Cards.SoulOfSeija.ReversedID.."}}another Soul of Seija will not nerf high quality items",
    [Cards.SoulOfSeija.ReversedID] = "Get {{Player"..Players.Seija.Type.."}}Seija's passive effect"..
    "#Inserting {{Card"..Cards.SoulOfSeija.ID.."}}another Soul of Seija will not nerf high quality items",
}


EIDInfo.Cards = {
    [Isaac.GetCardIdByName ("VoidHandThree")] = {
        Name = "Void Hand",
        Type = "CARD",
        Description = "Transform all pocket items on floor into pedestal items",
    },
    [Isaac.GetCardIdByName ("VoidHandTwo")] = {
        Name = "Void Hand",
        Type = "CARD",
        Description = "Transform all pocket items on floor into pedestal items",
    },
    [Isaac.GetCardIdByName ("VoidHandOne")] = {
        Name = "Void Hand",
        Type = "CARD",
        Description = "Transform all pocket items on floor into pedestal items",
    },
    [Cards.SoulOfEika.ID] = {
        Name = "Soul of Eika",
        Type = "SOUL",
        Description = "Spawn 3 friendly blood bonies"..
        "#Transform all hearts in the room into their friendly bonies",
    },
    [Cards.SoulOfSatori.ID] = {
        Name = "Soul of Satori",
        Type = "SOUL",
        Description = "{{Charm}} Mindcontrol all monsters, and charm all bosses in the room",
    },
    [Cards.SoulOfSeija.ID] = {
        Name = "Soul of Seija",
        Type = "SOUL",
        Description = "Use {{Collectible"..Collectibles.DFlip.Item.."}}D Flip"..
        "#Give player another {{Card"..THI.Cards.SoulOfSeija.ReversedID.."}}Soul of Seija",
    },
    [Cards.SoulOfSeija.ReversedID] = {
        Name = "Soul of Seija",
        Type = "SOUL",
        Description = "Use {{Collectible"..Collectibles.DFlip.Item.."}}D Flip",
    },
    [Cards.ASmallStone.ID] = {
        Name = "A Small Stone",
        Type = "CARD",
        Description = "Fire a rock tear to the shooting direction"..
        "#Has only 1 damage, pernamently adds 1 damage every use"..
        "#Spawn {{Card"..Cards.ASmallStone.ID.."}}A Small Stone",
    },
    [Cards.SpiritMirror.ID] = {
        Name = "Spirit Mirror",
        Type = "CARD",
        Description = "Spawn a friendly copy for each enemies in the room",
    },
    [Cards.SituationTwist.ID] = {
        Name = "Situation Twist",
        Type = "CARD",
        Description = "Reroll all pedestal items in the room"..
        "#The rerolled items will replace future items from item pools",
    },
}

EIDInfo.Pills = {
    [THI.Pills.PillOfUltramarineOrb.ID] = {
        Name = "Pill of Ultramarine Orb",
        Type = "PILL",
        Description = "Use {{Collectible"..CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS.."}}Glowing Hour Glass after hit in current room, this pill disappears"..
        "#Will not consume horse pill",
    }
}
EIDInfo.Tags = {
    [0] = "{{Reverie_TagDead}} Dead thing, used for unlock {{Collectible104}}Parasite",
    [1] = "{{Reverie_TagSyringe}} Spun Transformation",
    [2] = "{{Reverie_TagMom}} Yes Mother Transformation",
    [3] = "{{Reverie_TagTech}} Tech item, used for unlock {{Collectible524}}Technology Zero",
    [4] = "{{Reverie_TagBattery}} Battery item, used for unlock {{Collectible520}}Jumper Cables",
    [5] = "{{Reverie_TagGuppy}} Guppy Transformation",
    [6] = "{{Reverie_TagFly}} Beelzebub Transformation",
    [7] = "{{Reverie_TagBob}} Bob Transformation",
    [8] = "{{Reverie_TagMom}} Fun Guy Transformation",
    [9] = "{{Reverie_TagBaby}} Conjoined Transformation",
    [10] = "{{Reverie_TagAngel}} Seraphim Transformation",
    [11] = "{{Reverie_TagDevil}} Leviathan Transformation",
    [12] = "{{Reverie_TagPoop}} Oh Crap Transformation",
    [13] = "{{Reverie_TagBook}} Bookworm Transformation",
    [14] = "{{Reverie_TagSpider}} Spider Baby Transformation",
    [15] = "{{Reverie_TagQuest}} Quest item",
    [16] = "{{Reverie_TagMonsterManual}} Can be summoned by {{Collectible123}}Monster Manual",
    [17] = "{{Reverie_TagNoGreed}} Won't appear in Greed Mode",
    [18] = "{{Reverie_TagFood}} Food item, can be spawned by {{Collectible664}}Binge Eater",
    [19] = "{{Reverie_TagTearsUp}} Tears up, used for unlock {{Collectible532}}Lachryphagy",
    [20] = "{{Reverie_TagOffensive}} Can be found by{{Player31}}Tainted Lost",
    [21] = "{{Reverie_TagNoKeeper}} {{Player14}}Keeper and {{Player33}}Tainted Keeper won't find this",
    [22] = "{{Reverie_TagNoLostBr}} {{Player10}}The Lost won't find this with{{Collectible619}}Birthright",
    [23] = "{{Reverie_TagStars}} Star-related item, used for unlock {{Planetarium}}Planetarium",
    [24] = "{{Reverie_TagSummonable}} Can be summoned by{{Collectible712}}Lemegeton, or be mimiced by{{Trinket166}}Modeling Clay",
    [25] = "{{Reverie_TagNoCantrip}} Won't appear in challenge \"Cantripped!\"",
    [26] = "{{Reverie_TagWisp}} Has attached {{Collectible584}}Book of Virtues wisp",
    [27] = "{{Reverie_TagUniqueFamiliar}} Unique familiar which cannot be duplicated by {{Collectible357}}Box of Friends or{{Card92}} Soul of Lilith",
    [28] = "{{Reverie_TagNoChallenge}} Won't appear in challenges",
    [29] = "{{Reverie_TagNoDaily}} Won't appear in Daily Runs",
    [30] = "{{Reverie_TagLazShared}} {{Player29}}Tainted Lazarus' two forms share the effect",
    [31] = "{{Reverie_TagLazSharedGlobal}} {{Player29}}Tainted Lazarus' two forms share the {{ColorYellow}}global{{CR}} effect",
    [32] = "{{Reverie_TagNoEden}} {{Player9}}Eden will not start with this item"
}

EIDInfo.Characters = {
    [THI.Players.Eika.Type] = {
        Name = "Eika",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Eika",
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- Mom's Bracelet"},
                {str = "- Shiny Rock"},
                {str = "Stats:"},
                {str = "- HP: 2 Red Hearts"},
                {str = "- Extra: 1 Bomb"},
                {str = "- Speed: 0.85"},
                {str = "- Tear Rate: 2.73"},
                {str = "- Damage: 4.38"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 1.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "Instead of shoot tears, Eika stacks rocks above her head, and then throw them to enemies."},
                {str = "-Eika can only stack 5 rocks at the same time, the overflowed rocks will drop to the ground. If she moves when stacking, the rock limit will become 3 instead."},
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "Can stack 20 rocks at the same time."},
            },
            { -- Interactions
                {str = "Interactions", fsize = 2, clr = 3, halign = 0},
                {str = "Brimstone: The thrown rocks will spawn cross-shaped brimstones after land or hit."},
                {str = "Mom's Knife: Throw whirling blade rocks."},
                {str = "Mom's Knife + Brimstone: Throw whirling blade rocks, and shoot a cluster of fly away blade rocks."},
                {str = "Mom's Knife + Tiny Planet: Throw whirling blade rocks, which orbits player in a extermely fast speed."},
                {str = "Ipecac: Rocks will explode."},
                {str = "Technology: Rocks shoot cross-shaped lasers while flying."},
                {str = "Tech X: Rocks will spawn circle lasers while flying."},
                {str = "Anti-Gravity: Overrides Anti-Gravity."},
                {str = "Haemolacria: Rocks will split into small blood tears."},
                {str = "Chocolate Milk: Rocks' Damages increase with the stacking time."},
                {str = "Monstro's Lung: Throw a cluster of rocks."},
                {str = "Dr. Fetus: Stack bombs."},
                {str = "Epic Fetus: Fall rockets after rocks land or hit."},
                {str = "Cursed Eye: Tears up, but will teleport after hit."},
                {str = "Marked: Automatically throw rocks to the target position."},
                {str = "Analog Stick: Can throw towards all directions."},
                {str = "Spirit Sword: Rocks will spin swords during flight."},
                {str = "Soy Milk/Almond Milk: Automatically throw rocks."},
            },
        }
    },
    
    [THI.Players.EikaB.Type] = {
        Name = "Eika",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Tainted Eika",
        Nickname = "The Stillborn",
        Tainted = true,
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- Fetus Blood"},
                {str = "- Umbilical Cord"},
                {str = "Stats:"},
                {str = "- HP: 2 Red Hearts"},
                {str = "- Speed: 0.85"},
                {str = "- Tear Rate: 2.73"},
                {str = "- Damage: 2.62"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 0.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "With a bad start data, Tainted Eika has Fetus Blood at her pocket slot to help fight her enemies. When Fetus Blood is used, a friendly Blood Bony will spawn. Blood Bonies take the same action like Bonies, but are much stronger than them."},
                {str = "-Eika can only have 1 Blood Bony at floor 1. The count limit will increase as current floor increases."},
                {str = "-Blood Bonies' bones deal 1.2x player damage."},
                {str = "Tainted Eika cannot have soul Hearts, black hearts or even bone hearts, but she can convert them into another kinds of Bonies. Also, some kinds of these Bonies can upgrade when more hearts are gained, like Cube of Meat."},
                {str = "-Soul hearts can be converted into Soul Bonies, which can fly and not affected by the obstacles."},
                {str = "-L1: Shoots weak bones, which deal 1x player damage."},
                {str = "-L2: Shoots weak bones, and has 50% chance to fire a blue flame, which deals 0.2x player damage per hit."},
                {str = "-L3: Shoots weak bones and blue flames."},
                {str = "-Black hearts can be converted into Devil Bonies, which shoots 3 bones at a time, and explodes when killed."},
                {str = "-L1: Shoots strong bones, which deal 5 + player damage."},
                {str = "-L2: Shoots stronger bones, which deal 5 + 2 x player damage. They also has strong homing effect."},
                {str = "-L3: Shoots strongest and homing bones, which deal 5 + 3 x player damage, and spawn brimstone ball upon hit."},
                {str = "-Bone Hearts can be converted into Big Bonies. Which is simply tough and has more HP than any bonies. This cannot upgrade."},
                {str = "Tainted Eika also leaves blood creeps behind."},
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "Friendly heart bonies explodes upon death."},
                {str = "Will not damage player, and can destroy obstacles."},
            },
        }
    },
    
    [THI.Players.Satori.Type] = {
        Name = "Satori",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Satori",
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- Monster Manual"},
                {str = "- Guppy's Eye"},
                {str = "Stats:"},
                {str = "- HP: 2 Red Hearts"},
                {str = "- Speed: 1.0"},
                {str = "- Tear Rate: 2.18"},
                {str = "- Damage: 2.80"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 0.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "Satori always has a Psyche Eye familiar."},
                {str = "When she controls an enemy monsters by Psyche Eye, she permanently gains +0.01 tears up, +0.02 damage up and +0.025 range up."},
                {str = "When she kills friendly monsters by Psyche Eye's mind blast, she will gain +1 tears up, +2 damage up and +2.5 range up in 5 seconds."},
                {str = "Due to that Psyche Eye's psyche wave's radius is based on player's range, Satori's range will get higher and higher, making she can easily control a lot of monsters at the later game."},
                {str = "See Psyche Eye Item Page for more information."}
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "Mind blast's stats up get doubled."},
            },
        }
    },

    [THI.Players.SatoriB.Type] = {
        Name = "Satori",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Tainted Satori",
        Nickname = "The Addicted",
        Tainted = true,
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- Placebo"},
                {str = "- Candy Heart"},
                {str = "- Hematemesis"},
                {str = "Stats:"},
                {str = "- HP: 2 Heart Containers + half Red Heart"},
                {str = "- Speed: 0.5"},
                {str = "- Tear Rate: 2.73"},
                {str = "- Damage: 2.80"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 0.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "Tainted Satori sits on a wheel chair, that means she can safely walk on spikes or creeps."},
                {str = "Tainted Satori has awful starting move speed, but she can slowly increase her velocity by keep moving. When her speed charge is more than 50%, she will become invincible and can crash any enemies in front of her, dealing a terrible number of damage."},
                {str = "-If target enemy's HP is lower than the damage, only the charge that just kills the enemy will be lost. Otherwise, all charges will be lost, and Tainted Satori will be bounced off."},
                {str = "Tainted Satori's speed cap is 1.0."},
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "Speed up, speed cap + 0.25."},
                {str = "Crashing will cause explosion while speed is larger than or equal to 1.0." }
            },
        }
    },
    [THI.Players.Seija.Type] = {
        Name = "Seija",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Seija",
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- D Flip"},
                {str = "Stats:"},
                {str = "- HP: 3 Red Hearts"},
                {str = "- Extra: 1 Bomb"},
                {str = "- Speed: 1.00"},
                {str = "- Tear Rate: 2.73"},
                {str = "- Damage: 3.50"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 1.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "-Seija has the same stats as Isaac, as with a D Flip at her pocket slot, meaning that she can reroll bad items into good items, or reroll it back."},
                {str = "-Seija greatly buffs all quality 0 items, and some quality 1 items. But also nerfs most of quality 4 and some quality 3 items, making the player prefers low quality items."},
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "No longer nerfs strong items."},
            },
            { -- Buffs
                {str = "Buffs", fsize = 2, clr = 3, halign = 0},
                {str = "My Reflection", fsize = 2, halign = 0},
                {str = "x0.75 Range."},
                {str = "Fires shuriken tears which is piercing and spectral, will deal contact damage every frame."},
                {str = "Skatole", fsize = 2, halign = 0},
                {str = "Turns all flies friendly."},
                {str = "Spawn a blue fly when an enemy dies."},
                {str = "Boom!", fsize = 2, halign = 0},
                {str = "+89 additional bombs."},
                {str = "The Poop", fsize = 2, halign = 0},
                {str = "Spawn golden poop."},
                {str = "Kamikaze!", fsize = 2, halign = 0},
                {str = "Trigger Mama Mega's effect in this room."},
                {str = "Mom's Pad", fsize = 2, halign = 0},
                {str = "Deal 40 damage to all enemies, killed enemies will drop red hearts."},
                {str = "Teleport!", fsize = 2, halign = 0},
                {str = "Teleport you to the unvisited Treasure room, Ultra Secret Room, Devil/Angel Room, I AM Error Room in the order."},
                {str = "The Bean", fsize = 2, halign = 0},
                {str = "All enemies farts and get poisoned."},
                {str = "Dead Bird", fsize = 2, halign = 0},
                {str = "Spawn a dead bird when enemy killed."},
                {str = "Razor Blade", fsize = 2, halign = 0},
                {str = "Doubles Damage and triggers Soul of Magdalane's Effect."},
                {str = "Pageant Boy", fsize = 2, halign = 0},
                {str = "Spawn an additional nickel, dime, golden penny and lucky penny upon picked up."},
                {str = "Pennies have a chance to be replaced by nickel, dime, golden penny or lucky penny."},
                --{str = "Bum Friend", fsize = 2, halign = 0},
                --{str = "50% chance to give collectibles from beggar item pool instead."},
                {str = "Infestation", fsize = 2, halign = 0},
                {str = "Has 50% chance to poison the enemy and spawn a blue fly when an enemy is damaged."},
                {str = "Portable Slot", fsize = 2, halign = 0},
                {str = "50% chance to gain 1 penny when failed."},
                {str = "Black Bean", fsize = 2, halign = 0},
                {str = "Enemies nearby farts and get poisoned when player is damaged."},
                {str = "Enemies also triggers this after died."},
                {str = "Blood Rights", fsize = 2, halign = 0},
                {str = "Deals 40 additional damage, all enemies bleeds pernamently."},
                {str = "Bleeding enemies drops temporary red hearts when dies."},
                {str = "Abel"},
                {str = "Deals 128 damage per second to nearby enemies and makes them burn."},
                {str = "Link the player and abel with laser, deals damage to enemies touch the laser."},
                {str = "Tiny Planet", fsize = 2, halign = 0},
                {str = "Falls a meteor and explodes at a random position when tears hit an enemy, dealing 10x player damage."},
                {str = "Won't damage player."},
                {str = "Missing Page 2", fsize = 2, halign = 0},
                {str = "+1 Damage up."},
                {str = "Triggers Necronomicon when damaged."},
                {str = "Best Bud", fsize = 2, halign = 0},
                {str = "Always has the white fly."},
                {str = "The white fly will knockback enemies close to player, deal damages and make them confusion."},
                {str = "Isaac's Heart", fsize = 2, halign = 0},
                {str = "The heart repels enemies."},
                --{str = "D10", fsize = 2, halign = 0},
                --{str = "All non-Boss enemies has 80% chance to turn to fly."},
                {str = "Book of Secrets", fsize = 2, halign = 0},
                {str = "Use four times in one time."},
                {str = "Key Bum", fsize = 2, halign = 0},
                {str = "Gives an additional Latch Key."},
                {str = "Punching bag", fsize = 2, halign = 0},
                {str = "Pull the nearby enemies to its side and punch repeatedly."},
                {str = "Obsessed Fan", fsize = 2, halign = 0},
                {str = "Spawn 2 blue flies per second when enemy exists."},
                {str = "The Jar", fsize = 2, halign = 0},
                {str = "Drop 1 additional random heart after room cleared."},
                {str = "Strange Attractor", fsize = 2, halign = 0},
                {str = "Tears will shock enemies nearby."},
                {str = "Cursed Eye", fsize = 2, halign = 0},
                {str = "Doubles Tears."},
                -- {str = "Cain's Other Eye", fsize = 2, halign = 0},
                -- {str = "Fire brimstone laser to the nearest enemy."},
                -- {str = "Displays this floor's rooms after new floor."},
                {str = "Isaac's Tears", fsize = 2, halign = 0},
                {str = "Only needs shot to fully recharge."},
                -- {str = "Breath of Life", fsize = 2, halign = 0},
                -- {str = "Invincible while charges is not full."},
                -- {str = "Betrayal", fsize = 2, halign = 0},
                -- {str = "Charm 50% enemies when entered a new room."},
                -- {str = "Use Soul of Satori when damaged."},
                {str = "Linger Bean", fsize = 2, halign = 0},
                {str = "Clouds appears more frequently, and will chase enemies."},
                -- {str = "My Shadow", fsize = 2, halign = 0},
                -- {str = "Spawn black chargers under enemies."},
                -- {str = "Black chargers explode upon death, won't damage player."},
                {str = "Shade", fsize = 2, halign = 0},
                {str = "Spawn a Seija's shade for each enemies after entered a room."},
                {str = "Deal (2+1 * stage) contact damage per second."},
                {str = "Disappears when enemy dies."},
                {str = "Hushy", fsize = 2, halign = 0},
                {str = "Fire 3 lines of Continuum tears when stopped."},
                {str = "Plan C", fsize = 2, halign = 0},
                {str = "Gain 1UP!."},
                {str = "Dataminer", fsize = 2, halign = 0},
                {str = "When used:."},
                {str = "+0.1 Speed up +0.25 Tears up."},
                {str = "+0.5 Damage up +0.75 Range up."},
                {str = "+0.5 Luck."},
                {str = "Clicker", fsize = 2, halign = 0},
                {str = "Spawn a quality 4 item."},
                {str = "Scooper", fsize = 2, halign = 0},
                {str = "Use 5 more times."},
                {str = "+5 Damage up after each use, reduce 1.07 damage every second."},
                {str = "Brown Nugget", fsize = 2, halign = 0},
                {str = "Only needs 0.5 seconds for fully charged."},
                {str = "Curse of the Tower", fsize = 2, halign = 0},
                {str = "Explosion resistance."},
                {str = "Missing No.", fsize = 2, halign = 0},
                {str = "Get full soul heart after floor."},
                -- {str = "Ouija Board", fsize = 2, halign = 0},
                -- {str = "+1 Tears up."},
                -- {str = "Piercing tears."},
                {str = "IBS", fsize = 2, halign = 0},
                {str = "Remove the original effect, spawn 3 random dips and leave buffing creep after dealt enough damage instead."},
                {str = "TMTRAINER", fsize = 2, halign = 0},
                {str = "Replace this item to a new one, which replaces all super secret rooms to I AM ERROR room."},
                {str = "Battery Pack", fsize = 2, halign = 0},
                {str = "No longer spawns micro batteries, normal batteries has 5% chance to turn to mega battery."},
                {str = "Chance to spawn a battery after room cleared, 100% at 15 luck."},
                {str = "Little Baggy", fsize = 2, halign = 0},
                {str = "Turns all pills to horse pills."},
                {str = "Identify all pills."},
                {str = "Box", fsize = 2, halign = 0},
                {str = "25% chance to spawn another Box, or spawn an item from a random item pool."},
                {str = "A Quarter", fsize = 2, halign = 0},
                {str = "Lose this item, and gain 25 coins when coins are less than 25."},
                {str = "Spiderbaby", fsize = 2, halign = 0},
                {str = "Chance to fire spider web tears, which spawn blue spiders and spider webs on hit, slow enemies inside the webs."},
                {str = "50% at 8 Luck"},
                {str = "Lemon Mishap", fsize = 2, halign = 0},
                {str = "Starts an acid rain in the room lasts for 30 secs, Dealing 30% armor-ignoring damage + 100 damage in total, and can destroy obstacles."},
                {str = "Glaucoma", fsize = 2, halign = 0},
                {str = "Additional chance to fire confusion tears."},
                {str = "Flashes on hit, confuses all enemies nearby and deals 200% player damage to them, and clear bullets."},
                {str = "50% at 9 luck."},
                {str = "The Wiz", fsize = 2, halign = 0},
                {str = "Homing and piercing tears."},
                -- {str = "Athame", fsize = 2, halign = 0},
                -- {str = "Enemies killed by black laser has 20% chance to drop a black heart."},
                {str = "Taurus", fsize = 2, halign = 0},
                {str = "Speed becomes 1.95."},
                {str = "Green Eyed Envy", fsize = 2, halign = 0},
                {str = "Enemy copies get charmed for 5 minutes."},
                {str = "Vicious Curse", fsize = 2, halign = 0},
                {str = "No longer damages player, +1 soul heart."},
                {str = "Restore Damocles' update speed."},
                {str = "Protects player when killing by Damocles."},
                {str = "Cursed Blood", fsize = 2, halign = 0},
                {str = "Immune to fire damages."},
                {str = "Explosion damage will heal you half red heart instead."},
                {str = "Rainbow Card", fsize = 2, halign = 0},
                {str = "Won't lose items."},
                {str = "Other mod's quality 0 items", fsize = 2, halign = 0},
                {str = "All stats up."}
            },
            { -- Nerfs
                {str = "Nerfs", fsize = 2, clr = 3, halign = 0},
                {str = "Missing No.", fsize = 2, halign = 0},
                {str = "Won't meet quality 4 items."},
                {str = "Cricket's Head", fsize = 2, halign = 0},
                {str = "-33% Tears down."},
                {str = "Magic Mushroom", fsize = 2, halign = 0},
                {str = "-0.8 Speed down."},
                {str = "Dr. Fetus", fsize = 2, halign = 0},
                {str = "Explosion time get tripled."},
                {str = "D6", fsize = 2, halign = 0},
                {str = "Has 30% chance to remove the collectible."},
                {str = "Wafer", fsize = 2, halign = 0},
                {str = "Has 50% chance to take an addition damage when damaged."},
                {str = "Mom's Knife", fsize = 2, halign = 0},
                {str = "-25% Tears down."},
                {str = "-25% Damage down."},
                {str = "Homing."},
                {str = "Brimstone", fsize = 2, halign = 0},
                {str = "Blood laser's range is limited by player's range."},
                {str = "Ipecac", fsize = 2, halign = 0},
                {str = "Boomerange Tears."},
                {str = "Epic Fetus", fsize = 2, halign = 0},
                {str = "Doubles rockets' falling time."},
                {str = "Polyphemus", fsize = 2, halign = 0},
                {str = "-25% Tears down."},
                {str = "Sacred Heart", fsize = 2, halign = 0},
                {str = "-50% Tears down "},
                {str = "-0.5 Speed down "},
                {str = "-2.5 Range down "},
                {str = "-3 Luck down."},
                {str = "+1 Shotspeed up."},
                {str = "Pyromaniac", fsize = 2, halign = 0},
                {str = "Enemy restores HP instead of taking explosion damage."},
                {str = "Stop Watch", fsize = 2, halign = 0},
                {str = "-0.6 Speed down."},
                -- {str = "Infestation 2", fsize = 2, halign = 0},
                -- {str = "Spawn enemy spiders when an enemy dies."},
                {str = "20/20", fsize = 2, halign = 0},
                {str = "-6.75% damage down."},
                {str = "Proptosis", fsize = 2, halign = 0},
                {str = "-1 Shotspeed down."},
                {str = "Satanic Bible", fsize = 2, halign = 0},
                {str = "+1Broken Heart when used."},
                {str = "Holy Mantle", fsize = 2, halign = 0},
                {str = "Become The Lost forever."},
                {str = "Godhead", fsize = 2, halign = 0},
                {str = "+2.3 Shotspeed up."},
                {str = "Incubus", fsize = 2, halign = 0},
                {str = "-25 %Damage down."},
                {str = "Tech X", fsize = 2, halign = 0},
                {str = "+2 Shotspeed up."},
                -- {str = "Maw of the Void", fsize = 2, halign = 0},
                -- {str = "Enemies killed by lasers explodes."},
                {str = "Crown of the Light", fsize = 2, halign = 0},
                {str = "Red hearts run off slowly."},
                {str = "Mega Blast", fsize = 2, halign = 0},
                {str = "Blood laser's range is limited by player's range."},
                {str = "Void", fsize = 2, halign = 0},
                {str = "All stats slightly down after consumed a collectible."},
                {str = "D Infinity", fsize = 2, halign = 0},
                {str = "Has 33% chance to lose a charge after room cleared."},
                {str = "Psy Fly", fsize = 2, halign = 0},
                {str = "Greatly reduces speed."},
                {str = "Mega Mush", fsize = 2, halign = 0},
                {str = "Have not contact damage."},
                {str = "Revelation", fsize = 2, halign = 0},
                {str = "Laser's range is limited by player's range."},
                {str = "Binge Eater", fsize = 2, halign = 0},
                {str = "-0.12Speed down for each food item."},
                {str = "C Section", fsize = 2, halign = 0},
                {str = "Has 5% chance to fire an Unborn enemy."},
                {str = "Glitched Crown", fsize = 2, halign = 0},
                {str = "Collectibles has 80% chance to turn to Glitched Crown."},
                {str = "Twisted Pair", fsize = 2, halign = 0},
                {str = "-40% Damage down."},
                {str = "Abyss", fsize = 2, halign = 0},
                {str = "-10% Damage down after consumed a collectible."},
                {str = "Bag of Crafting", fsize = 2, halign = 0},
                {str = "75% chance to fail the crafting."},
                {str = "Flip", fsize = 2, halign = 0},
                {str = "50% chance to remove pedestal items."},
                {str = "Spindown Dice", fsize = 2, halign = 0},
                {str = "Reduces items' ID by 0-2 again randomly."},
                {str = "Ghost Pepper", fsize = 2, halign = 0},
                {str = "-8 Luck down."},
                {str = "Haemolacria", fsize = 2, halign = 0},
                {str = "Piercing Tears."},
                {str = "Rock Bottom", fsize = 2, halign = 0},
                {str = "All stats get doubled, then no longer changes."},
                {str = "Holy Light", fsize = 2, halign = 0},
                {str = "Lightbolts have only 33% player damage."},
                {str = "Dark Ribbon", fsize = 2, halign = 0},
                {str = "Enemies die inside the halo spawn enemy black chargers."},
                {str = "Vampire Tooth", fsize = 2, halign = 0},
                {str = "All hearts run off slowly."},
                {str = "Fan of the Dead", fsize = 2, halign = 0},
                {str = "Revives at the last room."},
                {str = "Saucer Remote", fsize = 2, halign = 0},
                {str = "UFO will attack player."},
                {str = "D2147483647", fsize = 2, halign = 0},
                {str = "Can only select quality 0 or 1 items."},
                {str = "Wild Fury", fsize = 2, halign = 0},
                {str = "Decrease stats instead after kills enemy."},
                {str = "Pure Fury", fsize = 2, halign = 0},
                {str = "x1.01 Damage up instead."},
                {str = "Exchange Tickets", fsize = 2, halign = 0},
                {str = "50% traders in the exchange transforms into Greeds."},
                {str = "Curse of Centipede", fsize = 2, halign = 0},
                {str = "Also gives Sacred Heart and Polyphemus."},
                {str = "Byte String", fsize = 2, halign = 0},
                {str = "All numbers affected by this item become 6."},
                {str = "Mimic Tear", fsize = 2, halign = 0},
                {str = "50% chance to remove the item instead of duplicating it"},
            }
        }
    },
    
    [THI.Players.SeijaB.Type] = {
        Name = "Seija",
        Sprite = "gfx/reverie/ui/characterportraits.anm2",
        Animation = "Tainted Seija",
        Nickname = "The Bullied",
        Tainted = true,
        Wiki = {
            { -- Start Data
                {str = "Start Data", fsize = 2, clr = 3, halign = 0},
                {str = "Items:"},
                {str = "- D Siphon"},
                {str = "Stats:"},
                {str = "- HP: 3 Red Hearts"},
                {str = "- Extra: 1 Bomb"},
                {str = "- Speed: 1.00"},
                {str = "- Tear Rate: 2.73"},
                {str = "- Damage: 3.50"},
                {str = "- Range: 6.50"},
                {str = "- Shot Speed: 1.00"},
                {str = "- Luck: 1.00"},
            },
            { -- Traits
                {str = "Traits", fsize = 2, clr = 3, halign = 0},
                {str = "-Just like normal Seija, Tainted Seija nerfs high quality items and buffs low quality items as well, but she can only meet quality 2 items, making her hardly to find any low quality items."},
                {str = "-To find low quality items, she must use her pocket active item - D Siphon to drain items' qualities. But beware, if D Siphon drains too much qualities, the qualities inside this item will be consumed, and the effect of this dice will be reversed."},
            },
            { -- Birthright
                {str = "Birthright", fsize = 2, clr = 3, halign = 0},
                {str = "The passive effect only prevents quality 0 items from spawning"},
            }
        }
    },
}

EIDInfo.Birthrights = {
    [Players.Eika.Type] = {
        Description = "Can stack 20 rocks",
        PlayerName = "Eika"
    },
    [Players.EikaB.Type] = {
        Description = "Friendly heart bonies explodes upon death"..
        "#Will not damage player",
        PlayerName = "Tainted Eika"
    },
    [Players.Satori.Type] = {
        Description = "Stats up from {{Collectible"..Collectibles.PsycheEye.Item.."}}Psyche Eye get doubled",
        PlayerName = "Satori"
    },
    [Players.SatoriB.Type] = {
        Description = "↑  {{Speed}}Speed + Max speed up"..
        "#{{Speed}} Crush will cause explosion while speed is larger than or equal to 1",
        PlayerName = "Tainted Satori"
    },
    [Players.Seija.Type] = {
        Description = "No longer nerf strong items",
        PlayerName = "Seija"
    },
    [Players.SeijaB.Type] = {
        Description = "{{Collectible"..Collectibles.DSiphon.Item.."}}D Siphon can be controlled to drain or release qualities"..
        "#Drains quality at default"..
        "#Releases quality when used while holding "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."drop button",
        PlayerName = "Tainted Seija"
    }
}

EIDInfo.LunaticDescs = {
    Collectibles = {
        [Collectibles.DarkRibbon.Item] = "+20% damage instead",
        [Collectibles.DYSSpring.Item] = "Fairies can only heal 1 {{Heart}}red heart and 1 {{SoulHeart}}soul heart",
        [Collectibles.MaidSuit.Item] = "Can only stop time for 2 seconds, and drops {{Card22}}XXI-The World after defeat the boss instead",
        [Collectibles.VampireTooth.Item] = "Heart drop rate reduced to 2.5%",
        [Collectibles.Roukanken.Item] = "No longer gain charges when kills enemies",
        [Collectibles.FanOfTheDead.Item] = "Life limit is 20",
        [Collectibles.OneOfNineTails.Item] = "Will no longer spawn more babies if player has reached the limit of 9",
        [Collectibles.Starseeker.Item] = "Choices become 2",
        [Collectibles.BookOfYears.Item] = "Has 30% chance to not spawn item",
        [Collectibles.TenguCamera.Item] = "Freeze 4 seconds instead",
        [Collectibles.Pagota.Item] = "No longer midas enemies",
        [Collectibles.ZombieInfestation.Item] = "Monsters has only 50% chance to spawn friendly clones",
        [Collectibles.D2147483647.Item] = "Needs 2 charges to transform, and excluded {{Collectible" ..
            CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE .. "}} Death Certificate",
        [Collectibles.TheInfamies.Item] = "No longer charms bosses",
        [Collectibles.RuneSword.Item] = "Can insert at most 6 runes",
        [Collectibles.WildFury.Item] = "Only affects {{Damage}} damage",
    },
    Trinkets = {
        [Trinkets.FortuneCatPaw.Trinket] = "The chance of dropping coins from Boss reduced to 60%",
    }
}
EIDInfo.SeijaBuffs = {
    Collectibles = {
        [CollectibleType.COLLECTIBLE_MY_REFLECTION] = "Fires shuriken tears (visual effect only)",
        [CollectibleType.COLLECTIBLE_SKATOLE] = "Turns all flies friendly"..
        "#Spawn a blue fly when an enemy dies",
        [CollectibleType.COLLECTIBLE_BOOM] = "+89 additional bombs",
        [CollectibleType.COLLECTIBLE_POOP] = "Spawn golden poop",
        [CollectibleType.COLLECTIBLE_KAMIKAZE] = "Trigger {{Collectible"..CollectibleType.COLLECTIBLE_MAMA_MEGA.."}}Mama Mega's effect in this room",
        [CollectibleType.COLLECTIBLE_MOMS_PAD] = "Deal 40 damage to all enemies, killed enemies will drop red hearts",
        [CollectibleType.COLLECTIBLE_TELEPORT] = "Teleport you to the unvisited {{TreasureRoom}}Treasure room, {{UltraSecretRoom}}Ultra Secret Room, {{DevilRoom}}Devil/{{AngelRoom}}Angel Room, I AM Error Room in the order",
        [CollectibleType.COLLECTIBLE_BEAN] = "All enemies farts and get poisoned",
        [CollectibleType.COLLECTIBLE_DEAD_BIRD] = "Spawn a dead bird when enemy killed",
        [CollectibleType.COLLECTIBLE_RAZOR_BLADE] = "Gain {{Damage}}Damage multiplier and triggers{{Card"..Card.CARD_SOUL_MAGDALENE.."}}Soul of Magdalane's Effect",
        [CollectibleType.COLLECTIBLE_PAGEANT_BOY] = "Spawn an additional nickel, dime, golden penny and lucky penny upon picked up"..
        "#Pennies have a chance to be replaced by nickel, dime, golden penny or lucky penny",
        --[CollectibleType.COLLECTIBLE_BUM_FRIEND] = "50% chance to gives collectibles from beggar item pool instead",
        [CollectibleType.COLLECTIBLE_INFESTATION] = "Has 50% chance to {{Poison}}poison the enemy and spawn a blue fly when an enemy is damaged",
        [CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = "50% chance to gain 1 {{Coin}}penny when failed",
        [CollectibleType.COLLECTIBLE_BLACK_BEAN] = "Enemies nearby farts and get {{Poison}}poisoned when player is damaged"..
        "#Enemies also triggers this after died",
        [CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = "Deals 40 additional damage, all enemies bleeds pernamently"..
        "#Bleeding enemies drops temporary red hearts when dies",
        [CollectibleType.COLLECTIBLE_ABEL] = "Deals 128 damage per second to nearby enemies and makes them burn"..
        "#Link the player and abel with laser, deals damage to enemies touch the laser",
        [CollectibleType.COLLECTIBLE_TINY_PLANET] = "Falls a meteor and explodes at a random position when tears hit an enemy, dealing 10x player damage"..
        "#Won't damage player",
        [CollectibleType.COLLECTIBLE_MISSING_PAGE_2] = "↑ +1 {{Damage}}Damage up"..
        "#Triggers {{Collectible"..CollectibleType.COLLECTIBLE_NECRONOMICON.."}}Necronomicon when damaged",
        [CollectibleType.COLLECTIBLE_BEST_BUD] = "Always has the white fly"..
        "#The white fly will knockback enemies close to player, deal damages and make them confusion",
        [CollectibleType.COLLECTIBLE_ISAACS_HEART] = "The heart repels enemies",
        --[CollectibleType.COLLECTIBLE_D10] = "All non-Boss enemies has 80% chance to turn to fly",
        [CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS] = "Use four times in one time",
        [CollectibleType.COLLECTIBLE_KEY_BUM] = "Gives an additional {{Collectible"..CollectibleType.COLLECTIBLE_LATCH_KEY.."}}Latch Key",
        [CollectibleType.COLLECTIBLE_PUNCHING_BAG] = "Pull the nearby enemies to its side and punch repeatedly",
        [CollectibleType.COLLECTIBLE_OBSESSED_FAN] = "Spawn 2 blue flies per second when enemy exists",
        [CollectibleType.COLLECTIBLE_THE_JAR] = "Drop 1 additional random heart after room cleared",
        [CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR] = "Tears will shock enemies nearby",
        [CollectibleType.COLLECTIBLE_CURSED_EYE] = "↑ {{Tears}} Doubles Tears",
        -- [CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE] = "Fire brimstone laser to the nearest enemy"..
        -- "#Displays this floor's rooms after new floor",
        [CollectibleType.COLLECTIBLE_ISAACS_TEARS] = "Only needs shot to fully recharge",
        --[CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = "Invincible while charges is not full",
        -- [CollectibleType.COLLECTIBLE_BETRAYAL] = "{{Charm}}Charm 50% enemies when entered a new room"..
        -- "#Use {{Card"..THI.Cards.SoulOfSatori.ID.."}}Soul of Satori when damaged",
        [CollectibleType.COLLECTIBLE_LINGER_BEAN] = "Clouds appears more frequently, and will chase enemies",
        --  [CollectibleType.COLLECTIBLE_MY_SHADOW] = "Spawn black chargers under enemies"..
        -- "#Black chargers explode upon death, won't damage player",
        [CollectibleType.COLLECTIBLE_SHADE] = "Spawn a Seija's shade for each enemies after entered a room"..
        "#Deal (2+1*stage) contact damage per second"..
        "#Disappears when enemy dies",
        [CollectibleType.COLLECTIBLE_HUSHY] = "Fire 3 lines of {{Collectible"..CollectibleType.COLLECTIBLE_CONTINUUM.."}}Continuum tears when stopped",
        [CollectibleType.COLLECTIBLE_PLAN_C] = "Gain {{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}}1UP!",
        [CollectibleType.COLLECTIBLE_DATAMINER] = "When used:"..
        "#↑ +0.1 Speed up ↑ +0.25 Tears up"..
        "#↑ +0.5 Damage up ↑ +0.75 Range up"..
        "#↑ +0.5 Luck",
        [CollectibleType.COLLECTIBLE_CLICKER] = "Spawn a quality {{Quality4}} item",
        [CollectibleType.COLLECTIBLE_SCOOPER] = "Use 5 more times"..
        "#↑ +5 Damage up after each use, reduce 1.07 damage every second",

        [CollectibleType.COLLECTIBLE_BROWN_NUGGET] = "Only needs 0.5 seconds for fully charged",
        [CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER] = "Explosion resistance",
        [CollectibleType.COLLECTIBLE_MISSING_NO] = "Get full soul heart after floor",
        
        [CollectibleType.COLLECTIBLE_IBS] = "Remove the original effect, spawn 3 random dips and leave buffing creep after dealt enough damage instead",
        [CollectibleType.COLLECTIBLE_TMTRAINER] = "Replace this item to a new one, which replaces all {{SuperSecretRoom}}super secret rooms to I AM ERROR room",
        [CollectibleType.COLLECTIBLE_BATTERY_PACK] = "No longer spawns micro batteries, normal batteries has 5% chance to turn to mega battery"..
        "#Chance to spawn a battery after room cleared"..
        "#100% at 15 luck",
        [CollectibleType.COLLECTIBLE_LITTLE_BAGGY] = "Turns all pills to horse pills"..
        "#Identify all pills",
        [CollectibleType.COLLECTIBLE_BOX] = "25% chance to spawn another {{Collectible"..CollectibleType.COLLECTIBLE_BOX.."}}Box, or spawn an item from a random item pool",
        [CollectibleType.COLLECTIBLE_QUARTER] = "Lose this item, and gain 25 {{Coin}}coins when coins are less than 25",
        [CollectibleType.COLLECTIBLE_SPIDERBABY] = "Chance to fire spider web tears, which spawn blue spiders and spider webs on hit, slow enemies inside the webs"..
        "#50% at 8 {{Luck}}Luck",
        [CollectibleType.COLLECTIBLE_LEMON_MISHAP] = "Starts an acid rain in the room lasts for 30 secs"..
        "#Dealing 30% armor-ignoring damage + 100 damage in total"..
        "#Can destroy obstacles",
        -- [CollectibleType.COLLECTIBLE_OUIJA_BOARD] = "↑ +1{{Tears}}Tears up"..
        -- "#Piercing tears",
        [CollectibleType.COLLECTIBLE_GLAUCOMA] = "Additional chance to fire confusion tears"..
        "#Flashes on hit, confuses all enemies nearby and deals 200% player damage to them, and clear bullets"..
        "#50% at 9 luck",
        [CollectibleType.COLLECTIBLE_TAURUS] = "{{Speed}}Speed becomes 1.95",
        [CollectibleType.COLLECTIBLE_THE_WIZ] = "Homing and piercing tears",
        -- [CollectibleType.COLLECTIBLE_ATHAME] = "Enemies killed by black laser has 20% chance to drop a black heart",
        [Collectibles.GreenEyedEnvy.Item] = "Enemy copies get charmed for 5 minutes",
        [Collectibles.ViciousCurse.Item] = "No longer damages player, +1 soul heart"..
        "#Restore {{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE.."}}Damocles' update speed"..
        "#Protects player when killing by {{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE.."}}Damocles",
        [Collectibles.CursedBlood.Item] = "Immune to fire damages"..
        "Explosion damage will heal you {{HalfHeart}}half red heart instead",
        [Collectibles.RainbowCard.Item] = "Won't lose items",
    },
    Modded = "↑ All stats up"
}
EIDInfo.SeijaNerfs = {
    Collectibles = {
        [CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = "↓ -33% {{Tears}}Tears down",
        [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = "↓ -0.8 {{Speed}}Speed down",
        [CollectibleType.COLLECTIBLE_DR_FETUS] = "Explosion time get tripled",
        [CollectibleType.COLLECTIBLE_D6] = "Has 30% chance to remove the collectible",
        [CollectibleType.COLLECTIBLE_WAFER] = "Has 50% chance to take an addition damage when damaged",
        [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = "↓ -25%{{Tears}}Tears down ↓-25%{{Damage}}Damage down"..
        "#Homing",
        [CollectibleType.COLLECTIBLE_BRIMSTONE] = "Blood laser's range is limited by player's {{Range}}range",
        [CollectibleType.COLLECTIBLE_IPECAC] = "Boomerange Tears",
        [CollectibleType.COLLECTIBLE_EPIC_FETUS] = "Doubles rockets' falling time",
        [CollectibleType.COLLECTIBLE_POLYPHEMUS] = "↓ -25%{{Tears}}Tears down",
        [CollectibleType.COLLECTIBLE_SACRED_HEART] = "↓ -50%{{Tears}}Tears down ↓-0.5{{Speed}}Speed down ↓-2.5{{Range}}Range down ↓-3{{Luck}}Luck down"..
        "#↑ +1{{Shotspeed}}Shotspeed up",
        [CollectibleType.COLLECTIBLE_PYROMANIAC] = "Enemy restores HP instead of taking explosion damage",
        [CollectibleType.COLLECTIBLE_STOP_WATCH] = "↓ -0.6{{Speed}} Speed down",
        -- [CollectibleType.COLLECTIBLE_INFESTATION_2] = "Spawn enemy spiders when an enemy dies",
        [CollectibleType.COLLECTIBLE_20_20] = "↓ -6.75%{{Damage}} Damage down",
        [CollectibleType.COLLECTIBLE_PROPTOSIS] = "↓ -1{{Shotspeed}} Shotspeed down",
        [CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = "+1{{BrokenHeart}}Broken Heart when used",
        [CollectibleType.COLLECTIBLE_HOLY_MANTLE] = "Become {{Player"..PlayerType.PLAYER_THELOST.."}}The Lost forever",
        [CollectibleType.COLLECTIBLE_GODHEAD] = "↑ +2.3{{Shotspeed}}Shotspeed up",
        [CollectibleType.COLLECTIBLE_INCUBUS] = "↓ -25%{{Damage}}Damage down",
        [CollectibleType.COLLECTIBLE_TECH_X] = "↑ +2{{Shotspeed}}Shotspeed up",
        -- [CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID] = "Enemies killed by lasers explodes",
        [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = "{{Heart}}Red hearts run off slowly",
        [CollectibleType.COLLECTIBLE_MEGA_BLAST] = "Blood laser's range is limited by player's {{Range}}range",
        [CollectibleType.COLLECTIBLE_VOID] = "↓ All stats slightly down after consumed a collectible",
        [CollectibleType.COLLECTIBLE_D_INFINITY] = "Has 33% chance to lose a charge after room cleared",
        [CollectibleType.COLLECTIBLE_PSY_FLY] = "Greatly reduces speed",
        [CollectibleType.COLLECTIBLE_MEGA_MUSH] = "Have not contact damage",
        [CollectibleType.COLLECTIBLE_REVELATION] = "Laser's range is limited by player's {{Range}}range",
        [CollectibleType.COLLECTIBLE_BINGE_EATER] = "↓ -0.12{{Speed}}Speed down for each food item",
        [CollectibleType.COLLECTIBLE_C_SECTION] = "Has 5% chance to fire an Unborn enemy",
        [CollectibleType.COLLECTIBLE_GLITCHED_CROWN] = "Collectibles has 80% chance to turn to {{Collectible"..CollectibleType.COLLECTIBLE_GLITCHED_CROWN.."}}Glitched Crown",
        [CollectibleType.COLLECTIBLE_TWISTED_PAIR] = "↓ -40%{{Damage}}Damage down",
        [CollectibleType.COLLECTIBLE_ABYSS] = "↓ -10%{{Damage}}Damage down after consumed a collectible",
        [CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING] = "75% chance to fail the crafting",
        [CollectibleType.COLLECTIBLE_FLIP] = "50% chance to remove pedestal items",
        [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = "Reduces items' ID by 0-2 again randomly",
        [CollectibleType.COLLECTIBLE_GHOST_PEPPER] = "↓-8 {{Luck}}Luck down",
        [CollectibleType.COLLECTIBLE_HAEMOLACRIA] = "Piercing tears",
        [CollectibleType.COLLECTIBLE_ROCK_BOTTOM] = "↑ All stats get doubled, then no longer changes",
        [CollectibleType.COLLECTIBLE_HOLY_LIGHT] = "Lightbolts have only 33% player damage",
        
        [Collectibles.DarkRibbon.Item] = "Enemies die inside the halo spawn enemy black chargers",
        [Collectibles.VampireTooth.Item] = "All hearts run off slowly",
        [Collectibles.FanOfTheDead.Item] = "Revives at the last room",
        [Collectibles.SaucerRemote.Item] = "UFO will attack player",
        [Collectibles.D2147483647.Item] = "Can only select quality {{Quality0}} or {{Quality1}} items",
        [Collectibles.WildFury.Item] = "↓ Stats down instead after kills enemy",
        [Collectibles.PureFury.Item] = "↑ {{Damage}}x1.01 Damage up instead",
        [Collectibles.ExchangeTicket.Item] = "50% traders in the exchange transforms into Greeds",
        [Collectibles.CurseOfCentipede.Item] = "Also gives{{Collectible"..CollectibleType.COLLECTIBLE_SACRED_HEART.."}}Sacred Heart and {{Collectible"..CollectibleType.COLLECTIBLE_POLYPHEMUS.."}}Polyphemus",
        [Collectibles.ByteString.Item] = "All numbers affected by the above effects become 6",
        [Collectibles.MimicTear.Item] = "50% chance to remove the item instead of duplicating it",
        [CollectibleType.COLLECTIBLE_MISSING_NO] = "Won't meet quality {{Quality4}} items",
    },
    Modded = "↓ All stats down"
}
return EIDInfo;
