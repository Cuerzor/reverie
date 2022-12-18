local Lib = LIB
local Screen = Lib:NewClass();

function Screen.GetScreenSize() 
    return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight());
end

function Screen.GetOffsetedRenderPosition(pos, offset)
    local game = Game();
    local room = game:GetRoom();
    return Isaac.WorldToScreen(pos) + offset - room:GetRenderScrollOffset() - game.ScreenShakeOffset;
end

function Screen.GetEntityOffsetedRenderPosition(entity, offset, positionOffset, noModifier)
    positionOffset = positionOffset or Vector.Zero;
    local game = Game();
    local room = game:GetRoom();
    
    if (not noModifier) then
        if (Screen.IsReflection()) then
            positionOffset = -positionOffset;
        end
    end
    return Screen.GetOffsetedRenderPosition(entity.Position + entity.PositionOffset + positionOffset, offset);
end

function Screen.IsReflection()
    local game = Game();
    local room = game:GetRoom();
    return room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT;
end

function Screen.GetEntityRenderPosition(entity, positionOffset, noModifier)
    positionOffset = positionOffset or Vector.Zero;
    local game = Game();
    local room = game:GetRoom();
    
    if (not noModifier) then
        if (room:IsMirrorWorld()) then
            local offset = Vector(-positionOffset.X, positionOffset.Y);
            local pos = Isaac.WorldToScreen(entity.Position + entity.PositionOffset +offset ) + game.ScreenShakeOffset;
            return Vector(Isaac.GetScreenWidth()-pos.X, pos.Y);
        end
    end
    return Isaac.WorldToScreen(entity.Position + entity.PositionOffset + positionOffset) + game.ScreenShakeOffset;
end

local function GetShaderParams(mod, name)
    if (name == "CUERLIB HUD Hack") then
        Isaac.RunCallback(Lib.Callbacks.CLC_RENDER_OVERLAY);
    end
end
Screen:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);

-- Avoid Shader Crash.
Screen:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

return Screen;