local Collectibles = CuerLib.Collectibles;
local CompareEntity = CuerLib.Detection.CompareEntity;
local Actives = CuerLib.Actives;
local DFlip = ModItem("D Flip", "DFLIP");

local config = Isaac.GetItemConfig();
DFlip.FixedPairs = {
    --Sad Onion - Dead Onion
    {{5,100,CollectibleType.COLLECTIBLE_SAD_ONION}, {5,100,CollectibleType.COLLECTIBLE_DEAD_ONION}},
    --Cricket's Head - Cricket's Body
    {{5,100,CollectibleType.COLLECTIBLE_CRICKETS_HEAD}, {5,100,CollectibleType.COLLECTIBLE_CRICKETS_BODY}},
    --Brother Bobby - Sister Maggy
    {{5,100,CollectibleType.COLLECTIBLE_BROTHER_BOBBY}, {5,100,CollectibleType.COLLECTIBLE_SISTER_MAGGY}},
    --1UP! - Magic Mushroom
    {{5,100,CollectibleType.COLLECTIBLE_1UP}, {5,100,CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM}},
    --Bible - Satanic Bible
    {{5,100,CollectibleType.COLLECTIBLE_BIBLE}, {5,100,CollectibleType.COLLECTIBLE_SATANIC_BIBLE}},
    --Guppy's Head - Tammy's Head
    {{5,100,CollectibleType.COLLECTIBLE_GUPPYS_HEAD}, {5,100,CollectibleType.COLLECTIBLE_TAMMYS_HEAD}},
    --Cain's Other Eye - Cain's Eye
    {{5,100,CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE}, {5,350,TrinketType.TRINKET_CAINS_EYE}},
    --Goat Head - Eucharist
    {{5,100,CollectibleType.COLLECTIBLE_GOAT_HEAD}, {5,100,CollectibleType.COLLECTIBLE_EUCHARIST}},
    --Bursting Sack - Juicy Sack
    {{5,100,CollectibleType.COLLECTIBLE_BURSTING_SACK}, {5,100,CollectibleType.COLLECTIBLE_JUICY_SACK}},
    --Trisagon - Brimstone
    {{5,100,CollectibleType.COLLECTIBLE_TRISAGION}, {5,100,CollectibleType.COLLECTIBLE_BRIMSTONE}},
    --Compound Fracture - Brittle Bones
    {{5,100,CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE}, {5,100,CollectibleType.COLLECTIBLE_BRITTLE_BONES}},
    --Holy Light - Explosivo
    {{5,100,CollectibleType.COLLECTIBLE_HOLY_LIGHT}, {5,100,CollectibleType.COLLECTIBLE_EXPLOSIVO}},
    --Lord of the Pit - Redemption
    {{5,100,CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT}, {5,100,CollectibleType.COLLECTIBLE_REDEMPTION}},
    --Wicked Crown - Holy Crown
    {{5,350,TrinketType.TRINKET_WICKED_CROWN}, {5,350,TrinketType.TRINKET_HOLY_CROWN}},
    --A Lighter - Ice Cube
    {{5,350,TrinketType.TRINKET_LIGHTER}, {5,350,TrinketType.TRINKET_ICE_CUBE}},
    --Blessed Penny - Cursed Penny
    {{5,350,TrinketType.TRINKET_BLESSED_PENNY}, {5,350,TrinketType.TRINKET_CURSED_PENNY}},
    --20/20 - Broken Glasses
    {{5,100,CollectibleType.COLLECTIBLE_20_20}, {5,350,TrinketType.TRINKET_BROKEN_GLASSES}},
    --Lump of Coal - Proptosis
    {{5,100,CollectibleType.COLLECTIBLE_LUMP_OF_COAL}, {5,100,CollectibleType.COLLECTIBLE_PROPTOSIS}},
    --Lump of Coal - Proptosis
    {{5,100,CollectibleType.COLLECTIBLE_INFAMY}, {5,100,CollectibleType.COLLECTIBLE_ISAACS_HEART}},
    --Halo - Pentagram
    {{5,100,CollectibleType.COLLECTIBLE_HALO}, {5,100,CollectibleType.COLLECTIBLE_PENTAGRAM}},
    --Magneto - Strange Attractor
    {{5,100,CollectibleType.COLLECTIBLE_MAGNETO}, {5,100,CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR}},
    --Hourglass - Hourglass
    {{5,100,CollectibleType.COLLECTIBLE_HOURGLASS}, {5,100,CollectibleType.COLLECTIBLE_HOURGLASS}},
    --Chocalate Milk - Soy Milk
    {{5,100,CollectibleType.COLLECTIBLE_CHOCOLATE_MILK}, {5,100,CollectibleType.COLLECTIBLE_SOY_MILK}},
    --Roid Rage - Growth Hormones
    {{5,100,CollectibleType.COLLECTIBLE_ROID_RAGE}, {5,100,CollectibleType.COLLECTIBLE_GROWTH_HORMONES}},
    --Mini Mush - Mega Mush
    {{5,100,CollectibleType.COLLECTIBLE_MINI_MUSH}, {5,100,CollectibleType.COLLECTIBLE_MEGA_MUSH}},
    --PHD - FALSE PHD
    {{5,100,CollectibleType.COLLECTIBLE_PHD}, {5,100,CollectibleType.COLLECTIBLE_FALSE_PHD}},
    --Wafer - Wafer
    {{5,100,CollectibleType.COLLECTIBLE_WAFER}, {5,100,CollectibleType.COLLECTIBLE_WAFER}},
    --Guardian Angel - Demon Baby
    {{5,100,CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL}, {5,100,CollectibleType.COLLECTIBLE_DEMON_BABY}},
    --Odd Mushroom (Thin) - Odd Mushroom (Large)
    {{5,100,CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN}, {5,100,CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE}},
    --Forget Me Now - Plan C
    {{5,100,CollectibleType.COLLECTIBLE_FORGET_ME_NOW}, {5,100,CollectibleType.COLLECTIBLE_PLAN_C}},
    --Razor Blade - Dull Razor
    {{5,100,CollectibleType.COLLECTIBLE_RAZOR_BLADE}, {5,100,CollectibleType.COLLECTIBLE_DULL_RAZOR}},
    --A Pony - White Pony
    {{5,100,CollectibleType.COLLECTIBLE_PONY}, {5,100,CollectibleType.COLLECTIBLE_WHITE_PONY}},
    --Remote Detonator - Tear Detonator
    {{5,100,CollectibleType.COLLECTIBLE_REMOTE_DETONATOR}, {5,100,CollectibleType.COLLECTIBLE_TEAR_DETONATOR}},
    --Speed Ball - Euthanasia
    {{5,100,CollectibleType.COLLECTIBLE_SPEED_BALL}, {5,100,CollectibleType.COLLECTIBLE_EUTHANASIA}},
    --Notched Axe - Dataminer
    {{5,100,CollectibleType.COLLECTIBLE_NOTCHED_AXE}, {5,100,CollectibleType.COLLECTIBLE_DATAMINER}},
    --Infestation - Infestation II
    {{5,100,CollectibleType.COLLECTIBLE_INFESTATION}, {5,100,CollectibleType.COLLECTIBLE_INFESTATION_2}},
    --Bloody Lust - Anemic
    {{5,100,CollectibleType.COLLECTIBLE_BLOODY_LUST}, {5,100,CollectibleType.COLLECTIBLE_ANEMIC}},
    --The Candle - Red Candle
    {{5,100,CollectibleType.COLLECTIBLE_CANDLE}, {5,100,CollectibleType.COLLECTIBLE_RED_CANDLE}},
    --Iron Bar - Midas' Touch
    {{5,100,CollectibleType.COLLECTIBLE_IRON_BAR}, {5,100,CollectibleType.COLLECTIBLE_MIDAS_TOUCH}},
    --Cube of Meat - Ball of Bandages
    {{5,100,CollectibleType.COLLECTIBLE_CUBE_OF_MEAT}, {5,100,CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES}},
    --Anti-Gravity - Black Hole
    {{5,100,CollectibleType.COLLECTIBLE_ANTI_GRAVITY}, {5,100,CollectibleType.COLLECTIBLE_BLACK_HOLE}},
    --Purity - Black Lotus
    {{5,100,CollectibleType.COLLECTIBLE_PURITY}, {5,100,CollectibleType.COLLECTIBLE_BLACK_LOTUS}},
    --Stop Watch - Broken Watch
    {{5,100,CollectibleType.COLLECTIBLE_STOP_WATCH}, {5,100,CollectibleType.COLLECTIBLE_BROKEN_WATCH}},
    --Key Piece 1 - Key Piece 2
    {{5,100,CollectibleType.COLLECTIBLE_KEY_PIECE_1}, {5,100,CollectibleType.COLLECTIBLE_KEY_PIECE_2}},
    --Knife Piece 1 - Knife Piece 2
    {{5,100,CollectibleType.COLLECTIBLE_KNIFE_PIECE_1}, {5,100,CollectibleType.COLLECTIBLE_KNIFE_PIECE_2}},
    --Trinity Shield - Spirit Sword
    {{5,100,CollectibleType.COLLECTIBLE_TRINITY_SHIELD}, {5,100,CollectibleType.COLLECTIBLE_SPIRIT_SWORD}},
    --Missing Page - Missing Page 2
    {{5,350,TrinketType.TRINKET_MISSING_PAGE}, {5,100,CollectibleType.COLLECTIBLE_MISSING_PAGE_2}},
    --Clear Rune - Black Rune
    {{5,100,CollectibleType.COLLECTIBLE_CLEAR_RUNE}, {5,300,Card.RUNE_BLACK}},
    --Butter Bean - Wait What?
    {{5,100,CollectibleType.COLLECTIBLE_BUTTER_BEAN}, {5,100,CollectibleType.COLLECTIBLE_WAIT_WHAT}},
    --Cancer - Cancer
    {{5,100,CollectibleType.COLLECTIBLE_CANCER}, {5,100,CollectibleType.COLLECTIBLE_CANCER}},
    --Judas' Shadow - My Shadow
    {{5,100,CollectibleType.COLLECTIBLE_JUDAS_SHADOW}, {5,100,CollectibleType.COLLECTIBLE_MY_SHADOW}},
    --Dad's Key - Mom's Key
    {{5,100,CollectibleType.COLLECTIBLE_DADS_KEY}, {5,100,CollectibleType.COLLECTIBLE_MOMS_KEY}},
    --Polaroid - Negative
    {{5,100,CollectibleType.COLLECTIBLE_POLAROID}, {5,100,CollectibleType.COLLECTIBLE_NEGATIVE}},
    --Glass Cannon - Broken Glass Cannon
    {{5,100,CollectibleType.COLLECTIBLE_GLASS_CANNON}, {5,100,CollectibleType.COLLECTIBLE_BROKEN_GLASS_CANNON}},
    --Yum Heart - Yuck Heart
    {{5,100,CollectibleType.COLLECTIBLE_YUM_HEART}, {5,100,CollectibleType.COLLECTIBLE_YUCK_HEART}},
    --Incubus - Succubus
    {{5,100,CollectibleType.COLLECTIBLE_INCUBUS}, {5,100,CollectibleType.COLLECTIBLE_SUCCUBUS}},
    --Restock - Restock
    {{5,100,CollectibleType.COLLECTIBLE_RESTOCK}, {5,100,CollectibleType.COLLECTIBLE_RESTOCK}},
    --Contagion - Toxic Shock
    {{5,100,CollectibleType.COLLECTIBLE_CONTAGION}, {5,100,CollectibleType.COLLECTIBLE_TOXIC_SHOCK}},
    --Void - Abyss
    {{5,100,CollectibleType.COLLECTIBLE_VOID}, {5,100,CollectibleType.COLLECTIBLE_ABYSS}},
    --Chaos - Chaos
    {{5,100,CollectibleType.COLLECTIBLE_CHAOS}, {5,100,CollectibleType.COLLECTIBLE_CHAOS}},
    --Glowing Hourglass - Glowing Hourglass
    {{5,100,CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS}, {5,100,CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS}},
    --Cambion Conception - Immaculate Conception
    {{5,100,CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION}, {5,100,CollectibleType.COLLECTIBLE_IMMACULATE_CONCEPTION}},
    --Crown of Light - Dark Prince's Crown
    {{5,100,CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT}, {5,100,CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN}},
    --Ghost Pepper - Bird's Eye
    {{5,100,CollectibleType.COLLECTIBLE_GHOST_PEPPER}, {5,100,CollectibleType.COLLECTIBLE_BIRDS_EYE}},
    --Duality - Duality
    {{5,100,CollectibleType.COLLECTIBLE_DUALITY}, {5,100,CollectibleType.COLLECTIBLE_DUALITY}},
    --Mom's Ring - Dad's Ring
    {{5,100,CollectibleType.COLLECTIBLE_MOMS_RING}, {5,100,CollectibleType.COLLECTIBLE_DADS_RING}},
    --Immaculate Heart - Heartbreak
    {{5,100,CollectibleType.COLLECTIBLE_IMMACULATE_HEART}, {5,100,CollectibleType.COLLECTIBLE_HEARTBREAK}},
    --Red Key - Blue Key
    {{5,100,CollectibleType.COLLECTIBLE_RED_KEY}, {5,350,TrinketType.TRINKET_BLUE_KEY}},
    --Venus - Mars
    {{5,100,CollectibleType.COLLECTIBLE_VENUS}, {5,100,CollectibleType.COLLECTIBLE_MARS}},
    --Teleport! - Teleport 2.0
    {{5,100,CollectibleType.COLLECTIBLE_TELEPORT}, {5,100,CollectibleType.COLLECTIBLE_TELEPORT_2}},
    --Spirit Shackles - Samson's Chains
    {{5,100,CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES}, {5,100,CollectibleType.COLLECTIBLE_SAMSONS_CHAINS}},
    --Hungry Soul - Purgatory
    {{5,100,CollectibleType.COLLECTIBLE_HUNGRY_SOUL}, {5,100,CollectibleType.COLLECTIBLE_PURGATORY}},
    --Blue Map - Treasure Map
    {{5,100,CollectibleType.COLLECTIBLE_BLUE_MAP}, {5,100,CollectibleType.COLLECTIBLE_TREASURE_MAP}},
    --Sol - Luna
    {{5,100,CollectibleType.COLLECTIBLE_SOL}, {5,100,CollectibleType.COLLECTIBLE_LUNA}},
    --Candy Heart - Soul Locket
    {{5,100,CollectibleType.COLLECTIBLE_CANDY_HEART}, {5,100,CollectibleType.COLLECTIBLE_SOUL_LOCKET}},
    --Book of Virtues - Book of Sin
    {{5,100,CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES}, {5,100,CollectibleType.COLLECTIBLE_BOOK_OF_SIN}},
    --Death Certificate - Nothing
    {{5,100,CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE}, {5,100, CollectibleType.COLLECTIBLE_BIRTHRIGHT}},
    --Flip - Flip
    {{5,100,CollectibleType.COLLECTIBLE_FLIP}, {5,100, CollectibleType.COLLECTIBLE_FLIP}},
    --Rock Bottom - The Stairway
    {{5,100,CollectibleType.COLLECTIBLE_ROCK_BOTTOM}, {5,100,CollectibleType.COLLECTIBLE_STAIRWAY}},

}

