local Dream = GensouDream;
local SpellCard = {};
SpellCard.__index = SpellCard;

local metatable = {};
metatable.__call = function()
        local new = {};
        setmetatable(new, SpellCard);
        return new;
    end

setmetatable(SpellCard, metatable);

function SpellCard:Update(doremy)
    local sprite = doremy:GetSprite();
    local data = self:GetData(doremy);
    local frame = self:GetFrame(doremy);

    if (self:CanMove(frame)) then
        Dream.Doremy.RandomMove(doremy);
    end
    
    -- Warning
    if (self:CanWarning(frame)) then
        THI.Effects.SpellCardWave.Shrink(doremy.Position);
    end
    -- Cast Danmaku.
    if (self:CanCast(frame)) then
        sprite:Play("Cast");
    end

    if (sprite:IsEventTriggered("Cast")) then
        self:OnCast(doremy);
    end

    self:PostUpdate(doremy);
end

function SpellCard:OnCast(doremy)
end

function SpellCard:PostUpdate(doremy)
end

function SpellCard:GetDuration()
    return 600;
end

function SpellCard:CanCast(frame)
    return frame % 120 == 0;
end

function SpellCard:CanMove(frame)
    return frame % 90 == 0 and not self:CanCast(frame);
end

function SpellCard:CanWarning(frame)
    return false;
end

function SpellCard:GetProjectileFlags(doremy, projectile)
    local flags = 0;
    if (doremy:HasEntityFlags(EntityFlag.FLAG_CHARM)) then
        flags = flags | ProjectileFlags.HIT_ENEMIES
    end

    if (doremy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        flags = flags | ProjectileFlags.CANT_HIT_PLAYER;
    end
    return flags;
end

function SpellCard:GetFrame(doremy)
    return Dream.Doremy.GetDoremyData(doremy).Frame;
end

function SpellCard:GetData(doremy)
    local data = Dream.Doremy.GetDoremyData(doremy);
    data.DanmakuData = data.DanmakuData or self:GetDefaultData(data);
    return data.DanmakuData;
end

function SpellCard.GetRandomPlayer()
    local game = THI.Game;
    local room = THI.Game:GetRoom();
    local player = game:GetRandomPlayer(room:GetCenterPos(), 1000);
    return player;
end

function SpellCard:GetDefaultData(doremy)
    return {};
end
return SpellCard;