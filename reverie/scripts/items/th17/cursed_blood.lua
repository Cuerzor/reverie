local Damages = CuerLib.Damages;
local Players = CuerLib.Players;
local CursedBlood = ModItem("Cursed Blood", "CURSED_BLOOD");

function CursedBlood:PreTakeDamage(tookDamage, amount, flags, source, countdown)
    local explosion = flags & DamageFlag.DAMAGE_EXPLOSION > 0;
    local fire = flags & DamageFlag.DAMAGE_FIRE > 0;
    if (explosion or fire) then
        local player = tookDamage:ToPlayer();
        if (player.Variant == 0) then
            if (player:HasCollectible(CursedBlood.Item)) then
                local Seija = Reverie.Players.Seija;
                if (Seija:WillPlayerBuff(player)) then
                    if (explosion) then
                        player:AddHearts(1);
                    end
                    return false;
                end
            end
        end
    end
end
CursedBlood:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, CursedBlood.PreTakeDamage, EntityType.ENTITY_PLAYER);

function CursedBlood:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    if (flags & (DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_FIRE) > 0) then
        local player = tookDamage:ToPlayer();
        if (player.Variant == 0) then
            if (player:HasCollectible(CursedBlood.Item)) then
                local Seija = Reverie.Players.Seija;
                if (not Seija:WillPlayerBuff(player)) then
                    Game():BombExplosionEffects (player.Position, 500, TearFlags.TEAR_BURN, Color.Default, player, 2, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR )
                    player:Kill();
                end
            end
        end
    end
end
CursedBlood:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, CursedBlood.PostTakeDamage, EntityType.ENTITY_PLAYER);

function CursedBlood:PreSpawnCleanAward(rng, position)
    for p, player in Players.PlayerPairs() do
        local num = player:GetCollectibleNum(CursedBlood.Item);
        if (num > 0) then
            player:AddCoins(num * 3);
            SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER);
        end
    end
end
CursedBlood:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CursedBlood.PreSpawnCleanAward); 

return CursedBlood;