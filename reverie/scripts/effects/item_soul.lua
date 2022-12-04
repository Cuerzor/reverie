local ItemSoul = ModEntity("Item Soul", "ITEM_SOUL");

ItemSoul.SubTypes = {
    RED = 0,
    BLACK = 1,
}

function ItemSoul:SetItem(entity, id)
    local effect = entity:ToEffect();
    if (effect) then
        local spr = effect:GetSprite();
        local itemConfig = Isaac.GetItemConfig();
        local config = itemConfig:GetCollectible(id);
        local gfx = (config and config.GfxFileName) or "";
        spr:ReplaceSpritesheet(1, gfx);
        spr:LoadGraphics();
        effect.State = id;
    end
end

local function PostEffectInit(mod, effect)
    if (effect.SubType == ItemSoul.SubTypes.BLACK) then
        effect:GetSprite():Play("Black");
    end
end
ItemSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, ItemSoul.Variant);

local function PostEffectUpdate(mod, effect)
    if (effect.Timeout >= 0) then
        effect.Timeout = effect.Timeout - 1;
    end
    local thresold = effect.LifeSpan - 45;
    if (effect.SubType == ItemSoul.SubTypes.BLACK) then
        if (effect.Timeout < thresold) then
            effect.Velocity = Vector(5, (thresold - effect.Timeout) / thresold * -50);
        end
    else
        if (effect.Timeout < thresold) then
            effect.Velocity = (effect.TargetPosition - effect.Position):Resized(20);
            if (effect.TargetPosition:Distance(effect.Position) < 20) then
                effect:Remove();
            end
        end
    end

    if (not effect.Child) then
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
        trail.MinRadius = 0.1;
        trail.MaxRadius = 0.15;
        trail.SpriteScale = Vector(5,5);
        trail.Parent = effect;
        if (effect.SubType == ItemSoul.SubTypes.BLACK) then
            trail:SetColor(Color(0.5, 0.5, 0.5, 1, 0,0,0), -1, 0);
        else
            trail:SetColor(Color(1, 0, 0, 0.5, 0, 0, 0), -1, 0);
        end
        effect.Child = trail;
    else 
        effect.Child.Position = effect.Position + effect.PositionOffset;
        --effect.Child.Velocity = effect.Velocity;
    end

    effect:MultiplyFriction(0.8);
    if (effect.Timeout < 0 or effect.LifeSpan <=0) then
        effect:Remove();
    end
end
ItemSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, ItemSoul.Variant);

local function PostEffectRemove(mod ,entity)
    if (entity.Variant == ItemSoul.Variant) then
        local effect = entity:ToEffect();
        if (effect.SubType ~= ItemSoul.SubTypes.BLACK) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, effect.State, effect.TargetPosition, Vector.Zero, entity.SpawnerEntity);
            SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)
        end
        if (effect.Child)then
            effect.Child:Remove();
        end
    end
end
ItemSoul:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEffectRemove, ItemSoul.Type);

return ItemSoul;