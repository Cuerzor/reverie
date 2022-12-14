local Dream = GensouDream;
local Screen = CuerLib.Screen;
local Math = CuerLib.Math;
local Entities = CuerLib.Entities;
local Players = CuerLib.Players;
local Actives = CuerLib.Actives;

-- Doremy
local Doremy = {
    Type = Isaac.GetEntityTypeByName("Doremy Sweet"),
    Variant = Isaac.GetEntityVariantByName("Doremy Sweet"),
}

Doremy.States = {
    NON_SPELL = 1,
    SPELL_CARD = 2
}

local deadDoremyList = {};

local function GetDoremyData(doremy)
    local data = doremy:GetData();
    local exists = data.DoremyData ~= nil;
    data.DoremyData = data.DoremyData or {
        RNG = RNG(),

        SpellId = 1,

        Waiting = false,
        Motion = {
            Moving = false,
            MoveTime = 0;
            Direction = "Right"
        },

        VerticalLine = nil,
        -- DamageLimit = 5,

        DanmakuData = nil
    }
    if (not exists) then
        data.DoremyData.RNG:SetSeed(Random(), 0);
    end
    return data.DoremyData;
end

Doremy.GetDoremyData = GetDoremyData;

-- Motion.
local function Move(doremy, x, y)
    local sprite = doremy:GetSprite();
    local data = GetDoremyData(doremy);

    doremy.TargetPosition = Vector(x, y);
    local dir = "Left";
    if (doremy.Position.X < x) then
        dir = "Right"
    end
    sprite:Play("FlyIn"..dir);
    data.Motion.Direction = dir;
    data.Motion.Moving = true;
    data.Motion.MoveTime = 30;
end
Doremy.Move = Move;

local function MoveToCenter(doremy)
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();
    local x = center.X;
    local y = 180;
    Move(doremy, x, y);
end
Doremy.MoveToCenter = MoveToCenter;

function Doremy.RandomMove(doremy)
    local data = GetDoremyData(doremy);
    local room = THI.Game:GetRoom();
    local center = room:GetCenterPos();
    local width = 200;
    local x = data.RNG:RandomFloat() * width + center.X - 100;
    local y = data.RNG:RandomFloat() * 120+ 140;
    Move(doremy, x, y);
end


local function ClearProjectiles(doremy)
    
    for k, v in pairs(Isaac.FindByType(9)) do
        v:Die();
    end
    
    for k, v in pairs(Isaac.FindByType(7)) do
        local laserData = v:GetData();
        if (Entities.CompareEntity(laserData.Doremy, doremy)) then
            v:Remove();
        end
    end
end

local function SpawnSupplies(doremy)
    local game = Game();
    local room = game:GetRoom();

    local center = room:GetCenterPos();
    local vel = Vector.Zero;
    local pos;

    local hasLost = false;
    local hasKeeper = false;
    local hasOther = false;
    for p, player in Players.PlayerPairs(true) do
        local playerType = player:GetPlayerType();
        if (playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B) then
            hasLost = true;
        elseif (playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B) then
            hasKeeper = true;
        else
            hasOther = true;
        end
    end

    if (hasOther) then
        pos = center;
        pos = room:FindFreePickupSpawnPosition(pos);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, pos, vel, doremy);
    end

    if (hasLost) then
        pos = center;
        pos = room:FindFreePickupSpawnPosition(pos);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HOLY, pos, vel, doremy);
    end
    if (hasKeeper) then
        pos = center;
        pos = room:FindFreePickupSpawnPosition(pos);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pos, vel, doremy);
    end

    for x = -1, 1, 2 do
        pos = center + Vector(x * 40, 0);
        pos = room:FindFreePickupSpawnPosition(pos);
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, pos, vel, doremy);
    end

end

local function ChargeActives()
    for p, player in Players.PlayerPairs(true) do
        Actives:ChargeAll(player, 2, true, true);
    end
end

