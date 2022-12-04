local Opt = {
    CancelNum = 0,
    LastPauseFocus = nil
}


function Opt:CancelPauseFocus()
    self.CancelNum = self.CancelNum + 1;
    if (not self.LastPauseFocus) then
        self.LastPauseFocus = Options.PauseOnFocusLost;
        Options.PauseOnFocusLost = false;
    end
end

function Opt:ResumePauseFocus()
    if (self.CancelNum > 0) then
        self.CancelNum = self.CancelNum - 1;
        if (self.CancelNum <= 0 and self.LastPauseFocus) then
            Options.PauseOnFocusLost = self.LastPauseFocus;
            self.LastPauseFocus = nil;
        end
    end
end

function Opt:ClearPauseFocus()
    Opt.CancelNum = 0;
    if (Opt.LastPauseFocus) then
        Options.PauseOnFocusLost = Opt.LastPauseFocus;
        Opt.LastPauseFocus = nil;
    end
end

local function Clear(mod)
    Opt:ClearPauseFocus()
end
THI:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Clear);
THI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Clear);


return Opt;