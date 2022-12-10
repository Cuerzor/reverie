local Chain = ModItem("Geographic Chain", "GEOGROPHIC_CHAIN");

Chain.ChangeToRock = {
    {Type = GridEntityType.GRID_ROCKB}, 
    {Type = GridEntityType.GRID_PILLAR}, 
}

Chain.Kills = {
    -- Traps
    { Type = EntityType.ENTITY_STONEHEAD }, -- Stone Heads (Will Revive)
    { Type = EntityType.ENTITY_CONSTANT_STONE_SHOOTER },  -- Stone Shooters (Will Revive)
    { Type = EntityType.ENTITY_STONE_EYE }, -- Stone Eye (Will Revive)
    { Type = EntityType.ENTITY_BRIMSTONE_HEAD }, -- Brimstone Head (Will Revive)
    { Type = EntityType.ENTITY_GAPING_MAW },    -- Attraction Head (Will Revive)
    { Type = EntityType.ENTITY_BROKEN_GAPING_MAW }, -- Broken Attraction Head (Will Revive)
    { Type = EntityType.ENTITY_BOMB_GRIMACE },  -- Bomb Grimace
    { Type = EntityType.ENTITY_QUAKE_GRIMACE }, -- Quake Grimace (Will Revive)
    { Type = EntityType.ENTITY_SPIKEBALL }, -- Corpse Spike Balls (Will Revive)
    { Type = EntityType.ENTITY_GIDEON }, -- The Great Gideon
    { Type = EntityType.ENTITY_BALL_AND_CHAIN }, -- Ball and Chain  (Will Revive)
    { Type = EntityType.ENTITY_MOCKULUS },  -- Mockulus Eye

    -- Hosts
    { Type = EntityType.ENTITY_HOST, Variant = 0 }, -- Host
    { Type = EntityType.ENTITY_HOST, Variant = 3 }, -- Hard Host
    { Type = EntityType.ENTITY_MOBILE_HOST },   -- Mobile Host
    { Type = EntityType.ENTITY_FLOATING_HOST }, -- Float Host
    -- Masks
    { Type = EntityType.ENTITY_MASK },  -- Masks
    { Type = EntityType.ENTITY_MASK_OF_INFAMY },    -- Mask of Infamy
    { Type = EntityType.ENTITY_VISAGE, Variant = 1 }, -- Visage Mask
    -- Spike Blocks
    { Type = EntityType.ENTITY_POKY },  -- Spike Blocks (Will Revive)
    { Type = EntityType.ENTITY_GRUDGE },  -- Grudge Spike Block (Will Revive)
    -- Death's Head
    { Type = EntityType.ENTITY_DEATHS_HEAD }, -- Death's Head
    { Type = EntityType.ENTITY_DEATHS_HEAD, Variant = 2 }, -- Cursed Death's Head
    { Type = EntityType.ENTITY_DEATHS_HEAD, Variant = 3 }, -- Brimstone Death's Head
    { Type = EntityType.ENTITY_DUSTY_DEATHS_HEAD }, -- Dusty Death's Head
    -- Misc
    { Type = EntityType.ENTITY_PEEP, Variant = 10 }, -- Peep Eye
    { Type = EntityType.ENTITY_PEEP, Variant = 11 }, -- Bloat Eye
    { Type = EntityType.ENTITY_GEMINI, Variant = 12 }, -- The Blighted Ovum Baby
    { Type = EntityType.ENTITY_SINGE, Variant = 1 }, -- Singe's Ball
    { Type = EntityType.ENTITY_LARRYJR, Variant = 2 }, -- Tuff Twin
    { Type = EntityType.ENTITY_LARRYJR, Variant = 3 },  -- The Shell
    { Type = EntityType.ENTITY_ETERNALFLY },    -- Eternal Fly
    { Type = EntityType.ENTITY_STONEY },    -- Stoney
    { Condition = function(entity) 
        local immortal = THI.Monsters.Immortal
        return entity.Type == immortal.Type  and entity.Variant == immortal.Variant;
    end },  -- Immortal (Mod Monster)
    { Condition = function(entity) 
        local spirit = THI.Monsters.EvilSpirit
        return entity.Type == spirit.Type  and entity.Variant == spirit.Variant;
    end },  -- Evil Spirit (Mod Monster)
}


