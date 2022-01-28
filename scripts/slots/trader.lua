local Screen = CuerLib.Screen;
local Collectibles = CuerLib.Collectibles;
local Detection = CuerLib.Detection;
local Trader = ModEntity("Trader (Normal)","EXC_TRADER");

local config = Isaac.GetItemConfig();

Trader.OfferType = {
    OFFER_COLLECTIBLE = 1,
    OFFER_EMERALD = 2
}
Trader.Services = {
    SERVICE_BUY = 1,
    SERVICE_RECOVERY = 2,
    SERVICE_SELL = 3,
    SERVICE_BARTER = 4
}
Trader.Classes = {
    CLASS_NORMAL = 0,
    CLASS_SHOP = 1,
    CLASS_SECRET = 2,
    CLASS_BOSS = 3,
    CLASS_DEVIL = 4,
    CLASS_ANGEL = 5,
    CLASS_CURSE = 6,
    NUM_CLASSES = 7,
}

local PlayerCollectibles = {
    List = {},
    Count = 0
};
local Buyables = {};
local BuyableCaches = {};

function Trader.CheckAllPlayerCollectibles()
    local game = THI.Game;
    local results = {};
    local count = 0;
    for p, player in Detection.PlayerPairs() do
        local collectibles = Collectibles.GetPlayerCollectibles(player);
        for id, num in pairs(collectibles) do
            local col = config:GetCollectible(id);
            if (col and not col:HasTags(ItemConfig.TAG_QUEST)) then
                results[id] = (results[id] or 0) + num;
                count = count + num;
            end
        end
    end
    PlayerCollectibles.List = results;
    PlayerCollectibles.Count = count;
end

function Trader.ClearSpawnCache()
    PlayerCollectibles = {
        List = {},
        Count = 0
    };
    Buyables = {};
    BuyableCaches = {};
end

function Trader.UpdateBuyableCache()
    for i = #BuyableCaches, 1, -1 do
        table.insert(Buyables, BuyableCaches[i]);
        table.remove(BuyableCaches, i)
    end
end

function Trader.GetBuyableItem(seed)
    local total = #Buyables;
    local weight = seed % math.max(1, total);
    for i, info in pairs(Buyables) do
        local id = info.ID;
        local num = 1;
        weight = weight - num;
        if (weight < 0) then
            table.remove(Buyables, i);
            return id, info.Pool;
        end
    end
    return 1, ItemPoolType.POOL_DEVIL;
end
function Trader.GetClass(seed)
    local value = seed % 100;
    if (value >= 30) then
        if (value < 50) then
            return Trader.Classes.CLASS_SHOP;
        elseif (value < 65) then
            return Trader.Classes.CLASS_BOSS;
        elseif (value < 75) then
            return Trader.Classes.CLASS_CURSE;
        elseif (value < 85) then
            return Trader.Classes.CLASS_DEVIL;
        elseif (value < 95) then
            return Trader.Classes.CLASS_ANGEL;
        elseif (value < 100) then
            return Trader.Classes.CLASS_SECRET;
        end
    end
    return Trader.Classes.CLASS_NORMAL
end

function Trader.GetTraderData(trader, init)
    local data = trader:GetData();
    if (init) then
        if (not data.EXC_TRADER) then
            data.EXC_TRADER = {
                IReceive = nil,
                YouReceive = nil,
                LeaveTimeout = 0,
                Dealt = false,
                DealerPlayer = nil
            }
        end
    end
    return data.EXC_TRADER;
end

    -- Classes:
    -- Normal: Boss -> Treasure
    -- Shop: Boss -> Shop
    -- Secret: Treasure -> Secret
    -- Boss: Treasure -> Boss
    -- Devil: Angel -> Devil
    -- Angel: Devil -> Angel
    -- Curse: Shop -> Curse
