local Detection = CuerLib.Detection;
local Instruments = THI.Instruments;
local Stats = CuerLib.Stats;

local Trumpet = ModItem("Maniac Trumpet", "MANIAC_TRUMPET");
Trumpet.Config = {
    Range = 110
};
Trumpet.Entity = {
    SubType = 1,
    SpriteFilename = Isaac.GetItemConfig():GetCollectible(Trumpet.Item).GfxFileName;
};
Trumpet.WaveColor = Color(1,0,0,0.5,0,0,0);

function Trumpet.GetPlayerData(player, init)
    return Trumpet:GetData(player, init, function() return {
        Count = 0
    } end);
end

function Trumpet:onPlayerEffect(player)
    local range = Trumpet.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, Trumpet.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = Trumpet.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or Trumpet.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
        player:EvaluateItems();
    end
end

function Trumpet:onUseItem(itemType, rng, player, flags, slot, data)
    Instruments.CreateInstrument(player, player.Position, Trumpet.Entity.SubType, 300);

    return { ShowAnim = true }
end

function Trumpet:onTrumpetInit(effect)
    if (effect.SubType == Trumpet.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, Trumpet.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function Trumpet:onTrumpetUpdate(effect)
    if (effect.SubType == Trumpet.Entity.SubType) then
        local range = Trumpet.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            Instruments.CreateMusicWave(effect, range* 2, range * 2, Trumpet.WaveColor)
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

function Trumpet:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local data = Trumpet.GetPlayerData(player, false);
        if (data) then
            --player.Damage = player.Damage * (1 + 1 * data.Count);
            Stats:MultiplyDamage(player, 1 + 0.5 * data.Count);
        end
    end
end

Trumpet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Trumpet.onPlayerEffect);
Trumpet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Trumpet.onTrumpetInit, Instruments.Entity.Variant);
Trumpet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Trumpet.onTrumpetUpdate, Instruments.Entity.Variant);
Trumpet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Trumpet.onEvaluateCache);
Trumpet:AddCallback(ModCallbacks.MC_USE_ITEM, Trumpet.onUseItem, Trumpet.Item);

return Trumpet;