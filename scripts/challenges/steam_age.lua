local SteamAge = ModChallenge("Steam Age", "STEAMAGE");

local ModifyPoolCooldown = 0;
function SteamAge:PostGameStarted(isContinued)
    if (not isContinued) then
        if (Isaac.GetChallenge() == SteamAge.Id) then
            
            ModifyPoolCooldown = 2;
            local player = Isaac.GetPlayer(0);
            local cellphone = THI.Collectibles.TenguCellphone;
            -- local flags = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME;
            -- player:UseActiveItem ( CollectibleType.COLLECTIBLE_SMELTER, flags);
            player:SetPocketActiveItem(cellphone.Item, false);
        end
    end
end
SteamAge:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SteamAge.PostGameStarted);
function SteamAge:PostUpdate()
    if (ModifyPoolCooldown > 0) then
        ModifyPoolCooldown = ModifyPoolCooldown - 1;
    end
end
SteamAge:AddCallback(ModCallbacks.MC_POST_UPDATE, SteamAge.PostUpdate);

function SteamAge:PreGetCollectible(pool, decrease, seed)
    local cellphone = THI.Collectibles.TenguCellphone;
    if (not cellphone.GeneratingOffers) then
        if (Isaac.GetChallenge() == SteamAge.Id and Game():GetFrameCount() > 2 and ModifyPoolCooldown <= 0) then
            return CollectibleType.COLLECTIBLE_QUARTER;
        end
    end
end
SteamAge:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, SteamAge.PreGetCollectible);

function SteamAge:PreGameExit(ShouldSave)
    ModifyPoolCooldown = 2;
end
SteamAge:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SteamAge.PreGameExit);

function SteamAge:PostPickupUpdate(pickup)
    if (Isaac.GetChallenge() == SteamAge.Id) then
        if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE) then
            local game = THI.Game;
            local level = game:GetLevel();
            local roomDesc = level:GetCurrentRoomDesc();
            -- local roomType = roomDesc.Data.Type;
            -- if (pickup.Price == 0) then
            --     if (roomDesc.GridIndex ~= level:GetStartingRoomIndex ( )) then
            --         pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, false, true, true);
            --     end
            --elseif (pickup.Price > 0) then
            if (pickup.Price > 0) then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, true, true, true);
            end
        end
    end
end
SteamAge:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, SteamAge.PostPickupUpdate);

return SteamAge;