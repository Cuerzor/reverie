local Screen = CuerLib.Screen;
local Collectibles = CuerLib.Collectibles
local Revive = CuerLib.Revive;
local Callbacks = CuerLib.Callbacks;
local Detection = CuerLib.Detection;

local FanOfTheDead = ModItem("Fan of the Dead", "FanOfTheDead");
FanOfTheDead.FontColor = KColor(1,1,1,1,0,0,0);

FanOfTheDead.Font = Font();
FanOfTheDead.Font:Load("font/pftempestasevencondensed.fnt");

FanOfTheDead.FanSprite = Sprite();
FanOfTheDead.FanSprite:Load("gfx/lives_fan.anm2", true);
FanOfTheDead.FanSprite:Play(FanOfTheDead.FanSprite:GetDefaultAnimation ( ));

local function GetPlayerData(player)
    return FanOfTheDead:GetData(player, true, function() return {
        Lives = 0
    } end);
end

local function CanRevive(player)
    if (not player:HasCollectible(FanOfTheDead.Item)) then
        return false;
    end

    -- local type = player:GetPlayerType();
    -- if (type == PlayerType.PLAYER_JACOB or type == PlayerType.PLAYER_ESAU) then
        
    --     local other = player:GetOtherTwin();
    --     if (other ~= nil) then
    --         local thisHas = player:HasCollectible(FanOfTheDead.Item) and GetPlayerData(player).Lives > 0;
    --         local otherHas = other:HasCollectible(FanOfTheDead.Item) and GetPlayerData(other).Lives > 0;
    --         return thisHas or otherHas;
    --     end
    -- end
    return GetPlayerData(player).Lives > 0;
end


local function AvoidDeath(player)
    local playerType = player:GetPlayerType();
    -- Create a heart to avoid player dies.
    -- The Forgotten creates bone hearts.
    if (playerType == PlayerType.PLAYER_THEFORGOTTEN) then
        local boneHearts = player:GetBoneHearts();
        if (boneHearts <= 0) then
            player:AddBoneHearts(1);
        end
    -- Keeper and Bethany creates heart containers.
    elseif (playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or playerType == PlayerType.PLAYER_BETHANY) then
        local maxHearts = player:GetMaxHearts();
        local hearts = player:GetMaxHearts();
        if (maxHearts <= 0) then
            player:AddMaxHearts(2);
        end
        if (hearts <= 0) then
            player:AddHearts(1);
        end
    -- Other characters;
    else
        local soulHearts = player:GetSoulHearts();
        if (soulHearts <= 0) then
            player:AddSoulHearts(1);
        end
    end

end

local function TransformHearts(player, data)
    
    local data = data or GetPlayerData(player);
    local maxHearts = player:GetMaxHearts();
    local type = player:GetPlayerType();
    local transformed = false;
    
    -- Keeper and Bethany will leave a heart container.
    if (type == PlayerType.PLAYER_KEEPER or type == PlayerType.PLAYER_KEEPER_B or type == PlayerType.PLAYER_BETHANY) then
        maxHearts = maxHearts - 2;
    end
    if (maxHearts > 0) then
        data.Lives = data.Lives + maxHearts;
        player:AddMaxHearts(-maxHearts, false);
        transformed = true;
    end
    
    -- The Forgotten will not check itself's Soul Hearts
    if (type ~= PlayerType.PLAYER_THEFORGOTTEN) then
        local soulHearts = player:GetSoulHearts() - 1;
        if (soulHearts > 0) then
            data.Lives = data.Lives + soulHearts;
            player:AddSoulHearts(-soulHearts);
            transformed = true;
        end
    end
    
    local boneHearts = player:GetBoneHearts();
    -- The Forgotten will leave a bone heart.
    if (type == PlayerType.PLAYER_THEFORGOTTEN) then
        boneHearts = boneHearts - 1;
    end
    if (boneHearts > 0) then
        data.Lives = data.Lives + boneHearts * 2;
        player:AddBoneHearts(-boneHearts);
        transformed = true;
    end
    
    -- The Forgotten will check its soul's Hearts.
    if (type == PlayerType.PLAYER_THEFORGOTTEN) then
        TransformHearts(player:GetSubPlayer(), data);
    end


    
    

    if (THI.IsLunatic()) then
        data.Lives = math.min(20, data.Lives);
    end

    
    if (transformed) then
        AvoidDeath(player);
    end
end


function FanOfTheDead:onPlayerEffect(player)
    
    if (player:HasCollectible(FanOfTheDead.Item)) then
        TransformHearts(player);
    end

