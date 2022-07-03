local Fairy = ModEntity("Spring Fairy", "SPRING_FAIRY");


function Fairy:CanCollect(player)
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
        if (Fairy:CanCollect(player)) then
            local canPick = true;
            if (pickup:IsShopItem()) then
                if (player:GetNumCoins() < pickup.Price) then
                    canPick = false;
                else
                    player:AddCoins(-pickup.Price);
                end
            end
            
            if (canPick) then
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
                THI.SFXManager:Play(THI.Sounds.SOUND_FAIRY_HEAL);
            end
        else
            return true;
        end
    end
end
Fairy:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreFairyCollision, Fairy.Variant)

local function CanCollect(mod, player, pickup)
    if (pickup.Type == Fairy.Type and pickup.Variant == Fairy.Variant) then
        return Fairy:CanCollect(player);
    end
end
Fairy:AddCustomCallback(CuerLib.CLCallbacks.CLC_CAN_COLLECT, CanCollect);

return Fairy;