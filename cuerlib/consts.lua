local BurnTearColor = Color(1,0.8,0,1,0.3,0,0);

local poopTearColor = Color(1.5, 1.5, 1.5, 1, -0.4, -0.45, -0.4);
poopTearColor:SetColorize(0.625, 0.6, 0.5, 1);

local Consts = {
    Vectors = {
        One = Vector(1,1)
    },
    Colors = {
        HitColor = Color(1,1,1,1,0.5,0,0),
        Clear = Color(0, 0, 0, 0, 0, 0, 0),
        HomingTear = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549),
        BounceTear = Color(1, 1, 0.8, 1, 0.1, 0.1, 0.1),
        BurnTear = BurnTearColor,
        PoisonTear = Color(0.4, 0.97, 0.5, 1, 0, 0, 0),
        PoopTear = poopTearColor;
    },
    DirectionVectors = {
        [0] = Vector(0, 0),
        [1] = Vector(-1, 0),
        [2] = Vector(0, -1),
        [3] = Vector(1, 0),
        [4] = Vector(0, 1)
    },
    DirectionAngles = {
        [0] = 0,
        [1] = 90,
        [2] = 180,
        [3] = -90,
        [4] = 0
    },
}

local DirectionAnimations = {
    [Direction.LEFT] = "Left",
    [Direction.UP] = "Up",
    [Direction.RIGHT] = "Right",
    [Direction.DOWN] = "Down"
}

function Consts.GetDirectionString(dir)
    return DirectionAnimations[dir] or DirectionAnimations[Direction.DOWN];
end
function Consts.GetDirectionVector(dir)
    return Consts.DirectionVectors[dir + 1];
end
return Consts;