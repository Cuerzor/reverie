local Screen = CuerLib.Screen;
local Stats = CuerLib.Stats;
local Collectibles = CuerLib.Collectibles;

local WolfEye = ModItem("Wolf Eye", "WOLF_EYE");

WolfEye.IndicatorSprite = Sprite();
WolfEye.IndicatorSprite:Load("gfx/reverie/wolf_eye_indicator.anm2");
WolfEye.IndicatorSprite:Play("Idle");


WolfEye.IndicatorLightSprite = Sprite();
WolfEye.IndicatorLightSprite:Load("gfx/reverie/wolf_eye_indicator_light.anm2");
WolfEye.IndicatorLightSprite:Play("Idle");

WolfEye.HasItem = false;

local function UpdateVisibleRooms()
    local level = THI.Game:GetLevel();

    local leftmost, rightmost, upmost, downmost = 13, 0, 13, 0;
    for rx = 0, 12 do
        for ry = 0, 12 do
            local curIndex = ry * 13 + rx;
            local curRoom = level:GetRoomByIdx(curIndex);
            if (curRoom.Data and curRoom.Data.Type ~= RoomType.ROOM_ULTRASECRET) then
                if (rx < leftmost) then
                    leftmost = rx;
                end
                if (rx > rightmost) then
                    rightmost = rx;
                end
                if (ry < upmost) then
                    upmost = ry;
                end
                if (ry > downmost) then
                    downmost = ry;
                end
            end
        end
    end

    for side = 0, 1 do
        for rx = leftmost, rightmost do
            local curIndex;
            if (side == 0) then
                curIndex = upmost * 13 + rx;
            else
                curIndex = downmost * 13 + rx;
            end
            local curRoom = level:GetRoomByIdx(curIndex);
            if (curRoom.Data and curRoom.Data.Type ~= RoomType.ROOM_ULTRASECRET) then
                curRoom.DisplayFlags = curRoom.DisplayFlags | 7;
            end
        end
    end
    for side = 0, 1 do
        for ry = upmost, downmost do
            local curIndex;
            if (side == 0) then
                curIndex = ry * 13 + leftmost;
            else
                curIndex = ry * 13 + rightmost;
            end
            local curRoom = level:GetRoomByIdx(curIndex);;
            if (curRoom.Data and curRoom.Data.Type ~= RoomType.ROOM_ULTRASECRET) then
                curRoom.DisplayFlags = curRoom.DisplayFlags | 7;
            end
        end
    end

    level:UpdateVisibility ( );
end

local function GetPlayerData(player, create)
    return WolfEye:GetData(player, create, function()
        return {
            HasEffect = false
        }
    end)
end

local function PostUpdate(mod)
    WolfEye.IndicatorSprite:Update();
    WolfEye.IndicatorLightSprite:Update();
    WolfEye.HasItem = Collectibles.IsAnyHasCollectible(WolfEye.Item);
end
WolfEye:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PostRender(mod)
    if (WolfEye.HasItem) then
        for i, ent in pairs(Isaac.FindByType(9)) do
            local proj = ent:ToProjectile();
            if (not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)) then
                local pos = Screen.GetEntityRenderPosition(proj);
                local size = proj.Size / 8;
                WolfEye.IndicatorLightSprite.Scale = Vector(size, size);
                WolfEye.IndicatorLightSprite:Render(pos, Vector.Zero, Vector.Zero);

                WolfEye.IndicatorSprite.Color = proj:GetColor();
                WolfEye.IndicatorSprite.Scale = Vector(size, size);
                WolfEye.IndicatorSprite:Render(pos, Vector.Zero, Vector.Zero);

            end
        end
    end
end
WolfEye:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender)

local function PostNewLevel()
    if (Collectibles.IsAnyHasCollectible(WolfEye.Item)) then
        UpdateVisibleRooms();
    end
end
WolfEye:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel)

local function PostPlayerEffect(mod, player)
    if (player:HasCollectible(WolfEye.Item)) then
        local data = GetPlayerData(player, true);
        if (not data.HasEffect) then
            data.HasEffect = true;
            UpdateVisibleRooms();
        end
    else
        local data = GetPlayerData(player, false);
        if (data and data.HasEffect) then
            data.HasEffect = false;
        end
    end
end
WolfEye:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

local function EvaluateCache(mod, player, flag)
    local num = player:GetCollectibleNum(WolfEye.Item);
    if (flag == CacheFlag.CACHE_DAMAGE) then
        Stats:AddDamageUp(player, num * 0.5);
    end
end
WolfEye:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)

return WolfEye;