local Lib = LIB;
local Inputs = Lib:NewClass();

local function GetTempPlayerData(player, create)
    local data = Lib:GetEntityLibData(player, true);
    if (create and not data.INPUTS) then
        data.INPUTS = {}
    end
    return data.INPUTS;
end

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

function Inputs.GetShootingVector(player, center)
    center = center or player.Position;
    local shooting = self.GetRawShootingVector(player, center);
    local target = Lib.Synergies.GetMarkedTarget(player);
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


function Inputs.IsDoubleTapped(player)
    local playerData = GetTempPlayerData(player, false);
    return playerData and playerData.DoubleTapped or false;
end

local function PlayerDoubleTapUpdate(mod, player)

	local playerData = GetTempPlayerData(player, true);

	local input = player:GetAimDirection()
	local inputPressed = input:Length() > 0;
	local inputDir = math.floor(input:GetAngleDegrees() / 90 + 0.5) % 4;
	if (not playerData.InputState or playerData.InputState == 0) then -- You need to release keys to double tap.
		if (not inputPressed) then
			playerData.InputTimeout = 0;
			playerData.InputState = 1;
		end
	elseif (playerData.InputState == 1) then -- press first.
		if (inputPressed) then
			playerData.InputTimeout = 6;
			playerData.InputDir = inputDir;
			playerData.InputState = 2;
		end
	elseif (playerData.InputState == 2) then --release.
		if (not inputPressed) then
			playerData.InputState = 3;
		end
	elseif (playerData.InputState == 3) then --press twice.
		if (inputPressed and inputDir == playerData.InputDir) then
			playerData.InputTimeout = 2;
			playerData.DoubleTapped = true;
			playerData.InputState = 4;
		end
	end

    if (playerData.InputTimeout and playerData.InputTimeout > 0) then
        playerData.InputTimeout = playerData.InputTimeout - 1;
	    if (playerData.InputTimeout <= 0) then
            playerData.InputDir = -1;
            playerData.InputState = 0;
            playerData.DoubleTapped = false;
        end
    end
end
Inputs:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerDoubleTapUpdate);

return Inputs;