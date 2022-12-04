local Screen = CuerLib.Screen;
local RagingDemon = ModEntity("Raging Demon Background", "RAGING_DEMON_BG");

function RagingDemon:GetBGData(entity, create)
    return RagingDemon:GetTempData(entity, create, function ()
        return {
            BlackscreenSprite = nil,
            SymbolSprite = nil
        }
    end)
end

function RagingDemon:PostInit(effect)
    effect.Timeout = 30;
end
RagingDemon:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RagingDemon.PostInit, RagingDemon.Variant);

function RagingDemon:PostUpdate(effect)


    local data = RagingDemon:GetBGData(effect, true);
    if (not data.BlackscreenSprite) then
        local spr = Sprite();
        spr:Load("gfx/reverie/1000.5853_raging demon background.anm2", true);
        spr:Play("BlackScreen");
        data.BlackscreenSprite = spr;
    end
    if (not data.SymbolSprite) then
        local spr = Sprite();
        spr:Load("gfx/reverie/1000.5853_raging demon background.anm2", true);
        spr:Play("Idle");
        data.SymbolSprite = spr;
    end

    if (effect.Timeout > 0) then
        effect.Timeout = effect.Timeout - 1;
    end
    
    if (effect.Timeout < 15) then
        local color = Color(1,1,1,effect.Timeout / 15);
        data.BlackscreenSprite.Color = color;
        data.SymbolSprite.Color = color;
    end
    effect.Position = Vector(effect.Position.X, 70);
    if (effect.Timeout == 0) then
        effect:Remove();
    end
end
RagingDemon:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RagingDemon.PostUpdate, RagingDemon.Variant);


function RagingDemon:PostRender(effect, offser)
    local data = RagingDemon:GetBGData(effect, false);
    if (data) then
        local black = data.BlackscreenSprite;
        local symbol = data.SymbolSprite;
        black:Render(Vector.Zero, Vector.Zero, Vector.Zero);
        symbol:Render(Screen.GetScreenSize() / 2, Vector.Zero, Vector.Zero);
    end
end
RagingDemon:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, RagingDemon.PostRender, RagingDemon.Variant);

return RagingDemon;