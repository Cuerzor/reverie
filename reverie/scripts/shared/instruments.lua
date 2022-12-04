local Instruments = {
    Entity = {
        Type = Isaac.GetEntityTypeByName("Flying Instrument"),
        Variant = Isaac.GetEntityVariantByName("Flying Instrument"),
        PositionOffset = Vector(0, -32),
    },
    MusicWave = {
        Type = Isaac.GetEntityTypeByName("Music Wave"),
        Variant = Isaac.GetEntityVariantByName("Music Wave"),
    },
    Note = {
        Type = Isaac.GetEntityTypeByName("Note"),
        Variant = Isaac.GetEntityVariantByName("Note"),
    },
    rng = RNG(),
}


function Instruments.GetInstrumentData(effect)
    local data = THI.GetData(effect);
    data.Instruments = data.Instruments or {
        WaveCooldown = 0,
        LifeTime = 0,
    }
    return data.Instruments;
end

function Instruments.GetWaveData(effect)
    local data = THI.GetData(effect);
    data.Instruments = data.Instruments or {
        Time = 12
    }
    return data.Instruments;
end

function Instruments.GetNoteData(effect)
    local data = THI.GetData(effect);
    data.Instruments = data.Instruments or {
        Time = 30
    }
    return data.Instruments;
end

function Instruments.CreateInstrument(creator, position, subtype, lifetime)
    local poof = Isaac.Spawn(Instruments.Entity.Type, EffectVariant.POOF01, 0, position + Instruments.Entity.PositionOffset, Vector(0, 0), creator):ToEffect();
    poof.SpriteScale =  Vector(0.5, 0.5);
    local instrument = Isaac.Spawn(Instruments.Entity.Type, Instruments.Entity.Variant, subtype, position, Vector(0, 0), creator):ToEffect();
    local data = Instruments.GetInstrumentData(instrument)
    data.LifeTime = lifetime;
    return instrument;
end

function Instruments.CreateMusicWave(effect, width, height, color)
    local wave = Isaac.Spawn(Instruments.MusicWave.Type, Instruments.MusicWave.Variant, 0, effect.Position, Vector(0, 0), effect):ToEffect();
    wave.SpriteScale = Vector(width / 256, height / 256);
    wave:SetColor (color, 0, 0, false, false);
    return wave;
end

function Instruments.CreateNote(instrument)
    local note = Isaac.Spawn(Instruments.Note.Type, Instruments.Note.Variant, 0, instrument.Position + Instruments.Entity.PositionOffset, Vector(0, 0), instrument):ToEffect();
    local angle = - (Instruments.rng:RandomFloat() * 90 + 45);
    note.Velocity = Vector.FromAngle(angle) * 4;
    return wave;
end

function Instruments:onWaveInit(effect)
    effect.DepthOffset = 31
end

function Instruments:onInstrumentInit(effect)
    effect.DepthOffset = 32
end

function Instruments:onNoteInit(effect)
    effect.DepthOffset = 33
end

function Instruments:onWaveUpdate(effect)
    local data = Instruments.GetWaveData(effect);
    if (data.Time > 0) then
        data.Time = data.Time - 1;
    end
    if (data.Time <= 0) then
        effect:Remove();
    end
end

function Instruments:onInstrumentUpdate(effect)
    local data = Instruments.GetInstrumentData(effect);
    if (data.WaveCooldown > 0) then
        data.WaveCooldown = data.WaveCooldown - 1;
    end
    if (data.LifeTime > 0) then
        data.LifeTime = data.LifeTime - 1;
    end
    if (data.LifeTime <= 0) then
        local poof = Isaac.Spawn(Instruments.Entity.Type, EffectVariant.POOF01, 0, effect.Position + Instruments.Entity.PositionOffset, Vector(0, 0), effect):ToEffect();
        poof.SpriteScale =  Vector(0.5, 0.5);
        effect:Remove();
    end
end

function Instruments:onNoteUpdate(effect)
    local data = Instruments.GetNoteData(effect);
    if (data.Time > 0) then
        data.Time = data.Time - 1;
    end
    if (data.Time <= 0) then
        effect:Remove();
    end
end

THI:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Instruments.onInstrumentInit, Instruments.Entity.Variant);
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Instruments.onInstrumentUpdate, Instruments.Entity.Variant);
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Instruments.onWaveInit, Instruments.MusicWave.Variant);
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Instruments.onWaveUpdate, Instruments.MusicWave.Variant);
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Instruments.onNoteInit, Instruments.Note.Variant);
THI:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Instruments.onNoteUpdate, Instruments.Note.Variant);

return Instruments;