local function NextState(doremy)
    local tempData = Dream:GetTempData();
    if (Entities.CompareEntity(tempData.Doremy, doremy)) then
        local data = Doremy.GetDoremyData(doremy);
        --doremy.HitPoints = doremy.MaxHitPoints * Doremy:GetHPByState(data.SpellId, data.UsingSpell);
        local usingSpell = Doremy:IsUsingSpellCard(doremy);
        -- Non-Spell.
        if (not usingSpell) then
            Dream:StartChoosingDream();
            SFXManager():Play(THI.Sounds.SOUND_TOUHOU_CHARGE);
            local Trail = Dream.Effects.NightmareTrail;
            local trail = Trail:SpawnTrail(doremy, Vector.Zero);
            trail:GetSprite():Play("Spin");
            trail:GetSprite().PlaybackSpeed = 1;
            trail.LifeSpan = 10;
            trail.Timeout = 21;

            
            local Star = Dream.Effects.DreamStar;
            for i = 1, 18 do
                local vel = Vector.FromAngle(i * 20) * 1;
                local star = Isaac.Spawn(Star.Type, Star.Variant, Star.SubType, doremy.Position, vel, doremy):ToEffect();
                local starData = star:GetData();
                starData.StarAcceleration = 1.1;
            end
            doremy:Remove();
        else -- Spell Card.
            
            Dream:AddClearedSpellCard(data.SpellId);
            if (not Dream:IsAllCleared()) then
                Dream:StartNonSpell();
                doremy:Remove();
                SpawnSupplies(doremy);
                ChargeActives();
            else
                Game():GetRoom():MamaMegaExplosion (doremy.Position);
                --THI.SFXManager:Play(SoundEffect.SOUND_MEGA_BLAST_START);
                SFXManager():Play(THI.Sounds.SOUND_TOUHOU_DESTROY, 0.5);
            end
        end
        
        data.DanmakuData = nil;
    end
end


---- Global Functions.

Doremy.StateHP = {
    0.9, --Non-Spell 1
    0.8, --Scarlet Nightmare
    0.8, --Non-Spell 2
    0.7, --Ochre Confusion
    0.7, --Empty
    0.6, --Creeping Bullet
    0.5, --Non-Spell 3
    0.4, --Dream Express
    0.4, --Empty
    0.3, --Butterfly Supplantation
    0.2, --Non-Spell 4
    0.1, --Dream Catcher
    0.1, --Empty
    0, --Ultramarine Lunatic Dream
}

