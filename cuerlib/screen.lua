local Screen = {
    
}

function Screen.GetScreenSize() 
    --return (Isaac.WorldToScreen(Vector(320, 280)) - THI.Game:GetRoom():GetRenderScrollOffset() - THI.Game.ScreenShakeOffset) * 2
    return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight());
end

function Screen.GetOffsetedRenderPosition(pos, offset)
    local game = THI.Game;
    local room = game:GetRoom();
    return Isaac.WorldToScreen(pos) + offset - room:GetRenderScrollOffset() - game.ScreenShakeOffset;
end

function Screen.GetEntityOffsetedRenderPosition(entity, offset, positionOffset, noModifier)
    positionOffset = positionOffset or Vector.Zero;
    local game = THI.Game;
    local room = game:GetRoom();
    
    if (not noModifier) then
        if (Screen.IsReflection()) then
            positionOffset = -positionOffset;
        end
    end
    return Screen.GetOffsetedRenderPosition(entity.Position + entity.PositionOffset + positionOffset, offset);
end

function Screen.IsReflection()
    local game = THI.Game;
    local room = game:GetRoom();
    -- local offset =  renderOffset - room:GetRenderScrollOffset() ;
    -- if (offset:Length() - game.ScreenShakeOffset:Length() > 0.1) then
    --     return true;
    -- end
    -- return false;
    return room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT;
end

function Screen.GetEntityRenderPosition(entity, positionOffset, noModifier)
    positionOffset = positionOffset or Vector.Zero;
    local game = THI.Game;
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

return Screen;