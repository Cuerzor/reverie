local Screen = CuerLib.Screen;
local Fire = ModEntity("Purple Magic Circle Fire", "MAGIC_CIRCLE")

Fire.SubTypes = {
    PURPLE = 0,
    RED = 1,
    CURSE = 2,
    BLACK = 3,
    GREY = 4
}
-- Main.
do
    local function PostFireUpdate(mod, fire)
        local spr = fire:GetSprite();
        if (spr:IsFinished("Appear")) then
            spr:Play("Idle")
        end
        if (spr:IsFinished("Disappear")) then
            fire:Remove();
        end

        local parent = fire.Parent;
        if (parent) then
            if (parent:Exists()) then
                fire.Position = parent.Position;
                fire.Velocity = parent.Velocity;
            else
                spr:Play("Disappear");
            end
        end
    end
    Fire:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostFireUpdate, Fire.Variant);

end

return Fire;