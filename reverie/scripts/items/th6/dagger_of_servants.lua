local Stats = CuerLib.Stats;
local Players = CuerLib.Players;
local DaggerOfServants = ModItem("Dagger of Servants", "DAGGER_OF_SERVANTS");

function DaggerOfServants:GetPlayerData(player, create)
    return self:GetData(player, create, function()
        return {
            Rooms = 0,
            DamageUp = 0
        }
    end)
end
function DaggerOfServants:GetPlayerTempData(player, create)
    return self:GetTempData(player, create, function()
        return {
            WillStab = nil,
            Warning = nil
        }
    end)
end

function DaggerOfServants:IsLethal(player)
    local brokenHearts = player:GetBrokenHearts();
    if (brokenHearts > 0) then
        -- 碎心。
        return false;
    else
        local hearts = player:GetHearts();
        local eternalHearts = player:GetEternalHearts();
        local boneHearts = player:GetBoneHearts();
        local soulHearts = player:GetSoulHearts();
        if (eternalHearts <= 0) then
            if (hearts <= 2 and boneHearts <= 0 and soulHearts <= 0) then
                --只有一颗或半颗红心。
                return true;
            end
            if (hearts <= 0 and boneHearts <= 1 and soulHearts <= 0) then
                --只有一颗骨心。
                return true;
            end
            if (hearts <= 0 and boneHearts <= 0 and soulHearts <= 2) then
                --只有一颗或半颗魂心。
                return true;
            end
        end
    end
    return false;
end

function DaggerOfServants:RemoveRightmostHeart(player)
    local brokenHearts = player:GetBrokenHearts();
    if (brokenHearts > 0) then
        -- 碎心。
        player:AddBrokenHearts(-1);
    else
        local hearts = player:GetHearts();
        local rottenHearts = player:GetRottenHearts();
        local eternalHearts = player:GetEternalHearts();
        local maxHearts = player:GetMaxHearts();
        local boneHearts = player:GetBoneHearts();
        local soulHearts = player:GetSoulHearts();

        local rightmostPosition = math.ceil(soulHearts / 2) + boneHearts - 1;
        local hasHalfSoulHeart = soulHearts % 2 == 1;
        if (not player:IsBoneHeart(rightmostPosition)) then
            if (soulHearts > 0) then
                -- 魂心。
                if (boneHearts <= 0 and maxHearts <= 0 and eternalHearts > 0 and soulHearts <= 2) then
                    -- 最外侧是魂心+永恒之心。
                    player:AddEternalHearts(-1);
                elseif (hasHalfSoulHeart) then
                    -- 最外侧是半魂心。
                    player:AddSoulHearts(-1);
                else
                    player:AddSoulHearts(-2);
                end
            else
                --红心
                if (eternalHearts > 0) then
                    if (rottenHearts > 0) then
                        -- 最外侧是腐心+永恒之心。
                        player:AddEternalHearts(-1);
                    else
                        -- 最外侧是永恒之心。
                        player:AddEternalHearts(-1);
                    end
                elseif (rottenHearts > 0) then
                    --腐心
                    player:AddRottenHearts(-2);
                elseif (hearts % 2 == 1) then
                    --半红心。
                    player:AddHearts(-1);
                else
                    player:AddHearts(-2);
                end
            end
        else
            -- 骨心（及其内容物）。
            local emptyBoneHeart = hearts + rottenHearts <= maxHearts + (boneHearts - 1) * 2;
            if (emptyBoneHeart) then
                if (boneHearts <= 1 and maxHearts <= 0 and eternalHearts > 0 and soulHearts <= 0) then
                    -- 空骨心 + 永恒之心。
                    player:AddEternalHearts(-1);
                else
                    -- 空骨心。
                    player:AddBoneHearts(-1);
                end
            else 
                --有内容物的骨心。
                if (eternalHearts > 0) then
                    -- 骨心内永恒之心。
                    player:AddEternalHearts(-1);
                elseif (rottenHearts > 0) then
                    -- 骨心内腐心
                    player:AddRottenHearts(-2);
                elseif (hearts % 2 == 1) then
                    -- 骨心内半红心。
                    player:AddHearts(-1);
                else
                    player:AddHearts(-2);
                end
            end
        end
    end

    local flags = DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_FAKE;

    local game = Game();
    player:ResetDamageCooldown();


    SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS);
    SFXManager():Play(SoundEffect.SOUND_DEVIL_CARD);
    game:SpawnParticles (player.Position, EffectVariant.BLOOD_PARTICLE, 10, 5);
    local vel = Vector(0, -Random() % 1000 / 1000 * 5 - 10);
    local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, player.Position, vel, player):ToEffect();
    smoke.LifeSpan = 16;
    smoke.Timeout = 16;
    smoke.SpriteScale = Vector(0.5, 0.5);
    smoke.DepthOffset = -2000;
    smoke:SetColor(Color(1, 1, 0.5, 0.8, 1, 0.2, 0), -1, 0);


    player:TakeDamage(0, flags, EntityRef(player), 120);
    player:SetMinDamageCooldown(120);
