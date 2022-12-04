local Dream = GensouDream;
local EmptySpell = Dream.SpellCard();
EmptySpell.Name = "EmptySpell";
    
function EmptySpell:GetDuration()
    return 0;
end

return EmptySpell;