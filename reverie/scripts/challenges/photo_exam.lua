local Exam = ModChallenge("Photo Exam", "PHOTO_EXAM");

function Exam:PostGameStarted(isContinued)
    if (Isaac.GetChallenge() == Exam.Id) then
        if (not isContinued) then
            
            local room = Game():GetRoom();
            local center = room:GetCenterPos() + Vector(0, 80);
            
            for _, ent in pairs(Isaac.FindByType(5)) do
                ent:Remove();
            end

            Isaac.Spawn(5,100,628, center + Vector(-80, -80), Vector.Zero, nil);
            Isaac.Spawn(5,100,628, center + Vector(80, -80), Vector.Zero, nil);
            Isaac.Spawn(5,100,628, center + Vector(-80, 80), Vector.Zero, nil);
            Isaac.Spawn(5,100,628, center + Vector(80, 80), Vector.Zero, nil);
        end
    end
end
Exam:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Exam.PostGameStarted);


local function PostNewLevel()
    if (Isaac.GetChallenge() == Exam.Id) then
        if (Game():GetLevel():GetStage() ~= 9) then
            Isaac.ExecuteCommand("stage 9");
        end
    end
end
Exam:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PostNewLevel);

local function PostPlayerInit(mod, player)
    if (Isaac.GetChallenge() == Exam.Id) then
        player:AddMaxHearts(12);
        player:AddHearts(12);
        player:SetPocketActiveItem(THI.Collectibles.TenguCamera.Item);
    end
end
Exam:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, PostPlayerInit);

-- local function PostNewRoom(mod)
--     if (Isaac.GetChallenge() == Exam.Id) then
--         local room = Game():GetRoom();
--         local center = room:GetCenterPos();
--         if (room:GetType() == RoomType.ROOM_BOSS and room:IsFirstVisit()) then
--             Isaac.Spawn(5,100,THI.Collectibles.TenguCamera.Item, center + Vector(0, 160), Vector.Zero, nil);
--         end
--     end
-- end
-- Exam:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom);

local function PostPlayerEffect(mod, player)
    if (Isaac.GetChallenge() == Exam.Id) then
        local TenguCamera = THI.Collectibles.TenguCamera;
        if (TenguCamera:GetPlayerScore(player) >= 100) then
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (ent:IsActiveEnemy() or ent.Type == EntityType.ENTITY_PROJECTILE) then
                    ent:Kill();
                end
            end
        end
    end
end
Exam:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

local function PostNPCUpdate(mod, npc)
    if (Isaac.GetChallenge() == Exam.Id) then
        if (npc.Type == EntityType.ENTITY_ISAAC and npc.Variant == 2) then
            npc.MaxHitPoints = 0.01;
            npc.HitPoints = 0.01;
        elseif (npc.Type == EntityType.ENTITY_HUSH) then
            npc.HitPoints = npc.MaxHitPoints / 3;
        end
    end
end
Exam:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate);

local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (Isaac.GetChallenge() == Exam.Id) then
        if (tookDamage.Type == EntityType.ENTITY_HUSH) then
            return false;
        end
    end
end
Exam:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage, EntityType.ENTITY_HUSH);

return Exam;