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