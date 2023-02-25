local Mod = THI;
local Transfuse = ModItem("Transfuse", "TRANSFUSE");

function Transfuse:UseItem(item, rng, player, flags, slot, vardata)
    for i = 1, 1 do
        player:ResetDamageCooldown();
        player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0);
    end
    local SatoriB = Mod.Players.SatoriB;
    local lastAddiction = SatoriB:GetAddiction(player);
    SatoriB:AddAddiction(player, -2);
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE|CacheFlag.CACHE_SPEED);
    player:EvaluateItems();
    -- SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN);
    -- Game():ShakeScreen(5);
    SFXManager():Play(SoundEffect.SOUND_POWERUP1);
    if (lastAddiction >= -6) then
        SatoriB:ShowHappyText(SatoriB:GetAddiction(player));
    end
    return {ShowAnim = true}
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Transfuse.UseItem, Transfuse.Item);


return Transfuse;