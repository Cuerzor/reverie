local Collectibles = CuerLib.Collectibles;
local Players = CuerLib.Players;
local Screen = CuerLib.Screen;
local Pickups = CuerLib.Pickups;

local ReverieMusic = ModItem("Reverie Music", "REVERIE_MUSIC");

ReverieMusic.Pitches = {
    1,
    2,
    6,
    1,
    2,
    5,
    1,
    2,

    7,
    1,
    2,
    6,
    1,
    2,
    5,
}
ReverieMusic.PlayerHasItem = nil;
ReverieMusic.MaxNoteCount = 15

local function GetGlobalData(create)
    return ReverieMusic:GetGlobalData(create, function()
        return {
            CollectedMusic = {},
            MusicNum = 0,
            MusicSpawned = false,
        }
    end)
end


local function GetTempGlobalData(create)
    return ReverieMusic:GetTempGlobalData(create, function()
        return {
            MusicAlpha = 0,
            MusicShowTimeout = 90,
            PaperSpawned = false
        }
    end)
end


local function PostUpdate(mod)
    ReverieMusic.PlayerHasItem = nil;
    for p, player in Players.PlayerPairs() do
        if (player:HasCollectible(ReverieMusic.Item, true)) then
            ReverieMusic.PlayerHasItem = player;
            break;
        end
    end

    local musicMNG = MusicManager();
    local music = musicMNG:GetCurrentMusicID();
    local data = GetGlobalData(true);
    if (not data.CollectedMusic[tostring(music)]) then
        data.CollectedMusic[tostring(music)] = true;
        data.MusicNum = data.MusicNum + 1;
        if (data.MusicNum <= ReverieMusic.MaxNoteCount and ReverieMusic.PlayerHasItem) then
            local pitch = 2^((ReverieMusic.Pitches[data.MusicNum]) /12);
            SFXManager():Play(THI.Sounds.SOUND_PIANO_C4, 1, 0, false, pitch);

            
            local tempData = GetTempGlobalData(true);
            tempData.MusicShowTimeout = 90;
        end
    end

    if (ReverieMusic.PlayerHasItem) then
        local tempData = GetTempGlobalData(true);
        if (tempData.MusicShowTimeout < 0) then
            tempData.MusicAlpha = tempData.MusicAlpha - 0.1;
        else
            tempData.MusicAlpha = tempData.MusicAlpha + 0.1;
            tempData.MusicShowTimeout = tempData.MusicShowTimeout - 1;
        end
        tempData.MusicAlpha = math.min(math.max(tempData.MusicAlpha, 0), 1);
    end

    -- 生成漂浮的乐谱纸。
    if (ReverieMusic.PlayerHasItem and data.MusicNum >= ReverieMusic.MaxNoteCount) then
        
        local room = Game():GetRoom();
        local level = Game():GetLevel();
        if (room:IsClear()) then
            local bossID = room:GetBossID();
            if (level:GetStage() == 8 and
                --Mom's Heart
                --bossID == 8 or 
                --It lives
                bossID == 25 ) then
                
                local tempData = GetTempGlobalData(false);

                local Box = THI.Pickups.ReverieMusicBox;
                local hasBox = #Isaac.FindByType(Box.Type, Box.Variant, Box.SubType) > 0;

                if (not tempData or not tempData.PaperSpawned and not hasBox)then
                    tempData = GetTempGlobalData(true);

                    local Paper = THI.Effects.ReverieMusicPaper;
                    local player = ReverieMusic.PlayerHasItem;
                    local paper = Isaac.Spawn(Paper.Type, Paper.Variant, Paper.SubType, player.Position, Vector.Zero, player);
                    paper.Parent = player;
                    local width = room:GetGridWidth();
                    paper.TargetPosition = room:GetGridPosition(width * 3 - 3);
                    paper.PositionOffset = Vector(0, -20);

                    tempData.PaperSpawned = true;
                end
            end
            
        end
    end
end
ReverieMusic:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate);

local function PostNewRoom(mod)
    
    if (THI.IsBossEnabled("Reverie")) then
        local tempData = GetTempGlobalData(false);
        if (tempData and tempData.PaperSpawned)then
            tempData.PaperSpawned = false;
        end

        local game = Game();
        local level = game:GetLevel();
        local room = game:GetRoom();
        local data = GetGlobalData(true);
        local stageType = level:GetStageType();
        local stage1 = level:GetStage() == 1 and stageType ~= StageType.STAGETYPE_GREEDMODE and stageType ~= StageType.STAGETYPE_REPENTANCE and stageType ~= StageType.STAGETYPE_REPENTANCE_B;
        if (game.Challenge == 0 and data.MusicNum >= 5 and not data.MusicSpawned and stage1
        and room:GetType() == RoomType.ROOM_TREASURE and not level:IsAscent ( ) and not game:IsGreedMode()) then
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0, 80));
            local col = Pickups:SpawnFixedCollectible(ReverieMusic.Item, pos, Vector.Zero, nil);
            col:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE);
            data.MusicSpawned = true;
        end
    end
end
ReverieMusic:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);


local NormalColor = KColor(1,1,1,1);
local CompleteColor = KColor(0,1,0,1);

local function PostRender(mod)
    local data = GetGlobalData(false);
    if (ReverieMusic.PlayerHasItem and data) then

        if (Game():GetHUD():IsVisible()) then

            local font = THI.GetFont("MUSICS");

            local musicString = THI.GetText(THI.StringCategories.DEFAULT, "#COLLECTED_MUSIC");
            local max = ReverieMusic.MaxNoteCount;
            musicString = string.gsub(musicString, "{{MAX}}", max);
            musicString = string.gsub(musicString, "{{CURRENT}}", math.min(max, data.MusicNum));


            local tempData = GetTempGlobalData(false);
            local alpha = (tempData and tempData.MusicAlpha) or 1;
            local FontColor = KColor(1,1,1,alpha);
            if (data.MusicNum >= max) then
                FontColor.Red, FontColor.Blue = 0, 0;
            end

            local size = Screen.GetScreenSize() 
            local pos = Vector(size.X / 2 - 96, 8 + Options.HUDOffset * 24);
            font:DrawStringUTF8(musicString, pos.X - 32, pos.Y, FontColor, 64, true)
        end
        
    end
end
ReverieMusic:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender);

return ReverieMusic;