local Database = {};
Database.PickupSprites = {
    [PickupVariant.PICKUP_HEART] = { -- Heart
        [HeartSubType.HEART_FULL] = "gfx/005.011_heart.anm2", -- Red Heart
        [HeartSubType.HEART_HALF] = "gfx/005.012_heart (half).anm2", -- Half Red Heart
        [HeartSubType.HEART_SOUL] = "gfx/005.013_heart (soul).anm2", -- Soul Heart
        [HeartSubType.HEART_HALF_SOUL] = "gfx/005.018_heart (halfsoul).anm2", -- Half Soul Heart
        [HeartSubType.HEART_BLACK] = "gfx/005.016_black heart.anm2", -- Black Heart
        [HeartSubType.HEART_ETERNAL] = "gfx/005.014_heart (eternal).anm2", -- Eternal Heart
        [HeartSubType.HEART_BLENDED] = "gfx/005.019_blended heart.anm2", -- Blended Heart
        [HeartSubType.HEART_BONE] = "gfx/005.01a_bone heart.anm2", -- Bone Heart
        [HeartSubType.HEART_DOUBLEPACK] = "gfx/005.015_double heart.anm2", -- Double Heart
        [HeartSubType.HEART_GOLDEN] = "gfx/005.017_goldheart.anm2", -- Golden Heart
        [HeartSubType.HEART_ROTTEN] = "gfx/005.01b_rotten heart.anm2", -- Rotten Heart
        [HeartSubType.HEART_SCARED] = "gfx/005.020_scared heart.anm2", -- Scared Heart
    },
    [PickupVariant.PICKUP_KEY] = { -- Key
        [KeySubType.KEY_NORMAL] = "gfx/005.031_key.anm2", -- Key
        [KeySubType.KEY_CHARGED] = "gfx/005.034_chargedkey.anm2", -- Charged Key
        [KeySubType.KEY_DOUBLEPACK] = "gfx/005.033_keyring.anm2", -- Double Key
        [KeySubType.KEY_GOLDEN] = "gfx/005.032_golden key.anm2", -- Golden Key
    },
    [PickupVariant.PICKUP_BOMB] = { -- Bomb
        [BombSubType.BOMB_NORMAL] = "gfx/005.041_bomb.anm2", -- Bomb
        [BombSubType.BOMB_DOUBLEPACK] = "gfx/005.042_double bomb.anm2", -- Double Bomb
        [BombSubType.BOMB_GIGA] = "gfx/005.047_giga bomb.anm2", -- Giga Bomb
        [BombSubType.BOMB_GOLDEN] = "gfx/005.043_golden bomb.anm2", -- Golden Bomb
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = { -- Battery
        [BatterySubType.BATTERY_NORMAL] = "gfx/005.090_littlebattery.anm2", -- Normal
        [BatterySubType.BATTERY_MICRO] = "gfx/005.090_microbattery.anm2", -- Micro
        [BatterySubType.BATTERY_MEGA] = "gfx/005.090_megabattery.anm2", -- Mega
        [BatterySubType.BATTERY_GOLDEN] = "gfx/005.090_golden battery.anm2", -- Golden
    },
    [PickupVariant.PICKUP_GRAB_BAG] = { -- Sack
        [SackSubType.SACK_NORMAL] = "gfx/005.069_grabbag.anm2", -- Normal
        [SackSubType.SACK_BLACK] = "gfx/005.069_black sack.anm2", -- Black
    },
    [PickupVariant.PICKUP_TAROTCARD] = { -- Cards and Runes
        [Card.CARD_FOOL] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_MAGICIAN] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_HIGH_PRIESTESS] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_EMPRESS] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_EMPEROR] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_HIEROPHANT] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_LOVERS] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_CHARIOT] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_JUSTICE] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_HERMIT] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_WHEEL_OF_FORTUNE] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_STRENGTH] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_HANGED_MAN] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_DEATH] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_TEMPERANCE] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_DEVIL] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_TOWER] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_STARS] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_MOON] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_SUN] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_JUDGEMENT] = "gfx/005.301_tarot card.anm2",
        [Card.CARD_WORLD] = "gfx/005.301_tarot card.anm2",
        -- Suit Cards
        [Card.CARD_CLUBS_2] ="gfx/005.302_suit card.anm2",
        [Card.CARD_DIAMONDS_2] ="gfx/005.302_suit card.anm2",
        [Card.CARD_SPADES_2] ="gfx/005.302_suit card.anm2",
        [Card.CARD_HEARTS_2] ="gfx/005.302_suit card.anm2",
        [Card.CARD_ACE_OF_CLUBS] ="gfx/005.302_suit card.anm2",
        [Card.CARD_ACE_OF_DIAMONDS] ="gfx/005.302_suit card.anm2",
        [Card.CARD_ACE_OF_SPADES] ="gfx/005.302_suit card.anm2",
        [Card.CARD_ACE_OF_HEARTS] ="gfx/005.302_suit card.anm2",
        [Card.CARD_JOKER] ="gfx/005.302_suit card.anm2",
        [Card.CARD_RULES] = "gfx/005.302_suit card.anm2",
        [Card.CARD_SUICIDE_KING] = "gfx/005.302_suit card.anm2",
        [Card.CARD_QUESTIONMARK] = "gfx/005.302_suit card.anm2",
        [Card.CARD_QUEEN_OF_HEARTS] = "gfx/005.302_suit card.anm2",

        -- Rune1
        [Card.RUNE_HAGALAZ] = "gfx/005.303_rune1.anm2",
        [Card.RUNE_JERA] = "gfx/005.303_rune1.anm2",
        [Card.RUNE_EHWAZ] = "gfx/005.303_rune1.anm2",
        [Card.RUNE_DAGAZ] = "gfx/005.303_rune1.anm2",

        -- Rune2
        [Card.RUNE_ANSUZ] = "gfx/005.304_rune2.anm2",
        [Card.RUNE_PERTHRO] = "gfx/005.304_rune2.anm2",
        [Card.RUNE_BERKANO] = "gfx/005.304_rune2.anm2",
        [Card.RUNE_ALGIZ] = "gfx/005.304_rune2.anm2",
        [Card.RUNE_BLANK] = "gfx/005.304_rune2.anm2",

        -- Black Rune
        [Card.RUNE_BLACK] = "gfx/005.307_blackrune.anm2",

        -- MTG Cards
        [Card.CARD_CHAOS] = "gfx/005.308_magic card.anm2",
        [Card.CARD_HUGE_GROWTH] = "gfx/005.308_magic card.anm2",
        [Card.CARD_ANCIENT_RECALL] = "gfx/005.308_magic card.anm2",
        [Card.CARD_ERA_WALK] = "gfx/005.308_magic card.anm2",

        -- Misc cards
        [Card.CARD_CREDIT] = "gfx/005.310_credit card.anm2",
        [Card.CARD_HUMANITY] = "gfx/005.309_card against humanity.anm2",
        [Card.CARD_GET_OUT_OF_JAIL] = "gfx/005.312_chance card.anm2",
        [Card.CARD_DICE_SHARD] = "gfx/005.306_diceshard.anm2",
        [Card.CARD_EMERGENCY_CONTACT] = "gfx/005.305_emergencycontact.anm2",
        [Card.CARD_HOLY] = "gfx/005.311_holy card.anm2",
        [Card.CARD_CRACKED_KEY] = "gfx/005.300.15_cracked key.anm2",
        [Card.RUNE_SHARD] = "gfx/005.313_rune shard.anm2",
        [Card.CARD_WILD] = "gfx/005.300.17_unus card.anm2",
        
        -- Reversed tarots
        [Card.CARD_REVERSE_FOOL] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_MAGICIAN] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_HIGH_PRIESTESS] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_EMPRESS] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_EMPEROR] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_HIEROPHANT] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_LOVERS] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_CHARIOT] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_JUSTICE] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_HERMIT] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_STRENGTH] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_HANGED_MAN] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_DEATH] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_TEMPERANCE] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_DEVIL] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_TOWER] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_STARS] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_MOON] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_SUN] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_JUDGEMENT] = "gfx/005.300.14_reverse tarot card.anm2",
        [Card.CARD_REVERSE_WORLD] = "gfx/005.300.14_reverse tarot card.anm2",

        [Card.CARD_SOUL_ISAAC] = "gfx/005.300.18_soul of isaac.anm2",
        [Card.CARD_SOUL_MAGDALENE] = "gfx/005.300.19_soul of magdalene.anm2",
        [Card.CARD_SOUL_CAIN] = "gfx/005.300.20_soul of cain.anm2",
        [Card.CARD_SOUL_JUDAS] = "gfx/005.300.21_soul of judas.anm2",
        [Card.CARD_SOUL_BLUEBABY] = "gfx/005.300.22_soul of blue baby.anm2",
        [Card.CARD_SOUL_EVE] = "gfx/005.300.23_soul of eve.anm2",
        [Card.CARD_SOUL_SAMSON] = "gfx/005.300.24_soul of samson.anm2",
        [Card.CARD_SOUL_AZAZEL] = "gfx/005.300.25_soul of azazel.anm2",
        [Card.CARD_SOUL_LAZARUS] = "gfx/005.300.26_soul of lazarus.anm2",
        [Card.CARD_SOUL_EDEN] = "gfx/005.300.27_soul of eden.anm2",
        [Card.CARD_SOUL_LOST] = "gfx/005.300.28_soul of the lost.anm2",
        [Card.CARD_SOUL_LILITH] = "gfx/005.300.29_soul of lilith.anm2",
        [Card.CARD_SOUL_KEEPER] = "gfx/005.300.30_soul of the keeper.anm2",
        [Card.CARD_SOUL_APOLLYON] = "gfx/005.300.31_soul of apollyon.anm2",
        [Card.CARD_SOUL_FORGOTTEN] = "gfx/005.300.32_soul of the forgotten.anm2",
        [Card.CARD_SOUL_BETHANY] = "gfx/005.300.33_soul of bethany.anm2",
        [Card.CARD_SOUL_JACOB] = "gfx/005.300.34_soul of jacob.anm2",
    },
    [PickupVariant.PICKUP_PILL] = { -- Pills
        [PillColor.PILL_BLUE_BLUE] = "gfx/005.071_pill blue-blue.anm2",
	    [PillColor.PILL_WHITE_BLUE] = "gfx/005.072_pill white-blue.anm2",
	    [PillColor.PILL_ORANGE_ORANGE] = "gfx/005.073_pill orange-orange.anm2",
	    [PillColor.PILL_WHITE_WHITE] = "gfx/005.074_pill white-white.anm2",
	    [PillColor.PILL_REDDOTS_RED] = "gfx/005.075_pill dots-red.anm2",
	    [PillColor.PILL_PINK_RED] = "gfx/005.076_pill pink-red.anm2",
	    [PillColor.PILL_BLUE_CADETBLUE] = "gfx/005.077_pill blue-cadetblue.anm2",
	    [PillColor.PILL_YELLOW_ORANGE] = "gfx/005.078_pill yellow-orange.anm2",
	    [PillColor.PILL_ORANGEDOTS_WHITE] = "gfx/005.079_pill dots-white.anm2",
	    [PillColor.PILL_WHITE_AZURE] = "gfx/005.080_pill white-azure.anm2",
	    [PillColor.PILL_BLACK_YELLOW] = "gfx/005.081_pill black-yellow.anm2",
	    [PillColor.PILL_WHITE_BLACK] = "gfx/005.082_pill white-black.anm2",
	    [PillColor.PILL_WHITE_YELLOW] = "gfx/005.083_pill white-yellow.anm2",
	    [PillColor.PILL_GOLD] = "gfx/005.084_pill gold-gold.anm2",

        
        [PillColor.PILL_BLUE_BLUE | PillColor.PILL_GIANT_FLAG] = "gfx/005.071_horse pill blue-blue.anm2",
	    [PillColor.PILL_WHITE_BLUE | PillColor.PILL_GIANT_FLAG] = "gfx/005.072_horse pill white-blue.anm2",
	    [PillColor.PILL_ORANGE_ORANGE | PillColor.PILL_GIANT_FLAG] = "gfx/005.073_horse pill orange-orange.anm2",
	    [PillColor.PILL_WHITE_WHITE | PillColor.PILL_GIANT_FLAG] = "gfx/005.074_horse pill white-white.anm2",
	    [PillColor.PILL_REDDOTS_RED | PillColor.PILL_GIANT_FLAG] = "gfx/005.075_horse pill dots-red.anm2",
	    [PillColor.PILL_PINK_RED | PillColor.PILL_GIANT_FLAG] = "gfx/005.076_horse pill pink-red.anm2",
	    [PillColor.PILL_BLUE_CADETBLUE | PillColor.PILL_GIANT_FLAG] = "gfx/005.077_horse pill blue-cadetblue.anm2",
	    [PillColor.PILL_YELLOW_ORANGE | PillColor.PILL_GIANT_FLAG] = "gfx/005.078_horse pill yellow-orange.anm2",
	    [PillColor.PILL_ORANGEDOTS_WHITE | PillColor.PILL_GIANT_FLAG] = "gfx/005.079_horse pill dots-white.anm2",
	    [PillColor.PILL_WHITE_AZURE | PillColor.PILL_GIANT_FLAG] = "gfx/005.080_horse pill white-azure.anm2",
	    [PillColor.PILL_BLACK_YELLOW | PillColor.PILL_GIANT_FLAG] = "gfx/005.081_horse pill black-yellow.anm2",
	    [PillColor.PILL_WHITE_BLACK | PillColor.PILL_GIANT_FLAG] = "gfx/005.082_horse pill white-black.anm2",
	    [PillColor.PILL_WHITE_YELLOW | PillColor.PILL_GIANT_FLAG] = "gfx/005.083_horse pill white-yellow.anm2",
	    [PillColor.PILL_GOLD | PillColor.PILL_GIANT_FLAG] = "gfx/005.084_horse pill gold-gold.anm2",
    }
}



return Database;