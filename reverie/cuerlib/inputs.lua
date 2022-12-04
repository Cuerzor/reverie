local Lib = _TEMP_CUERLIB;
local Inputs = Lib:NewClass();

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

    if (Options.MouseControl) then
        center = center or player.Position;
        if (player.ControllerIndex == 0) then
            if (Input.IsMouseBtnPressed(0)) then
                return (Input.GetMousePosition(true) - center):Normalized();
            end
        end
    end
    return player:GetShootingJoystick();
end

function Inputs:GetShootingVector(player, center)
    center = center or player.Position;
    local shooting = self.GetRawShootingVector(player, center);
    local target = Lib.Synergies:GetMarkedTarget(player);
    if (target) then
        shooting = target.Position - player.Position;
    elseif (not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) and shooting:Length() > 0) then
        if (math.abs(shooting.Y) >= math.abs(shooting.X)) then
            shooting = Vector(0, shooting.Y);
        elseif (shooting.X ~= 0) then
            shooting = Vector(shooting.X, 0);
        end
    end
    return shooting:Normalized();
end


return Inputs;