local Planet = ModEntity("Hell Planet", "HELL_OTHERWORLD");
Planet.SubTypes = {
    OTHERWORLD = 0,
    EARTH = 1,
    MOON = 2
}
Planet.OrbitConfigs = {
    [Planet.SubTypes.OTHERWORLD] = {
        Distance = Vector(110, 90),
        Speed = 0.02,
        Layer = 3,
    },
    [Planet.SubTypes.EARTH] = {
        Distance = Vector(68, 61.38),
        Speed = 0.045,
        Layer = 2,
    },
    [Planet.SubTypes.MOON] = {
        Distance = Vector(42, 34.38),
        Speed = 0.075,
        Layer = 1,
    }
}

function Planet:GetPlanetPosition(familiar, playerCentered)
    local parent = familiar.Parent or familiar.Player;
    if (familiar.Player and (familiar.Player:HasTrinket(TrinketType.TRINKET_DUCT_TAPE) or playerCentered)) then
        parent = familiar.Player;
    end
    local layer = 0;
    local config = Planet.OrbitConfigs[familiar.SubType];
    familiar.OrbitDistance = (config and config.Distance) or EntityFamiliar.GetOrbitDistance(layer);
    familiar.OrbitSpeed = (config and config.Speed) or 0.02;
    familiar.OrbitLayer = (config and config.Layer) or 3;
    if (parent) then
        return parent.Position + familiar:GetOrbitPosition(Vector.Zero);
    end
    return familiar.Position;
end

local PlanetPositionOffset = Vector(0, -24);

local function GetPlanetData(planet, create)
    local function default()
        return {
            IsOrbiting = false
        }
    end
    return Planet:GetData(planet, create, default)
end

local function SetOrbital(planet, value)
    local data = GetPlanetData(planet, true);
    if (data.IsOrbiting ~= value) then
        data.IsOrbiting = value;
        if (value) then
            local config = Planet.OrbitConfigs[planet.SubType];
            local layer = (config and config.Layer) or 3;
            planet:ToFamiliar():AddToOrbit(layer);
            planet.PositionOffset = PlanetPositionOffset;
        else
            planet:ToFamiliar():RemoveFromOrbit();
        end
    end
end

local function PostFamiliarInit(mod, familiar)
    if (familiar.Variant == Planet.Variant) then
        local spr = familiar:GetSprite();
        SetOrbital(familiar, true)
        if (familiar.SubType == Planet.SubTypes.EARTH) then
            spr:Load("gfx/reverie/003.5822.1_planet earth.anm2", true);
            spr:Play("Idle");
            familiar.CollisionDamage = 5;
            familiar.Size = 17;
        elseif (familiar.SubType == Planet.SubTypes.MOON) then
            spr:Load("gfx/reverie/003.5822.2_planet moon.anm2", true);
            spr:Play("Idle");
            familiar.CollisionDamage = 3;
            familiar.Size = 11;
        end
    end
end
Planet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PostFamiliarInit)

local function PostFamiliarUpdate(mod, familiar)
    if (familiar.Variant == Planet.Variant) then
        if (Game():GetRoom():GetFrameCount()> 0) then
            familiar.Velocity = Planet:GetPlanetPosition(familiar) - familiar.Position;
        else
            familiar.Velocity = Vector.Zero;
        end
    end
end
Planet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFamiliarUpdate)

local function PostGameStarted(mod, isContinued)
    for i, ent in pairs(Isaac.FindByType(Planet.Type, Planet.Variant)) do
        ent.Velocity = Vector.Zero;
    end
end
Planet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)

local function PostNewRoom(mod)
    for i, ent in pairs(Isaac.FindByType(Planet.Type, Planet.Variant)) do
        ent.Position = Planet:GetPlanetPosition(ent:ToFamiliar())
    end
end
Planet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

local function PostFamiliarCollision(mod, familiar, other, low)
    if (other.Type == EntityType.ENTITY_PROJECTILE) then
        local proj = other:ToProjectile();
        if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
            other:Die();
        end
    end
end
Planet:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, PostFamiliarCollision, Planet.Variant)

return Planet;