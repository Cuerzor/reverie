local Mallet = ModItem("Miracle Mallet", "MIRACLE_MALLET");

function Mallet:PostUseMallet(item, rng, player, flags, slot, varData)
    local itemPool = THI.Game:GetItemPool();
    local room = THI.Game:GetRoom();
    local roomType = room:GetType();
    local config = Isaac.GetItemConfig();
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        if (ent.SubType > 0) then
            local seed = rng:Next();
            local itemRNG = RNG();
            itemRNG:SetSeed(seed, 0);
            local pool = itemPool:GetPoolForRoom(roomType, seed);
            if (pool < 0) then
                pool = ItemPoolType.POOL_TREASURE;
            end
            local item = CollectibleType.COLLECTIBLE_BRIMSTONE;
            local times = 0;
            local rolledItem;
            while (rolledItem ~= CollectibleType.COLLECTIBLE_BRIMSTONE and times < 1024) do
                local currentSeed = itemRNG:Next();
                rolledItem = itemPool:GetCollectible(pool, false, currentSeed, CollectibleType.COLLECTIBLE_BRIMSTONE);
                if (rolledItem == 0) then
                    rolledItem = CollectibleType.COLLECTIBLE_BRIMSTONE;
                end

                local col = config:GetCollectible(rolledItem);

                if (col) then
                    if (col.Quality >= 4) then
                        itemPool:RemoveCollectible (rolledItem);
                        item = rolledItem;
                        break;
                    end
                end 
                itemPool:AddRoomBlacklist(rolledItem);
                times = times + 1;
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
            ent:ToPickup():Morph(ent.Type, ent.Variant, item, true, false, true);

            player:AddBrokenHearts(3);
        end
    end
    itemPool:ResetRoomBlacklist();
    THI.SFXManager:Play(SoundEffect.SOUND_DEVILROOM_DEAL);
    return {ShowAnim = true, Remove = true}
end
Mallet:AddCallback(ModCallbacks.MC_USE_ITEM, Mallet.PostUseMallet, Mallet.Item);

return Mallet;