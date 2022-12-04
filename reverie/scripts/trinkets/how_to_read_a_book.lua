local Detection = CuerLib.Detection;
local Book = ModTrinket("How to Read A Book", "TOKIKO_BOOK");


local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
    if (Game():GetFrameCount() > 1 and loopCount == 1) then
        local mulitplier = 0;

        for p, player in Detection.PlayerPairs() do
            mulitplier = mulitplier + player:GetTrinketMultiplier(Book.Trinket);
        end

        if (mulitplier > 0) then
            local itemPool = Game():GetItemPool();
            local itemConfig = Isaac.GetItemConfig();
            local rng = RNG();
            rng:SetSeed(seed, 0);
            local newSeed = seed;
            for i = 1, 50 do
                local collectible = itemPool:GetCollectible(pool, false, newSeed);
                local config = itemConfig:GetCollectible(collectible);
                if (config and config:HasTags(ItemConfig.TAG_BOOK)) then
                    itemPool:GetCollectible(pool, true, newSeed);
                    return collectible;
                end
                newSeed = rng:Next();
            end
        end
    end
end
Book:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, PreGetCollectible, nil, 20);

return Book;