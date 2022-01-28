local Lib = CuerLib;
local Callbacks = Lib.Callbacks;
local Screen = CuerLib.Screen;
local Shields = {};

local spr = Sprite();
spr:Load("gfx/characters/058_book of shadows.anm2", true);
spr:SetAnimation("WalkDown");

function Shields:GetPlayerData(player, init)
    local data = Lib:GetData(player);
    if (init) then
        data.Shields = data.Shields or  {
            ShieldTime = 0,
            ShieldFrame = 0
        }
    end
    return data.Shields;
end

function Shields:AddShield(player, time)
    local playerData = Shields:GetPlayerData(player, true);
    playerData.ShieldFrame = 0;
    playerData.ShieldTime = playerData.ShieldTime + time;
    player:SetMinDamageCooldown(1);
    player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
end

function Shields:PostPlayerEffect(player)
    local playerData = Shields:GetPlayerData(player, false);
    -- Shield
    if (playerData) then
        if (playerData.ShieldTime > 0) then
            playerData.ShieldTime = playerData.ShieldTime - 1;
            playerData.ShieldFrame = playerData.ShieldFrame + 1;
        end
    end
end

function Shields:PostPlayerUpdate(player)
    
    local playerData = Shields:GetPlayerData(player, false);
    -- Shield
    if (playerData) then
        if (playerData.ShieldTime > 0) then
            player:SetMinDamageCooldown(1);
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        end
    end
end

function Shields:PostNewRoom()
    local game = THI.Game;
    for i, player in Lib.Detection.PlayerPairs() do 
        local playerData = Shields:GetPlayerData(player, false);
        if (playerData) then
            if (playerData.ShieldTime > 0) then
                playerData.ShieldTime = 0;
            end
        end
    end
end
function Shields:PostPlayerRender(player, offset)
    local playerData = Shields:GetPlayerData(player, false);
    if (playerData) then
        if (playerData.ShieldTime > 0) then
            if (playerData.ShieldTime > 90) then
                spr:SetFrame("WalkDown", playerData.ShieldFrame % 40);
            else
                spr:SetFrame("Blink", playerData.ShieldFrame % 16);
            end
            spr.Scale = player.SpriteScale;
            local pos = Screen.GetEntityOffsetedRenderPosition(player, offset);
            spr:Render(pos, Vector.Zero, Vector.Zero);
        end
    end
end

function Shields:Register(mod)
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Shields.PostPlayerEffect);
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Shields.PostPlayerUpdate);
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Shields.PostNewRoom);
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Shields.PostPlayerRender);
end

return Shields;