-- function Doremy:GetHPByState(spellID, usingSpell)
--     local state = spellID * 2;
--     if (not usingSpell) then
--         state = state - 1;
--     end
--     state = math.max(1, math.min(#self.StateHP, state));
--     return self.StateHP[state];
-- end


function Doremy:GetUsingNonSpell(doremy)
    if (not Doremy:IsUsingSpellCard(doremy)) then
        local data = GetDoremyData(doremy);
        local info = Dream.NonSpells[data.SpellId];
        return info;
    end
    return nil;
end

function Doremy:GetUsingSpell(doremy)
    if (Doremy:IsUsingSpellCard(doremy)) then
        local data = GetDoremyData(doremy);
        local info = Dream.SpellCards[data.SpellId];
        return info;
    end
    return nil;
end
function Doremy:SetSpellCard(doremy, id, isSpellCard)
    local data = GetDoremyData(doremy);
    data.SpellId = id;
    local npc = doremy:ToNPC();
    if (isSpellCard) then
        npc.State = Doremy.States.SPELL_CARD
    else
        npc.State = Doremy.States.NON_SPELL
    end
end
function Doremy:SetWait(doremy, wait, time)
    local data = GetDoremyData(doremy);
    data.Waiting = wait;
    doremy:ToNPC().StateFrame = time;
end

function Doremy:GetSpellFrame(doremy)
    local data = GetDoremyData(doremy);
    return doremy:ToNPC().StateFrame;
end

function Doremy:IsUsingSpellCard(doremy)
    return doremy:ToNPC().State == Doremy.States.SPELL_CARD;
end



--------------------------
-- Events 
--------------------------
local function doremyInit(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local doremy = entity;
        local sprite = doremy:GetSprite();
        sprite:Play("Idle");
        doremy.TargetPosition = doremy.Position;

        local data = GetDoremyData(entity);

        -- Spawn Vert Line.
        local pos = Vector(entity.Position.X, 40);
        local VertLine = Doremy.VerticalLine;
        local line = Isaac.Spawn(VertLine.Type, VertLine.Variant, VertLine.SubType, pos, Vector.Zero, entity);
        line.Parent = entity;
        line.DepthOffset = 0; 
        line:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
        data.VerticalLine = line;
    end
end

Dream:AddCallback(ModCallbacks.MC_POST_NPC_INIT, doremyInit, Doremy.Type);

local function doremyUpdate(mod, entity)
    if (entity.Variant == Doremy.Variant ) then

        
        local doremy = entity;
        -- Die.
        if (doremy:IsDead()) then
            return;
        end

        -- Get Data.
        local data = GetDoremyData(doremy);

        -- Sprite Update.
        local sprite = doremy:GetSprite();
        if (sprite:IsEventTriggered("Idle")) then
            sprite:Play("Idle");
        end

        -- Move.
        if (data.Motion.Moving) then
            data.Motion.MoveTime = data.Motion.MoveTime - 1;
            if (data.Motion.MoveTime <= 0) then
                data.Motion.Moving = false;
                sprite:Play("FlyOut"..data.Motion.Direction);
            end
        end
        doremy.Velocity = (doremy.TargetPosition - doremy.Position) * 0.15;

        
        if (data.Waiting) then
            doremy.EntityCollisionClass = 0;
            doremy.StateFrame = doremy.StateFrame - 1;
            if (doremy.StateFrame <= 0) then
                data.Waiting = false;
                doremy.StateFrame = 0;
                doremy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            end
        else

            doremy.StateFrame = doremy.StateFrame + 1;
            local usingSpells = Doremy:IsUsingSpellCard(doremy);
            local spell;
            if (usingSpells) then
                spell = Doremy:GetUsingSpell(doremy);
            else
                spell = Doremy:GetUsingNonSpell(doremy);
            end
            -- Switch State.
            spell:Update(doremy);

            if (usingSpells) then
                local duration = spell:GetDuration()
                local timeout = duration - doremy.StateFrame
                if (timeout <= 300 and timeout > 0 and timeout % 30 == 0) then
                    SFXManager():Play(THI.Sounds.SOUND_TOUHOU_TIMEOUT, 2);
                end
                --local stateHP = doremy.MaxHitPoints * Doremy:GetHPByState(data.SpellId, data.UsingSpell)
                if (timeout <= 0) then
                    doremy:Kill();
                    doremy:Kill();
                end
            end
        end

    end
end
Dream:AddCallback(ModCallbacks.MC_NPC_UPDATE, doremyUpdate, Doremy.Type);

-- local damageLock = false;
-- local function doremyTakeDamage(mod, tookDamage, amount, flags, source, countdown)
--     if (tookDamage.Variant == Doremy.Variant) then
--         if (amount > 0) then
--             local doremy = tookDamage;
--             local data = GetDoremyData(doremy);
            
--             if (data.DamageLimit <= 0) then
--                 return false;
--             end

            
--             -- Recude Damage.
--             if (amount > data.DamageLimit and not damageLock) then
--                 damageLock = true;
--                 doremy:TakeDamage(data.DamageLimit, flags, source, countdown);
--                 damageLock = false;
                
--                 data.DamageLimit = 0;
--                 return false;
--             else 
--                 data.DamageLimit = data.DamageLimit - amount;
--             end
--         end
--     end
-- end
-- Dream:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, doremyTakeDamage, Doremy.Type);

local function doremyTakeDamage(mod, tookDamage, amount, flags, source, countdown)
    if (tookDamage.Variant == Doremy.Variant) then
        if (amount > 0) then
            local doremy = tookDamage;
            local data = GetDoremyData(doremy);
            
            if (data.Waiting) then
                return false;
            end
        end
    end
end
Dream:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, doremyTakeDamage, Doremy.Type);

local function doremyKill(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local doremy = entity:ToNPC();
        -- THI.Effects.SpellCardWave.Burst(doremy.Position);
        -- THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DESTROY, 0.5);
        -- THI.Game:ShakeScreen(30);
        -- table.insert(deadDoremyList, doremy);

        
        local usingSpell = Doremy:GetUsingSpell(doremy);
        if (usingSpell) then
            usingSpell:End(entity);
        end
        ClearProjectiles(doremy);
        NextState(doremy);
    end
end
Dream:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, doremyKill, Doremy.Type);

local function doremyDeath(mod, entity)
    if (entity.Variant == Doremy.Variant) then
        local doremy = entity;
        THI.Game:GetRoom():MamaMegaExplosion (doremy.Position);
        --THI.SFXManager:Play(SoundEffect.SOUND_MEGA_BLAST_START);
        THI.SFXManager:Play(THI.Sounds.SOUND_TOUHOU_DESTROY, 0.5);
        Dream:EndBattle();
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



-- Vertical Line.
do
    local VerticalLine = {
        Type = Isaac.GetEntityTypeByName("Doremy Vertical Line"),
        Variant = Isaac.GetEntityVariantByName("Doremy Vertical Line"),
        SubType = 3
    }

    local function VerticalLineUpdate(mod, effect)
        if (effect.SubType == VerticalLine.SubType) then
            local parent = effect.Parent;
            if (parent and parent:Exists() and not parent:IsDead()) then
                local pos = Vector(parent.Position.X, 40);
                effect.Position = pos;
                effect.DepthOffset = 0; 
            else
                effect:Remove();
            end
        end
    end
    Dream:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, VerticalLineUpdate, VerticalLine.Variant);

    Doremy.VerticalLine = VerticalLine;
end


return Doremy;
