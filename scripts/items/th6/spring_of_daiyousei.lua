local SaveAndLoad = CuerLib.SaveAndLoad
local Collectibles = CuerLib.Collectibles
local Callbacks = CuerLib.Callbacks;

local DYSSpring = ModItem("Spring of Daiyousei", "DYSSpring");
DYSSpring.Fairy = Isaac.GetEntityTypeByName("Spring Fairy");
DYSSpring.FairyVariant = Isaac.GetEntityVariantByName("Spring Fairy");
DYSSpring.FairyEffect = Isaac.GetEntityTypeByName("Fairy Effect");
DYSSpring.FairyEffectVariant = Isaac.GetEntityVariantByName("Fairy Effect");
DYSSpring.Particle = Isaac.GetEntityTypeByName("Fairy Particle");
DYSSpring.ParticleVariant = Isaac.GetEntityVariantByName("Fairy Particle");
DYSSpring.FairyRNG = RNG();
--DYSSpring.SoundId = Isaac.GetSoundIdByName("Fairy Heal");
DYSSpring.Config = {
    TransformationChance = 10
};

local function CanCollect(player)
    return player:CanPickRedHearts() or player:CanPickSoulHearts()
end

function DYSSpring:GetFairyData(fairy)
    return DYSSpring:GetData(fairy, true, function() return {
        rng = RNG()
    } end);
end

function DYSSpring:GetFairyEffectData(effect) 
    return DYSSpring:GetData(effect, true, function() return {
        rng = nil,
        player = nil,
        pickedTime = 0
    } end);
end

function DYSSpring:GetFairyParticleData(particle) 
    return DYSSpring:GetData(particle, true, function() return {
        Gravity = 0,
        HeightSpeed = 0,
        Position = Vector(320, 280),
        Velocity = Vector(0, 0),
        Height = 0,
        Time = 0
    } end);
end

function DYSSpring:postPickCollectible(player, item, count, touched)
    if (not touched) then
        if (count > 0) then
            for i=1,count do
                -- Resotre all red hearts
                player:AddHearts(player:GetEffectiveMaxHearts());
                -- Gain 2 soul hearts
                player:AddSoulHearts(4);
                -- Recharge the active
                player:FullCharge(ActiveSlot.SLOT_PRIMARY);
                player:FullCharge(ActiveSlot.SLOT_SECONDARY);
                player:FullCharge(ActiveSlot.SLOT_POCKET);
                player:FullCharge(ActiveSlot.SLOT_POCKET2);
            end
        end
    end
end
Callbacks:AddCallback(DYSSpring:GetMod(), CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, DYSSpring.postPickCollectible, DYSSpring.Item);

-- region Fairy Effect
function DYSSpring:onFairyEffectUpdate(effect)
    local effectData = DYSSpring:GetFairyEffectData(effect);
    local player = effectData.player;
    if (player == nil) then
        effect:Remove();
        return
    end
    
    local t = effectData.pickedTime * effectData.pickedTime / 60
    local x = math.sin(t);
    local y = math.cos(t);
    effect.Velocity = player.Position + player.Velocity + Vector(x, y) * 20 - effect.Position;
    local scale = (90 - effectData.pickedTime) / 90;
    effect.Size = scale;
    effect.SpriteScale = Vector(scale, scale);
    
    local particle = Isaac.Spawn(DYSSpring.Particle, DYSSpring.ParticleVariant, 0, effect.Position + Vector(0, -10), Vector(0, 0), effect)
    local particleData = DYSSpring:GetFairyParticleData(particle);
    particleData.Position = effect.Position;
    particleData.Height = -10;
    particleData.HeightSpeed = -10;
    particleData.Velocity = Vector(x,y) * effectData.rng:RandomFloat() * 5;
    particleData.Gravity = 1;
    particleData.Time = effectData.pickedTime / 90;
    
    if (scale <= 0) then
        effect:Remove();
    end
    effectData.pickedTime = effectData.pickedTime + 1;
end

-- endregion Fairy Effect

-- region Spring Fairy


function DYSSpring:onFairyUpdate(pickup)
    local pickupData = DYSSpring:GetFairyData(pickup)
    local rng = pickupData.rng;
    if (not pickup:IsShopItem()) then
        local x = (rng:RandomFloat() - 0.5) * 0.5;
        local y = (rng:RandomFloat() - 0.5) * 0.5;
        pickup:AddVelocity(Vector(x, y))
    end
end

function DYSSpring:onFairyRender(pickup, offset)
    if (pickup:IsShopItem()) then
        pickup:GetSprite():Play("Land")
    end
