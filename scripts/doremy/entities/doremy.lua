local Dream = GensouDream;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;

-- Doremy
local Doremy = {
    Type = Isaac.GetEntityTypeByName("Doremy Sweet"),
    Variant = Isaac.GetEntityVariantByName("Doremy Sweet"),
    SpellCardNameFont = Font(),
    SpellCardNameSprite = Sprite()
}

Doremy.SpellCardNameFont:Load("font/cjk/lanapixel.fnt") -- load a font into the font object
Doremy.SpellCardNameSprite:Load("gfx/doremy/ui/spell_card_name_underline.anm2", true);
Doremy.SpellCardNameSprite:Play("Idle");


local deadDoremyList = {};
local MaxStateTime = 600;

local function GetDoremyData(doremy)
    local data = doremy:GetData();
    local exists = data.DoremyData ~= nil;
    data.DoremyData = data.DoremyData or {
        RNG = RNG(),
        Position = doremy.Position,

        UsingSpell = false,
        SpellId = 0,
        SpellPool = {},

        StateTime = 0,
        Frame = 0,
        Motion = {
            Moving = false,
            MoveTime = 0;
            Target = Vector.Zero,
            Direction = "Right"
        },
        DamageLimit = 5,
        DanmakuData = nil
    }
    if (not exists) then
        data.DoremyData.RNG:SetSeed(Random(), 0);
    end
    return data.DoremyData;
end

Doremy.GetDoremyData = GetDoremyData;


local function Move(doremy, x, y)
    local sprite = doremy:GetSprite();
    local data = GetDoremyData(doremy);

    data.Motion.Target = Vector(x, y);
    local dir = "Left";
    if (x - data.Position.X > 0) then
        dir = "Right"
    end
    sprite:Play("FlyIn"..dir);
    data.Motion.Direction = dir;
    data.Motion.Moving = true;
    data.Motion.MoveTime = 30;
end
Doremy.Move = Move;

function Doremy.RandomMove(doremy)
    local data = GetDoremyData(doremy);
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();
    local width = 200;
    local x = data.RNG:RandomFloat() * width + center.X - 100;
    local y = data.RNG:RandomFloat() * 120+ 140;
    Move(doremy, x, y);
end


local function MoveToCenter(doremy)
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();
    local x = center.X;
    local y = 180;
    Move(doremy, x, y);
end
Doremy.MoveToCenter = MoveToCenter;

local function SpawnReward()
    
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();
    local offset = Vector(40, 0);
    local bombPos = room:FindFreePickupSpawnPosition(center);
    local soulPos1 = room:FindFreePickupSpawnPosition(center - offset);
    local soulPos2 = room:FindFreePickupSpawnPosition(center + offset);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 1, bombPos, Vector.Zero, nil);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, soulPos1, Vector.Zero, nil);
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, soulPos2, Vector.Zero, nil);
end

local function ClearProjectiles(doremy)
    
    for k, v in pairs(Isaac.FindByType(9)) do
        v:Kill();
    end
    
    for k, v in pairs(Isaac.FindByType(7)) do
        local laserData = v:GetData();
        if (laserData.Doremy == doremy.InitSeed) then
            v:Remove();
        end
    end
end

