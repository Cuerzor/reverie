local Familiars = CuerLib.Familiars;
local Consts = CuerLib.Consts;
local Math = CuerLib.Math;
local Entities = CuerLib.Entities;
local CompareEntity = Entities.CompareEntity;
local Players = CuerLib.Players;
local Fairies = ModPart("Light Fairies", "LIGHT_FAIRIES");
Fairies.FairyInfos = {}
Fairies.ComboFairies = {}
Fairies.SubTypes = {
    DORMANT = 0,
    AWAKED = 1,
}

local function GetPlayerData(player, create) 
    return Fairies:GetData(player, create, function() return {
        AwakeFairies = {}
    } end);
end
local function GetFairyData(familiar, create) 
    return Fairies:GetData(familiar, create, function() return {
        IsFollowing = false
    } end);
end
local function GetFairyTempData(familiar, create) 
    return Fairies:GetData(familiar, create, function() return {
        ComboFairyCount = 0,
        ComboIndex = 0,
        ComboTime = 0,
    } end);
end

function Fairies:HasNeededRoom(variant)

    local needed = self.FairyInfos[variant] and self.FairyInfos[variant].AwakeRoomTypes;

    if (not needed) then
        return false;
    end
    local level = Game():GetLevel();
    local rooms = level:GetRooms();
    for i = 0, rooms.Size - 1 do
        local room = rooms:Get(i);
        if (room and room.Data) then
            local type = room.Data.Type;
            for needType, value in pairs(needed) do
                if (type == needType and value) then
                    return true;
                end
            end
        end
    end
    return false
end

function Fairies:AddFairy(variant, info)
    self.FairyInfos[variant] = info;
end

function Fairies:RemoveFairy(variant, info)
    self.FairyInfos[variant] = nil;
end

function Fairies:AddComboFairy(item, variant)
    self.ComboFairies[item] = variant;
end
function Fairies:RemoveComboFairy(item, variant)
    self.ComboFairies[item] = variant;
end
function Fairies:GetAwakedFairyNum(player, variant)
    local data = GetPlayerData(player, false);
    if (data) then
        return (data.AwakeFairies[variant] or 0);
    end
    return 0;
end
function Fairies:ClearAwakedFairyNum(player, variant)
    local data = GetPlayerData(player, false);
    if (data) then
        data.AwakeFairies[variant] = 0;
    end
end



function Fairies:WakeFairy(familiar)
    familiar.SubType = Fairies.SubTypes.AWAKED;
    familiar:GetSprite():Play("Awake");
    local player = familiar.Player;
    if (player) then
        local data = GetPlayerData(player, true);
        data.AwakeFairies[familiar.Variant] = (data.AwakeFairies[familiar.Variant] or 0) + 1;
    end
end

function Fairies:ComboFairy(familiar, index, count)
    familiar.SubType = Fairies.SubTypes.AWAKED;
    familiar:GetSprite():Play("Combo");
    local fairyData = GetFairyTempData(familiar, true);
    fairyData.ComboIndex = index;
    fairyData.ComboFairyCount = count;
    fairyData.ComboTime = 0;

    local player = familiar.Player;
    if (player) then
        local data = GetPlayerData(player, true);
        data.AwakeFairies[familiar.Variant] = (data.AwakeFairies[familiar.Variant] or 0) + 1;
    end
end

function Fairies:DormantFairy(familiar)
    familiar.SubType = Fairies.SubTypes.DORMANT;
    familiar:GetSprite():Play("Awake");
    local player = familiar.Player;
    if (player) then
        local data = GetPlayerData(player, false);
        if (data and data.AwakeFairies) then
            local awakeNum = data.AwakeFairies[familiar.Variant];
            if (awakeNum and awakeNum > 0) then
                data.AwakeFairies[familiar.Variant] = awakeNum - 1;
            end
        end
    end
end

function Fairies:SpawnAward(familiar, awards)
    local room = Game():GetRoom();
    for i, award in pairs(awards) do
        for num = 1, award.Count do
            local pos = room:FindFreePickupSpawnPosition(familiar.Position);
            Isaac.Spawn(award.Type, award.Variant or 0, award.SubType or 0, pos, Vector.Zero, familiar);
        end
    end
end

