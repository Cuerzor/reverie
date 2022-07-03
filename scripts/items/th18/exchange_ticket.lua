local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local CompareEntity = Detection.CompareEntity;
local Players = CuerLib.Players;
local Ticket = ModItem("Exchange Ticket", "EXCTicket");

Ticket.Exchange = {
    Type = RoomType.ROOM_CHEST,
    Variant = 5800
}
THI.Shared.SoftlockFix:AddModGotoRoom(Ticket.Exchange.Type, Ticket.Exchange.Variant);


local EmeraldFont = THI.Fonts.PFTempesta7;
local EmeraldSprite = Sprite();
EmeraldSprite:Load("gfx/reverie/emerald_icon.anm2", true);
EmeraldSprite:Play("Icon");

function Ticket.GetPlayerData(player, init)
    return Ticket:GetData(player, init, function() return {
        Emeralds = 0
    } end)
end

function Ticket.GetEmeralds(player, wisps)
    local data = Ticket.GetPlayerData(player, false);
    local emeralds = (data and data.Emeralds) or 0;
    if (wisps == true) then
        emeralds = 0;
    end

    if (wisps ~= false) then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Ticket.Item)) do
            if (CompareEntity(ent:ToFamiliar().Player, player)) then
                emeralds = emeralds + 1;
            end
        end
    end
    return emeralds;
end

function Ticket.AddEmeralds(player, value)
    local data = Ticket.GetPlayerData(player, true);
    
    if (value < 0) then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Ticket.Item)) do
            if (not ent:IsDead() and ent:Exists() and CompareEntity(ent:ToFamiliar().Player, player)) then
                value = value + 1;
                ent:Kill();
            end
        end
    end
    data.Emeralds = data.Emeralds + value;
end

function Ticket.IsExchange(type, variant)
    local room = THI.Game:GetRoom();
    local level = THI.Game:GetLevel();
    local desc = level:GetCurrentRoomDesc();
    local config = desc.Data;

    type = type or config.Type;
    variant = variant or config.Variant;

    return type == Ticket.Exchange.Type and variant == Ticket.Exchange.Variant;
end
function Ticket.PostNewRoom()
    if (Ticket.IsExchange()) then
        local game = Game();
        local room = game:GetRoom();

        room:SetClear (true);


        -- Spawn Traders.
        local Trader = THI.Slots.Trader;
        Trader.CheckAllPlayerCollectibles();
        for x = 1, 3, 1 do
            for y = 0, 1 do
                Trader.SpawnTrader(Trader.Services.SERVICE_BUY, Vector(160 + x * 80, 260 + y * 80), Random());
            end
        end
        
        for x = 1, 3, 1 do
            for y = 0, 1 do
                Trader.SpawnTrader(Trader.Services.SERVICE_SELL, Vector(160 + x * 80, 500 + y * 80), Random());
            end
        end
        Trader.UpdateBuyableCache()
        
        for x = 1, 3, 1 do
            for y = 0, 1 do
                Trader.SpawnTrader(Trader.Services.SERVICE_BARTER, Vector(680 + x * 80, 500 + y * 80), Random());
            end
        end
        Trader.UpdateBuyableCache()
        
        for x = 1, 3, 1 do
            for y = 0, 1 do
                Trader.SpawnTrader(Trader.Services.SERVICE_RECOVERY, Vector(680 + x * 80, 260 + y * 80), Random());
            end
        end
        Trader.ClearSpawnCache()
    end
end
Ticket:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Ticket.PostNewRoom);


function Ticket:PostUseTicket(item, rng, player, flags, slot, varData)
    local beastExists = #Isaac.FindByType(EntityType.ENTITY_BEAST) > 0;
    
    if (not beastExists) then
        THI.GotoRoom("s.chest."..Ticket.Exchange.Variant);
        THI.Game:StartRoomTransition (-3, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player);
    else
        local room = Game():GetRoom();
        local pos = room:GetRandomPosition(160);
        Players.TeleportToPosition(player, pos);
    end
end
Ticket:AddCallback(ModCallbacks.MC_USE_ITEM, Ticket.PostUseTicket, Ticket.Item);

function Ticket:PostRender()
    local game = THI.Game;
    for p, player in Detection.PlayerPairs() do
        if (Ticket.IsExchange()) then
            local pos = Screen.GetEntityRenderPosition(player, Vector(6, 32))
            EmeraldSprite:Render(pos);

            local str = tostring(Ticket.GetEmeralds(player, false));
            EmeraldFont:DrawString(str, pos.X, pos.Y - 16, KColor.White);
            
            local wispEmeralds = Ticket.GetEmeralds(player, true);
            if (wispEmeralds > 0) then
                EmeraldFont:DrawString("+"..wispEmeralds, pos.X + EmeraldFont:GetStringWidth(str) + 4, pos.Y - 16, KColor.Green);
            end
        end
    end
end
Ticket:AddCallback(ModCallbacks.MC_POST_RENDER, Ticket.PostRender);

-- function Ticket.PreGameExit(shouldSave)
--     if (shouldSave) then
--         if (Ticket.IsExchange()) then
--             local level = THI.Game:GetLevel()
--             local lastRoom = level:GetLastRoomDesc ( )
--             print(lastRoom.SafeGridIndex);
--             THI.Game:ChangeRoom(lastRoom.SafeGridIndex);
--         end
--     end
-- end
-- Ticket:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Ticket.PreGameExit);

return Ticket;