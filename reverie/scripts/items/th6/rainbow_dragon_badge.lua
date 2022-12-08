local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local Screen = CuerLib.Screen;

local DragonBadge = ModItem("Rainbow Dragon Badge", "DragonBadge");
DragonBadge.MaxTime = 30;
DragonBadge.MaxUseTime = 10;
DragonBadge.Colors ={
    [0] = Color(1,1,1,1,1,0,0),
    [1] = Color(1,1,1,1,1,0.5,0),
    [2] = Color(1,1,1,1,1,1,0),
    [3] = Color(1,1,1,1,0.5,1,0),
    [4] = Color(1,1,1,1,0,1,0),
    [5] = Color(1,1,1,1,0,1,0.5),
    [6] = Color(1,1,1,1,0,1,1),
    [7] = Color(1,1,1,1,0,0.5,1),
    [8] = Color(1,1,1,1,0,0,1),
    [9] = Color(1,1,1,1,0.5,0,1),
    [10] = Color(1,1,1,1,1,0,1),
    [11] = Color(1,1,1,1,1,0,0.5)
};
DragonBadge.DarkColor = Color(1, 0, 0, 1, 0, 0, 0);
DragonBadge.PunchSprite = Sprite();
DragonBadge.PunchSprite:Load("gfx/reverie/ui/belial_badge_punch.anm2", true)
DragonBadge.PunchSprite:Play("Idle")
DragonBadge.BlackscreenSprite = Sprite();
DragonBadge.BlackscreenSprite:Load("gfx/reverie/ui/belial_badge_punch.anm2", true)
DragonBadge.BlackscreenSprite:Play("BlackScreen")
DragonBadge.RagingDemonCostume = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_raging_demon.anm2")

function DragonBadge:GetBadgeGlobalData(create) 
    return DragonBadge:GetTempGlobalData(create, function() return {
        Pausing = false,
        BlackScreen = 0,
        Punches = {}
    } end);
end

function DragonBadge:GetPlayerData(player, create) 
    return DragonBadge:GetData(player, create, function() return {
        dashing = false,
        useTime = 0,
        dashTime = 0,
        BelialTarget = nil,
        BelialState = 0,
        BelialTime = 0
    } end);
end

function DragonBadge:GetNPCData(npc) 
    return DragonBadge:GetData(npc, true, function() return {
        pinned = false
    } end);
end

function DragonBadge:GetBelialState(player);
    local playerData = DragonBadge:GetPlayerData(player, false);
    return (playerData and playerData.BelialState) or 0;
end

function DragonBadge:onPlayerUpdate(player)
    local playerData = DragonBadge:GetPlayerData(player, false);
    
    if (playerData and playerData.dashing) then
        player:SetMinDamageCooldown(1);
        player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        if (playerData.dashTime <= 0) then
            playerData.dashing = false;
            playerData.useTime = 0;
            playerData.dashTime = 0;
            player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        else
            local index = (DragonBadge.MaxTime - playerData.useTime) % 12;
            playerData.useTime = playerData.useTime - 1;
            playerData.dashTime = playerData.dashTime - 1;
            local trailInfo = THI.Effects.PlayerTrail;
            local subType = trailInfo.SubTypes.RAINBOW;
            if (Players.HasJudasBook(player)) then
                subType = trailInfo.SubTypes.HORSESHOE;
                player:SetColor(DragonBadge.DarkColor, 1, 1, false, false);
            else
                player:SetColor(DragonBadge.Colors[index], 1, 1, false, false);
            end
            local trail = Isaac.Spawn(trailInfo.Type, trailInfo.Variant, subType, player.Position, Vector(0, 0), player);
            trail.SpriteScale = player.SpriteScale;
        end
    end

    if (playerData and playerData.BelialState > 0) then
        playerData.BelialTime = playerData.BelialTime + 1;
        player.Velocity = Vector.Zero;
        local state = playerData.BelialState;
        if (state == 1) then -- Fade to black.
            if (playerData.BelialTime >= 10) then
                playerData.BelialState = 2;
                playerData.BelialTime = 0
            end
        elseif (state == 2) then -- Hitting.
            if (playerData.BelialTarget) then
                local target = playerData.BelialTarget;
                local damage = player.Damage * 0.03;
                local flags = DamageFlag.DAMAGE_CRUSH;
                for i = 1, 50 do
                    target:TakeDamage(damage, flags, EntityRef(player), 0);
                end
                SFXManager():Play(SoundEffect.SOUND_PUNCH);

                local globalData = DragonBadge:GetBadgeGlobalData(true);
                local rng = RNG();
                rng:SetSeed(math.max(Random(), 1), 1);
                local punch = {
                    Position = Screen.GetEntityRenderPosition(target, target.PositionOffset),
                    Scale = rng:RandomFloat() + 1.5,
                    Rotation = rng:RandomFloat() * 360,
                }
                table.insert(globalData.Punches, punch);
            end
            if (playerData.BelialTime >= 20) then
                playerData.BelialState = 3;
                playerData.BelialTime = 0
                SFXManager():Play(THI.Sounds.SOUND_RAGING_DEMON);
                local RagingDemon = THI.Effects.RagingDemonBackground;
                Isaac.Spawn(RagingDemon.Type, RagingDemon.Variant, 0, Vector.Zero, Vector.Zero, player);
                DragonBadge:UnfreezeGame();
                player:AddNullCostume(DragonBadge.RagingDemonCostume);
            end

        elseif (state == 3) then -- Fade out black.
            player:SetMinDamageCooldown(3);
            player.ControlsCooldown = math.max(player.ControlsCooldown, 1);
            if (playerData.BelialTime >= 20) then
                playerData.BelialTarget = nil;
                playerData.BelialState = 0;
                playerData.BelialTime = 0;
                player:SetMinDamageCooldown(20);
                player:TryRemoveNullCostume(DragonBadge.RagingDemonCostume);
            end
        end
    end

    if (DragonBadge:IsGamePausing()) then
        player:SetMinDamageCooldown(3);
        player.ControlsCooldown = math.max(player.ControlsCooldown, 1);
        player.Velocity = Vector.Zero;
    end
    
