local Knife = ModEntity("Haniwa Knife", "HANIWA_KNIFE");
Knife.SubType = Knife.Variant;


local function GetTempKnifeData(knife, create)
    return Knife:GetTempData(knife, create, function()
        return {
            HitEnemies = {}
        }
    end)
end

local function PostKnifeInit(mod, knife)
    if (knife.SubType == Knife.SubType) then
        local spr = knife:GetSprite();
        spr:Play("Swing2");
        spr:ReplaceSpritesheet(0, "");
        spr:LoadGraphics();

    end
end
Knife:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, PostKnifeInit)


-- Knife:AddCallback(ModCallbacks.MC_POST_UPDATE, function(mod) 
--     for i = 1, 816 do
--         if (THI.SFXManager:IsPlaying(i)) then
--             print(i);
--         end
--     end
-- end)


local function PostKnifeUpdate(mod, knife)
    if (knife.SubType == Knife.SubType) then
        local spr = knife:GetSprite();
        if (spr:IsFinished("Swing") or spr:IsFinished("Swing2")) then
            knife:Remove();
        end

        if (knife.Parent) then
            knife.Velocity = knife.Parent.Position - knife.Position - knife.PositionOffset;
            knife.Size = knife.Scale * 32
            knife.SpriteScale = Vector(knife.Scale, knife.Scale);
        end
    end
end
Knife:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, PostKnifeUpdate)

local damageLock = false;
local function PreTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    local sourceEnt = source.Entity;
    if (sourceEnt and sourceEnt.Type == Knife.Type and sourceEnt.SubType == Knife.SubType) then
        if (not damageLock) then
            damageLock = true;
            tookDamage:TakeDamage(source.Entity.CollisionDamage, flags, source, countdown);
            damageLock = false;
            return false;
        else
            local data = GetTempKnifeData(sourceEnt, true);
            local hash = GetPtrHash(tookDamage);
            if (data.HitEnemies[hash]) then
                return false;
            end
            data.HitEnemies[hash] = true;
        end
    end
end
Knife:AddCustomCallback(CuerLib.CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, PreTakeDamage)

local function PostTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    local sourceEnt = source.Entity;
    if (sourceEnt and sourceEnt.Type == Knife.Type and sourceEnt.SubType == Knife.SubType) then
        THI.SFXManager:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1.5);
        if (sourceEnt.Parent) then
            sourceEnt.Parent:AddVelocity((sourceEnt.Position - tookDamage.Position):Resized(5))
        end
    end
end
Knife:AddCustomCallback(CuerLib.CLCallbacks.CLC_POST_ENTITY_TAKE_DMG, PostTakeDamage)

return Knife;