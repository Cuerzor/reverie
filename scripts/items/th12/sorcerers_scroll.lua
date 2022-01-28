local Stats = CuerLib.Stats;
local CompareEntity = CuerLib.Detection.CompareEntity;
local Actives = CuerLib.Actives;
local Scroll = ModItem("Sorcerer's Scroll", "SORCERERS_SCROLL");

local ScrollCharges = Isaac.GetItemConfig():GetCollectible(Scroll.Item).MaxCharges;

function Scroll.GetPlayerData(player, init)
    local function getter()
        return {
            UseTime = 0
        }
    end
    return Scroll:GetData(player, init, getter);

end
do
    local function PostUseScroll(mod, item, rng, player, flags, slot, varData)
        local soulCount;
        local playerType = player:GetPlayerType();
        if (playerType == PlayerType.PLAYER_BETHANY) then 
            soulCount = player:GetSoulCharge();
            local activeCharge = player:GetActiveCharge(slot);
            if (activeCharge < ScrollCharges) then
                soulCount = soulCount - (ScrollCharges - activeCharge);
            end
            player:AddSoulCharge (-soulCount);
        else
            soulCount = player:GetSoulHearts();
            local redHearts = player:GetHearts ( )
            local boneHearts = player:GetBoneHearts();
            if (redHearts <= 0 and boneHearts < 0 or playerType == PlayerType.PLAYER_THESOUL) then
                soulCount = soulCount - 1;
            end
            player:AddSoulHearts (-soulCount);
        end
        if (soulCount > 0) then
            
            local data = Scroll.GetPlayerData(player, true);
            data.UseTime = data.UseTime + soulCount;
            THI.SFXManager:Play(SoundEffect.SOUND_DEVILROOM_DEAL);
            if (Actives.CanSpawnWisp(player, flags)) then
                player:AddWisp(Scroll.Item, player.Position);
            end
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
            

            return {ShowAnim = true}
        end
        return {Discharge = false, ShowAnim = true}
    end
    Scroll:AddCallback(ModCallbacks.MC_USE_ITEM, PostUseScroll, Scroll.Item);

    local function EvaluateCache(mod, player, flag)
        local data = Scroll.GetPlayerData(player, false);
        local wispCount = 0;
        for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, Scroll.Item)) do
            if (CompareEntity(ent:ToFamiliar().Player, player) and not ent:IsDead()) then
                wispCount = wispCount + 1;
            end
        end
        local times = (data and data.UseTime or 0) + wispCount;
        if (times > 0) then
            if (flag == CacheFlag.CACHE_DAMAGE) then
                Stats:AddDamageUp(player, 0.2 * times);
            elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                Stats:AddTearsUp(player, 0.2 * times);
                -- local maxTimes = 20;
                -- local maxValue = 2.27;
                -- local a = -maxValue / maxTimes ^ 2;
                
                -- Stats:AddTearsModifier(player, function(tears)
                --     if (times > maxTimes) then
                --         return tears + maxValue;
                --     else
                --         return tears + (a * (times - maxTimes) ^ 2 + maxValue);
                --     end
                --     --return tears + times ^0.5 * 0.5
                -- end);
            elseif (flag == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed + 0.03 * times;
            elseif (flag == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange + 16;
            end
        end
    end
    Scroll:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EvaluateCache);

    local function PostWispUpdate(mod, wisp)
        if (wisp.SubType == Scroll.Item and wisp.FrameCount == 5 and wisp.Player) then
            local player = wisp.Player;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end
    end
    Scroll:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PostWispUpdate, FamiliarVariant.WISP);

    local function PostWispRemove(mod, wisp)
        if (wisp.Variant == FamiliarVariant.WISP and wisp.SubType == Scroll.Item and wisp:ToFamiliar().Player) then
            local player = wisp:ToFamiliar().Player;
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED);
            player:EvaluateItems();
        end
    end
    Scroll:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PostWispRemove, EntityType.ENTITY_FAMILIAR);
end

return Scroll;