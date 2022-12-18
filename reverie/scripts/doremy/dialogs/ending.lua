local Dream = GensouDream;
local Dialog = Dream.Dialog;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Players = CuerLib.Players;

local Ending = Dialog();
Ending.__index = Ending;
function Ending:New()
    local new = {};
    setmetatable(new, self);
    new:Init();
    return new;
end

local EndingStrings = {
    Title = "#DOREMY_ENDING_TITLE",
    Subtitle = "#DOREMY_ENDING_SUBTITLE"
}

function Ending:Init()
    self.ShrineSprite = Sprite();
    self.ShrineSprite:Load("gfx/doremy/effects/shrine.anm2", true);
    self.ShrineSprite:Play("Shrine");

    self.ShrineCameraSprite = Sprite();
    self.ShrineCameraSprite:Load("gfx/doremy/effects/shrine.anm2", true);
    self.ShrineCameraSprite:Play("Camera");

    self.ReimuSprite = Sprite();
    self.ReimuSprite:Load("gfx/doremy/effects/reimu.anm2", true);
    self.ReimuSprite:Play("Worried");

    self.IsaacSprite = Sprite();
    self.IsaacSprite:Load("gfx/doremy/effects/isaac_image.anm2", false);
    self.IsaacSprite:ReplaceSpritesheet (0, "gfx/doremy/effects/isaac_image_clothed.png")
    self.IsaacSprite:ReplaceSpritesheet (1, "gfx/doremy/effects/isaac_image_clothed.png")
    self.IsaacSprite:ReplaceSpritesheet (2, "gfx/doremy/effects/isaac_image_clothed.png")
    self.IsaacSprite:LoadGraphics();
    self.IsaacSprite:Play("Appear");

    self.DoremySprite = Sprite();
    self.DoremySprite:Load("gfx/doremy/effects/doremy_image.anm2", true);
    self.DoremySprite:Play("Idle");
    self.Data = {
        CameraPos = Vector(0, 80),
        ReimuPos = Vector(0, 50),
        IsaacPos = Vector(0, 90),
        DoremyPos = Vector(0, -210),
        ThanksAlpha = 0,
        BlessingAlpha = 0
    }
end




local endingMusic = Isaac.GetMusicIdByName("Gensou Ending");





local function ReimuSpeak(dialog, time, talkAnim, normalAnim)

    talkAnim = talkAnim or "Talk";
    normalAnim = normalAnim or "Stand";

    local spr = dialog.ReimuSprite;
    if (time == 1) then
        spr:Play(talkAnim);
    end
    local textData = dialog.TextData;
    if (textData.Index >= utf8.len(textData.PureText)) then
        spr:Play(normalAnim);
    end
end

