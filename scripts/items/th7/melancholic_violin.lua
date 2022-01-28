local Detection = CuerLib.Detection;
local Instruments = THI.Instruments;
local Stats = CuerLib.Stats;

local MelancholicViolin = ModItem("Melancholic Violin", "MelancholicViolin");
MelancholicViolin.Config = {
    Range = 110
};
MelancholicViolin.Entity = {
    SubType = 0,
    SpriteFilename="gfx/items/collectibles/melancholic_violin.png"
};
MelancholicViolin.WaveColor = Color(0,0,1,0.5,0,0,0);
MelancholicViolin.SlowColor = Color(1,1,1,1,0,0,1);

function MelancholicViolin.GetPlayerData(player, init)
    return MelancholicViolin:GetData(player, init, function() return {
        Count = 0
    } end);
end

function MelancholicViolin:onPlayerEffect(player)
    local data = MelancholicViolin.GetPlayerData(player);
    local range = MelancholicViolin.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, MelancholicViolin.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = MelancholicViolin.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or MelancholicViolin.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end
end

function MelancholicViolin:onUseItem(itemType, rng, player, flags, slot, data)
    Instruments.CreateInstrument(player, player.Position, MelancholicViolin.Entity.SubType, 300);

    return { ShowAnim = true }
end

function MelancholicViolin:onViolinInit(effect)
    if (effect.SubType == MelancholicViolin.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, MelancholicViolin.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function MelancholicViolin:onViolinUpdate(effect)
    if (effect.SubType == MelancholicViolin.Entity.SubType) then
        local range = MelancholicViolin.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            Instruments.CreateMusicWave(effect, range* 2, range * 2, MelancholicViolin.WaveColor)
            Instruments.CreateNote(effect);
            data.WaveCooldown = 10;

            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (Detection.IsValidEnemy(ent)) then
                    if (ent.Position:Distance(effect.Position) < range + ent.Size / 2) then
                        ent:AddSlowing(EntityRef(effect), 10, 0.5, MelancholicViolin.SlowColor);
                    end
                end
            end
        end
    end
end

function MelancholicViolin:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_FIREDELAY) then
        local data = MelancholicViolin.GetPlayerData(player);
        if (data and data.Count > 0) then
            Stats:AddTearsModifier(player, function(tears, original)
                if (tears < 10) then
                    return math.min(10, tears + 5 * data.Count);
                end
                return tears;
            end);
        end
    end
end

MelancholicViolin:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MelancholicViolin.onPlayerEffect);
MelancholicViolin:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MelancholicViolin.onViolinInit, Instruments.Entity.Variant);
MelancholicViolin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MelancholicViolin.onViolinUpdate, Instruments.Entity.Variant);
MelancholicViolin:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MelancholicViolin.onEvaluateCache);
MelancholicViolin:AddCallback(ModCallbacks.MC_USE_ITEM, MelancholicViolin.onUseItem, MelancholicViolin.Item);

return MelancholicViolin;