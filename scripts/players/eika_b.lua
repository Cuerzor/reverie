local Lib = CuerLib;
local Consts = Lib.Consts;
local Stats = Lib.Stats
local EikaB = ModPlayer("Tainted Eika", true, "EikaB");

local creepRNG = RNG();
local fetusBloodItem = nil

function EikaB:PostPlayerInit(player)
    if (player:GetPlayerType() == EikaB.Type) then
        player:AddTrinket (TrinketType.TRINKET_UMBILICAL_CORD);
    end
end
EikaB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EikaB.PostPlayerInit);


function EikaB:PostPlayerEffect(player)
    fetusBloodItem = fetusBloodItem or THI.Collectibles.FetusBlood.Item;
    if (player:GetPlayerType() == EikaB.Type) then
        if (creepRNG:RandomInt(2) == 1) then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, player):ToEffect();
            local scale =  player.Size / 12;
            creep.Scale = scale;
            creep:SetColor(Consts.Colors.Clear, 1, 99, false);
            creep.Timeout = 10;
        end
        
        
        if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= fetusBloodItem) then
            player:SetPocketActiveItem (fetusBloodItem, ActiveSlot.SLOT_POCKET, false);
        end
    else
        if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == fetusBloodItem) then
            player:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET, false);
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EikaB.PostPlayerEffect);

function EikaB:PostFireTear(tear)
    local spawner = tear.SpawnerEntity;
    local player = nil;
    if (spawner) then
        player = spawner:ToPlayer();
    end


    if (player and player:GetPlayerType() == EikaB.Type) then
        -- Change tear's variant to blood.
        local variant = tear.Variant;
        local changeVariant = -1;
        if (variant == TearVariant.BLUE) then
            changeVariant = TearVariant.BLOOD;
        elseif (variant == TearVariant.CUPID_BLUE) then
            changeVariant = TearVariant.CUPID_BLOOD;
        elseif (variant == TearVariant.PUPULA) then
            changeVariant = TearVariant.PUPULA_BLOOD;
        elseif (variant == TearVariant.GODS_FLESH) then
            changeVariant = TearVariant.GODS_FLESH_BLOOD;
        elseif (variant == TearVariant.GLAUCOMA) then
            changeVariant = TearVariant.GLAUCOMA_BLOOD;
        elseif (variant == TearVariant.EYE) then
            changeVariant = TearVariant.EYE_BLOOD;
        elseif (variant == TearVariant.KEY) then
            changeVariant = TearVariant.KEY_BLOOD;
        end

        if (changeVariant >= 0) then
            tear:ChangeVariant(changeVariant);
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, EikaB.PostFireTear);


function EikaB:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == EikaB.Type) then
        if (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.25;
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 0.75);
        -- elseif (cache == CacheFlag.CACHE_FIREDELAY) then
        --     local delay = player.MaxFireDelay * 2;
        --     player.MaxFireDelay = delay;
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EikaB.OnEvaluateCache)


return EikaB;