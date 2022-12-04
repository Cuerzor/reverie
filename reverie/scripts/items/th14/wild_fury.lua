local Stats = CuerLib.Stats;
local Detection = CuerLib.Detection;
local WildFury = ModItem("Wild Fury", "WILD_FURY")

WildFury.Multiplier = 1.5;
WildFury.CostumeId = Isaac.GetCostumeIdByPath("gfx/reverie/characters/costume_wild_fury.anm2");

local function GetPlayerData(player, create)
    return WildFury:GetData(player, create, function()
        return {
            Timeout = -1,
            Growth = 0,
        }
    end)
end

function WildFury:GetEffectTimeout(player)
    local data = GetPlayerData(player, false);
    return (data and data.Timeout) or -1;
end

function WildFury:SetEffectTimeout(player, value)
    local data = GetPlayerData(player, true);
    data.Timeout = value;
end

function WildFury:AddEffectTimeout(player, value)
    self:SetEffectTimeout(player, self:GetEffectTimeout(player) + value);
end


function WildFury:GetGrowth(player)
    local data = GetPlayerData(player, false);
    return (data and data.Growth) or 0;
end

function WildFury:SetGrowth(player, value)
    local data = GetPlayerData(player, true);
    data.Growth = value;
end

function WildFury:AddGrowth(player, value)
    self:SetGrowth(player, self:GetGrowth(player) + value);
end


-- Events.

local function PostPlayerUpdate(mod, player)
    local effects = player:GetEffects();
    local timeout = WildFury:GetEffectTimeout(player);
    if (timeout >= 0) then
        timeout = timeout - 1;

        local red = timeout % 6 < 3;
        local even = (timeout + 2) % 6 < 3;
        
        local r = 1;
        if (red) then
            r = 0.5;
        end
        local color = Color(r,0,0,1,0,0,0);

        if (timeout <= 120) then
            if (even) then
                color.G = r;
                color.B = r;
            end

            if (timeout % 30 == 0) then
                THI.SFXManager:Play(SoundEffect.SOUND_BEEP, 5, 0, false, 0.6)
            end
        end
        player:SetColor(color, 3, -99)

        WildFury:SetEffectTimeout(player, timeout);

        -- When End.
        if (timeout < 0) then
            player.Visible = true;
            effects:RemoveCollectibleEffect(WildFury.Item, -1);
            -- if (effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)) then
            --     effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS);
            -- end
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY);
            player:EvaluateItems();

            player:TryRemoveNullCostume(WildFury.CostumeId);
        end
    end
end
WildFury:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE , PostPlayerUpdate);


local function PostEntityKill(mod, entity)
    if (entity:IsActiveEnemy(true)) then
        for p, player in Detection.PlayerPairs() do
            
            local timeout = WildFury:GetEffectTimeout(player);
            if (timeout >= 0) then
                local Fangs = THI.Effects.WildFangs;
                local fangs = Isaac.Spawn(Fangs.Type, Fangs.Variant, Fangs.SubTypes.BITE, entity.Position, Vector.Zero, entity):ToEffect();
                fangs.DepthOffset = 400;
                local size = entity.Size / 30;
                fangs.SpriteScale = Vector(size, size);

                local npc = entity:ToNPC();
                if (npc) then
                    npc:MakeSplat(size * 5);
                end

                Game():ShakeScreen(5);

                SFXManager():Play(THI.Sounds.SOUND_WILD_BITE, 2);

                WildFury:AddGrowth(player, math.min(10000, entity.MaxHitPoints))
                player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY);
                player:EvaluateItems();
            end
        end
    end
end
WildFury:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL , PostEntityKill);

-- local function PostNewRoom(mod)
--     for p, player in Detection.PlayerPairs() do
        
--         local timeout = WildFury:GetEffectTimeout(player);
--         if (timeout >= 0) then
--             WildFury:SetEffectTimeout(player, -1);
--             player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY);
--             player:EvaluateItems();
--         end
--     end
-- end
-- WildFury:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , PostNewRoom);

local function EvaluateCache(mod, player, flag)
    local timeout = WildFury:GetEffectTimeout(player);
    local growth = WildFury:GetGrowth(player);
    local multiplier = WildFury.Multiplier;
    local Seija = THI.Players.Seija;
    local nerf = Seija:WillPlayerNerf(player);
    local nerfMultiplier = 1;
    if (nerf) then
        nerfMultiplier = 0.9999 ^ growth;
    end
    if (flag == CacheFlag.CACHE_DAMAGE) then
        if (nerf) then
            Stats:MultiplyDamage(player, nerfMultiplier);
        else
            Stats:AddDamageUp(player, growth * 0.001);
        end
        if (timeout >= 0) then
            Stats:MultiplyDamage(player, multiplier);
        end
    else
        if (not THI.IsLunatic()) then
            if (flag == CacheFlag.CACHE_SPEED) then
                if (nerf) then
                    player.MoveSpeed = player.MoveSpeed - growth * 0.0002;
                else
                    player.MoveSpeed = player.MoveSpeed + growth * 0.0002;
                end
                if (timeout >= 0) then
                    player.MoveSpeed = player.MoveSpeed * multiplier;
                end
            elseif (flag == CacheFlag.CACHE_FIREDELAY) then
                Stats:AddTearsModifier(player, function(tears) 
                    if (nerf) then
                        tears = tears * nerfMultiplier;
                    else
                        tears = tears + (growth * 0.001) ^ 0.5;
                    end
                    if (timeout >= 0) then
                        tears = tears * multiplier;
                    end
                    return tears
                end);
            elseif (flag == CacheFlag.CACHE_RANGE) then
                if (nerf) then
                    player.TearRange = player.TearRange - growth * 0.04;
                else
                    player.TearRange = player.TearRange + growth * 0.04;
                end
                if (timeout >= 0) then
                    player.TearRange = player.TearRange * multiplier;
                end
            end
        end
    end
end
WildFury:AddCallback(ModCallbacks.MC_EVALUATE_CACHE , EvaluateCache);

local function PostUseFury(mod, item, rng, player, flags, source, varData)
    local pos = player.Position;
    local wave = Isaac.Spawn(1000,127,1,pos,Vector.Zero,nil):ToEffect();
    wave.CollisionDamage = 76;
    wave.State=1;
    wave.Scale = 55; 
    wave.MaxRadius = 140;
    wave.MinRadius =10;
    wave.TargetPosition = pos;
    wave.DepthOffset = 400;
    
    local Fangs = THI.Effects.WildFangs;
    local fangs = Isaac.Spawn(Fangs.Type,Fangs.Variant,0,pos + Vector(0, -24),Vector.Zero,nil):ToEffect();
    fangs.DepthOffset = 400;

    WildFury:AddEffectTimeout(player, 600);

    Game():ShakeScreen(30);
    SFXManager():Play(THI.Sounds.SOUND_WILD_ROAR, 2);

    
    player:AddNullCostume(WildFury.CostumeId);

    player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FIREDELAY);
    player:EvaluateItems();

    --local flags = UseFlag.USE_NOCOSTUME | UseFlag.USE_NOANIM
    --player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, flags)
end
WildFury:AddCallback(ModCallbacks.MC_USE_ITEM , PostUseFury, WildFury.Item);

return WildFury;