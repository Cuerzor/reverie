local Detection = CuerLib.Detection;
local Instruments = THI.Instruments;
local Stats = CuerLib.Stats;

local ManiacTrumpet = ModItem("Maniac Trumpet", "ManiacTrumpet");
ManiacTrumpet.Config = {
    Range = 110
};
ManiacTrumpet.Entity = {
    SubType = 1,
    SpriteFilename="gfx/items/collectibles/maniac_trumpet.png"
};
ManiacTrumpet.WaveColor = Color(1,0,0,0.5,0,0,0);

function ManiacTrumpet.GetPlayerData(player, init)
    return ManiacTrumpet:GetData(player, init, function() return {
        Count = 0
    } end);
end

function ManiacTrumpet:onPlayerEffect(player)
    local range = ManiacTrumpet.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, ManiacTrumpet.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = ManiacTrumpet.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or ManiacTrumpet.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
        player:EvaluateItems();
    end
end

function ManiacTrumpet:onUseItem(itemType, rng, player, flags, slot, data)
    Instruments.CreateInstrument(player, player.Position, ManiacTrumpet.Entity.SubType, 300);

    return { ShowAnim = true }
end

function ManiacTrumpet:onTrumpetInit(effect)
    if (effect.SubType == ManiacTrumpet.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, ManiacTrumpet.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function ManiacTrumpet:onTrumpetUpdate(effect)
    if (effect.SubType == ManiacTrumpet.Entity.SubType) then
        local range = ManiacTrumpet.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            Instruments.CreateMusicWave(effect, range* 2, range * 2, ManiacTrumpet.WaveColor)
            Instruments.CreateNote(effect);
            data.WaveCooldown = 10;
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (Detection.IsValidEnemy(ent)) then
                    if (ent.Position:Distance(effect.Position) < range + ent.Size / 2) then
                        ent:AddVelocity((ent.Position - effect.Position):Normalized() * 5);
                        ent:TakeDamage(2, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(effect), 0)
                    end
                end
            end
        end
    end
end

function ManiacTrumpet:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local data = ManiacTrumpet.GetPlayerData(player, false);
        if (data) then
            --player.Damage = player.Damage * (1 + 1 * data.Count);
            Stats:MultiplyDamage(player, 1 + 0.5 * data.Count);
        end
    end
end

ManiacTrumpet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ManiacTrumpet.onPlayerEffect);
ManiacTrumpet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ManiacTrumpet.onTrumpetInit, Instruments.Entity.Variant);
ManiacTrumpet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ManiacTrumpet.onTrumpetUpdate, Instruments.Entity.Variant);
ManiacTrumpet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ManiacTrumpet.onEvaluateCache);
ManiacTrumpet:AddCallback(ModCallbacks.MC_USE_ITEM, ManiacTrumpet.onUseItem, ManiacTrumpet.Item);

return ManiacTrumpet;