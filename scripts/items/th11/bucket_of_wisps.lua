local Detection = CuerLib.Detection;
local Actives = CuerLib.Actives;
local Math = CuerLib.Math;
local Bucket = ModItem("Bucket of Wisps", "BUCKET_OF_WISPS")
Bucket.Soul = ModEntity("Bucket Soul", "BUCKET_OF_WISPS")
Bucket.Soul.SubType = 580

local function GetPlayerData(player, create)
    return Bucket:GetData(player, create, function()
        return {
            Souls = {};
        }
    end)
end

function Bucket:AddSoul(player, hp)
    local data = GetPlayerData(player, true);
    if (#data.Souls < 64) then
        table.insert(data.Souls, hp);
    end
end
function Bucket:GetSoulNum(player)
    local data = GetPlayerData(player, false);
    return (data and #data.Souls) or 0;
end

function Bucket:GetSoul(player, index)
    local data = GetPlayerData(player, false);
    return (data and data.Souls[index]) or nil;
end
function Bucket:RemoveSoul(player, index)
    local data = GetPlayerData(player, true);
    table.remove(data.Souls, index);
end

local function PostNPCUpdate(mod, npc)
    if (npc:IsActiveEnemy(true) and npc.CanShutDoors and npc:IsDead()) then
        for _, player in Detection.PlayerPairs() do
            if (player:HasCollectible(Bucket.Item))  then
                local soul = Isaac.Spawn(Bucket.Soul.Type, Bucket.Soul.Variant, Bucket.Soul.SubType, npc.Position, RandomVector() * 10, npc):ToEffect();
                soul.Target = player;
                soul.MaxHitPoints = npc.MaxHitPoints;
            end
        end
    end
end
Bucket:AddCallback(ModCallbacks.MC_NPC_UPDATE, PostNPCUpdate)

do -- Bucket Soul
    local function PostEffectUpdate(mod, effect)
        if (effect.Variant == Bucket.Soul.Variant and effect.SubType == Bucket.Soul.SubType) then

            if (not effect.Child) then
                local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
                trail.MinRadius = 0.15;
                trail.MaxRadius = 0.15;
                trail.SpriteScale = Vector(2,2);
                trail.Parent = effect;
                trail:SetColor(Color(0.3, 0.6, 1, 0.5, 0, 0, 0), -1, 0);
                effect.Child = trail;
            else 
                effect.Child.Position = effect.Position + Vector(0,-24);
                --effect.Child.Velocity = effect.Velocity;
            end
            

            local spr = effect:GetSprite();
            if (effect.State == 0) then
                if (effect.Target and effect.Target:Exists()) then
                    spr:Play("Move");

                    local curVel = effect.Velocity;
                    local target2This = effect.Target.Position - effect.Position;
                    -- local curAngle = curVel:GetAngleDegrees();
                    -- local targetAngle = target2This:GetAngleDegrees();
                    -- local includedAngle = targetAngle - curAngle;
                    -- if (includedAngle > 180) then
                    --     includedAngle = includedAngle - 360;
                    -- elseif (includedAngle < -180) then
                    --     includedAngle = includedAngle + 360;
                    -- end

                    -- local speed = math.min(curVel:Length() + 1, 20);
                    -- effect.Velocity = Vector.FromAngle(curAngle + includedAngle * 0.3):Resized(speed);
                    
                    local speed = math.min(curVel:Length() + 1, 20);
                    effect.Velocity = (effect.Velocity * 0.5 + target2This * 0.5):Resized(speed);
                    --effect.Velocity = Vector.FromAngle(curAngle + includedAngle * 0.3):Resized(speed);

                    if (effect.Target.Position:Distance(effect.Position) <= effect.Target.Size) then
                        THI.SFXManager:Play(SoundEffect.SOUND_SOUL_PICKUP)
                        effect.Position = effect.Target.Position;
                        effect.State = 1;
                        effect.Velocity = Vector.Zero;
                        Bucket:AddSoul(effect.Target, effect.MaxHitPoints)

                        local player = effect.Target:ToPlayer();
                        if (player) then
                            if (Bucket:GetSoulNum(player) >= 8) then
                                for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
                                    if (player:GetActiveItem(slot) == Bucket.Item) then
                                        Game():GetHUD():FlashChargeBar (player, slot)
                                        THI.SFXManager:Play(SoundEffect.SOUND_ITEMRECHARGE);
                                    end
                                end
                            end
                        end
                    end
                else
                    spr:Play("Idle");
                    effect:MultiplyFriction(0.9);
                end
            else
                spr:Play("Collect");
                if (spr:IsFinished("Collect")) then
                    effect:Remove();
                end
            end
        end
    end
    Bucket:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate)

    local function PostEntityRemove(mod, entity)
        if (entity.Type == Bucket.Soul.Type and entity.Variant == Bucket.Soul.Variant and entity.SubType == Bucket.Soul.SubType) then
            if (entity.Child and entity.Child:Exists()) then
                entity.Child:Remove();
            end
        end
    end
    Bucket:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostEntityRemove)
end

local function PreUseBucket(mod, item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_OWNED <= 0 or flags & UseFlag.USE_MIMIC > 0 or Bucket:GetSoulNum(player) < 8) then
        return true;
    end
end
Bucket:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, PreUseBucket, Bucket.Item);


local function PostUseBucket(mod, item, rng, player, flags, slot, varData)
    if (flags & UseFlag.USE_OWNED > 0 and flags & UseFlag.USE_MIMIC <= 0 and Bucket:GetSoulNum(player) >= 8) then
        local total = 0;
        for i = 1, 8 do
            total = total + Bucket:GetSoul(player, 1);
            Bucket:RemoveSoul(player, 1);
        end

        local count = 1;
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)) then
            count = 2;
        end
        for i = 1, count do
            local resultHP = math.max(0, math.min(24, math.ceil(2 * (total / 40) ^ 0.5)));
            local wisp = player:AddWisp(Bucket.Item, player.Position);
            wisp.MaxHitPoints = resultHP;
            wisp.HitPoints = resultHP;
        end

        return {ShowAnim = true};
    end
end
Bucket:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseBucket, Bucket.Item);


local function PostTearUpdate(mod, tear)
    if (tear.FrameCount == 1) then
        
        local spawner = tear.SpawnerEntity;
        if (spawner) then
            if (spawner.Type == EntityType.ENTITY_FAMILIAR and spawner.Variant == FamiliarVariant.WISP and spawner.SubType == Bucket.Item) then
                tear.CollisionDamage = math.ceil(spawner.MaxHitPoints / 3);
                tear.Scale = Math.GetTearScaleByDamage(tear.CollisionDamage) / 2;
            end
        end
    end
end
Bucket:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate);


local function GetShaderParams(mod, name)
    if (Game():GetHUD():IsVisible ( ) and name == "HUD Hack") then
        Actives.RenderActivesCount(Bucket.Item, function(player) 
            return Bucket:GetSoulNum(player);
        end);
    end
end
Bucket:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GetShaderParams);

return Bucket;