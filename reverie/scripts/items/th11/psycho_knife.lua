local Maths = CuerLib.Math;
local Screen = CuerLib.Screen;
local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local CompareEntity = Entities.CompareEntity;
local Mod = THI;
local PsychoKnife = ModItem("Psycho Knife", "PsychoKnife");

PsychoKnife.SlashVariant = Isaac.GetEntityVariantByName("Psycho Slash");

-- local soundPlaying = false;
-- local soundVolume = 2;
-- local soundTime = 0;
local smokeRNG = RNG();
local executeRadius = 60;
local executeHPThresold = 0.2;
local bossExecuteHPThresold = 0.1;
local bossExecutePercent = 0.1;
local bossExecuteDamageAddition = 5;
local knockbackRadius = 80;

local maxCharges = Isaac.GetItemConfig():GetCollectible(PsychoKnife.Item).MaxCharges;

local markSprite = Sprite();
markSprite:Load("gfx/reverie/execution_mark.anm2", true);
markSprite:Play("Idle");

function PsychoKnife.PlaySound()
    SFXManager():Play(Mod.Sounds.SOUND_EXECUTE, 0.8, 0, false, 1)
end

function PsychoKnife.GetPlayerTempData(player, init)
    local data = player:GetData();
    if (init) then
        data._PSYCHOKNIFE = data._PSYCHOKNIFE or {
            Executing = false,
            Target = nil,
            Time = 0,
            StartPosition = player.Position,
            TargetCollision = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS,
            PlayerCollision = EntityCollisionClass.ENTCOLL_ENEMIES
        };
    end
    return data._PSYCHOKNIFE;
end

function PsychoKnife.GetNPCTempData(npc, init)
    local data = npc:GetData();
    if (init) then
        data._PSYCHOKNIFE = data._PSYCHOKNIFE or {
            ExecuteBy = nil,
            MarkAlpha = 0
        }
    end
    return data._PSYCHOKNIFE;
end


function PsychoKnife.CanEnemyExecute(player, npc)
    local position = player.Position;
    if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:IsDead()) then
        return false;
    end

    local thresold = executeHPThresold;
    if (npc:IsBoss()) then
        thresold = bossExecuteHPThresold;
    end
    if (npc.HitPoints <= npc.MaxHitPoints * thresold or npc.HitPoints <= player.Damage * 2) then
        return true;
    end
    --if (not npc:IsBoss()) then

        if (npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_MIDAS_FREEZE | EntityFlag.FLAG_FEAR)) then
            return true;
        end

        if (npc.Position:Distance(position) <= npc.Size + player.Size + executeRadius) then
            return true;
        end

        -- -- Back Stab.
        -- local target= nil;
        -- if (npc:GetPlayerTarget ( )) then
        --     target = npc:GetPlayerTarget().Position;
        -- elseif (npc.Target) then
        --     target = npc.Target.Position;
        -- elseif (npc.TargetPosition:Length() > 10) then
        --     target = npc.TargetPosition;
        -- end
        -- if (target) then
        --     local npcBack = npc.Position - target;
        --     local posToNPC = position - npc.Position;
        --     local angle = Maths.GetIncludedAngle(npcBack, posToNPC);
        --     if (angle <= 45) then
        --         return true;
        --     end
        -- end
    --end
    return false;
end


function PsychoKnife.FindTargetEnemy(player)
    local position = player.Position
    local nearest = nil;
    for i, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent:IsVulnerableEnemy()) then
            local npc = ent:ToNPC();
            local distance = npc.Position:Distance(position);
            if (distance <= npc.Size + player.Size + executeRadius * 2 and PsychoKnife.CanEnemyExecute(player, npc)) then
                if (not nearest or distance < position:Distance(nearest.Position)) then
                    nearest = npc;
                end
            end
        end
    end
    return nearest;
end

function PsychoKnife.Execute(player, target)
    local data = PsychoKnife.GetPlayerTempData(player, true);
    PsychoKnife.PlaySound();
    data.Executing = true;
    data.Time = 15;
    data.StartPosition = player.Position;
    if (target) then
        data.TargetCollision = target.EntityCollisionClass;
        target.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
    end
    data.PlayerCollision = player.EntityCollisionClass;
    player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
    Game():ShakeScreen(5);
