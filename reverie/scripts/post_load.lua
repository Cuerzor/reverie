local Database = THI.Shared.Database;
local EntityTags = THI.Shared.EntityTags;

local cardSprites = Database.PickupSprites[PickupVariant.PICKUP_TAROTCARD];
cardSprites[THI.Cards.SoulOfEika.ID] = "gfx/reverie/005.300.583_soul of eika.anm2";
cardSprites[THI.Cards.SoulOfSatori.ID] = "gfx/reverie/005.300.584_soul of satori.anm2";
cardSprites[THI.Cards.SoulOfSeija.ID] = "gfx/reverie/005.300.586_soul of seija.anm2";
cardSprites[THI.Cards.SoulOfSeija.ReversedID] = "gfx/reverie/005.300.587_soul of seija reversed.anm2";


local Note = THI.Bosses.ReverieNote
local Doremy = THI.GensouDream.Doremy;
EntityTags:AddEntity("CopyBlacklist", Note.Type, Note.Variant);
EntityTags:AddEntity("CopyBlacklist", Note.SekibankiDrone.Type, Note.SekibankiDrone.Variant);
EntityTags:AddEntity("CopyBlacklist", Note.HecatiaMoon.Type, Note.HecatiaMoon.Variant);
EntityTags:AddEntity("CopyBlacklist", Doremy.Type, Doremy.Variant);
EntityTags:AddEntity("RemoveBlacklist", Doremy.Type, Doremy.Variant);


EntityTags:AddEntity("LastWillsBlacklist", THI.Pickups.StarseekerBall.Type, THI.Pickups.StarseekerBall.Variant);
EntityTags:AddEntity("LastWillsBlacklist", THI.Pickups.FoodPickup.Type, THI.Pickups.FoodPickup.Variant);
EntityTags:AddEntity("LastWillsBlacklist", THI.Pickups.FoxsAdviceBottle.Type, THI.Pickups.FoxsAdviceBottle.Variant);


local Collectibles = THI.Collectibles;
THI.Trinkets.SymmetryOCD:AddWhitelistMultiple({
Collectibles.YinYangOrb.Item,
Collectibles.DYSSpring.Item,
Collectibles.DragonBadge.Item,
Collectibles.Koakuma.Item,
Collectibles.Grimoire.Item,
Collectibles.FrozenSakura.Item,
Collectibles.ChenBaby.Item,
Collectibles.ShanghaiDoll.Item,
Collectibles.FanOfTheDead.Item,
Collectibles.FriedTofu.Item,
Collectibles.Starseeker.Item,
Collectibles.Pathseeker.Item,
Collectibles.GourdShroom.Item,
Collectibles.BookOfYears.Item,
Collectibles.Illusion.Item,
Collectibles.TenguCamera.Item,
Collectibles.SunflowerPot.Item,
Collectibles.ContinueArcade.Item,
Collectibles.RodOfRemorse.Item,
Collectibles.SunnyFairy.Item,
Collectibles.LunarFairy.Item,
Collectibles.StarFairy.Item,
Collectibles.Onbashira.Item,
Collectibles.Escape.Item,
Collectibles.Keystone.Item,
Collectibles.BucketOfWisps.Item,
Collectibles.GreenEyedEnvy.Item,
Collectibles.PsycheEye.Item,
Collectibles.Technology666.Item,
Collectibles.ScaringUmbrella.Item,
Collectibles.Unzan.Item,
Collectibles.Pagota.Item,
Collectibles.D2147483647.Item,
Collectibles.EmptyBook.Item,
Collectibles.TheInfamies.Item,
Collectibles.SekibankisHead.Item,
Collectibles.DFlip.Item,
Collectibles.ThunderDrum.Item,
Collectibles.CarnivalHat.Item,
Collectibles.Hekate.Item,
Collectibles.DadsShares.Item,
Collectibles.GolemOfIsaac.Item,
Collectibles.BackDoor.Item,
Collectibles.FetusBlood.Item,
Collectibles.CockcrowWings.Item,
Collectibles.GamblingD6.Item,
Collectibles.RebelMechaCaller.Item,
Collectibles.DSiphon.Item,
Collectibles.FairyDust.Item,
Collectibles.Asthma.Item,
Collectibles.Dejavu.Item,
Collectibles.Jealousy.Item,
Collectibles.RainbowCard.Item})