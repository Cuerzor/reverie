local Lib = CuerLib;

local Revive = {
    Infos = {}
}

local function GetPlayerData(player)
    local data = Lib:GetData(player);
    data._REVIVE = data._REVIVE or {
        IsDead = false,
        ReviveTime = 0,
        ReviveInfo = nil,
        Reviver = nil,
        PlayingAnimation = nil
    }
    return data._REVIVE;
end

function Revive.GetPlayerData(player)
    return GetPlayerData(player);
end

local function CanInfoRevive(player, info)
    local playerType = player:GetPlayerType();
    local reviver = player;
    local canRevive = (info.BeforeVanilla or not player:WillPlayerRevive()) and info.ReviveCondition(player);
    
    if (not canRevive and info.CanBorrowLife) then
        if (playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU) then
            local twin = player:GetOtherTwin();
            if (twin) then
                local canTwinRevive = (info.BeforeVanilla or not twin:WillPlayerRevive()) and info.ReviveCondition(twin);
                canRevive = canRevive or canTwinRevive;
                if (canTwinRevive) then
                    reviver = twin;
                end
            end
        end
    end
    return canRevive, reviver;
end

local function CanPlayerRevive(player)
    local result = false;
    local topPriorityInfo = nil;
    local resultReviver = nil;
    for id, info in pairs(Revive.Infos) do
        local canRevive, reviver = CanInfoRevive(player, info);
        if (canRevive) then

            local replace = false;
            if (not topPriorityInfo) then
                replace = true;
            else
                if (info.Priority > topPriorityInfo.Priority) then
                    replace = true;
                elseif (info.Priority == topPriorityInfo.Priority) then
                    replace = info.ReviveTime < topPriorityInfo.ReviveTime;
                end
            end


            if (replace) then
                result = true;
                topPriorityInfo =  info;
                resultReviver = reviver;
            end
        end
    end
    return { CanRevive = result, Info = topPriorityInfo, Reviver = resultReviver};
end

local function RevivePlayer(player)

    local data = GetPlayerData(player);
    local playerType = player:GetPlayerType();
    local maxHearts = player:GetMaxHearts();
    local hearts = player:GetHearts();
    -- Keeper and Bethany will has at lease one heart container.
    if (playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or playerType == PlayerType.PLAYER_BETHANY) then
        if (maxHearts <= 0) then
            player:AddMaxHearts(2 - maxHearts);
        end
        if (hearts <= 0) then
            player:AddHearts(1);
        end
    -- The forgotten will has at lease one bone heart.
    elseif (playerType == PlayerType.PLAYER_THEFORGOTTEN) then
        local boneHearts = player:GetBoneHearts();
        if (boneHearts <= 0) then
            player:AddBoneHearts(1);
        end
    else
        if (maxHearts > 0) then
            -- If player has heart containers, and has no red hearts, add 1 red heart.
            if (hearts <= 0) then
                player:AddHearts(1-hearts);
            end
        else
            -- If don't have heart containers, and has no soul hearts, add 1 soul heart.
            if (player:GetSoulHearts() <= 0) then
                player:AddSoulHearts(1);
            end
        end
    end
end

local function CheckRevive(player) 

    local type = player:GetPlayerType();

    

    local data = GetPlayerData(player);
    local info = data.ReviveInfo;

    if (data.IsDead and data.ReviveTime > info.ReviveTime) then
        RevivePlayer(player);

        data.IsDead = false;
        data.ReviveTime = 0;
        player:StopExtraAnimation();
        player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        if (info.Callback) then
            info.Callback(player, data.Reviver);
        end
        return true;
    end
    return false;
end

function Revive.IsReviving(player)
    
    local data = GetPlayerData(player);
    return data.IsDead;
end
function Revive.AddReviveInfo(beforeVanilla, reviveTime, animation, reviveCondition, reviveCallback, canBorrowLife, priority)
    reviveCondition = reviveCondition or nil;
    reviveTime = reviveTime or 112;
    animation = animation or "Death";
    reviveCallback = reviveCallback or nil;
    if (canBorrowLife == nil) then
        canBorrowLife = true;
    end
    priority = priority or 0;

    if (reviveCondition == nil) then
        reviveCondition = function(player) return true; end
    end
    local info = { 
        BeforeVanilla = beforeVanilla, 
        Animation = animation, 
        ReviveCondition = reviveCondition, 
        ReviveTime = reviveTime,
        Callback = reviveCallback,
        CanBorrowLife = canBorrowLife,
        Priority = priority,
    }

    table.insert(Revive.Infos, info);