end
function PsychoKnife:PostPlayerEffect(player)
    
    local game = Game();

    if (player:HasCollectible(PsychoKnife.Item)) then

        local activeCharged = false;
        local extraCharge = player:GetEffectiveSoulCharge() + player:GetEffectiveBloodCharge();

        if (player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == PsychoKnife.Item) then
            if (player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= maxCharges or extraCharge > 0) then
                activeCharged = true;
            end
        end

        if (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == PsychoKnife.Item and player:GetCard(0) <= 0 and player:GetPill(0) <= 0) then
            if (player:GetActiveCharge(ActiveSlot.SLOT_POCKET) >= maxCharges or extraCharge > 0) then
                activeCharged = true;
            end
        end

        if (game:GetFrameCount() % 2 == 0) then
            local data = PsychoKnife.GetPlayerTempData(player, true);
            if (data.Target) then
                local oldTargetData = PsychoKnife.GetNPCTempData(data.Target, true);
                if (oldTargetData.ExecuteBy and CompareEntity(oldTargetData.ExecuteBy, player)) then
                    oldTargetData.ExecuteBy = nil;
                end
            end
            if (activeCharged) then
                if (not data.Executing) then
                    data.Target = PsychoKnife.FindTargetEnemy(player);
                    if (data.Target) then
                        local newTargetData = PsychoKnife.GetNPCTempData(data.Target, true);
                        if (not newTargetData.ExecuteBy) then
                            newTargetData.ExecuteBy = player;
                        end
                    end
                end
            end
        end
    end

    local data = PsychoKnife.GetPlayerTempData(player, false);
    if (data) then
        if (data.Executing) then
            local center = player.Position;
            local judasBook = Players.HasJudasBook(player);
            
            local target = data.Target;
            if (target) then
                if (not target:IsDead()) then
                    target:AddEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE | EntityFlag.FLAG_FREEZE);
                else
                    target:ClearEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE | EntityFlag.FLAG_FREEZE);
                end
                center = target.Position;
                player.Position = center;
            end
            local pos = center + RandomVector() * smokeRNG:RandomFloat() * 30;
            local smoke = Isaac.Spawn(1000, 59, 0, pos, RandomVector() * smokeRNG:RandomFloat() *1, nil):ToEffect();
            local color = Color(0.3,0.3,0.3,1,0,0,0);
            if (judasBook) then
                color = Color(0.5, 0, 0, 1, 0, 0, 0);
            end
            smoke.Color = color;
            smoke.SpriteScale = Vector(2, 2);
            smoke.LifeSpan = 20;
            smoke.Timeout = 20;
            

            if (data.Time > 0) then
                player.ControlsCooldown = math.max(player.ControlsCooldown, data.Time + 1);
                data.Time = data.Time - 1;
                player.Visible = false;
                player:SetMinDamageCooldown(60);
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
                if (data.Time <= 0) then
                    data.Executing = false;
                    SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL, 1, 0, false, 0.6)
                    SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1)
                    game:ShakeScreen(15);
                    player.Visible = true;
                    local slash = Isaac.Spawn(EntityType.ENTITY_EFFECT, PsychoKnife.SlashVariant, 0, center, Vector.Zero, player):ToEffect();
                    slash.SpriteScale = Vector(2, 2);
                    slash.DepthOffset = 160;

                    -- Push back enemies around.
                    
                    for i, ent in pairs(Isaac.GetRoomEntities()) do
                        if (ent:IsEnemy()) then
                            local npc = ent:ToNPC();
                            local playerToNPC = npc.Position - player.Position;
                            local distance = playerToNPC:Length();
                            local force = (knockbackRadius - distance) / knockbackRadius * 20 + 30;
                            if (force > 0) then
                                npc:AddVelocity(playerToNPC:Normalized() * force);
                                npc:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_APPLY_IMPACT_DAMAGE);
                            end
                        end
                    end


                    if (target) then
                        if (not target:IsDead()) then
                            target:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE);
                            target:ClearEntityFlags(EntityFlag.FLAG_NO_SPRITE_UPDATE | EntityFlag.FLAG_FREEZE);
                            local flags = DamageFlag.DAMAGE_IGNORE_ARMOR;
                            if (target:IsBoss()) then
                                local damage = target.MaxHitPoints * bossExecutePercent + bossExecuteDamageAddition * player.Damage;
                                if (player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then
                                    damage = damage * 2;
                                end
                                target:TakeDamage(damage, flags, EntityRef(player), 0)
                            else
                                target:TakeDamage(target.MaxHitPoints, flags, EntityRef(player), 0)
                                target:Kill();
                            end
                            target.EntityCollisionClass = data.TargetCollision;
                            
                            if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
                                player:AddWisp(PsychoKnife.Item, target.Position)
                            end
                            if (judasBook) then
                                if (target:IsDead() or target:HasMortalDamage()) then
                                    Mod:AddTemporaryDamage(player, 1, 300);
                                end
                            end
                        end
                        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;--data.PlayerCollision;
                        local room = game:GetRoom();
                        local blocked, pos2 = room:CheckLine (data.StartPosition, target.Position, 0, 0);
                        player.Position = pos2;
                    end
                end
            end
        end
    end
end
PsychoKnife:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PsychoKnife.PostPlayerEffect)

