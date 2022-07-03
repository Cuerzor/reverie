local EikaSoul = ModCard("SoulOfEika", "SOUL_EIKA");


local function PostUseCard(mod, card, player, flags)
    
    local BloodBony = THI.Monsters.BloodBony;
    for i = 1, 3 do
        BloodBony:SpawnBony(BloodBony.Type, BloodBony.Variant, BloodBony.SubTypes.PERNAMENT, player.Position, player);
    end

    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART)) do
        local subType = ent.SubType;
        if (subType == HeartSubType.HEART_FULL or subType == HeartSubType.HEART_HALF or subType == HeartSubType.HEART_DOUBLEPACK
        or subType == HeartSubType.HEART_SCARED) then
            
            local count = 1;
            if (subType == HeartSubType.HEART_DOUBLEPACK) then
                count = 2;
            end

            for i = 1, count do
                local bony = BloodBony:SpawnBony(BloodBony.Type, BloodBony.Variant, BloodBony.SubTypes.PERNAMENT, ent.Position, player);
                if (subType == HeartSubType.HEART_HALF) then
                    bony.HitPoints = bony.HitPoints / 2;
                end
            end
            ent:Remove();
        elseif (subType == HeartSubType.HEART_BLENDED or subType == HeartSubType.HEART_SOUL or subType == HeartSubType.HEART_HALF_SOUL) then
            
            local amount = 2;
            if (subType == HeartSubType.HEART_HALF_SOUL) then
                amount = 1;
            end
            BloodBony:ConvertSoulHearts(ent.Position, amount, player);
            ent:Remove();
        elseif (subType == HeartSubType.HEART_BLACK) then
            BloodBony:ConvertBlackHearts(ent.Position, 2, player);
            ent:Remove();
        elseif (subType == HeartSubType.HEART_BONE) then
            local Big = BloodBony.Variants.FATTY;
            BloodBony:SpawnBony(Big.Type, Big.Variant, Big.SubType, ent.Position, player);
            ent:Remove();
        elseif (subType == HeartSubType.HEART_ETERNAL) then
            BloodBony:SpawnBony(EntityType.ENTITY_BONY, 1, 0, ent.Position, player);
            ent:Remove();
        end
    end

    THI.SFXManager:Play(SoundEffect.SOUND_MONSTER_ROAR_0);

end
THI:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard, EikaSoul.ID);

THI:AddAnnouncer(EikaSoul.ID, THI.Sounds.SOUND_SOUL_OF_EIKA, 15)

return EikaSoul;