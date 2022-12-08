local Damages = CuerLib.Damages;
local Players = CuerLib.Players;
local DadsShares = ModItem("Dad's Shares", "DadsShares");

function DadsShares:PostTakeDamage(tookDamage, amount, flags, source, countdown)
    if (not Damages.IsSelfDamage(tookDamage, flags, source)) then
        local player = tookDamage:ToPlayer();
        if (player.Variant == 0) then
            local num = player:GetCollectibleNum(DadsShares.Item);
            if (num > 0) then
                local coins = player:GetNumCoins();
                local dropped = math.min(num * 5, coins);
                player:AddCoins(-dropped);
                local effectRNG = RNG();

                local droppedCoins = math.ceil(dropped / 5);
                for c = 1, droppedCoins do
                    local v = RandomVector()*(effectRNG:RandomFloat()*2+2); 
                    local poof = Isaac.Spawn(1000,15,100,player.Position,v,player);
                    local spr = poof:GetSprite();
                    spr:Load("gfx/005.022_nickel.anm2", true);
                    spr:Play("Appear");
                    -- spr:ReplaceSpritesheet(0, "gfx/items/pick ups/pickup_002_coin.png");
                    -- spr:LoadGraphics();
                end
            end
        end
    end
end
DadsShares:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, DadsShares.PostTakeDamage, EntityType.ENTITY_PLAYER);

function DadsShares:PreSpawnCleanAward(rng, position)
    local game = THI.Game;
    local sharesCount = 0;
    for p, player in Players.PlayerPairs() do
        local num = player:GetCollectibleNum(DadsShares.Item);
        sharesCount = sharesCount + num;
    end
    if (sharesCount > 0) then
        local room = THI.Game:GetRoom();
        for i = 1, sharesCount do
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true, false);
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, pos, Vector.Zero, nil);
        end
    end
end
DadsShares:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, DadsShares.PreSpawnCleanAward); 

return DadsShares;