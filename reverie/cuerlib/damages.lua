local Lib = _TEMP_CUERLIB;
local Callbacks = Lib.Callbacks;
local Damages = Lib:NewClass();

function Damages:PreEntityTakeDamage(entity, amount, flags, source, countdown)
    for i, info in pairs(Callbacks.Functions.PreEntityTakeDamage) do
        if (info.OptionalArg == nil or info.OptionalArg <= 0 or entity.Type == info.OptionalArg) then
            local result = info.Func(info.Mod, entity, amount, flags, source, countdown);
            if (result == false) then
                return result;
            end
        end
    end


    for i, info in pairs(Callbacks.Functions.PostEntityTakeDamage) do
        if (info.OptionalArg == nil or info.OptionalArg <= 0 or entity.Type == info.OptionalArg) then
            info.Func(info.Mod, entity, amount, flags, source, countdown);
        end
    end
end
Damages:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Damages.PreEntityTakeDamage);

function Damages.IsSelfDamage(entity, flags, source)
    local ivBag = flags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE) > 0;
    if (ivBag) then
        return true;
    end

    if (source) then
        if (source.Type == EntityType.ENTITY_SLOT) then
            return true;
        end

        if (source.Entity) then
            if (source.Type == entity.Type and GetPtrHash(source.Entity) == GetPtrHash(entity)) then
                return true;
            end
        -- else
        --     return true;
        end
    end
    return false;
end
return Damages;