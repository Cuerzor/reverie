

local Consts = SINGLETON:NewClass();

Consts.Vectors = {
    One = Vector(1,1)
}
local poopTearColor = Color(1.5, 1.5, 1.5, 1, -0.4, -0.45, -0.4);
poopTearColor:SetColorize(0.625, 0.6, 0.5, 1);
Consts.Colors = {
    HitColor = Color(1,1,1,1,0.5,0,0),
    Clear = Color(0, 0, 0, 0, 0, 0, 0),
    HomingTear = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549),
    BounceTear = Color(1, 1, 0.8, 1, 0.1, 0.1, 0.1),
    BurnTear = Color(1,0.8,0,1,0.3,0,0),
    PoisonTear = Color(0.4, 0.97, 0.5, 1, 0, 0, 0),
    PoopTear = poopTearColor,
    Green = Color(0,1,0,1,0,0,0),
}
Consts.DirectionVectors = {
    [-1] = Vector(0, 0),
    [0] = Vector(-1, 0),
    [1] = Vector(0, -1),
    [2] = Vector(1, 0),
    [3] = Vector(0, 1)
}
Consts.DirectionAngles = {
    [-1] = 0,
    [0] = 90,
    [1] = 180,
    [2] = -90,
    [3] = 0
}
Consts.DirectionStrings = {
    [Direction.LEFT] = "Left",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Right",
    [Direction.DOWN] = "Down"
}

function Consts.GetDirectionString(dir)
    return Consts.DirectionStrings[dir] or "";
end
return Consts;