end

function FanOfTheDead:postPickCollectible(player, item, count, touched)
    local playerType = player:GetPlayerType();
    TransformHearts(player);

    AvoidDeath(player);
end
FanOfTheDead:AddCustomCallback(CLCallbacks.CLC_POST_GAIN_COLLECTIBLE, FanOfTheDead.postPickCollectible, FanOfTheDead.Item);

local function PostRevive(player, reviver)   
    --local data = GetPlayerData(player);
    local reviverData = GetPlayerData(reviver);
    reviverData.Lives = reviverData.Lives - 1;
    -- local type = player:GetPlayerType();
    -- if (type == PlayerType.PLAYER_JACOB or type == PlayerType.PLAYER_ESAU) then
    --     local other = player:GetOtherTwin();
    --     local otherData = GetPlayerData(other);
    --     local thisHas = player:HasCollectible(FanOfTheDead.Item) and data.Lives > 0;
    --     local otherHas = other:HasCollectible(FanOfTheDead.Item) and otherData.Lives > 0;
        
    --     if (thisHas) then
    --         data.Lives = data.Lives - 1;
    --     else
    --         if (otherHas) then
    --             otherData.Lives = otherData.Lives - 1;
    --         end
    --     end
    -- else
    --     data.Lives = data.Lives - 1;
    -- end
end

local function RenderPlayer(player, playerIndex)
    if (player:HasCollectible(FanOfTheDead.Item) and THI.Game:GetHUD():IsVisible()) then
        local type = player:GetPlayerType();
        local data = GetPlayerData(player);
        local hudOffset = Options.HUDOffset;
        local x = 35+ 20 * hudOffset;;
        local y = 64 + 12 * hudOffset;
        local screenSize = Screen.GetScreenSize();
        local screenShake = THI.Game.ScreenShakeOffset;
        if (playerIndex == 0) then
            if (type == PlayerType.PLAYER_JACOB) then
                y = y + 14;
            end
        elseif (playerIndex == 1) then
            x = screenSize.X - 111 - 24 * hudOffset;
            local hearts = math.ceil(((player:GetMaxHearts() + player:GetSoulHearts()) / 2 + player:GetBoneHearts() + player:GetBrokenHearts()) / 3);
            y = hearts * 10 + 13 + 12 * hudOffset;;
        elseif (playerIndex == 2) then
            x = 43 + 22 * hudOffset;
            y = screenSize.Y - 64 - 6 * hudOffset;
        elseif (playerIndex == 3) then
            x = screenSize.X - 119 - 16 * hudOffset;
            y = screenSize.Y - 64 - 6 * hudOffset;
        end

        
        if (type == PlayerType.PLAYER_ESAU) then
            if (playerIndex == 0) then
                x = screenSize.X - 64 - 16 * hudOffset;
                y = screenSize.Y - 64 - 6 * hudOffset;;
            else
                return;
            end
        end
        
        FanOfTheDead.FanSprite:Render(Vector(x, y), Vector.Zero, Vector.Zero);
        FanOfTheDead.Font:DrawString(data.Lives, x+8 + screenShake.X, y-7 + screenShake.Y,FanOfTheDead.FontColor, 0, true)
    end
end

function FanOfTheDead:onRender()   
    local controllers = {};
    local playerIndex = 0;
    for i, player in Detection.PlayerPairs() do
        -- If is not a coop baby.
        if (player.Variant == 0 and controllers[player.ControllerIndex] ~= true) then
            local type = player:GetPlayerType();
            RenderPlayer(player, playerIndex);
            if (type == PlayerType.PLAYER_JACOB) then
                local other = player:GetOtherTwin();
                RenderPlayer(other, playerIndex);
            end
            controllers[player.ControllerIndex] = true;
            playerIndex = playerIndex + 1;
        end
    end
end


function FanOfTheDead:onEvaluateCache(player, flag)
    if (player:HasCollectible(FanOfTheDead.Item)) then
        if (flag == CacheFlag.CACHE_FLYING) then
            player.CanFly = true;
        elseif (flag == CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL;
        end
    end
end



Revive.AddReviveInfo(true, 60, "LostDeath", CanRevive, PostRevive);
FanOfTheDead:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FanOfTheDead.onPlayerEffect);
--FanOfTheDead:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, FanOfTheDead.onPlayerUpdate);
FanOfTheDead:AddCallback(ModCallbacks.MC_POST_RENDER, FanOfTheDead.onRender);
FanOfTheDead:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FanOfTheDead.onEvaluateCache);

return FanOfTheDead;