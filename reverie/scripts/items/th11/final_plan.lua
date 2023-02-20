local Mod = THI;
local FinalPlan = ModItem("Final Plan", "FINAL_PLAN");

function FinalPlan:UseItem(item, rng, player, flags, slot, vardata)
    for i = 1, 6 do
        player:ResetDamageCooldown();
        player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0);
    end
    local SatoriB = Mod.Players.SatoriB;
    local lastAddiction = SatoriB:GetAddiction(player);
    SatoriB:AddAddiction(player, -6);
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE|CacheFlag.CACHE_SPEED);
    player:EvaluateItems();
    SFXManager():Play(SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED);
    player:AnimateSad();
    if (lastAddiction >= -6) then
        SFXManager():Play(SoundEffect.SOUND_POWERUP1);
        SatoriB:ShowHappyText(SatoriB:GetAddiction(player));
    end
    Game():ShakeScreen(20);
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, FinalPlan.UseItem, FinalPlan.Item);


return FinalPlan;