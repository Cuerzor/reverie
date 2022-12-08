local Entities = CuerLib.Entities;
local Instruments = THI.Instruments;
local Stats = CuerLib.Stats;
local Players = CuerLib.Players;

local Violin = ModItem("Melancholic Violin", "MELAN_VIOLIN");
Violin.Config = {
    Range = 110
};
Violin.Entity = {
    SubType = 0,
    SpriteFilename = Isaac.GetItemConfig():GetCollectible(Violin.Item).GfxFileName;
};
Violin.WaveColor = Color(0,0,1,0.5,0,0,0);
Violin.WaveColorDemonic = Color(0,0,0.5,0.5,0,0,0);
Violin.SlowColor = Color(1,1,1,1,0,0,1);

function Violin.GetPlayerData(player, init)
    return Violin:GetData(player, init, function() return {
        Count = 0
    } end);
end

function Violin:onPlayerEffect(player)
    local range = Violin.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, Violin.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = Violin.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or Violin.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end
end

function Violin:onUseItem(itemType, rng, player, flags, slot, data)
    local instrument = Instruments.CreateInstrument(player, player.Position, Violin.Entity.SubType, 300);
    
    if (Players.HasJudasBook(player)) then
        instrument.State = 2;
    end

    return { ShowAnim = true }
end

function Violin:onViolinInit(effect)
    if (effect.SubType == Violin.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, Violin.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function Violin:onViolinUpdate(effect)
    if (effect.SubType == Violin.Entity.SubType) then
        local range = Violin.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            local demonic = effect.State == 2;
            local color = Violin.WaveColor;
            if( demonic) then
                color = Violin.WaveColorDemonic
            end
            Instruments.CreateMusicWave(effect, range* 2, range * 2, color)
            Instruments.CreateNote(effect);
            data.WaveCooldown = 10;


            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (Entities.IsValidEnemy(ent)) then
                    if (ent.Position:Distance(effect.Position) < range + ent.Size / 2) then
                        ent:AddSlowing(EntityRef(effect), 10, 0.5, Violin.SlowColor);
                        if (demonic) then
                            ent:AddEntityFlags(EntityFlag.FLAG_WEAKNESS);
                        end
                    end
                end
            end
        end
    end
end

function Violin:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_FIREDELAY) then
        local data = Violin.GetPlayerData(player, false);
        if (data and data.Count > 0) then
            Stats:AddTearsModifier(player, function(tears, original)
                return tears + 5 * data.Count;
            end);
        end
    end
end

Violin:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Violin.onPlayerEffect);
Violin:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Violin.onViolinInit, Instruments.Entity.Variant);
Violin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Violin.onViolinUpdate, Instruments.Entity.Variant);
Violin:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Violin.onEvaluateCache);
Violin:AddCallback(ModCallbacks.MC_USE_ITEM, Violin.onUseItem, Violin.Item);

return Violin;