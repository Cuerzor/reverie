local Dream = GensouDream;
local Dialog = Dream.Dialog;
local Screen = CuerLib.Screen;
local Detection = CuerLib.Detection;

local Outro = Dialog();
Outro.__index = Outro;
function Outro:New()
    local new = {};
    setmetatable(new, self);
    return new;
end

Outro.Data = {
    Doremy = nil,
    Isaac = nil
}

local DoremyImage = {
    Type = Isaac.GetEntityTypeByName("Doremy Image"),
    Variant = Isaac.GetEntityVariantByName("Doremy Image"),
    DoremySubType = 0,
    IsaacSubType = 1;
}
local function GetMaxCollectible()
    local config = Isaac:GetItemConfig();
    local collectibles = config:GetCollectibles();
    local size = collectibles.Size;
    local max = 0;
    for i=1, size do
        local item = config:GetCollectible(i);
        if (item and item.ID > max) then
            max = item.ID;
        end
    end
    return max;
end

local function GetMaxTrinket()
    local config = Isaac:GetItemConfig();
    local trinkets = config:GetTrinkets ( )
    local size = trinkets.Size;
    local max = 0;
    for i=1, size do
        local item = config:GetTrinket(i);
        if (item and item.ID > max) then
            max = item.ID;
        end
    end
    return max;
end


local MaxCollectible = GetMaxCollectible();
local MaxTrinket = GetMaxTrinket();

local function DoremySpeak(dialog, time, talkAnim, normalAnim)

    talkAnim = talkAnim or "Talk";
    normalAnim = normalAnim or "Stand";

    if (time == 1) then
        dialog.Data.Doremy:GetSprite():Play(talkAnim);
    end
    local textData = dialog.TextData;
    if (textData.Index >= utf8.len(textData.PureText)) then
        dialog.Data.Doremy:GetSprite():Play(normalAnim);
    end
end


local Config = {
    TextKey = "#DOREMY_OUTRO",
    TextColors = {
        KColor(0.5,0.5,1,1),
        KColor(1,1,1,1),
    },
    Keyframes = {
        {
            Duration = 60
        },
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    local music = MusicManager();
                    music:Play(Music.MUSIC_PLANETARIUM, 0);
                    music:UpdateVolume();
                    
                    local tempData = Dream:GetTempData(); 
                    tempData.BlackScreenAlphaSpeed = -0.03;
                    THI.Game:GetPlayer(0):AnimateAppear();
                    Outro.Data.Isaac:GetSprite():Play("Appear");
                end
            end,
            Duration = 40
        },
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    dialog.Data.Isaac:GetSprite():Play("LookUp");
                end
            end,
            Duration = 30
        },
        {
            Text = {
                Id = 1,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "ReadTalk", "Read")
            end,
            Duration = 100
        },
        -- "But... what should I do now, Doremy?",
        {
            Text = {
                Id = 2,
                Color = 2,
                Speed = 0.8
            },
            Duration = 100
        },
        -- "My mom, my daddy...I'm just a sinner."
        {
            Text = {
                Id = 3,
                Color = 2,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                if (time == 1) then
                    dialog.Data.Isaac:GetSprite():Play("LowerHead");
                    dialog.Data.Doremy:GetSprite():Play("CloseBook");
                end
            end,
            Duration = 100
        },
        -- Doremy Ducks
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    dialog.Data.Doremy:GetSprite():Play("Duck");
                end
                if (time >= 20 and time <= 30) then
                    local room = THI.Game:GetRoom();
                    local center = room:GetCenterPos();
                    local startPos = center -  Vector(0, 40);
                    local endPos = dialog.Data.Isaac.Position - Vector(0, 28);

                    dialog.Data.Doremy.Position = startPos + (endPos - startPos) * (time - 20) / (30 -20);
                end
            end,
            Duration = 34
        },
        -- Doremy Pets
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    dialog.Data.Doremy:GetSprite():Play("Pet");
                end
            end,
            Duration = 30
        },
        -- "Don't worry, Isaac, it's not your fault at all.",
        {
            Text = {
                Id = 4,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },
        -- "You don't have sins, you are just an innocent child.",
        {
            Text = {
                Id = 5,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },

        -- "If you feel strange or afraid there, find me in your dream.",
        {
            Text = {
                Id = 6,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },
        --"I will help you as I can. Be a good boy, okay?",
        {
            Text = {
                Id = 7,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },
        -- "Okay...",
        {
            Text = {
                Id = 8,
                Color = 2,
                Speed = 2
            },
            Duration = 45
        },
        -- "Good, Isaac. Time to go.",
        {
            Text = {
                Id = 9,
                Color = 1,
                Speed = 1
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },
        --"Close your eyes, have a good dream, Isaac..."
        {
            Text = {
                Id = 10,
                Color = 1,
                Speed = 0.8
            },
            Action = function(dialog, time) 
                DoremySpeak(dialog, time, "PetTalk", "DuckIdle")
            end,
            Duration = 100
        },
        -- Isaac Slept.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    Outro.Data.Isaac:GetSprite():Play("Sleep");
                end
            end,
            Duration = 40
        },
        -- Doremy stood up.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    Outro.Data.Doremy:GetSprite():Play("EndDuck");
                end
            end,
            Duration = 30
        },
        -- Doremy Cast.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    Outro.Data.Doremy:GetSprite():Play("Cast");
                end
            end,
            Duration = 20
        },
        -- Start Teleport.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    THI.SFXManager:Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR);
                    MusicManager():Fadeout(0.5);
                end
                THI.Game:ShakeScreen(5);

                local tempData = Dream:GetTempData(); 
                tempData.WhiteScreenAlphaSpeed = 0;
                tempData.WhiteScreenAlpha = (time / 210) * 2 - 1;

                -- Set Positions.
                local room = THI.Game:GetRoom();
                local center = room:GetCenterPos();
                local isaacOrigin = center;
                local doremyOrigin = isaacOrigin - Vector(0, 28);

                if (time < 120) then
                    local doremyY = -(-math.cos(time / 60 * math.pi) + 1) / 2 * 32;
                    Outro.Data.Doremy.Position = doremyOrigin + Vector(0, doremyY);
                else
                    Outro.Data.Doremy.Position = Outro.Data.Doremy.Position - Vector(0, time - 120);
                end
                local isaacTime = time - 30;
                if (isaacTime > 0) then
                    if (isaacTime < 120) then
                        local isaacY = -(-math.cos(isaacTime / 60 * math.pi) + 1) / 2 * 32;
                        Outro.Data.Isaac.Position = isaacOrigin + Vector(0, isaacY);
                    else
                        Outro.Data.Isaac.Position = Outro.Data.Isaac.Position - Vector(0, isaacTime - 120);
                    end
                end
            end,
            Duration = 210
        },
        -- Black Screen.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    local tempData = Dream:GetTempData(); 
                    tempData.WhiteScreenAlphaSpeed = -1/60;
                    tempData.BlackScreenAlphaSpeed = 1/60;
                end
            end,
            Duration = 60
        },
        -- Black Screen.
        {
            Action = function(dialog, time) 
                if (time == 1) then
                    local tempData = Dream:GetTempData(); 
                    tempData.WhiteScreenAlpha = 0;
                end
            end,
            Duration = 60
        },
    }
}


