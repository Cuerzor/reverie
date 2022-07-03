local EntityTags = {
    Tags = {}
}


EntityTags.Tags.DiggerEnemies = {
    { Type = EntityType.ENTITY_LUMP },
    { Type = EntityType.ENTITY_PARA_BITE },
    { Type = EntityType.ENTITY_FRED },
    { Type = EntityType.ENTITY_ROUND_WORM },
    { Type = EntityType.ENTITY_NIGHT_CRAWLER },
    { Type = EntityType.ENTITY_ROUNDY },
    { Type = EntityType.ENTITY_ULCER },
    { Type = EntityType.ENTITY_TARBOY },
    { Type = EntityType.ENTITY_MR_MINE },
    { Type = EntityType.ENTITY_DEEP_GAPER },
    { Type = EntityType.ENTITY_FIRE_WORM },
    { Type = EntityType.ENTITY_MOLE },
    { Type = EntityType.ENTITY_HENRY },
    { Type = EntityType.ENTITY_NEEDLE },

    
    { Type = EntityType.ENTITY_PIN },
    { Type = EntityType.ENTITY_POLYCEPHALUS },
    { Type = EntityType.ENTITY_STAIN },
    { Type = EntityType.ENTITY_BIG_HORN },
}
EntityTags.Tags.ConvertToBlueSpiders = {

    { Type = EntityType.ENTITY_SPIDER },
    { Type = EntityType.ENTITY_STRIDER },
}
EntityTags.Tags.ConvertToBlueFlies = {

    { Type = EntityType.ENTITY_FLY },
    { Type = EntityType.ENTITY_ATTACKFLY },
    { Type = EntityType.ENTITY_RING_OF_FLIES },
    { Type = EntityType.ENTITY_SWARM },
    { Type = EntityType.ENTITY_ARMYFLY },
    { Type = EntityType.ENTITY_DART_FLY },
}
EntityTags.Tags.FlyEnemies = {
    { Type = EntityType.ENTITY_FLY },
    { Type = EntityType.ENTITY_ATTACKFLY },
    { Type = EntityType.ENTITY_POOTER },
    { Type = EntityType.ENTITY_MOTER },
    { Type = EntityType.ENTITY_RING_OF_FLIES },
    { Type = EntityType.ENTITY_ETERNALFLY },
    { Type = EntityType.ENTITY_DART_FLY },
    { Type = EntityType.ENTITY_SWARM },
    { Type = EntityType.ENTITY_HUSH_FLY },
    { Type = EntityType.ENTITY_ARMYFLY },
    { Type = EntityType.ENTITY_WILLO },

    { Type = EntityType.ENTITY_SUCKER },
    
    { Type = EntityType.ENTITY_BOOMFLY },

    { Type = EntityType.ENTITY_FULL_FLY },
    { Type = EntityType.ENTITY_FLY_L2 },
    { Type = EntityType.ENTITY_WILLO_L2 },

    { Type = EntityType.ENTITY_FLY_BOMB },
    { Type = EntityType.ENTITY_BABY_PLUM },
}

