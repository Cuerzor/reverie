local Lib = CuerLib;
local Consts = Lib.Consts;
local Stats = Lib.Stats;
local Players = Lib.Players;
local EikaB = ModPlayer("Tainted Eika", true, "EikaB");

EikaB.BirthrightMode = 1
EikaB.HasEikaB = false;

local creepRNG = RNG();
local fetusBloodItem = nil

EikaB.DangerItems = {
    [CollectibleType.COLLECTIBLE_ABADDON] = true,
    [CollectibleType.COLLECTIBLE_BRITTLE_BONES] = true
}

local EikaInDanger = {};

function EikaB:PostPlayerInit(player)
    if (player:GetPlayerType() == EikaB.Type) then
        player:AddTrinket (TrinketType.TRINKET_UMBILICAL_CORD);
    end
end
EikaB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EikaB.PostPlayerInit);


-- function EikaB:PostPlayerEffect(player)
--     fetusBloodItem = fetusBloodItem or THI.Collectibles.FetusBlood.Item;
--     if (player:GetPlayerType() == EikaB.Type) then
--     end
-- end
-- EikaB:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EikaB.PostPlayerEffect);

local function PostPlayerUpdate(mod, player)
    fetusBloodItem = fetusBloodItem or THI.Collectibles.FetusBlood.Item;
    if (player:GetPlayerType() == EikaB.Type) then
        
        EikaB.HasEikaB = true;
        local BloodBony = THI.Monsters.BloodBony;
        -- Devil Bonies.
        local soulHearts = player:GetSoulHearts();
        local blackHeartMask = player:GetBlackHearts ( );
        local Devil = BloodBony.Variants.DEVIL;
        local bHearts = blackHeartMask;
        local sHearts = soulHearts;
        local blackHearts = 0;
        while (bHearts > 0) do
            if (bHearts & 1 > 0) then
                local reduced = math.min(sHearts, 2);
                blackHearts = blackHearts + reduced;
                soulHearts = soulHearts - reduced;
                -- local reduced = math.min(sHearts, 2);
                -- player:AddBlackHearts (-reduced);
                -- soulHearts = soulHearts - reduced;
                -- local bony = BloodBony:SpawnBony(Devil.Type, Devil.Variant, Devil.SubType, player.Position, player);
                -- if (sHearts == 1) then
                --     bony.HitPoints = bony.MaxHitPoints / 2;
                -- end
                -- THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);
            end
            sHearts = sHearts - 2;
            bHearts = bHearts >> 1;
        end
        if (blackHearts > 0) then
            BloodBony:ConvertBlackHearts(player.Position, blackHearts, player);
            Players.AddRawBlackHearts (player, -blackHearts);
            THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);
        end

        -- Soul Bonies.
        if (soulHearts > 0) then
            
            BloodBony:ConvertSoulHearts(player.Position, soulHearts, player);
            Players.AddRawSoulHearts (player, -soulHearts);
            -- local Soul = BloodBony.Variants.SOUL;
            -- for h = soulHearts, 1, -2 do 
            --     Players.AddRawSoulHearts (player, -math.min(h, 2));
            --     local bony = BloodBony:SpawnBony(Soul.Type, Soul.Variant, Soul.SubType, player.Position, player);
            --     if (h == 1) then
            --         bony.HitPoints = bony.MaxHitPoints / 2;
            --     end
            --     
            -- end
            THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);
        end

        -- Big Bony.
        local boneHearts = player:GetBoneHearts ( );
        player:AddBoneHearts (-boneHearts);
        local BigBony = BloodBony.Variants.FATTY;
        for h = boneHearts, 1, -1 do
            BloodBony:SpawnBony(BigBony.Type, BigBony.Variant, BigBony.SubType, player.Position, player);
            THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);
        end

        if (player.FrameCount == 1) then
            
            if (player:GetMaxHearts() <= 0) then
                player:AddMaxHearts(2);
                player:AddHearts(1);
            end
        end

        if (player:IsFrame(2, 0)) then
            if (Random() % 2 == 1) then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, player):ToEffect();
                local scale =  player.Size / 12;
                creep.Scale = scale;
                creep:SetColor(Consts.Colors.Clear, 1, 99, false);
                creep.Timeout = 10;
            end
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
EikaB:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

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

