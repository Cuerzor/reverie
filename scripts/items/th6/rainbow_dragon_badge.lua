local Detection = CuerLib.Detection;

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


function DragonBadge:GetPlayerData(player) 
    return DragonBadge:GetData(player, true, function() return {
        dashing = false,
        useTime = 0,
        dashTime = 0
    } end);
end

function DragonBadge:GetNPCData(npc) 
    return DragonBadge:GetData(npc, true, function() return {
        pinned = false
    } end);
end


function DragonBadge:onPlayerUpdate(player)
    local playerData = DragonBadge:GetPlayerData(player);
    
    if (playerData.dashing) then
        player:SetMinDamageCooldown(1);
        player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK);
        if (playerData.dashTime <= 0) then
            playerData.dashing = false;
            playerData.useTime = 0;
            playerData.dashTime = 0;
        else
            local index = (DragonBadge.MaxTime - playerData.useTime) % 12;
            player:SetColor(DragonBadge.Colors[index], 1, 1, false, false);
            playerData.useTime = playerData.useTime - 1;
            playerData.dashTime = playerData.dashTime - 1;
            local trailInfo = THI.Effects.PlayerTrail;
            local trail = Isaac.Spawn(trailInfo.Type, trailInfo.Variant, trailInfo.SubTypes.RAINBOW, player.Position, Vector(0, 0), player);
            trail.SpriteScale = player.SpriteScale;
        end
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

-- TODO Post Collision
function DragonBadge:prePlayerCollision(player, collider)
    local playerData = DragonBadge:GetPlayerData(player);
    if (playerData.dashing) then
        if (Detection.IsValidEnemy(collider)) then
            local colliderData = DragonBadge:GetNPCData(collider);
            
            if (not colliderData.pinned) then
                THI.SFXManager:Play(SoundEffect.SOUND_PUNCH)
                
                local direciton = (collider.Position - player.Position):Normalized();
                local playerDir = player.Velocity:Normalized();
                local dot = direciton:Dot(playerDir);
                player:AddVelocity(dot * -20 * direciton);
                DragonBadge:PunchEnemy(player, collider)
                local damage = 40+ 10 * player.Damage;
                collider:TakeDamage(damage, 0, EntityRef(player), 0);
                DragonBadge:ShockAwayEnemies(player);
                playerData.dashTime = playerData.dashTime + DragonBadge.MaxTime;
                
                THI.Game:ShakeScreen(10)
            end
        end
    end
end
DragonBadge:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_PLAYER_COLLISION, DragonBadge.prePlayerCollision)


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
        player.ControlsCooldown = 10
        local playerData = DragonBadge:GetPlayerData(player);
        playerData.dashing = true;
        playerData.useTime = DragonBadge.MaxUseTime;
        playerData.dashTime = playerData.dashTime + DragonBadge.MaxTime;
    end
end

DragonBadge:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DragonBadge.onPlayerUpdate);
DragonBadge:AddCallback(ModCallbacks.MC_NPC_UPDATE, DragonBadge.onNPCUpdate);


DragonBadge:AddCallback(ModCallbacks.MC_USE_ITEM, DragonBadge.useBadge, DragonBadge.Item);


return DragonBadge;