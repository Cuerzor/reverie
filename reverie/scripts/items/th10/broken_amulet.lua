local Screen = CuerLib.Screen;
local Entities = CuerLib.Entities;
local Tears = CuerLib.Tears;
local BrokenAmulet = ModItem("Broken Amulet", "BrokenAmulet");

Tears:RegisterModTearFlag("Reverie Devilhead")
local TearFlag = Tears.TearFlags["Reverie Devilhead"];

function BrokenAmulet:GetTearData(tear, init)
    local data = tear:GetData();
    if (init) then
        if (not data._BROKEN_AMULET) then
            
            data._BROKEN_AMULET = {
                HaloInited = false,
                HaloSprite = nil,
                HaloDamage = 0,
                HaloScale = 0.5
            }
        end
    end
    return data._BROKEN_AMULET;
end

function BrokenAmulet:IsDevilHead(tear)
    local flags = Tears:GetModTearFlags(tear);
    return flags and flags:Has(TearFlag)
end

function BrokenAmulet:AddDevilHead(tear)
    local flags = Tears:GetModTearFlags(tear, true);
    flags:Add(TearFlag)
end

function BrokenAmulet:RemoveDevilHead(tear)
    local flags = Tears:GetModTearFlags(tear, true);
    flags:Remove(TearFlag)
end


function BrokenAmulet:PostFireTear(tear)
    local player;
    local spawner = tear.SpawnerEntity;
    if (spawner) then
        player = spawner:ToPlayer();
    end

    if (player) then
        if (player:HasCollectible(BrokenAmulet.Item)) then
            BrokenAmulet:AddDevilHead(tear);
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, BrokenAmulet.PostFireTear)

function BrokenAmulet:PostTearUpdate(tear)
    if (tear:IsFrame(2, 0)) then

        -- Ludovico Synergies.
        if (tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then
            
            local devilHead = BrokenAmulet:IsDevilHead(tear);

            local player;
            local spawner = tear.SpawnerEntity;
            if (spawner) then
                player = spawner:ToPlayer();
            end

            local shouldDevilHead = player and player:HasCollectible(BrokenAmulet.Item);
            if (devilHead ~= shouldDevilHead) then
                if (shouldDevilHead) then
                    BrokenAmulet:AddDevilHead(tear);
                else
                    BrokenAmulet:RemoveDevilHead(tear);
                end
            end
        end


        if (BrokenAmulet:IsDevilHead(tear)) then
            local data = BrokenAmulet:GetTearData(tear, true);
            if (data) then
                -- Init Halo.
                if (not data.HaloInited) then
                    data.HaloInited = true;
                    local spawner = tear.SpawnerEntity;
                    local player = nil;
                    while (spawner) do
                        local p = spawner:ToPlayer();
                        if (p) then
                            player = p;
                            break;
                        end
                        spawner = spawner.SpawnerEntity;
                    end
                    if (player) then
                        local luck = player.Luck;
                        local haloScale = math.min(1, math.max(0.5, 0.5 + player.Luck / -5 * 0.5));
                        local damage = math.min(0.8, math.max(0.2, 0.2 + player.Luck / -5 * 0.6));
                        data.HaloScale = haloScale;
                        data.HaloDamage = player.Damage * damage;

                        local spr = Sprite();
                        spr:Load("gfx/reverie/unfortune_halo.anm2", true);
                        spr:Play("Idle")
                        spr.Scale = Vector(tear.Scale * haloScale, tear.Scale * haloScale);
                        data.HaloSprite = spr;
                    end
                end

                -- Update Halo.
                local scale = tear.Scale * data.HaloScale;
                if (data.HaloSprite) then
                    data.HaloSprite:Update();
                    data.HaloSprite.Scale = Vector(scale, scale);
                end
                
                local player;
                local spawner = tear.SpawnerEntity;
                if (spawner) then
                    player = spawner:ToPlayer();
                end
                local size = scale * 100;
                for i, ent in pairs(Isaac.FindInRadius(tear.Position, size, EntityPartition.ENEMY)) do
                    if (Entities.IsValidEnemy(ent)) then
                        ent:TakeDamage(data.HaloDamage, 0, EntityRef(player), 0);
                    end
                end
            end
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, BrokenAmulet.PostTearUpdate)

function BrokenAmulet:PostTearRender(tear, offset)
    if (BrokenAmulet:IsDevilHead(tear)) then
        local data = BrokenAmulet:GetTearData(tear, true);
        if (data and data.HaloSprite) then
            local pos = Screen.GetEntityOffsetedRenderPosition(tear, offset);
            data.HaloSprite:Render(pos);
        end
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, BrokenAmulet.PostTearRender)


function BrokenAmulet:EvaluateCache(player, cache)
    if (cache == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck - player:GetCollectibleNum(BrokenAmulet.Item) * 3;
    end
end
BrokenAmulet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BrokenAmulet.EvaluateCache)

return BrokenAmulet;