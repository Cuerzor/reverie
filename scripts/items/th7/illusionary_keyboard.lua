local Instruments = THI.Instruments;
local Detection = CuerLib.Detection;
local Players = CuerLib.Players;

local Keyboard = ModItem("Illusionary Keyboard", "ILLU_KEYBOARD");
Keyboard.Config = {
    Range = 110
};
Keyboard.Entity = {
    SubType = 2,
    SpriteFilename=Isaac.GetItemConfig():GetCollectible(Keyboard.Item).GfxFileName;
};
Keyboard.WaveColor = Color(0,1,0,0.5,0,0,0);
Keyboard.WaveColorDemonic = Color(0,0.5,0,0.5,0,0,0);

function Keyboard.GetPlayerData(player, init)
    return Keyboard:GetData(player, init, function() return {
        Count = 0
    } end);
end

function Keyboard:PostPlayerUpdate(player)
    local range = Keyboard.Config.Range;

    local count = 0;
    for _, ent in pairs(Isaac.FindByType(Instruments.Entity.Type, Instruments.Entity.Variant, Keyboard.Entity.SubType)) do
        if (ent.Position:Distance(player.Position) <= range + player.Size) then
            count = count + 1;
        end
    end

    local data = Keyboard.GetPlayerData(player, false);
    local curCount = (data and data.Count) or 0;
    if (count ~= curCount) then
        data = data or Keyboard.GetPlayerData(player, true);
        data.Count = count;
        player:AddCacheFlags(CacheFlag.CACHE_SPEED);
        player:EvaluateItems();
    end
end

function Keyboard:onUseItem(itemType, rng, player, flags, slot, data)
    local instrument = Instruments.CreateInstrument(player, player.Position, Keyboard.Entity.SubType, 300);
    if (Players.HasJudasBook(player)) then
        instrument.State = 2;
    end

    return { ShowAnim = true }
end

function Keyboard:onKeyboardInit(effect)
    if (effect.SubType == Keyboard.Entity.SubType) then
        local sprite = effect:GetSprite();
        sprite:ReplaceSpritesheet(0, Keyboard.Entity.SpriteFilename)
        sprite:LoadGraphics();
    end
end

function Keyboard:onKeyboardUpdate(effect)
    if (effect.SubType == Keyboard.Entity.SubType) then
        local range = Keyboard.Config.Range;
        local data = Instruments.GetInstrumentData(effect);
        if (data.WaveCooldown <= 0) then
            
            local demonic = effect.State == 2;
            local color = Keyboard.WaveColor;
            if( demonic) then
                color = Keyboard.WaveColorDemonic
            end
            Instruments.CreateMusicWave(effect, range* 2, range * 2, color)
            Instruments.CreateNote(effect);
            data.WaveCooldown = 10;
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (ent.Position:Distance(effect.Position) < range + ent.Size / 2) then
                    if (ent.Type == EntityType.ENTITY_PROJECTILE) then
                        local projectile = ent:ToProjectile();
                        if (not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                            ent:Remove();
                        end
                    elseif (Detection.IsValidEnemy(ent)) then
                        if (demonic) then
                            ent:AddFreeze ( EntityRef(effect), 10)
                        end
                    end
                end
            end
        end
    end
end

function Keyboard:onEvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_SPEED) then
        local data = Keyboard.GetPlayerData(player, false);
        if (data) then
            player.MoveSpeed = math.max(player.MoveSpeed, math.min(2, player.MoveSpeed + 1 * data.Count));
        end
    end
end

Keyboard:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Keyboard.PostPlayerUpdate);
Keyboard:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Keyboard.onKeyboardInit, Instruments.Entity.Variant);
Keyboard:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Keyboard.onKeyboardUpdate, Instruments.Entity.Variant);
Keyboard:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Keyboard.onEvaluateCache);
Keyboard:AddCallback(ModCallbacks.MC_USE_ITEM, Keyboard.onUseItem, Keyboard.Item);
return Keyboard;