local ClassPools = {
    [Trader.Classes.CLASS_NORMAL] = {Buys = ItemPoolType.POOL_DEVIL, Sells = ItemPoolType.POOL_TREASURE},
    [Trader.Classes.CLASS_BOSS] = {Buys = ItemPoolType.POOL_TREASURE, Sells = ItemPoolType.POOL_BOSS},
    [Trader.Classes.CLASS_SHOP] = {Buys = ItemPoolType.POOL_BOSS, Sells = ItemPoolType.POOL_SHOP},
    [Trader.Classes.CLASS_SECRET] = {Buys = ItemPoolType.POOL_SHOP, Sells = ItemPoolType.POOL_SECRET},
    [Trader.Classes.CLASS_CURSE] = {Buys = ItemPoolType.POOL_SECRET, Sells = ItemPoolType.POOL_CURSE},
    [Trader.Classes.CLASS_ANGEL] = {Buys = ItemPoolType.POOL_CURSE, Sells = ItemPoolType.POOL_ANGEL},
    [Trader.Classes.CLASS_DEVIL] = {Buys = ItemPoolType.POOL_ANGEL, Sells = ItemPoolType.POOL_DEVIL},
}
local GreedPools = {
    [ItemPoolType.POOL_TREASURE] = ItemPoolType.POOL_GREED_TREASURE;
    [ItemPoolType.POOL_SHOP] = ItemPoolType.POOL_GREED_SHOP;
    [ItemPoolType.POOL_SECRET] = ItemPoolType.POOL_GREED_SECRET;
    [ItemPoolType.POOL_BOSS] = ItemPoolType.POOL_GREED_BOSS;
    [ItemPoolType.POOL_DEVIL] = ItemPoolType.POOL_GREED_DEVIL;
    [ItemPoolType.POOL_ANGEL] = ItemPoolType.POOL_GREED_ANGEL;
    [ItemPoolType.POOL_CURSE] = ItemPoolType.POOL_GREED_CURSE;
}

local function ConvertToGreedPool(pool)
    return GreedPools[pool] or pool;
end

local function ConvertToNormalPool(pool)
    for normal, greed in pairs(GreedPools) do
        if (greed == pool) then
            return normal;
        end
    end
    return pool;
end

function Trader.GetTraderPool(class, sell)
    local pool = ItemPoolType.POOL_TREASURE;
    local classInfo = ClassPools[class];
    if (sell) then
        pool = classInfo.Sells;
    else
        pool = classInfo.Buys;
    end

    if (THI.Game:IsGreedMode()) then
        return ConvertToGreedPool(pool);
    end 
    return pool;
end

function Trader.GetPoolTrader(pool, sell)
    if (THI.Game:IsGreedMode()) then
        pool = ConvertToNormalPool(pool)
    end 

    for class, info in pairs(ClassPools) do
        if (sell) then
            if (pool == info.Sells) then
                return class
            end
        else
            if (pool == info.Buys) then
                return class
            end
        end
    end


    return Trader.Classes.CLASS_NORMAL;
end

function Trader.SpawnTrader(service, pos, seed)
    local tradeData = Trader.NewTradeData(service, seed);
    local npc = Isaac.Spawn(Trader.Type, Trader.Variant, tradeData.Class, pos, Vector.Zero, nil);
    Trader.ApplyTrade(npc, tradeData);
    npc.TargetPosition = npc.Position;
end

function Trader.NewTradeData(service, seed)
    seed = seed or Random();
    local data = {};
    local meType = 1;
    local meSubType = 1;
    local youType = 3;
    local youSubType = 3;
    local class = Trader.Classes.CLASS_NORMAL;
    if (service == Trader.Services.SERVICE_BUY) then
        meType = Trader.OfferType.OFFER_COLLECTIBLE;
        meSubType = Trader.GetCollectible(class, false, true, seed)

        youType = Trader.OfferType.OFFER_EMERALD;
        youSubType = 1;
        local col = config:GetCollectible(meSubType);
        if (col) then
            youSubType = col.Quality + 1;
        end
    elseif (service == Trader.Services.SERVICE_RECOVERY) then
        meType = Trader.OfferType.OFFER_COLLECTIBLE;
        meSubType = Trader.GetBuyableItem(seed);

        youType = Trader.OfferType.OFFER_EMERALD;
        youSubType = 1;
        local col = config:GetCollectible(meSubType);
        if (col) then
            youSubType = col.Quality + 1;
        end
    elseif (service == Trader.Services.SERVICE_SELL) then
        class = Trader.GetClass(seed);
        youType = Trader.OfferType.OFFER_COLLECTIBLE;
        youSubType = Trader.GetCollectible(class, true, false, seed)

        meType = Trader.OfferType.OFFER_EMERALD;
        meSubType = 1;
        local col = config:GetCollectible(youSubType);
        if (col) then
            meSubType = math.max(1, col.Quality * 2);
        end
    elseif (service == Trader.Services.SERVICE_BARTER) then
        meType = Trader.OfferType.OFFER_COLLECTIBLE;
        local item, pool = Trader.GetBuyableItem(seed);
        meSubType = item;
        class = Trader.GetPoolTrader(pool, false);

        
        local quality = 4;
        local col = config:GetCollectible(meSubType);
        if (col) then
            quality = col.Quality;
        end

        youType = Trader.OfferType.OFFER_COLLECTIBLE;
        youSubType = Trader.GetCollectible(class, true, false, seed, quality, 3)
    end
    data.IReceive = Trader.GetOfferData(meType, meSubType);
    data.YouReceive = Trader.GetOfferData(youType, youSubType);
    data.Class = class;
    return data;
