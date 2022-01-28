local ItemPools = {};


function ItemPools.GetItemPoolCollectibles()
    local game = Game();
    local list = {};
    local itemPools = game:GetItemPool();
    for pool = 0, ItemPoolType.NUM_ITEMPOOLS - 1 do
        local col = itemPools:GetCollectible(pool, false, Random(), -1);
        while (col > 0) do
            list[col] = list[col] or {};
            table.insert(list[col], pool);
            itemPools:AddRoomBlacklist (col);
            col = itemPools:GetCollectible(pool, false, Random(), -1);
        end
        itemPools:ResetRoomBlacklist();
    end
    return list;
end

return ItemPools;