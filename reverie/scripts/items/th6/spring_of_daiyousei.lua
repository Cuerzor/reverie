local Collectibles = CuerLib.Collectibles

local DYSSpring = ModItem("Spring of Daiyousei", "SPRING_OF_DAIYOUSEI");

DYSSpring.Config = {
    TransformationChance = 10
};

function DYSSpring:CanTransformHeart(seed)
    if (Collectibles.IsAnyHasCollectible(DYSSpring.Item)) then
        local transform = false;
        local value = seed % 100;
        return value < DYSSpring.Config.TransformationChance;
    end
    return false;
end


local function PostGainCollectible(mod, player, item, count, touched)
    if (not touched) then
        if (count > 0) then
            for i=1,count do
                -- Resotre all red hearts
                player:AddHearts(player:GetEffectiveMaxHearts());
                -- Gain 2 soul hearts
                player:AddSoulHearts(4);
                -- Recharge the active
                player:FullCharge(ActiveSlot.SLOT_PRIMARY);
                player:FullCharge(ActiveSlot.SLOT_SECONDARY);
                player:FullCharge(ActiveSlot.SLOT_POCKET);
                player:FullCharge(ActiveSlot.SLOT_POCKET2);
            end
        end
    end
end
DYSSpring:AddCallback(CuerLib.CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, PostGainCollectible, DYSSpring.Item);

local function PreEntitySpawn(mod, id, variant, subtype, position, velocity, spawner, seed)
    if (id == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_HEART) then
        
        local room = Game():GetRoom();
        if (room:GetFrameCount() > 0 or room:IsFirstVisit()) then
            if (DYSSpring:CanTransformHeart(seed)) then
                local Fairy = THI.Pickups.SpringFairy;
                return { 
                    Fairy.Type, 
                    Fairy.Variant,
                    Fairy.SubType,
                    seed
                };
            end
        end
    end
end
DYSSpring:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, PreEntitySpawn);


return DYSSpring;

