local Dream = GensouDream;
local Dialog = Dream.Dialog;
local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;
local Intro = Dialog();
Intro.__index = Intro;
function Intro:New()
    local new = {};
    setmetatable(new, self);
    return new;
end

Intro.Data = {
    Doremy = nil
}


local DoremyImage = {
    Type = Isaac.GetEntityTypeByName("Doremy Image"),
    Variant = Isaac.GetEntityVariantByName("Doremy Image"),
}

local function DoremySpeak(dialog, time, read)

    local talkAnim = "Talk";
    local normalAnim = "Stand";
    if (read) then
        talkAnim = "ReadTalk";
        normalAnim = "Read";
    end

    if (time == 1) then
        dialog.Data.Doremy:GetSprite():Play(talkAnim);
    end
    local textData = dialog.TextData;
    if (textData.Index >= utf8.len(textData.PureText)) then
        dialog.Data.Doremy:GetSprite():Play(normalAnim);
    end
end
local Config = {
    TextKey = "#DOREMY_INTRO",
    TextColors = {
        KColor(0.5,0.5,1,1),
        KColor(1,1,1,1),
    },
    Keyframes = {
        {
            Duration = 15,
        },
        {
            Duration = 60,
            Action = function(dialog, time) 
                local color = dialog.Data.Doremy.Color;
                if (time == 1) then
                    local tempData = Dream:GetTempData(); 
                    color.A = 0;
                    tempData.BlackScreenAlphaSpeed = -1/60;
                    local mainPlayer = THI.Game:GetPlayer(0);
                    mainPlayer:AnimateAppear();
                end
                color.A = math.min(1, color.A+ 0.05);
                dialog.Data.Doremy.Color = color;
            end
        },
        {
            Text = {
                Id = 1,
                Color = 1,
                Speed = 0.5
            }, 
            Action = function(dialog, time) DoremySpeak(dialog, time, true) end,
            Duration = 150
        },
        {
            Text = {
                Id = 2,
                Color = 2,
                Speed = 1
            },
            Duration = 100
        },
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.Data.Doremy:GetSprite():Play("CloseBook");
                end
            end,
            Duration = 20
        },
        {
            Text = {
                Id = 3,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 70
        },
        {
            Text = {
                Id = 4,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 90
        },
        {
            Text = {
                Id = 5,
                Color = 2,
                Speed = 2
            },
            Duration = 60
        },
        {
            Text = {
                Id = 6,
                Color = 1,
                Speed = 0.6
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 140
        },
        {
            Text = {
                Id = 7,
                Color = 2,
                Speed = 2
            },
            Duration = 80
        },
        {
            Text = {
                Id = 8,
                Color = 2,
                Speed = 0.8
            },
            Duration = 100
        },
        {
            Text = {
                Id = 9,
                Color = 2,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                if (time == 1) then
                    THI.Game:GetPlayer(0):AnimateSad();
                    THI.Game:AddPixelation(45);
                end
            end,
            Duration = 80
        },
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.Data.Doremy:GetSprite():Play("OpenBook");
                end
            end,
            Duration = 20
        },
        {
            Text = {
                Id = 10,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, true) end,
            Duration = 70
        },
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.Data.Doremy:GetSprite():Play("CloseBook");
                end
            end,
            Duration = 20
        },
        {
            Text = {
                Id = 11,
                Color = 1,
                Speed = 1
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 80
        },
        {
            Text = {
                Id = 12,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 80
        },
        {
            Text = {
                Id = 13,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 80
        },
        {
            Text = {
                Id = 14,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) DoremySpeak(dialog, time, false) end,
            Duration = 80
        },
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    THI.SFXManager:Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR);
                    dialog.Data.Doremy:GetSprite():Play("Cast");
                    MusicManager():Fadeout(0.5);
                end
                THI.Game:ShakeScreen(5);
                local tempData = Dream:GetTempData(); 
                tempData.WhiteScreenAlphaSpeed = 0;
                tempData.WhiteScreenAlpha = time / 60;
            end,
            Duration = 60
        },
    }
}


function Intro:GetConfig()
    return Config;
end

function Intro:GetTextPosition()
    local screenSize = Screen.GetScreenSize()
    local x = 0;
    local y = 240;

    local key = self:GetCurrentKeyframeConfig();
    if (key) then
        if (key.Text.Color == 1) then
            local doremy = Intro.Data.Doremy;
            if (doremy) then 
                local pos = Isaac.WorldToScreen(doremy.Position + Vector(0, 20));;
                y = pos.Y;
            end
        else
            local pos = Isaac.WorldToScreen(THI.Game:GetPlayer(0).Position + Vector(0, 20));
            y = pos.Y;
        end
    end

    return x, y, screenSize.X;
end

local function DisableControls()
    for i, player in Detection.PlayerPairs(true, true) do 
        player.ControlsEnabled = false;
        player.Velocity = Vector.Zero;
    end
end


function Intro:Start()
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();

    for i, player in Detection.PlayerPairs(true, true) do 
        local pos = center;
        if (i > 0) then
            local index = (i % 16) % 10 + 1;
            local layer = math.floor((index+1) / 2);
            local dir = (index % 2)* 2 - 1;
            local xOffset = dir * (40 + layer * 40);
            pos = pos + Vector(xOffset, 0);
        end
        player.Position = pos;
        player.Velocity = Vector.Zero;
    end
    
    local tempData = Dream:GetTempData(); 
    tempData.BlackScreenAlpha = 1;
    tempData.BlackScreenAlphaSpeed = 0;
    THI.Game:GetHUD():SetVisible(false);


    local imagePosition = center;
    imagePosition.Y = imagePosition.Y - 120;
    Intro.Data.Doremy = Isaac.Spawn(DoremyImage.Type, DoremyImage.Variant, 0, imagePosition, Vector.Zero, nil);
    Intro.Data.Doremy:GetSprite():Play("Read");
end

function Intro:Run()
    DisableControls();
    Dialog.Run(self);
end

function Intro:End()
    
    local room = THI.Game:GetRoom();
    local position = room:GetGridPosition(room:GetGridSize() - math.ceil(room:GetGridWidth() * 1.5));
    for i, player in Detection.PlayerPairs(true, true) do 
        player.ControlsEnabled = true;
        player.Position = position;
        player:StopExtraAnimation();
    end
    Intro.Data.Doremy:Remove();
    THI.Game:GetHUD():SetVisible(true);
    THI.SFXManager:Play(SoundEffect.SOUND_FLASHBACK);
    Dream:StartNonSpell();
    
    local tempData = Dream:GetTempData(); 
    
    tempData.WhiteScreenAlpha = 1;
    tempData.WhiteScreenAlphaSpeed = -0.03;
    tempData.BlackScreenAlpha = 0;
    tempData.BlackScreenAlphaSpeed = 0;
    
end

return Intro;