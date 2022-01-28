local Thunder = ModEntity("Holy Thunder", "HOLY_THUDNER");

-- Main.
do
    local function PostThunderInit(mod, thunder)
        local spr = thunder:GetSprite();
        spr:Play("Shock");
    end
    Thunder:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostThunderInit, Thunder.Variant);

    local function PostThunderUpdate(mod, thunder)

        if (thunder.FrameCount == 1) then
            local halfVector = Vector(0.5, 0.5)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, thunder.Position, Vector.Zero, thunder);
            local game = Game();
            game:SpawnParticles (thunder.Position, EffectVariant.EMBER_PARTICLE, 10, 10, Color.Default);
            local exp = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, thunder.Position, Vector.Zero, thunder):ToEffect();
            exp.Scale = 0.5;
            exp.SpriteScale = halfVector;

            local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, thunder.Position, Vector.Zero, thunder):ToEffect();
            crater.SpriteScale = halfVector;
            THI.SFXManager:Play(THI.Sounds.SOUND_THUNDER_SHOCK, 3);
        end
        local spr = thunder:GetSprite();
        if (spr:IsFinished("Shock")) then
            thunder:Remove();
        end
    end
    Thunder:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostThunderUpdate, Thunder.Variant);
end

return Thunder;
