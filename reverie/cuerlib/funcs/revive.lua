---@alias ReviveCallback fun(player :EntityPlayer , reviver:EntityPlayer) @param Player is the reviving player. reviver is the the player that revives the dead.

---@class ReviveInfo
---@field CanBorrowLife boolean @Can player borrow life from the other twin?
---@field BeforeVanilla boolean @Will this revive before vanilla items?
---@field Animation string @Animation name which player should play while reviving.
---@field ReviveFrame integer @Frame number which the revive animation should stops at.
---@field Callback ReviveCallback @Function called after revive. 

local Lib = LIB;

local Revive = Lib:NewClass();
Revive.Infos = {}

local function GetPlayerData(player)
    local data = Lib:GetEntityLibData(player);
    data._REVIVE = data._REVIVE or {
        IsDead = false,
        ReviveTime = 0,
        ReviveInfo = nil,
        Reviver = nil,
        PlayingAnimation = nil,
        AnimationCountdown = -1
    }
    return data._REVIVE;
end

function Revive.GetPlayerData(player)
    return GetPlayerData(player);
end


function Revive.IsReviving(player)
    local playerType = player:GetPlayerType();
    local data = GetPlayerData(player);
    -- if (IsForgottenB(player)) then
    --     local twin = player:GetOtherTwin()
    --     local twinData = GetPlayerData(twin);
    --     return data.IsDead or twinData.IsDead;
    -- else
        return data.IsDead;
    --end
end

---@param player EntityPlayer 
---@return string ReviveAnimation
function Revive:GetPlayerReviveAnimation(player)
    local playerType = player:GetPlayerType();
    if (playerType == PlayerType.PLAYER_THELOST 
    or playerType == PlayerType.PLAYER_THELOST_B 
    or playerType == PlayerType.PLAYER_THESOUL
    or playerType == PlayerType.PLAYER_THESOUL_B) then
        return "LostDeath";
    end

    if (player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)) then
        return "LostDeath";
    end

    return "Death";
end


---@param player EntityPlayer 
---@return integer ReviveFrame
function Revive:GetPlayerReviveFrame(player)
    local playerType = player:GetPlayerType();
    if (playerType == PlayerType.PLAYER_THELOST 
    or playerType == PlayerType.PLAYER_THELOST_B 
    or playerType == PlayerType.PLAYER_THESOUL
    or playerType == PlayerType.PLAYER_THESOUL_B) then
        return 37;
    end

    if (player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)) then
        return 37;
    end

    return 56;
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

local function IsForgottenB(player)
    local playerType = player:GetPlayerType();
    return playerType == PlayerType.PLAYER_THEFORGOTTEN_B or playerType == PlayerType.PLAYER_THESOUL_B;
end

do -- Check.
    local function CanSinglePlayerRevive(player, result)
        return result.BeforeVanilla or not player:WillPlayerRevive();
    end
    local function CanResultRevive(player, result)
        local playerType = player:GetPlayerType();
        local reviver = player;
        if (CanSinglePlayerRevive(player, result)) then
            return true, player;
        elseif (result.CanBorrowLife) then
            if (playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU) then
                local twin = player:GetOtherTwin();
                if (twin and CanSinglePlayerRevive(twin, result)) then
                    return true, twin;
                end
            end
        end
        return false, nil;
    end

    function Revive:CanPlayerRevive(player)
        local canRevive = false;
        ---@type ReviveInfo
        local info = nil;
        local resultReviver = nil;

        for _, i in pairs(Lib.Callbacks.Functions.PreRevive) do
            local result = i.Func(i.Mod, player);
            if (result) then
                if (result.CanBorrowLife == nil) then result.CanBorrowLife = true; end
                if (result.BeforeVanilla == nil) then result.BeforeVanilla = false; end
                local can, reviver = CanResultRevive(player, result);
                if (can) then
                    canRevive = can;
                    info = result;
                    resultReviver = reviver;
                    break;
                end
            end
        end
        return { CanRevive = canRevive, Info = info, Reviver = resultReviver};
    end

end


-- Revive Player at specific animation frame.
local function RevivePlayer(player)
    local data = GetPlayerData(player);
    local playerType = player:GetPlayerType();
    local maxHearts = player:GetMaxHearts();
    local hearts = player:GetHearts();

    if (playerType == PlayerType.PLAYER_THEFORGOTTEN_B) then
        if (player.EntityCollisionClass == 0) then
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
        end
    end

    -- Keeper and Bethany will has at lease one heart container.
    if (Lib.Players:IsFullRedHeartPlayer(playerType)) then
        if (maxHearts <= 0) then
            player:AddMaxHearts(2 - maxHearts);
        end
        if (hearts <= 0) then
            player:AddHearts(1);
        end
    -- The forgotten will has at lease one bone heart.
    elseif (Lib.Players:IsFullBoneHeartPlayer(playerType)) then
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
                Lib.Players:AddRawSoulHearts(player, 1);
            end
        end
    end


    local info = data.ReviveInfo;

    
    local callback = info.Callback;
    if (callback) then
        callback(player, data.Reviver);
    end

    
    for _, i in pairs(Lib.Callbacks.Functions.PostRevive) do
        i.Func(i.Mod, player, info);
    end
