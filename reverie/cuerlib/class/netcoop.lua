local Lib = LIB;
local NetCoop = Lib:NewClass();

local isNetCoop = false;
local playerControllerList = {};
local records = false;
function NetCoop.IsNetCoop()
    return isNetCoop;
end


local function PostPlayerInit(mod, player)
    if (Game():GetFrameCount() <= 0) then
        records = true;
    end
end
NetCoop:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, PostPlayerInit)
local function PostPlayerUpdate(mod, player)
    if (records) then
        if (player.Variant == 0 and not player.Parent) then
            playerControllerList[player.ControllerIndex] = true;
        end
    end
end
NetCoop:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, PostPlayerUpdate)

local function PostGameStarted(mod, isContinued)
    isNetCoop = false;
    if (not isContinued) then
        local playerNum = 0;
        for i, value in pairs(playerControllerList) do
            if (value) then
                playerNum = playerNum + 1;
            end
        end
        if (playerNum > 1) then
            isNetCoop = true;
        end
        records = false;
        playerControllerList = {};
    end
end
NetCoop:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, PostGameStarted)

return NetCoop;