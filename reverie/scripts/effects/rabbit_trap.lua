local RabbitTrap = ModEntity("Rabbit Trap", "RabbitTrap");
RabbitTrap.SubType = 5810;


local maxChecktime = 3;
local function GetTrapData(trap, init) 
    return RabbitTrap:GetData(trap, init, function() return {
        CheckTime = maxChecktime,
        Triggered = false
    } end);
end

local function TriggerTrap(trap)
    
    local data = GetTrapData(trap, true);
    if (not data.Triggered) then
        data.Triggered = true;
        trap:GetSprite():Play("Trigger");
    end
end

local function UpdateTrap(trap)
    
    trap.SpriteScale = Vector(1, 1);
    trap.Timeout = 270;

    local data = GetTrapData(trap, true);
    if (data.Triggered) then
        local spr = trap:GetSprite();
        if (spr:IsFinished("Trigger")) then
            --spr:SetFrame("Trigger", 41);
            --spr:Play("Disappear");
        end
        
        if (spr:IsFinished("Disappear")) then
            trap:Remove();
        end
        spr:Update();
    end

    data.CheckTime = data.CheckTime - 1;
    if (data.CheckTime <= 0) then
        data.CheckTime = maxChecktime;
        for _, ent in pairs(Isaac.FindInRadius(trap.Position, 50, EntityPartition.ENEMY)) do
            local npc = ent:ToNPC();
            if (npc) then
                if (not ent:IsFlying() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                    if (npc.Position:Distance(trap.Position) <= 15 + npc.Size) then
                        if (not npc:IsBoss()) then
                            npc:Kill();
                        else
                            npc:TakeDamage(30, DamageFlag.DAMAGE_IGNORE_ARMOR | DamageFlag.DAMAGE_COUNTDOWN, EntityRef(trap), 20);
                        end
                        TriggerTrap(trap);
                        return;
                    end
                end
            end
        end
    end
end

function RabbitTrap:onTrapUpdate(trap)
    if (trap.SubType == RabbitTrap.SubType) then
        UpdateTrap(trap);
    end
end
RabbitTrap:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RabbitTrap.onTrapUpdate, RabbitTrap.Variant);

return RabbitTrap;