function DFlip.AddFixedPair(type1, variant1, subType1, type2, variant2, subType2)
    local pair = {{type1, variant1, subType1}, {type2, variant2, subType2}};
    table.insert(DFlip.FixedPairs, pair);
end

local function GetNotFixedCollectibles()
    local fixed = {};
    
    for _, pair in pairs(DFlip.FixedPairs) do
        local item1 = pair[1];
        local item2 = pair[2];
        if (item1[1] == 5 and item1[2] == 100) then
            local id = item1[3];
            if (id > 0) then
                fixed[id] = true;
            end
        end
        if (item2[1] == 5 and item2[2] == 100) then
            local id = item2[3];
            if (id > 0) then
                fixed[id] = true;
            end
        end
    end
    local greed = THI.Game:IsGreedMode();
    local function condition(id)
        local conf = config:GetCollectible(id);
        if (not conf or conf:HasTags(ItemConfig.TAG_QUEST) or conf.Hidden) then
            return false;
        end
        if (greed and conf:HasTags(ItemConfig.TAG_NO_GREED)) then
            return false;
        end
        if (fixed[id]) then
            return false;
        end
        return true;
    end
    return Collectibles.FindCollectibles(condition);
end
function DFlip.GetPairs(seed)
    local notFixed = GetNotFixedCollectibles();
    local rng = RNG();
    rng:SetSeed(seed, 0);
    local result = {};
    while (#notFixed > 1) do
        local index1 = rng:RandomInt(#notFixed) + 1;
        local item1 = notFixed[index1];
        table.remove(notFixed, index1);
        local index2 = rng:RandomInt(#notFixed) + 1;
        local item2 = notFixed[index2];
        table.remove(notFixed, index2);

        local pair = {{5, 100, item1}, {5, 100, item2}};
        table.insert(result, pair);
    end

    if (#notFixed == 1) then
        local item = notFixed[1];
        table.remove(notFixed, 1);
        local pair = {{5, 100, item}, {5, 100, item}};
        table.insert(result, pair);
    end
    return result;
end

DFlip.Pairs = {}
if (THI.Game:GetFrameCount() > 0) then
    local game = THI.Game;
    local seeds = game:GetSeeds();
    DFlip.Pairs = DFlip.GetPairs(seeds:GetStartSeed());
end


function DFlip.GetAnother(type, variant, subtype)
    for _, pair in pairs(DFlip.FixedPairs) do
        local item1 = pair[1];
        local item2 = pair[2];
        if (item1[1] == type and item1[2] == variant and item1[3] == subtype) then
            return item2;
        end
        if (item2[1] == type and item2[2] == variant and item2[3] == subtype) then
            return item1;
        end
    end
    for _, pair in pairs(DFlip.Pairs) do
        local item1 = pair[1];
        local item2 = pair[2];
        if (item1[1] == type and item1[2] == variant and item1[3] == subtype) then
            return item2;
        end
        if (item2[1] == type and item2[2] == variant and item2[3] == subtype) then
            return item1;
        end
    end
    return nil;
end


local function UseDFlip(mod, item, rng, player, flags, slot, vardata)
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        local type = ent.Type;
        local variant = ent.Variant;
        local subType = ent.SubType;
        local canRoll = false;
        if (variant == PickupVariant.PICKUP_TAROTCARD) then
            if (subType >= Card.CARD_FOOL and subType <= Card.CARD_WORLD) then
                subType = subType + Card.CARD_REVERSE_FOOL - Card.CARD_FOOL ;
                canRoll = true;
            elseif (subType >= Card.CARD_REVERSE_FOOL and subType <= Card.CARD_REVERSE_WORLD) then
                subType = subType - (Card.CARD_REVERSE_FOOL - Card.CARD_FOOL);
                canRoll = true;
            end
        end
        local another = DFlip.GetAnother(type, variant, subType);

        if (another) then
            type = another[1];
            variant = another[2];
            subType = another[3];
            canRoll = true;
        end

        local pickup = ent:ToPickup();

        
        if ((pickup.Variant == 100) and pickup.SubType <= 0) then
            canRoll = false;
        end

        if (canRoll) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil);
            if (subType < 0) then
                pickup:Remove();
            else
                pickup:Morph(type, variant, subType, true, true, true);
            end
        end
    end
    if (Actives.CanSpawnWisp(player, flags)) then
        local spawn = true;
        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, DFlip.Item)) do
            if (CompareEntity(ent:ToFamiliar().Player, player)) then
                spawn = false;
                ent:Kill();
            end
        end
        if (spawn) then
            for i = 1, 3 do
                player:AddWisp(DFlip.Item, player.Position);
            end
        end
    end
    return {ShowAnim = true};
end
DFlip:AddCallback(ModCallbacks.MC_USE_ITEM, UseDFlip, DFlip.Item);

local function PostGameStarted(mod, isContinued)
    local game = THI.Game;
    local seeds = game:GetSeeds();
    DFlip.Pairs = DFlip.GetPairs(seeds:GetStartSeed());
end
DFlip:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted);

return DFlip;