EntityTags.Tags.SpiderEnemies = {
    { Type = EntityType.ENTITY_HOPPER, Variant = 1 },

    { Type = EntityType.ENTITY_SPIDER },
    { Type = EntityType.ENTITY_BIGSPIDER },

    { Type = EntityType.ENTITY_BABY_LONG_LEGS },
    { Type = EntityType.ENTITY_CRAZY_LONG_LEGS },

    { Type = EntityType.ENTITY_SPIDER_L2 },

    { Type = EntityType.ENTITY_WALL_CREEP },
    { Type = EntityType.ENTITY_RAGE_CREEP },
    { Type = EntityType.ENTITY_BLIND_CREEP },

    { Type = EntityType.ENTITY_RAGLING },
    { Type = EntityType.ENTITY_TICKING_SPIDER },
    { Type = EntityType.ENTITY_BLISTER },
    { Type = EntityType.ENTITY_THE_THING },
    
    { Type = EntityType.ENTITY_STRIDER },
    { Type = EntityType.ENTITY_ROCK_SPIDER },
    { Type = EntityType.ENTITY_MIGRAINE },
    { Type = EntityType.ENTITY_SWARM_SPIDER },
    { Type = EntityType.ENTITY_REAP_CREEP },
    
    { Type = EntityType.ENTITY_BOIL, Variant = 2 },
    { Type = EntityType.ENTITY_WALKINGBOIL, Variant = 2 },
    { Type = EntityType.ENTITY_HOPPER, Variant = 2 },
 
}
EntityTags.Tags.BoneEnemies = {
    { Type = EntityType.ENTITY_BONY},
    { Type = EntityType.ENTITY_BLACK_BONY },

    { Type = EntityType.ENTITY_REVENANT },
    { Type = EntityType.ENTITY_MAZE_ROAMER },

    { Type = EntityType.ENTITY_MOMS_DEAD_HAND},
    { Type = EntityType.ENTITY_BIG_BONY },
    { Type = EntityType.ENTITY_DUSTY_DEATHS_HEAD },

    { Type = EntityType.ENTITY_BOOMFLY, Variant = 4 },
    { Type = EntityType.ENTITY_DEATHS_HEAD },
    { Type = EntityType.ENTITY_NECRO },
    { Type = EntityType.ENTITY_NEEDLE, Variant = 1 },
    { Type = EntityType.ENTITY_CLICKETY_CLACK },
    { Type = EntityType.ENTITY_POLYCEPHALUS, Variant = 1 },
    { Type = EntityType.ENTITY_THE_LAMB },
    { Type = EntityType.ENTITY_MEGA_SATAN_2 },
    { Type = EntityType.ENTITY_FORSAKEN },
 
}
EntityTags.Tags.PoopEnemies = {
    { Type = EntityType.ENTITY_DIP},

    { Type = EntityType.ENTITY_SQUIRT },
    { Type = EntityType.ENTITY_DINGA },
    { Type = EntityType.ENTITY_HARDY },
    { Type = EntityType.ENTITY_DRIP},
    { Type = EntityType.ENTITY_SPLURT},
    { Type = EntityType.ENTITY_DUMP},

    { Type = EntityType.ENTITY_GURGLING, Variant = 2},
    { Type = EntityType.ENTITY_DINGLE},
    { Type = EntityType.ENTITY_BROWNIE},
    { Type = EntityType.ENTITY_CLOG},
    { Type = EntityType.ENTITY_COLOSTOMIA},
 
}

EntityTags.Tags.CopyBlacklist = {
    {Type = EntityType.ENTITY_MEGA_SATAN},
    {Type = EntityType.ENTITY_MEGA_SATAN_2},
    {Type = EntityType.ENTITY_BEAST},
    {Type = EntityType.ENTITY_MOTHER},
    {Type = EntityType.ENTITY_DELIRIUM},
}

EntityTags.Tags.LastWillsBlacklist = {
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_THROWABLEBOMB},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_POOP},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_CHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_BOMBCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_SPIKEDCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_ETERNALCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_MIMICCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_OLDCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_WOODENCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_MEGACHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_HAUNTEDCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_LOCKEDCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_REDCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_MOMSCHEST, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_COLLECTIBLE, SubType = 0},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_COLLECTIBLE, SubType = CollectibleType.COLLECTIBLE_DADS_NOTE},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_SHOPITEM},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_TROPHY},
    {Type = EntityType.ENTITY_PICKUP, Variant = PickupVariant.PICKUP_BED},
}

function EntityTags:AddEntity(tag, type, variant, subtype)
    table.insert(self.Tags[tag], {Type = type, Variant = variant, SubType = subtype});
end

function EntityTags:EntityFits(entity, tag)
    
    for _, info in ipairs(EntityTags.Tags[tag]) do
        if (info.Condition and info.Condition(entity)) then
            return true;
        end
        if (info.Type == entity.Type) then
            if (not info.Variant or info.Variant == entity.Variant) then
                if (not info.SubType or info.SubType == entity.SubType) then
                    return true;
                end
            end
        end
    end
    return false;
end

return EntityTags;