end


function DragonBadge:PunchEnemy(player, enemy)
    local enemyData = DragonBadge:GetNPCData(enemy);
    
    local direciton = (enemy.Position - player.Position):Normalized();
    enemy:AddVelocity(direciton * 20);
    enemy:AddConfusion(EntityRef(player), 90, false);
    enemyData.pinned = true;
    enemyData.pinnedTime = 10;
end

function DragonBadge:ShockAwayEnemies(player)
    for i=0,11 do
        local rad = i / 6 * math.pi;
        local velocity = Vector(math.cos(rad), math.sin(rad)) * 10;
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIST, 0, player.Position, velocity, player):ToTear();
        tear.CollisionDamage = 10;
        tear.TearFlags = TearFlags.TEAR_PUNCH;
        tear:SetColor(DragonBadge.Colors[i], 0, 1, false, false);
    end
end

do -- Pause.

    function DragonBadge:FreezeGame()
        local data = self:GetBadgeGlobalData(true);
        data.Pausing = true;

        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (ent.Type ~= EntityType.ENTITY_PLAYER) then
                ent:AddEntityFlags(EntityFlag.FLAG_FREEZE);
                ent:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE);
                ent:GetData().REVERIE_BDB_BELIAL_FREEZE = true;
            end
        end
    end
    function DragonBadge:UnfreezeGame()
        local data = self:GetBadgeGlobalData(true);
        local pausing = false;
        for p, player in Players.PlayerPairs(true, true) do
            local state = self:GetBelialState(player);
            if (state > 0 and state < 3) then
                pausing = true;
            end
            if (state <= 0) then
                player:SetMinDamageCooldown(60);
            end
        end
        data.Pausing = pausing;
        if (not data.Pausing) then
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if (ent:GetData().REVERIE_BDB_BELIAL_FREEZE) then
                    ent:ClearEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE);
                    ent:ClearEntityFlags(EntityFlag.FLAG_FREEZE);
                end
            end
        end
    end
    function DragonBadge:IsGamePausing()
        local data = self:GetBadgeGlobalData(false);
        return data and data.Pausing;
    end
    function DragonBadge:FreezeUpdate()
        if (DragonBadge:IsGamePausing()) then
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if (ent.Type ~= EntityType.ENTITY_PLAYER) then
                    ent:AddEntityFlags(EntityFlag.FLAG_FREEZE);
                    ent:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE);
                    ent:GetData().REVERIE_BDB_BELIAL_FREEZE = true;
                end
            end
        end

        local striking = false;
        for p, player in Players.PlayerPairs(true, true) do
            local playerData = DragonBadge:GetPlayerData(player, false);
            if (playerData and playerData.BelialState > 0 and playerData.BelialState < 3) then
                striking = true;
                break;
            end
        end
        local data = DragonBadge:GetBadgeGlobalData(false);
        if (striking) then
            data = DragonBadge:GetBadgeGlobalData(true);
            data.BlackScreen = math.min(1, data.BlackScreen + 0.3);
        else
            if (data) then
                data.BlackScreen = data.BlackScreen or 0;
                data.BlackScreen = math.max(0, data.BlackScreen - 0.3);
            end
        end
        
        if (data) then
            for i, punch in ipairs(data.Punches) do
                data.Punches[i] = nil;
            end
        end
    end
    DragonBadge:AddCallback(ModCallbacks.MC_POST_UPDATE, DragonBadge.FreezeUpdate)

    function DragonBadge:PostRender()
        local data = DragonBadge:GetBadgeGlobalData(false); 
        local alpha = 0;
        if (data) then
            alpha = data.BlackScreen;
            if (alpha > 0) then
                local spr = DragonBadge.BlackscreenSprite;
                spr.Color = Color(0,0,0,alpha);
                spr:Render(Vector.Zero, Vector.Zero, Vector.Zero);
    
                local punchSpr = DragonBadge.PunchSprite;
                for _, punch in ipairs(data.Punches) do
                    punchSpr.Rotation = punch.Rotation;
                    punchSpr.Scale = Vector(punch.Scale, punch.Scale);
                    punchSpr:Render(punch.Position, Vector.Zero, Vector.Zero);
                end
            end
        end
    end
    DragonBadge:AddCallback(ModCallbacks.MC_POST_RENDER, DragonBadge.PostRender)
    -- function DragonBadge:GetShaderParams(name)
    --     local data = DragonBadge:GetBadgeGlobalData(false); 
    --     if (name == "Reverie Belial RDB") then
    --         local alpha = 0;
    --         if (data and data.BlackScreen) then
    --             alpha = data.BlackScreen;
    --         end
    --         return { Alpha = alpha};
    --     end
    -- end
    -- DragonBadge:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, DragonBadge.GetShaderParams)