local function SwitchState(doremy)
    local tempData = Dream:GetTempData(); 
    local data = GetDoremyData(doremy);
    data.Frame = 0;

    
    data.UsingSpell = not data.UsingSpell;
    if (not data.UsingSpell) then
        
        --THI.SFXManager:Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DANMAKU);

        -- Refill Pool.
        local pool = data.SpellPool;
        if (#pool <= 0) then
            for i = 0, #Dream.SpellCards - 1 do
                if (i ~= data.SpellId and #Dream.SpellCards > 1) then
                    table.insert(pool, i);
                end
            end
        end

        local index = data.RNG:RandomInt(#pool) + 1;
        data.SpellId = pool[index];
        table.remove(pool, index);

        tempData.SpellCardBG.Display = false;
        tempData.SpellCardName.Display = false;
    else
        --THI.SFXManager:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_SPELL_CARD);
        tempData.SpellCardBG.Display = true;
        tempData.SpellCardName.Display = true;
        tempData.SpellCardName.Time = 0;
        local key = Dream.SpellCards[data.SpellId+ 1].NameTextKey;
        
        local category = THI.StringCategories.DEFAULT;
        tempData.SpellCardName.Name = THI.GetText(category, key);
    end
    data.DanmakuData = nil;
    MoveToCenter(doremy);
end



--------------------------
-- Events 
--------------------------
local function doremyInit(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local doremy = entity;
        local sprite = doremy:GetSprite();
        sprite:Play("Idle");
    end
end

Dream:AddCallback(ModCallbacks.MC_POST_NPC_INIT, doremyInit, Doremy.Type);

local function doremyUpdate(mod, entity)
    if (entity.Variant == Doremy.Variant ) then
        local doremy = entity;
        local sprite = doremy:GetSprite();
        -- Die.
        if (entity:IsDead()) then
            return;
        end

        -- Get Data.
        local data = GetDoremyData(doremy);


        -- Update Damage Limit.
        data.DamageLimit = math.min(100, data.DamageLimit + 1);

        -- Idle when Stopped.
        if (sprite:IsEventTriggered("Idle")) then
            sprite:Play("Idle");
        end

        -- Move.
        if (data.Motion.Moving) then
            local target = data.Motion.Target;
            local pos = data.Position;
            data.Position = target + (pos - target) * 0.85;
            data.Motion.MoveTime = data.Motion.MoveTime - 1;
            if (data.Motion.MoveTime <= 0) then
                data.Motion.Moving = false;
                sprite:Play("FlyOut"..data.Motion.Direction);
            end
        end
        doremy.Velocity = data.Position - doremy.Position;


        function GetUsingSpell()
            local info = Dream.SpellCards[data.SpellId + 1];
            if (data.UsingSpell) then
                return info.Spell;
            else
                return info.NonSpell;
            end
        end
        -- Switch State.
        data.StateTime = data.StateTime + 1;
        if (data.StateTime >= GetUsingSpell():GetDuration()) then
            SwitchState(doremy);
            data.StateTime = 0;
        end

        data.Frame = data.Frame + 1;
        GetUsingSpell():Update(doremy);

    end
end
Dream:AddCallback(ModCallbacks.MC_NPC_UPDATE, doremyUpdate, Doremy.Type);


local damageLock = false;
local function doremyTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Variant == Doremy.Variant) then
        if (amount > 0) then
            local doremy = tookDamage;
            local data = GetDoremyData(doremy);
            
            if (data.DamageLimit <= 0) then
                return false;
            end

            
            -- Recude Damage.
            if (amount > data.DamageLimit and not damageLock) then
                damageLock = true;
                doremy:TakeDamage(data.DamageLimit, flags, source, countdown);
                damageLock = false;
                
                data.DamageLimit = 0;
                return false;
            else 
                data.DamageLimit = data.DamageLimit - amount;
            end
        end
    end
end
Dream:AddCustomCallback(CLCallbacks.CLC_PRE_ENTITY_TAKE_DMG, doremyTakeDamage, Doremy.Type);



local function doremyKill(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local tempData = Dream:GetTempData(); 
        local doremy = entity:ToNPC();
        -- local data = GetDoremyData(doremy);
        -- if (data.SpellId <= 3) then
            
        --     -- Switch State.
        --     SwitchState(doremy);
        --     return false;
        -- else
        --THI.SFXManager:Play(SoundEffect.SOUND_MEGA_BLAST_START);
        Dream.SpellCardEffect.Burst(doremy.Position);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DESTROY);
        THI.Game:ShakeScreen(30);
        table.insert(deadDoremyList, doremy);
        ClearProjectiles(doremy)
        --end
        tempData.SpellCardName.Display = false;
        tempData.SpellCardBG.Display = false;
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, doremyKill, Doremy.Type);

local function doremyDeath(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local doremy = entity;
        THI.Game:GetRoom():MamaMegaExplosion (doremy.Position);
        --THI.SFXManager:Play(SoundEffect.SOUND_MEGA_BLAST_START);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DESTROY);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, doremyDeath, Doremy.Type);



local function doremyGameUpdate(mod)
    for i, doremy in pairs(deadDoremyList) do
        if (doremy:Exists()) then
            local sprite = doremy:GetSprite();
            doremy.Position = doremy.Position + Vector(2, -1) * math.max(0, 30 - sprite:GetFrame()) / 15;
        else
            deadDoremyList[i] = nil;
        end
    end

end
Dream:AddCallback(ModCallbacks.MC_POST_UPDATE, doremyGameUpdate);


local function renderSpellName(mod)
    local tempData = Dream:GetTempData(); 
    if (tempData.SpellCardName.Display) then
        tempData.SpellCardName.Alpha = 1;
    else
        tempData.SpellCardName.Alpha = tempData.SpellCardName.Alpha - 0.05;
    end

    if (tempData.SpellCardName.Alpha > 0) then
        if (not THI.Game:IsPaused()) then
            tempData.SpellCardName.Time = tempData.SpellCardName.Time + 1;
        end

        local screenSize = Screen.GetScreenSize();
        local x = 0;
        local y = 0;
        if (tempData.SpellCardName.Time < 40) then
            x = (screenSize.X -180 ) * Math.EaseOut(tempData.SpellCardName.Time / 40);
        else
            x = screenSize.X - 180;
        end
        
        if (tempData.SpellCardName.Time < 40) then
            y = screenSize.Y - 20;
        elseif (tempData.SpellCardName.Time < 60) then
            y = (screenSize.Y - 20) * (1 -Math.EaseOut((tempData.SpellCardName.Time - 40) / 20));
        end
        Doremy.SpellCardNameFont:DrawStringUTF8(tempData.SpellCardName.Name,x,y,KColor(1,1,1,tempData.SpellCardName.Alpha),0,true) -- render string with loaded font on position 60x50y
        
        Doremy.SpellCardNameSprite:Render(Vector(x, y), Vector.Zero, Vector.Zero);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_RENDER, renderSpellName);

return Doremy;
