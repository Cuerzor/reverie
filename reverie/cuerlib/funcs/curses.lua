local Lib = LIB;
local Curses = Lib:NewClass();

local function EvaluateCurse(curses)
    curses = curses or Game():GetLevel():GetCurses();
    local callbacks = Isaac.GetCallbacks(Lib.CLCallbacks.CLC_EVALUATE_CURSE);
    for _, callback in pairs(callbacks) do
        local result = callback.Function(callback.Mod, curses);
        if (result ~= nil) then
            if (type(result) == "number") then
                curses = result;
            else
                error("Trying to return a value which is not a number or nil in EVALUATE_CURSE.");
            end
        end
    end
    return curses;
end
function Curses:EvaluateCurses()
    local level = Game():GetLevel();
    local beforeCurses = level:GetCurses();
    local curses = EvaluateCurse();

    local removedCurses = ~curses & beforeCurses;
    local addedCurses = ~beforeCurses & curses;

    -- Avoid remove Curse of Labyrinth.
    removedCurses = removedCurses & ~LevelCurse.CURSE_OF_LABYRINTH;
    addedCurses = addedCurses & ~LevelCurse.CURSE_OF_LABYRINTH;
    level:RemoveCurses(removedCurses);
    level:AddCurse(addedCurses);
end

local function OnCurseEvaluate(mod, curses)
    local newCurses = EvaluateCurse(curses);
    return newCurses;
end
Curses:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, OnCurseEvaluate);

return Curses;