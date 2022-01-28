local Lib = CuerLib;
local Inputs = {

}

function Inputs.DisabledInput(hook)
    if (hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED) then
        return false;
    elseif (hook == InputHook.GET_ACTION_VALUE) then
        return 0;
    end
end

function Inputs.IsPressingShoot(player)
    if (player:AreControlsEnabled ()) then
        local controller = player.ControllerIndex;
        if (controller == 0) then
            if (Input.IsMouseBtnPressed(0)) then
                return true;
            end
        end
        return Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controller) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controller) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controller) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controller);
    end
    return false;
end


-- Get Raw Shooting Vector of a player.
-- **center**: The position to be relative from mouse position if using mouse.
function Inputs.GetRawShootingVector(player, center)
    
    if (not player:AreControlsEnabled ( )) then
        return Vector.Zero;
    end

    center = center or player.Position;
    if (player.ControllerIndex == 0) then
        if (Input.IsMouseBtnPressed(0)) then
            return (Input.GetMousePosition(true) - center):Normalized();
        end
    end
    return player:GetShootingJoystick();
end

-- local pressed = {};
-- function Inputs.IsActionDown(action, controllerIndex)
--     pressed[tostring(controllerIndex)] = pressed[tostring(controllerIndex)] or {};
--     local controllerData = pressed[tostring(controllerIndex)];

--     local actionKey = tostring(action);
--     if (Input.IsActionPressed(action, controllerIndex)) then
--         if (not controllerData[actionKey]) then
--             controllerData[actionKey] = true;
--             return true;
--         end
--     else
--         controllerData[actionKey] = false;
--     end
--     return false;
-- end

local actionsData = {};
function Inputs.GetActionHoldTime(action, controllerIndex)
    local controllerData = actionsData[tostring(controllerIndex)];
    if (controllerData) then
        local actionData = controllerData[action];
        if (actionData) then
            local time = actionData.ActionHoldTime;
            return time or 0;
        end
    end
    return 0;
end
function Inputs.IsActionDown(action, controllerIndex)
    local controllerData = actionsData[tostring(controllerIndex)];
    if (controllerData) then
        local actionData = controllerData[action];
        if (actionData) then
            local pressed = actionData.ActionDown;
            return pressed;
        end
    end
    return false;
end

local function PostUpdate(mod, player)

    local game = Game();
    for i = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(i);
        local key = tostring(player.ControllerIndex);
        actionsData[key] = actionsData[key] or {};
    end

    for index, controllerData in pairs(actionsData) do
        local allNil = true;
        for action = ButtonAction.ACTION_LEFT, ButtonAction.ACTION_MENUTAB do
            controllerData[action] = controllerData[action] or {};
            local actionData = controllerData[action] ;
            if (Input.IsActionPressed(action, tonumber(index))) then
                actionData.ActionDown = not actionData.ActionPressed
                actionData.ActionPressed = true;
                actionData.ActionHoldTime = (actionData.ActionHoldTime or 0) + 1;
                allNil = false;
            else
                actionData.ActionDown = false;
                actionData.ActionPressed = false;
                actionData.ActionHoldTime = nil;
            end
        end
        if (allNil) then
            actionsData[index] = nil;
        end
    end
end

function Inputs:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);
end

return Inputs;