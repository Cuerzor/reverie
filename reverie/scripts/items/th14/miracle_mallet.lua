local ItemPools = CuerLib.ItemPools;
local Players = CuerLib.Players;
local Mallet = ModItem("Miracle Mallet", "MIRACLE_MALLET");
Mallet.Affecting = false;

Mallet.LargeEntities = {
    {{Type = 5, Variant = 40, SubType = 1}, {Type = 5, Variant = 40, SubType = 7}},
    {{Type = 5, Variant = 60, SubType = 1}, {Type = 5, Variant = 57, SubType = 1}},
    {{Type = 5, Variant = 90, SubType = 1}, {Type = 5, Variant = 90, SubType = 3}},
    {{Type = 5, Variant = 90, SubType = 2}, {Type = 5, Variant = 90, SubType = 3}}

}

function Mallet:TryEnlarge(entity)
    if (entity.Type == EntityType.ENTITY_PICKUP) then
        local pickup = entity:ToPickup();
        if (pickup.Variant == PickupVariant.PICKUP_PILL) then
            if (pickup.SubType <= 2048) then
                pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType + 2048, false, true, false);
                return true;
            end
        end

        for _, pair in ipairs(self.LargeEntities) do
            local info1 = pair[1];
            local info2 = pair[2];
            local other = nil;
            if (info1.Type == entity.Type and info1.Variant == entity.Variant and info1.SubType == entity.SubType) then
                other = info2;
            end

            if (other) then
                pickup:Morph(other.Type, other.Variant, other.SubType, false, true, false);
                return true;
            end
        end
    end
    return false;
end

function Mallet:EnlargePickups()
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        self:TryEnlarge(ent);
    end
end

function Mallet:PostUseMallet(item, rng, player, flags, slot, varData)
    local itemPool = THI.Game:GetItemPool();
    local room = THI.Game:GetRoom();
    local roomType = room:GetType();
    Mallet.Affecting = true;
    ItemPools:EvaluateRoomBlacklist();
    for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        if (ent.SubType > 0 and ent.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE) then
            local seed = rng:Next();

            local item = room:GetSeededCollectible(seed);
            if (item == CollectibleType.COLLECTIBLE_BREAKFAST) then
                item = CollectibleType.COLLECTIBLE_BRIMSTONE;
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil);
            local pickup = ent:ToPickup();
            pickup:Morph(ent.Type, ent.Variant, item, true, false, true);
            pickup.Touched = false;

            if (roomType == RoomType.ROOM_DEVIL and Players.HasJudasBook(player)) then
                player:AddBlackHearts(6);
            else
                player:AddBrokenHearts(3);
            end
        end
    end
    Mallet.Affecting = false;
    ItemPools:EvaluateRoomBlacklist();


    Mallet:EnlargePickups();
    THI.SFXManager:Play(SoundEffect.SOUND_DEVILROOM_DEAL);
    return {ShowAnim = true, Remove = true}
end
Mallet:AddCallback(ModCallbacks.MC_USE_ITEM, Mallet.PostUseMallet, Mallet.Item);

local function EvaluateBlacklist(mod, id, config)
    if (Mallet.Affecting) then
        return config.Quality < 4;
    end
end
Mallet:AddCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateBlacklist);

return Mallet;