function PsychoKnife:UseKnife(item, rng, player, flags, slot, vardata)
    local data = PsychoKnife.GetPlayerTempData(player, false);
    if (data and not data.Executing) then
        if (data.Target and not data.Target:IsDead() and data.Target:Exists()) then
            PsychoKnife.Execute(player);
            return {Discharge = true;}
        end
    end
    return {Discharge = false;}
end
PsychoKnife:AddCallback(ModCallbacks.MC_USE_ITEM, PsychoKnife.UseKnife, PsychoKnife.Item)

function PsychoKnife:PostNPCUpdate(npc)
    local data = PsychoKnife.GetNPCTempData(npc, false);
    if (data) then
        if (data.ExecuteBy and data.ExecuteBy:Exists() and not data.ExecuteBy:IsDead()) then
            data.MarkAlpha = data.MarkAlpha + 0.3;
        else
            data.MarkAlpha = data.MarkAlpha - 0.3;
        end
        data.MarkAlpha = math.min(1, math.max(0, data.MarkAlpha));
    end
end
PsychoKnife:AddCallback(ModCallbacks.MC_NPC_UPDATE, PsychoKnife.PostNPCUpdate)

function PsychoKnife:PostNPCRender(npc, offset)
    local data = PsychoKnife.GetNPCTempData(npc, false);
    if (data and not npc:IsDead()) then
        if (data.MarkAlpha > 0) then
            local game = Game();
            markSprite.Color = Color(1,1,1,data.MarkAlpha);
            local pos = Screen.GetEntityOffsetedRenderPosition(npc, offset, Vector(0, -16));
            markSprite:Render(pos);
        end
    end
end
PsychoKnife:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, PsychoKnife.PostNPCRender)

-- function PsychoKnife:PostRender()
--     if (soundPlaying) then
--         soundTime = soundTime + 1;
--         if (soundTime % 3 == 0) then
--             SFXManager():Play(SoundEffect.SOUND_HOLY_MANTLE, soundVolume, 0, false, 0.5)
--             --SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL, soundVolume, 0, false, 2)
--             soundVolume = (50 - soundTime) / 15;
--             if (soundVolume <=0) then
--                 soundPlaying = false;
--                 soundTime = 0;
--             end
--         end
--     end
-- end
-- PsychoKnife:AddCallback(ModCallbacks.MC_POST_RENDER, PsychoKnife.PostRender)


function PsychoKnife:PostSlashUpdate(effect)
    local spr = effect:GetSprite();
    if (spr:IsFinished("Slash")) then
        spr:Play("Disappear");
    end

    
    if (spr:IsFinished("Disappear")) then
        effect:Remove();
    end

end
PsychoKnife:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PsychoKnife.PostSlashUpdate, PsychoKnife.SlashVariant)




return PsychoKnife;