end
function Revive:onPlayerKilled(entity)
    local player = entity:ToPlayer();
    local data = GetPlayerData(entity);
    local playerType = player:GetPlayerType();

    
    
    -- Check if player can revive.
    local reviveInfoData = CanPlayerRevive(player);

    local canRevive = reviveInfoData.CanRevive;
    local info = reviveInfoData.Info;
    local reviver = reviveInfoData.Reviver;

    if (canRevive) then
        -- If Can Revive.
        local shouldHasHeart = player:GetBoneHearts() + player:GetSoulHearts() + player:GetHearts() > 0;
        local addedHeartContainers = 0;

        local onlyRedHearts = playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or playerType == PlayerType.PLAYER_BETHANY;
        local onlyBoneHearts = playerType == PlayerType.PLAYER_THEFORGOTTEN
        
        if (not shouldHasHeart) then
            -- Add hearts for no soul heart characters, avoiding revive() create a soul heart.
            if(onlyBoneHearts) then
                player:AddBoneHearts(1);
            -- Keeper and Bethany will create a heart container.
            elseif(onlyRedHearts) then
                if (player:GetMaxHearts() <= 0) then
                    player:AddMaxHearts(2);
                    addedHeartContainers = addedHeartContainers + 2;
                end
                player:AddHearts(2);
            end
        end

        player:Revive();

        -- Remove added Heart Containers to make it invisible.
        if(onlyRedHearts) then
            player:AddMaxHearts(-addedHeartContainers);
        end


        -- Set Data Info.
        data.ReviveTime = 0;
        data.IsDead = true;
        data.ReviveInfo = info;
        data.PlayingAnimation = info.Animation;
        data.Reviver = reviver;


        -- Clear Hearts.
        if (not shouldHasHeart) then
            local redHearts = player:GetHearts();
            if (redHearts > 0) then
                player:AddHearts(-redHearts);
            end

            local boneHearts = player:GetBoneHearts();
            if (boneHearts > 0) then
                player:AddBoneHearts(-boneHearts);
            end

            local soulHearts = player:GetSoulHearts();
            if (soulHearts > 0) then
                player:AddSoulHearts(-soulHearts);
            end
        end
    end
end

function Revive:onPlayerUpdate(player)
    local data = GetPlayerData(player);
    if (data.PlayingAnimation) then
        player:PlayExtraAnimation(data.PlayingAnimation)
        data.PlayingAnimation = nil;
    end
    if (data.IsDead) then
        player:SetMinDamageCooldown(120);
        player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        data.ReviveTime = data.ReviveTime + 1;
        if (player:GetSprite():IsEventTriggered("DeathSound")) then
            THI.SFXManager:Play(SoundEffect.SOUND_ISAACDIES);
        end
        player.Velocity = Vector.Zero;
        CheckRevive(player);
    end
end

function Revive:onInputAction(entity, hook, action)
    -- Disable all motion action while dead.
    if (entity) then
        if (entity.Type == EntityType.ENTITY_PLAYER) then
            local player = entity:ToPlayer();
            local data = GetPlayerData(player);
            if (data.IsDead) then
                if (hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED) then
                    return false;
                elseif (hook == InputHook.GET_ACTION_VALUE) then
                    return 0;
                end
            end
        end
    end
end

function Revive:PrePlayerCollision(player, other, low)
    local data = GetPlayerData(player);
    if (data.IsDead) then
        return false;
    end
end

function Revive:preNPCCollision(npc, other, low)
    if (other.Type == EntityType.ENTITY_PLAYER) then
        local player = other:ToPlayer();
        local data = GetPlayerData(player);
        if (data.IsDead) then
            return false;
        end
    end
    return nil;
end

function Revive:Register(mod)
    local Callbacks = Lib.Callbacks;

    
    Callbacks:AddCallback(mod, CLCallbacks.CLC_PRE_PLAYER_COLLISION, Revive.PrePlayerCollision);
    mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Revive.preNPCCollision);

    mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Revive.onInputAction);
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Revive.onPlayerUpdate);
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Revive.onPlayerKilled, EntityType.ENTITY_PLAYER);
end


function Revive:Unregister(mod)
    local Callbacks = Lib.Callbacks;
    Callbacks:RemoveCallback(mod, CLCallbacks.CLC_PRE_PLAYER_COLLISION, Revive.PrePlayerCollision);
    mod:RemoveCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Revive.preNPCCollision);

    mod:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, Revive.onInputAction);
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Revive.onPlayerUpdate);
    mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_KILL, Revive.onPlayerKilled);
end

return Revive;