local Trail = ModEntity("Player Trail", "PLAYER_TRAIL");

Trail.SubTypes = {
    RAINBOW = 0,
    HORSESHOE = 1,
    KAGEROU = 2
}
local function PostTrailUpdate(mod, trail)
    local frame = trail.FrameCount;
    local maxFrame = 12;
    if (trail.SubType == Trail.SubTypes.RAINBOW) then
        local function GetComponent(offset)
            local f = frame + offset;
            local interval = 6;
            local dir = math.floor(f / interval) % 2;
            local x = f % interval;
            if (dir == 0) then
                return math.min(1, math.max(2 - x * 0.5, 0))
            else
                return math.min(1, math.max(x * 0.5 - 1, 0))
            end
        end
        local r = GetComponent(0)
        local g = GetComponent(4)
        local b = GetComponent(8);
        local a = 1 - frame / maxFrame;
        trail:GetSprite().Color = Color(r, g, b, a, 0, 0, 0);
    elseif (trail.SubType == Trail.SubTypes.HORSESHOE) then
        local a = 1 - frame / maxFrame;
        trail:GetSprite().Color = Color(1, 0, 0, a, 0, 0, 0);
    elseif (trail.SubType == Trail.SubTypes.KAGEROU) then
        local a = 1 - frame / maxFrame;
        trail:GetSprite().Color = Color(0.3,0,1,a / 2,0,0,0.5)
    end
    if (frame >= maxFrame) then
        trail:Remove();
    end
end
Trail:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostTrailUpdate, Trail.Variant)
Trail:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostTrailUpdate, Trail.Variant)

return Trail;