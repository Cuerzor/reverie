local Onbashira = ModEntity("Onbashira", "ONBASHIRA");
Onbashira.MaxTimeout = 240;

Onbashira.MaxRadius = 180;

local function GetOnbashiraData(onbashira, create)
    return Onbashira:GetData(onbashira, create, function ()
        return {
            Piles = nil
        }
    end)
end

local function SpawnPile(onbashira, position)
    position = position or onbashira.Position;
    local pile = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PILE, 0, position, Vector.Zero, onbashira):ToEffect();
    pile.Timeout = 10;
    pile.DepthOffset = 1;
    return pile;
end

local function SpawnPileGroup(onbashira)
    local data = GetOnbashiraData(onbashira, true);
    data.Piles = {};
    for i = 1, 3 do
        local pos = onbashira.Position;
        local pile = SpawnPile(onbashira, pos);
        pile.Parent = onbashira;
        pile.PositionOffset = Vector.FromAngle(i * 30 + 30) * Vector(20, 10) + Vector(0, -3)
        table.insert(data.Piles, pile);
    end
end


function Onbashira:Crush(onbashira)
    Game():ShakeScreen(15);
    Game():BombDamage(onbashira.Position, 100, 80, true, onbashira.SpawnerEntity, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_CRUSH);
    THI.SFXManager:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND);

    local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, onbashira.Position, Vector.Zero, onbashira):ToEffect();
    wave.Parent = onbashira.SpawnerEntity;
    wave.Timeout = 30;
    wave:SetRadii(40, 80);

    
    SpawnPileGroup(onbashira)
    
end


function Onbashira:Pulse(onbashira)
    local radius = self.MaxRadius;
    local Wave = THI.Effects.SpellCardWave;
    local wave = Isaac.Spawn(Wave.Type, Wave.Variant, Wave.SubTypes.BURST, onbashira.Position, Vector.Zero, onbashira);
    wave:SetColor(Color(0,1,1,0.5,0,0,0), -1, 0);
    wave.DepthOffset = 2;

    for i, ent in ipairs(Isaac.FindInRadius(onbashira.Position, radius, EntityPartition.ENEMY)) do
        if (ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, ent.Position, Vector.Zero, onbashira.SpawnerEntity);
        end
    end
end

function Onbashira:IsInRange(onbashira, position)
    return onbashira.Position:Distance(position) < self.MaxRadius;
end

local function PostOnbashiraInit(mod, ent)
    if (ent.Variant == Onbashira.Variant) then
        ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET);
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR);
        local spr = ent:GetSprite();
        spr:Play("Fall")
        ent.TargetPosition = ent.Position;
    end
end
Onbashira:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostOnbashiraInit, Onbashira.Variant);

local function PostOnbashiraUpdate(mod, onbashira)
    if (onbashira.Variant == Onbashira.Variant) then
        onbashira.Velocity = onbashira.TargetPosition - onbashira.Position;
        local spr = onbashira:GetSprite();
        if (spr:IsEventTriggered("Crush")) then
            Onbashira:Crush(onbashira);
        end

        
        if (onbashira.FrameCount <= Onbashira.MaxTimeout) then
            if (spr:IsFinished("Fall") or not spr:IsPlaying("Fall")) then
                onbashira.State = 5;
            end
            -- Pulsing.
            if (onbashira.State == 5) then
                spr:Play("Pulse");
                if (onbashira:IsFrame(15, 0)) then
                    Onbashira:Pulse(onbashira);
                end
            end
        else -- Ascend
            spr:Play("Ascend");
            if (spr:IsFinished("Ascend")) then
                onbashira:Remove()
            end
        end

        -- Create Piles.

        if (onbashira:Exists()) then
            
            local data = GetOnbashiraData(onbashira, false);
            if (not data or not data.Piles) then
                if (onbashira.State == 5) then
                    SpawnPileGroup(onbashira);
                end
            else
                for _, pile in ipairs(data.Piles) do
                    pile.Timeout = 10;
                end
            end
        end
    end
end
Onbashira:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostOnbashiraUpdate, Onbashira.Variant);

return Onbashira;