local Pedia = Encyclopedia;
local Collectibles = THI.Collectibles;
local Pools = {
    [Collectibles.YinYangOrb.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.MarisasBroom.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_GOLDEN_CHEST,
        Pedia.ItemPools.POOL_WOODEN_CHEST
    },
    [Collectibles.DarkRibbon.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.DYSSpring.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.DragonBadge.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.Koakuma.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_BABY_SHOP,
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.Grimoire.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_LIBRARY,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.MaidSuit.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GOLDEN_CHEST
    },
    [Collectibles.VampireTooth.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.Destruction.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_GREED_CURSE
    },
    [Collectibles.DeletedErhu.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.FrozenSakura.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.ChenBaby.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP
    },
    [Collectibles.ShanghaiDoll.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GOLDEN_CHEST,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.MelancholicViolin.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.ManiacTrumpet.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.IllusionaryKeyboard.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.Roukanken.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.FanOfTheDead.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_OLD_CHEST,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.FriedTofu.Item] = 
    {
        Pedia.ItemPools.POOL_BOSS,
        Pedia.ItemPools.POOL_BEGGAR
    },
    [Collectibles.OneOfNineTails.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.Gap.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_OLD_CHEST,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.Starseeker.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.Pathseeker.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE
    },
    [Collectibles.GourdShroom.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.JarOfFireflies.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.SongOfNightbird.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_CURSE
    },
    [Collectibles.BookOfYears.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_LIBRARY,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.RabbitTrap.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP
    },
    [Collectibles.Illusion.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.PeerlessElixir.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_BEGGAR,
        Pedia.ItemPools.POOL_DEMON_BEGGAR
    },
    [Collectibles.DragonNeckJewel.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.BuddhasBowl.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.RobeOfFirerat.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.SwallowsShell.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.JeweledBranch.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.AshOfPhoenix.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE
    },
    [Collectibles.TenguCamera.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.SunflowerPot.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE
    },
    [Collectibles.ContinueArcade.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.RodOfRemorse.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_ANGEL
    },
    [Collectibles.IsaacsLastWills.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_OLD_CHEST,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.SunnyFairy.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.LunarFairy.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP
    },
    [Collectibles.StarFairy.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP
    },
    [Collectibles.LeafShield.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_WOODEN_CHEST
    },
    [Collectibles.BakedSweetPotato.Item] = 
    {
        Pedia.ItemPools.POOL_BOSS,
        Pedia.ItemPools.POOL_GREED_BOSS,
        Pedia.ItemPools.POOL_BEGGAR
    },
    [Collectibles.BrokenAmulet.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL
    },
    [Collectibles.ExtendingArm.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.WolfEye.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.Benediction.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.Onbashira.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_WOODEN_CHEST,
    },
    [Collectibles.YoungNativeGod.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP
    },
    [Collectibles.GeographicChain.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.RuneSword.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.Escape.Item] = 
    {
        Pedia.ItemPools.POOL_BOSS,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_BOSS,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.Keystone.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.AngelsRaiment.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.BucketOfWisps.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_WOODEN_CHEST
    },
    [Collectibles.PlagueLord.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ROTTEN_BEGGAR
    },
    [Collectibles.GreenEyedEnvy.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST
    },
    [Collectibles.OniHorn.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR
    },
    [Collectibles.PsycheEye.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.GuppysCorpseCart.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_RED_CHEST,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.Technology666.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL
    },
    [Collectibles.PsychoKnife.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL
    },
    [Collectibles.DowsingRods.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.ScaringUmbrella.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.Unzan.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE
    },
    [Collectibles.Pagota.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.SorcerersScroll.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.SaucerRemote.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.TenguCellphone.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.EtherealArm.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST
    },
    [Collectibles.MountainEar.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.ZombieInfestation.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_ROTTEN_BEGGAR
    },
    [Collectibles.WarpingHairpin.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP
    },
    [Collectibles.HolyThunder.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.GeomanticDetector.Item] = {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.Lightbombs.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL,
        Pedia.ItemPools.POOL_BOMB_BUM
    },
    [Collectibles.D2147483647.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_ULTRA_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.TheInfamies.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.EmptyBook.Item] = 
    {
        Pedia.ItemPools.POOL_LIBRARY
    },
    [Collectibles.SekibankisHead.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.SekibankisHead.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.DFlip.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.MiracleMallet.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL
    },
    [Collectibles.ThunderDrum.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.MiracleMalletReplica.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_BEGGAR,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.RuneCape.Item] = 
    {
        Pedia.ItemPools.POOL_BOSS,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_GREED_BOSS,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.LunaticGun.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.ViciousCurse.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST
    },
    [Collectibles.CarnivalHat.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.PureFury.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_ULTRA_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.Hekate.Item] = 
    {
        Pedia.ItemPools.POOL_PLANETARIUM
    },
    [Collectibles.DadsShares.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_OLD_CHEST
    },
    [Collectibles.MomsIOU.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_OLD_CHEST
    },
    [Collectibles.YamanbasChopper.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.GolemOfIsaac.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET
    },
    [Collectibles.DancerServants.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_BABY_SHOP
    },
    [Collectibles.BackDoor.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE
    },
    [Collectibles.FetusBlood.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR,
        Pedia.ItemPools.POOL_ULTRA_SECRET,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_GREED_DEVIL
    },
    [Collectibles.CockcrowWings.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.KiketsuBlackmail.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR
    },
    [Collectibles.CarvingTools.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_GOLDEN_CHEST,
        Pedia.ItemPools.POOL_CRANE_GAME
        
    },
    [Collectibles.BrutalHorseshoe.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR
    },
    [Collectibles.Hunger.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.SakeOfForgotten.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_SECRET
    },
    [Collectibles.GamblingD6.Item] = {
        
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.YamawarosCrate.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP,
        Pedia.ItemPools.POOL_WOODEN_CHEST
    },
    [Collectibles.DelusionPipe.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_DEMON_BEGGAR
    },
    [Collectibles.SoulMagatama.Item] = 
    {
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.FoxInTube.Item] = 
    {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_RED_CHEST
    },
    [Collectibles.DaitenguTelescope.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.ExchangeTicket.Item] = 
    {
        Pedia.ItemPools.POOL_SHOP,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.CurseOfCentipede.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET
    },
    [Collectibles.RebelMechaCaller.Item] = 
    {
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_GREED_DEVIL,
        Pedia.ItemPools.POOL_ULTRA_SECRET,
        Pedia.ItemPools.POOL_CRANE_GAME
    },
    [Collectibles.DSiphon.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_SHOP
    },
    [Collectibles.DreamSoul.Item] = 
    {
    },
    [Collectibles.ParasiticMushroom.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE
    },
    [Collectibles.FairyDust.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.SpiritCannon.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_ANGEL,
        Pedia.ItemPools.POOL_GREED_ANGEL
    },
    [Collectibles.DaggerOfServants.Item] = 
    {
        Pedia.ItemPools.POOL_RED_CHEST,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_DEVIL,
        Pedia.ItemPools.POOL_DEMON_BEGGAR,
        Pedia.ItemPools.POOL_ULTRA_SECRET,
    },
    [Collectibles.Asthma.Item] = 
    {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_GREED_TREASURE,
    },
    [Collectibles.ByteString.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_GREED_SECRET,
    },
    [Collectibles.Dejavu.Item] = 
    {
        Pedia.ItemPools.POOL_SECRET
    },
    [Collectibles.Jealousy.Item] = {
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_RED_CHEST,
    },
    [Collectibles.EyeOfChimera.Item] = {
        Pedia.ItemPools.POOL_TREASURE,
        Pedia.ItemPools.POOL_SECRET,
        Pedia.ItemPools.POOL_CURSE,
        Pedia.ItemPools.POOL_CRANE_GAME,
        Pedia.ItemPools.POOL_GREED_TREASURE,
        Pedia.ItemPools.POOL_GREED_SECRET,
        Pedia.ItemPools.POOL_GREED_CURSE,
        Pedia.ItemPools.POOL_ROTTEN_BEGGAR,
    },
}
return Pools;