end

function DYSSpring:onFairyCollision(pickup, collider)
    local player = collider:ToPlayer();
    if (player ~= nil) then
        if (CanCollect(player)) then
            local data = DYSSpring:GetFairyData(pickup);
            
            local canPick = true;
            if (pickup:IsShopItem()) then
                if (player:GetNumCoins() < pickup.Price) then
                    canPick = false;
                else
                    player:AddCoins(-pickup.Price);
                end
            end
            
            if (canPick) then
                if (THI.IsLunatic()) then
                    player:AddHearts(2);
                else
                    player:AddHearts(player:GetMaxHearts());
                end
                player:AddSoulHearts(2);
                -- Remove self and create a fairy Effect.
                local fairyEffect = Isaac.Spawn(DYSSpring.FairyEffect, DYSSpring.FairyEffectVariant, 0, pickup.Position, Vector(0, 0), nil):ToEffect()
                local fairyEffectData = DYSSpring:GetFairyEffectData(fairyEffect);
                fairyEffectData.player = player;
                fairyEffectData.rng = data.rng;
                fairyEffect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
                pickup:Remove();
                --THI.SFXManager:Play(SoundEffect.SOUND_BOSS2_BUBBLES);
                THI.SFXManager:Play(THI.Sounds.SOUND_FAIRY_HEAL);
            end
        else
            return true;
        end
    end
end

-- endregion Spring Fairy


function DYSSpring:onParticleUpdate(effect)
    local data = DYSSpring:GetFairyParticleData(effect);
    data.HeightSpeed = data.HeightSpeed + data.Gravity;
    data.Position = data.Position + data.Velocity;
    data.Height = data.Height + data.HeightSpeed;
    
    effect.Velocity = data.Position + Vector(0, data.Height) - effect.Position;
    effect.DepthOffset = -data.Height;
    
    local scale = 1 - data.Time / 30;
    effect.SpriteScale = Vector(scale, scale)
    data.Time = data.Time + 1;
    if (data.Height >= 0 or scale <= 0) then
        effect:Remove();
    end
end

function DYSSpring:CanTransformHeart(variant, subtype)
    if (Collectibles.IsAnyHasCollectible(DYSSpring.Item)) then
        if (variant == PickupVariant.PICKUP_HEART) then
            local transform = false;
            local rng = DYSSpring.FairyRNG;
            local value = rng:RandomInt(100);
            transform = value < DYSSpring.Config.TransformationChance;
            return transform;
        end
    end
    return false;
end


function DYSSpring:preRoomEntitySpawn(entType, variant, subtype, gridIndex, seed)
    if (entType == EntityType.ENTITY_PICKUP and DYSSpring:CanTransformHeart(variant, subtype)) then
        return { 
            DYSSpring.Fairy, 
            DYSSpring.FairyVariant,
            0
        };
    end
end

function DYSSpring:onPickupSelection(pickup, variant, subType)
    local room = THI.Game:GetRoom();
    if (room:IsInitialized()) then
        if (DYSSpring:CanTransformHeart(variant, subType)) then
            return { 
                DYSSpring.FairyVariant,
                0
            };
        end
    end
end

function DYSSpring:onGameStarted(isContinued)
    if (not isContinued) then
        DYSSpring.FairyRNG = RNG()
        DYSSpring.FairyRNG:SetSeed(THI.Game:GetSeeds():GetStartSeed(), 0);
    end
end



DYSSpring:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DYSSpring.onGameStarted);
DYSSpring:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, DYSSpring.preRoomEntitySpawn);
DYSSpring:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, DYSSpring.onPickupSelection);

DYSSpring:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DYSSpring.onParticleUpdate, DYSSpring.ParticleVariant)

DYSSpring:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DYSSpring.onFairyEffectUpdate, DYSSpring.FairyEffectVariant)

DYSSpring:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, DYSSpring.onFairyRender, DYSSpring.FairyVariant)
DYSSpring:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, DYSSpring.onFairyUpdate, DYSSpring.FairyVariant)
DYSSpring:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, DYSSpring.onFairyCollision, DYSSpring.FairyVariant)


function DYSSpring:CanCollect(player, pickup)
    if (pickup.Type == DYSSpring.Fairy and pickup.Variant == DYSSpring.FairyVariant) then
        return CanCollect(player);
    end
end
Callbacks:AddCallback(DYSSpring:GetMod(), CLCallbacks.CLC_CAN_COLLECT, DYSSpring.CanCollect);

return DYSSpring;

