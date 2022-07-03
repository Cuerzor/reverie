local ItemPools = CuerLib.ItemPools;
local Mallet = ModItem("Miracle Mallet", "MIRACLE_MALLET");
Mallet.Affecting = false;

function Mallet:PostUseMallet(item, rng, player, flags, slot, varData)
    local itemPool = THI.Game:GetItemPool();
    local room = THI.Game:GetRoom();
    local roomType = room:GetType();
    Mallet.Affecting = true;
    ItemPools:EvaluateRoomBlacklist();
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        if (ent.SubType > 0 and ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
            local seed = rng:Next();
            local pool = ItemPools:GetPoolForRoom(roomType, seed);

            local item = itemPool:GetCollectible(pool, true, seed, CollectibleType.COLLECTIBLE_BRIMSTONE);
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
            local pickup = ent:ToPickup();
            pickup:Morph(ent.Type, ent.Variant, item, true, false, true);
            pickup.Touched = false;

            player:AddBrokenHearts(3);
        end
    end
    Mallet.Affecting = false;
    ItemPools:EvaluateRoomBlacklist();
    THI.SFXManager:Play(SoundEffect.SOUND_DEVILROOM_DEAL);
    return {ShowAnim = true, Remove = true}
end
Mallet:AddCallback(ModCallbacks.MC_USE_ITEM, Mallet.PostUseMallet, Mallet.Item);

local function EvaluateBlacklist(mod, id, config)
    if (Mallet.Affecting) then
        return config.Quality < 4;
    end
end
Mallet:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateBlacklist);

return Mallet;