end

function Trader.GetCollectible(class, sell, playerHas, seed, targetQuality, rerollTimes)
    rerollTimes = rerollTimes or 0
    targetQuality = targetQuality or 3;
    local game = THI.Game;
    local rng = RNG();
    rng:SetSeed(seed, 0);
    if (playerHas) then
        local totalCount = PlayerCollectibles.Count;

        local thresold = rng:RandomInt(totalCount);

        local targetCol = CollectibleType.COLLECTIBLE_BREAKFAST;
        local inited = false;
        for id, num in pairs(PlayerCollectibles.List) do
            local decrease = num;
            if (not inited and decrease > 0) then
                targetCol = id;
                inited = true;
            end
            thresold = thresold - decrease;
            if (thresold < 0) then
                targetCol = id;
                PlayerCollectibles.List[id] = num - 1;
                PlayerCollectibles.Count = PlayerCollectibles.Count - 1;
                goto Selected;
            end
        end
        ::Selected::
        return targetCol;
    else
        local itemPool = game:GetItemPool();
        local result = 1;
        local pool = Trader.GetTraderPool(class, sell);
        if (sell) then
            -- High quality.
            local time = 0;
            local nearest = 10;
            local nearestCol = CollectibleType.COLLECTIBLE_BREAKFAST;
            while (time <= rerollTimes) do
                local c = itemPool:GetCollectible(pool, false, Random(), CollectibleType.COLLECTIBLE_BREAKFAST);
                -- Get Quality.
                local quality = 0;
                local col = config:GetCollectible(c);
                if (col) then
                    quality = col.Quality;
                end
                -- Compare Quality.
                local diff = math.abs(targetQuality - quality) ;
                if (diff < nearest) then
                    nearest = diff;
                    nearestCol = c;
                end
                time = time + 1;
            end
            result = nearestCol;
        else
            result = itemPool:GetCollectible(pool, false, seed, CollectibleType.COLLECTIBLE_NULL);
        end
        itemPool:AddRoomBlacklist(result);
        local info = {
            ID = result,
            Pool = pool
        }
        table.insert(BuyableCaches, info);

        return result;
    end
end
function Trader.GetOfferData(type, subType)
    local data = {
        Type = type,
        SubType = subType
    };

    local sprite = Sprite();
    if (type == Trader.OfferType.OFFER_COLLECTIBLE) then
        local gfx = config:GetCollectible(data.SubType).GfxFileName;
        sprite:Load("gfx/005.100_collectible.anm2", false);
        sprite:ReplaceSpritesheet(1, gfx);
        sprite:LoadGraphics();
        sprite:Play("ShopIdle");
        sprite.Scale = Vector(0.5, 0.5);
    elseif (type == Trader.OfferType.OFFER_EMERALD) then
        sprite:Load("gfx/emerald_icon.anm2", true);
        sprite:Play("Icon");
        sprite.Scale = Vector(0.5, 0.5);
    end
    data.Sprite = sprite;
    return data;
end

function Trader.ApplyTrade(npc, trade)
    local data = Trader.GetTraderData(npc, true);
    data.IReceive = trade.IReceive;
    data.YouReceive = trade.YouReceive;
end


function Trader:PostNPCInit(npc)
    if (npc.Variant == Trader.Variant) then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY;
        local flags = EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_NO_PLAYER_CONTROL | EntityFlag.FLAG_HIDE_HP_BAR;
        npc:AddEntityFlags(flags);
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
    end
end
Trader:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Trader.PostNPCInit, Trader.Type);