local function PostUpdate(mod)
    EikaB.HasEikaB = false;
end
EikaB:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);


-- local function GetPickupData(pickup, create)
--     return EikaB:GetData(pickup, create, function() return {
--         Affected = false
--     } end)
-- end

-- local function PostCollectibleUpdate(mod, pickup)
--     if (pickup.Price < 0) then
--         local hasEika = EikaB.HasEikaB;
--         if (pickup.Price ~= -5) then
--             local data = GetPickupData(pickup, true);
--             if (not data.Affected) then
--                 if (hasEika) then
--                     data.Affected = true;
--                     pickup.AutoUpdatePrice = false;
--                     pickup.Price = -5;
--                     if (not pickup.Child or not pickup.Child:Exists()) then
--                         local spikes = Isaac.Spawn(1000, 174, 0, pickup.Position, Vector.Zero, pickup);
--                         pickup.Child = spikes;
--                         spikes.Parent = pickup;
--                     end
--                 end
--             end
--         else
--             local data = GetPickupData(pickup, false);
--             if (data and data.Affected) then
--                 if (not hasEika) then
--                     data.Affected = false;
--                     pickup.AutoUpdatePrice = true;
--                     pickup.Price = -5;
--                 end
--             end
--         end
--     end
-- end
-- EikaB:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE);

function EikaB:OnEvaluateCache(player, cache)
    if (player:GetPlayerType() == EikaB.Type) then
        if (cache == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed - 0.15;
        elseif (cache == CacheFlag.CACHE_DAMAGE) then
            Stats:MultiplyDamage(player, 0.75);
        -- elseif (cache == CacheFlag.CACHE_FIREDELAY) then
        --     local delay = player.MaxFireDelay * 2;
        --     player.MaxFireDelay = delay;
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EikaB.OnEvaluateCache)

local function PostGainItem(mod, player, item, count, touched)
    if (player:GetPlayerType() == EikaB.Type and EikaB.DangerItems[item]) then
        if (player:GetMaxHearts() <= 0) then
            player:AddMaxHearts(2);
            player:AddHearts(1);
        end
    end
end
EikaB:AddCallback(CuerLib.Callbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainItem)


local function PostUseCard(mod, card, player, flags)
    if (player:GetPlayerType() == EikaB.Type) then
        if (card == Card.CARD_REVERSE_SUN) then
            if (player:GetMaxHearts() <= 0) then
                player:AddMaxHearts(2);
                player:AddHearts(1);
            end
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard)

local function PostUseItem(mod, item, rng, player, flags, slot, varData)
    if (player:GetPlayerType() == EikaB.Type) then
        if (item == CollectibleType.COLLECTIBLE_LARYNX) then
            local sfx = THI.SFXManager;
            if (sfx:IsPlaying(SoundEffect.SOUND_LARYNX_SCREAM_LO)) then
                sfx:Stop(SoundEffect.SOUND_LARYNX_SCREAM_LO);
                sfx:Play(SoundEffect.SOUND_HUSH_GROWL)
            elseif (sfx:IsPlaying(SoundEffect.SOUND_LARYNX_SCREAM_MED)) then
                sfx:Stop(SoundEffect.SOUND_LARYNX_SCREAM_MED);
                sfx:Play(SoundEffect.SOUND_HUSH_LOW_ROAR)
            elseif (sfx:IsPlaying(SoundEffect.SOUND_LARYNX_SCREAM_HI)) then
                sfx:Stop(SoundEffect.SOUND_LARYNX_SCREAM_HI);
                sfx:Play(SoundEffect.SOUND_HUSH_ROAR)
            end
        end
    end
end
EikaB:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseItem)

Players.SetOnlyRedHeartPlayer(EikaB.Type, true);


return EikaB;