local Config = {
    TextKey = "#DOREMY_ENDING",
    TextColors = {
        KColor(1,0.5,0.5,1),
        KColor(1,1,1,1),
        KColor(0.5,0.5,1,1),
    },
    Keyframes = {
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("Appear");
                end
                dialog.ReimuSprite:Play("Worried");
            end,
            Duration = 30
        },
        -- Isaac waked, Reimu was surprised.
        {
            Action = function(dialog, time)
                if (time == 20) then
                    dialog.ReimuSprite:Play("Surprised");
                end
            end,
            Duration = 40
        },
        -- Isaac looks left
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("LookLeft");
                end
            end,
            Duration = 30
        },
        -- Isaac looks Right
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("LookRight");
                end
            end,
            Duration = 30
        },
        -- Isaac looks up
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("LookUp");
                end
            end,
            Duration = 60
        },
        -- "...You are finally awake, kid."
        {
            Text = {
                Id = 1,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 100
        },
        -- "Where am I?"
        {
            Text = {
                Id = 2,
                Color = 2,
                Speed = 2,
            },
            Duration = 60
        },
        -- "This is the Hakurei Shrine.",
        {
            Text = {
                Id = 3,
                Color = 1,
                Speed = 1.5,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 90
        },
        -- "I'm Reimu, the Shrine maiden of this shrine.",
        {
            Text = {
                Id = 4,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 100
        },
        -- "Someone told me there would be a lost human child here.",
        {
            Text = {
                Id = 5,
                Color = 1,
                Speed = 0.8,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 100
        },
        -- "She also told me to look after him.",
        {
            Text = {
                Id = 6,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 80
        },
        -- Reimu shakes her head.
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.ReimuSprite:Play("ShakeHead");
                end
            end,
            Duration = 30
        },
        -- "Geez...Don't just push everything on me."
        {
            Text = {
                Id = 7,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "TurnHeadTalk", "TurnHead")
            end,
            Duration = 80
        },
        -- "Reimu, what should I do then...?"
        {
            Text = {
                Id = 8,
                Color = 2,
                Speed = 1,
            },
            Action = function(dialog, time)
                if (time == 15) then
                    dialog.ReimuSprite:Play("PutDownHand");
                end
            end,
            Duration = 80
        },
        -- "You will live in Gensokyo from now on."
        {
            Text = {
                Id = 9,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 80
        },
        -- "But first, you need a home."
        {
            Text = {
                Id = 10,
                Color = 1,
                Speed = 2,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 80
        },
        -- "In that case, you can stay in my shrine for the time being."
        {
            Text = {
                Id = 11,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 100
        },
        -- "Okay..."
        {
            Text = {
                Id = 12,
                Color = 2,
                Speed = 3,
            },
            Duration = 60
        },
        -- "Come on, let's go have a look at your new home."
        {
            Text = {
                Id = 13,
                Color = 1,
                Speed = 1,
            },
            Action = function(dialog, time)
                ReimuSpeak(dialog, time, "Talk", "Idle")
            end,
            Duration = 100
        },
        -- Reimu returned to shrine.
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.ReimuSprite:Play("WalkUp");
                end
                
                if (time < 30) then
                    dialog.Data.ReimuPos = dialog.Data.ReimuPos + Vector(1,-1);
                elseif (time < 60) then
                    dialog.Data.ReimuPos = dialog.Data.ReimuPos + Vector(-0.3, -0.7);
                elseif (time <= 80) then
                    dialog.ReimuSprite:SetFrame(0);
                    dialog.ReimuSprite.Color = Color(1,1,1,1 - (time - 60) / 20);
                end
            end,
            Duration = 100
        },
        -- Isaac looks down
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("Idle");
                end
            end,
            Duration = 30
        },
        -- Isaac walks into the shrine.
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.IsaacSprite:Play("WalkUp");
                end
                
                local t = time - 20;
                if (t < 0) then
                    dialog.Data.IsaacPos = dialog.Data.IsaacPos + Vector(0,-2);
                elseif (t < 20) then
                    dialog.Data.IsaacPos = dialog.Data.IsaacPos + Vector(1.5,-1.5);
                elseif (t < 40) then
                    dialog.Data.IsaacPos = dialog.Data.IsaacPos + Vector(-0.45, -1.05);
                elseif (t <= 50) then
                    dialog.IsaacSprite:SetFrame(0);
                    dialog.IsaacSprite.Color = Color(1,1,1,1 - (t - 40) / 10);
                end
            end,
            Duration = 80
        },
        -- Camera moves up
        {
            Action = function(dialog, time)
                if (time <= 50) then
                    local x = 0;
                    local y = 80 - Math.EaseInAndOut(time / 50) * 250;
                    dialog.Data.CameraPos = Vector(x, y);
                end
            end,
            Duration = 80
        },
        -- "Welcome to Gensokyo, Isaac...",
        {
            Text = {
                Id = 14,
                Color = 3,
                Speed = 1,
            },
            Duration = 80
        },
        -- "See you in your dream...",
        {
            Text = {
                Id = 15,
                Color = 3,
                Speed = 1,
            },
            Duration = 80
        },
        -- Doremy flew away.
        {
            Action = function(dialog, time)
                if (time == 1) then
                    dialog.DoremySprite:Play("FlyAway");
                end

                local x = 0;
                local y = -210;
                x = time * time / 5;
                y = y - time * time / 5;
                dialog.Data.DoremyPos = Vector(x, y);
            end,
            Duration = 80
        },
        -- Camera moves up to the moon
        {
            Action = function(dialog, time)
                
                if (time <= 50) then
                    local x = 0;
                    local y = 80 - 250 - Math.EaseInAndOut(time / 50) * 475;
                    dialog.Data.CameraPos = Vector(x, y);
                end
            end,
            Duration = 80
        },
        -- Thanks for playing!
        {
            Action = function(dialog, time)
                dialog.Data.ThanksAlpha = math.min(1, time / 30);
            end,
            Duration = 80
        },
        -- May Isaac live a happy new life.
        {
            Action = function(dialog, time)
                dialog.Data.BlessingAlpha = math.min(1, time / 30);
            end,
            Duration = 80
        },
        -- Black screen
        {
            Action = function(dialog, time)
                local tempData = Dream:GetTempData(); 
                tempData.BlackScreenAlphaSpeed = 0;
                tempData.BlackScreenAlpha = time / 120;
            end,
            Duration = 120
        }
    }
}


function Ending:GetConfig()
    return Config;
end

function Ending:GetTextPosition()
    local screenSize = Screen.GetScreenSize();
    local center = screenSize / 2;
    local pos = center - self.Data.CameraPos;
    local cameraPos = center;
    local reimuPos = pos + self.Data.ReimuPos;
    local isaacPos = pos + self.Data.IsaacPos;
    local doremyPos = pos + self.Data.DoremyPos;


    local key = self:GetCurrentKeyframeConfig();
    if (key) then
        if (key.Text.Color == 1) then
            y = reimuPos.Y - 80;
        elseif (key.Text.Color == 2) then
            y = isaacPos.Y + 20;
        else
            y = doremyPos.Y + 20;
        end
    end

    return 0, y, screenSize.X;
end

local function DisableControls()
    for i, player in Players.PlayerPairs(true, true) do 
        player.ControlsEnabled = false;
    end
end


function Ending:Start()
    local tempData = Dream:GetTempData(); 
    tempData.BlackScreenAlphaSpeed = -1/30
    local music = MusicManager();
    music:Play(endingMusic, 0);
    music:UpdateVolume();
end

function Ending:Run()
    DisableControls();
    Dialog.Run(self);
    if (self.CurrentKeyframe > 1) then
        self.ReimuSprite:Update();
        self.IsaacSprite:Update();
        self.DoremySprite:Update();
    end
end

function Ending:Render()
    -- Render Shrine.
    local screenSize = Screen.GetScreenSize();
    local center = screenSize / 2;
    local pos = center - self.Data.CameraPos;
    local cameraPos = center;
    local reimuPos = pos + self.Data.ReimuPos;
    local isaacPos = pos + self.Data.IsaacPos;
    local doremyPos = pos + self.Data.DoremyPos;

    local viewBottomRight = cameraPos + Vector(320, 240);
    local shrineBottomRight = (pos + Vector(320, 320)) - viewBottomRight;
    
    self.ShrineSprite:Render(pos, Vector.Zero, shrineBottomRight);
    self.ReimuSprite:Render(reimuPos, Vector.Zero, Vector.Zero);
    self.IsaacSprite:Render(isaacPos, Vector.Zero, Vector.Zero);
    self.DoremySprite:Render(doremyPos, Vector.Zero, Vector.Zero);
    self.ShrineCameraSprite:Render(cameraPos, Vector(-1000, -1000), Vector(-1000, -1000));

    local strings = EndingStrings;
    local titleString = THI.GetText(strings.Title) ;
    local subtitleString = THI.GetText(strings.Subtitle) ;
    local font = THI.GetFont("DOREMY_DIALOG");
    font:DrawStringScaledUTF8(titleString, 0, center.Y, 2, 2, KColor(1,1,1,self.Data.ThanksAlpha), math.floor(screenSize.X), true);
    font:DrawStringScaledUTF8(subtitleString, 0, center.Y + 40, 1, 1, KColor(1,1,1,self.Data.BlessingAlpha), math.floor(screenSize.X), true);

    Dialog.Render(self);
end

function Ending:End()
    local tempData = Dream:GetTempData(); 
    tempData.BlackScreenAlphaSpeed = 0;
    tempData.BlackScreenAlpha = 1;
    THI.Game:FinishChallenge();
end

return Ending;