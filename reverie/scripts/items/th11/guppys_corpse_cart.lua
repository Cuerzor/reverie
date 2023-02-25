local CorpseCart = ModItem("Guppy's Corpse Cart", "GUPPYS_CORPSE_CART");

local itemConfig = Isaac.GetItemConfig():GetCollectible(CorpseCart.Item)
CorpseCart.ChargeSpritePath = "gfx\\reverie\\characters\\costumes\\costume_guppys_corpse_cart_b.png"
CorpseCart.NormalSpritePath = "gfx\\reverie\\characters\\costumes\\costume_guppys_corpse_cart.png";

function CorpseCart:CanCrush(player)
    if (player:GetPlayerType() == Reverie.Players.SatoriB.Type) then
        return false;
    end
    local effects = player:GetEffects();
    return effects:HasCollectibleEffect(CorpseCart.Item);
end

local function PostPlayerEffect(mod, player)
    if (player:IsFrame(3, 0)) then
        
        if (player:HasCollectible(CorpseCart.Item)) then
            local effects = player:GetEffects();
            if (player.Velocity:Length() >= 4) then
                if (not effects:HasCollectibleEffect(CorpseCart.Item)) then
                    effects:AddCollectibleEffect(CorpseCart.Item, false);
                    player:ReplaceCostumeSprite (itemConfig, CorpseCart.ChargeSpritePath, 0);
                end
            else
                if (effects:HasCollectibleEffect(CorpseCart.Item)) then
                    effects:RemoveCollectibleEffect(CorpseCart.Item, -1);
                    player:ReplaceCostumeSprite (itemConfig, CorpseCart.NormalSpritePath, 0);
                end
            end
        end
    end
end
CorpseCart:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

local function EvaluateCache(mod, player, flag)
    if (player:HasCollectible(CorpseCart.Item)) then
        if (flag == CacheFlag.CACHE_FLYING) then
            player.CanFly = true;
        elseif (flag == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + 0.2;
        end
    end
end
CorpseCart:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache)


local function PreNPCCollision(mod, npc, other, low)
    local player = other:ToPlayer();
    if (player and player:HasCollectible(CorpseCart.Item) and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if (CorpseCart:CanCrush(player)) then
            local Wheelchair = THI.Shared.Wheelchair;
            local damage =  10 + 10 * (player.Damage / 3.5) ^ 0.5;
            Wheelchair:Crush(npc, damage, player);
            if (not npc:HasMortalDamage()) then
                player:AddVelocity((player.Position-npc.Position):Resized(20));
            end
            return false;
        end
    end
end
CorpseCart:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, PreNPCCollision)

return CorpseCart;