local SatoriSoul = ModCard("SoulOfSatori", "SOUL_SATORI");


local function PostUseCard(mod, card, player, flags)
    
    local poofColor = Color(0.5,0,0.5, 0.5, 0, 0, 0);
    for p = 0, 1 do
        local subType = p + 1;
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, subType, player.Position, Vector.Zero, player);
        poof:SetColor(poofColor, 0, 0);
    end
    THI.SFXManager:Play(SoundEffect.SOUND_DEATH_CARD)
    Game():ShakeScreen(10);

    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent:IsActiveEnemy() and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_STATUS_EFFECTS)) then
            if (ent:IsBoss() or ent.Type == EntityType.ENTITY_THE_HAUNT or ent.Type == EntityType.ENTITY_EXORCIST) then
                ent:AddCharmed( EntityRef(player), 150);
            else
                ent:AddCharmed( EntityRef(player), -1);
                THI.SFXManager:Play(THI.Sounds.SOUND_MIND_CONTROL);
            end
        end
    end

end
THI:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard, SatoriSoul.ID);
THI:AddAnnouncer(SatoriSoul.ID, THI.Sounds.SOUND_SOUL_OF_SATORI, 15)

return SatoriSoul;