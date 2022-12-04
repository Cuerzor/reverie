local Mirror = ModCard("SpiritMirror", "SPIRIT_MIRROR");

Mirror.MirrorColor = Color(1,1,1,1,0,1,1);


local function GetTempGlobalData(create)
    return Mirror:GetTempGlobalData(create, function()
        return {
            CopyList = {},
            MirrorList = {}
        }
    end)
end
local function GetTempNPCData(npc, create)
    return Mirror:GetTempData(npc, create, function()
        return {
            IsMirrored = true,
            Trail = nil;
        }
    end)
end


function Mirror:GetCopyEntityNum()
    local globalData = GetTempGlobalData(false);
    return (globalData and #globalData.CopyList) or 0;
end
function Mirror:EnqueueCopyEntity(entity)
    local globalData = GetTempGlobalData(true);
    
    local champion = -1;
    local npc = entity:ToNPC();
    if (npc) then
        champion = npc:GetChampionColorIdx();
    end
    local info = {
        Type = entity.Type,
        Variant = entity.Variant,
        SubType = entity.SubType,
        Champion = champion,
        Position = entity.Position;
    }
    table.insert(globalData.CopyList, info)
end
function Mirror:DequeueCopyEntity()
    local globalData = GetTempGlobalData(false);
    if (globalData) then
        local list = globalData.CopyList;
        if (#list > 0) then
            local info = list[1];
            table.remove(list, 1);
            return info;
        end
        return nil;
    end
end
function Mirror:ClearCopyEntity()
    local globalData = GetTempGlobalData(false);
    if (globalData) then
        for k,v in pairs(globalData.CopyList) do
            globalData.CopyList[k] = nil;
        end
    end
end
function Mirror:Copy(entity)
    local center = Game():GetRoom():GetCenterPos();
    local targetPosition = Game():GetRoom():FindFreePickupSpawnPosition(center - (entity.Position - center),0, true);

    local copy = Isaac.Spawn(entity.Type, entity.Variant, entity.SubType, targetPosition, Vector.Zero, nil);
    local npc = copy:ToNPC();
    local entChampion = entity:ToNPC() and entity:ToNPC():GetChampionColorIdx() or -1;
    if (npc and entChampion >= 0) then
        npc:MakeChampion (npc.InitSeed, entChampion, false);
    end
    copy:SetColor(Mirror.MirrorColor, 30, 0, true);
    copy:AddCharmed(EntityRef(nil), -1);

    --Trail
    local trail = Isaac.Spawn(1000,166,0,entity.Position, Vector.Zero, copy):ToEffect();
    trail.Parent = copy;
    --trail.Timeout = 30;


    local data = GetTempNPCData(npc, true);
    data.IsMirrored = true;
    data.Trail = trail;

    
    local globalData = GetTempGlobalData(true);
    globalData.MirrorList[GetPtrHash(copy)] = {Entity = copy, Timeout = 20, TargetPosition = targetPosition};
end

local function PostUseCard(mod, card, player, flags)

    Game():ShakeScreen(10);
    THI.SFXManager:Play(SoundEffect.SOUND_DEATH_CARD)
    THI.SFXManager:Play(SoundEffect.SOUND_MIRROR_EXIT);
    local EntityTags = THI.Shared.EntityTags;
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if (ent:IsActiveEnemy() and ent:CanShutDoors() and not EntityTags:EntityFits(ent, "CopyBlacklist") and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            local poofColor = Color(0,0.5,0.5, 1, 0, 0, 0);
            for p = 0, 1 do
                local subType = p + 1;
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, subType, ent.Position, Vector.Zero, ent);
                poof:SetColor(poofColor, 0, 0);
            end

            --Mirror:EnqueueCopyEntity(ent);
            Mirror:Copy(ent);
        end
    end
end
Mirror:AddCallback(ModCallbacks.MC_USE_CARD, PostUseCard, Mirror.ID)

local function PostUpdate(mod)
    if (Game():GetFrameCount() % 2 == 0) then
        if (Mirror:GetCopyEntityNum() > 0) then
            local info = Mirror:DequeueCopyEntity();


            -- local center = Game():GetRoom():GetCenterPos();
            -- local targetPosition = Game():GetRoom():FindFreePickupSpawnPosition(center - (info.Position - center),0, true);

            -- local entity = Isaac.Spawn(info.Type, info.Variant, info.SubType, targetPosition, Vector.Zero, nil);
            -- local npc = entity:ToNPC();
            -- if (npc and info.Champion >= 0) then
            --     npc:MakeChampion (npc.InitSeed, info.Champion, false);
            -- end
            -- entity:SetColor(Mirror.MirrorColor, 30, 0, true);
            -- entity:AddCharmed(EntityRef(nil), -1);

            -- --Trail
            -- local trail = Isaac.Spawn(1000,166,0,info.Position, Vector.Zero, entity):ToEffect();
            -- trail.Parent = entity;
            -- --trail.Timeout = 30;


            -- local data = GetTempNPCData(npc, true);
            -- data.IsMirrored = true;
            -- data.Trail = trail;

            
            -- local globalData = GetTempGlobalData(true);
            -- globalData.MirrorList[GetPtrHash(entity)] = {Entity = entity, Timeout = 20, TargetPosition = targetPosition};
            -- THI.SFXManager:Play(SoundEffect.SOUND_MIRROR_EXIT);
        end

    end
    -- Move copies.
    local globalData = GetTempGlobalData(false);
    if (globalData) then
        for hash, info in pairs(globalData.MirrorList) do
            local target =  info.Entity.Position * 0.9 + info.TargetPosition * 0.1;
            info.Entity.Position =target;
            info.Timeout = info.Timeout - 1;


            local data = GetTempNPCData(info.Entity, false);
            if (data) then
                if (data.Trail and data.Trail:Exists()) then
                    --data.Trail.Position = npc.Position;
                    data.Trail.SpriteScale = Vector(info.Entity.Size / 4, info.Entity.Size / 4);
                    data.Trail.Velocity = (target - data.Trail.Position) * 0.5;
                            
                    --data.Trail.MaxRadius = math.max(0.1, 1-(info.Timeout) / 5);
                    data.Trail.MinRadius = math.max(0.06, 1-(info.Timeout) / 5);
                    if (info.Timeout < 0) then
                        data.Trail:Remove();
                        data.Trail = nil;
                    end
                end
            end

            if (info.Timeout < 0) then
                globalData.MirrorList[hash] = nil;
            end

            
        end
    end
end
Mirror:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)

local function PreNPCCollision(mod, npc, other, low)
    local globalData = GetTempGlobalData(false);
    if (globalData) then
        if (globalData.MirrorList[GetPtrHash(npc)]) then
            return true;
        end
    end
end
Mirror:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreNPCCollision)

local function PostNewRoom(mod)
    Mirror:ClearCopyEntity()
end
Mirror:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)


THI:AddAnnouncer(Mirror.ID, THI.Sounds.SOUND_SPIRIT_MIRROR, 15)


return Mirror;