end

function DaggerOfServants:GetRoomCounter(player)
    local data = self:GetPlayerData(player, false);
    return (data and data.Rooms) or 0;
end
function DaggerOfServants:ReadyToStab(player)
    return DaggerOfServants:GetRoomCounter(player) >= 3;
end

function DaggerOfServants:AddDamageUp(player)
    local data = self:GetPlayerData(player, true);
    data.DamageUp = (data.DamageUp or 0) + 0.6;
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:EvaluateItems();
end

function DaggerOfServants:PostNewRoom()
    
    for p, player in Players.PlayerPairs() do
        if (player:HasCollectible(DaggerOfServants.Item)) then
            local playerType = player:GetPlayerType();
            local isLost = playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or playerType == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE);
            if (not isLost) then
                local game = Game();
                local room = game:GetRoom();
                if (room:IsFirstVisit()) then
                    local data = self:GetPlayerTempData(player, true);
                    data.WillStab = true;
                end
            end
        end
    end
end
DaggerOfServants:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DaggerOfServants.PostNewRoom);

function DaggerOfServants:PostPlayerEffect(player)
    if (player:HasCollectible(DaggerOfServants.Item)) then
        local game = Game();
        local room = game:GetRoom();
        if (room:GetFrameCount() >= 1) then
            local tempData = self:GetPlayerTempData(player, false);
            if (tempData and tempData.WillStab) then
                tempData.WillStab = nil;
                local data = self:GetPlayerData(player, true);
                local lethal = self:IsLethal(player);
                local ready = self:ReadyToStab(player);
                if (not lethal or not ready) then
                    data.Rooms = data.Rooms + 1;
                end
                if (ready) then
                    if (not lethal) then
                        data.Rooms = 0;
                        self:RemoveRightmostHeart(player);
                        self:AddDamageUp(player);
                    end
                end
            end
        end
    end
end
DaggerOfServants:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DaggerOfServants.PostPlayerEffect);


    
function DaggerOfServants:PostPlayerUpdate(player)
    if (player:HasCollectible(DaggerOfServants.Item) and self:ReadyToStab(player)) then 
        local data = self:GetPlayerTempData(player, true);
        if (not data.Warning or not data.Warning:Exists()) then
            
            local Warning = THI.Effects.DaggerWarning;
            local warning = Isaac.Spawn(Warning.Type, Warning.Variant, 0, player.Position, Vector.Zero, player);
            warning.Parent = player;
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position + Vector(0, player.SpriteScale.Y * -36), Vector.Zero, warning);
            data.Warning = warning;
            warning.DepthOffset = 10;
            warning:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
        else
            data.Warning.Position = player.Position;
            data.Warning.Velocity = player.Velocity;
            data.Warning.SpriteOffset = Vector(0, player.SpriteScale.Y * -36);
        end
    end
end
DaggerOfServants:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, DaggerOfServants.PostPlayerUpdate);

function DaggerOfServants:EvaluateCache(player, flag)
    if (flag == CacheFlag.CACHE_DAMAGE) then
        local data = self:GetPlayerData(player, false);
        Stats:AddDamageUp(player, (data and data.DamageUp) or 0);
    end
end
DaggerOfServants:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DaggerOfServants.EvaluateCache);



return DaggerOfServants;