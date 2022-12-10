local Lib = LIB;
local Damages = Lib:NewClass();
function Damages.IsSelfDamage(entity, flags, source)
    return flags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) > 0;
end
return Damages;