local function PostFairyUpdate(mod, familiar)


    for variant, info in pairs(Fairies.FairyInfos) do
        if (variant == familiar.Variant) then
            local roomTypes = info.AwakeRoomTypes;
            local awards = info.AwakeAwards;
            local fireTearFunc = info.FireTear;
            
            local spr = familiar:GetSprite()
            
            local player = familiar.Player;
            local data = GetFairyData(familiar, true); 

            -- Following.
            if (spr:IsPlaying("Combo")) then
            
                if (data.IsFollowing) then
                    familiar:RemoveFromFollowers();
                    data.IsFollowing = false;
                end
            else
                   
                if (not data.IsFollowing) then
                    familiar:AddToFollowers();
                    data.IsFollowing = true;
                end 
                familiar:FollowParent();
            end


            
            if (familiar.SubType == Fairies.SubTypes.DORMANT) then -- Dormant.
                spr:Play("Dormant");
                local room = Game():GetRoom();
                if (room:GetFrameCount() % 30 == 11) then
                    
                    local roomType = room:GetType();
                    if (roomTypes[roomType] or not Fairies:HasNeededRoom(variant)) then
                        THI.SFXManager:Play(SoundEffect.SOUND_POWERUP_SPEWER);
                        Fairies:WakeFairy(familiar);
                    end
                end
            else
                if (spr:IsPlaying("Awake") or spr:IsPlaying("Combo")) then -- Awaking.

                    if (spr:IsPlaying("Combo")) then
                        local fairyData = GetFairyTempData(familiar, false);
                        if (fairyData) then
                            local maxTime = 35;
                            local timeX = fairyData.ComboTime / maxTime;
                            local time;
                            if (timeX < 0.5) then
                                time = timeX ^ 2 *2
                            else
                                time =  1-(2 * (timeX-1)^2)
                            end
                            local angle = 90 + fairyData.ComboIndex / fairyData.ComboFairyCount * 360 + time * 720;
                            if (fairyData.ComboFairyCount == 0) then
                                angle = time * 360;
                            end

                            local radius = math.min(40, timeX * 100);

                            local targetPos = player.Position + Vector.FromAngle(angle) * radius;
                            familiar.Velocity = familiar.Velocity * 0.5 + (targetPos - familiar.Position) * 0.5;

                            if (fairyData.ComboTime < maxTime) then
                                fairyData.ComboTime = fairyData.ComboTime + 1;
                            end
                        end 
                    end

                    if (spr:IsEventTriggered("Bonus")) then
                        THI.SFXManager:Play(SoundEffect.SOUND_THUMBSUP);
                        Fairies:SpawnAward(familiar, awards);
                    end
                else -- Awaked.
                    local dir = player:GetFireDirection();
                    local fireDir = Familiars.GetFireVector(familiar, dir)
                    Familiars.DoFireCooldown(familiar);
                    if (dir ~= Direction.NO_DIRECTION and Familiars.CanFire(familiar) and (player == nil or player:IsExtraAnimationFinished())) then
                        familiar.HeadFrameDelay = 7;
                        familiar.FireCooldown = 9;
                        fireTearFunc(familiar, fireDir)
                        familiar.ShootDirection = Math.GetDirectionByAngle(fireDir:GetAngleDegrees());
                    end

                    if (Familiars.CanFire(familiar)) then
                        familiar.ShootDirection = Direction.NO_DIRECTION;
                    end
                    
                    Familiars.AnimationUpdate(familiar, Consts.DirectionVectors[familiar.ShootDirection]);
                end
            end
        end
    end
end
Fairies:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostFairyUpdate)

local function PostPlayerEffect(mod, player)
    local room = Game():GetRoom();
    if (room:GetFrameCount() == 10 or Game():GetFrameCount() % 30 == 0) then
        local fairyCollectiblesNum = {}
        local minCollectibleCount = 0; 
        for item, variant in pairs(Fairies.ComboFairies) do
            local num = player:GetCollectibleNum(item, true);
            fairyCollectiblesNum[item] = num;
            minCollectibleCount = math.min(minCollectibleCount, num);
        end

        -- If Collectible group's count is larger than 0.
        if (minCollectibleCount > 0) then

            local comboFairyCount = 0;
            -- Find valid (dormant) fairy groups.
            local dormantFairies = {};
            local minFamiliarCount = 32768;
            for item, variant in pairs(Fairies.ComboFairies) do
                comboFairyCount = comboFairyCount + 1;
                dormantFairies[variant] = {};
                for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, variant, Fairies.SubTypes.DORMANT)) do
                    local familiar = ent:ToFamiliar();
                    if (CompareEntity(familiar.Player, player)) then
                        table.insert(dormantFairies[variant], familiar);
                    end
                end
                minFamiliarCount = math.min(#dormantFairies[variant], minFamiliarCount);
            end

            -- Combo fairies.
            local comboGroupCount = math.min(minCollectibleCount, minFamiliarCount);
            local fairyCount = comboGroupCount * comboFairyCount;
            local fairyIndex = 0;
            for group = 1, comboGroupCount do
                for variant, list in pairs(dormantFairies) do
                    Fairies:ComboFairy(list[1], fairyIndex, fairyCount)
                    fairyIndex = fairyIndex + 1;
                    table.remove(list, 1);
                end
            end
            if (comboGroupCount > 0) then
                THI.SFXManager:Play(SoundEffect.SOUND_POWERUP_SPEWER_AMPLIFIED);
                THI.SFXManager:Play(THI.Sounds.SOUND_FAIRY_HEAL);
            end
        end
    end
    
end
Fairies:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)


local function PostNewLevel(mod)
    
    
    for variant, info in pairs(Fairies.FairyInfos) do

        for p, player in Players.PlayerPairs(true, true) do
            Fairies:ClearAwakedFairyNum(player, variant)
        end

        local hasRoom = Fairies:HasNeededRoom(variant);

        for i, ent in pairs(Isaac.FindByType(3, variant)) do
            local familiar = ent:ToFamiliar();
            if (familiar.SubType ~= Fairies.SubTypes.DORMANT) then
                Fairies:DormantFairy(familiar);
            end

        end

        
    end
end
Fairies:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel)
return Fairies;