function Outro:GetConfig()
    return Config;
end

function Outro:GetTextPosition()
    local screenSize = Screen.GetScreenSize()
    local y = 240;

    local key = self:GetCurrentKeyframeConfig();
    if (key) then
        if (key.Text.Color == 1) then
            local doremy = Outro.Data.Doremy;
            if (doremy) then 
                y = Isaac.WorldToScreen(doremy.Position - Vector(0, 80)).Y;
            end
        else
            local isaac = Outro.Data.Isaac;
            if (isaac) then
                y = Isaac.WorldToScreen(isaac.Position + Vector(0, 20)).Y;
            end
        end
    end

    return 0, y, screenSize.X;
end

local function DisableControls()
    for i, player in Detection.PlayerPairs(true, true) do
        player.ControlsEnabled = false;
    end
end


function Outro:Start()
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();

    -- Clear Collectibles.
    for i, player in Detection.PlayerPairs() do
        for c = 1, MaxCollectible do
            local num = player:GetCollectibleNum(c);
            for n = 1, num do
                player:RemoveCollectible (c, false, ActiveSlot.SLOT_PRIMARY, true);
            end
        end

        
        for t = 1, MaxTrinket do
            local tries = 0;
            while (player:TryRemoveTrinket(t) or tries > 1024) do
                tries = tries + 1;
                if (tries > 1024) then
                    error("Tries out when removing trinket "..t.."!");
                end
            end
        end

        player: ClearCostumes ( );
        player.Color = Color(1,1,1,0)
    end

    
    -- Remove Objects.
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent.Type < EntityType.ENTITY_EFFECT and ent.Type ~= EntityType.ENTITY_PLAYER) then
            ent:Remove();
        end
    end
    THI.Game:GetPlayer(0).Position = center;

    

    local imagePosition = center - Vector(0, 40);
    Outro.Data.Doremy = Isaac.Spawn(DoremyImage.Type, DoremyImage.Variant, DoremyImage.DoremySubType, imagePosition, Vector.Zero, nil);
    Outro.Data.Doremy:GetSprite():Play("Read");
    
    Outro.Data.Isaac = Isaac.Spawn(DoremyImage.Type, DoremyImage.Variant, DoremyImage.IsaacSubType, THI.Game:GetPlayer(0).Position, Vector.Zero, nil);
    
    THI.Game:GetHUD():SetVisible(false);
end

function Outro:Run()
    DisableControls();
    
    for i, player in Detection.PlayerPairs() do
        player.Color = Color(1,1,1,0)
    end
    Dialog.Run(self);

    -- make all entities invisible.
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent.Type < EntityType.ENTITY_EFFECT and ent.Type ~= EntityType.ENTITY_PLAYER) then
            ent.Color = Color(1,1,1,0);
        end
    end

end

function Outro:End()
    local tempData = Dream:GetTempData(); 
    tempData.BlackScreenAlpha = 1;
    tempData.BlackScreenAlphaSpeed = 0;
end

return Outro;