local Math = CuerLib.Math;
local Consts = CuerLib.Consts;
local SeijasShade = ModEntity("Seija's Shade", "SEIJAS_SHADE");

local function GetShadeTempData(shade, create)
    return SeijasShade:GetTempData(shade, create, function()
        return {
            Pathes = {}
        }
    end)
end

local function PostEffectInit(mod, effect)
    effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
    effect.DepthOffset = -10;
    effect.CollisionDamage = (2 + Game():GetLevel():GetStage() * 1) / 15;
end
SeijasShade:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, SeijasShade.Variant)

local function PostEffectUpdate(mod, effect)
    if (not effect.Parent or not effect.Parent:Exists()) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, effect);
        effect:Remove();
    else
        local data = GetShadeTempData(effect, true);
        table.insert(data.Pathes, effect.Parent.Position);
        local target = effect.Position;
        if (#data.Pathes > 30) then
            target = data.Pathes[1];
            table.remove(data.Pathes, 1);
        end
        effect.Velocity = target - effect.Position;
    end

    -- Damage.
    if (effect:IsFrame(2, 0)) then
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if (ent.Position:Distance(effect.Position) < ent.Size + effect.Size and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                ent:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0);
            end
        end
    end


    -- Sprite.
    local spr = effect:GetSprite();
    local vel = effect.Velocity;
    local prefix = "Walk";
    if (effect.Parent and effect.Parent:IsFlying()) then
        prefix = "Fly";
    end
    if (vel:Length() < 1) then
        spr:SetFrame(prefix.."Down", 0);
    else
        local angle = vel:GetAngleDegrees();
        local dir = Math.GetDirectionByAngle(angle);
        local name = Consts:GetDirectionString(dir);
        spr:Play(prefix..name);
    end

end
SeijasShade:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, SeijasShade.Variant)


return SeijasShade;