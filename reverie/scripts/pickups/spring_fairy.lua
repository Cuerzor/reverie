local Players = CuerLib.Players;
local Fairy = ModEntity("Spring Fairy", "SPRING_FAIRY");


function Fairy:CanCollect(player, pickup)
    if (pickup:IsShopItem()) then
        if (player:GetNumCoins() < pickup.Price) then
            return false;
        end
    end
    if (pickup:GetSprite():IsPlaying("Appear")) then
        return false;
    end
    return player:CanPickRedHearts() or player:CanPickSoulHearts()
end

local function PostFairyUpdate(mod, pickup)
    if (not pickup:IsShopItem()) then
        local x = (Random() % 1000 / 1000 - 0.5) * 0.5;
        local y = (Random() % 1000 / 1000 - 0.5) * 0.5;
        pickup:AddVelocity(Vector(x, y))
    else
        pickup:GetSprite():Play("Land")
    end
end
Fairy:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PostFairyUpdate, Fairy.Variant)


local function PreFairyCollision(mod, pickup, collider)
    local player = collider:ToPlayer();
    if (player) then
        if (Fairy:CanCollect(player, pickup)) then
            if (pickup:IsShopItem()) then
                Players:Buy(player, pickup.Price);
            end
            if (THI.IsLunatic()) then
                player:AddHearts(2);
            else
                player:AddHearts(player:GetMaxHearts());
            end
            player:AddSoulHearts(2);
            -- Remove self and create a fairy Effect.
            local Effect = THI.Effects.FairyEffect;
            local fairyEffect = Isaac.Spawn(Effect.Type, Effect.Variant, 0, pickup.Position, Vector(0, 0), player):ToEffect()
            fairyEffect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT);
            pickup:Remove();
            --THI.SFXManager:Play(SoundEffect.SOUND_BOSS2_BUBBLES);
            SFXManager():Play(THI.Sounds.SOUND_FAIRY_HEAL);
        else
            return true;
        end
    end
end
Fairy:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, PreFairyCollision, Fairy.Variant)

local function CanCollect(mod, player, pickup)
    return Fairy:CanCollect(player, pickup);
end
Fairy:AddCallback(CuerLib.Callbacks.CLC_CAN_PICKUP_COLLECT, CanCollect, Fairy.Variant);

return Fairy;