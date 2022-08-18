
local Detection = CuerLib.Detection;
local ItemPools = CuerLib.ItemPools;
local Collectibles = CuerLib.Collectibles;
local SeijaB = ModPlayer("Tainted Seija", true, "SEIJA_B");

SeijaB.Costume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_seija_b.anm2");
SeijaB.Sprite = "gfx/reverie/seija_b.anm2"
SeijaB.SpriteFlying = "gfx/reverie/seija_b_flying.anm2"

local function GetPlayerTempData(player, create)
    return SeijaB:GetTempData(player, create, function()
        return {
            CostumeState = 0,
            SpriteState = 0,
            WasSeijaB = false
        }
    end)
end
local function GetPickupTempData(pickup, create)
    return SeijaB:GetTempData(pickup, create, function()
        return {
            Duplicated = false;
        }
    end)
end

local function UpdatePlayerSprite(player)
    local data = GetPlayerTempData(player, true);
    local sprState = 1;
    local costumeState = 1;
    local path = SeijaB.Sprite;
    if (player.CanFly) then
        path = SeijaB.SpriteFlying;
        sprState = 2;
    end
    if (data.SpriteState ~= sprState) then
        data.SpriteState = sprState;
        local spr = player:GetSprite();
        local animation = spr:GetAnimation();
        local frame = spr:GetFrame();
        local overlayAnimation = spr:GetOverlayAnimation();
        local overlayFrame = spr:GetOverlayFrame();
        spr:Load(path, true);
        spr:SetFrame(animation, frame);
        spr:SetOverlayFrame(overlayAnimation, overlayFrame);

    end

    if (data.CostumeState ~= costumeState) then
        data.CostumeState = costumeState;
        
        player:TryRemoveNullCostume(SeijaB.Costume);
        if (costumeState == 1) then
            player:AddNullCostume(SeijaB.Costume);
        end
    end
end


do -- Events
    local function PostPlayerInit(mod, player)
        if (player:GetPlayerType() == SeijaB.Type) then
            player:AddNullCostume(SeijaB.Costume);
            local game = Game();
            if (not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0)) then
                player:SetPocketActiveItem(THI.Collectibles.DSiphon.Item, ActiveSlot.SLOT_POCKET, false);
                game:GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB);
            end
        end
    end
    SeijaB:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, PostPlayerInit, 0)


    local function PostPlayerUpdate(mod, player)
        if (player:GetPlayerType() == SeijaB.Type) then
            UpdatePlayerSprite(player);
            local tempData = GetPlayerTempData(player, true);
            tempData.WasSeijaB = true;
        else
            local tempData = GetPlayerTempData(player, false);
            if (tempData and tempData.WasSeijaB) then
                tempData.WasSeijaB = false;
                player:TryRemoveNullCostume(SeijaB.Costume);
            end
        end
    end
    SeijaB:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate, 0)

    -- local gettingCollectible = false;
    local seijaBPlayer = nil;
    local seijaBCached = false;
    -- local seijaBHasBirthright = nil;

    local function CacheSeijaBPlayer()
        if (not seijaBCached) then
            seijaBPlayer = nil;
            -- seijaBHasBirthright = nil;
            for p, player in Detection.PlayerPairs() do
                if (player:GetPlayerType() == SeijaB.Type) then
                    seijaBPlayer = player;
                    -- if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                    --     seijaBHasBirthright = true;
                    -- end
                end
            end
            seijaBCached = true;
        end
    end

    local function PreGetCollectible(mod, pool, decrease, seed, loopCount)
        if (Game():GetFrameCount() > 0) then
            local cachedBefore = seijaBCached;
            CacheSeijaBPlayer();
            if (not cachedBefore) then
                ItemPools:EvaluateRoomBlacklist();
            end
        end
    end
    SeijaB:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_GET_COLLECTIBLE, PreGetCollectible, nil, -100)
    
    local function EvaluateRoomBlacklist(mod, id, config)
        local DSiphon = THI.Collectibles.DSiphon;
        if (not DSiphon.GettingCollectible) then
            CacheSeijaBPlayer();
            if (seijaBPlayer) then
                -- if (seijaBHasBirthright) then
                --     return config.Quality >= 4;
                -- else
                    return config.Quality ~= 2;
                -- end
            end
        end
    end
    SeijaB:AddCustomCallback(CuerLib.CLCallbacks.CLC_EVALUATE_POOL_BLACKLIST, EvaluateRoomBlacklist)

    

    local function PostUpdate(mod)
        if (seijaBCached) then
            seijaBCached = false;
        end
    end
    SeijaB:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)
    

end
return SeijaB;