Chain.WhiteList = {
    {Type = GridEntityType.GRID_LOCK}, 
    {Type = GridEntityType.GRID_POOP}, 
    {Type = GridEntityType.GRID_ROCK}, 
    {Type = GridEntityType.GRID_ROCKB},
    {Type = GridEntityType.GRID_ROCKT},
    {Type = GridEntityType.GRID_ROCK_ALT}, 
    {Type = GridEntityType.GRID_ROCK_ALT2}, 
    {Type = GridEntityType.GRID_ROCK_BOMB}, 
    {Type = GridEntityType.GRID_ROCK_GOLD}, 
    {Type = GridEntityType.GRID_ROCK_SPIKED}, 
    {Type = GridEntityType.GRID_ROCK_SS}, 
    {Type = GridEntityType.GRID_SPIDERWEB}, 
    {Type = GridEntityType.GRID_STATUE}, 
    {Type = GridEntityType.GRID_TNT}, 
}

local function PostUseChain(mod, item, rng, player, flags, slot, varData)

    local room = Game():GetRoom();
    local width = room:GetGridWidth();
    local height = room:GetGridHeight();
    for x = 1, width - 1 do
        for y = 1, height - 1 do
            local index = x + y * width;
            local gridEntity = room:GetGridEntity(index);
            if (gridEntity) then
                local type = gridEntity:GetType();
                local variant = gridEntity:GetVariant();
                local changeToRock = false;
                for i, v in ipairs(Chain.ChangeToRock) do
                    if (type == v.Type and (not v.Variant or v.Variant == variant)) then
                        changeToRock = true;
                        break;
                    end
                end
                if (changeToRock) then
                    gridEntity:SetType(GridEntityType.GRID_ROCK);
                    gridEntity:SetVariant(0);
                    type = GridEntityType.GRID_ROCK;
                    variant = 0;
                elseif (type == GridEntityType.GRID_LOCK) then
                    if (gridEntity.State == 0) then
                        gridEntity:GetSprite():Play("Breaking");
                        gridEntity:GetSprite():SetFrame(20);
                        gridEntity.State = 1;
                    end
                end

                if (type == GridEntityType.GRID_PIT) then
                    if (gridEntity.State == 0) then
                        local pit = gridEntity:ToPit();
                        pit:MakeBridge(nil);
                    end
                else
                    local whitelist = false;
                    for i, info in ipairs(Chain.WhiteList) do
                        if (info.Type == type) then
                            whitelist = true;
                            break;
                        end
                    end
                    if (whitelist) then
                        gridEntity:Hurt(10000);
                        gridEntity:Destroy(false);
                    end
                end
            end
        end
    end

    -- Kills.
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            
            local canKill = false;
            for _, info in ipairs(Chain.Kills) do
                if (info.Condition and info.Condition(ent)) then
                    canKill = true;
                    break;
                end
                if (info.Type == ent.Type) then
                    if (not info.Variant or info.Variant == ent.Variant) then
                        canKill = true;
                        break;
                    end
                end
            end
            if (canKill) then
                ent:Kill();
            end
        end
    end

    Game():ShakeScreen(15);
    THI.SFXManager:Play(SoundEffect.SOUND_ANIMA_TRAP);

    return {ShowAnim = true}
end
Chain:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseChain, Chain.Item);

local function EvaluateCache(mod, player, flags)
    if (flags == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + player:GetCollectibleNum(Chain.Item) * 2;
    end
end
Chain:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

local function PostGainChain(mod, player, item, count ,touched)
    player:AddCacheFlags(CacheFlag.CACHE_LUCK);
    player:EvaluateItems();
end
Chain:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainChain, Chain.Item);

return Chain;