function Trader:PostNPCUpdate(npc)
    if (npc.Variant == Trader.Variant) then

        npc.Velocity = npc.TargetPosition - npc.Position;
        npc:MultiplyFriction(0.6);
        if (npc:IsDead()) then
            print("dead");
        end

        local data = Trader.GetTraderData(npc, false);
        if (data) then
            if (data.Dealt) then
                local spr = npc:GetSprite();
                if (data.LeaveTimeout >= 0) then
                    data.LeaveTimeout = data.LeaveTimeout - 1;
                    if (data.LeaveTimeout < 0) then
                        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
                        spr:Play("Teleport");
                        
                        -- Spawn Prize.
                        local YouReceive = data.YouReceive;
                        if (YouReceive) then
                            if (YouReceive.Type == Trader.OfferType.OFFER_COLLECTIBLE) then
                                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, YouReceive.SubType, npc.Position, Vector.Zero, nil);
                                THI.SFXManager:Play(SoundEffect.SOUND_SLOTSPAWN);
                            elseif (YouReceive.Type == Trader.OfferType.OFFER_EMERALD) then
                                local Ticket = THI.Collectibles.ExchangeTicket;
                                Ticket.AddEmeralds(data.DealerPlayer, YouReceive.SubType);
                                THI.SFXManager:Play(SoundEffect.SOUND_CASH_REGISTER);
                            end
                        end

                        THI.SFXManager:Play(SoundEffect.SOUND_HELL_PORTAL1);
                    end
                else
                    if (spr:IsFinished("Teleport")) then
                        npc:Remove();
                    end
                end
            end
        end
    end
end
Trader:AddCallback(ModCallbacks.MC_NPC_UPDATE, Trader.PostNPCUpdate, Trader.Type);

function Trader:PostNPCRender(npc, offset)
    if (npc.Variant == Trader.Variant) then
        local data = Trader.GetTraderData(npc, false);
        if (data) then
            if (not data.Dealt) then
                local IReceive = data.IReceive;
                local YouReceive = data.YouReceive;
                if (IReceive) then
                    local pos = Screen.GetEntityOffsetedRenderPosition(npc, offset, Vector(-22, -60), true);
                    IReceive.Sprite:Render(pos);
                    
                    if (IReceive.Type == Trader.OfferType.OFFER_EMERALD) then
                        THI.Fonts.Terminus8:DrawString(IReceive.SubType, pos.X, pos.Y - 10, KColor.White);
                    end
                end
                if (YouReceive) then
                    local pos = Screen.GetEntityOffsetedRenderPosition(npc, offset, Vector(22, -60), true);
                    YouReceive.Sprite:Render(pos);
                    if (YouReceive.Type == Trader.OfferType.OFFER_EMERALD) then
                        THI.Fonts.Terminus8:DrawString(YouReceive.SubType, pos.X, pos.Y - 10, KColor.White);
                    end
                end
            end
        end
    end
end
Trader:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, Trader.PostNPCRender, Trader.Type);

function Trader:PostPlayerCollision(player, other, low)
    if (other.Type == Trader.Type and other.Variant == Trader.Variant) then
        
        local data = Trader.GetTraderData(other, false);
        if (data) then
            if (not data.Dealt) then

                local function NiceDeal(player)
                    data.LeaveTimeout = 30;
                    THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
                    data.Dealt = true;
                    data.DealerPlayer = player;
                    other:GetSprite():Play("Dealt");
                end 

                local function Cannot()
                    if (not THI.SFXManager:IsPlaying(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)) then
                        THI.SFXManager:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ);
                    end
                end 

                local IReceive = data.IReceive;
                local YouReceive = data.YouReceive;
                if (IReceive and YouReceive) then
                    if (IReceive.Type == Trader.OfferType.OFFER_COLLECTIBLE) then
                        if (player:HasCollectible(IReceive.SubType, true)) then
                            player:RemoveCollectible(IReceive.SubType, true);
                            NiceDeal(player)
                        else
                            Cannot()
                        end
                    elseif (IReceive.Type == Trader.OfferType.OFFER_EMERALD) then
                        local Ticket = THI.Collectibles.ExchangeTicket;
                        if (Ticket.GetEmeralds(player) >= IReceive.SubType) then
                            Ticket.AddEmeralds(player, -IReceive.SubType);
                            NiceDeal(player)
                        else
                            Cannot()
                        end
                    end
                end
            end
        end
    end
end
Trader:AddCustomCallback(CLCallbacks.CLC_POST_PLAYER_COLLISION, Trader.PostPlayerCollision, 0);


-- function Trader:PostTraderKill(trader)
--     if (trader.Variant ==Trader.Variant) then
--         trader:ToNPC():Morph(trader.Type, trader.Variant, trader.SubType, 0);
--     end
-- end
-- Trader:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Trader.PostTraderKill, Trader.Type);

return Trader;