local Instruments = THI.Instruments;

local IllusionaryKeyboard = ModItem("Illusionary Keyboard", "IllusionaryKeyboard");
IllusionaryKeyboard.Config = {
    Range = 110
};
IllusionaryKeyboard.Entity = {
    SubType = 2,
    SpriteFilename="gfx/items/collectibles/illusionary_keyboard.png"
};
IllusionaryKeyboard.WaveColor = Color(0,1,0,0.5,0,0,0);

function IllusionaryKeyboard.GetPlayerData(player, init)
    return IllusionaryKeyboard:GetData(player, init, function() return {
        Count = 0
    } end);
end

function IllusionaryKeyboard:PostPlayerUpdate(player)
    local range = IllusionaryKeyboard.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, IllusionaryKeyboard.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = IllusionaryKeyboard.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or IllusionaryKeyboard.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
    end
end

function IllusionaryKeyboard:onUseItem(itemType, rng, player, flags, slot, data)
    Instruments.CreateInstrument(player, player.Position, IllusionaryKeyboard.Entity.SubType, 300);

    return { ShowAnim = true }
end

function IllusionaryKeyboard:onKeyboardInit(effect)
    if (effect.SubType == IllusionaryKeyboard.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, IllusionaryKeyboard.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function IllusionaryKeyboard:onKeyboardUpdate(effect)
    if (effect.SubType == IllusionaryKeyboard.Entity.SubType) then
        local range = IllusionaryKeyboard.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            Instruments.CreateMusicWave(effect, range* 2, range * 2, IllusionaryKeyboard.WaveColor)
            Instruments.CreateNote(effect);
            data.WaveCooldown = 10;
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
                if (ent.Position:Distance(effect.Position) < range + ent.Size / 2) then
                    ent:Remove();
                end
            end
        end
    end
end

function IllusionaryKeyboard:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_SPEED) then
        local data = IllusionaryKeyboard.GetPlayerData(player, false);
        if (data) then
            player.MoveSpeed = math.max(player.MoveSpeed, math.min(2, player.MoveSpeed + 1 * data.Count));
        end
    end
end

IllusionaryKeyboard:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, IllusionaryKeyboard.PostPlayerUpdate);
IllusionaryKeyboard:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, IllusionaryKeyboard.onKeyboardInit, Instruments.Entity.Variant);
IllusionaryKeyboard:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, IllusionaryKeyboard.onKeyboardUpdate, Instruments.Entity.Variant);
IllusionaryKeyboard:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, IllusionaryKeyboard.onEvaluateCache);
IllusionaryKeyboard:AddCallback(ModCallbacks.MC_USE_ITEM, IllusionaryKeyboard.onUseItem, IllusionaryKeyboard.Item);
return IllusionaryKeyboard;