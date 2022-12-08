local CompareEntity = CuerLib.Entities.CompareEntity;
local Unzan = ModEntity("Unzan Face", "UNZAN");
Unzan.TearColor = Color(1,1,1,0.5,1,0.5,0.5);
Unzan.OffsetVector = Vector(-480, 0);

local function GetUnzanData(unzan, create)
    return Unzan:GetTempData(unzan, create, function()
        return {
            StateTime = 0,
            FistIndex = 0,
        }
    end);
end


local function GetTearData(tear, create)
    return Unzan:GetTempData(tear, create, function()
        return {
            Unzan = false,
            InsideRoom = false,
            Disappearing = false
        }
    end);
end

function Unzan:TearDisappear(tear)
    local tearData = GetTearData(tear, true);
    tearData.Disappearing = true;
    tear.EntityCollisionClass = 0;
    Game():ShakeScreen(10);
    tear:Die();
    THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.5)
end

local function PostEffectInit(mod, effect)
    effect.TargetPosition = Unzan.OffsetVector;
    THI.SFXManager:Play(THI.Sounds.SOUND_UFO, 0.5);
    effect.SpriteScale = Vector(0.4, 0.4);
end
Unzan:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Unzan.Variant)

local function PostEffectUpdate(mod, effect)

    if (effect.State == 0) then
        effect.TargetPosition = effect.TargetPosition * 0.8;
    end

    if (effect.FrameCount > 30) then
        local game = Game();
        local room = game:GetRoom();
        local level = game:GetLevel();
        local height = room:GetGridHeight();
        local width = room:GetGridWidth();
        local data = GetUnzanData(effect, true);
        data.StateTime = data.StateTime + 1;
        if (effect.State == 0) then
                
            local hasEnemy = false;
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    hasEnemy = true;
                    break;
                end
            end
            if (hasEnemy) then
                -- if (data.StateTime > height * 5 + 30) then
                --     data.StateTime = 0;
                --     data.FistIndex = (data.FistIndex or 0 + 1) % 2;
                -- end
                -- for i = 1, height / 2 - 1 do
                --     if (data.StateTime == i * 5) then
                --         local y = i * 2;
                --         local pos = Vector(0, room:GetGridPosition(y * width).Y);
                --         local vel = Vector(1, 0);
            
                --         if ((i + data.FistIndex or 0) % 2 == 1) then
                --             pos.X = room:GetGridPosition(width - 1).X + 40
                --             vel.X = - vel.X;
                --         end
            
                --         local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, effect);
                --         poof.SpriteScale = Vector(2, 2)
                --         poof:SetColor(Unzan.TearColor, -1, 0);
                --         local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIST, 0, pos, vel, effect):ToTear();
                --         tear:AddTearFlags(TearFlags.TEAR_PUNCH | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL);
                --         tear.Scale = 8;
                --         tear.CollisionDamage = level:GetStage() * 5;
                --         tear.FallingAcceleration = -0.1;
                --         tear:SetColor(Unzan.TearColor, -1, 0);
                --         local tearData = GetTearData(tear, true);
                --         tearData.Unzan = true;
                --     end
                -- end
                if (data.StateTime > 60) then
                    data.StateTime = 0;
                    local parent = effect.Parent;
                    if (parent) then
                        for i =1, 2 do
                        
                            local pos = Vector(0, parent.Position.Y);
                            local vel = Vector(1, 0);
                            if (i == 2) then
                                pos.X = room:GetGridPosition(width - 1).X + 40
                                vel.X = - vel.X;
                            end
                            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, effect);
                            poof.SpriteScale = Vector(2, 2)
                            poof:SetColor(Unzan.TearColor, -1, 0);
                            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIST, 0, pos, vel, effect):ToTear();
                            tear:AddTearFlags(TearFlags.TEAR_PUNCH | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL);
                            tear.Scale = 8;
                            tear.CollisionDamage = level:GetStage() * 2;
                            tear.FallingAcceleration = -0.1;
                            tear:SetColor(Unzan.TearColor, -1, 0);
                            local tearData = GetTearData(tear, true);
                            tearData.Unzan = true;
                        end
                    end
                end
            end
            if (not hasEnemy and room:IsClear()) then
                effect.State = 1;
            end
        elseif (effect.State == 1) then
            if (effect.TargetPosition.X > -1) then 
                effect.TargetPosition = Vector(-1, effect.TargetPosition.Y); 
            end
            effect.TargetPosition = effect.TargetPosition * 1.25;

            if (effect.TargetPosition.X <= Unzan.OffsetVector.X) then
                effect:Remove();
            end
        end

    end
end
Unzan:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Unzan.Variant)

local function PostTearUpdate(mod, tear)
    local tearData = GetTearData(tear, false);
    if (tearData) then
        if (tearData.Unzan) then
            local room = Game():GetRoom();
            if (not tearData.Disappearing) then
                tear:MultiplyFriction(1.1);
            end


            -- local insideRoom = tear.Position.X > 40 and tear.Position.X < room:GetGridPosition(room:GetGridWidth() - 1).X + 40;
            -- if (insideRoom) then
            --     if (not tearData.InsideRoom) then
            --         tearData.InsideRoom = true;
            --     end
            -- else
            --     if (tearData.InsideRoom) then
            --         if (not tearData.Disappearing) then
            --             tearData.Disappearing = true;
            --             tear.EntityCollisionClass = 0;
            --             Game():ShakeScreen(10);
            --             tear:Die();
            --             THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU, 0.5)
                        
            --         end
            --     end
            -- end
            if (not tearData.Disappearing) then
                for i, ent in ipairs(Isaac.FindInRadius(tear.Position, tear.Size * 2, EntityPartition.TEAR)) do
                    if (not CompareEntity(ent, tear) and ent.Position:Distance(tear.Position) < tear.Size * 2) then
                        local otherData = GetTearData(ent, false);
                        if (otherData and otherData.Unzan) then
                            Unzan:TearDisappear(tear);
                            Unzan:TearDisappear(ent:ToTear());
                            local stage = Game():GetLevel():GetStage();
                            local crushDamage = 10 * stage;
                            for _, enm in ipairs(Isaac.FindInRadius((tear.Position + ent.Position) / 2, tear.Size, EntityPartition.ENEMY)) do
                                if (enm:IsEnemy() and not enm:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                                    enm:TakeDamage(crushDamage, DamageFlag.DAMAGE_CRUSH, EntityRef(tear), 0);
                                    SFXManager():Play(SoundEffect.SOUND_BONE_BREAK)
                                end
                            end
                            break;

                        end
                    end
                end
            end
        end
    end
end
Unzan:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PostTearUpdate)


local function PostEffectRender(mod, effect)
    local pos = effect.TargetPosition + Game():GetRoom():GetRenderScrollOffset();
    effect:GetSprite():Render(pos, Vector.Zero, Vector.Zero);
end
Unzan:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, PostEffectRender, Unzan.Variant)

return Unzan;