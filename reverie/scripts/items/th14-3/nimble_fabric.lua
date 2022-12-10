local Actives = CuerLib.Actives;
local Screen = CuerLib.Screen;
local Fabric = ModItem("Nimble Fabric", "NIMBLE_FABRIC");


local function GetTempPlayerData(player, create)
    return Fabric:GetTempData(player, create, function()
        return {
            Invincible = false,
            Fabric = nil,
            Cooldown = -1,
        }
    end)
end

function Fabric:RemoveFabric(player)
    local tempData = GetTempPlayerData(player, true);
    tempData.Fabric = nil;
    tempData.Cooldown = 5;
end

local function PostPlayerUpdate(mod, player)
    local tempData = GetTempPlayerData(player, false);
    if (tempData) then
        local fabric = tempData.Fabric;
        if (fabric and fabric:Exists()) then
            player:SetMinDamageCooldown(59);
            player.Velocity = Vector.Zero;
            fabric.PositionOffset = player.PositionOffset;
            if (not tempData.Invincible) then
                tempData.Invincible = true;
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE;
                player.ControlsCooldown = math.max(player.ControlsCooldown, 1);
            end
        else
            if (tempData.Invincible) then
                tempData.Invincible = false;
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL;
            end
            tempData.Fabric = nil;
        end

        if (tempData.Cooldown >= 0) then
            tempData.Cooldown = tempData.Cooldown - 1;
        end
    end
end
Fabric:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate);


local function TryUseFabric(mod, item, player, slot)
    local result = Actives:GetTotalCharges(player, slot) > 0;
    return result;
end
Fabric:AddCallback(CuerLib.Callbacks.CLC_TRY_USE_ITEM, TryUseFabric, Fabric.Item);

local function PreUseFabric(mod, item, rng, player, flags, slot)
    local tempData = GetTempPlayerData(player, false);
    if (tempData and tempData.Cooldown >= 0) then
        return true;
    end
end
Fabric:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, PreUseFabric, Fabric.Item);

local function PostUseFabric(mod, item, rng, player, flags, slot, varData)
    local tempData = GetTempPlayerData(player, true);

    local effect = Fabric.Effect;
    local fabric = Isaac.Spawn(effect.Type, effect.Variant, effect.SubType, player.Position, Vector.Zero, player):ToEffect();
    fabric.Timeout = 150;
    fabric.DepthOffset = 10;
    fabric.Parent = player;
    fabric.SpriteScale = player.SpriteScale;
    fabric.PositionOffset = player.PositionOffset;
    tempData.Cooldown = 5;
    player:SetMinDamageCooldown(59);

    tempData.Fabric = fabric;
    THI.SFXManager:Play(THI.Sounds.SOUND_NIMBLE_FABRIC);

    
    if (flags & UseFlag.USE_OWNED > 0) then
        if (Actives.CanSpawnWisp(player, flags)) then
            local wisp = player:AddWisp(Fabric.Item, player.Position);
        end
        Actives:CostUseTryCharges(player, item, slot, 1)
    else
        Actives:EndUseTry(player, slot)
    end
    
    
    return {ShowAnim = false, Discharge = false}
end
Fabric:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseFabric, Fabric.Item);

do -- Effect.

    local Effect = ModEntity("Nimble Fabric", "NIMBLE_FABRIC");
    local chargeBar = Sprite();
    chargeBar:Load("gfx/chargebar.anm2")
    chargeBar:Play("Charging");
    Effect.ChargeBarSprite = chargeBar;

    local function PostEffectInit(mod, effect)
        local spr = effect:GetSprite();
        spr:Play("Appear");
    end
    Effect:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, PostEffectInit, Effect.Variant);

    local function PostEffectUpdate(mod, effect)
        local spr = effect:GetSprite();
        if (spr:IsFinished("Appear")) then
            spr:Play("Idle");
        elseif (spr:IsPlaying("Idle")) then
            local parent = effect.Parent;
            if (parent) then
                effect.Position = parent.Position;
                effect.Velocity = parent.Velocity;
                local player = parent:ToPlayer();

                local canceled = true;
                if (player and Actives.IsActiveItemPressed(player, Fabric.Item)) then
                    canceled = false;
                end

                if (canceled or effect.Timeout == 0) then
                    Fabric:RemoveFabric(player)
                    spr:Play("Disappear");
                end
            end

        elseif (spr:IsFinished("Disappear")) then
            effect:Remove();
        end

    end
    Effect:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PostEffectUpdate, Effect.Variant);

    local function PostEffectRender(mod, effect, offset)
        if (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
            local spr = effect:GetSprite();
            if (spr:IsPlaying("Idle")) then
                local barSpr = Effect.ChargeBarSprite;
                barSpr:SetFrame(math.floor(effect.Timeout / 150 * 100));
                local pos = Screen.GetEntityOffsetedRenderPosition(effect, offset, Vector(0, -24 *  effect.SpriteScale.Y));
                barSpr:Render(pos, Vector.Zero, Vector.Zero);
            end
        end
    end
    Effect:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, PostEffectRender, Effect.Variant);

    Fabric.Effect = Effect;
end

return Fabric;