end

-- TODO Post Collision
function DragonBadge:postPlayerCollision(player, collider)
    local playerData = DragonBadge:GetPlayerData(player, false);
    if (playerData and playerData.dashing) then
        if (Entities.IsValidEnemy(collider)) then
        
            local judasBook = Players.HasJudasBook(player);

            if (judasBook) then
                playerData.dashTime = 0;
                playerData.BelialTarget = collider;
                playerData.BelialState = 1;
                playerData.BelialTime = 0;
                DragonBadge:FreezeGame();
                SFXManager():Play(SoundEffect.SOUND_SKIN_PULL);
            else -- Normal.
                local colliderData = DragonBadge:GetNPCData(collider);
                
                if (not colliderData.pinned) then
                    SFXManager():Play(SoundEffect.SOUND_PUNCH)
                    
                    local direciton = (collider.Position - player.Position):Normalized();
                    local playerDir = player.Velocity:Normalized();
                    local dot = direciton:Dot(playerDir);
                    player:AddVelocity(dot * -20 * direciton);
                    DragonBadge:PunchEnemy(player, collider)
                    local damage = 20 + 10 * player.Damage;
                    collider:TakeDamage(damage, 0, EntityRef(player), 0);
                    DragonBadge:ShockAwayEnemies(player);
                    playerData.dashTime = playerData.dashTime + DragonBadge.MaxTime;
                    
                    Game():ShakeScreen(10)
                end
            end
        end
    end
end
DragonBadge:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_PLAYER_COLLISION, DragonBadge.postPlayerCollision)


function DragonBadge:onNPCUpdate(npc)
    local npcData = DragonBadge:GetNPCData(npc);
    if (npcData.pinned) then
        npcData.pinnedTime = npcData.pinnedTime - 1;
        if (npcData.pinnedTime <= 0) then
            npcData.pinnedTime = 0;
            npcData.pinned = false;
        end
    end
end


function DragonBadge:useBadge(t, RNG, player, flags, slot)
    local movement = player:GetMovementVector();
    if (movement:Distance(Vector(0, 0)) <= 0) then
        return { Discharge = false };
    else
        THI.SFXManager:Play(SoundEffect.SOUND_SHELLGAME);
        if (flags & UseFlag.USE_CARBATTERY <= 0) then
            player:AddVelocity(player.Velocity:Normalized() * 20);
        end
        player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
        player.ControlsCooldown = math.max(10, player.ControlsCooldown);
        local playerData = DragonBadge:GetPlayerData(player, true);
        playerData.dashing = true;
        playerData.useTime = DragonBadge.MaxUseTime;
        playerData.dashTime = playerData.dashTime + DragonBadge.MaxTime;
    end
end

DragonBadge:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DragonBadge.onPlayerUpdate);
DragonBadge:AddCallback(ModCallbacks.MC_NPC_UPDATE, DragonBadge.onNPCUpdate);


DragonBadge:AddCallback(ModCallbacks.MC_USE_ITEM, DragonBadge.useBadge, DragonBadge.Item);


return DragonBadge;