end

local function ReviveUpdate(player) 

    local type = player:GetPlayerType();

    local data = GetPlayerData(player);
    local info = data.ReviveInfo;
    local spr = player:GetSprite();
    local frame = spr:GetFrame();--data.ReviveTime;

    local canRevive = false;
    local anim = spr:GetAnimation();
    if (player:IsExtraAnimationFinished()) then
        player:PlayExtraAnimation(info.Animation);
    else
        canRevive = frame >= info.ReviveFrame-- or player:IsExtraAnimationFinished();
    end

    if (canRevive or data.ReviveTime >= 60) then
        
        data.IsDead = false;
        data.ReviveTime = 0;
        player:StopExtraAnimation();
        player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        RevivePlayer(player);
        return true;
    end
    return false;
end

do -- Events.
    local function PostPlayerKilled(mod, entity)
        local player = entity:ToPlayer();

        if (entity.Variant == 1) then
            return;
        end
        local playerType = player:GetPlayerType();
        local isForgottenB = playerType == PlayerType.PLAYER_THEFORGOTTEN_B;
        local twin = player:GetOtherTwin()
        local data = GetPlayerData(entity);
        

        
        -- Check if player can revive.
        local reviveInfoData = Revive:CanPlayerRevive(player);

        local canRevive = reviveInfoData.CanRevive;
        local info = reviveInfoData.Info;
        local reviver = reviveInfoData.Reviver;

        if (canRevive) then
            -- If Can Revive.
            local shouldHasHeart = player:GetBoneHearts() + player:GetSoulHearts() + player:GetHearts() > 0;
            local addedHeartContainers = 0;

            local onlyRedHearts = Lib.Players:IsFullRedHeartPlayer(playerType);
            local onlyBoneHearts = Lib.Players:IsFullBoneHeartPlayer(playerType);
            
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

            if (isForgottenB) then
                if (not player.Visible) then
                    player.Visible = true;
                end
            end

            -- Remove added Heart Containers to make it invisible.
            if(onlyRedHearts) then
                player:AddMaxHearts(-addedHeartContainers);
            end


            -- Set Data Info.
            info.Animation = info.Animation or Revive:GetPlayerReviveAnimation(player);
            info.ReviveFrame = info.ReviveFrame or Revive:GetPlayerReviveFrame(player);


            data.ReviveTime = 0;
            data.IsDead = true;
            data.ReviveInfo = info;
            data.AnimationCountdown = -1;
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
                    Lib.Players:AddRawSoulHearts(player, -soulHearts)
                end
            end
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPlayerKilled, EntityType.ENTITY_PLAYER);

    local function PostPlayerUpdate(mod, player)
        local playerType = player:GetPlayerType();
        local data = GetPlayerData(player);
        if (data.PlayingAnimation) then
            data.AnimationCountdown = data.AnimationCountdown or -1;
            if (data.AnimationCountdown < 0) then
                
                player:PlayExtraAnimation(data.PlayingAnimation)
                data.PlayingAnimation = nil;
            else
                data.AnimationCountdown = data.AnimationCountdown - 1;
            end
        end
        if (Revive.IsReviving(player)) then
            player:SetMinDamageCooldown(120);
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
            if (player:GetSprite():IsEventTriggered("DeathSound")) then
                SFXManager():Play(SoundEffect.SOUND_ISAACDIES);
            end
            player.ControlsCooldown = math.max(player.ControlsCooldown, 1);
            player.Velocity = Vector.Zero;
            ReviveUpdate(player);
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);

    local function PostPlayerEffect(mod, player)
        if (Revive.IsReviving(player)) then
            local data = GetPlayerData(player);
            data.ReviveTime = data.ReviveTime + 1;
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect);
    

    local function PrePlayerCollision(mod, player, other, low)
        if (Revive.IsReviving(player)) then
            return true;
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PrePlayerCollision);

    local function PreOtherCollision(mod, _, other, low)
        if (other.Type == EntityType.ENTITY_PLAYER) then
            local player = other:ToPlayer();
            local data = GetPlayerData(player);
            if (Revive.IsReviving(player)) then
                return true;
            end
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreOtherCollision);
    Revive:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreOtherCollision);

end

return Revive;