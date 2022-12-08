local Entities = CuerLib.Entities;
local UTF8 = CuerLib.UTF8;
local Dialog = {
    CurrentKeyframe = 0,
    CurrentTime = 0,
    TextData = {
        PureText = "",
        Metas = nil,
        Index = 0,
        Wait = {
            Waiting = false,
            Frame = 0,
            NextIndex = 0,
        }
    },
    Finished = false,
};

Dialog.__index = Dialog;

local metatable = {
    __call = function()
        new = {};
        setmetatable(new, Dialog);
        return new;
    end
}
setmetatable(Dialog, metatable);


function Dialog.GetTextMetas(rawText)
    local index = 1;
    local metas = {};
    local length = string.len(rawText);
    local textIndex = 1;
    local newText = "";
    while (index <= length) do
        local openIndex = string.find (rawText, "{", index);
        
        -- if no { is found after index.
        if (openIndex == nil) then
            newText = newText..string.sub(rawText, index);
            return newText, metas;
        end

        -- if found { after index.
        -- find }.
        local closeIndex = string.find (rawText, "}", openIndex + 1);
        -- if no } is found.
        if (closeIndex == nil) then
            error("expecting \"}\" after \"{\"");
            return nil, nil;
        end

        -- if } is found.
        local metaContent = string.sub(rawText, openIndex + 1, closeIndex - 1);
        local meta = {};
        -- Find : in meta content.
        local colonIndex = string.find(metaContent, ":");
        -- if no : is found.
        if (colonIndex == nil) then
            meta.Type = metaContent
        else
            meta.Type = string.sub(metaContent, 1, colonIndex - 1);
            meta.Argument = string.sub(metaContent, colonIndex + 1);
        end
        textIndex = textIndex + openIndex - index;
        
        
        newText = newText..string.sub(rawText, index, openIndex - 1);

        
        meta.Index = 0;
        for i, code in utf8.codes(newText) do
            if (i < textIndex - 1) then
                meta.Index = meta.Index + 1;
            end
        end
        table.insert(metas, meta);
        -- Set the next index to the index after }.
        index = closeIndex + 1;
    end
    return newText, metas;
end


function Dialog:GetConfig()
    return nil;
end

function Dialog:GetTextPosition()
    return 0, 240, 480;
end

function Dialog:SwitchKeyFrame(keyframe)
    self.CurrentKeyframe = keyframe;
    self.CurrentTime = 0;
    self.TextData.Index = 0;
    local config = self:GetConfig();
    if (config) then
        local keyframeConfig = config.Keyframes[self.CurrentKeyframe];
        if (keyframeConfig) then
            local textConfig = keyframeConfig.Text;
            if (textConfig) then
                local key = config.TextKey;
                local text = THI.GetText(THI.StringCategories.DIALOGS, key.."_"..textConfig.Id);
                self.TextData.PureText, self.TextData.Metas = Dialog.GetTextMetas(text);
            end
        end
    end
end

function Dialog:GetCurrentKeyframeConfig()
    local config = self:GetConfig();
    if (config) then
        return config.Keyframes[self.CurrentKeyframe];
    end
    return nil;
end

function Dialog:Start()
end


function Dialog:Run()
    if (self.CurrentKeyframe == 0) then
        self:SwitchKeyFrame(1);
    end

    local keyframeConfig = self:GetCurrentKeyframeConfig();
    if (keyframeConfig) then
        self.CurrentTime = self.CurrentTime + 1;

        local textConfig = keyframeConfig.Text
        if (textConfig) then
            local textData = self.TextData;
            if (textData.Wait.Waiting) then
                -- if is waiting.
                local waitData = textData.Wait;
                waitData.Frame = waitData.Frame + 1;
                if (waitData.Frame > waitData.TotalFrame) then
                    waitData.Waiting = false;
                    textData.Index = waitData.NextIndex;
                end
            else
                -- If is not waiting.
                local pureText = textData.PureText;
                local length = utf8.len(pureText);

                local currentIndex = textData.Index;
                local nextIndex = currentIndex + textConfig.Speed * length / 30;
                nextIndex = math.min(length, math.max(0,nextIndex));

                -- Meta wait.
                for i, meta in pairs(textData.Metas) do
                    if (currentIndex < meta.Index and nextIndex >= meta.Index) then
                        if (meta.Type == "WAIT") then
                            if (meta.Argument) then
                                local number = tonumber(meta.Argument);
                                if (number and number > 0) then
                                    textData.Wait.Waiting = true;
                                    textData.Wait.Frame = 0;
                                    textData.Wait.TotalFrame = number;
                                    textData.Wait.NextIndex = meta.Index;
                                    nextIndex = meta.Index;
                                end
                            end
                        end
                    end
                end

                if (currentIndex < length) then
                    if (math.floor(nextIndex) >currentIndex) then
                        THI.SFXManager:Play(SoundEffect.SOUND_BEEP, 0.5, 0, false, 0.7);
                    end
                    textData.Index = nextIndex;
                end
            end

        end
        
        local frameAction = keyframeConfig.Action;
        if (frameAction) then
            frameAction(self, self.CurrentTime);
        end

        if (self.CurrentTime >= keyframeConfig.Duration) then
            self:SwitchKeyFrame(self.CurrentKeyframe + 1);
        end

    end
    if (self.CurrentKeyframe > #self:GetConfig().Keyframes) then
        self:Finish();
    end

end

function Dialog:Finish()
    if (not self.Finished) then
        self.Finished = true;
        self:End();
    end
end

function Dialog:End()
end

function Dialog:IsFinished()
    return self.Finished;
end

function Dialog:Render()
    
    local config = self:GetConfig();
    if (config) then
        local keyframeConfig = config.Keyframes[self.CurrentKeyframe];
        if (keyframeConfig) then
            local textConfig = keyframeConfig.Text;
            if (textConfig) then
                local pureText = self.TextData.PureText;
                local text = UTF8.sub(pureText, 1, math.floor(self.TextData.Index))
                -- local x = 0;
                -- local y = 240;
                -- local width = 480;
                local x, y, width = self:GetTextPosition();
                local color = config.TextColors[textConfig.Color];
                local scale = textConfig.Size or 1;

                local font = THI.GetFont("DOREMY_DIALOG")
                font:DrawStringScaledUTF8(text, x, y, scale, scale, color, math.floor(width), true);
            end
        end
    end
end

return Dialog;