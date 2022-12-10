local Players = CuerLib.Players;
local Stats = CuerLib.Stats;
local Collectibles = CuerLib.Collectibles;
local Wings = ModItem("Cockcrow Wings", "COCKCROW_WINGS")

do
    local function GetGlobalData(create)
        local function default()
            return {
                Time = 0,
                ApplyDarkness = false
            }
        end
        return Wings:GetGlobalData(create, default);
    end

    Wings.Time = {
        NONE = 0,
        DAY = 1,
        DUSK = 2,
        NIGHT = 3,
        DAWN = 4,
    }

    function Wings:SetTime(time)
        local globalData = GetGlobalData(true);
        if (globalData.Time ~= time) then
            local lastTime = globalData.Time;
            globalData.Time = time;
            self:UpdateTime(lastTime);
        end
    end
    
    function Wings:ResetTime()
        local globalData = GetGlobalData(false);
        local time = self.Time.NONE;
        if (globalData and globalData.Time ~= time) then
            local lastTime = globalData.Time;
            globalData.Time = time;
            self:UpdateTime(lastTime);
        end
    end
    function Wings:GetTime()
        local globalData = GetGlobalData(false);
        return (globalData and globalData.Time) or self.Time.NONE
    end

    function Wings:IsApplyingCurseOfDarkness()
        local globalData = GetGlobalData(false);
        return (globalData and globalData.ApplyDarkness) or false;
    end

    function Wings:ApplyCurseOfDarkness()
        local globalData = GetGlobalData(true);
        globalData.ApplyDarkness = true;
    end

    function Wings:FinishCurseOfDarkness()
        local globalData = GetGlobalData(false);
        if (globalData)  then globalData.ApplyDarkness = false; end
    end

    function Wings:UpdatePlayer(player)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY);
        player:EvaluateItems();
    end

    function Wings:UpdateTime(lastTime)
        for p, player in Players.PlayerPairs(true, true) do
            if (player:HasCollectible(self.Item)) then
                self:UpdatePlayer(player)
            end
        end


        local time = self:GetTime();
        if (time == self.Time.DAY or time == self.Time.DUSK) then
            -- If lastTime is None, Dawn or Night.
            if (lastTime ~= self.Time.DAY and lastTime ~= self.Time.DUSK) then
                THI.SFXManager:Play(THI.Sounds.SOUND_ROOSTER_CROW);
            end
        elseif (time == self.Time.NIGHT or time == self.Time.DAWN) then
            -- If lastTime is None, Day or Dusk.
            if (lastTime ~= self.Time.NIGHT and lastTime ~= self.Time.DAWN) then
                self:ApplyCurseOfDarkness();
                THI.SFXManager:Play(SoundEffect.SOUND_DOG_HOWELL);
            end
        end

        local level = Game():GetLevel();
        local rooms = level:GetRooms();
        for i = 0, rooms.Size-1 do
            local rm = rooms:Get(i);
            local index = rm.SafeGridIndex;
            local room = level:GetRoomByIdx(index);
            if (room and room.Data) then
                
                local fits = false;
                if (time == self.Time.DAY or time == self.Time.DUSK) then
                    fits = room.Data.Type == RoomType.ROOM_BOSS;
                elseif (time == self.Time.NIGHT or time == self.Time.DAWN) then
                    local type = room.Data.Type;
                    fits = type == RoomType.ROOM_SECRET or type == RoomType.ROOM_SUPERSECRET or type == RoomType.ROOM_ULTRASECRET;
                end
                if (fits) then
                    room.DisplayFlags = room.DisplayFlags | 6;
                end
            end
        end
        level:UpdateVisibility();

        THI.EvaluateCurses();
    end

    function Wings:GetTimeByFrame(frame)
        local seconds = math.floor(frame / 30);
        seconds = seconds % 240;
        if (seconds < 30) then
            return self.Time.DAWN;
        elseif (seconds < 120) then
            return self.Time.DAY;
        elseif (seconds < 150) then
            return self.Time.DUSK;
        elseif (seconds < 240) then
            return self.Time.NIGHT;
        end
    end

end

do -- Events.

    local function EvaluateItems(mod, player, flag)
        if (player:HasCollectible(Wings.Item)) then
            local time = Wings:GetTime()
            if (time == Wings.Time.DAY) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:AddDamageUp(player, 1);
                elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsModifier(player, function(tears)
                        return tears - 0.5
                    end);
                end
            elseif (time == Wings.Time.NIGHT) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsUp(player, 1);
                elseif (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:AddFlatDamage(player, -0.5);
                end
            elseif (time == Wings.Time.DAWN) then
                if (flag == CacheFlag.CACHE_FIREDELAY) then
                    Stats:AddTearsUp(player, 0.5);
                end
            elseif (time == Wings.Time.DUSK) then
                if (flag == CacheFlag.CACHE_DAMAGE) then
                    Stats:AddDamageUp(player, 0.5);
                end
            end

            if (flag == CacheFlag.CACHE_FLYING) then
                player.CanFly = true;
            end
        end
    end
    Wings:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateItems)

    local function PostUpdate()
        local game = Game();
        -- If it's half a minute.
        local frameCount = Game().TimeCounter
        if (frameCount % 900 == 1) then
            -- Do a time update.
            if (Collectibles.IsAnyHasCollectible(Wings.Item)) then
                Wings:SetTime(Wings:GetTimeByFrame(frameCount))
            else
                Wings:ResetTime();
            end
        end

        local time = Wings:GetTime()
        if (time == Wings.Time.NIGHT or time == Wings.Time.DAWN) then
            if (Wings:IsApplyingCurseOfDarkness()) then
                local darkness = game:GetDarknessModifier();
                if (darkness == 0) then
                    game:Darken(1, 30);
                elseif (darkness == 1) then
                    THI.EvaluateCurses();
                    Wings:FinishCurseOfDarkness();
                end
            end
        end
    end
    Wings:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

    local function PostWingsChanged(mod, player, item, diff)
        local frameCount = Game().TimeCounter
        if (Collectibles.IsAnyHasCollectible(Wings.Item)) then
            Wings:SetTime(Wings:GetTimeByFrame(frameCount))
        else
            Wings:ResetTime();
        end
    end
    Wings:AddCallback(CuerLib.CLCallbacks.CLC_POST_CHANGE_COLLECTIBLES, PostWingsChanged, Wings.Item)

    local function EvaluateCurse(mod, curses)
        local time = Wings:GetTime()
        if (time == Wings.Time.DAY or time == Wings.Time.DUSK) then
            curses = curses & ~LevelCurse.CURSE_OF_DARKNESS;
        elseif (time == Wings.Time.NIGHT or time == Wings.Time.DAWN) then
            local isDarkness = true;
            if (Wings:IsApplyingCurseOfDarkness()) then
                isDarkness = Game():GetDarknessModifier() >= 1;
            end
            if (isDarkness) then
                curses = curses | LevelCurse.CURSE_OF_DARKNESS;
            end
        end
        return curses;
    end
    Wings:AddCallback(CuerLib.CLCallbacks.CLC_EVALUATE_CURSE, EvaluateCurse)
end

return Wings;